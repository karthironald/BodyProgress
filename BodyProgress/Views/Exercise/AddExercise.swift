//
//  AddExercise.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct AddExercise: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Binding var shouldPresentAddNewExercise: Bool
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var selectedWorkout: Workout
    @State var name: String = ""
    @State var notes: String = ""
    var selectedExercise: Exercise?
    
    @State private var errorMessage = ""
    @State private var shouldShowValidationAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("kHeaderName")) { TextField("kPlaceholderEnterHere", text: $name) }
                Section(header: Text("kHeaderNotes")) { TextField("kPlaceholderEnterHereOptional", text: $notes) }
            }
                .onAppear(perform: {
                    kAppDelegate.addSeparatorLineAppearance()
                })
                .alert(isPresented: $shouldShowValidationAlert, content: { () -> Alert in
                    Alert(title: Text("kAlertTitleError"), message: Text(errorMessage), dismissButton: .default(Text("kButtonTitleOkay")))
                })
                .navigationBarTitle(Text(selectedExercise == nil ? "kScreenTitleNewExercise" : "kScreenTitleEditExercise"), displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: { self.validateData() }) { CustomBarButton(title: NSLocalizedString("kButtonTitleSave", comment: "Button title")).environmentObject(appSettings)
            })
        }
    }
    
    /**Dismisses the view*/
    func dismissView() {
        self.shouldPresentAddNewExercise = false
    }
    
    func validateData() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            errorMessage = NSLocalizedString("kAlertMsgExerciseNameRequired", comment: "Alert message")
            shouldShowValidationAlert.toggle()
        } else {
            saveExercise()
        }
    }
    
    /**Saves the new workout*/
    func saveExercise() {
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
        Text("kPreviewYtb")
    }
}
