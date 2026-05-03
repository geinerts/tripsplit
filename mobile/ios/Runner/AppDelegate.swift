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
