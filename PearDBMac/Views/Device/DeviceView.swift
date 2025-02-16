//
//  DeviceView.swift
//  PearDBMac
//
//  Created by Paras KCD on 16/2/25.
//

import SwiftUI

struct DeviceView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    @StateObject var deviceViewModel: DeviceViewModel = .init(appDbDownloader: AppleDBDownloader.shared)
    
    var body: some View {
        ZStack {
            Rectangle.semiOpaqueWindow().padding(-1)
            VStack {
                HeaderView(title: "Devices") { search in
                    deviceViewModel.search(searchString: search)
                } applyFilter: { filter in
                    deviceViewModel.filter(filterString: filter)
                }
                NavigationStack {
                    if deviceViewModel.isLoading {
                        ProgressView("Downloading Device Data…")
                            .progressViewStyle(.circular)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    else {
                        ScrollView {
                            LazyVGrid(columns: columns, alignment: .leading) {
                                if (!deviceViewModel.searchedDevices.isEmpty) {
                                    ForEach(deviceViewModel.searchedDevices.lazy, id: \.id) { device in
                                        DeviceItemView(device: device)
                                    }
                                } else if (!deviceViewModel.devices.isEmpty) {
                                    ForEach(deviceViewModel.devices.lazy, id: \.id) { device in
                                        DeviceItemView(device: device)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                }
            }
        }
    }
}
