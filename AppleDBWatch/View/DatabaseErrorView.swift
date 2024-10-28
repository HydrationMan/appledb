//
//  DatabaseErrorView.swift
//  AppleDBWatchApp
//
//  Created by Kane Parkinson on 26/09/2024.
//

import SwiftUI

struct DatabaseErrorView: View {
    @State private var hardwareToEdit: Hardware?
    @FetchRequest(fetchRequest: Hardware.all()) private var hardware

    var provider = HardwareProvider.shared
    var body: some View {
        VStack {
            Image(.sad)
                .resizable()
                .frame(width: 60, height: 75)
            Text("Database error ocurred.")
        }
    }
}

