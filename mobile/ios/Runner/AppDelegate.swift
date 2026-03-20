import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, UNUserNotificationCenterDelegate {
  private let pushChannelName = "app.splyto/push"
  private var cachedPushToken: String?
  private var pendingPushTokenResult: FlutterResult?

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
        self.pendingPushTokenResult = result
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    cachedPushToken = token

    if let pendingResult = pendingPushTokenResult {
      pendingPushTokenResult = nil
      pendingResult(token)
    }

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
