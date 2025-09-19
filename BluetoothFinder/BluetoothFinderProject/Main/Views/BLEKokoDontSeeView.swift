//
//  BLEKokoDontSeeView.swift
//  blekokofinder
//
//  Created by Developer on 13.06.25.
//

import SwiftUI

struct BLEKokoDontSeeView: View {

    enum Content: CaseIterable {
        case bluetoothOff
        case deviceOff
        case deviceOutOfRange
        case notDiscovered

        var title: String {
            switch self {
            case .bluetoothOff:
                return "Bluetooth turned off"
            case .deviceOff:
                return "Device powered off"
            case .deviceOutOfRange:
                return "Device out of range"
            case .notDiscovered:
                return "Device not discoverable"
            }
        }

        var image: ImageResource {
            switch self {
            case .bluetoothOff:
                    .bluetooth
            case .deviceOff:
                    .deviceOff1
            case .deviceOutOfRange:
                    .deviceOutOfRange
            case .notDiscovered:
                    .deviceNotDiscovered
            }
        }
    }

    let hideView: () -> Void

    let content: [Content] = Content.allCases

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack {
                header
                options
                okButton
            }
            .background(.main)
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }

    private var header: some View {
            HStack {
                Image(.close).opacity(0)
                Spacer()
                VStack {
                    Text("Don’t see device?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Here are several reasons")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
                Spacer()
                Button(action: {
                    hideView()
                }) {
                    Image(.close)
                }
            }
            .padding()
    }

    private var options: some View {
        ForEach(content, id: \.self) { content in
            makeCell(content: content)
        }
    }

    private func makeCell(content: Content) -> some View {
        HStack {
            Image(content.image)
            Text(content.title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var okButton: some View {
        BLEKokoBlueButton(
            title: "Got it!",
            icon: nil,
            action: {
                hideView()
            }
        )
        .padding()
    }
}

#Preview {
    BLEKokoDontSeeView(hideView: {})
}
