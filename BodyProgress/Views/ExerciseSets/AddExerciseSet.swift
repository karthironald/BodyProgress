//
//  AddExerciseSet.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

struct AddExerciseSet: View {
    
    @Binding var shouldPresentAddNewExerciseSet: Bool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var selectedExercise: Exercise
    @State var name: String = ""
    @State var notes: String = ""
    @State var weightIndex: Int = 0
    @State var reputationIndex: Int = 0
    @State var weight: Double = 7
    @State var reputation: Double = 10
    var selectedExerciseSet: ExerciseSet?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) { TextField("Enter here", text: $name) }
                Section(header: Text("Notes")) { TextField("Enter here (optional)", text: $notes) }
                Section(header: Text("Weight (\(Int(weight)) kgs)"), footer: Text("Previous: \(previousSetWeight()) kgs")) {
                    Slider(value: $weight, in: 1...100, step: 1)
                }
                Section(header: Text("Reputations (\(Int(reputation)) rps)"), footer: Text("Previous: \(previousSetRep()) rps")) {
                    Slider(value: $reputation, in: 1...100, step: 1)
                }
            }
            .onAppear(perform: {
                kAppDelegate.addSeparatorLineAppearance()
            })
                .navigationBarTitle(Text("New Set"), displayMode: .inline)
                .navigationBarItems(
                    trailing: Button(action: { self.saveWorkout() }) { CustomBarButton(title: "Save")
                })
        }
    }
    
    func previousSetWeight() -> String {
        if selectedExerciseSet == nil {
            return "\(Int(selectedExercise.wExerciseSets.last?.wWeight ?? 0.0))"
        } else {
            let index = selectedExercise.wExerciseSets.firstIndex { (exSet) -> Bool in
                exSet.wId == selectedExerciseSet?.wId
            }
            if let index = index, index > 0 {
                let previousExset = selectedExercise.wExerciseSets[index - 1]
                return "\(Int(previousExset.wWeight))"
            }
        }
        return "0"
    }
    
    func previousSetRep() -> String {
        if selectedExerciseSet == nil {
            return "\(selectedExercise.wExerciseSets.last?.wReputation ?? 0)"
        } else {
            let index = selectedExercise.wExerciseSets.firstIndex { (exSet) -> Bool in
                exSet.wId == selectedExerciseSet?.wId
            }
            if let index = index, index > 0 {
                let previousExset = selectedExercise.wExerciseSets[index - 1]
                return "\(Int(previousExset.wReputation))"
            }
        }
        return "0"
    }
    
    /**Dismisses the view*/
    func dismissView() {
        self.shouldPresentAddNewExerciseSet = false
    }
    
    /**Saves the new workout*/
    func saveWorkout() {
        if selectedExerciseSet != nil { // Update set flow
            selectedExerciseSet?.name = self.name
            selectedExerciseSet?.notes = self.notes
            selectedExerciseSet?.weight = self.weight
            selectedExerciseSet?.reputation = Int16(self.reputation)
        } else { // New set flow
            let newExerciseSet = ExerciseSet(context: managedObjectContext)
            newExerciseSet.name = self.name
            newExerciseSet.notes = self.notes
            newExerciseSet.id = UUID()
            newExerciseSet.createdAt = Date()
            newExerciseSet.updatedAt = Date()
            newExerciseSet.weight = self.weight
            newExerciseSet.reputation = Int16(self.reputation)
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
