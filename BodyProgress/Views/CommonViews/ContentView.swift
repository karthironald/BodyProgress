//
//  ContentView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 17/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab = 0 // Sets workout tab as selected tab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WorkoutFilterView().tabItem {
                Image(systemName: "w.circle.fill")
                    .imageScale(.large)
                Text("Workout")
            }.tag(0)
            WokroutHistoryTabView().tabItem {
                Image(systemName: "h.circle.fill")
                    .imageScale(.large)
                Text("History")
            }.tag(1)
            SettingsView().tabItem {
                Image(systemName: "gear")
                    .imageScale(.large)
                Text("Settings")
            }.tag(2)
        }
        .accentColor(kPrimaryColour)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
