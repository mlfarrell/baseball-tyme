//
//  ContentView.swift
//  Baseball Tyme
//
//  Created by Michael Farrell on 7/26/25.
//

import SwiftUI

extension Game
{
    static var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        return formatter
    }()
    
    var formattedDate: String? {
        Game.formatter.string(for: gameDate)
    }
    
    var homeTeamName: String? {
        teams.home.team.teamName
    }
    
    var awayTeamName: String? {
        teams.away.team.teamName
    }
}

struct ContentView: View {
    let data: DataStore?
    
    func update() async -> Bool {
        guard let data else { return false }
        return await data.update()
    }
    
    var body: some View {
        ZStack {
            Image("Bg")
                .saturation(0.2)
                .imageScale(.large)
                .foregroundStyle(.tint)
            Rectangle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [.white, .black]), startPoint: .top, endPoint: .bottom)
                )
                .blendMode(.screen)
            
            if data?.loading == false {
                VStack {
                    Text(data?.team?.name ?? "Team Name")
                        .font(Font.custom("American Typewriter", size: 24))
                        .padding(.bottom, 5)
                    if let game = data?.todaysGames?.first {
                        let have = game.gameDate > Date() ? "have" : "had"
                        Text("\(have) a game today at \(game.formattedDate ?? "")")
                    } else {
                        Text("do not play today")
                    }
                }
                .foregroundColor(.black)
                .padding()
                .background(.white)
                .cornerRadius(14)
            } else {
                ProgressView()
                    .controlSize(.extraLarge)
                    .progressViewStyle(.circular)
                    .tint(Color(red: 0.2, green: 0.2, blue: 1.0))
            }

        }
        .padding()
    }
}

#Preview {
    ContentView(data: DataStore.mockStore)
}
