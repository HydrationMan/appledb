//
//  SettingsView.swift
//  AppleDBWatchApp
//
//  Created by Kane Parkinson on 30/09/2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: AboutView()) {
                    Text("About AppleDB")
                    }
                NavigationLink(destination: SupaView()) {
                    Text("Superbro")
                }
                NavigationLink(destination: SettingsDatabase()) {
                    Text("Database Settings")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

func retrieveBuild() -> String {
    if let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
        return appBuild
    }
    return "Unknown"
}
func retrieveVersion() -> String {
    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        return appVersion
    }
    return "Unknown"
}

