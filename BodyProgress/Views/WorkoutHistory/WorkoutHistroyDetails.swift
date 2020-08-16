//
//  WorkoutHistroyDetails.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 18/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct WorkoutHistroyDetails: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var appSettings: AppSettings
    var selectedWorkout: WorkoutHistory
    @State private var resumeButtonSelected: Bool = false
    
    var body: some View {
        List(selectedWorkout.wExercises, id: \.self) { exercise in
            TodayExcerciseRow(exercise: exercise, isViewOnly: true)
        }
        .sheet(isPresented: $resumeButtonSelected, content: {
            TodayWorkout(duration: self.selectedWorkout.wDuration, selectedWorkout: self.selectedWorkout, workout: self.selectedWorkout.workout!).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
        })
        .padding([.top, .bottom], 10)
        .navigationBarTitle(Text("\(selectedWorkout.wName)").font(kPrimaryBodyFont))
        .navigationBarItems(trailing:
            HStack {
                Spacer()
                if !selectedWorkout.wDuration.detailedDisplayDuration().isEmpty {
                    Text("\(selectedWorkout.wDuration.detailedDisplayDuration())")
                        .font(kPrimaryBodyFont)
                        .foregroundColor(.orange)
                }
                if (!selectedWorkout.wStatus && selectedWorkout.workout != nil) || (selectedWorkout.startedAt != nil && selectedWorkout.finishedAt == nil) {
                    Button(action: {
                        self.resumeButtonSelected.toggle()
                    }) {
                        Text("Continue")
                            .font(kPrimarySubheadlineFont)
                            .foregroundColor(.white)
                            .bold()
                            .padding(10)
                            .frame(height: 30)
                            .background(self.appSettings.themeColorView())
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
            }
        )
    }
}

struct WorkoutHistroyDetails_Previews: PreviewProvider {
    static var previews: some View {
        Text("Yet to configure")
    }
}
