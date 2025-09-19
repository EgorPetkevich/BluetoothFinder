//
//  RadarView.swift
//  blekokofinder
//
//  Created by Developer on 13.06.25.
//


import SwiftUI

struct RadarView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<4) { i in
                Circle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: CGFloat(100 + i * 60), height: CGFloat(100 + i * 60))
                    .scaleEffect(animate ? 1.4 : 1)
                    .opacity(animate ? 0 : 0.4)
                    .animation(
                        .easeOut(duration: 2.5)
                            .repeatForever()
                            .delay(Double(i) * 0.5),
                        value: animate
                    )
            }

            Circle()
                .fill(.main)
                .frame(width: 100, height: 100)

            Image(.bluetoothWave)
                .resizable()
                .frame(width: 40, height: 40)
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    RadarView()
}
