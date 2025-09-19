//
//  FavorietSearchResultView.swift
//  blekokofinder
//
//  Created by George Popkich on 1.07.25.
//

import SwiftUI
import CoreData
import CoreBluetooth

struct FavorietSearchResultView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        sortDescriptors: 
            [NSSortDescriptor(
                keyPath: \BluetoothDeviceEntity.lastSeen,
                ascending: false)],
        predicate: NSPredicate(format: "favorite == NO"),
        animation: .default
    )
    private var savedDevices: FetchedResults<BluetoothDeviceEntity>
    

    @State private var selectedDeviceIDs: Set<UUID> = []
    @State private var showPaywall: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                header
                Spacer()
                if savedDevices.isEmpty {
                    Text("No saved devices.")
                        .foregroundStyle(.white)
                        .padding()
                } else {
                    scrollView
                }
                Spacer()
            }
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.mainDark)
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

//MARK: FavorietSearchResultView Views
private extension FavorietSearchResultView {
    
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.backward")
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.white)
            }

            Spacer()

            if !selectedDeviceIDs.isEmpty {
                Button("Done") {
                    handleDoneAction()
                }
                .foregroundStyle(.blue)
                .transition(.opacity)
            } else {
                Color.clear.frame(width: 44, height: 24)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: selectedDeviceIDs)
    }
    
    @ViewBuilder
    private var scrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(savedDevices, id: \.deviceId) { device in
                    FavorietSearchRow(
                        icon: iconForDevice(device.systemDeviceName),
                        title: device.userDeviceName,
                        time: formatTime(device.lastSeenDate),
                        meters: String(format: "%.1f m", device.deviceDistance),
                        isSelected: selectedDeviceIDs.contains(device.deviceId)
                    )
                    .onTapGesture {
                        toggleSelection(for: device.deviceId)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func getPaywall() -> AnyView {
        return AnyView(BLEKokoInRevPaywall())
    }
    
}

//Private extention
private extension FavorietSearchResultView {
    
    private func handleDoneAction() {
        for id in selectedDeviceIDs {
            let fetchRequest:
            NSFetchRequest<BluetoothDeviceEntity> = BluetoothDeviceEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "id == %@", id as CVarArg)
            fetchRequest.fetchLimit = 1

            if let device = try? context.fetch(fetchRequest).first {
                device.isFavorite = true
            }
        }

        do {
            try context.save()
            selectedDeviceIDs.removeAll()
            dismiss()
        } catch {
            print("Failed to update favorites: \(error)")
        }
    }

    private func iconForDevice(_ name: String) -> ImageResource {
        
        let lowercased = name.lowercased()
        if lowercased.contains("airpods") {
            return .airpods
        } else if lowercased.contains("iphone") {
            return .iphone
        } else if lowercased.contains("mac") {
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
            return "\(secondsAgo / 60) min ago"
        } else if secondsAgo < 86400 {
            return "\(secondsAgo / 3600) hour\(secondsAgo / 3600 == 1 ? "" : "s") ago"
        } else {
            return "\(secondsAgo / 86400) day\(secondsAgo / 86400 == 1 ? "" : "s") ago"
        }
    }
    
    private func toggleSelection(for id: UUID) {
        if selectedDeviceIDs.contains(id) {
            selectedDeviceIDs.remove(id)
        } else {
            selectedDeviceIDs.insert(id)
        }
    }
    
}
