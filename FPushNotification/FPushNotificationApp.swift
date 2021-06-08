//
//  FPushNotificationApp.swift
//  FPushNotification
//
//  Created by Darrien Huntley on 6/7/21.
//

import SwiftUI
import Firebase


// Set up Steps ...


/*
 
 INSTALL CAPABILITIES
 1. Signing and capavbilites
 2. Add - push notification
 3. Add background mode ( check the last 3 options [fetch | remote | processing])
 
 
 
 INSTALL FIREBASE....
 1. FirebaseMessaging
 2. In XCode: copy google file - reserved client id
 3. appname | info
 4. + url type
 5. paste into URL scheme
 
 INSTALL KEY
 1. https://developer.apple.com/account/resources/authkeys/list
 2. Create key - Download (keep safe)
 3. In Firebase : Settings | Cloud Messaging
 4. APNs Authorization Key
 5. Upload
 6. Drag in Auth Key you dowloaded
 7. id - End of file text after underscore - .... ex.OIFIJGOVV
 8. Team ID [Under Membership:] https://developer.apple.com/account/#/membership/SNW84Q39QZ
 
 
 
 COPY TOKEN
 1. fE0ZOoDSYUrGugTmTxC58O:APA91bH8_eO5CaTkUWowoCLwzVGpQaWJOOQ6TWpdKApiZwMWoFHXHlD13oc7odhzjJaQtnzqBWARZh4QYMa9vOaIyETnpArdBKgPKJJGFzI4-OBchsB0NnI1ExHhlSILEKwmTs33nwgn"
 
 
 
 
 
 
 
 */


@main
struct FPushNotificationApp: App {
    
    // Calling Delegate...
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            CreateNotificationView()
        }
    }
}




// Intializing Firebase...
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    let gcmMessageIDKey = "HDarrien.me"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Setting Up Notification
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        
        // Setting Up Cloud Messanging
        Messaging.messaging().delegate = self
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token : \(error)")
            } else if let token = token {
                print("DEBUG: FCM registration token : \(token)")
                //  print("Remote FCM registration token: \(token)")
                
            }
        }
        
        // FirebaseApp.configure()
        
        return true
    }
    
    // MARK: UISceneSession Lifestyle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options : UIScene.ConnectionOptions ) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    // ----------- MESSAGING -----------
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        
        // Store token in Firestore For Sending Notifcation ...
        
        print("BEBUG DataDict : \(dataDict)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        print("DEBUG: User Info 2: \(userInfo)")
        
        
        completionHandler([[.banner, .list, .sound]])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        print("DEBUG: User Info 3: \(userInfo)")
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)

        // Action with Message Data Here..
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print("DEBUG: User Info 1: \(userInfo)")
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
}




//
//// Intializing Firebase...
//class AppDelegate: NSObject, UIApplicationDelegate {
//
//    let gcmMessageIDKey = "gcm.message_id"
//
//    func application(_ application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//
//        FirebaseApp.configure()
//
//        // Setting Up Cloud Messanging
//        Messaging.messaging().delegate = self
//
//        // Setting Up Notification
//        if #available(iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = self
//
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: {_, _ in })
//        } else {
//            let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//
//        application.registerForRemoteNotifications()
//        return true
//    }
//
//
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//
//        // Action with Message Data Here..
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//
//        print("DEBUG: User Info 1: \(userInfo)")
//        completionHandler(UIBackgroundFetchResult.newData)
//    }
//
//    // In order to receive notification ...
//    // didfa...
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//
//    }
//
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
//    }
//
//}
//
//// Cloud Message...
//
//extension AppDelegate : MessagingDelegate {
//
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("Firebase registration token: \(String(describing: fcmToken))")
//
//        let dataDict:[String: String] = ["token": fcmToken ?? ""]
//
//        // Store token in Firestore For Sending Notifcation ...
//
//        print("BEBUG DataDict : \(dataDict)")
//    }
//
//}
//
//
//// User Notifications [AKA InApp Notifications] ....
//
//@available(iOS 10, *)
//extension AppDelegate : UNUserNotificationCenterDelegate {
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//
//        // Action with MSG Data...
//
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//
//        print("DEBUG: User Info 2: \(userInfo)")
//
//
//        completionHandler([[.banner, .badge, .sound]])
//
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//
//
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//        // Action with MSG Data...
//        print(userInfo)
//
//        completionHandler()
//    }
//
//
//}
