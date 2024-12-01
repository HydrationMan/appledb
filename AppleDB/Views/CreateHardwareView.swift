//
//  CreateHardwareView.swift
//  AppleDB
//
//  Created by Kane Parkinson on 07/08/2024.
//

import SwiftUI
import Combine
import Foundation

struct CreateHardwareView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = DeviceViewModel()

    @State private var showFilteredTypes: Bool = false
    @State private var selectedType: String?
    @State private var selectedDevice: DeviceListEntry?
    @State private var selectedBoard: String?

    @State private var firmwareEntries: [FirmwareEntry] = []
    @State private var selectedFirmware: FirmwareEntry?
    @State private var isLoadingFirmware = false

    let hardwareProvider = HardwareProvider.shared
    @ObservedObject var vm: EditHardwareViewModel

    var body: some View {
        NavigationView {
            Form {
                // Device Type Selection Section
                Section(header: Text("Device Type").font(.headline)) {
                    Toggle("Show Filtered Types", isOn: $showFilteredTypes)
                        .padding(.vertical, 5)

                    Picker("Select Device Type", selection: $selectedType) {
                        Text("Select a type").tag(nil as String?)
                        ForEach(filteredDeviceTypes, id: \.self) { type in
                            Text(type).tag(type as String?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedType) { newType in
                        withAnimation(.easeInOut) {
                            if newType != nil {
                                selectedDevice = nil
                            }
                        }
                    }
                }

                // Device Selection Section
                if let selectedType = selectedType {
                    Section(header: Text("Select a \(selectedType)").font(.headline)) {
                        Picker("Select Device", selection: $selectedDevice) {
                            Text("Select a \(selectedType)").tag(nil as DeviceListEntry?)
                            ForEach(viewModel.devices.filter { $0.type == selectedType }, id: \.self) { device in
                                Text(device.name).tag(device as DeviceListEntry?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedDevice) { newDevice in
                            if let device = newDevice {
                                fetchFirmwareData(for: device)
                            }
                        }
                    }
                }

                // Device Details Section
                if let details = selectedDevice {
                    Section(header: Text("Device Details").font(.headline)) {
                        Text("Device Name: \(details.name)")
                        Text("SoC: \(details.soc)")
                        Text("Architecture: \(details.arch ?? "Unknown")")
                        Text("Type: \(details.type)")
                        Text("Released: \(details.released.joined(separator: ", "))")

                        if let boardOptions = details.board, boardOptions.count > 1 {
                            Picker("Select Board", selection: $selectedBoard) {
                                ForEach(boardOptions, id: \.self) { board in
                                    Text(board).tag(board)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        } else {
                            Text("Board: \(details.board?.first ?? "Unknown")")
                                .onAppear {
                                    selectedBoard = details.board?.first
                                }
                        }
                    }
                }

                // Firmware Selection Section
                if isLoadingFirmware {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView("Loading Firmware...")
                            Spacer()
                        }
                    }
                } else if !firmwareEntries.isEmpty {
                    Section(header: Text("Select Firmware").font(.headline)) {
                        Picker("Firmware Version", selection: $selectedFirmware) {
                            ForEach(firmwareEntries, id: \.self) { firmware in
                                Text("\(firmware.version) - \(firmware.build ?? "Unknown")")
                                    .tag(firmware as FirmwareEntry?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }

                // Save Button
                Section {
                    Button(action: {
                        saveDeviceToCoreData(selectedDevice!)
                    }) {
                        Text("Save Device")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(canSave ? Color.accentColor : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!canSave)
                }
            }
            .navigationTitle("Add New Hardware")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchDeviceList()
            }
        }
    }

    // MARK: - Helper Methods

    private var filteredDeviceTypes: [String] {
        let allTypes = Array(Set(viewModel.devices.map { $0.type })).sorted()
        let predefinedTypes = ["iPhone", "iPad", "iPad Pro", "iPad Air", "Apple Watch", "Apple TV", "AirPods", "Headset", "MacBook", "MacBook Air", "MacBook Pro", "Mac Pro", "Mac mini", "Mac Studio"]
        return showFilteredTypes ? allTypes.filter { predefinedTypes.contains($0) } : allTypes
    }

    private var canSave: Bool {
        // Check if all required fields are selected
        guard let _ = selectedType,
              let _ = selectedDevice,
              let _ = selectedFirmware else {
            return false
        }

        // If multiple boards are available, ensure a board is selected
        if let details = selectedDevice, let boardOptions = details.board, boardOptions.count > 1 {
            return selectedBoard != nil
        }

        return true
    }

    private func saveDeviceToCoreData(_ device: DeviceListEntry) {
        vm.hardware.identifier = device.identifier?.first ?? "Unknown"
        vm.hardware.device = device.name
        vm.hardware.type = device.type
        vm.hardware.chip = device.soc
        vm.hardware.version = selectedFirmware?.version ?? "Unknown"
        vm.hardware.build = selectedFirmware?.build ?? "Unknown"
        vm.hardware.osStr = selectedFirmware?.osStr ?? "Unknown"
        vm.hardware.board = selectedBoard ?? "Unknown"

        do {
            try vm.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save hardware to CoreData: \(error)")
        }
    }

    private func fetchFirmwareData(for device: DeviceListEntry) {
        isLoadingFirmware = true
        guard let url = URL(string: "https://api.appledb.dev/ios/main.json") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([FirmwareEntry].self, from: data)
                    DispatchQueue.main.async {
                        firmwareEntries = decodedData.filter { $0.deviceMap.contains(device.identifier?.first ?? "") }
                        selectedFirmware = firmwareEntries.first
                        isLoadingFirmware = false
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                    isLoadingFirmware = false
                }
            } else {
                isLoadingFirmware = false
            }
        }.resume()
    }

    
    private func sortBuildNumbers(_ build1: String?, _ build2: String?) -> Bool {
        guard let build1 = build1, let build2 = build2 else {
            return build1 != nil
        }
        return build1.compare(build2, options: .numeric) == .orderedDescending
    }
}
