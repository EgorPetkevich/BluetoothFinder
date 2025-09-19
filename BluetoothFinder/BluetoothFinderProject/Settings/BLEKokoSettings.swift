//
//  BLEKokoSettings.swift
//  blekokofinder
//
//  Created by Developer on 13.06.25.
//

import SwiftUI
import MessageUI


extension View {
    func openURL(_ url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
}

enum BLEKokoSettingsData: CaseIterable {

    case faq
    case access
    case privacy
    case terms
    case contact
    case shareApp

    var title: String {
        switch self {
        case .faq:
            return "FAQ"
        case .access:
            return "Bluetooth access"
        case .privacy:
            return "Privacy Policy"
        case .terms:
            return "Terms of Use"
        case .contact:
            return "Contact us"
        case .shareApp:
            return "Share App"
        }
    }

    var image: ImageResource {
        switch self {
        case .faq:
                .faq
        case .access:
                .bluetoothAccess
        case .privacy:
                .privacy
        case .terms:
                .terms
        case .contact:
                .contactus
        case .shareApp:
                .share
        }
    }
}

struct BLEKokoSettings: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) var dismiss

    let content: [BLEKokoSettingsData] = BLEKokoSettingsData.allCases

    @State private var showFAQ: Bool = false
    @State private var showMail: Bool = false
    @State private var mailErrorAlert: Bool = false
    @State private var showPaywall: Bool = false

    var body: some View {
        VStack {
            header

            scrollView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.mainDark)
        .sheet(isPresented: $showFAQ, content: {
            BLEKokoFAQ()
                .presentationDetents([.large])
        })
        .sheet(isPresented: $showMail) {
            MailView()
        }
        .alert("Mail Not Available", isPresented: $mailErrorAlert) {
            Button("OK", role: .cancel) { }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background && !UDManager.isPremium() {
                showPaywall = true
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            getPaywall()
        }
    }

    private var header: some View {
        HStack {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "chevron.backward")
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.white)
            })
            Spacer()
            Text("Settings")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 24, height: 24)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func makeCell(
        content: BLEKokoSettingsData,
        action: @escaping () -> Void
    ) -> some View {
        BLEKokoSettingsRow(content: content, action: action)
    }

    private var scrollView: some View {
        ScrollView {
            ForEach(content, id:\.self) { content in
                makeCell(content: content, action: {
                    switch content {
                    case .faq:
                        showFAQ = true
                    case .access:
                        openBluetoothSettings()
                    case .privacy:
                        let url = AppConfig.privacy
                        openURL(url)
                    case .terms:
                        let url = AppConfig.terms
                        openURL(url)
                    case .contact:
                        openMailVC()
                    case .shareApp:
                        shareApplication()
                    }
                })
            }
        }
        .padding()
    }
    
    private func getPaywall() -> AnyView {
        return AnyView(BLEKokoInRevPaywall())
    }

    private func openBluetoothSettings() {
         if let url = URL(string: "App-Prefs:root=Bluetooth"), UIApplication.shared.canOpenURL(url) {
             UIApplication.shared.open(url)
         }
     }

    func shareApplication() {
        let url = URL(string: AppConfig.share)!
        let activVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        Task { @MainActor in
            if let topVC = UIApplication.getTopMost() {
                if topVC.presentedViewController == nil {
                    if let popoverController = activVC.popoverPresentationController {
                        popoverController.sourceView = topVC.view
                        popoverController.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                        popoverController.permittedArrowDirections = []
                    }
                    topVC.present(activVC, animated: true)
                } else {
                    print("Already presenting a VC")
                }
            }
        }
    }

    func openMailVC() {
        if MFMailComposeViewController.canSendMail() {
            showMail = true
        } else {
            mailErrorAlert = true
        }
    }
}

extension UIApplication {
    static func getTopMost() -> UIViewController? {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return nil }

        var topVC = keyWindow.rootViewController
        while let presentedVC = topVC?.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }
}

#Preview {
    BLEKokoSettings()
}


struct BLEKokoSettingsRow: View {

    let content: BLEKokoSettingsData
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }, label:{
            HStack {
                Image(content.image)

                Text(content.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical)
        })
        .background(.row)
        .cornerRadius(8)
    }
}

#Preview {
    BLEKokoSettingsRow(content: .access, action: {})
}
