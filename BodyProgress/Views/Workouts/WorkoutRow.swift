//
//  WorkoutRow.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 17/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

struct WorkoutRow: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var workout: Workout
    @State private var shouldShowStartWorkoutAlert = false
    @State private var startButtonSelected: Bool = false
    var moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType) // Sheet block calling multiple time and duplicates records are being created in todayworkout. So we are using separate managed object context to fetch and handle today wrokout separately.
    
    var body: some View {
        ZStack {
            workout.wBodyPart.color()
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(workout.wName)
                            .font(kPrimaryBodyFont)
                            .fontWeight(.bold)
                            .lineLimit(2)
                        if workout.wIsFavourite {
                            Image(systemName: "star.fill")
                                .font(kPrimarySubheadlineFont)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    HStack {
                        Text(workout.wBodyPart.rawValue)
                            .font(kPrimarySubheadlineFont)
                            .foregroundColor(.secondary)
                        if workout.wExercises.count > 0 {
                            Circle()
                                .fill(Color.secondary)
                                .frame(width: 5, height: 5)
                            Text("\(workout.wExercises.count)")
                                .font(kPrimarySubheadlineFont)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Spacer()
                VStack(spacing: 5) {
                    Button(action: {
                        Helper.hapticFeedback()
                        self.shouldShowStartWorkoutAlert.toggle()
                    }) {
                        Text("Start workout")
                            .font(kPrimarySubheadlineFont)
                            .foregroundColor(.white)
                            .bold()
                            .padding(10)
                            .frame(height: 30)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    if workout.lastTrainedAt != nil {
                        Text("\(workout.lastTrainedAtString())")
                            .font(kPrimaryFootnoteFont)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Not trained yet")
                            .font(kPrimaryFootnoteFont)
                            .foregroundColor(.secondary)
                    }
                }
                Image(systemName: "arrowtriangle.right.fill")
                    .foregroundColor(.secondary)
                    .opacity(0.2)
                    .padding(.leading)
                .frame(width: 20)
            }
            .padding()
        }
        .alert(isPresented: $shouldShowStartWorkoutAlert, content: { () -> Alert in
            Alert(title: Text("Ready to start \(workout.wName)?"), message: (!workout.wNotes.isEmpty && workout.wNotes != kDefaultValue) ? Text("Notes: \(workout.wNotes)") : nil, primaryButton: .cancel(Text("kButtonTitleCancel")), secondaryButton: .default(Text("kButtonTitleStart"), action: {
                self.startButtonSelected.toggle()
            }))
        })
        .sheet(isPresented: $startButtonSelected, content: {
            TodayWorkout(selectedWorkout: self.createWorkoutHistory()).environment(\.managedObjectContext, self.moc).environmentObject(self.appSettings)
        })
        .frame(height: 80)
        .cornerRadius(kCornerRadius)
    }
    
    /**Creates workout history entry for start today workout*/
    func createWorkoutHistory() -> WorkoutHistory {
        let workoutHistory = WorkoutHistory(context: moc)
        workoutHistory.name = workout.name
        workoutHistory.notes = workout.notes
        workoutHistory.bodyPart = workout.bodyPart
        workoutHistory.id = UUID()
        workoutHistory.createdAt = Date()
        workoutHistory.updatedAt = Date()
        
        let req: NSFetchRequest<Workout> = Workout.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", workout.wId as CVarArg)
        req.predicate = predicate
        moc.persistentStoreCoordinator = kAppDelegate.persistentContainer.persistentStoreCoordinator
        do {
            let w = try moc.fetch(req) as [Workout]
            let fetchedWorkout = w.first
               workoutHistory.workout = fetchedWorkout
               
               for exercise in fetchedWorkout?.wExercises ?? [] {
                   let exerciseHistory = ExerciseHistory(context: self.moc)
                   exerciseHistory.name = exercise.name
                   exerciseHistory.notes = exercise.notes
                   exerciseHistory.bodyPart = fetchedWorkout?.bodyPart
                   exerciseHistory.id = UUID()
                   exerciseHistory.createdAt = Date()
                   exerciseHistory.updatedAt = Date()
                   exerciseHistory.references = exercise.references
                   
                   for exerciseSet in exercise.wExerciseSets {
                       let newExerciseSetHistory = ExerciseSetHistory(context: self.moc)
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
            
               if self.moc.hasChanges {
                   do {
                       try self.moc.save()
                   } catch {
                       print(error.localizedDescription)
                   }
               }
               return workoutHistory
        } catch {
            print(error.localizedDescription)
        }
        
        return workoutHistory
    }
    
}

struct WorkoutRow_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let pWorkout = Workout(context: moc)
        pWorkout.name = "My big biceps"
        pWorkout.notes = "Sample"
        pWorkout.isFavourite = true
//        pWorkout.lastTrainedAt = Date().addingTimeInterval(-1000)
        pWorkout.bodyPart = BodyParts.fullBody.rawValue
        let exer1 = Exercise(context: moc)
        let exer2 = Exercise(context: moc)
        
        pWorkout.exercises = [exer1, exer2]
        
        return WorkoutRow(workout: pWorkout)
            .previewLayout(.fixed(width: 400, height: 80))
    }
}
