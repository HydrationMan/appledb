//
//  HomeScreen.swift
//  PearDBWatchApp
//
//  Created by Kane Parkinson on 02/04/2024.
//

import SwiftUI

struct HomeScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple, .fixedCyan],startPoint: .topLeading,endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack {
                Link("Buy Rune!", destination: URL(string:"https://havoc.app/package/rune")!)
            }
        }
    }
}
