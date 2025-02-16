//
//  HeaderView.swift
//  PearDBMac
//
//  Created by Paras KCD on 16/2/25.
//

import SwiftUI

struct HeaderView: View {
    var title: String
    var searchable: (String) -> Void
    var applyFilter: (String?) -> Void
    
    @State var filter: String? = nil
    @State var search: String = ""
    
    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.largeTitle)
            Searchbar(searchText: $search, hasCancel: !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) { searching in
                searchable(searching)
            } onCancel: {
                
            }
            Menu {
                Button("Filter") {
                    self.filter = nil
                    self.applyFilter(self.filter)
                }
                Button("Accessories") {
                    self.filter = "Accessories"
                    self.applyFilter(self.filter)
                }
            } label: {
                Label {
                    Text(filter ?? "Filter")
                } icon: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                .containerShape(RoundedRectangle(cornerRadius: 99))
            }
            .frame(maxWidth: 128)
            .menuStyle(BorderlessButtonMenuStyle())
            .padding(16)
            .background(.thickMaterial)
            .cornerRadius(99)
            .overlay {
                RoundedRectangle(cornerRadius: 99).stroke(Color(NSColor.separatorColor), lineWidth: 1)
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(.ultraThickMaterial)
        .compositingGroup()
        .shadow(radius: 5)
        .border(width: 1, edges: [.bottom], color: Color(NSColor.gridColor))
    }
}
