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
                Image(systemName: "bolt.circle.fill")
                    .imageScale(.large)
                    .font(kPrimaryTitleFont)
                    .padding([.leading], 15)
                    .foregroundColor(Color.gray)
                    .opacity(0.5)
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
                    if (!workout.wNotes.isEmpty) && (workout.wNotes != kDefaultValue) {
                        Text(workout.wNotes)
                            .font(kPrimarySubheadlineFont)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(5)
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
        .frame(height: 80)
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
        return WorkoutRow(workout: pWorkout)
            .previewLayout(.fixed(width: 400, height: 80))
    }
}
