//
//  SkProduct+localized.swift
//  blekokofinder
//
//  Created by George Popkich on 1.07.25.
//

import StoreKit

extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        if let scene =
            UIApplication
            .shared
            .connectedScenes
            .first(where:
                    { $0.activationState == .foregroundActive }
            ) as? UIWindowScene {
            DispatchQueue.main.async {
                requestReview(in: scene)
            }
        }
    }
}

extension SKProduct {
    
    var localizedCurrencyPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
    
}
