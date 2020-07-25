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
    
    @State var shouldPresentAddNewReference = false
    @State var redrawPreview = false
    @State var newLink = ""
    @State var shouldShowDeleteConfirmation = false
    @State var deleteIndex = kCommonListIndex
    @State var editMode = false
    
    @FetchRequest(entity: ReferenceLinks.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ReferenceLinks.createdAt, ascending: false)]) var referencesLinks: FetchedResults<ReferenceLinks>
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack {
                    if shouldPresentAddNewReference {
                        HStack {
                            TextField("Paste the link", text: $newLink)
                                .padding(.leading)
                                .font(kPrimaryBodyFont)
                            Button(action: {
                                withAnimation {
                                    self.shouldPresentAddNewReference.toggle()
                                }
                                if !self.newLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    self.createNewReference()
                                }
                            }) {
                                Image(systemName: newLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "xmark.circle.fill" : "checkmark.circle.fill")
                                    .imageScale(.medium)
                                    .padding(.trailing)
                                    .foregroundColor( newLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .green)
                            }
                        }
                        .frame(height: 40)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
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
                                }
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .navigationBarTitle("Reference")
            .navigationBarItems(
                leading:
                Button(action: {
                    withAnimation {
                        self.editMode.toggle()
                    }
                }) {
                    Text(self.editMode ? "Done" : "Edit")
                        .font(kPrimaryBodyFont)
                        .foregroundColor(appSettings.themeColorView())
                },
                trailing:
                Button(action: {
                    self.newLink = ""
                    withAnimation {
                        self.shouldPresentAddNewReference.toggle()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(kPrimaryTitleFont)
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
    }
    
    func createNewReference() {
        let reference = ReferenceLinks(context: managedObjectContext)
        reference.id = UUID()
        reference.createdAt = Date()
        reference.updatedAt = Date()
        reference.url = newLink
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
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
        let moc = kAppDelegate.persistentContainer.viewContext
        
        let link = ReferenceLinks(context: moc)
        link.id = UUID()
        link.createdAt = Date()
        link.updatedAt = Date()
        link.url = "www.google.com"
        return ReferenceLinksListView().environment(\.managedObjectContext, moc).environmentObject(AppSettings())
    }
}

struct StringLink : Identifiable{
    var id = UUID()
    var string : String
}
