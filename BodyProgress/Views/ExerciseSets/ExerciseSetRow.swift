//
//  ExerciseSetRow.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

struct ExerciseSetRow: View {
    
    @ObservedObject var exerciseSet: ExerciseSet
    
    var body: some View {
        ZStack {
            kPrimaryBackgroundColour
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(exerciseSet.wName)
                            .font(kPrimaryBodyFont)
                            .fontWeight(.bold)
                        if exerciseSet.wIsFavourite {
                            Image(systemName: "star.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                                .foregroundColor(kFavStarColour)
                        }
                    }
//                    if (!exerciseSet.wNotes.isEmpty) && (exerciseSet.wNotes != kDefaultValue) {
//                        Text(exerciseSet.wNotes)
//                            .font(kPrimarySubheadlineFont)
//                            .multilineTextAlignment(.leading)
//                            .opacity(0.75)
//                    }
                    Text("\(exerciseSet.wWeight, specifier: "%.2f") kgs X \(exerciseSet.wReputation) rps")
                        .font(kPrimarySubheadlineFont)
                        .opacity(0.75)
                }
                .padding()
                Spacer()
            }
        }
        .frame(height: 60)
        .cornerRadius(kCornerRadius)
    }
}

struct ExerciseSetRow_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let pExerciseSet = ExerciseSet(context: moc)
        pExerciseSet.name = "Sample"
        pExerciseSet.notes = "Sample"
        return ExerciseSetRow(exerciseSet: pExerciseSet)
    }
}
