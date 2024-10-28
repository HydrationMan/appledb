//
//  DetailedHardwareView.swift
//  AppleDB
//
//  Created by Kane Parkinson on 24/10/2024.
//

import SwiftUI

struct DetailedHardwareView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm: EditHardwareViewModel
    let hardware: Hardware
    @State private var isEditing = false
    @State private var manualEditMode = false

    var body: some View {
        VStack {
            AsyncCachedImage(
                url: URL(string: "https://img.appledb.dev/device@main/\(hardware.identifier ?? "iPhone1,1")/0.avif"),
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                },
                placeholder: {
                    ProgressView()
                        .frame(width: 100, height: 100)
                }
            )
            List {
                Section(header: Text("General Information")) {
                    Text("Device Name: \(hardware.device ?? "Unknown")")
                    Text("Device Type: \(hardware.type ?? "Unknown")")
                    Text("Chip: \(hardware.chip ?? "Unknown")")
                    Text("Version: \(hardware.version ?? "Unknown")")
                    Text("Build: \(hardware.build ?? "Unknown")")
                    Text("OS: \(hardware.osStr ?? "Unknown")")
                    Text("Board: \(hardware.board ?? "Unknown")")
                }
                    
                Section(header: Text("Notes")) {
                    Text(hardware.note ?? "No notes available")
                }
            .navigationTitle("Hardware Details")
            }
        }
        .padding()
    }
    
    private func saveChanges() {
        do {
            try vm.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving hardware: \(error)")
        }
    }
}


