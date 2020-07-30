//
//  TodayExcerciseRow.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 07/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct TodayExcerciseRow: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var exercise: ExerciseHistory
    @State private var shouldPresentReferences = false
    
    var isViewOnly = false
    
    var body: some View {
        ZStack {
            kPrimaryBackgroundColour
            VStack {
                HStack() {
                    Text(exercise.wName)
                        .font(kPrimaryHeadlineFont)
                        .bold()
                    Spacer()
                    if exercise.wReferences.count > 0 {
                        Button(action: {
                            self.shouldPresentReferences.toggle()
                        }) {
                            Image(systemName: "info.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                Divider()
                VStack(alignment: .leading) {
                    ForEach(exercise.wExerciseSets, id: \.self) { exSet in
                        TodayExerciseSet(exerciseSet: exSet, isViewOnly: self.isViewOnly).environmentObject(self.appSettings).environment(\.managedObjectContext, self.managedObjectContext)
                    }
                }
            }
            .padding()
            Spacer()
        }
        .sheet(isPresented: $shouldPresentReferences, content: {
            ExerciseReferenceView(shouldPresentReferences: self.$shouldPresentReferences, referencesLinks: self.exercise.wReferences, exerciseName: self.exercise.wName).environmentObject(self.appSettings)
        })
        .frame(height: 50.0 + CGFloat(exercise.wExerciseSets.count * 50))
        .cornerRadius(kCornerRadius)
    }
}

struct TodayExcerciseRow_Previews: PreviewProvider {
    static var previews: some View {
        Text("Yet to be configured")
    }
}
