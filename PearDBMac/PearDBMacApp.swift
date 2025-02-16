//
//  PearDBMacApp.swift
//  PearDBMac
//
//  Created by Paras KCD on 16/2/25.
//

import SwiftUI

@main
struct PearDBMacApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, DeviceEntryProvider.shared.viewContext)
        }
    }
}

// MARK: NavigationStack
struct MainView: View {
    @State var selected: Int? = 0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Group {
                        NavigationLink(destination: DeviceView(), tag: 0, selection: $selected) {
                            Label("Devices", systemImage: "internaldrive")
                        }
                        NavigationLink(destination: Text("Firmware - soon"), tag: 1, selection: $selected) {
                            Label("Firmware", systemImage: "terminal")
                        }
                        NavigationLink(destination: Text("Database - soon"), tag: 2, selection: $selected) {
                            Label("Database", systemImage: "tray.full")
                        }
                        NavigationLink(destination: Text("Settings - soon"), tag: 3, selection: $selected) {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                } header: {
                    Text("PearDB")
                }
                
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("PearDB")
            .frame(minWidth: 150, idealWidth: 250, maxWidth: 300)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
            }
        }
    }
}

// Toggle Sidebar Function
func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
