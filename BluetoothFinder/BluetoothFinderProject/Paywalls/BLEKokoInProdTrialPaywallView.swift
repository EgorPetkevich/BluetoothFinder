//
//  BLEKokoInProdTrialPaywallView.swift
//  blekokofinder
//
//  Created by George Popkich on 5.07.25.
//

import SwiftUI

struct BLEKokoInProdTrialPaywallView: View {
  
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    
    @ObservedObject var apphudService: ApphudService
    @Binding var isPresented: Bool
    
    @State private var isAnimating = false
    @State private var dismissView = false
    @State private var trialPrice: String = ""
    @State private var showError = false
    @State private var showCloseButton = false
    @State private var pricesLoaded = false
    @State private var onboardingSubtitleAlpha: Double
    @State private var showPageIndicator: Bool
    @State private var paywallButtonTitle: String?
    
    init(isPresented: Binding<Bool>, apphudService: ApphudService) {
        self._isPresented = isPresented
        self.apphudService = apphudService
        _showPageIndicator = State(initialValue: UDManager.getValue(forKey: .is_paging_enabled))
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
                        .padding(.top, 24)

                    Text("Start to Continue BLE Finder\nwith a 3 day trial and \(trialPrice)/week.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .font(.system(size: 14, weight: .medium))
                        .opacity(onboardingSubtitleAlpha)

                    if showPageIndicator {
                        CustomPageControl(
                            numberOfPages: 5,
                            currentPage: .constant(3)
                        )
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                    } else {
                        Spacer()
                            .frame(height: 76.0)
                    }
                    
                    Button(action: {
                        subButtonDidTap()
                    }, label: {
                        HStack(spacing: 8) {
                            Text(paywallButtonTitle ?? "3-day Free Trial then \(trialPrice)/week \nAuto renewable. Cancel anytime")
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
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isAnimating = true
                        }
                    
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + UDManager.getOnbTimerValue()) {
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
                                withAnimation {
                                    isOnboarding = false
                                    apphudService.paywallWasShown = true
                                    isPresented = false
                                }
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
                primaryButton: .default(Text("Try again")) {
                    subButtonDidTap()
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
        .navigationBarHidden(true)
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
private extension BLEKokoInProdTrialPaywallView {
    func updatePrices() {
        Task {
            let price = await apphudService.getProductPrice(type: .trial) ?? "..."
            DispatchQueue.main.async {
                self.trialPrice = price
                self.pricesLoaded = true
            }
        }
    }

    func subButtonDidTap() {
        Task {
            let result = await apphudService.makePurchase(type: .trial)
            onPurchaseResult(result)
        }
    }

    func onPurchaseResult(_ result: Bool) {
        DispatchQueue.main.async {
            if result {
                withAnimation {
                    isOnboarding = false
                    apphudService.paywallWasShown = true
                    isPresented = false
                }
            } else {
                showError = true
            }
        }
    }

    func restoreDidTap() {
        Task {
            let result = await apphudService.restorePurchases()
            onPurchaseResult(result)
        }
    }

    func handleBottomButtonTap(_ button: BottomViewButtons) {
        switch button {
        case .privacy:
            openURL(AppConfig.privacy)
        case .terms:
            openURL(AppConfig.terms)
        case .restore:
            restoreDidTap()
        }
    }

    func openURL(_ string: String) {
        if let url = URL(string: string) {
            UIApplication.shared.open(url)
        }
    }
}
