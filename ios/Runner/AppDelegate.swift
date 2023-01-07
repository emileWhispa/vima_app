import UIKit
import Flutter
import FirebaseCore
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCXOJJDB-5gGJPkMXcy4S6GwOj9mFdprbQ")
    GeneratedPluginRegistrant.register(with: self)
      if FirebaseApp.app() == nil {           FirebaseApp.configure()      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
