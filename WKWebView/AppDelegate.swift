//
//  AppDelegate.swift
//  KWKWebView
//
//  Created by Channing Kuo on 2020/10/15.
//

import UIKit
import CoreData

//JPUSHRegisterDelegate
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // TODO 极光推送暂不接入
//        let entity = JPUSHRegisterEntity()
//        entity.types = Int(JPAuthorizationOptions.alert.union(JPAuthorizationOptions.badge).union(JPAuthorizationOptions.sound).union(JPAuthorizationOptions.providesAppNotificationSettings).rawValue)
//
//        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
//
//        #if DEBUG
//        JPUSHService.setup(withOption: launchOptions, appKey: "bde096b860e2f33960751d5e", channel: "YSW-CHANNEL", apsForProduction: false)
//        #else
//        JPUSHService.setup(withOption: launchOptions, appKey: "bde096b860e2f33960751d5e", channel: "YSW-CHANNEL", apsForProduction: true)
//        #endif
        
        FileUtils.setupHtml()
        
        return true
    }
    
    // MARK: JPush Lifecycle
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        JPUSHService.registerDeviceToken(deviceToken)
//    }
//
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        debugPrint("did Fail To Register For Remote Notifications With Error: %@", error)
//    }
//
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        JPUSHService.handleRemoteNotification(userInfo)
//        completionHandler(UIBackgroundFetchResult.newData)
//    }
//
//    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
//        let userInfo = notification.request.content.userInfo
//
//        if ((notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self)) != nil) {
//            JPUSHService.handleRemoteNotification(userInfo)
//        }
//        completionHandler(Int(UNNotificationPresentationOptions.list.rawValue))
//    }
//
//    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
//        let userInfo = response.notification.request.content.userInfo
//
//        if ((response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self)) != nil) {
//            JPUSHService.handleRemoteNotification(userInfo)
//        }
//        completionHandler()
//    }
//
//    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
//        if (notification != nil) && ((notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self)) != nil) {
//            // 从通知界面直接进入应用
//        } else {
//            // 从通知设置界面进入应用
//        }
//    }
//
//    func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable : Any]!) {
//
//    }

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

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "KWKWebView")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

