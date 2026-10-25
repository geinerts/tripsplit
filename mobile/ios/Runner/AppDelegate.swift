import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let pushChannelName = "app.splyto/push"
  private var cachedPushToken: String?
  private var pendingPushTokenResult: FlutterResult?

  private enum PushPermissionState {
    case authorized
    case notDetermined
    case denied
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SplytoWindowLayout") {
      let layoutChannel = FlutterMethodChannel(
        name: "app.splyto/window_layout", binaryMessenger: registrar.messenger())
      layoutChannel.setMethodCallHandler { [weak registrar] call, result in
        guard call.method == "getLayout" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard #available(iOS 27.1, *), let view = registrar?.viewController?.view,
              view.window != nil else {
          result(nil)
          return
        }
        // UIKit knows the camera/status region, including its interactive margins.
        // Ask for a full-width safe rectangle below it instead of guessing a
        // camera height from a device name or the horizontal Flutter inset.
        var insets = view.edgeInsets(for: .safeArea(cornerAdaptation: .vertical))
        let occlusions = view.reservedRegions(kind: .occlusion).filter { $0.isActive }
        let obstructionBottom = occlusions.map { $0.frame.maxY }.max() ?? 0
        // Only reclaim a side inset when UIKit identifies all obstructions in
        // the upper part of this window. Ordinary landscape notches keep their
        // standard safe area. Keep the unobstructed side's base margin on both
        // sides; the vertical safe-area bottom still protects rounded corners.
        if view.safeAreaInsets.left + view.safeAreaInsets.right > 0,
           obstructionBottom > 0, obstructionBottom < view.bounds.height * 0.4 {
          let sideMargin = min(insets.left, insets.right)
          insets = UIEdgeInsets(top: max(obstructionBottom, insets.top),
                                left: sideMargin, bottom: insets.bottom,
                                right: sideMargin)
        }
        result([
          "width": view.bounds.width, "height": view.bounds.height,
          "left": insets.left, "top": insets.top,
          "right": insets.right, "bottom": insets.bottom
        ])
      }
    }
    let messenger = engineBridge.applicationRegistrar.messenger()
    let pushChannel = FlutterMethodChannel(name: pushChannelName, binaryMessenger: messenger)
    pushChannel.setMethodCallHandler { [weak self] call, result in
      self?.handlePushMethodCall(call: call, result: result)
    }
  }

  private func handlePushMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestPushToken":
      requestPushToken(result: result)
    case "getCachedPushToken":
      result(cachedPushToken)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestPushToken(result: @escaping FlutterResult) {
    if let token = cachedPushToken, !token.isEmpty {
      result(token)
      return
    }

    resolvePushPermissionState { [weak self] permissionState in
      guard let self else {
        return
      }

      switch permissionState {
      case .authorized:
        DispatchQueue.main.async {
          self.finishPushTokenRegistration(result: result)
        }
      case .notDetermined:
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
          [weak self] granted, _ in
          guard let self else {
            return
          }
          if !granted {
            DispatchQueue.main.async {
              result(nil)
            }
            return
          }
          DispatchQueue.main.async {
            self.finishPushTokenRegistration(result: result)
          }
        }
      case .denied:
        DispatchQueue.main.async {
          result(nil)
        }
      }
    }
  }

  private func resolvePushPermissionState(
    completion: @escaping (PushPermissionState) -> Void
  ) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .authorized, .provisional, .ephemeral:
        completion(.authorized)
      case .notDetermined:
        completion(.notDetermined)
      case .denied:
        completion(.denied)
      @unknown default:
        completion(.denied)
      }
    }
  }

  private func finishPushTokenRegistration(result: @escaping FlutterResult) {
    if let token = cachedPushToken, !token.isEmpty {
      result(token)
      return
    }
    pendingPushTokenResult = result
    UIApplication.shared.registerForRemoteNotifications()
  }

  private func hexDeviceToken(_ deviceToken: Data) -> String {
    deviceToken.map { String(format: "%02x", $0) }.joined()
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = hexDeviceToken(deviceToken).trimmingCharacters(in: .whitespacesAndNewlines)
    let pendingResult = pendingPushTokenResult
    pendingPushTokenResult = nil
    cachedPushToken = token.isEmpty ? nil : token
    pendingResult?(cachedPushToken)

    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    if let pendingResult = pendingPushTokenResult {
      pendingPushTokenResult = nil
      pendingResult(nil)
    }
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
