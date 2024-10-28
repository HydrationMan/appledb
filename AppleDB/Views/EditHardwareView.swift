//
//  EditHardwareView.swift
//  AppleDB
//
//  Created by Kane Parkinson on 24/10/2024.
//

import SwiftUI
import CoreData

struct EditHardwareView: View {
    @ObservedObject var vm: EditHardwareViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var firmwareEntries: [FirmwareEntry] = []
    @State private var selectedFirmware: FirmwareEntry?
    @State private var isLoadingFirmware = false

    @StateObject private var viewModel = DeviceViewModel()

    var body: some View {
        VStack {
            if isLoadingFirmware {
                ProgressView("Loading firmware...")
                    .padding()
            } else {
                VStack {
                    Text("Editing Firmware for \(vm.hardware.device ?? "Unknown Device")")
                        .font(.headline)
                        .padding()
                    
                    if !firmwareEntries.isEmpty {
                        Picker("Select Firmware", selection: $selectedFirmware) {
                            ForEach(firmwareEntries, id: \.self) { firmware in
                                Text("\(firmware.version) - \(firmware.build ?? "Unknown")")
                                    .tag(firmware as FirmwareEntry?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .onChange(of: selectedFirmware) { newFirmware in
                            if let firmware = newFirmware {
                                vm.hardware.version = firmware.version
                                vm.hardware.build = firmware.build ?? "Unknown"
                                vm.hardware.osStr = firmware.osStr
                            }
                        }
                    } else {
                        Text("No firmware data available for this device.")
                            .padding()
                    }

                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(8)
                        }

                        Button(action: {
                            saveChanges()
                        }) {
                            Text("Save")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Edit Firmware")
        .onAppear {
            viewModel.fetchDeviceList()
            loadInitialFirmwareData()
        }
    }
    
    private func loadInitialFirmwareData() {
        guard let identifier = vm.hardware.identifier, !identifier.isEmpty else {
            print("Error: Hardware identifier is empty or nil.")
            return
        }
        
        if let selectedDevice = viewModel.devices.first(where: { $0.identifier?.contains(identifier) == true }) {
            fetchFirmwareData(for: selectedDevice)
        } else {
            print("Error: No matching device found for identifier \(identifier).")
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
                        if !filteredEntries.isEmpty {
                            self.firmwareEntries = filteredEntries.sorted {
                                sortBuildNumbers($0.build, $1.build)
                            }
                            self.selectedFirmware = self.firmwareEntries.first
                        } else {
                            print("No relevant firmware entries found.")
                        }
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
                    print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                    self.isLoadingFirmware = false
                }
            }
        }.resume()
    }

    private func saveChanges() {
        do {
            try vm.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving hardware: \(error)")
        }
    }

    private func sortBuildNumbers(_ build1: String?, _ build2: String?) -> Bool {
        guard let build1 = build1, let build2 = build2 else {
            return build1 != nil
        }
        return build1.compare(build2, options: .numeric) == .orderedDescending
    }
}

extension Binding {
    init(_ source: Binding<Value?>, default defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}
