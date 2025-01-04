//
//  ContentView.swift
//  AppleDB
//
//  Created by Kane Parkinson on 30/07/2024.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var hardwareToEdit: Hardware?
    @FetchRequest(fetchRequest: Hardware.all()) private var hardware

    var provider = HardwareProvider.shared
    var body: some View {
        TabView {
            DatabaseView()
                .tabItem {
                    Label("Database", systemImage: "externaldrive")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

