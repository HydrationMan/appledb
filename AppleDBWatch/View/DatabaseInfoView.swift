//
//  DatabaseInfoView.swift
//  AppleDBWatchApp
//
//  Created by Kane Parkinson on 16/05/2024.
//

import SwiftUI

struct DatabaseInfoView: View {
    @State private var hardwareToEdit: Hardware?
    @FetchRequest(fetchRequest: Hardware.all()) private var hardware

    var provider = HardwareProvider.shared
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Text("Devices: \(hardware.count)")
                        .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("Devices")
        }
    }
}

