//
//  DeviceDetailView.swift
//  PearDBMac
//
//  Created by Paras KCD on 16/2/25.
//

import SwiftUI

struct DeviceDetailView: View {
    var device: Device
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                HStack {
                    AsyncImage(url: URL(string: "https://img.appledb.dev/device@main/\(device.key)/0.png")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 128, height: 256)
                        } else if phase.error != nil {
                            Color.clear
                                .frame(width: 128, height: 256)
                        } else {
                            ProgressView()
                        }
                    }
                    VStack(alignment: .leading) {
                        Text(device.name)
                            .font(.largeTitle)
                        Text("Released: \(device.released ?? "unknown")")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("Chip: \(device.soc ?? "unknown")")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("Model(s): \(device.model?.joined(separator: ", ") ?? "unknown")")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(.ultraThickMaterial)
            .compositingGroup()
            .shadow(radius: 5)
            .border(width: 1, edges: [.bottom], color: Color(NSColor.gridColor))
            
            ScrollView {
                
            }
        }
        
    }
}
