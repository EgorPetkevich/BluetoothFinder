//
//  LaunchScreen.swift
//  blekokofinder
//
//  Created by Developer on 13.06.25.
//

import SwiftUI

struct BLEKokoLaunchScreen: View {
    var body: some View {
        VStack {
            Image(.launchScreenIcon)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(.main)
    }
}

#Preview {
    BLEKokoLaunchScreen()
}
