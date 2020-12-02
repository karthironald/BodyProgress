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
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var exercise: Exercise
    @ObservedObject var selectedWorkout: Workout
    
    @State private var shouldPresentEditExercise: Bool = false
    
    @State private var shouldPresentReferences = false
    @State private var referenceViewIndex: Int = kCommonListIndex
    
    var body: some View {
        NavigationLink(destination: ExerciseSetsList(selectedExercise: exercise)) {
            VStack(alignment: .leading) {
                HStack {
                    Text(exercise.wName)
                        .font(kPrimaryBodyFont)
                        .fontWeight(.bold)
                        .padding([.top, .bottom], 10)
                    .sheet(isPresented: $shouldPresentEditExercise, content: {
                        AddExercise(shouldPresentAddNewExercise: self.$shouldPresentEditExercise, selectedWorkout: self.selectedWorkout, name: exercise.wName, notes: exercise.wNotes, referenceLinks: exercise.wReferences.map({ ($0.wUrl, true) }), selectedExercise: exercise).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
                    })
                    if (exercise.wExerciseSets.count > 0) {
                        Spacer()
                        Text("\(exercise.wExerciseSets.count)")
                            .modifier(CustomInfoTextStyle(appSettings: appSettings))
                    }
                }
                
                // Adding empty view to show the sheet as sheet is not presenting if we try to show it anywhere else in the view.
                EmptyView()
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(isPresented: self.$shouldPresentReferences, content: {
                        ExerciseReferenceView(shouldPresentReferences: self.$shouldPresentReferences, referencesLinks: exercise.wReferences, exerciseName: exercise.wName).environmentObject(self.appSettings)
                    })
            }
            .padding([.top, .bottom], 5)
            .contextMenu {
                Button(action: {
                    self.shouldPresentReferences = true
                }) {
                    Image(systemName: "info.circle.fill")
                    Text("kButtonTitleReferences")
                }
                Button(action: {
                    self.shouldPresentEditExercise = true
                }) {
                    Image(systemName: "square.and.pencil")
                    Text("kButtonTitleEdit")
                }
        }
        }
    }
}

struct ExerciseRow_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        
        let pWorkout = Workout(context: moc)
        pWorkout.id = UUID()
        pWorkout.name = "Bicpes"
        
        let pExercise = Exercise(context: moc)
        pExercise.id = UUID()
        pExercise.name = "Dummbells curl"
        pExercise.notes = "Keep dumbeels straight, lift up and down slowly and repeat"
        
        let sets1 = ExerciseSet(context: moc)
        let sets2 = ExerciseSet(context: moc)
        let sets3 = ExerciseSet(context: moc)
        
        pExercise.exerciseSets = [sets1, sets2, sets3]
        
        pWorkout.exercises = [pExercise]
        
        return ExerciseRow(exercise: pExercise, selectedWorkout: pWorkout).environment(\.managedObjectContext, moc).environmentObject(AppSettings())
    }
}
