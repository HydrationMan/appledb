//
//  ContentView.swift
//  AppleDBWatchApp
//
//  Created by Kane Parkinson on 06/05/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var hardwareToEdit: Hardware?
    @FetchRequest(fetchRequest: Hardware.all()) private var hardware
    var provider = HardwareProvider.shared
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack {
                TabView() {
                    DatabaseInfoView()
                    SettingsView()
                }
            }
            .tabViewStyle(.page)
        }
        .compositingGroup()
    }
}
