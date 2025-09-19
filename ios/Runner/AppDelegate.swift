import Flutter
import UIKit
import UMCommon


@main
@objc class AppDelegate: FlutterAppDelegate {
  
    //let storeManager = StoreManager()
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let generalChannel = FlutterMethodChannel(name: "ParlerAI/general_channel", binaryMessenger: controller.binaryMessenger)
        generalChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if (call.method == "log_event") {
                self.sendLogEvent(args: call.arguments)
                result("")
            } else if (call.method == "signin_with_apple") {
//                self.signInWithApple { data in
//                    result(data)
//                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected dictionary arguments", details: nil))
            }
        })
        
        self.initSDKs()
//        self.setupNotification(application)
        self.handleInAppPurchases()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func initSDKs() {
        let umApiKey = "67c5c16f9a16fe6dcd58d497"
        UMConfigure.initWithAppkey(umApiKey, channel: "")
    }
    
//    private func setupNotification(_ application: UIApplication) {
//        UNUserNotificationCenter.current().delegate = self
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(
//          options: authOptions,
//          completionHandler: { _, _ in }
//        )
//        application.registerForRemoteNotifications()
//    }
    
    private func sendLogEvent(args: Any?) {
        if let arguments = args as? [String: Any] {
            let k = arguments["key"] as? String
            let v = arguments["value"] as? [String: Any] ?? [:]
            if let _k = k, !_k.isEmpty {
                MobClick.event(_k, attributes: v)
            }
        }
    }
    
    
    private func handleInAppPurchases() {
        //storeManager.requestInAppPurchasesProducts(["macopine.plus.monthly"])
    }
    
    
}



//extension UINavigationController {
//     open override var preferredStatusBarStyle: UIStatusBarStyle {
//         return .darkContent
//     }
// }
