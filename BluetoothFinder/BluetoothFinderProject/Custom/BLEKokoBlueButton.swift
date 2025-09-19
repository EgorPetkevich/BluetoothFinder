//
//  BLEKokoBlueButton.swift
//  blekokofinder
//
//  Created by Developer on 13.06.25.
//

import SwiftUI

struct BLEKokoBlueButton: View {

    @State var title: String
    let icon: ImageResource?
    let action: () -> Void

    var body: some View {
        Button(action: action, label: {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                if let icon {
                    Image(icon)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48.0)
        })
        .padding(.horizontal, 16)
        .background(.mainBlue)
        .cornerRadius(24)
    }
}

#Preview {
    BLEKokoBlueButton(title: "Lalal", icon: .searchButtonIcon, action: {})
}
