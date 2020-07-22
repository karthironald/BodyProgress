//
//  TodayWorkout.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 07/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData
import Combine

struct TodayWorkout: View {
    
    @State var startDate = Date()
    @State var duration: Int16 = 0
    @State var showIncompleteAlert = false
    @State var showCompleteInfoAlert = false
    @State var shouldPauseTimer = false {
        didSet {
            shouldPauseTimer ? pauseTimer() : resumeTimer()
        }
    }
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var celebrate = false
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentation
    
    var selectedWorkout: WorkoutHistory
    var workout: Workout
    
    var body: some View {
        NavigationView {
            ZStack {
                List(selectedWorkout.wExercises, id: \.self) { exercise in
                    TodayExcerciseRow(exercise: exercise).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
                }
                .padding([.top, .bottom], 10)
                .navigationBarTitle(Text("\(selectedWorkout.wName)").font(kPrimaryBodyFont), displayMode: .inline)
                .navigationBarItems(
                    leading: TimerView(startDate: $startDate, duration: $duration, shouldPauseTimer: $shouldPauseTimer, timer: $timer, selectedWorkout: selectedWorkout, workout: workout).environment(\.managedObjectContext, managedObjectContext),
                    trailing: Button(action: {
                        self.shouldPauseTimer = true
                        if !self.selectedWorkout.isAllSetCompleted() {
                            self.showIncompleteAlert.toggle()
                        } else {
                            self.showCompleteInfoAlert.toggle()
                            self.celebrate.toggle()
                        }
                    }, label: {
                        CustomBarButton(title: "Finish")
                    })
                )
                    .alert(isPresented: $showIncompleteAlert) { () -> Alert in
                        Helper.hapticFeedback()
                        return Alert(title: Text("Few exercise sets are pending. Are you sure to finish?"), primaryButton: Alert.Button.cancel({
                            self.shouldPauseTimer = false
                        }), secondaryButton: Alert.Button.default(Text("Finish"), action: {
                            self.showCompleteInfoAlert.toggle()
                            self.celebrate.toggle()
                        }))
                }
                .onDisappear {
                    self.updateWorkout()
                }
                if self.celebrate {
                    ConfettiView(confetti: [.text("💪🏻"), .text("🎉")])
                        .transition(.opacity)
                        .animation(.easeOut(duration: 2))
                        .zIndex(2)
                }
            }
        }
        .alert(isPresented: $showCompleteInfoAlert, content: { () -> Alert in
            Helper.hapticFeedback()
            return Alert(title:
                Text("Today workout has been saved successfully"), message: nil, dismissButton: Alert.Button.cancel(Text("Okay"), action: {
                    self.presentation.wrappedValue.dismiss()
                    self.updateWorkout()
                }))
        })
    }
    
    /**Pauses the timer*/
    func pauseTimer() {
        self.timer.upstream.connect().cancel()
        Helper.hapticFeedback()
    }
    
    /**Resumes the timer from previously stopped time*/
    func resumeTimer() {
        self.startDate = Date().advanced(by: TimeInterval(-self.duration)) // Consider already ran duration when resuming the timer.
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        Helper.hapticFeedback()
    }
    
    /**Update and save the work in core data*/
    func updateWorkout() {
        selectedWorkout.duration = self.duration
        selectedWorkout.status = selectedWorkout.isAllSetCompleted()
        workout.lastTrainedAt = Date()
        selectedWorkout.workout = self.workout
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                #warning("We are showing workout saved alert before saving it. There could be posibility to face error when saving the workout. Need to handle it")
                print(error)
            }
        }
    }
    
}

struct TodayWorkout_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let previewData = createWorkoutHistory()
        return TodayWorkout(selectedWorkout: previewData.1, workout: previewData.0).environment(\.managedObjectContext, moc).environmentObject(AppSettings())
    }
    
    
    static func createWorkoutHistory() -> (Workout, WorkoutHistory) {
        let workout = Workout(context: moc)
        
        let workoutHistory = WorkoutHistory(context: moc)
        workoutHistory.name = workout.name
        workoutHistory.notes = workout.notes
        workoutHistory.bodyPart = workout.bodyPart
        workoutHistory.id = UUID()
        workoutHistory.createdAt = Date()
        workoutHistory.updatedAt = Date()
        
        for exercise in workout.wExercises {
            let exerciseHistory = ExerciseHistory(context: moc)
            exerciseHistory.name = exercise.name
            exerciseHistory.notes = exercise.notes
            exerciseHistory.bodyPart = workout.bodyPart
            exerciseHistory.id = UUID()
            exerciseHistory.createdAt = Date()
            exerciseHistory.updatedAt = Date()
            
            for exerciseSet in exercise.wExerciseSets {
                let newExerciseSetHistory = ExerciseSetHistory(context: moc)
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
        
        return (workout, workoutHistory)
    }
    
}

struct TimerView: View {
    
    @Binding var startDate: Date
    @State var displayDuration = ""
    @Binding var duration: Int16
    @Binding var shouldPauseTimer: Bool
    @State var shouldPause = false
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    @Environment(\.managedObjectContext) var managedObjectContext
    var selectedWorkout: WorkoutHistory
    var workout: Workout
    
    var body: some View {
        Text("\(displayDuration)")
            .font(kPrimaryBodyFont)
            .foregroundColor(.orange)
            .opacity((shouldPauseTimer || shouldPause) ? 0.5 : 1)
            .padding([.trailing, .top, .bottom])
            .frame(width: 100)
            .onReceive(timer) { date in
                self.duration = Int16(date.timeIntervalSince(self.startDate))
                self.displayDuration = self.duration.displayDuration()
                self.updateWorkout()
        }
        .onTapGesture {
            self.shouldPause.toggle()
            self.shouldPause ? self.pauseTimer() : self.resumeTimer()
        }
        .onAppear(perform: {
            self.resumeTimer()
        })
            .onDisappear {
                self.pauseTimer()
        }
    }
    
    /**Pauses the timer*/
    func pauseTimer() {
        self.timer.upstream.connect().cancel()
        Helper.hapticFeedback()
    }
    
    /**Resumes the timer from previously stopped time*/
    func resumeTimer() {
        self.startDate = Date().advanced(by: TimeInterval(-self.duration)) // Consider already ran duration when resuming the timer.
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        Helper.hapticFeedback()
    }
    
    /**Update and save the work in core data*/
    func updateWorkout() {
        selectedWorkout.duration = self.duration
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                #warning("We are showing workout saved alert before saving it. There could be posibility to face error when saving the workout. Need to handle it")
                print(error)
            }
        }
    }
    
}
