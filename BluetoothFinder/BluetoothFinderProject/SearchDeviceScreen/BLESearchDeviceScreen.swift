//
//  BLESearchDeviceScreen.swift
//  blekokofinder
//
//  Created by Developer on 18.06.25.
//
import SwiftUI
import CoreBluetooth

struct BLESearchDeviceScreen: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var bleManager: BLEManager

    @State var deviceEnity: BluetoothDeviceEntity?
   
    @State private var signalStrength: Int = 0
    @State private var showEdit: Bool = false
    @State private var showPaywall: Bool = false

    @State private var isMonitoringStarted: Bool = false

    var body: some View {
        ZStack {
            VStack {
                header
                Spacer()
                main
                Text("Navigate to find your\ndevice")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Spacer()
                searchButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.mainDark)
            .sheet(isPresented: $showEdit) {
                if let deviceEnity {
                    EditDeviceView(device: deviceEnity)
                    .ignoresSafeArea(.keyboard)
                    .scrollDismissesKeyboard(.interactively)
                  
                }
            }
        }
        .onReceive(bleManager.$isBluetoothOn) { isOn in
            if isOn {
                bleManager.startScan()
            }
        }
        .onReceive(bleManager.$discoveredDevices) { devices in
            guard !isMonitoringStarted else { return }

            if let entity = deviceEnity,
                      let match = devices.first(where: {
                          $0.systemName.lowercased() == entity.systemDeviceName.lowercased()
                      }) {
                bleManager.monitorRSSI(for: match.peripheral)
                isMonitoringStarted = true
            }
        }
        .onReceive(bleManager.$latestRSSI) { rssi in
            guard let rssi else { return }
            signalStrength = signalPercent(from: rssi)
        }
        .onDisappear {
            bleManager.stopScan()
            bleManager.reset()
        }
        .navigationBarHidden(true)
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
                bleManager.reset()
            }) {
                Image(systemName: "chevron.backward")
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.white)
            }

            Spacer()
            Text(deviceEnity?.userDeviceName ?? "Unknown Device")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()

            Button(action: {
                showEdit = true
            }, label: {
                Image(.pen)
            })
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var main: some View {
        VStack(spacing: 24) {
            ZStack {
                SearchRadarView(signalPercent: $signalStrength)
                    .transition(.opacity)
            }
            .animation(.easeInOut(duration: 0.3), value: bleManager.isScanning)
        }
    }

    private var searchButton: some View {
        BLEKokoBlueButton(
            title: "Found",
            icon: .check
        ) {
           dismiss()
        }
        .padding()
    }
    
    private func getPaywall() -> AnyView {
        return AnyView(BLEKokoInRevPaywall())
    }

    private func openBluetoothSettings() {
        if let url = URL(string: "App-Prefs:root=Bluetooth"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    private func signalPercent(from rssi: NSNumber) -> Int {
        return max(0, min(100, 2 * (Int(truncating: rssi) + 100)))
    }
}
