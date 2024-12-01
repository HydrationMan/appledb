//
//  HardwareRowView.swift
//  AppleDB
//
//  Created by Kane Parkinson on 23/10/2024.
//

import SwiftUI
import Combine
import SwipeActions

//struct HardwareRowView: View {
//    @Environment(\.managedObjectContext) private var moc
//    let hardware: Hardware
//
//    var body: some View {
//        SwipeViewGroup {
//            SwipeView {
//                HStack {
//                    // Display hardware information
//                    Image(systemName: "desktopcomputer")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 40, height: 40)
//
//                    VStack(alignment: .leading) {
//                        Text(hardware.name ?? "Unknown Device")
//                            .font(.headline)
//
//                        Text(hardware.model ?? "Unknown Model")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    }
//
//                    Spacer()
//                }
//                .padding()
//                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)))
//                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
//            } leadingActions: { _ in
//                // Example of a leading swipe action
//                SwipeAction(systemImage: "pencil.circle") {
//                    // Edit action
//                    print("Edit hardware tapped")
//                }
//                .font(.title)
//                .background {
//                    VisualEffectView(.systemThinMaterial)
//                }
////                .allowSwipeToTrigger() // Allows swipe to trigger without tap
//            } trailingActions: { context in
//                // Delete Action with Custom Background and Animation
//                SwipeAction(systemImage: "trash", backgroundColor: .red) {
//                    context.state.wrappedValue = .closed
//                    withAnimation(.spring()) {
//                        do {
//                            try deleteHardware()
//                        } catch {
//                            print(error)
//                        }
//                    }
//                }
//                .font(.largeTitle)
////                .swipeActionWidth(100) // Customize swipe action width
////                .allowSwipeToTrigger() // Allows swipe-to-trigger delete
//                .background {
//                    VisualEffectView(.systemChromeMaterial)
//                }
//            }
//        }
//        .contentShape(Rectangle()) // Allows blank space to be swipeable too
//    }

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
                            withAnimation(.spring()) {
                                do {
                                    try deleteHardware()
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    )
                    .allowSwipeToTrigger()
                }
            )
            .swipeActionWidth(100)
            .swipeMinimumDistance(30)
        }
    }

    // MARK: - Delete Hardware
    private func deleteHardware() throws {
        moc.delete(hardware)
        try moc.save()
    }

    var formattedIdentifier: String {
        return (hardware.identifier ?? "Unknown").replacingOccurrences(of: "%20", with: " ")
    }
}
