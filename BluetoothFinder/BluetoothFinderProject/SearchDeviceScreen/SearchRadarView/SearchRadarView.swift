//
//  SearchRadarView.swift
//  blekokofinder
//
//  Created by George Popkich on 2.07.25.
//

import SwiftUI

struct SearchRadarView: View {
    @Binding var signalPercent: Int
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<4) { i in
                RadarPulse(index: i, animate: animate)
            }

            Circle()
                .fill(Color.black)
                .frame(width: 100, height: 100)

            Text("\(signalPercent)%")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.white)
        }
        .onAppear {
            animate = true
        }
    }
}

private struct RadarPulse: View {
    let index: Int
    let animate: Bool

    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.5))
            .frame(width: CGFloat(100 + index * 60),
                   height: CGFloat(100 + index * 60))
            .scaleEffect(animate ? 1.4 : 1)
            .opacity(animate ? 0 : 0.4)
            .animation(
                .easeOut(duration: 2.5)
                    .repeatForever()
                    .delay(Double(index) * 0.5),
                value: animate
            )
    }
}
