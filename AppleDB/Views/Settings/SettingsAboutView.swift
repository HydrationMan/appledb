//
//  SettingsAboutView.swift
//  AppleDB
//
//  Created by Kane Parkinson on 18/12/2024.
//

import SwiftUI
import NavigationStackBackport

struct SettingsAboutView: View {
    var body: some View {
        NavigationStackBackport.NavigationStack {
            VStack {
                Image(.appleDB)
                    .resizable()
                    .frame(width: 256, height: 256)
                    .cornerRadius(15)
                Text("AppleDB")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 24))
                Text("Version: \(retrieveVersion())")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Text("Build: \(retrieveBuild())")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(.rightSupa)
                    .resizable()
                    .frame(width: 40, height: 40)
                Text("Miss you bro.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("2005-2024")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
            }
            .navigationTitle("About")
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
