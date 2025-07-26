//
//  NotificationManager.swift
//  Baseball Tyme
//
//  Created by Michael Farrell on 7/26/25.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject {
    func requestAuthorization() async {
        let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        
        if granted == true {
            print("Good to go on notifications")
        }
    }
    
    func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func scheduleOut(for team: String, with games: [Game]) async {
        for game in games {
            guard game.gameDate > Date(), game.gameDate.isThisWeek else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "\(team.capitalized) Notification"
            if let homeTeam = game.homeTeamName, let awayTeam = game.awayTeamName {
                content.subtitle = "\(homeTeam) at \(awayTeam) starts at \(game.formattedDate ?? "unknown")"
            } else {
                content.subtitle = "\(team.capitalized) Game starts at \(game.formattedDate ?? "unknown")"
            }
            content.sound = nil
            
            let dateComponents = Calendar.current.dateComponents([.day, .month, .minute, .hour], from: game.gameDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            print("Scheduling game on \(game.gameDate)...")
            
            let notificationCenter = UNUserNotificationCenter.current()
            do {
                try await notificationCenter.add(request)
            } catch {
                print("plmlmmlmmlll!!!")
            }
        }
    }
}
