//
//  EntityExtention.swift
//  blekokofinder
//
//  Created by George Popkich on 2.07.25.
//

import Foundation
import CoreBluetooth
import CoreData
import SwiftUI

extension BluetoothDeviceEntity {
    
    public var isFavorite: Bool {
        get { favorite }
        set { favorite = newValue }
    }

    public var deviceId: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }

    public var systemDeviceName: String {
        get { systemName ?? "Unknown Name" }
        set { systemName = newValue}
    }
    
    public var userDeviceName: String {
        get { userName ?? systemDeviceName }
        set { userName = newValue}
    }

    public var lastSeenDate: Date {
        get { lastSeen ?? Date() }
        set { lastSeen = newValue }
    }

    public var deviceDistance: Double {
        get { distance }
        set { distance = newValue }
    }

    
    static func createOrUpdate(
        from device: DiscoveredDevice,
        in context: NSManagedObjectContext,
        savedDevices: FetchedResults<BluetoothDeviceEntity>)
    {
        if let existing = savedDevices.first(where: {
            $0.deviceId == device.id && $0.systemDeviceName == $0.systemDeviceName
        }) {
            existing.lastSeen = Date()
            existing.deviceDistance = estimateDistanceValue(from: device.rssi)
        } else {
            //save new
            let entity = BluetoothDeviceEntity(context: context)
            entity.id = device.id
            entity.systemDeviceName = device.systemName
            entity.lastSeen = Date()
            entity.deviceDistance = estimateDistanceValue(from: device.rssi)
            entity.favorite = false
        }
    }
    
    private static func estimateDistanceValue(from rssi: NSNumber) -> Double {
        let rssiValue = rssi.doubleValue
        let txPower: Double = -59
        return pow(10, (txPower - rssiValue) / 20)
    }
}

extension NSManagedObjectContext {
    
    public func saveContext() {
        if self.hasChanges {
            do {
                try self.save()
            } catch {
                let nsError = error as NSError
                fatalError("[Error] \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}
