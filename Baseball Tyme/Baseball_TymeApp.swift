//
//  Baseball_TymeApp.swift
//  Baseball Tyme
//
//  Created by Michael Farrell on 7/26/25.
//

import SwiftUI
import BackgroundTasks

let bgTaskId = "com.vertostudio.Baseball-Tyme.refresh"

@main
struct Baseball_TymeApp: App {
    @Environment(\.scenePhase) private var scenePhase

    private let notificationManager = NotificationManager()
    @State private var data = DataStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(data: $data)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if scenePhase == .background {
                data.save()
                
                scheduleBackgroundRefresh()
            }
        }
    }
    
    init() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: bgTaskId, using: nil) { [self] task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }

        Task { [self] in
            await notificationManager.requestAuthorization()
            
            do {
                try await data.update()
                
                if let games = data.games {
                    await notificationManager.scheduleOut(for: data.team?.teamName ?? "Baseball", with: games)
                }
            } catch {
                data.errorState = true
            }
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        Task {
            do {
                try await data.update()
                
                if let games = data.games {
                    await notificationManager.scheduleOut(for: data.team?.teamName ?? "Baseball", with: games)
                }
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
    }
    
    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: bgTaskId)
        request.earliestBeginDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
               
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
