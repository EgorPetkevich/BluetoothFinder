//
//  BLEKokoOnboard2.swift
//  blekokofinder
//
//  Created by Developer on 28.06.25.
//

import SwiftUI
import StoreKit

struct BLEKokoProdOnboardSecond: View {
    @ObservedObject var apphudService: ApphudService
    
    @State private var isAnimating = false
    @State private var navigate = false
    @State private var showPageIndicator: Bool
    @State private var onboardingButtonTitle: String?
    @State private var oboardingSubtitleAlpha: Double
    
    init(apphudService: ApphudService) {
        self.apphudService = apphudService
        _showPageIndicator = State(initialValue: UDManager.getValue(forKey: .is_paging_enabled))
        _onboardingButtonTitle = State(initialValue: UDManager.getOnbButtonTitleText())
        _oboardingSubtitleAlpha = State(initialValue: UDManager.getSubtitleAlpha())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Image(.onb2)
                    .frame(maxHeight: .infinity)

                Text("Watch the device\nsearch")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .font(.system(size: 32, weight: .semibold))

                Text("Track the progress of the device approach\nas a percentage")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .font(.system(size: 14, weight: .medium))
                    .opacity(oboardingSubtitleAlpha)

                if showPageIndicator {
                    CustomPageControl(
                        numberOfPages: 5,
                        currentPage: .constant(1)
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
                        navigate = true
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
                    requestReview()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isAnimating = true
                    }
                }
                .padding(.horizontal)

                .navigationDestination(isPresented: $navigate) {
                    BLEKokoProdOnboardThird(apphudService: apphudService)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.mainDark)
        }
        .navigationBarHidden(true)
    }
    
    private func requestReview() {
        DispatchQueue.main.async {
            if UDManager.getValue(forKey: .isReview) {
                SKStoreReviewController.requestReviewInCurrentScene()
            }
        }
    }
}
