import Flutter
import UIKit
import flutter_inappwebview_ios

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let flutterViewController = window?.rootViewController as? FlutterViewController {
      InAppWebViewFlutterPlugin.register(with: flutterViewController.registrar(forPlugin: "InAppWebViewFlutterPlugin")!)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
