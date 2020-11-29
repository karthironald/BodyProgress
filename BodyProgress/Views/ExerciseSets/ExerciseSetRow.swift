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
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var appSettings: AppSettings
    
    @ObservedObject var selectedExercise: Exercise
    @ObservedObject var exerciseSet: ExerciseSet
    
    @State private var shouldPresentEditExerciseSet: Bool = false
    
    var body: some View {
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
            .sheet(isPresented: $shouldPresentEditExerciseSet, content: {
                AddExerciseSet(
                    shouldPresentAddNewExerciseSet: self.$shouldPresentEditExerciseSet,
                    selectedExercise: self.selectedExercise,
                    name: exerciseSet.wName,
                    notes: exerciseSet.wNotes,
                    weight: exerciseSet.wWeight,
                    reputation: Double(exerciseSet.wReputation),
                    selectedExerciseSet: exerciseSet
                ).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
            })
            
            Text("\(exerciseSet.wWeight, specifier: "%.2f") kgs X \(exerciseSet.wReputation) rps")
                .font(kPrimarySubheadlineFont)
                .foregroundColor(.secondary)
        }
        .padding([.top, .bottom], 10)
        .contextMenu {
            Button(action: {
                self.shouldPresentEditExerciseSet.toggle()
            }) {
                Image(systemName: "square.and.pencil")
                Text("kButtonTitleEdit")
            }
        }
    }
}

struct ExerciseSetRow_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let pExercise = Exercise(context: moc)
        pExercise.id = UUID()
        pExercise.name = "Preview"
        
        let pExerciseSet = ExerciseSet(context: moc)
        pExerciseSet.name = "Sample"
        pExerciseSet.notes = "Sample"
        
        pExercise.exerciseSets = [pExerciseSet]
        
        return ExerciseSetRow(selectedExercise: pExercise, exerciseSet: pExerciseSet)
    }
}
