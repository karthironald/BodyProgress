//
//  AddExercise.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct AddExercise: View {
    
    @Binding var shouldPresentAddNewExercise: Bool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var selectedWorkout: Workout
    @State var name: String = ""
    @State var notes: String = ""
    var selectedExercise: Exercise?
    
    var body: some View {
        NavigationView {
            Form {
                Section { TextField("Name", text: $name) }
                Section { TextField("Notes", text: $notes) }
            }
                .onAppear(perform: {
                    kAppDelegate.addSeparatorLineAppearance()
                })
            .navigationBarTitle(Text("New Exercise"), displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: { self.saveWorkout() }) { CustomBarButton(title: "Save")
            })
        }
    }
    
    /**Dismisses the view*/
    func dismissView() {
        self.shouldPresentAddNewExercise = false
    }
    
    /**Saves the new workout*/
    func saveWorkout() {
        if selectedExercise != nil { // Update exercise flow
            selectedExercise?.name = self.name
            selectedExercise?.notes = self.notes
            selectedExercise?.bodyPart = selectedWorkout.wBodyPart.rawValue
        } else { // New workout flow
            let newExercise = Exercise(context: managedObjectContext)
            newExercise.name = self.name
            newExercise.notes = self.notes
            newExercise.bodyPart = selectedWorkout.wBodyPart.rawValue
            newExercise.id = UUID()
            newExercise.createdAt = Date()
            newExercise.updatedAt = Date()
            selectedWorkout.addToExercises(newExercise)
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

struct AddExercise_Previews: PreviewProvider {
    static var previews: some View {
        Text("Yet to configure preview")
    }
}
