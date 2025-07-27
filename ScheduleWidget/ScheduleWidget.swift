//
//  ScheduleWidget.swift
//  ScheduleWidget
//
//  Created by Michael Farrell on 7/26/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let data = DataStore()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), gameDate: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), gameDate: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let nextGame = data.games?.first { game in
            game.gameDate > Date()
        }
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, gameDate: nextGame?.gameDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let gameDate: Date?
}

struct ScheduleWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Next Game")
                .padding(.bottom, 10)
            if entry.gameDate != nil {
                HStack {
                    Image(systemName: "baseball")
                    HStack {
                        Text(entry.gameDate!.formatted(.dateTime.weekday()))
                        Text(entry.gameDate!.formatted(.dateTime.day()))
                    }
                }
                HStack {
                    Image(systemName: "baseball.circle")
                    Text(entry.gameDate!, style: .time)
                }
            } else {
                Text("Unknown")
            }
        }
        .font(Font.custom("American Typewriter", size: 16))
        .padding()
        //.foregroundStyle(.white)
        .background(.clear)
        .cornerRadius(12)
    }
}

struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ScheduleWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ScheduleWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Baseball Widget")
        .description("Baseball schedule widget")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    ScheduleWidget()
} timeline: {
    SimpleEntry(date: .now, gameDate: .now)
}
