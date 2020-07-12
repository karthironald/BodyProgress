//
//  BodyPartSummary.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 12/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

struct BodyPartSummary: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var data: [(sum: Double, min: Double, max: Double, average: Double, count: Double, workout: String)] = []
    
    var bodyPart: BodyParts
    
    var body: some View {
        List(0..<data.count, id: \.self) { index in
            HStack {
                VStack(alignment: .leading) {
                    Text("Name: \(self.data[index].workout)")
                    Text("Sum: \(self.data[index].sum.detailedDisplayDuration())")
                    Text("Min: \(self.data[index].min.detailedDisplayDuration())")
                    Text("Max: \(self.data[index].max.detailedDisplayDuration())")
                    Text("Count: \(Int(self.data[index].count))")
                    Text("Average: \(self.data[index].average.detailedDisplayDuration())")
                }
                Spacer()
            }
        }
        .navigationBarTitle(Text("\(bodyPart.rawValue)"))
        .onAppear {
            WorkoutHistory.fetchBodyPartSummary(context: self.managedObjectContext, of: self.bodyPart) { (data) in
                self.data = data
            }
        }
    }
}

struct BodyPartSummary_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        BodyPartSummary(bodyPart: .arms).environment(\.managedObjectContext, moc).environmentObject(AppSettings())
    }
}
