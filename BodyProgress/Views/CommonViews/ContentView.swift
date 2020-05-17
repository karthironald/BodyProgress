//
//  ContentView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 17/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WokroutHistoryTabView().tabItem {
                Image(systemName: "h.circle.fill")
                    .imageScale(.large)
                Text("History")
            }.tag(0)
            WorkoutsList().tabItem {
                Image(systemName: "w.circle.fill")
                    .imageScale(.large)
                Text("Workouts")
            }.tag(1)
            Diets().tabItem {
                Image(systemName: "d.circle.fill")
                    .imageScale(.large)
                Text("Diets")
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
