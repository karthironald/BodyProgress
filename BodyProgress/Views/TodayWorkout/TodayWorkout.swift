//
//  TodayWorkout.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 07/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

let kOneHour: Int16 = 3600
let kOneMinute: Int16 = 60

struct TodayWorkout: View {
    
    var startDate = Date()
    @State var displayDuration = ""
    @State var duration: Int16 = 0
    @State var showIncompleteAlert = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentation
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var selectedWorkout: WorkoutHistory
    
    var body: some View {
        NavigationView {
            List(selectedWorkout.wExercises, id: \.self) { exercise in
                TodayExcerciseRow(exercise: exercise).environment(\.managedObjectContext, self.managedObjectContext)
            }
            .padding([.top, .bottom], 10)
            .navigationBarTitle(Text("\(selectedWorkout.wName)").font(kPrimaryBodyFont), displayMode: .inline)
            .navigationBarItems(
                leading:Text("\(displayDuration)").font(kPrimaryBodyFont).foregroundColor(.orange),
                trailing: Button(action: {
                    if !self.isAllSetCompleted() {
                        self.showIncompleteAlert.toggle()
                    } else {
                        self.updateWorkout()
                        self.presentation.wrappedValue.dismiss()
                    }
                }, label: {
                    CustomBarButton(title: "Finish")
                })
            )
                .alert(isPresented: $showIncompleteAlert) { () -> Alert in
                    Alert(title: Text("Few exercise sets are pending. Are you sure to finish?"), primaryButton: Alert.Button.cancel(), secondaryButton: Alert.Button.default(Text("Finish"), action: {
                        self.updateWorkout()
                        self.presentation.wrappedValue.dismiss()
                    }))
            }
        }
        .onReceive(timer) { date in
            self.duration = Int16(date.timeIntervalSince(self.startDate))
            self.displayDuration = self.duration.displayDuration()
        }
    }
    
    func updateWorkout() {
        selectedWorkout.duration = self.duration
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    func isAllSetCompleted() -> Bool {
        for exercise in selectedWorkout.wExercises {
            for sets in exercise.wExerciseSets {
                if sets.wStatus == false {
                    return false
                }
            }
        }
        return true
    }
    
}

struct TodayWorkout_Previews: PreviewProvider {
    static var previews: some View {
        TodayWorkout(selectedWorkout: WorkoutHistory())
    }
}
