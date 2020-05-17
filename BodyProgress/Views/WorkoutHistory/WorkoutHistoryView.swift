//
//  WorkoutHistory.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 12/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData
        
struct WorkoutHistoryView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: WorkoutHistory.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutHistory.createdAt, ascending: false)]) var workoutHistory: FetchedResults<WorkoutHistory>
    
    init(predicate: NSPredicate?, sortDescriptor: NSSortDescriptor) {
        let fetchRequest = NSFetchRequest<WorkoutHistory>(entityName: WorkoutHistory.entity().name ?? "WorkoutHistory")
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        _workoutHistory = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        ZStack {
            if workoutHistory.count == 0 {
                EmptyStateInfoView(message: "No workouts histories")
            }
            VStack {
                List{
                    ForEach(0..<workoutHistory.count, id: \.self) { workoutIndex in
                        ZStack {
                            WokroutHistoryRow(workoutHistory: self.workoutHistory[workoutIndex])
                        }
                    }
                }
            }
            .navigationBarTitle(Text("History"))
        }
        .onAppear {
            kAppDelegate.removeSeparatorLineAppearance()
        }
    }
}

struct WorkoutHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutHistoryView(predicate: NSPredicate(format: "status == %@", WorkoutHistoryStatusSort.Both.rawValue), sortDescriptor: NSSortDescriptor(keyPath: \WorkoutHistory.createdAt, ascending: false))
    }
}
