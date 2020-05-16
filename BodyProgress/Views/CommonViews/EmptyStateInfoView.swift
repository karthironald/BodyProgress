//
//  EmptyStateInfoView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct EmptyStateInfoView: View {
    
    var image: Image = Image(systemName: "exclamationmark.triangle.fill")
    var message: String = "No data to show"
    
    var body: some View {
        VStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.secondary)
                .shadow(radius: 10)
            Text(message)
                .font(kPrimaryBodyFont)
        }
        .padding()
        .zIndex(1)
    }
}

struct EmptyStateInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateInfoView()
    }
}
