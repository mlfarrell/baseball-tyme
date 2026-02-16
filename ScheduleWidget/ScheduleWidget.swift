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
        SimpleEntry(date: Date(), gameDate: nil, homeTeam: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), gameDate: nil, homeTeam: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let games = data.games else {
            completion(Timeline(entries: [], policy: .atEnd))
            return
        }
        
        let n = 5
        let nextNGames = games.indices.filter { i in
            games[i].gameDate > Date()
        }.prefix(n)
        
        let entries = nextNGames.map { i in
            let game = games[i]
            let previousGameDate = ((i > 0) ? games[i-1].gameDate : nil) ?? Date()
            let showAfter = Calendar.current.date(byAdding: .hour, value: 3, to: previousGameDate)
            let homeTeam = data.teamAbbreviation(id: game.teams.home.team.id)
            
            return SimpleEntry(date: showAfter ?? Date(), gameDate: game.gameDate, homeTeam: homeTeam)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let gameDate: Date?
    let homeTeam: String?
}

struct ScheduleWidgetEntryView : View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.widgetRenderingMode) var renderingMode

    var entry: Provider.Entry

    var body: some View {
        ZStack {
            if renderingMode == .fullColor {
                switch widgetFamily {
                case .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge:
                    Image("smallerBg")
                        .blur(radius: 2)
                        .saturation(0.2)
                    if colorScheme == .light {
                        Rectangle()
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [.white, .gray]), startPoint: .top, endPoint: .bottom)
                            )
                            .opacity(0.7)
                            .blendMode(.lighten)
                    } else {
                        Rectangle()
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [.white, .black]), startPoint: .top, endPoint: .bottom)
                            )
                            .opacity(0.75)
                            .blendMode(.multiply)
                    }
                default:
                    EmptyView()
                }
            } else {
                EmptyView()
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Next Game")
                    .padding(.bottom, 10)
                if entry.gameDate != nil, entry.homeTeam != nil {
                    HStack {
                        Image(systemName: "baseball")
                        HStack {
                            Text(entry.gameDate!.formatted(.dateTime.weekday()))
                            Text("\(entry.gameDate!.formatted(.dateTime.month(.defaultDigits)))/\(entry.gameDate!.formatted(.dateTime.day()))")
                        }
                        .minimumScaleFactor(0.75)
                    }
                    HStack {
                        Image(systemName: "baseball.circle")
                        Text(entry.gameDate!, style: .time)
                            .minimumScaleFactor(0.75)
                            .lineLimit(1)
                    }
                    switch widgetFamily {
                        case .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge:
                        HStack {
                            Image(systemName: "at.circle")
                            Text(entry.homeTeam!)
                                .minimumScaleFactor(0.75)
                                .lineLimit(1)
                        }
                        default:
                            EmptyView()
                    }
                } else {
                    Text("Unknown")
                }
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
        .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium, ])
    }
}

#Preview(as: .systemSmall) {
    ScheduleWidget()
} timeline: {
    SimpleEntry(date: .now, gameDate: .now, homeTeam: "San")
}
