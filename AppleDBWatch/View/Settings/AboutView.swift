//
//  AboutView.swift
//  AppleDBWatchApp
//
//  Created by Kane Parkinson on 30/09/2024.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Image(.appleDB)
                    .resizable()
                    .frame(width: 64, height: 64)
                Text("AppleDB")
                    .multilineTextAlignment(.center)
                Text("Version: \(retrieveVersion())")
                    .multilineTextAlignment(.center)
                Text("Build: \(retrieveBuild())")
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("About")
        }
    }
}
