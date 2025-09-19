//
//  AppDelegate.swift
//  blekokofinder
//
//  Created by George Popkich on 16.07.25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        if let shortcutItem = options.shortcutItem {
            QuickActionsManager.instance.handle(shortcutItem: shortcutItem)
        }
        
        let sceneConfig = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = CustomSceneDelegate.self
        return sceneConfig
    }
}





