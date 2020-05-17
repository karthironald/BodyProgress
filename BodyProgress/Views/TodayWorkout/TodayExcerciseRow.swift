//
//  TodayExcerciseRow.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 07/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct TodayExcerciseRow: View {
    
    @ObservedObject var exercise: ExerciseHistory
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
            VStack {
                HStack() {
                    Text(exercise.wName)
                        .font(kPrimaryHeadlineFont)
                        .bold()
                    Spacer()
                }
                Divider()
                VStack(alignment: .leading) {
                    ForEach(exercise.wExerciseSets, id: \.self) { exSet in
                        TodayExerciseSet(exerciseSet: exSet).environment(\.managedObjectContext, self.managedObjectContext)
                    }
                }
            }
            .padding()
            Spacer()
        }
        .frame(height: 50.0 + CGFloat(exercise.wExerciseSets.count * 50))
        .cornerRadius(kCornerRadius)
    }
}

struct TodayExcerciseRow_Previews: PreviewProvider {
    static var previews: some View {
        Text("Yet to be configured")
    }
}
