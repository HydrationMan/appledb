//
//  SupaView.swift
//  AppleDBWatchApp
//
//  Created by Kane Parkinson on 26/09/2024.
//

import SwiftUI

struct SupaView: View {
    var body: some View {
        VStack {
            Text("This app contains Complications to add to your Watch face(s).")
                .font(.system(size: 10))
                .padding()
            Text("Dedicated to Hugo Mason. 2005-2024.")
                .font(.system(size: 10))
            Text("Miss ya buddy.")
                .font(.system(size: 10))
            Image("Superbro")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
        }
    }
}
