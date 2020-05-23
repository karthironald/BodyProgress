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
    
    var startDate = Date()
    @State var displayDuration = ""
    @State var duration: Int16 = 0
    @State var showIncompleteAlert = false
    @State var showCompleteInfoAlert = false
    
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
                    if !self.selectedWorkout.isAllSetCompleted() {
                        self.showIncompleteAlert.toggle()
                    } else {
                        self.updateWorkout()
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
        .alert(isPresented: $showCompleteInfoAlert, content: { () -> Alert in
            Alert(title:
                Text("🎉"), message: Text("Today workout has been saved successfully"), dismissButton: Alert.Button.cancel(Text("Okay"), action: {
                self.presentation.wrappedValue.dismiss()
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
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                self.showCompleteInfoAlert.toggle()
            } catch {
                print(error)
            }
        }
    }
    
}

struct TodayWorkout_Previews: PreviewProvider {
    static var previews: some View {
        TodayWorkout(selectedWorkout: WorkoutHistory())
    }
}
