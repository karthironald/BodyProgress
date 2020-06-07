//
//  ExercisesList.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 23/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct ExercisesList: View {
    
    @ObservedObject var selectedWorkout: Workout
    @State var shouldPresentAddNewExercise = false
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var shouldPresentEditExercise: Bool = false
    @State var editExerciseIndex: Int = kCommonListIndex
    @State var startButtonSelected: Bool = false
    
    var body: some View {
        ZStack {
            if selectedWorkout.wExercises.count == 0 {
                EmptyStateInfoView(message: "No exercises added")
            }
            VStack {
                List {
                    ForEach(0..<selectedWorkout.wExercises.count, id: \.self) { exerciseIndex in
                        ZStack {
                            ExerciseRow(exercise: self.selectedWorkout.wExercises[exerciseIndex])
                                .contextMenu {
                                    Button(action: {
                                        self.editExerciseIndex = exerciseIndex
                                        self.shouldPresentEditExercise = true
                                    }) {
                                        Image(systemName: "square.and.pencil")
                                        Text("Edit")
                                    }
                                    Button(action: {
                                        withAnimation {
                                            self.toggleFav(exercise: self.selectedWorkout.wExercises[exerciseIndex])
                                        }
                                    }) {
                                        Image(systemName: self.selectedWorkout.wExercises[exerciseIndex].wIsFavourite  ? "star.fill" : "star")
                                        Text(self.selectedWorkout.wExercises[exerciseIndex].wIsFavourite  ? "Unfavourite" : "Favourite")
                                    }
                                    Button(action: {
                                        withAnimation {
                                            self.deleteExercise(exercise: self.selectedWorkout.wExercises[exerciseIndex])
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                        Text("Delete")
                                    }
                            }
                            NavigationLink(destination: ExerciseSetsList(selectedExercise: self.selectedWorkout.wExercises[exerciseIndex])) {
                                EmptyView()
                            }
                        }
                    }
                    .onDelete { (indexSet) in
                        if let index = indexSet.first, index < self.selectedWorkout.wExercises.count {
                            withAnimation {
                                self.deleteExercise(exercise: self.selectedWorkout.wExercises[index])
                            }
                        }
                    }
                }
                .padding([.top, .bottom], 10)
                .sheet(isPresented: $shouldPresentEditExercise, content: {
                    AddExercise(shouldPresentAddNewExercise: self.$shouldPresentEditExercise, selectedWorkout: self.selectedWorkout, name: self.selectedWorkout.wExercises[self.editExerciseIndex].wName, notes: self.selectedWorkout.wExercises[self.editExerciseIndex].wNotes, selectedExercise: self.selectedWorkout.wExercises[self.editExerciseIndex]).environment(\.managedObjectContext, self.managedObjectContext)
                })
                    .navigationBarTitle(Text("Exercise"))
                    .navigationBarItems(trailing:
                        HStack {
                            Button(action: {
                                self.startButtonSelected.toggle()
                            }) {
                                Image(systemName: "play.circle.fill")
                                    .font(kPrimaryTitleFont)
                            }
                            .padding()
                            
                            Button(action: {
                                self.shouldPresentAddNewExercise.toggle()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(kPrimaryTitleFont)
                                    .foregroundColor(kPrimaryColour)
                            }.sheet(isPresented: $shouldPresentAddNewExercise) {
                                AddExercise(shouldPresentAddNewExercise: self.$shouldPresentAddNewExercise, selectedWorkout: self.selectedWorkout).environment(\.managedObjectContext, self.managedObjectContext)
                            }
                        }
                )
            }
        }
        .onAppear {
            kAppDelegate.removeSeparatorLineAppearance()
        }
        .sheet(isPresented: $startButtonSelected, content: {
            TodayWorkout(selectedWorkout: self.createWorkoutHistory(), workout: self.selectedWorkout).environment(\.managedObjectContext, self.managedObjectContext)
        })
            .navigationBarTitle(Text(selectedWorkout.wName))
    }
    
    /**Toggles the favourite status of the exercise*/
    func toggleFav(exercise: Exercise) {
        exercise.isFavourite.toggle()
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    /**Deletes the given exercise*/
    func deleteExercise(exercise: Exercise) {
        managedObjectContext.delete(exercise)
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    /**Creates workout history entry for start today workout*/
    func createWorkoutHistory() -> WorkoutHistory {
        let workoutHistory = WorkoutHistory(context: managedObjectContext)
        workoutHistory.name = selectedWorkout.name
        workoutHistory.notes = selectedWorkout.notes
        workoutHistory.bodyPart = selectedWorkout.bodyPart
        workoutHistory.id = UUID()
        workoutHistory.createdAt = Date()
        workoutHistory.updatedAt = Date()
        
        for exercise in selectedWorkout.wExercises {
            let exerciseHistory = ExerciseHistory(context: managedObjectContext)
            exerciseHistory.name = exercise.name
            exerciseHistory.notes = exercise.notes
            exerciseHistory.bodyPart = selectedWorkout.bodyPart
            exerciseHistory.id = UUID()
            exerciseHistory.createdAt = Date()
            exerciseHistory.updatedAt = Date()
            
            for exerciseSet in exercise.wExerciseSets {
                let newExerciseSetHistory = ExerciseSetHistory(context: managedObjectContext)
                newExerciseSetHistory.name = exerciseSet.name
                newExerciseSetHistory.notes = exerciseSet.notes
                newExerciseSetHistory.id = UUID()
                newExerciseSetHistory.createdAt = Date()
                newExerciseSetHistory.updatedAt = Date()
                newExerciseSetHistory.weight = exerciseSet.wWeight
                newExerciseSetHistory.reputation = exerciseSet.wReputation
                
                exerciseHistory.addToExerciseSets(newExerciseSetHistory)
            }
            
            workoutHistory.addToExercises(exerciseHistory)
        }
        
        return workoutHistory
    }
    
}

struct WorkoutDetail_Previews: PreviewProvider {
    static var previews: some View {
        Text("Yet to configure the preview")
    }
}
