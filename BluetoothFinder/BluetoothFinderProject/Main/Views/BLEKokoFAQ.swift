//
//  BLEKokoFAQ.swift
//  blekokofinder
//
//  Created by Developer on 17.06.25.
//

import SwiftUI

enum FAQSteps: CaseIterable {
    case step1
    case step2
    case step3
    case step4
    case step5

    var title: String {
        switch self {
        case .step1:
            return "1. What is the purpose of a Bluetooth Finder App?"
        case .step2:
            return "2. How does the Bluetooth Finder App work?"
        case .step3:
            return "3. Will using the Bluetooth Finder App drain my phone's battery?"
        case .step4:
            return "4. Is it necessary to activate Bluetooth to use the Bluetooth Finder App?"
        case .step5:
            return "5. What types of devices can I connect to using Bluetooth technology with this app?"
        }
    }

    var subtitle: String {
        switch self {
        case .step1:
            return "A Bluetooth Finder App helps users locate and connect with nearby Bluetooth-enabled devices, using Bluetooth technology to detect and display devices within range."
        case .step2:
            return "The app scans for nearby Bluetooth signals emitted by devices such as smartphones, headphones, and speakers, then presents a list of these devices for users to identify and connect with as needed."
        case .step3:
            return "While actively scanning for Bluetooth devices, the app may consume some battery power. However, modern smartphones are designed to minimize battery drain from background processes. To conserve battery life, it's advisable to close the app when not in use."
        case .step4:
            return "Yes, Bluetooth must be enabled on your device for the Bluetooth Finder App to function properly. Ensure Bluetooth is turned on in your device settings before using the app."
        case .step5:
            return "Bluetooth technology enables connections with a variety of devices including smartphones, tablets, laptops, headphones, speakers, smartwatches, fitness trackers, keyboards, mice, and more."
        }
    }
}

struct BLEKokoFAQ: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            header
            scroll
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.mainDark)

    }

    private var header: some View {
        HStack {
            Button(action: {
            }, label: {
                Image(.closeMD)
            })
            .opacity(0)
            .padding()

            Spacer()

            Text("FAQ")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
            Button(action: {
                dismiss()
            }, label: {
                Image(.closeMD)
            })
            .padding()

        }
    }

    private var scroll: some View {
        ScrollView(content: {
            ForEach(FAQSteps.allCases, id: \.title, content: { model in
                makeCell(with: model)
            })
        })
    }

    @ViewBuilder
    private func makeCell(with model: FAQSteps) -> some View {
        VStack {
            Text(model.title)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .bold))
            Text(model.subtitle)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 14))
        }
        .padding(.top, 16)
        .padding(.horizontal)
    }
}


#Preview {
    BLEKokoFAQ()
}
