//
//  BDaySupaLeft.swift
//  AppleDBPhoneWidget
//
//  Created by Kane Parkinson on 15/05/2024.
//

import SwiftUI
import WidgetKit

struct BDaySupaRightEntry: TimelineEntry {
    let date: Date
    let providerInfo: String
}

struct BDaySupaRightTimeLineProvider: TimelineProvider {
    typealias Entry = BDaySupaRightEntry
    
    func placeholder(in context: Context) -> Entry {
        return BDaySupaRightEntry(date: Date(), providerInfo: "placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = BDaySupaRightEntry(date: Date(), providerInfo: "snapshot")
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
        let entry = BDaySupaRightEntry(date: currentDate, providerInfo: "timeline")
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct BDaySupaRightWidgetView: View {
    
    let entry: BDaySupaRightEntry
    
    // Function to check if today is 8th September
    private var isBirthdayToday: Bool {
        let today = Calendar.current.dateComponents([.day, .month], from: entry.date)
        return today.day == 8 && today.month == 9
    }
    
    var body: some View {
        HStack {
            VStack {
                // Choose the image based on the date
                Image(uiImage: UIImage(named: isBirthdayToday ? "BDaySupaRight" : "NoBDaySupaRight") ?? UIImage())
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

struct BDaySupaRightWidget: Widget {
    let kind: String = "BDaySupaRight"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BDaySupaRightTimeLineProvider()) { entry in
            BDaySupaRightWidgetView(entry: entry)
        }
        .configurationDisplayName("Supa Birthday - Right Facing")
        .description("SuperBro Living Years, Images changes upon his birthday every year - Right Facing.")
        .supportedFamilies([.systemSmall])
    }
}
