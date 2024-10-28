//
//  AppleDBApp.swift
//  AppleDB
//
//  Created by Kane Parkinson on 30/07/2024.
//

import SwiftUI

@main
struct AppleDBApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, HardwareProvider.shared.viewContext)
        }
    }
}
