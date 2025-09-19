//
//  FavoriteRow.swift
//  blekokofinder
//
//  Created by George Popkich on 3.07.25.
//

import SwiftUI
import CoreBluetooth

struct FavoriteRow: View {
    let device: DiscoveredDevice
    @Binding var selectedDevice: DiscoveredDevice?
    @Binding var navigateSelectedDevice: Bool

    var body: some View {
        Button(action: {
            selectedDevice = device
            navigateSelectedDevice = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(device.peripheral.name ?? "Unknown Device")
                        .font(.headline)
                        .foregroundColor(.white)

//                    Text("Signal: \(device.rssiPercent)%")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
                }

                Spacer()

//                ProgressView(value: Float(device.rssiPercent), total: 100)
//                    .frame(width: 80)
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
