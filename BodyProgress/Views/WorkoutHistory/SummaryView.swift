//
//  SummaryView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 08/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct SummaryView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var totalWorkoutTime: Int16 = 0
    
    var body: some View {
        Text(totalWorkoutTime.displayDuration())
            .font(.title)
            .onAppear {
                WorkoutHistory.fetchSum(context: self.managedObjectContext) { (data) in
                    for d in data {
                        print("\(d.1) : \(d.0)")
                    }
                }
            }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}
