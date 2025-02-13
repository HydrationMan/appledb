//
//  dbView.swift
//  PearDB
//
//  Created by Kane Parkinson on 04/02/2025.
//

import SwiftUI

struct dbView: View {
    
    @State private var isShowingNewDevice = false
    
    var provider = DeviceEntryProvider.shared
    
    var body: some View {
        NavigationStack {
            List {
                ForEach((0...10), id: \.self) { item in
                    ZStack(alignment: .leading) {
                        NavigationLink(destination: dbDetailView()) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        dbRowView()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingNewDevice.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $isShowingNewDevice) {
                NavigationStack {
                    newDeviceView()
                }
            }
            .navigationTitle("Database")
        }
    }
}

#Preview {
    NavigationStack {
        dbView()
    }
}
