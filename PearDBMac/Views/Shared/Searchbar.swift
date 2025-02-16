//
//  Searchbar.swift
//  PearDBMac
//
//  Created by Paras KCD on 16/2/25.
//

import SwiftUI

struct Searchbar: View {
    @Binding var searchText: String
    var hasCancel: Bool = true
    var action: (String) -> Void
    var onCancel: ()->()
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $searchText)
                .onChange(of: searchText) { searching in
                    action(searching)
                }
                .textFieldStyle(.plain)
            if hasCancel {
                Button(action: {
                    searchText = ""
                    onCancel()
                }) {
                    Image(systemName: "x.circle")
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
                .transition(.move(edge: .trailing))
                .animation(.easeInOut(duration: 1.0), value: UUID())
            }
        }
        .padding(16)
        .background(.thickMaterial)
        .cornerRadius(99)
        .overlay {
            RoundedRectangle(cornerRadius: 99).stroke(Color(NSColor.separatorColor), lineWidth: 1)
        }
    }
}
