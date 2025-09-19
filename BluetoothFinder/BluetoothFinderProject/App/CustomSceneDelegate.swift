//
//  CustomSceneDelegate.swift
//  blekokofinder
//
//  Created by George Popkich on 16.07.25.
//

import UIKit

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        QuickActionsManager.instance.handle(shortcutItem: shortcutItem)
        completionHandler(true)
    }
}
