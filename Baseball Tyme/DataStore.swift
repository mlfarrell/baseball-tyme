//
//  DataStore.swift
//  Baseball Tyme
//
//  Created by Michael Farrell on 7/26/25.
//

import Foundation

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
    let teamName: String?
    let team: Team
    let games: [Game]
}

@Observable
class DataStore {
    var cacheURL: URL? {
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        return url.appendingPathComponent("cacheData", conformingTo: .propertyList)
    }
    
    static var mockStore: DataStore {
        let store = DataStore()
        
        store.teamName = "San Diego Padres"
        store.loading = false
        store.team = Team(id: 0, name: store.teamName, teamName: "Padres", link: nil)
        store.games = [
            Game(teams: GameTeams(away: GameTeam(team: store.team!), home: GameTeam(team: store.team!)), gameDate: Date())
        ]
        return store
    }
    
    var todaysGames: [Game]? {
        return games?.filter { game in
            game.gameDate.isToday
        }
    }
    
    func load() -> Bool {
        guard let url =  cacheURL else { return false }
        guard let data = try? Data(contentsOf: url) else { return false }
        guard let unarchived = try? PropertyListDecoder().decode(ArchivedData.self, from: data) else { return false }
        
        if let name = unarchived.teamName {
            self.teamName = name
        }
        self.team = unarchived.team
        self.games = unarchived.games
        return true
    }
    
    func save() {
        guard let team, let games else { return }
        guard let data = try? PropertyListEncoder().encode(ArchivedData(teamName: teamName, team: team, games: games)) else { return }
        guard let url =  cacheURL else { return }
                                                           
        try? data.write(to: url)
    }
            
    func update(fromDisk: Bool = true) async -> Bool {
        if load() {
            loading = false
        }
        
        guard let teamResponse = await BaseballAPI.getTeam(named: teamName) else { return false }
        self.team = teamResponse
        self.games = await BaseballAPI.getGames(for: teamResponse)
        loading = false
        return true
    }
    
    var teamName = "San Diego Padres"
    var loading = true
    var team: Team?
    var games: [Game]?
}
