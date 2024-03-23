//
//  AppDelegate.swift
//  Gangyebab
//
//  Created by 이동현 on 3/7/24.
//

import UIKit
import SwiftRater

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var dbManager = DBManager.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dbManager.createTodoTable()
        dbManager.createRepeatTable()
        UIFont.registerCustomFonts()
        
        SwiftRater.daysUntilPrompt = 7
        SwiftRater.usesUntilPrompt = 80
        SwiftRater.daysBeforeReminding = 10
        SwiftRater.showLaterButton = true
        SwiftRater.appLaunched()
        
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


}

