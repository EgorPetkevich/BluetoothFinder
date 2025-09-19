//
//  BLEKokoInRevPaywall.swift
//  blekokofinder
//
//  Created by George Popkich on 5.07.25.
//

import Foundation

enum BottomViewButtons: String, CaseIterable, Identifiable {
    var id: Self { self }

    case privacy = "Privacy"
    case restore = "Restore"
    case terms = "Terms"
}
