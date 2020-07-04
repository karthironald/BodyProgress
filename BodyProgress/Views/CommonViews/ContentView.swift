//
//  ContentView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 17/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @State private var selectedTab = 0 // Sets workout tab as selected tab
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: WorkoutHistory.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutHistory.createdAt, ascending: true)]) var todayWorkout: FetchedResults<WorkoutHistory>
    
    init() {
        let fetchRequest = NSFetchRequest<WorkoutHistory>(entityName: WorkoutHistory.entity().name ?? "WorkoutHistory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutHistory.createdAt, ascending: true)]
        
        //Get today's beginning & end
        let dateFrom = Calendar.current.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        let dateTo = Calendar.current.date(byAdding: .day, value: 1, to: dateFrom)!

        print(dateFrom)
        print(dateTo)
        
        let fromPredicate = NSPredicate(format: "createdAt >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "createdAt < %@", dateTo as NSDate)
        let p = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate])

        fetchRequest.predicate = p
        _todayWorkout = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                TabView(selection: self.$selectedTab) {
                    WorkoutFilterView().environmentObject(self.appSettings).tabItem {
                        Image(systemName: "w.circle.fill")
                            .imageScale(.large)
                        Text("Workout")
                    }.tag(0)
                    WokroutHistoryTabView().environmentObject(self.appSettings).tabItem {
                        Image(systemName: "h.circle.fill")
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
                    kAppDelegate.configureAppearances(color: AppSettings.colors[self.appSettings.themeColorIndex])
                })
                .accentColor(self.appSettings.themeColorView())
                Text("\(self.todayWorkout.first?.wName ?? "--")")
                    .frame(width: geo.size.width - 100)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(15)
                    .zIndex(2)
                    .offset(x: 0, y: (geo.size.height / 2) - 100)
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
