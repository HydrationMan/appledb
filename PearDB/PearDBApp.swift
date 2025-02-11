//
//  PearDBApp.swift
//  PearDB
//
//  Created by Kane Parkinson on 04/02/2025.
//

import SwiftUI

@main
struct PearDBApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

// MARK: Tab View
struct MainView: View {
    var body: some View {
        TabView {
            DeviceListView()
                .tabItem {
                    Label("Devices", systemImage: "internaldrive")
                }
            FirmwareView()
                .tabItem {
                    Label("Firmware", systemImage: "terminal")
                }
            dbView()
                .tabItem {
                    Label("Database", systemImage: "tray.full")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
