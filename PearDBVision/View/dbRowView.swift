//
//  DeviceRowView.swift
//  PearDB
//
//  Created by Kane Parkinson on 11/02/2025.
//

import SwiftUI

struct dbRowView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DeviceName")
                .font(.system(size: 26,
                              design: .rounded).bold())
            Text("Identifier")
                .font(.callout.bold())
            Text("Model")
                .font(.callout.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            Button {
                
            } label: {
                Image(systemName: "star")
                    .font(.title3)
                    .symbolVariant(.fill)
                    .foregroundStyle(.gray.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    dbRowView()
}
