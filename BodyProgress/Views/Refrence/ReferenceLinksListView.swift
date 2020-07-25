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
    @State var shouldPresentAddNewReference = true
    
    @State var redrawPreview = false
    @State var newLink = ""
    let links : [StringLink]  = [StringLink(string: "https://www.instagram.com/p/CDBl3aIn7pg/?utm_source=ig_web_copy_link")]
    
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
                            }) {
                                Image(systemName: newLink.count == 0 ? "xmark.circle.fill" : "checkmark.circle.fill")
                                    .imageScale(.medium)
                                    .padding(.trailing)
                                    .foregroundColor( newLink.count == 0 ? .secondary : .green)
                            }
                        }
                        .frame(height: 40)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    ForEach(links) { link in
                        LinkRow(previewURL: URL(string: link.string)!, redraw: self.$redrawPreview)
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
