//
//  Diets.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 23/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct Diets: View {
    var body: some View {
        NavigationView {
            ZStack {
                EmptyStateInfoView(image: Image(systemName: "waveform.path.ecg"), title: "Yet to be implemented!")
                .navigationBarTitle(Text("Diets"))
            }
        }
    }
}

struct Diets_Previews: PreviewProvider {
    static var previews: some View {
        Diets()
    }
}
