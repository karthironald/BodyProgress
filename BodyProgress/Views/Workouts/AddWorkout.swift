//
//  AddWorkout.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 27/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

struct AddWorkout: View {
    
    @Binding var shouldPresentAddNewWorkout: Bool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var name: String = ""
    @State var notes: String = ""
    @State var bodyPartIndex = 0
    var workoutToEdit: Workout?
    
    var body: some View {
        NavigationView {
            Form {
                Section { TextField("Name", text: $name) }
                Section { TextField("Notes", text: $notes) }
                Section {
                    Picker("Body part", selection: $bodyPartIndex) {
                        ForEach(0..<BodyParts.allCases.count, id: \.self) { index in
                            Text(BodyParts.allCases[index].rawValue)
                        }
                    }
                }
            }
            .onAppear(perform: {
                kAppDelegate.addSeparatorLineAppearance()
            })
                .navigationBarTitle(Text("New Workout"), displayMode: .inline)
                .navigationBarItems(
                    trailing: Button(action: { self.saveWorkout() }) { CustomBarButton(title: "Save")
                })
        }
        
    }
    
    /**Dismisses the view*/
    func dismissView() {
        self.shouldPresentAddNewWorkout = false
    }
    
    /**Saves the new workout*/
    func saveWorkout() {
        if workoutToEdit != nil { // Update workout flow
            workoutToEdit?.name = self.name
            workoutToEdit?.notes = self.notes
            workoutToEdit?.bodyPart = BodyParts.allCases[bodyPartIndex].rawValue
        } else { // New workout flow
            let newWorkout = Workout(context: managedObjectContext)
            newWorkout.name = self.name
            newWorkout.notes = self.notes
            newWorkout.bodyPart = BodyParts.allCases[bodyPartIndex].rawValue
            newWorkout.id = UUID()
            newWorkout.createdAt = Date()
            newWorkout.updatedAt = Date()
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

struct AddWorkout_Previews: PreviewProvider {
    let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        AddWorkout(shouldPresentAddNewWorkout: .constant(false))
    }
}
