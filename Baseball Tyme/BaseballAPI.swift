//
//  BaseballAPI.swift
//  Baseball Tyme
//
//  Created by Michael Farrell on 7/26/25.
//

import Foundation

class BaseballAPI
{
    static let baseURL = URL(string: "https://statsapi.mlb.com/api/v1/")!
    
    static var seaonStart: Date {
        let year = Calendar.current.component(.year, from: Date())
        
        var components = DateComponents()
        components.day = 1
        components.month = 3
        components.year = year
        return Calendar.current.date(from: components) ?? Date()
    }

    static var seaonEnd: Date {
        let year = Calendar.current.component(.year, from: Date())
        
        var components = DateComponents()
        components.day = 31
        components.month = 10
        components.year = year
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static var dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()

    static func getTeam(named name: String) async -> Team? {
        guard let url = URL(string: "teams", relativeTo: baseURL) else { return nil }
        let request = URLRequest(url: url)
        
        guard let (data, _) = try? await URLSession.shared.data(for: request) else { return nil }
        guard let teams = try? JSONDecoder().decode(Teams.self, from: data) else { return nil }
        
        return teams.teams.first { $0.name.lowercased() == name.lowercased() }
    }
    
    static func getGames(for team: Team) async -> [Game]? {
        guard var url = URL(string: "schedule/games", relativeTo: baseURL) else { return nil }
        url.append(queryItems: [
            URLQueryItem(name: "sportId", value: "1"),
            URLQueryItem(name: "teamId", value: "\(team.id)"),
            URLQueryItem(name: "startDate", value:  dateFormatter.string(from: seaonStart)),
            URLQueryItem(name: "endDate", value: dateFormatter.string(from: seaonEnd)),
        ])
        
        let request = URLRequest(url: url)
                
        guard let (data, _) = try? await URLSession.shared.data(for: request) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let schedule = try! decoder.decode(Schedule.self, from: data)

        let allGames = schedule.dates.map {
            $0.games
        }.flatMap {
            $0
        }
        
        return allGames
    }
}
