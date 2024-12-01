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
    @State private var showDeleteConfirmation = false

    // Editable Fields
    @State private var deviceName: String
    @State private var deviceType: String
    @State private var chip: String
    @State private var version: String
    @State private var build: String
    @State private var osStr: String
    @State private var board: String
    @State private var notes: String

    init(vm: EditHardwareViewModel, hardware: Hardware) {
        self.vm = vm
        self.hardware = hardware
        _deviceName = State(initialValue: hardware.device ?? "")
        _deviceType = State(initialValue: hardware.type ?? "")
        _chip = State(initialValue: hardware.chip ?? "")
        _version = State(initialValue: hardware.version ?? "")
        _build = State(initialValue: hardware.build ?? "")
        _osStr = State(initialValue: hardware.osStr ?? "")
        _board = State(initialValue: hardware.board ?? "")
        _notes = State(initialValue: hardware.note ?? "")
    }

    var body: some View {
        VStack {
            // Image Section
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
                    if isEditing {
                        TextField("Device Name", text: $deviceName)
                        TextField("Device Type", text: $deviceType)
                        TextField("Chip", text: $chip)
                        TextField("Version", text: $version)
                        TextField("Build", text: $build)
                        TextField("OS", text: $osStr)
                        TextField("Board", text: $board)
                    } else {
                        Text("Device Name: \(hardware.device ?? "Unknown Device")")
                        Text("Device Type: \(hardware.type ?? "Unknown Type")")
                        Text("Chip: \(hardware.chip ?? "Unknown Chip")")
                        Text("Version: \(hardware.version ?? "Unknown Version")")
                        Text("Build: \(hardware.build ?? "Unknown Build")")
                        Text("OS: \(hardware.osStr ?? "Unknown OS")")
                        Text("Board: \(hardware.board ?? "Unknown Board")")
                    }
                }

                Section(header: Text("Notes")) {
                    if isEditing {
                        TextField("Notes", text: $notes)
                    } else {
                        Text(hardware.note?.isEmpty == false ? hardware.note! : "No notes available")
                    }
                }

                if isEditing {
                    Section {
                        Button(action: {
                            saveChanges()
                        }) {
                            Text("Save Changes")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Text("Delete Hardware")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .alert(isPresented: $showDeleteConfirmation) {
                            Alert(
                                title: Text("Delete Hardware"),
                                message: Text("Are you sure you want to delete this hardware entry? This action cannot be undone."),
                                primaryButton: .destructive(Text("Delete")) {
                                    deleteHardware()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Cancel" : "Edit")
                }
            }
        }
    }

    // MARK: - Save Changes
    private func saveChanges() {
        do {
            let context = vm.provider.viewContext
            guard let existingHardware = try context.existingObject(with: hardware.objectID) as? Hardware else {
                print("Failed to fetch existing hardware object.")
                return
            }

            existingHardware.device = deviceName.trimmingCharacters(in: .whitespacesAndNewlines)
            existingHardware.type = deviceType.trimmingCharacters(in: .whitespacesAndNewlines)
            existingHardware.chip = chip.trimmingCharacters(in: .whitespacesAndNewlines)
            existingHardware.version = version.trimmingCharacters(in: .whitespacesAndNewlines)
            existingHardware.build = build.trimmingCharacters(in: .whitespacesAndNewlines)
            existingHardware.osStr = osStr.trimmingCharacters(in: .whitespacesAndNewlines)
            existingHardware.board = board.trimmingCharacters(in: .whitespacesAndNewlines)
            existingHardware.note = notes.trimmingCharacters(in: .whitespacesAndNewlines)

            try context.save()
            isEditing = false
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving hardware: \(error)")
        }
    }

    // MARK: - Delete Hardware
    private func deleteHardware() {
        let context = vm.provider.viewContext

        do {
            guard let existingHardware = try context.existingObject(with: hardware.objectID) as? Hardware else {
                print("Failed to fetch existing hardware object.")
                return
            }

            context.delete(existingHardware)
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to delete hardware: \(error)")
        }
    }
}
