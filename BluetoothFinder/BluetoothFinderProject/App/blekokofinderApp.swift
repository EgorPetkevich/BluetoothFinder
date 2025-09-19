//
//  blekokofinderApp.swift
//  blekokofinder
//
//  Created by Developer on 13.06.25.
//

import SwiftUI
import ApphudSDK
import StoreKit
import MessageUI
import CoreData

@main
struct PDFMasterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var quickActions = QuickActionsManager.instance
    
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @AppStorage("isPremium") var isPremium: Bool = true
    
    @StateObject private var apphudService = ApphudService.instance
    @State private var showMail: Bool = false
    @State private var mailErrorAlert: Bool = false

    let persistence = DataStorageManager.shared
   
    init() {
        //MARK: - Review
//        Apphud.start(apiKey: AppConfig.apphudKEY)
//        isPremium = Apphud.hasActiveSubscription()
    }
        
    var body: some Scene {
        WindowGroup {
            Group {
                if isOnboarding {
                    BLEKokoProdOnboardFirst(apphudService: apphudService)
                } else if isPremium || apphudService.paywallWasShown  {
                    BLEKokoMainView(bleManager: BLEManager())
                        .preferredColorScheme(.light)
                }  else if let paywallView = apphudService.paywallView {
                    paywallView
                } else {
                    BLEKokoLaunchScreen()
                }
            }
            .onAppear {
                //MARK: - Review
//                isPremium = Apphud.hasActiveSubscription()
                handleQuickAction(quickActions.quickAction)
            }
            .onChange(of: quickActions.quickAction) { action in
                handleQuickAction(action)
            }
            .environment(\.managedObjectContext, persistence.container.viewContext)
    
            .sheet(isPresented: $showMail) {
                MailView()
            }
            .alert("Mail Not Available", isPresented: $mailErrorAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        
    }
 
    private func handleQuickAction(_ action: QuickActionsManager.QuickActionType?) {
        guard let action = action else { return }
        
        switch action {
        case .feedback:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                SKStoreReviewController.requestReviewInCurrentScene()
            }
        case .cancel, .help:
            if MFMailComposeViewController.canSendMail() {
                showMail = true
            } else {
                mailErrorAlert = true
            }
        }
        DispatchQueue.main.async {
            quickActions.quickAction = nil
        }
    }
    
}

