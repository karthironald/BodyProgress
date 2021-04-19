//
//  ExerciseReferenceView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 30/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct ExerciseReferenceView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @State private var redrawPreview = false
    @Binding var shouldPresentReferences: Bool
    
    var referencesLinks: [ReferenceLinks] = []
    var exerciseName: String
    
    var body: some View {
        NavigationView {
            ZStack {
                if referencesLinks.count == 0 {
                    EmptyStateInfoView(title: NSLocalizedString("kInfoMsgNoReferenceLinksAdded", comment: "Info message"))
                }
                ScrollView(.vertical) {
                    VStack {
                        ForEach(0..<referencesLinks.count, id: \.self) { linkIndex in
                            LinkRow(referenceLink: self.referencesLinks[linkIndex], redraw: self.$redrawPreview)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitle(Text("\(exerciseName) references"), displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    self.shouldPresentReferences.toggle()
                }) {
                    CustomBarButton(title: NSLocalizedString("kButtonTitleDone", comment: "Button title")).environmentObject(appSettings)
                }
            )
        }
    }
}

struct ExerciseReferenceView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseReferenceView(shouldPresentReferences: .constant(false), exerciseName: "Sample")
    }
}
