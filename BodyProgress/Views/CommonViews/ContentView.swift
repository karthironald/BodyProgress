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
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WorkoutFilterView().environmentObject(self.appSettings).tabItem {
                Image(systemName: "flame")
                    .imageScale(.large)
                Text("Workout")
            }.tag(0)
            WokroutHistoryTabView().environmentObject(self.appSettings).tabItem {
                Image(systemName: "clock")
                    .imageScale(.large)
                Text("History")
            }.tag(1)
            SettingsView().environmentObject(self.appSettings).tabItem {
                Image(systemName: "gear")
                    .imageScale(.large)
                Text("Settings")
            }.tag(2)
        }
        .onAppear(perform: {
            kAppDelegate.configureAppearances(color: AppThemeColours.allCases[self.appSettings.themeColorIndex].uiColor())
        })
        .accentColor(appSettings.themeColorView())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
