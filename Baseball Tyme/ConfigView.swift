//
//  ConfigView.swift
//  Baseball Tyme
//
//  Created by Michael Farrell on 7/27/25.
//

import SwiftUI

struct ConfigViewState {
    var isPresented = false
}

//extension Team: Identifiable {
//    //var id: String { self.id }
//}

struct ConfigView: View {
    @Binding var data: DataStore
    @Binding var config: ConfigViewState

    var body: some View {
        VStack {
            HStack {
                Text("Your Team: ")
                    .font(Font.custom("American Typewriter", size: 24))
                Picker("Team", selection: $data.currentTeamId) {
                    ForEach(data.allTeams ?? [], id: \.self.id) { team in
                        Text(team.name)
                            .font(Font.custom("American Typewriter", size: 16))
                    }
                }
                .pickerStyle(.wheel)
                .tint(.black)
            }
            .padding(.bottom)
            Button("Done") {
                config.isPresented = false
            }
            .padding(6)
            .background()
            .cornerRadius(8)
        }
        .padding([.top, .leading, .bottom])
        .foregroundStyle(.primary)
        //.background(.ultraThinMaterial)
    }
}

#Preview {
    @Previewable @State var config = ConfigViewState()
    @Previewable @State var data = DataStore.mockStore
    ConfigView(data: $data, config: $config)
}
