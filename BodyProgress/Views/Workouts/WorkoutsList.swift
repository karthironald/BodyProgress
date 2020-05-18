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
    
    var body: some View {
        NavigationView {
            ZStack {
                if workouts.count == 0 {
                    EmptyStateInfoView(message: "No workouts added")
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
                                            Text("Edit")
                                        }
                                        Button(action: {
                                            withAnimation {
                                                self.toggleFav(workout: self.workouts[workoutIndex])
                                            }
                                        }) {
                                            Image(systemName: self.workouts[workoutIndex].wIsFavourite  ? "star.fill" : "star")
                                            Text(self.workouts[workoutIndex].wIsFavourite  ? "Unfavourite" : "Favourite")
                                        }
                                        Button(action: {
                                            withAnimation {
                                                self.deleteWorkout(workout: self.workouts[workoutIndex])
                                            }
                                        }) {
                                            Image(systemName: "trash")
                                            Text("Delete")
                                        }
                                }
                                NavigationLink(destination: ExercisesList(selectedWorkout: self.workouts[workoutIndex])) {
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $shouldPresentEditWorkout, content: {
                        AddWorkout(shouldPresentAddNewWorkout: self.$shouldPresentEditWorkout, name: self.workouts[self.editWorkoutIndex].wName, notes: self.workouts[self.editWorkoutIndex].wNotes, bodyPartIndex: BodyParts.allCases.firstIndex(of: self.workouts[self.editWorkoutIndex].wBodyPart) ?? 0, workoutToEdit: self.workouts[self.editWorkoutIndex]).environment(\.managedObjectContext, self.managedObjectContext)
                    })
                    .navigationBarTitle(Text("Workouts"))
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
