//
//  AddExerciseSet.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct AddExerciseSet: View {
    
    @Binding var shouldPresentAddNewExerciseSet: Bool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    static let weights: [Double] = [2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0]
    static let reputations: [Int] = [8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]
    var selectedExercise: Exercise
    @State var name: String = ""
    @State var notes: String = ""
    @State var weightIndex: Int = 0
    @State var reputationIndex: Int = 0
    var selectedExerciseSet: ExerciseSet?
    
    var body: some View {
        NavigationView {
            Form {
                Section { TextField("Name", text: $name) }
                Section { TextField("Notes", text: $notes) }
                Section {
                    Picker("Weight (kgs)", selection: $weightIndex) {
                        ForEach(0..<Self.weights.count, id: \.self) { index in
                            Text(String(describing: Self.weights[index]))
                        }
                    }
                    Picker("Reputations", selection: $reputationIndex) {
                        ForEach(0..<Self.reputations.count, id: \.self) { index in
                            Text(String(describing: Self.reputations[index]))
                        }
                    }
                }
            }
            .onAppear(perform: {
                kAppDelegate.addSeparatorLineAppearance()
            })
                .navigationBarTitle(Text("New set"), displayMode: .inline)
                .navigationBarItems(
                    trailing: Button(action: { self.saveWorkout() }) { CustomBarButton(title: "Save")
                })
        }
    }
    
    /**Dismisses the view*/
    func dismissView() {
        self.shouldPresentAddNewExerciseSet = false
    }
    
    /**Saves the new workout*/
    func saveWorkout() {
        if selectedExerciseSet != nil {
            selectedExerciseSet?.name = self.name
            selectedExerciseSet?.notes = self.notes
            selectedExerciseSet?.weight = Self.weights[weightIndex]
            selectedExerciseSet?.reputation = Int16(Self.reputations[reputationIndex])
        } else {
            let newExerciseSet = ExerciseSet(context: managedObjectContext)
            newExerciseSet.name = self.name
            newExerciseSet.notes = self.notes
            newExerciseSet.id = UUID()
            newExerciseSet.createdAt = Date()
            newExerciseSet.updatedAt = Date()
            newExerciseSet.weight = Self.weights[weightIndex]
            newExerciseSet.reputation = Int16(Self.reputations[reputationIndex])
            selectedExercise.addToExerciseSets(newExerciseSet)
        }
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                dismissView()
            } catch {
                print(error)
            }
        }
    }
    
}

struct AddExerciseSet_Previews: PreviewProvider {
    static var previews: some View {
        Text("Yet to configure preview")
    }
}
