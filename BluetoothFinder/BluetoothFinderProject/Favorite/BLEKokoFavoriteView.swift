//
//  BLEKokoFavoriteView.swift
//  blekokofinder
//
//  Created by Developer on 13.06.25.
//

import SwiftUI
import CoreData

struct BLEKokoFavoriteView: View {
    
    private enum NavigationRoute {
        case add
        case device(BluetoothDeviceEntity)
    }
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context

    @State private var activeRoute: NavigationRoute?
    @State private var isNavigating = false
    @State private var showPaywall: Bool = false
    
    @ObservedObject var bleManager: BLEManager
    

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \BluetoothDeviceEntity.lastSeen,
                ascending: false
            )
        ],
        predicate: NSPredicate(format: "favorite == YES"),
        animation: .default
    )
    
    private var favoriteDevices: FetchedResults<BluetoothDeviceEntity>

    var body: some View {
        NavigationStack {
            VStack {
                header
                Spacer()
                if favoriteDevices.isEmpty {
                    main
                } else {
                    deviceList
                }
                Spacer()
                addButton
            }
            .background(.mainDark)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            //Navigation
            .navigationDestination(isPresented: $isNavigating) {
                Group {
                    switch activeRoute {
                    case .add:
                        FavorietSearchResultView()
                            .onDisappear { isNavigating = false }

                    case .device(let device):
                        BLESearchDeviceScreen(
                            bleManager: bleManager,
                            deviceEnity: device
                        )
                    case .none:
                        EmptyView()
                    }
                }
            }
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

}


//MARK: BLEKokoFavoriteView Views
private extension BLEKokoFavoriteView {
    
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
            Text("Favorite")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 24, height: 24)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var main: some View {
        VStack(spacing: 24) {
            Image(.heartSlash)
                .resizable()
                .frame(width: 64, height: 64)

            VStack(alignment: .center, spacing: 4) {
                Text("It seems your list is empty.")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)

                Text("Click on the button to start adding\nyour favorite devices.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
    }

    @ViewBuilder
    private var deviceList: some View {
        let uniqueDevices = Dictionary(grouping: favoriteDevices,
                                       by: { $0.deviceDistance })
            .compactMap { $0.value.first }

        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(uniqueDevices, id: \.deviceId) { device in
                    makeFavoriteRow(device)
                }
            }
            .padding()
        }
    }
    
    private func makeFavoriteRow(_ device: BluetoothDeviceEntity) -> some View {
        Button(action: {
            activeRoute = .device(device)
            isNavigating = true
        }) {
            SearchResultRow(
                icon: iconForDevice(device.systemDeviceName),
                title: device.userName ?? device.userDeviceName,
                time: formatTime(device.lastSeenDate),
                meters: String(format: "%.1f m", device.deviceDistance)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var addButton: some View {
        BLEKokoBlueButton(
            title: "Add",
            icon: .add,
            action: {
                activeRoute = .add
                isNavigating = true
            }
        )
        .padding()
    }
    
    private func getPaywall() -> AnyView {
        return AnyView(BLEKokoInRevPaywall())
    }
    
}

//Private extention
private extension BLEKokoFavoriteView {
    
    private func iconForDevice(_ deviceName: String) -> ImageResource {
        let name = deviceName.lowercased()
        if name.contains("airpods") {
            return .airpods
        } else if name.contains("iphone") {
            return .iphone
        } else if name.contains("mac") {
            return .mac
        } else {
            return .unknownDeviceIcon
        }
    }

    private func formatTime(_ date: Date) -> String {
        let secondsAgo = Int(Date().timeIntervalSince(date))

        if secondsAgo < 60 {
            return "now"
        } else if secondsAgo < 3600 {
            let minutes = secondsAgo / 60
            return "\(minutes) min ago"
        } else if secondsAgo < 86400 {
            let hours = secondsAgo / 3600
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = secondsAgo / 86400
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
    
}
