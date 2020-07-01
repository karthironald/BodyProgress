//
//  WorkoutRow.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 17/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

struct WorkoutRow: View {
    
    @ObservedObject var workout: Workout
    
    var body: some View {
        ZStack {
            workout.wBodyPart.color()
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(workout.wName)
                            .font(kPrimaryHeadlineFont)
                            .fontWeight(.bold)
                        if workout.wIsFavourite {
                            Image(systemName: "star.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                                .foregroundColor(kFavStarColour)
                        }
                    }
                    if workout.lastTrainedAt != nil {
                        Text("Last trained: \(workout.wLastTrainedAt, formatter: DateFormatter().appDormatter)")
                            .font(kPrimarySubheadlineFont)
                        .opacity(0.5)
                    }
                    if (!workout.wNotes.isEmpty) && (workout.wNotes != kDefaultValue) {
                        Text(workout.wNotes)
                            .font(kPrimarySubheadlineFont)
                            .multilineTextAlignment(.leading)
                    }
                    }
                .padding()
                Spacer()
                if workout.wExercises.count > 0 {
                    Text("\(workout.wExercises.count)")
                        .font(kPrimaryBodyFont)
                        .bold()
                        .frame(width: 30, height: 30)
                        .padding([.top, .bottom], 5)
                        .clipShape(Circle())
                }
                Image(systemName: "arrowtriangle.right.fill")
                    .foregroundColor(.secondary)
                    .opacity(0.2)
                    .padding([.top, .bottom, .trailing])
            }
        }
        .frame(height: 100)
        .cornerRadius(kCornerRadius)
    }
    
}

struct WorkoutRow_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let pWorkout = Workout(context: moc)
        pWorkout.name = "Arms"
        pWorkout.notes = "Sample notes"
        pWorkout.isFavourite = true
        
        let exer1 = Exercise(context: moc)
        let exer2 = Exercise(context: moc)
        
        pWorkout.exercises = [exer1, exer2]
        
        return WorkoutRow(workout: pWorkout)
            .previewLayout(.fixed(width: 400, height: 100))
    }
}
