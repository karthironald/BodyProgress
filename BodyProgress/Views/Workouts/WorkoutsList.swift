//
//  WorkoutsList.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 17/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

struct WorkoutsList: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Workout.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Workout.createdAt, ascending: true)]) var workouts: FetchedResults<Workout>
    
    @State private var shouldShowDeleteConfirmation = false
    @State private var deleteIndex = kCommonListIndex
    
    init(predicate: NSPredicate?, sortDescriptor: NSSortDescriptor) {
        let fetchRequest = NSFetchRequest<Workout>(entityName: Workout.entity().name ?? "Workout")
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        _workouts = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        ZStack {
            if workouts.count == 0 {
                EmptyStateInfoView(title: NSLocalizedString("kInfoMsgNoWorkoutsAddedTitle", comment: "Info message"), message: NSLocalizedString("kInfoMsgNoWorkoutsAddedMessage", comment: "Info message"))
            }
            List {
                ForEach(BodyParts.allCases, id: \.self) { part in
                    let filteredWorkouts = workouts.filter { $0.wBodyPart == part }
                    if filteredWorkouts.count > 0 {
                        Section(header: Text(part.rawValue)) {
                            ForEach(filteredWorkouts) { workout in
                                WorkoutRow(workout: workout).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
                            }
                            .onDelete { (indexSet) in
                                if let index = indexSet.first, index < filteredWorkouts.count {
                                    let filteredWorkout = filteredWorkouts[index]
                                    if let i = workouts.firstIndex(where: { $0.wId == filteredWorkout.wId }) {
                                        self.deleteIndex = i
                                        self.shouldShowDeleteConfirmation.toggle()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .onAppear {
            kAppDelegate.removeSeparatorLineAppearance()
        }
        .alert(isPresented: $shouldShowDeleteConfirmation) { () -> Alert in
            Alert(title: Text("kAlertTitleConfirm"), message: Text("kAlertMsgDeleteWorkout"), primaryButton: .cancel(), secondaryButton: .destructive(Text("kButtonTitleDelete"), action: {
                withAnimation {
                    if self.deleteIndex != kCommonListIndex {
                        self.deleteWorkout(workout: self.workouts[self.deleteIndex])
                    }
                }
            }))
        }
    }

    /**Deletes the workout*/
    func deleteWorkout(workout: Workout) {
        managedObjectContext.delete(workout)
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
}

struct WorkoutsList_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsList(predicate: nil, sortDescriptor: NSSortDescriptor(keyPath: \Workout.createdAt, ascending: true))
    }
}
