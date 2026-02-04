import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var securityChannel: FlutterMethodChannel?
  private var isScreenCaptured = false
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup method channel for security
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    securityChannel = FlutterMethodChannel(
      name: "com.zztherapy/security",
      binaryMessenger: controller.binaryMessenger
    )
    
    securityChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      
      switch call.method {
      case "startScreenCaptureDetection":
        self.startScreenCaptureDetection()
        result(nil)
      case "stopScreenCaptureDetection":
        self.stopScreenCaptureDetection()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func startScreenCaptureDetection() {
    // Listen for screen capture notifications
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureDidChange),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    
    // Check initial state
    checkScreenCaptureStatus()
  }
  
  private func stopScreenCaptureDetection() {
    NotificationCenter.default.removeObserver(
      self,
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
  }
  
  @objc private func screenCaptureDidChange() {
    checkScreenCaptureStatus()
  }
  
  private func checkScreenCaptureStatus() {
    let isCaptured = UIScreen.main.isCaptured
    
    if isCaptured != isScreenCaptured {
      isScreenCaptured = isCaptured
      
      // Notify Flutter about screen capture state change
      securityChannel?.invokeMethod("onScreenCaptureChanged", arguments: isCaptured)
    }
  }
}
