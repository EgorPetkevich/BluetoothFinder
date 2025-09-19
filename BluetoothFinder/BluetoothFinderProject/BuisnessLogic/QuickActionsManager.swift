//
//  QuickActionsManager.swift
//  blekokofinder
//
//  Created by George Popkich on 16.07.25.
//

import UIKit
import Combine

final class QuickActionsManager: ObservableObject {
    
    static let instance = QuickActionsManager()
    
    enum QuickActionType: String {
        case feedback
        case cancel
        case help
    }
    
    @Published var quickAction: QuickActionType?
    
    func handle(shortcutItem: UIApplicationShortcutItem) {
        guard let type = QuickActionType(rawValue: shortcutItem.type) else { return }
        DispatchQueue.main.async {
            self.quickAction = type
        }
    }
}
