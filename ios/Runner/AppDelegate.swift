import UIKit
import Flutter
import FirebaseCore
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//    GMSServices.provideAPIKey("AIzaSyCXOJJDB-5gGJPkMXcy4S6GwOj9mFdprbQ")
//    GeneratedPluginRegistrant.register(with: self)
//      if FirebaseApp.app() == nil {           FirebaseApp.configure()      }
//    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//  }
//
    var webUrl:String?;
    var filePath:String?;
    
    override func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        webUrl = userActivity.webpageURL?.absoluteString
    }

    override func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

      webUrl = userActivity.webpageURL?.absoluteString
        return true;
    }
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GMSServices.provideAPIKey("AIzaSyCXOJJDB-5gGJPkMXcy4S6GwOj9mFdprbQ")
      if FirebaseApp.app() == nil {           FirebaseApp.configure()      }
      
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let batteryChannel = FlutterMethodChannel(name: "app.channel.shared.data",
                                                binaryMessenger: controller.binaryMessenger)
      batteryChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        // Note: this method is invoked on the UI thread.
        // Handle battery messages.
          if( call.method == "deep-link"){
              if(self.webUrl != nil ){
              result(self.webUrl)
              }else{
                  
                  result(nil);
              }
              self.webUrl = nil
          }else{
              result(nil);
          }
      })
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
