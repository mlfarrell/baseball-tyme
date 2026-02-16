//
//  Game.swift
//  Baseball Tyme
//
//  Created by Michael Farrell on 7/26/25.
//

/// https://github.com/MajorLeagueBaseball/google-cloud-mlb-hackathon/blob/main/datasets/mlb-statsapi-docs/MLB-StatsAPI-Spec.json

import Foundation

struct Sport : Codable {
    let id: Int
}

struct League : Codable {
    let id: Int
    let name: String
    let link: URL?
}

struct Leagues: Codable {
    let leagues: [League]
}

struct Teams : Codable {
    let teams: [Team]
}

struct Team : Codable {
    let id: Int
    let name: String //"San Diego Padres"
    let teamName: String?
    let abbreviation: String?
    let link: URL?
}

//https://statsapi.mlb.com/api/v1/schedule/games/?sportId=1&teamId=135&startDate=07/01/2025&endDate=07/31/2025
struct Schedule : Codable {
    let dates: [GameDate]
}

struct GameDate: Codable {
    let games: [Game]
}

struct GameTeams: Codable {
    let away: GameTeam
    let home: GameTeam
}

struct GameTeam: Codable {
    let team: Team
}

struct Game : Codable {
    let teams: GameTeams
    let gameDate: Date
}
