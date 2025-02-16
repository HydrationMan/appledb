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
                VStack(alignment: .leading) {
                    Text(device.name)
                    Text(device.type ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
