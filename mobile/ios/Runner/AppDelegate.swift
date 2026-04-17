import Flutter
import FirebaseCore
import FirebaseMessaging
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, MessagingDelegate {
  private let pushChannelName = "app.splyto/push"
  private var cachedPushToken: String?
  private var pendingPushTokenResult: FlutterResult?
  private var firebaseConfigured = false

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
    firebaseConfigured = configureFirebaseIfNeeded()
    if firebaseConfigured {
      Messaging.messaging().delegate = self
    }
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
    if !firebaseConfigured {
      firebaseConfigured = configureFirebaseIfNeeded()
    }
    if !firebaseConfigured {
      result(nil)
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

  private func configureFirebaseIfNeeded() -> Bool {
    if FirebaseApp.app() != nil {
      return true
    }
    guard
      let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
      let options = FirebaseOptions(contentsOfFile: plistPath)
    else {
      return false
    }
    FirebaseApp.configure(options: options)
    return FirebaseApp.app() != nil
  }

  private func fetchFcmToken(result: FlutterResult? = nil) {
    if !firebaseConfigured {
      result?(nil)
      return
    }
    Messaging.messaging().token { [weak self] token, _ in
      guard let self else {
        return
      }
      let value = (token ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
      DispatchQueue.main.async {
        if value.isEmpty {
          result?(nil)
          return
        }
        self.cachedPushToken = value
        result?(value)
      }
    }
  }

  private func apnsTokenType() -> MessagingAPNSTokenType {
    #if DEBUG
      return .sandbox
    #else
      return .prod
    #endif
  }

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    let token = (fcmToken ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    if token.isEmpty {
      return
    }
    cachedPushToken = token
    if let pendingResult = pendingPushTokenResult {
      pendingPushTokenResult = nil
      pendingResult(token)
    }
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    if !firebaseConfigured {
      firebaseConfigured = configureFirebaseIfNeeded()
    }
    let pendingResult = pendingPushTokenResult
    pendingPushTokenResult = nil
    if firebaseConfigured {
      Messaging.messaging().setAPNSToken(deviceToken, type: apnsTokenType())
      fetchFcmToken(result: pendingResult)
    } else {
      pendingResult?(nil)
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
