//
//  SearchResultView.swift
//  blekokofinder
//
//  Created by Developer on 13.06.25.
//

import SwiftUI
import CoreBluetooth
import CoreData

struct SearchResultView: View {
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "lastSeen >= %@",
                               Date().addingTimeInterval(-60) as NSDate),
        animation: .default
    )
    private var savedDevices: FetchedResults<BluetoothDeviceEntity>
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) var dismiss

    @ObservedObject var bleManager: BLEManager

    @State private var isWaitingForResult = false
    @State private var selectedDeviceEntity: BluetoothDeviceEntity?
    @State private var navigate: Bool = false
    @State private var showPaywall: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                header
                Spacer()
                if isWaitingForResult {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.white)
                } else {
                    scrollView
                }
                Spacer()
                searchButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.mainDark)
            
            .onAppear {
                isWaitingForResult = false
            }
            
            //Listener BleManager DiscoveredDevices
            .onChange(of: bleManager.isScanning) { isScanning in
                if !isScanning {
                    isWaitingForResult = false
                    autoSaveDiscoveredDevices()
                }
            }
            //Navigate to BLESearchDeviceScreen
            .navigationDestination(isPresented: $navigate) {
                if let selectedDeviceEntity {
                    BLESearchDeviceScreen(
                        bleManager: bleManager,
                        deviceEnity: selectedDeviceEntity)
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .background && !UDManager.isPremium() {
                    showPaywall = false
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                getPaywall()
            }
        }
    }
    
}

//MARK: SearchResultView Views
private extension SearchResultView {
    
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.backward")
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.white)
            }
            Spacer()
            Text("Search Result")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 24, height: 24)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var scrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(savedDevices, id: \.objectID) { entity in
                    makeRow(for: entity)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func makeRow(for entity: BluetoothDeviceEntity) -> some View {
        Button(action: {
            selectedDeviceEntity = entity
            navigate = true
        }) {
            SearchResultRow(
                icon: iconForDevice(entity.systemDeviceName),
                title: entity.userDeviceName,
                time: formatTime(entity.lastSeenDate),
                meters: String(format: "%.1f m", entity.deviceDistance)
            )
        }
        .buttonStyle(.plain)
    }

    private var searchButton: some View {
        BLEKokoBlueButton(
            title: "Search",
            icon: .searchButtonIcon,
            action: {
                if bleManager.isBluetoothOn {
                    startScanning()
                } else {
                    openBluetoothSettings()
                }
            }
        )
        .padding()
    }
    
    private func getPaywall() -> AnyView {
        return AnyView(BLEKokoInRevPaywall())
    }
    
}

//Private extention Open Settings
private extension SearchResultView {
    
    private func startScanning() {
        guard !isWaitingForResult else { return }

        isWaitingForResult = true
        bleManager.startSingleScan()
    }
    
    private func openBluetoothSettings() {
         if let url = URL(string: "App-Prefs:root=Bluetooth"),
            UIApplication.shared.canOpenURL(url) {
             UIApplication.shared.open(url)
         }
     }
    
    private func autoSaveDiscoveredDevices() {
        let context = DataStorageManager.shared.container.viewContext
        bleManager.discoveredDevices.forEach {
            BluetoothDeviceEntity.createOrUpdate(from: $0, in: context,
                                                 savedDevices: savedDevices)
        }
        context.saveContext()
    }
    
}

// extention Cell formaters
private extension SearchResultView {
    
    private func iconForDevice(_ systemName: String) -> ImageResource {
        bleManager.iconForDevice(systemName)
    }
    
    private func formatTime(_ date: Date) -> String {
        bleManager.formatTime(date)
        
    }
    
}
