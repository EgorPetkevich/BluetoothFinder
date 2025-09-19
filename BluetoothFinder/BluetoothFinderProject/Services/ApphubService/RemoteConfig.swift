//
//  RemouteConfig.swift
//  blekokofinder
//
//  Created by George Popkich on 1.07.25.
//

import Foundation

struct RemoteConfig: Codable {
    let onboarding_button_title: String?
    let paywall_button_title: String?
    let is_review_enabled: Bool
    let onboarding_subtitle_alpha: Double
    let onboarding_close_delay: Double
    let paywall_close_delay: Double
    let is_paging_enabled: Bool
    
}
