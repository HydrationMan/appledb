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
        VStack {
            if viewModel.devices.isEmpty {
                Text("Loading devices...")
            } else {
                Toggle("Show Filtered Types", isOn: $showFilteredTypes)
                    .padding()

                let filteredDeviceTypes = ["iPhone", "iPad", "iPad Pro", "iPad Air", "Apple Watch", "Apple TV", "AirPods", "Headset", "MacBook", "MacBook Air", "MacBook Pro", "Mac Pro", "Mac mini", "Mac Studio"]

                var filteredTypes: [String] {
                    return allTypes.filter { filteredDeviceTypes.contains($0) }
                }
                
                var allTypes: [String] {
                    return Array(Set(viewModel.devices.map { $0.type })).sorted()
                }

                Picker("Device Type", selection: $selectedType) {
                    Text("Select a type").tag(nil as String?)
                    ForEach(showFilteredTypes ? filteredTypes : allTypes, id: \.self) { type in
                        Text(type).tag(type as String?)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding()
                .onChange(of: selectedType) { newType in
                    withAnimation(.easeInOut) {
                        if newType != nil {
                            selectedDevice = nil
                        }
                    }
                }

                if let selectedType = selectedType {
                    let filteredDevices = viewModel.devices.filter { $0.type == selectedType }

                    Picker("Select a \(selectedType)", selection: $selectedDevice) {
                        Text("Select a \(selectedType)").tag(nil as DeviceListEntry?) // Placeholder
                        ForEach(filteredDevices, id: \.self) { device in
                            Text(device.name).tag(device as DeviceListEntry?)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .padding()
                    .id(selectedType)
                    .transition(.scale)
                    .animation(.easeInOut, value: selectedType)
                    .onChange(of: selectedDevice) { newDevice in
                        if let device = newDevice {
                            fetchFirmwareData(for: device)
                        }
                    }

                    if let details = selectedDevice {
                        VStack(alignment: .leading) {
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
                                .padding()
                            } else {
                                Text("Board: \(details.board?.first ?? "Unknown")")
                                    .onAppear {
                                        selectedBoard = details.board?.first
                                    }
                            }

                            if isLoadingFirmware {
                                ProgressView("Loading Firmware...")
                            } else if !firmwareEntries.isEmpty {
                                Picker("Select Firmware", selection: $selectedFirmware) {
                                    ForEach(firmwareEntries, id: \.self) { firmware in
                                        Text("\(firmware.version) - \(firmware.build ?? "Unknown")")
                                            .tag(firmware as FirmwareEntry?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                            }

                            Button(action: {
                                saveDeviceToCoreData(details)
                                print("Current Identifier \(Locale.current.identifier)")
                            }) {
                                Text("Save Device")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .transition(.opacity.combined(with: .scale))
                        .animation(.easeInOut, value: selectedDevice)
                    } else {
                        Text("Select a device to see details.")
                            .padding()
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut, value: selectedDevice)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchDeviceList()
        }
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

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode([FirmwareEntry].self, from: data)

                    let filteredEntries = decodedData.filter { entry in
                        entry.deviceMap.contains(device.identifier?.first ?? "")
                    }

                    DispatchQueue.main.async {
                        self.firmwareEntries = filteredEntries.sorted {
                            sortBuildNumbers($0.build, $1.build)
                        }
                        self.selectedFirmware = self.firmwareEntries.first
                        self.isLoadingFirmware = false
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                    DispatchQueue.main.async {
                        self.isLoadingFirmware = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoadingFirmware = false
                }
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
