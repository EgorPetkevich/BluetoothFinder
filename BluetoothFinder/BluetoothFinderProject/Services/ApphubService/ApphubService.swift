//
//  ApphubService.swift
//  blekokofinder
//
//  Created by George Popkich on 1.07.25.
//

import Foundation
import ApphudSDK
import StoreKit
import SwiftUI
import Combine

@MainActor
final class ApphudService: ObservableObject {
    
    enum PurchaseType: Int {
        case weekly
        case trial
        
        var productId: String {
            switch self {
            case .weekly: return "com.finder.ble.application.weekly"
            case .trial: return "com.finder.ble.application.weekly.trial"
            }
        }
    }
    
    var inappPaywall: ApphudPaywall?
    var onbordingPaywall: ApphudPaywall?
    
    private let inappID = "inapp_paywall"
    private let onboadingID = "onboarding_paywall"
    
    static let instance = ApphudService()
    
    @Published var paywallView: AnyView? = nil
    @Published var paywallWasShown: Bool = false
    
    @Published var paywall: ApphudPaywall?
    @Published var remoteConfig: RemoteConfig?
    @Published var products: [ApphudProduct]?
    
    //MARK: - Review
    @Published var isPremium: Bool = /*Apphud.hasActiveSubscription()*/ true
    @Published var productTrialPrice: String?
    @Published var productWeeklyPrice: String?
    
    
    
    private init() {
        //MARK: - Review
//        Task {
//            await loadPaywall()
//        }
    }

    enum RemoteConfigError: Error {
        case failedToFetch
    }

    func getRemoteConfig() async throws -> RemoteConfig {
        
        guard let config =  await fetchRemoteConfig() else {
           
            throw NSError(domain: "RemoteConfig",
                          code: 0,
                          userInfo: [NSLocalizedDescriptionKey: 
                                        "[Error] Load RemoteConfig"
                                    ])
        }
        UDManager.setOnbTimerValue(config.onboarding_close_delay)
        UDManager.setTimerValue(config.paywall_close_delay)
        UDManager.setValue(forKey: .isReview, value: config.is_review_enabled)
        UDManager.setValue(forKey: .is_paging_enabled, value: config.is_paging_enabled)
        UDManager.setTitleText(for: .onboarding_button_title, text: config.onboarding_button_title)
        UDManager.setTitleText(for: .paywall_button_title, text: config.paywall_button_title)
        UDManager.onbordingSubtitleAlpha(config.onboarding_subtitle_alpha)
        
        if let products {
            UDManager.setValue(forKey: .hasTrial,
                               value: products
                .contains {$0.productId.lowercased().contains("trial")})
        }
       
        return config
    }
    
    private func loadPaywall() async {
        do {
            let config = try await getRemoteConfig()
            DispatchQueue.main.async {
                
                self.paywallView = AnyView(BLEKokoInRevPaywall(dismissHandler: {
                    self.paywallWasShown = true
                    self.paywallView = nil
                }))
                
            }
        } catch {
            print("[Error] Load Paywall: \(error)")
        }
    }
    
    func checkStatus() -> Bool {
        //MARK: - Review
        return true
//        return Apphud.hasActiveSubscription()
    }

    func getProductPrice(type: PurchaseType) async -> String? {
        await fetchProducts()

        guard let product = products?.first(where: { $0.productId == type.productId}) else {
            print("[ERROR] Product with ID \(type.productId) not found.")
            return nil
        }
        
        guard let skProduct = product.skProduct else {
            print("[ERROR] skProduct is nil for product ID \(type.productId).")
            return nil
        }
        return skProduct.localizedCurrencyPrice
    }
    
    func makePurchase(type: PurchaseType) async -> Bool {

        return true
//        await fetchProducts()
//        
//        guard let product = products?.first(where: { $0.productId == type.productId }) else {
//            print("[ERROR] Product not found for \(type.productId)")
//            return false
//        }
//        
//        let result = await withCheckedContinuation { continuation in
//            Apphud.purchase(product) { result in
//                if let subscription = result.subscription, subscription.isActive() {
//                    print("Subscription active for \(type.productId)")
//                    continuation.resume(returning: true)
//                } else if let nonRenewingPurchase = result.nonRenewingPurchase, nonRenewingPurchase.isActive() {
//                    print("Non-renewing purchase active for \(type.productId)")
//                    continuation.resume(returning: true)
//                } else if let error = result.error {
//                    print("[ERROR] Purchase failed: \(error.localizedDescription)")
//                    continuation.resume(returning: false)
//                } else {
//                    print("[ERROR] Unknown purchase state for \(type.productId)")
//                    continuation.resume(returning: false)
//                }
//            }
//        }
//        
//        isPremium = result
//        UDManager.setValue(forKey: .isPremium, value: result)
//        return result
    }


    func restorePurchases() async -> Bool {

        return true
//        let result = await withCheckedContinuation { continuation in
//            Apphud.restorePurchases { [weak self] subscriptions, _, error in
//                if let error = error {
//                    print("[RESTORE FAILURE]: \(error.localizedDescription)")
//                    continuation.resume(returning: false)
//                    return
//                }
//                
//                let isPremium = subscriptions?.contains(where: { $0.isActive() }) ?? false
//                self?.isPremium = isPremium
//                print("[RESTORE SUCCESS]: Access \(isPremium ? "restored" : "not restored")")
//                continuation.resume(returning: isPremium)
//            }
//        }
//        UDManager.setValue(forKey: .isPremium, value: result)
//        return result
    }

    private func fetchRemoteConfig() async -> RemoteConfig? {
        if let paywall = paywall {
            return decodeRemoteConfig(from: paywall)
        } else {
            let fetchedPaywall = await fetchPaywall()
            self.paywall = fetchedPaywall
            await fetchProducts()
            return decodeRemoteConfig(from: fetchedPaywall)
        }
    }
    
    private func fetchPaywall() async -> ApphudPaywall? {
        await withCheckedContinuation { continuation in
            Apphud.paywallsDidLoadCallback { paywalls, error in
                var id: String
                if UDManager.getValue(forKey: .isOnboarding) {
                    id = self.onboadingID
                } else {
                    id = self.inappID
                }
                
                self.onbordingPaywall = paywalls.first(where: { $0.identifier == self.onboadingID })
                self.inappPaywall = paywalls.first(where: { $0.identifier == self.inappID })
                
                if let paywall = paywalls.first(where: { $0.identifier == id }) {
                    
                    continuation.resume(returning: paywall)
                } else {
                    print("[ERROR] Paywall not found")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    private func decodeRemoteConfig(from paywall: ApphudPaywall?) -> RemoteConfig? {
   
        guard let json = paywall?.json else { return nil }

        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            var config = try JSONDecoder().decode(RemoteConfig.self, from: data)
            return config
        } catch {
            print("[ERROR] Failed to decode remote config: \(error)")
            return nil
        }
    }
    
    private func fetchProducts() async {
        if let paywall = paywall {
            products = paywall.products
            
        } else {
            let fetchedPaywall = await fetchPaywall()
            self.paywall = fetchedPaywall
            self.products = fetchedPaywall?.products
        }
    }
    
    private func updateProductPrices() async {
        productTrialPrice = await getProductPrice(type: .trial)
        productWeeklyPrice = await getProductPrice(type: .weekly)
    }
}


