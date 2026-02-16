//
//  DataStore.swift
//  Baseball Tyme
//
//  Created by Michael Farrell on 7/26/25.
//

import Foundation
import SwiftUI

extension Date {
    var isThisWeek: Bool {
        let todayComponents = Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date())
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: self)

        return todayComponents.weekOfYear == dateComponents.weekOfYear && todayComponents.month == dateComponents.month && todayComponents.year == dateComponents.year
    }
    
    var isToday: Bool {
        let todayComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: self)

        return todayComponents.day == dateComponents.day && todayComponents.month == dateComponents.month && todayComponents.year == dateComponents.year
    }
}

struct ArchivedData : Codable {
    let currentTeamId: Int
    let team: Team
    let allTeams: [Team]
    let games: [Game]
}

@Observable
class DataStore {
    var cacheURL: URL? {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.vertostudio.baseball-tyme") else { return nil }
        //guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        return url.appendingPathComponent("cacheData", conformingTo: .propertyList)
    }
    
    static var mockStore: DataStore {
        let store = DataStore()
        
        store.loading = false
        store.team = Team(id: 1, name: store.teamName, teamName: "Padres", abbreviation: "SD", link: nil)
        store.currentTeamId = 2
        store.games = [
            Game(teams: GameTeams(away: GameTeam(team: store.team!), home: GameTeam(team: store.team!)), gameDate: Date())
        ]
        store.allTeams = [
            Team(id: 1, name: "San Diego Padres", teamName: "Padres", abbreviation: "SD", link: nil),
            Team(id: 2, name: "Baltimore Orioles", teamName: "Orioles", abbreviation: "BAL", link: nil)
        ]
        return store
    }
    
    var todaysGames: [Game]? {
        return games?.filter { game in
            game.gameDate.isToday
        }
    }
    
    init() {
        try? load()
    }
    
    func load() throws {
        guard let url =  cacheURL else { return }
        let data = try Data(contentsOf: url)
        let unarchived = try PropertyListDecoder().decode(ArchivedData.self, from: data)
        
        self.currentTeamId = unarchived.currentTeamId
        self.allTeams = unarchived.allTeams
        self.team = unarchived.team
        self.games = unarchived.games
    }
    
    func save() {
        guard let team, let games, let allTeams else { return }
        guard let data = try? PropertyListEncoder().encode(ArchivedData(currentTeamId: currentTeamId, team: team,  allTeams: allTeams, games: games)) else { return }
        guard let url =  cacheURL else { return }
                                                           
        try? data.write(to: url)
    }
                
    let defaultTeamName = "San Diego Padres"
    var teamName: String {
        get {
            return allTeams?.first { $0.id == currentTeamId }?.name ?? defaultTeamName
        }
    }
    
    func teamAbbreviation(id: Int) -> String {
        return allTeams?.first { $0.id == id }?.abbreviation ?? "Unk"
    }
    
    var currentTeamId: Int = 0
    var allTeams: [Team]?
    var team: Team?
    var games: [Game]?
    
    var loading = true
    var errorState = false
}
