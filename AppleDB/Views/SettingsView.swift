//
//  SettingsView.swift
//  AppleDB
//
//  Created by Kane Parkinson on 24/09/2024.
//

import SwiftUI
import NavigationStackBackport

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        NavigationStackBackport.NavigationStack {
            VStack {
                List {
                    NavigationLink("About") {
                        SettingsAboutView()
                    }
                    NavigationLink("Database") {
                        SettingsDatabaseView()
                            .environment(\.managedObjectContext, viewContext)
                        
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

