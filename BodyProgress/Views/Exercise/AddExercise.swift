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
    @State var referenceLinks: [String] = []
    @State private var shouldShowPasteButton = false
    var selectedExercise: Exercise?
    var copiedUrl = UIPasteboard.general.url

    @State private var errorMessage = ""
    @State private var shouldShowValidationAlert = false

    var body: some View {
        
        NavigationView {
            Form {
                Section(header: Text("kHeaderName")) { TextField("kPlaceholderEnterHere", text: $name) }
                Section(header: Text("kHeaderNotes")) { TextField("kPlaceholderEnterHereOptional", text: $notes) }
                Section {
                    ForEach(0..<referenceLinks.count + 1, id: \.self) { linkIndex in
                        Group {
                            if linkIndex == self.referenceLinks.count {
                                Button(action: {
                                    self.referenceLinks.append("")
                                }) {
                                    Text("Add Reference")
                                }
                            } else {
                                HStack {
                                    TextField("Enter reference link...", text: Binding<String>(get: {
                                        self.referenceLinks[linkIndex]
                                    }, set: {
                                        self.referenceLinks[linkIndex] = $0.lowercased()
                                    }))
                                        .font(kPrimaryBodyFont)
                                        .foregroundColor(self.canOpenURL(self.referenceLinks[linkIndex]) ? nil : .red)
                                    if self.shouldShowPasteButton {
                                        Button("Paste") {
                                            if let urlString = self.copiedUrl?.absoluteString {
                                                self.referenceLinks[linkIndex] = urlString
                                            }
                                        }
                                        .foregroundColor(self.appSettings.themeColorView())
                                    }
                                }
                            }
                        }
                    }
                }
            }
                .onAppear(perform: {
                    self.shouldShowPasteButton = (self.copiedUrl != nil) ? true : false
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
    
    func canOpenURL(_ string: String?) -> Bool {
        guard let urlString = string, let url = URL(string: urlString) else { return false }
        if !UIApplication.shared.canOpenURL(url) { return false }

        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
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
            newExercise.displayOrder = Int16(selectedWorkout.wExercises.count)
            newExercise.references = NSSet(array: createNewReference())
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
    
    func createNewReference() -> [ReferenceLinks] {
        var links: [ReferenceLinks] = []
        for link in referenceLinks where canOpenURL(link) {
            let reference = ReferenceLinks(context: managedObjectContext)
            reference.id = UUID()
            reference.createdAt = Date()
            reference.updatedAt = Date()
            reference.url = link
            reference.bodyPart = selectedWorkout.wBodyPart.rawValue
            
            links.append(reference)
        }
        return links
    }
    
}

struct AddExercise_Previews: PreviewProvider {
    static var previews: some View {
        Text("kPreviewYtb")
    }
}
