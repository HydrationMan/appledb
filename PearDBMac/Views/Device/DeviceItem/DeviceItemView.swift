//
//  DeviceDetailView.swift
//  PearDBMac
//
//  Created by Paras KCD on 16/2/25.
//

import SwiftUI

struct DeviceItemView: View {
    var device: Device
    
    var body: some View {
        NavigationLink(destination: DeviceDetailView(device: device)) {
            HStack {
                AsyncImage(url: URL(string: "https://img.appledb.dev/device@main/\(device.key)/0.png")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 64)
                    } else if phase.error != nil {
                        Color.clear
                            .frame(width: 32, height: 64)
                    } else {
                        ProgressView()
                    }
                }
                VStack(alignment: .leading) {
                    Text(device.name)
                    Text(device.type ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                Image(systemName: "chevron.forward")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
