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

    let deviceTypes: [String] = [
        "All", "iPhone", "iPad", "iPad Pro", "iPad Air", "Apple Watch", "Apple TV",
        "AirPods", "Headset", "MacBook", "MacBook Air", "MacBook Pro",
        "Mac Pro", "Mac mini", "Mac Studio"
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
//                floatingAddButton()
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
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 40, height: 40)
//                .foregroundColor(.accentColor)

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

//    private func floatingAddButton() -> some View {
//        VStack {
//            Spacer()
//            HStack {
//                Spacer()
//                Button(action: { showCreateSheet = true }) {
//                    Image(systemName: "plus.circle.fill")
//                        .resizable()
//                        .frame(width: 56, height: 56)
//                        .foregroundColor(.accentColor)
//                        .shadow(radius: 5)
//                }
//                .padding()
//            }
//        }
//    }

    // MARK: - Data Filtering

    private func filteredHardware() -> [Hardware] {
        guard let selectedType = selectedType, selectedType != "All" else {
            return Array(hardware)
        }
        return hardware.filter { $0.type == selectedType }
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
