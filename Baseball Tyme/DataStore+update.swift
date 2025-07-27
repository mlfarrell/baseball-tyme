//
//  DataStore+update.swift
//  Baseball Tyme
//
//  Created by Michael Farrell on 7/26/25.
//

import Foundation

extension DataStore {
    func update(fromDisk: Bool = true) async -> Bool {
        if fromDisk && load() {
            loading = false
        }
        
        guard let teamResponse = await BaseballAPI.getTeam(named: teamName) else { return false }
        self.team = teamResponse
        self.games = await BaseballAPI.getGames(for: teamResponse)
        loading = false
        return true
    }
}
