//
//  ReferenceLinksRow.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 25/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import LinkPresentation

struct LinkRow : UIViewRepresentable {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var referenceLink: ReferenceLinks
    
    @Binding var redraw: Bool
    
    func makeUIView(context: Context) -> LPLinkView {
        if let url = URL(string: referenceLink.wUrl) {
            let view = LPLinkView(url: url)
            
            let provider = LPMetadataProvider()
            if let metadata = try? NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: referenceLink.wMetadata) {
                view.metadata = metadata
                DispatchQueue.main.async {
                    self.redraw.toggle()
                }
            } else {
                provider.startFetchingMetadata(for: url) { (metadata, error) in
                    if let metadata = metadata {
                        DispatchQueue.main.async {
                            view.metadata = metadata
                            self.redraw.toggle()
                        }
                        self.cache(metadata: metadata)
                    } else if error != nil {
                        DispatchQueue.main.async {
                            let metaData = LPLinkMetadata()
                            metaData.title = "Couldn't load reference link"
                            view.metadata = metaData
                            view.sizeToFit()
                            self.redraw.toggle()
                        }
                    }
                }
            }
            return view
        } else {
            return LPLinkView()
        }
    }
    
    func updateUIView(_ view: LPLinkView, context: Context) {
        // New instance for each update
    }
    
    func cache(metadata: LPLinkMetadata) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: true)
            referenceLink.metadata = data
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                }
            }
        }  catch {
            print(error.localizedDescription)
        }
    }
    
}
