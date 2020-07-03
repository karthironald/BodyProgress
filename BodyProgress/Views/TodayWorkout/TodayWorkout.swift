//
//  TodayWorkout.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 07/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

struct TodayWorkout: View {
    
    @State var startDate = Date()
    @State var displayDuration = ""
    @State var duration: Int16 = 0
    @State var showIncompleteAlert = false
    @State var showCompleteInfoAlert = false
    @State var shouldPauseTimer = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentation
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var selectedWorkout: WorkoutHistory
    var workout: Workout
    
    var body: some View {
        NavigationView {
            List(selectedWorkout.wExercises, id: \.self) { exercise in
                TodayExcerciseRow(exercise: exercise).environment(\.managedObjectContext, self.managedObjectContext)
            }
            .padding([.top, .bottom], 10)
            .navigationBarTitle(Text("\(selectedWorkout.wName)").font(kPrimaryBodyFont), displayMode: .inline)
            .navigationBarItems(
                leading: Text("\(displayDuration)")
                    .font(kPrimaryBodyFont)
                    .foregroundColor(.orange)
                    .opacity(shouldPauseTimer ? 0.5 : 1)
                    .padding([.trailing, .top, .bottom])
                    .onTapGesture {
                        self.shouldPauseTimer ? self.resumeTimer() : self.pauseTimer()
                    },
                trailing: Button(action: {
                    self.pauseTimer()
                    if !self.selectedWorkout.isAllSetCompleted() {
                        self.showIncompleteAlert.toggle()
                    } else {
                        self.showCompleteInfoAlert.toggle()
                    }
                }, label: {
                    CustomBarButton(title: "Finish")
                })
            )
                .alert(isPresented: $showIncompleteAlert) { () -> Alert in
                    Helper.hapticFeedback()
                    return Alert(title: Text("Few exercise sets are pending. Are you sure to finish?"), primaryButton: Alert.Button.cancel({
                        self.resumeTimer()
                    }), secondaryButton: Alert.Button.default(Text("Finish"), action: {
                        self.showCompleteInfoAlert.toggle()
                    }))
            }
        }
        .alert(isPresented: $showCompleteInfoAlert, content: { () -> Alert in
            Helper.hapticFeedback()
            return Alert(title:
                Text("🎉"), message: Text("Today workout has been saved successfully"), dismissButton: Alert.Button.cancel(Text("Okay"), action: {
                    self.presentation.wrappedValue.dismiss()
                    self.updateWorkout()
            }))
        })
            .onReceive(timer) { date in
                self.duration = Int16(date.timeIntervalSince(self.startDate))
                self.displayDuration = self.duration.displayDuration()
        }
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
    
    /**Pauses the timer*/
    func pauseTimer() {
        self.timer.upstream.connect().cancel()
        shouldPauseTimer = true
        Helper.hapticFeedback()
    }
    
    /**Resumes the timer from previously stopped time*/
    func resumeTimer() {
        self.startDate = Date().advanced(by: TimeInterval(-self.duration)) // Consider already ran duration when resuming the timer.
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        shouldPauseTimer = false
        Helper.hapticFeedback()
    }
    
}

struct TodayWorkout_Previews: PreviewProvider {
    static var previews: some View {
        Text("Yet to configure preview")
    }
}
