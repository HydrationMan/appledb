//
//  dbDetailView.swift
//  PearDB
//
//  Created by Kane Parkinson on 11/02/2025.
//

import SwiftUI

struct dbDetailView: View {
    var body: some View {
        Spacer()
        Image(systemName: "ipad.landscape.and.iphone")
            .font(.system(size: 120))
        List {
            LabeledContent {
                Text("iPhone xx Pro Max")
            } label: {
                Text("Product Name")
            }
            Section("Product Details") {
                LabeledContent {
                    Text("Test")
                } label: {
                    Text("Identifier")
                }
                LabeledContent {
                    Text("Test")
                } label: {
                    Text("Board")
                }
                LabeledContent {
                    Text("Test")
                } label: {
                    Text("Model")
                }
                LabeledContent {
                    Text("Test")
                } label: {
                    Text("Released")
                }
            }
            LabeledContent {
                Text("Test")
            } label: {
                Text("Serial Number")
            }
        }.navigationTitle("Device")
    }
}

#Preview {
    NavigationStack {
        dbDetailView()
    }
}
