//
//  BDaySupaLeft.swift
//  AppleDBPhoneWidget
//
//  Created by Kane Parkinson on 15/05/2024.
//

import SwiftUI
import WidgetKit

struct BDaySupaLeftEntry: TimelineEntry {
    let date: Date
    let providerInfo: String
}

struct BDaySupaLeftTimeLineProvider: TimelineProvider {
    typealias Entry = BDaySupaLeftEntry
    
    func placeholder(in context: Context) -> Entry {
        return BDaySupaLeftEntry(date: Date(), providerInfo: "placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = BDaySupaLeftEntry(date: Date(), providerInfo: "snapshot")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        var nextUpdateDate: Date
        
        // Determine the next update time
        let today = Calendar.current.dateComponents([.day, .month], from: currentDate)
        
        if today.day == 7 && today.month == 9 {
            // On September 7th, update hourly
            nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate
        } else {
            // Set the next update for midnight
            nextUpdateDate = Calendar.current.startOfDay(for: currentDate).addingTimeInterval(86400) // Midnight of the next day
        }
        
        // Create the timeline entry
        let entry = BDaySupaLeftEntry(date: currentDate, providerInfo: "timeline")
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct BDaySupaLeftWidgetView: View {
    
    let entry: BDaySupaLeftEntry
    
    // Function to check if today is 8th September
    private var isBirthdayToday: Bool {
        let today = Calendar.current.dateComponents([.day, .month], from: entry.date)
        return today.day == 8 && today.month == 9
    }
    
    var body: some View {
        HStack {
            VStack {
                // Choose the image based on the date
                Image(uiImage: UIImage(named: isBirthdayToday ? "BDaySupaLeft" : "NoBDaySupaLeft") ?? UIImage())
                    .resizable()
                    .frame(width: 42, height: 42)
                    .widgetBackground(Color.clear)
                
                Text("Superbro")
                Text("2005-2024")
                
                // Show birthday message if it's 8th September
                if isBirthdayToday {
                    Text("Happy Birthday Bro")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .widgetBackground(Color.clear)
        }
    }
}

struct BDaySupaLeftWidget: Widget {
    let kind: String = "BDaySupaLeft"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BDaySupaLeftTimeLineProvider()) { entry in
            BDaySupaLeftWidgetView(entry: entry)
        }
        .configurationDisplayName("Supa Birthday - Left Facing")
        .description("SuperBro Living Years, Images changes upon his birthday every year. Left Facing.")
        .supportedFamilies([.systemSmall])
    }
}
