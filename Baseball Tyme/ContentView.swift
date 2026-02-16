//
//  ContentView.swift
//  Baseball Tyme
//
//  Created by Michael Farrell on 7/26/25.
//

import SwiftUI
import WidgetKit

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
    //let data: DataStore?
    @Binding var data: DataStore
    @State var configViewState = ConfigViewState()
    
    var gameView: some View {
        VStack {
            Text(data.team?.name ?? "Team Name")
                .font(Font.custom("American Typewriter", size: 24))
                .padding(.bottom, 5)
            if let game = data.todaysGames?.first {
                let have = game.gameDate > Date() ? "have" : "had"
                Text("\(have) a game today at \(game.formattedDate ?? "")")
            } else {
                Text("do not play today")
            }
        }
        .foregroundColor(.black)
        .padding(25)
    }
        
    var body: some View {
        ZStack {
            Color.clear.overlay {
                Image("Bg")
                    .resizable()
                    .scaledToFill()
                    .saturation(0.2)
                    .brightness(0.2)
                    .edgesIgnoringSafeArea(.all)
            }
            Rectangle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [.white, .black]), startPoint: .top, endPoint: .bottom)
                )
                .blendMode(.screen)
                .edgesIgnoringSafeArea(.all)
            
            if data.loading == false {
                VStack {
                    Spacer()
                    if #available(iOS 26.0, *) {
                        gameView
                            .glassEffect(.clear, in: .rect(cornerRadius: 25.0))
                    }
                    else {
                        gameView
                            .background(.white)
                            .cornerRadius(14)
                    }
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            configViewState.isPresented = true
                        } label: {
                            Image(systemName: "gear")
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: 50, height: 50)
                        .tint(.white)
                        .padding(.trailing, 35)
                    }
                    .onChange(of: data.currentTeamId) { oldValue, newValue in
                        WidgetCenter.shared.reloadTimelines(ofKind: "ScheduleWidget")
                    }
                }
                .sheet(isPresented: $configViewState.isPresented, onDismiss: didDismissEditor) {
                    ConfigView(data: $data, config: $configViewState)
                        .presentationDetents([.fraction(0.3)])
                        .presentationBackground(.clear)
                }
            } else {
                ProgressView()
                    .controlSize(.extraLarge)
                    .progressViewStyle(.circular)
                    .tint(.white)
            }
        }
    }
    
    private func didDismissEditor() {
        Task {
            try await data.updateGames()
        }
    }
}

#Preview {
    @Previewable @State var data = DataStore.mockStore
    ContentView(data: $data)
}
