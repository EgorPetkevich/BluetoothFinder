//
//  UDManager.swift
//  blekokofinder
//
//  Created by George Popkich on 1.07.25.
//

import Foundation

final class UDManager {

    enum Keys: String {
        case isOnboarding = "isOnboarding"
        case onboardingTimer = "onboardingTimer"
        case timer = "timer"
        case isPremium = "isPremium"
        case isReview = "isReview"
        case hasTrial = "hasTrial"
        
        case onboarding_button_title = "onboarding_button_title"
        case paywall_button_title = "paywall_button_title"
        case onboarding_subtitle_alpha = "onboarding_subtitle_alpha"
        case is_paging_enabled = "is_paging_enabled"
    }
    
    private static var ud: UserDefaults = .standard
    
    private init() {}
    
    static func setValue(forKey key: Keys, value: Bool) {
        ud.setValue(value, forKey: key.rawValue)
    }
    
    static func setTitleText(for key: Keys, text: String?) {
        ud.setValue(text, forKey: key.rawValue)
    }
    
    static func getValue(forKey key: Keys) -> Bool {
        return ud.bool(forKey: key.rawValue)
    }
    
    static func setAppStatus(isPremium value: Bool) {
        ud.set(true, forKey: Keys.isPremium.rawValue)
    }
    
    static func isPremium() -> Bool {
//        getValue(forKey: .isPremium)
        true
    }
    
    static func setTimerValue(_ timer: Double) {
        ud.set(timer, forKey: Keys.timer.rawValue)
    }
    
    static func setOnbTimerValue(_ timer: Double) {
        ud.set(timer, forKey: Keys.onboardingTimer.rawValue)
    }
    
    static func onbordingSubtitleAlpha(_ alpha: Double) {
        ud.set(alpha, forKey: Keys.onboarding_subtitle_alpha.rawValue)
    }
    
    static func getSubtitleAlpha() -> Double {
        if let value = ud.value(forKey: Keys.onboarding_subtitle_alpha.rawValue) as? Double {
            return value
        }
        return 1
    }
    
    static func getTimerValue() -> Double {
        if let value = ud.value(forKey: Keys.timer.rawValue) as? Double {
            return value
        }
        return 0
    }
    
    static func getOnbTimerValue() -> Double {
        if let value = ud.value(forKey: Keys.onboardingTimer.rawValue) as? Double {
            return value
        }
        return 0
    }
    
    static func getOnbButtonTitleText() -> String? {
        ud.value(forKey: Keys.onboarding_button_title.rawValue) as? String
    }
    
    static func getPaywallButtonTitleText() -> String? {
        ud.value(forKey: Keys.paywall_button_title.rawValue) as? String
    }
}
