//
//  ReferenceLinksListView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 25/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

//, StringLink(string: "https://www.instagram.com/p/CDBl3aIn7pg/?utm_source=ig_web_copy_link"), StringLink(string: "https://www.instagram.com/p/CCwID_pDYkr/?utm_source=ig_web_copy_link"), StringLink(string: "https://www.instagram.com/p/CDBCF5WpX50/?utm_source=ig_web_copy_link"), StringLink(string: "https://www.instagram.com/p/CCouyMXpXop/?utm_source=ig_web_copy_link"), StringLink(string: "https://www.instagram.com/p/CCMUsfGJQfK/?utm_source=ig_web_copy_link"), StringLink(string: "https://www.instagram.com/p/CBWd-5tD39Q/?utm_source=ig_web_copy_link")

struct ReferenceLinksListView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var shouldPresentAddNewReference = true
    @State var redrawPreview = false
    @State var newLink = ""
    
    @FetchRequest(entity: ReferenceLinks.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ReferenceLinks.createdAt, ascending: true)]) var referencesLinks: FetchedResults<ReferenceLinks>
    
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
                    ForEach(referencesLinks, id: \.self) { link in
                        LinkRow(referenceLink: link, redraw: self.$redrawPreview)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Reference")
            .navigationBarItems(trailing:
                Button(action: {
                    withAnimation {
                        self.shouldPresentAddNewReference.toggle()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(kPrimaryTitleFont)
                        .foregroundColor(appSettings.themeColorView())
                }
            )
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
    
    
}

struct ReferenceLinksListView_Previews: PreviewProvider {
    static var previews: some View {
        ReferenceLinksListView().environmentObject(AppSettings())
    }
}

struct StringLink : Identifiable{
    var id = UUID()
    var string : String
}
