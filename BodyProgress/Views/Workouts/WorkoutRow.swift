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
    @State private var shouldPresentEditWorkout: Bool = false
    
    var body: some View {
        NavigationLink(destination: ExercisesList(selectedWorkout: workout)) {
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
                    .sheet(isPresented: $shouldPresentEditWorkout, content: {
                        AddWorkout(shouldPresentAddNewWorkout: self.$shouldPresentEditWorkout, name: workout.wName, notes: workout.wNotes, bodyPartIndex: BodyParts.allCases.firstIndex(of: workout.wBodyPart) ?? 0, workoutToEdit: workout).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
                    })
                    
                    if workout.wExercises.count > 0 {
                        HStack {
                            Text("Exercise:")
                            Text("\(workout.wExercises.count)")
                        }
                        .font(kPrimarySubheadlineFont)
                        .foregroundColor(.secondary)
                    }
                }
                Spacer()
                StartWorkoutView(workout: workout).environment(\.managedObjectContext, managedObjectContext).environmentObject(appSettings)
            }
            .padding([.top, .bottom], 10)
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

struct StartWorkoutView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var workout: Workout
    
    @State private var shouldShowStartWorkoutAlert = false
    @State private var startButtonSelected: Bool = false
    @State private var todayWorkout = WorkoutHistory(context: kAppDelegate.persistentContainer.viewContext)
    
    var body: some View {
        VStack(spacing: 5) {
            Button(action: {
                Helper.hapticFeedback()
                self.shouldShowStartWorkoutAlert.toggle()
            }) {
                Text("Start workout")
                    .font(kPrimarySubheadlineFont)
                    .foregroundColor(Color(AppThemeColours.green.uiColor()))
                    .bold()
                    .padding(10)
                    .frame(height: 30)
                    .background(Color(AppThemeColours.green.uiColor()).opacity(0.1))
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
        .alert(isPresented: $shouldShowStartWorkoutAlert, content: { () -> Alert in
            Alert(title: Text("Ready to start \(workout.wName)?"), message: self.alertMessageView(), primaryButton: .cancel(Text("kButtonTitleCancel")), secondaryButton: .default(Text("kButtonTitleStart"), action: {
                self.todayWorkout = self.createWorkoutHistory()
                self.startButtonSelected.toggle()
            }))
        })
        .sheet(isPresented: $startButtonSelected, content: {
            TodayWorkout(selectedWorkout: self.todayWorkout, workout: self.workout).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
        })
    }
    
    func alertMessageView() -> Text? {
        var message: String = ""
        if !workout.wNotes.isEmpty && workout.wNotes != kDefaultValue {
            message = "\(workout.wNotes)"
        }
        
        let req: NSFetchRequest<WorkoutHistory> = WorkoutHistory.fetchRequest()
        let predicate = NSPredicate(format: "workout.id == %@", workout.wId as CVarArg)
        let sortDescriptor = NSSortDescriptor(keyPath: \WorkoutHistory.createdAt, ascending: false)
        
        req.predicate = predicate
        req.sortDescriptors = [sortDescriptor]
        
        do {
            if let lastWorkoutSession = try managedObjectContext.fetch(req).first, lastWorkoutSession.wDuration > 0 {
                let duration = lastWorkoutSession.wDuration.detailedDisplayDuration()
                if !message.isEmpty { message.append("\n") }
                message.append("\nLast session: \(duration)")
                
                let eta = Date().addingTimeInterval(TimeInterval(lastWorkoutSession.wDuration))
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                
                let timeString = formatter.string(from: eta)
                message.append("\n\nYou might finish the workout at \(timeString)")
            }
        } catch {
            print(error.localizedDescription)
        }
        return !message.isEmpty ? Text(message) : nil
    }
    
    /**Creates workout history entry for start today workout*/
    func createWorkoutHistory() -> WorkoutHistory {
        let workoutHistory = WorkoutHistory(context: managedObjectContext)
        workoutHistory.name = workout.name
        workoutHistory.notes = workout.notes
        workoutHistory.bodyPart = workout.bodyPart
        workoutHistory.id = UUID()
        workoutHistory.createdAt = Date()
        workoutHistory.updatedAt = Date()
        workoutHistory.startedAt = Date()
        
        for exercise in workout.wExercises {
            let exerciseHistory = ExerciseHistory(context: managedObjectContext)
            exerciseHistory.name = exercise.name
            exerciseHistory.notes = exercise.notes
            exerciseHistory.bodyPart = workout.bodyPart
            exerciseHistory.id = UUID()
            exerciseHistory.createdAt = Date()
            exerciseHistory.updatedAt = Date()
            exerciseHistory.references = exercise.references
            
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
        
        workoutHistory.workout = workout
        
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
