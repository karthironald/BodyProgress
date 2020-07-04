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
    
    @EnvironmentObject var appSettings: AppSettings
    @Binding var shouldPresentAddNewWorkout: Bool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var name: String = ""
    @State var notes: String = ""
    @State var bodyPartIndex = 0
    var workoutToEdit: Workout?
    
    @State private var errorMessage = ""
    @State private var shouldShowValidationAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("kHeaderName")) { TextField("kPlaceholderEnterHere", text: $name) }
                Section(header: Text("kHeaderNotes")) { TextField("kPlaceholderEnterHereOptional", text: $notes) }
                Section(header: Text("kHeaderChooseBodyPart")) {
                    Picker("kPlaceholderBodyPart", selection: $bodyPartIndex) {
                        ForEach(0..<BodyParts.allCases.count, id: \.self) { index in
                            Text(BodyParts.allCases[index].rawValue)
                        }
                    }
                }
            }
            .onAppear(perform: {
                kAppDelegate.addSeparatorLineAppearance()
            })
                .alert(isPresented: $shouldShowValidationAlert, content: { () -> Alert in
                    Alert(title: Text("kAlertTitleError"), message: Text(errorMessage), dismissButton: .default(Text("kButtonTitleOkay")))
                })
                .navigationBarTitle(Text(workoutToEdit == nil ? "kScreenTitleNewWorkout" : "kScreenTitleEditWorkout"), displayMode: .inline)
                .navigationBarItems(
                    trailing: Button(action: { self.validateData() }) { CustomBarButton(title: NSLocalizedString("kButtonTitleSave", comment: "Button title")).environmentObject(appSettings)
                })
        }
        
    }
    
    /**Dismisses the view*/
    func dismissView() {
        self.shouldPresentAddNewWorkout = false
    }
    
    func validateData() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if name.isEmpty {
            errorMessage = NSLocalizedString("kAlertMsgWorkoutNameRequired", comment: "Alert message")
            shouldShowValidationAlert.toggle()
        } else {
            saveWorkout()
        }
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
            newWorkout.isFavourite = false
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
