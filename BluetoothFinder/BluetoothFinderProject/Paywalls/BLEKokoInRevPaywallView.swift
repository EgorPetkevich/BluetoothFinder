//
//  BLEKokoInAppPaywall.swift
//  blekokofinder
//
//  Created by Developer on 28.06.25.
//

import SwiftUI

import SwiftUI

struct BLEKokoInRevPaywall: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isAnimating = false
    @State private var isOn = false
    @State private var dismissView = false
    @State private var trialPrice: String = ""
    @State private var weeklyPrice: String = ""
    @State private var showError = false
    @State private var showCloseButton = false
    @State private var onboardingSubtitleAlpha: Double
    @State private var pricesLoaded = false
    
    @State private var paywallButtonTitle: String?
    
    private var trialDidSelect: Bool {
        isOn
    }

    @ObservedObject var apphudService: ApphudService = .instance
    
//    private var dismissHandler: (() -> Void)?
    
    private var buttonTitle: String {
        if let title = paywallButtonTitle {
            return title
        } else {
            return isOn
                ? "3-day Free Trial then \(trialPrice)/week \nAuto renewable. Cancel anytime"
                : "Subscribe for \(weeklyPrice)/week \nAuto renewable. Cancel anytime"
        }
    }
    
    private var dismissHandler: (() -> Void)?

    init(dismissHandler: (() -> Void)? = nil) {
        self.dismissHandler = dismissHandler
        _paywallButtonTitle = State(initialValue: UDManager.getPaywallButtonTitleText())
        _onboardingSubtitleAlpha = State(initialValue: UDManager.getSubtitleAlpha())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 8) {
                    Image(.paywallImg)
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(edges: .horizontal)
                    
                    Text("Full access\nto all functions of")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .font(.system(size: 32, weight: .semibold))
                        .padding(.top, 24.0)
                    
                    Text(isOn
                         ? "Start to continue BLE Finder \nwith a 3 day trial and \(trialPrice)/week"
                         : "Start to continue BLE Finder \nwith no limits just for \(weeklyPrice)/week")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.bottom, 16)
                        .opacity(onboardingSubtitleAlpha)
                    
                    freeTrialToggleView
                     
                    Button(action: {
                        subButtonDidTap()
                    }, label: {
                        HStack(spacing: 8) {
                            Text(paywallButtonTitle ?? (isOn
                                  ? "3-day Free Trial then \(trialPrice)/week \nAuto renewable. Cancel anytime"
                                  : "Subscribe for \(weeklyPrice)/week \nAuto renewable. Cancel anytime"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48.0)
                    })
                    .padding(.horizontal, 16)
                    .background(.mainBlue)
                    .cornerRadius(24)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                    
                
                    .onAppear {
                        updatePrices()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isAnimating = true
                        }
        
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + UDManager.getTimerValue()) {
                                showCloseButton = true
                                
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 0)

                    bottomView
                        .padding(.bottom, 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.mainDark)
                
                VStack {
                    HStack {
                        Spacer()
                        if showCloseButton {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                                dismissHandler?()
                            }, label: {
                                Image(.onboardClose)
                            })
                            .padding()
                        }
                    }
                    Spacer()
                }
            }
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Oops..."),
                message: Text("Something went wrong. Please try again"),
                primaryButton: .default(Text("Try again"), action: {
                    subButtonDidTap()
                }),
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
        .navigationBarHidden(true)
    }

    private var freeTrialToggleView: some View {
        HStack {
            Text("I want my Free Trial.")
                .font(.system(size: 16))
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .frame(height: 44)
    }

    @ViewBuilder
    private var bottomView: some View {
        HStack(spacing: 8) {
            Text("By continuing, you agree to:")
                .foregroundStyle(.onbDesc)
                .font(.system(size: 13, weight: .medium))
            Spacer()
            ForEach(
                BottomViewButtons.allCases,
                id: \.self
            ) { content in
                Button(action: {
                    handleBottomButtonTap(content)
                }) {
                    Text(content.rawValue)
                        .foregroundStyle(.onbDesc)
                        .font(.system(size: 13, weight: .medium))
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }
}

//Private extention
extension BLEKokoInRevPaywall {
    
    private func handleBottomButtonTap(_ button: BottomViewButtons) {
        switch button {
        case .privacy:
            openURL(AppConfig.privacy)
        case .terms:
            openURL(AppConfig.terms)
        case .restore:
            restorButtonDidTap()
        }
    }
    
    private func updatePrices() {
        Task {
            let trial = await apphudService.getProductPrice(type: .trial)
            let weekly = await apphudService.getProductPrice(type: .weekly)
            
            DispatchQueue.main.async {
                self.trialPrice = trial ?? "..."
                self.weeklyPrice = weekly ?? "..."
                self.pricesLoaded = true
            }
        }
    }

    private func restorButtonDidTap() {
        Task {
            let success = await apphudService.restorePurchases()
            onPurchaseResult(success)
        }
    }

    private func subButtonDidTap() {
        let type: ApphudService.PurchaseType = trialDidSelect ? .trial : .weekly
        Task {
            let result = await apphudService.makePurchase(type: type)
            self.onPurchaseResult(result)
        }
    }

    private func termsDidTap() {
        if let url = URL(string: AppConfig.terms) {
            UIApplication.shared.open(url)
        }
    }

    private func privacyDidTap() {
        if let url = URL(string: AppConfig.privacy) {
            UIApplication.shared.open(url)
        }
    }

    private func onPurchaseResult(_ result: Bool) {
        DispatchQueue.main.async {
            if result {
               
                presentationMode.wrappedValue.dismiss()
                dismissHandler?()
            } else {
                showError = true
            }
        }
    }
    
}
