//
//  BLEManager.swift
//  blekokofinder
//
//  Created by Developer on 13.06.25.
//

import Foundation
import CoreBluetooth
import Combine

struct DiscoveredDevice: Identifiable, Equatable {
    var id: UUID { peripheral.identifier }
    var systemName: String { peripheral.name ?? "Unknow Name" }
    let peripheral: CBPeripheral
    let rssi: NSNumber
    let discoveredAt: Date
}

final class BLEManager: NSObject, ObservableObject {
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var isBluetoothOn: Bool = false
    @Published var isScanning: Bool = false

    private var centralManager: CBCentralManager!
    private var scanDuration: TimeInterval = 3.0
    
    //Monitoring
    @Published var latestRSSI: NSNumber?
    private var rssiTimer: Timer?
    private var monitoredPeripheralID: UUID?
    private var monitoredPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    deinit {
        
    }

    func startSingleScan() {
        guard centralManager.state == .poweredOn else { return }

        discoveredDevices.removeAll()
        isScanning = true

        centralManager.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + scanDuration) { [weak self] in
            self?.centralManager.stopScan()
            self?.isScanning = false
        }
    }
    
    func iconForDevice(_ name: String) -> ImageResource {
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

    func formatTime(_ date: Date) -> String {
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
    
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBluetoothOn = (central.state == .poweredOn)
    }

//    func centralManager(_ central: CBCentralManager,
//                        didDiscover peripheral: CBPeripheral,
//                        advertisementData: [String: Any],
//                        rssi RSSI: NSNumber) {
//
//        let device = DiscoveredDevice(peripheral: peripheral,
//                                      rssi: RSSI,
//                                      discoveredAt: Date())
//
//        if let index = discoveredDevices.firstIndex(where: {
//            $0.peripheral.name == peripheral.name
//        }) {
//            discoveredDevices[index] = device
//        } else {
//            discoveredDevices.append(device)
//        }
//
//        if peripheral.identifier == monitoredPeripheralID {
//            DispatchQueue.main.async {
//                self.latestRSSI = RSSI
//            }
//        }
//    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        
        guard let name = peripheral.name, !name.isEmpty else { return }
        guard RSSI.intValue > -90 else { return }

        let device = DiscoveredDevice(peripheral: peripheral,
                                      rssi: RSSI,
                                      discoveredAt: Date())

        if let index = discoveredDevices.firstIndex(where: {
            $0.peripheral.identifier == peripheral.identifier
        }) {
            discoveredDevices[index] = device
        } else {
            discoveredDevices.append(device)
        }

        if peripheral.identifier == monitoredPeripheralID {
            DispatchQueue.main.async {
                self.latestRSSI = RSSI
            }
        }
    }
}

// MARK: - RSSI Monitoring
extension BLEManager: CBPeripheralDelegate {
    
    func reset() {
        stopScan()
        stopMonitoringRSSI()
        discoveredDevices.removeAll()
        monitoredPeripheral = nil
        monitoredPeripheralID = nil
        latestRSSI = nil
    }
    
    func startScan() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth not active")
            return
        }
        
        discoveredDevices.removeAll()
        
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
    }
    
    func stopScan() {
        stopMonitoringRSSI()
        centralManager.stopScan()
    }
    
    func monitorRSSI(for peripheral: CBPeripheral) {
        monitoredPeripheralID = peripheral.identifier
        monitoredPeripheral = peripheral
        peripheral.delegate = self

        print("Trying to connect to \(peripheral.name ?? "unknown")")

        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral.identifier == monitoredPeripheralID {
            print("Connected to \(peripheral.name ?? "unknown")")
            peripheral.readRSSI()
            startRSSITimer()
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        if peripheral.identifier == monitoredPeripheralID {
            print("Failed to connect to \(peripheral.name ?? "unknown") — using RSSI from scan")

            if let device = discoveredDevices.first(where: {
                $0.peripheral.identifier == peripheral.identifier
            }) {
                DispatchQueue.main.async {
                    self.latestRSSI = device.rssi
                }
            }
            startRSSITimer()
            monitoredPeripheral = nil
            monitoredPeripheralID = nil
        }
    }
    
    private func startRSSITimer() {
        print("Starting RSSI timer for: \(monitoredPeripheral?.name ?? "?")")
        rssiTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let peripheral = self?.monitoredPeripheral else { return }
            print("Asking RSSI from \(peripheral.name ?? "?")")
            peripheral.readRSSI()
        }
    }
    
    func stopMonitoringRSSI() {
        rssiTimer?.invalidate()
        rssiTimer = nil
        
        if let peripheral = monitoredPeripheral,
           peripheral.state == .connected || peripheral.state == .connecting {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        
        monitoredPeripheral = nil
        monitoredPeripheralID = nil
        latestRSSI = nil
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let error = error {
            print("[RSSI Error]: \(error.localizedDescription)")
            return
        }

        if peripheral.identifier == monitoredPeripheralID {
            print("RSSI read from \(peripheral.name ?? "unknown"): \(RSSI)")
            DispatchQueue.main.async {
                self.latestRSSI = RSSI
            }
        }
    }
}

