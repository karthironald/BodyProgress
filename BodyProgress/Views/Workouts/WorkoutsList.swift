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
    @State private var shouldPresentEditWorkout: Bool = false
    
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
            VStack {
                List {
                    ForEach(workouts) { workout in
                        ZStack {
                            WorkoutRow(workout: workout).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
                                .contextMenu {
                                    Button(action: {
                                        self.shouldPresentEditWorkout.toggle()
                                    }) {
                                        Image(systemName: "square.and.pencil")
                                        Text("kButtonTitleEdit")
                                    }
                                    Button(action: {
                                        withAnimation {
                                            self.toggleFav(workout: workout)
                                        }
                                    }) {
                                        Image(systemName: workout.wIsFavourite  ? "star.fill" : "star")
                                        Text(workout.wIsFavourite  ? "kButtonTitleUnfavourite" : "kButtonTitleFavourite")
                                    }
                                    Button(action: {
                                        if let index = self.workouts.firstIndex(where: { $0.id == workout.id }) {
                                            self.deleteIndex = index
                                        }
                                        self.shouldShowDeleteConfirmation.toggle()
                                    }) {
                                        Image(systemName: "trash")
                                        Text("kButtonTitleDelete")
                                    }
                            }
                            NavigationLink(destination: ExercisesList(selectedWorkout: workout)) {
                                EmptyView()
                            }
                        }
                        .sheet(isPresented: $shouldPresentEditWorkout, content: {
                            AddWorkout(shouldPresentAddNewWorkout: self.$shouldPresentEditWorkout, name: workout.wName, notes: workout.wNotes, bodyPartIndex: BodyParts.allCases.firstIndex(of: workout.wBodyPart) ?? 0, workoutToEdit: workout).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
                        })
                    }
                    .onDelete { (indexSet) in
                        if let index = indexSet.first, index < self.workouts.count {
                            self.deleteIndex = index
                            self.shouldShowDeleteConfirmation.toggle()
                        }
                    }
                }
                .listStyle(InsetListStyle())
            }
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
    
    /**Toggles favourite status of the workout*/
    func toggleFav(workout: Workout) {
        workout.isFavourite.toggle()
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
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
