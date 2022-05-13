//
//  ViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/20.
//

import UIKit
import Firebase
import FirebaseMessaging
import GoogleSignIn
import UserNotifications
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
    -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if(error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("not signed in before or signed out")
            } else {
                print(error.localizedDescription)
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {// Use Firebase library to configure APIs
       
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        
        if let user = Auth.auth().currentUser {
            print("You're sign in as \(user.uid), email: \(user.email ?? "no email")")
        }
        
        Messaging.messaging().delegate = self
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions,completionHandler: {_, _ in })
            application.registerForRemoteNotifications()
//        GIDSignIn.sharedInstance()?.clientID = "382918594867-akdm60fcq7msffhgglug1eou939g2ebh.apps.googleusercontent.com"
//        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         Messaging.messaging().apnsToken = deviceToken
      }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("\(#function)")
  }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String!) {
    print("Firebase registration token: \(fcmToken)")
    let dataDict:[String: String] = ["token": fcmToken]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
  }
}

