//
//  WorkoutHistroyDetails.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 18/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct WorkoutHistroyDetails: View {
    
    var selectedWorkout: WorkoutHistory
    
    var body: some View {
        List(selectedWorkout.wExercises, id: \.self) { exercise in
            TodayExcerciseRow(exercise: exercise, isViewOnly: true)
        }
        .padding([.top, .bottom], 10)
        .navigationBarTitle(Text("\(selectedWorkout.wName)").font(kPrimaryBodyFont))
        .navigationBarItems(trailing:
            Group {
                if !selectedWorkout.wDuration.detailedDisplayDuration().isEmpty {
                    Text("\(selectedWorkout.wDuration.detailedDisplayDuration())")
                        .font(kPrimaryBodyFont)
                        .foregroundColor(.orange)
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
