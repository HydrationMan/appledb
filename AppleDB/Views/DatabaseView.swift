//
//  DatabaseView.swift
//  AppleDB
//
//  Created by Kane Parkinson on 23/10/2024.
//

import SwiftUI
import SwipeActions
import NavigationStackBackport

struct DatabaseView: View {
    @State private var showCreateSheet = false
    @State private var selectedType: String? = nil
    @FetchRequest(fetchRequest: Hardware.all()) private var hardware
    var provider = HardwareProvider.shared

    let deviceTypes = ["All", "iPhone", "iPad", "iPad Pro", "iPad Air", "Apple Watch", "Apple TV", "AirPods", "Headset", "MacBook", "MacBook Air", "MacBook Pro", "Mac Pro", "Mac mini", "Mac Studio"]
    
    var filteredHardware: [Hardware] {
        if let selectedType = selectedType, selectedType != "All" {
            return hardware.filter { $0.type == selectedType }
        } else {
            return Array(hardware)
        }
    }
    
    var body: some View {
        NavigationStackBackport.NavigationStack {
                Picker("Device Type", selection: $selectedType) {
                    ForEach(deviceTypes, id: \.self) { type in
                        Text(type).tag(type as String?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                List {
                    ForEach(filteredHardware) { hardware in
                        NavigationLink(destination: {
                            let vm = EditHardwareViewModel(provider: provider)
                            DetailedHardwareView(vm: vm, hardware: hardware)
                        }) {
                            HardwareRowView(hardware: hardware)
                        }
                    }
                }
                .navigationBarItems(trailing: Button(action: {
                    showCreateSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                })
            }
            .navigationBarItems(trailing: Button(action: {
                showCreateSheet = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
            })
            .sheet(isPresented: $showCreateSheet) {
                let vm = EditHardwareViewModel(provider: provider)
                CreateHardwareView(vm: vm)
            }
    }
}

private extension DatabaseView {
    func delete(_ hardware: Hardware) throws {
        let context = provider.viewContext
        let existingHardware = try context.existingObject(with: hardware.objectID)
        context.delete(existingHardware)
        DispatchQueue.global(qos: .background).async {
            context.performAndWait {
                do {
                    try context.save()
                } catch {
                    print("Failed to save context: \(error)")
                }
            }
        }
    }
}
