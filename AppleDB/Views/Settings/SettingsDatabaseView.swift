//
//  SettingsDatabaseView.swift
//  AppleDB
//
//  Created by Kane Parkinson on 18/12/2024.
//

import SwiftUI
import NavigationStackBackport

struct SettingsDatabaseView: View {
    var body: some View {
        NavigationStackBackport.NavigationStack {
            VStack {
                Text("The settings-ening begins...")
                    .multilineTextAlignment(.center)
                Text("(I definitely did NOT run out of steam to finish more settings.)")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Database")
        }
    }
}
