//
//  MainView.swift
//  Freeagle
//
//  Created by Gabriele Zito on 21/07/25.
//

import SwiftUI

struct MainView: View {
    @State private var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection){
            EventListView().tabItem{
                Label("Events", systemImage: "house.fill").accentColor(.primary)
            }.tag(0)
            JoinedEventsListView().tabItem{
                Label("Your Events", systemImage: "person.3.fill").accentColor(.primary)
            }.tag(1)
        }.onAppear{}
    }
}

#Preview {
    MainView()
}
