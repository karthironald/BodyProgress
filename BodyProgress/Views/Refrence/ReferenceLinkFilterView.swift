//
//  ReferenceLinkFilterView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 26/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct ReferenceLinkFilterView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var shouldPresentAddNewReference = false
    @State private var shouldPresentBodyParts = false
    
    var body: some View {
        NavigationView {
            VStack {
                if shouldPresentBodyParts {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(BodyParts.allCases, id: \.self) { part in
                                Text(part.rawValue)
                                    .font(kPrimaryFootnoteFont)
                                    .opacity(1)
                                    .padding()
                                    .background(self.appSettings.referenceSelectedBodyParts.contains(part) ? self.appSettings.themeColorView() : kPrimaryBackgroundColour)
                                    .foregroundColor(.white)
                                    .frame(height: 30)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        if self.appSettings.referenceSelectedBodyParts.contains(part) {
                                            if let index = self.appSettings.referenceSelectedBodyParts.firstIndex(of: part) {
                                                self.appSettings.referenceSelectedBodyParts.remove(at: index)
                                                self.appSettings.referenceSelectedBodyParts = self.appSettings.referenceSelectedBodyParts
                                            }
                                        } else {
                                            self.appSettings.referenceSelectedBodyParts.append(part)
                                            self.appSettings.referenceSelectedBodyParts = self.appSettings.referenceSelectedBodyParts
                                        }
                                }
                            }
                        }
                    }
                    .padding([.leading, .trailing], 15)
                    Divider()
                        .padding([.leading, .trailing], 15)
                }
                
                ReferenceLinksListView(predicate: self.predicate(), sortDescriptor: NSSortDescriptor(keyPath: \ReferenceLinks.createdAt, ascending: false))
            }
            .navigationBarTitle("Reference")
            .navigationBarItems(
                trailing:
                HStack {
                    Button(action: {
                        withAnimation(.linear) {
                            self.shouldPresentBodyParts.toggle()
                        }
                    }) {
                        Text(shouldPresentBodyParts ? "Done" : "Filter")
                            .font(kPrimaryBodyFont)
                            .bold()
                    }
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.shouldPresentAddNewReference.toggle()
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(kPrimaryTitleFont)
                            .foregroundColor(appSettings.themeColorView())
                    }
                }
            )
            .sheet(isPresented: $shouldPresentAddNewReference, content: {
                AddNewReferenceLinkView(shouldPresentAddNewReference: self.$shouldPresentAddNewReference).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
            })
        }
    }
    
    /**Creates predicate based on filter values*/
    func predicate() -> NSPredicate? {
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "bodyPart IN %@", appSettings.referenceSelectedBodyParts.map { $0.rawValue }))
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
}

struct ReferenceLinkFilterView_Previews: PreviewProvider {
    static var previews: some View {
        ReferenceLinkFilterView().environmentObject(AppSettings())
    }
}
