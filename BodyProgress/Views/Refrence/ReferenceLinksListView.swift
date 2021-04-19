//
//  ReferenceLinksListView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 25/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

struct ReferenceLinksListView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var redrawPreview = false
    @State private var shouldShowDeleteConfirmation = false
    @State private var deleteIndex = kCommonListIndex
    @State private var editMode: Bool = false
    
    @FetchRequest(entity: ReferenceLinks.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ReferenceLinks.createdAt, ascending: false)]) var referencesLinks: FetchedResults<ReferenceLinks>
    
    init(predicate: NSPredicate?, sortDescriptor: NSSortDescriptor) {
        let fetchRequest = NSFetchRequest<ReferenceLinks>(entityName: ReferenceLinks.entity().name ?? "ReferenceLinks")
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        _referencesLinks = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        ZStack {
            if referencesLinks.count == 0 {
                EmptyStateInfoView(title: NSLocalizedString("kInfoMsgNoReferenceLinksAdded", comment: "Info message"))
            }
            ScrollView(.vertical) {
                VStack {
                    ForEach(0..<referencesLinks.count, id: \.self) { linkIndex in
                        ZStack {
                            LinkRow(referenceLink: self.referencesLinks[linkIndex], redraw: self.$redrawPreview)
                            if self.editMode {
                                Button(action: {
                                    withAnimation {
                                        self.deleteIndex = linkIndex
                                        self.shouldShowDeleteConfirmation.toggle()
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .padding()
                                        .background(Color.red)
                                        .shadow(radius: 5)
                                        .clipShape(Circle())
                                }.zIndex(2)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarItems(leading:
            Button(action: {
                withAnimation {
                    self.editMode.toggle()
                }
            }) {
                Text(self.editMode ? "Done" : "Edit")
                    .font(kPrimaryBodyFont)
                    .foregroundColor(appSettings.themeColorView())
            }
        )
            .alert(isPresented: $shouldShowDeleteConfirmation, content: { () -> Alert in
                Alert(title: Text("kAlertTitleConfirm"), message: Text("kAlertMsgDeleteReferenceLink"), primaryButton: .cancel(), secondaryButton: .destructive(Text("kButtonTitleDelete"), action: {
                    withAnimation {
                        if self.deleteIndex != kCommonListIndex {
                            self.delete(referenceLink: self.referencesLinks[self.deleteIndex])
                        }
                    }
                }))
            })
    }
    
    /**Deletes the given exercise*/
    func delete(referenceLink: ReferenceLinks) {
        managedObjectContext.delete(referenceLink)
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
}

struct ReferenceLinksListView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewReferenceLinkView(shouldPresentAddNewReference: .constant(true))
    }
}

struct StringLink : Identifiable{
    var id = UUID()
    var string : String
}

struct AddNewReferenceLinkView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var newLink: String = ""
    @Binding var shouldPresentAddNewReference: Bool
    @State private var bodyPartIndex = 0
    @State private var shouldShowPasteButton = false
    
    @State private var errorMessage = ""
    @State private var shouldShowValidationAlert = false
    var copiedUrl = UIPasteboard.general.url
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        TextField("Enter reference link...", text: $newLink)
                            .font(kPrimaryBodyFont)
                        if shouldShowPasteButton {
                            Button("Paste") {
                                if let urlString = self.copiedUrl?.absoluteString {
                                    self.newLink = urlString
                                }
                            }
                            .foregroundColor(appSettings.themeColorView())
                        }
                    }
                }
                Section {
                    Picker("kPlaceholderBodyPart", selection: $bodyPartIndex) {
                        ForEach(0..<BodyParts.allCases.count, id: \.self) { index in
                            Text(BodyParts.allCases[index].rawValue)
                        }
                    }
                }
            }
            .onAppear(perform: {
                self.shouldShowPasteButton = (self.copiedUrl != nil) ? true : false
            })
                .navigationBarTitle(Text("New reference"), displayMode: .inline)
                .alert(isPresented: $shouldShowValidationAlert, content: { () -> Alert in
                    Alert(title: Text("kAlertTitleError"), message: Text(errorMessage), dismissButton: .default(Text("kButtonTitleOkay")))
                })
                .navigationBarItems(
                    trailing: Button(action: { self.validateData() }) { CustomBarButton(title: NSLocalizedString("kButtonTitleSave", comment: "Button title")).environmentObject(appSettings)
                })
        }
    }
    
    func createNewReference() {
        let reference = ReferenceLinks(context: managedObjectContext)
        reference.id = UUID()
        reference.createdAt = Date()
        reference.updatedAt = Date()
        reference.url = newLink
        reference.bodyPart = BodyParts.allCases[bodyPartIndex].rawValue
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                self.shouldPresentAddNewReference.toggle()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func validateData() {
        newLink = newLink.trimmingCharacters(in: .whitespacesAndNewlines)
        if newLink.isEmpty || URL(string: newLink) == nil {
            errorMessage = NSLocalizedString("kAlertMsgRefLinkRequired", comment: "Alert message")
            shouldShowValidationAlert.toggle()
        } else {
            createNewReference()
        }
    }
    
}
