//
//  WokroutHistoryRow.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 15/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct WokroutHistoryRow: View {
    
    @ObservedObject var workoutHistory: WorkoutHistory
    
    var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
            HStack(alignment: .center) {
                Image(systemName: "clock.fill")
                    .imageScale(.large)
                    .font(kPrimaryTitleFont)
                    .foregroundColor(Color.gray)
                    .padding([.leading], 15)
                    .opacity(0.5)
                VStack(alignment: .leading) {
                    Text(workoutHistory.wName)
                        .font(kPrimaryHeadlineFont)
                        .fontWeight(.bold)
                    Text("Trained at: \(workoutHistory.wCreatedAt, formatter: formatter)")
                        .font(kPrimaryBodyFont)
                        .opacity(0.5)
                    if !workoutHistory.wDuration.detailedDisplayDuration().isEmpty {
                        Text("Duration: \(workoutHistory.wDuration.detailedDisplayDuration())")
                            .font(kPrimaryBodyFont)
                            .opacity(0.5)
                    }
                }
                .padding(5)
                Spacer()
                Image(systemName: isAllSetCompleted() ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .imageScale(.large)
                    .foregroundColor(isAllSetCompleted() ? kPrimaryColour : .red)
                    .font(kPrimaryBodyFont)
                    .padding()
            }
        }
        .frame(height: 90)
        .cornerRadius(kCornerRadius)
    }
    
    func isAllSetCompleted() -> Bool {
        for exercise in workoutHistory.wExercises {
            for sets in exercise.wExerciseSets {
                if sets.wStatus == false {
                    return false
                }
            }
        }
        return true
    }
    
}

struct WokroutHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        Text("Sample")
        //        WokroutHistoryRow()
    }
}
