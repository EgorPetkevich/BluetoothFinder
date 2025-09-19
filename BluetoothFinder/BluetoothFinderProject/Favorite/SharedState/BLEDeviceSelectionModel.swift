//
//  BLEDeviceSelectionModel.swift
//  blekokofinder
//
//  Created by George Popkich on 3.07.25.
//

import SwiftUI
import Combine

class BLEDeviceSelectionModel: ObservableObject {
    @Published var selectedDevice: DiscoveredDevice?
    @Published var navigateSelectedDevice = false
}
