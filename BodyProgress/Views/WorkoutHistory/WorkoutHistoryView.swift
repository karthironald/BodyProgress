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
    
    @State var shouldShowDeleteConfirmation = false
    @State var deleteIndex = kCommonListIndex
    
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
                            NavigationLink(destination: WorkoutHistroyDetails(selectedWorkout: self.workoutHistory[workoutIndex])) {
                                EmptyView()
                                    .zIndex(1)
                            }
                        }
                    }
                    .onDelete { (indexSet) in
                        if let index = indexSet.first, index < self.workoutHistory.count {
                            self.deleteIndex = index
                            self.shouldShowDeleteConfirmation.toggle()
                        }
                    }
                }
            }
            .navigationBarTitle(Text("History"))
        }
        .alert(isPresented: $shouldShowDeleteConfirmation, content: { () -> Alert in
            Alert(title: Text("kAlertTitleConfirm"), message: Text("kAlertMsgDeleteWorkoutHistory"), primaryButton: .cancel(), secondaryButton: .destructive(Text("kButtonTitleDelete"), action: {
                withAnimation {
                    if self.deleteIndex != kCommonListIndex {
                        self.delete(workoutHistory: self.workoutHistory[self.deleteIndex])
                    }
                }
            }))
        })
        .onAppear {
            kAppDelegate.removeSeparatorLineAppearance()
        }
    }
    
    /**Deletes given workout history*/
    func delete(workoutHistory: WorkoutHistory) {
        managedObjectContext.delete(workoutHistory)
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
}

struct WorkoutHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutHistoryView(predicate: NSPredicate(format: "status == %@", WorkoutHistoryStatusSort.Both.rawValue), sortDescriptor: NSSortDescriptor(keyPath: \WorkoutHistory.createdAt, ascending: false))
    }
}
