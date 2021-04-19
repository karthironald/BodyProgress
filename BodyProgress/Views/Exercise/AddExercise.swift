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
    @State var referenceLinks: [(String, Bool)] = []
    var selectedExercise: Exercise?

    @State private var errorMessage = ""
    @State private var shouldShowValidationAlert = false
    @State private var shouldShowDeleteConfirmation = false
    @State private var deleteIndex = kCommonListIndex
    
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
                                    self.referenceLinks.insert(("", false), at: 0)
                                }) {
                                    Text("Add Reference")
                                }
                                .deleteDisabled(true)
                            } else {
                                TextField("Enter reference link...", text: Binding<String>(get: {
                                    self.referenceLinks[linkIndex].0
                                }, set: {
                                    self.referenceLinks[linkIndex].0 = $0
                                }))
                                .font(kPrimaryBodyFont)
                                .foregroundColor(self.canOpenURL(self.referenceLinks[linkIndex].0) ? nil : .red)
                                .disabled(self.referenceLinks[linkIndex].1)
                            }
                        }
                    }.onDelete { (indexSet) in
                        if let index = indexSet.first, index < self.selectedExercise?.wReferences.count ?? 0, self.referenceLinks[index].1 {
                            self.deleteIndex = index
                            self.shouldShowDeleteConfirmation.toggle()
                        } else if let index = indexSet.first, index < self.referenceLinks.count {
                            self.referenceLinks.remove(at: index)
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
                .alert(isPresented: $shouldShowDeleteConfirmation, content: { () -> Alert in
                    Alert(title: Text("kAlertTitleConfirm"), message: Text("kAlertMsgDeleteExerciseReference"), primaryButton: .cancel(), secondaryButton: .destructive(Text("kButtonTitleDelete"), action: {
                        withAnimation {
                            if self.deleteIndex != kCommonListIndex {
                                self.delete(referenceLink: self.selectedExercise?.wReferences[self.deleteIndex])
                            }
                        }
                    }))
                })
                .navigationBarTitle(Text(selectedExercise == nil ? "kScreenTitleNewExercise" : "kScreenTitleEditExercise"), displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: { self.validateData() }) { CustomBarButton(title: NSLocalizedString("kButtonTitleSave", comment: "Button title")).environmentObject(appSettings)
            })
        }
    }
    
    func canOpenURL(_ string: String?) -> Bool {
        var formatterString = string?.trimmingCharacters(in: .whitespacesAndNewlines)
        formatterString = formatterString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let urlString = formatterString, let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
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
        
        let references = createNewReference()
        
        if selectedExercise != nil { // Update exercise flow
            selectedExercise?.name = self.name
            selectedExercise?.notes = self.notes
            selectedExercise?.bodyPart = selectedWorkout.wBodyPart.rawValue
            if references.count > 0 {
                selectedExercise?.addToReferences(NSSet(array: references))
            }
        } else { // New workout flow
            let newExercise = Exercise(context: managedObjectContext)
            newExercise.name = self.name
            newExercise.notes = self.notes
            newExercise.bodyPart = selectedWorkout.wBodyPart.rawValue
            newExercise.id = UUID()
            newExercise.createdAt = Date()
            newExercise.updatedAt = Date()
            newExercise.displayOrder = Int16(selectedWorkout.wExercises.count)
            if references.count > 0 {
                newExercise.addToReferences(NSSet(array: references))
            }
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
        for link in referenceLinks where canOpenURL(link.0) && !(selectedExercise?.wReferences.map({ $0.url }).contains(link.0) ?? false) {
            let reference = ReferenceLinks(context: managedObjectContext)
            reference.id = UUID()
            reference.createdAt = Date()
            reference.updatedAt = Date()
            reference.url = link.0.trimmingCharacters(in: .whitespacesAndNewlines)
            reference.bodyPart = selectedWorkout.wBodyPart.rawValue
            
            links.append(reference)
        }
        return links
    }
    
    /**Deletes the given exercise*/
    func delete(referenceLink: ReferenceLinks?) {
        if let referenceLink = referenceLink {
            managedObjectContext.delete(referenceLink)
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                    if let selectedExercise = selectedExercise {
                        referenceLinks = selectedExercise.wReferences.map { ($0.wUrl, true) }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

struct AddExercise_Previews: PreviewProvider {
    static var previews: some View {
        Text("kPreviewYtb")
    }
}
