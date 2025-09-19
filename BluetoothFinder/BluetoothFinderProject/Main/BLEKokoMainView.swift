//
//  BLEKokoMainView.swift
//  blekokofinder
//
//  Created by Developer on 13.06.25.
//

import SwiftUI
import CoreData

struct BLEKokoMainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var savedDevices: FetchedResults<BluetoothDeviceEntity>
    
    @ObservedObject var bleManager: BLEManager

    @State private var showSettings: Bool = false
    @State private var showFavorites: Bool = false
    @State private var showDontSeeView: Bool = false
    @State private var navigateToResults: Bool = false
    @State private var showPaywall: Bool = false

    var body: some View {
        ZStack {
            VStack {
                header
                Spacer()
                main
                Spacer()
                searchButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.mainDark)
            
            if showDontSeeView {
                BLEKokoDontSeeView(hideView: {
                    withAnimation {
                        showDontSeeView = false
                    }
                })
                .transition(.opacity)
                .zIndex(1)
            }
        }
        
        //Listener BleManager DiscoveredDevices
        .onChange(of: bleManager.isScanning) { isScanning in
            if !isScanning {
                autoSaveDiscoveredDevices {
                    DispatchQueue.main.async {
                        navigateToResults = true
                    }
                }
            }
        }
        
        //Navigate to BLEKokoFavoriteView
        .fullScreenCover(isPresented: $showFavorites, content: {
            BLEKokoFavoriteView(bleManager: bleManager)
        })
        //Navigate to BLEKokoSettings
        .fullScreenCover(isPresented: $showSettings, content: {
            BLEKokoSettings()
        })
        //Navigate ot SearchResultView
        .fullScreenCover(isPresented: $navigateToResults, content: {
            SearchResultView(bleManager: bleManager)
        })

        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background && 
                !UDManager.isPremium() &&
                !isModalPresented()
            {
                showPaywall = true
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            getPaywall()
        }
    }
   
}

//MARK: BLEKokoMainView Views
private extension BLEKokoMainView {
    
    private var header: some View {
        HStack {
            Button(action: {
                showFavorites = true
            }, label: {
                Image(.favorites)
            })
            Spacer()
            Text("Search")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Button(action: {
                showSettings = true
            }, label: {
                Image(.settings)
            })
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var main: some View {
        VStack(spacing: 24) {
            ZStack {
                if bleManager.isScanning {
                    RadarView()
                        .transition(.opacity)
                } else {
                    Image(.launchScreenIcon)
                        .resizable()
                        .frame(width: 250, height: 250)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: bleManager.isScanning)

            Button(action: {
                withAnimation {
                    showDontSeeView = true
                }
            }, label: {
                Text("Can’t find your device?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .underline()
            })
        }
    }

    private var searchButton: some View {
          BLEKokoBlueButton(
              title: "Search",
              icon: .searchButtonIcon
          ) {
              guard
                /*UDManager.getValue(forKey: .isPremium)*/ true
              else {
                  showPaywall = false
                  return
              }
              
              if bleManager.isBluetoothOn {
                  bleManager.startSingleScan()
              } else {
                  openBluetoothSettings()
              }
          }
          .padding()
      }
    
    private func getPaywall() -> AnyView {
        return AnyView(BLEKokoInRevPaywall())
    }
    
}

//Private extention
private extension BLEKokoMainView {
    
    private func autoSaveDiscoveredDevices(completion: @escaping () -> Void) {
        let context = DataStorageManager.shared.container.viewContext

        bleManager.discoveredDevices.forEach {
            BluetoothDeviceEntity.createOrUpdate(from: $0, in: context,
                                                 savedDevices: savedDevices)
        }
        context.perform {
            context.saveContext()
            completion()
        }
    }
    
    private func openBluetoothSettings() {
         if let url = URL(string: "App-Prefs:root=Bluetooth"), 
                UIApplication.shared.canOpenURL(url) {
             UIApplication.shared.open(url)
         }
     }
    
    private func estimateDistanceValue(from rssi: NSNumber) -> Double {
        let rssiValue = rssi.doubleValue
        let txPower: Double = -59
        return pow(10, (txPower - rssiValue) / 20)
    }
    
    func isModalPresented() -> Bool {
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first(where: { $0.isKeyWindow })?.rootViewController else {
            return false
        }
        return root.presentedViewController != nil
    }
    
}
