//
//  EditDeviceView.swift
//  blekokofinder
//
//  Created by George Popkich on 3.07.25.
//

import SwiftUI
import CoreData

struct EditDeviceView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context

    @ObservedObject private var device: BluetoothDeviceEntity
    @State private var userNameText: String

    init(device: BluetoothDeviceEntity) {
        _device = ObservedObject(initialValue: device)
        _userNameText = State(initialValue: device.userDeviceName)
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Text("Edit")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)

                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(.close)
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 16)
                    .padding(.top)
                }
            }
            .frame(height: 24)

            HStack {
                Text("Name")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.top, 16)
                    .padding(.leading, 16)
                Spacer()
            }

            TextField("Enter name", text: $userNameText)
                .foregroundColor(.white)
                .padding(16)
                .background(Color.row)
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .submitLabel(.done)
                .onSubmit {
                    saveAndDismiss()
                }

            HStack {
                Button(action: {
                    device.isFavorite.toggle()
                }, label: {
                    if device.isFavorite {
                        Label {
                            Text("Erase from My Devices")
                                .font(.system(size: 16.0, weight: .medium))
                                .foregroundStyle(.red)
                        } icon: {
                            Image(.redHeartSlash)
                        }
                    } else {
                        Label {
                            Text("Add to My Devices")
                                .font(.system(size: 16.0, weight: .medium))
                                .foregroundStyle(.mainBlue)
                        } icon: {
                            Image(.blueHeart)
                        }
                    }
                    
                })
                .padding(.leading, 26)
                .padding(.top, 16)
                Spacer()
            }

            Spacer()
            BLEKokoBlueButton(title: "Save", icon: nil) {
                saveAndDismiss()
            }
            .padding(.horizontal, 16.0)
        }
        .presentationDetents([.medium])
        .background(.mainDark)
    }
    
    private func saveAndDismiss() {
        device.userDeviceName = userNameText
        
        do {
            try context.save()
        } catch {
            print("Error saving updated name: \(error)")
        }
        dismiss()
    }
}
