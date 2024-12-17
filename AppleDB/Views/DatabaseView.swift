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
    @State private var showCreateSheet: Bool = false
    @State private var selectedType: String? = "All"
    @FetchRequest(fetchRequest: Hardware.all()) private var hardware: FetchedResults<Hardware>
    var provider = HardwareProvider.shared

    let categorizedDeviceTypes: [String: [String]] = [
        "All": [
            "iPhone", "iPad", "iPad Pro", "iPad Air", "iPad mini", "Apple Watch", "Apple TV",
            "AirPods", "Headset", "MacBook", "MacBook Air", "MacBook Pro",
            "Mac Pro", "Mac mini", "Mac Studio"
        ],
        "iPad": ["iPad", "iPad Pro", "iPad Air", "iPad mini"],
        "Mac": ["MacBook", "MacBook Air", "MacBook Pro", "Mac Pro", "Mac mini", "Mac Studio"],
        "iPhone": ["iPhone"],
        "Apple Watch": ["Apple Watch"],
        "AirPods": ["AirPods"],
        "Vision Pro": ["Headset"],
        "Apple TV": ["Apple TV"]
    ]

    let deviceTypes: [String] = [
        "All", "iPhone", "iPad", "Mac", "Apple Watch", "AirPods", "Vision Pro", "Apple TV"
    ]

    var body: some View {
        NavigationStackBackport.NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                VStack(spacing: 16) {
                    deviceTypeFilterView()
                    compactDeviceListView()
                }
                .padding(.top)
            }
            .navigationTitle("Hardware Database")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateSheet = true }) {
                        Image(systemName: "plus").font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                let vm = EditHardwareViewModel(provider: provider)
                CreateHardwareView(vm: vm)
            }
        }
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func deviceTypeFilterView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(deviceTypes, id: \.self) { type in
                    Button(action: {
                        selectedType = type
                    }) {
                        Text(type)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedType == type ? Color.accentColor : Color(.secondarySystemBackground))
                            .foregroundColor(selectedType == type ? .white : .primary)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func compactDeviceListView() -> some View {
        List(filteredHardware()) { hardware in
            NavigationLink(destination: {
                let vm = EditHardwareViewModel(provider: provider)
                DetailedHardwareView(vm: vm, hardware: hardware)
            }) {
                compactHardwareRowView(hardware: hardware)
                    .listRowBackground(Color(.secondarySystemBackground))
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    private func compactHardwareRowView(hardware: Hardware) -> some View {
        HStack(spacing: 16) {
            // Device Icon
            AsyncCachedImage(
                url: URL(string: "https://img.appledb.dev/device@main/\(hardware.identifier ?? "iPhone1,1")/0.avif"),
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                },
                placeholder: {
                    ProgressView()
                        .frame(width: 40, height: 40)
                }
            )

            // Device Info
            VStack(alignment: .leading) {
                Text(hardware.device ?? "Unknown Device")
                    .font(.headline)
                Text("\(hardware.identifier ?? "Unknown Model") - \(hardware.version ?? "Unknown Version") (\(hardware.build ?? "Unknown Build"))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

    // MARK: - Data Filtering

    private func filteredHardware() -> [Hardware] {
        guard let selectedType = selectedType, selectedType != "All" else {
            return Array(hardware)
        }

        // Get the corresponding subtypes for the selected category
        let subtypes = categorizedDeviceTypes[selectedType] ?? [selectedType]

        // Filter hardware by subtypes
        return hardware.filter { subtypes.contains($0.type ?? "") }
    }
}

extension DatabaseView {
    public func delete(_ hardware: Hardware) throws {
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
