//
//  ViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/20.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import GoogleSignIn
import UserNotifications

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
        
        //원격 알림 설정
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        //메시지 델리겟
        Messaging.messaging().delegate = self
        
        // 푸쉬 포그라운드 설정
        UNUserNotificationCenter.current().delegate = self
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
    
    // fcm 토큰이 등록이 되었을 때
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
      print("[Log] deviceToken :", deviceTokenString)
        
      Messaging.messaging().apnsToken = deviceToken
    }
    
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    // 푸쉬 메시지가 앱이 켜져 있을 때 나올 때
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      
      let userInfo = notification.request.content.userInfo
      
      print("willPresent: userInfo : ", userInfo)
  
      completionHandler([.banner,.sound,.badge])
  }
  
    //푸쉬메시지를 받았을 때
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
      let userInfo = response.notification.request.content.userInfo
      
      print("didReceive: userInfo : ", userInfo)
      
      completionHandler()
  }
}

//MARK:- FCM
extension AppDelegate: MessagingDelegate {
    
    // fcm 등록 토큰을 받았을 때
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
    }
    
    // 받은 메시지 처리
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // TODO: Handle data of notification
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
}

