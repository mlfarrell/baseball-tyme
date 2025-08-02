//
//  DataStore+update.swift
//  Baseball Tyme
//
//  Created by Michael Farrell on 7/26/25.
//

import Foundation

extension DataStore {
    func updateGames() async throws {
        if let team = allTeams?.first(where: { $0.name.lowercased() == teamName.lowercased() }) {
            self.team = team
            self.games = try await BaseballAPI.getGames(for: team)
            self.currentTeamId = team.id
        }
    }
    
    func update(onlyFromDisk: Bool = false) async throws {        
        do {
            try load()
            loading = false
        }
        catch {
            //carry on and load from API
        }
        
        if !onlyFromDisk {
            let majorLeagues = try await BaseballAPI.getMajorLeagues()
            let teamsResponse = try await BaseballAPI.getAllTeams(in: majorLeagues)
            self.allTeams = teamsResponse
            
            try await updateGames()
            loading = false
        }
    }
}
