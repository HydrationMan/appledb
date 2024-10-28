//
//  HardwareRowView.swift
//  AppleDB
//
//  Created by Kane Parkinson on 23/10/2024.
//

import SwiftUI
import Combine
import SwipeActions

struct HardwareRowView: View {
    
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var hardware: Hardware
    
    var body: some View {
        SwipeViewGroup {
            SwipeView(
                label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(hardware.device ?? "Unknown")
                                .font(.system(size: 18, design: .rounded).bold())
                                .foregroundColor(.primary)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(formattedIdentifier)
                                        .font(.callout.bold())
                                        .foregroundColor(.primary)
                                    Text(hardware.chip ?? "Unknown")
                                        .font(.callout.bold())
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(hardware.version ?? "Unknown")
                                        .font(.callout.bold())
                                        .foregroundColor(.primary)
                                    Text(hardware.build ?? "Unknown")
                                        .font(.callout.bold())
                                        .foregroundColor(.primary)
                                }
                            }
                            Text("\(hardware.note ?? "")")
                                .font(.callout.bold())
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        AsyncCachedImage(
                            url: URL(string: "https://img.appledb.dev/device@main/\(hardware.identifier ?? "iPhone1,1")/0.avif"),
                            content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                            },
                            placeholder: {
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            }
                        )
                    }
                    .padding()
                    .cornerRadius(8)
                    .shadow(radius: 2)
                },
                trailingActions: { context in
                    SwipeAction(
                        systemImage: "trash",
                        backgroundColor: Color.red,
                        action: {
                            do {
                                try deleteHardware()
                            } catch {
                                print(error)
                            }
                        }
                    )
                }
            )
            .swipeMinimumDistance(30)
        }
    }
    
    private func deleteHardware() throws {
        moc.delete(hardware)
        try moc.save()
    }

    var formattedIdentifier: String {
        return (hardware.identifier ?? "Unknown").replacingOccurrences(of: "%20", with: " ")
    }
}
