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
    @State var startButtonSelected: Bool = false
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
        let statusPredicate = NSPredicate(format: "status == %@", NSNumber(booleanLiteral: false))
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate, statusPredicate])
        
        fetchRequest.predicate = predicate
        _todayWorkout = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: self.$selectedTab) {
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
                if self.todayWorkout.count > 0 {
                    TodayWorkoutConfimationView(startButtonSelected: self.$startButtonSelected, todayWorkoutName: self.todayWorkout.first?.wName ?? "--")
                    .frame(width: geo.size.width - 40)
                    .offset(x: -20, y: -70)
                }
            }
            .onAppear(perform: {
                kAppDelegate.configureAppearances(color: AppThemeColours.allCases[self.appSettings.themeColorIndex].uiColor())
            })
            .sheet(isPresented: self.$startButtonSelected, content: {
                TodayWorkout(selectedWorkout: self.todayWorkout.first!, workout: self.todayWorkout.first!.workout!).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
            })
            .accentColor(self.appSettings.themeColorView())
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppSettings())
//        TodayWorkoutConfimationView(startButtonSelected: .constant(false), todayWorkoutName: "Core").environmentObject(AppSettings())
    }
}

struct TodayWorkoutConfimationView: View {
    
    @Binding var startButtonSelected: Bool
    var todayWorkoutName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Do you want to resume your today workout, \(todayWorkoutName)?")
                .font(kPrimaryBodyFont)
                .foregroundColor(.white)
                .padding([.leading, .trailing, .top])
                .multilineTextAlignment(.leading)
            HStack {
                Spacer()
                Button(action: {
                    
                }) {
                    Text("No")
                        .font(kPrimaryBodyFont)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 100, height: 30)
                        .background(Color.black.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: kCornerRadius))
                }
                .padding([.leading, .top, .bottom])
                Button(action: {
                    self.startButtonSelected.toggle()
                }) {
                    Text("Yes")
                        .font(kPrimaryBodyFont)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 100, height: 30)
                        .background(Color.black.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: kCornerRadius))
                }
                .padding()
            }
            
        }
        .background(Color.orange)
        .cornerRadius(kCornerRadius)
    }
}
