//
//  AppDelegate.swift
//  GPXCreator
//
//  Created by user on 2018/11/01.
//  Copyright © 2018年 user. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var backgroundTaskIdentifier:UIBackgroundTaskIdentifier? = nil


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("バックグラウンドへいきました")
        
        if LocationDataManager.shared.isStarting {
            
            // 計測中であるのならば
            
            // 延長申請
            self.backgroundTaskIdentifier = application.beginBackgroundTask(expirationHandler: {
                print("一応ずっと動いてよいはずです。実機だとこれが呼ばれません")
            })
            
            print("バックグランド動作を開始します")
            
            // 通知を出す
            self.showAlertNotification()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - 自作メソッド
    func showAlertNotification() {
        // 通知の内容をつくる
        let content = UNMutableNotificationContent()
        content.title = "位置情報トラッカーが稼働中です"
        content.body = "測定しています"
        
        // これは1秒後をきっかけとするトリガー
        let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // 通知リクエストオブジェクトにまとめる
        let notificationRequest = UNNotificationRequest(identifier: "myNotification1", content: content, trigger: timeTrigger)
        
        // ユーザー通知センターの共有インスタンスを得る
        let userNotificationCenter = UNUserNotificationCenter.current()        
        // ユーザー通知センターに登録
        userNotificationCenter.add(notificationRequest, withCompletionHandler: nil)
    }
}

