//
//  BLEKokoOnboard3.swift
//  blekokofinder
//
//  Created by Developer on 28.06.25.
//

import SwiftUI

struct BLEKokoProdOnboardThird: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool?

    @ObservedObject var apphudService: ApphudService
    
    @State private var isAnimating = false
    @State private var showPageIndicator: Bool
    @State private var onboardingButtonTitle: String?
    @State private var oboardingSubtitleAlpha: Double
    @State private var showPaywall = false
    
    init(apphudService: ApphudService) {
        self.apphudService = apphudService
        _showPageIndicator = State(initialValue: UDManager.getValue(forKey: .is_paging_enabled))
        _onboardingButtonTitle = State(initialValue: UDManager.getOnbButtonTitleText())
        _oboardingSubtitleAlpha = State(initialValue: UDManager.getSubtitleAlpha())
    }
    

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Image(.onb3)
                    .frame(maxHeight: .infinity)

                Text("Keep your\ndevices")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .font(.system(size: 32, weight: .semibold))

                Text("Add devices to your favorites\nquickly and easily")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .font(.system(size: 14, weight: .medium))
                    .opacity(oboardingSubtitleAlpha)

                if showPageIndicator {
                    CustomPageControl(
                        numberOfPages: 5,
                        currentPage: .constant(2)
                    )
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                } else {
                    Spacer()
                        .frame(height: 64.0)
                }

                // Кнопка с анимацией
                BLEKokoBlueButton(
                    title: onboardingButtonTitle ?? "Continue",
                    icon: nil,
                    action: {
                        
                        if UDManager.isPremium() {
                            isOnboarding = false
                        } else {
                            showPaywall = true
                        }
                        
                    }
                )
                .padding(.bottom, 34)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isAnimating = true
                    }
                }
                .padding(.horizontal)
                .navigationDestination(isPresented: $showPaywall) {
                    if UDManager.getValue(forKey: .hasTrial) {
                        BLEKokoInProdTrialPaywallView(isPresented: $showPaywall, 
                                                      apphudService: apphudService)
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut(duration: 0.3), value: showPaywall)
                    } else {
                        BLELoloInProdPaywall(isPresented: $showPaywall, 
                                             apphudService: apphudService)
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut(duration: 0.3), value: showPaywall)
                    }
                }
             
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.mainDark)
        }
        .navigationBarHidden(true)
    }
}
