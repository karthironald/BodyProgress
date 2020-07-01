//
//  WorkoutsList.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 17/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import Combine

struct WorkoutsList: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Workout.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Workout.createdAt, ascending: true)]) var workouts: FetchedResults<Workout>
    @State var shouldPresentAddNewWorkout: Bool = false
    @State var shouldPresentEditWorkout: Bool = false
    @State var editWorkoutIndex: Int = kCommonListIndex
    
    @State var shouldShowDeleteConfirmation = false
    @State var deleteIndex = kCommonListIndex
    
    var body: some View {
        NavigationView {
            ZStack {
                if workouts.count == 0 {
                    EmptyStateInfoView(message: NSLocalizedString("kInfoMsgNoWorkoutsAdded", comment: "Info message"))
                }
                VStack {
                    List {
                        ForEach(0..<workouts.count, id: \.self) { workoutIndex in
                            ZStack {
                                WorkoutRow(workout: self.workouts[workoutIndex])
                                    .contextMenu {
                                        Button(action: {
                                            self.editWorkoutIndex = workoutIndex
                                            self.shouldPresentEditWorkout.toggle()
                                        }) {
                                            Image(systemName: "square.and.pencil")
                                            Text("kButtonTitleEdit")
                                        }
                                        Button(action: {
                                            withAnimation {
                                                self.toggleFav(workout: self.workouts[workoutIndex])
                                            }
                                        }) {
                                            Image(systemName: self.workouts[workoutIndex].wIsFavourite  ? "star.fill" : "star")
                                            Text(self.workouts[workoutIndex].wIsFavourite  ? "kButtonTitleUnfavourite" : "kButtonTitleFavourite")
                                        }
                                        Button(action: {
                                            self.deleteIndex = workoutIndex
                                            self.shouldShowDeleteConfirmation.toggle()
                                        }) {
                                            Image(systemName: "trash")
                                            Text("kButtonTitleDelete")
                                        }
                                }
                                NavigationLink(destination: ExercisesList(selectedWorkout: self.workouts[workoutIndex])) {
                                    EmptyView()
                                }
                            }
                        }
                        .onDelete { (indexSet) in
                            if let index = indexSet.first, index < self.workouts.count {
                                self.deleteIndex = index
                                self.shouldShowDeleteConfirmation.toggle()
                            }
                        }
                    }
                    .sheet(isPresented: $shouldPresentEditWorkout, content: {
                        AddWorkout(shouldPresentAddNewWorkout: self.$shouldPresentEditWorkout, name: self.workouts[self.editWorkoutIndex].wName, notes: self.workouts[self.editWorkoutIndex].wNotes, bodyPartIndex: BodyParts.allCases.firstIndex(of: self.workouts[self.editWorkoutIndex].wBodyPart) ?? 0, workoutToEdit: self.workouts[self.editWorkoutIndex]).environment(\.managedObjectContext, self.managedObjectContext)
                    })
                    .navigationBarTitle(Text("kScreenTitleWorkouts"))
                    .navigationBarItems(trailing:
                        Button(action: {
                            self.shouldPresentAddNewWorkout.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(kPrimaryTitleFont)
                                .foregroundColor(kPrimaryColour)
                        }.sheet(isPresented: $shouldPresentAddNewWorkout) {
                            AddWorkout(shouldPresentAddNewWorkout: self.$shouldPresentAddNewWorkout).environment(\.managedObjectContext, self.managedObjectContext)
                        }
                    )
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
        WorkoutsList()
    }
}
