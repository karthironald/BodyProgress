//
//  ExerciseRow.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

struct ExerciseRow: View {
    
    @ObservedObject var exercise: Exercise
    
    var body: some View {
        ZStack {
            exercise.wBodyPart.color()
            VStack {
                HStack(alignment: .center) {
                    Image(systemName: "bolt.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .font(kPrimaryTitleFont)
                        .padding([.leading], 25)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(exercise.wName)
                                .font(kPrimaryHeadlineFont)
                                .fontWeight(.bold)
                            if exercise.wIsFavourite {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(Color.white)
                            }
                        }
                        
                        if (!exercise.wNotes.isEmpty) && (exercise.wNotes != kDefaultValue) {
                            Text(exercise.wNotes)
                                .font(kPrimarySubheadlineFont)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding([.leading, .top, .bottom])
                    Spacer()
                    if exercise.wExerciseSets.count > 0 {
                        Text("\(exercise.wExerciseSets.count)")
                            .font(kPrimaryBodyFont)
                            .bold()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding([.top, .bottom], 5)
                            .clipShape(Circle())
                    }
                    Image(systemName: "arrowtriangle.right.fill")
                        .foregroundColor(.black)
                        .opacity(0.1)
                        .padding([.top, .bottom, .trailing])
                }
            }
        }
        .foregroundColor(.white)
        .frame(height: 80)
        .cornerRadius(kCornerRadius)
        .shadow(radius: kShadowRadius)
    }
}

struct ExerciseRow_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let pExercise = Exercise(context: moc)
        pExercise.name = "Dummbells curl"
        pExercise.notes = "Do it slowly"
        return ExerciseRow(exercise: pExercise)
    }
}
