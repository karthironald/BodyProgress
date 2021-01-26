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
    
    @State private var data: [(sum: Double, min: Double, max: Double, average: Double, count: Double, workout: String)] = []
    
    var bodyPart: BodyParts
    var total: Double {
        data.map { $0.sum }.reduce(0.0, +)
    }
    
    var body: some View {
        ZStack {
            if data.count == 0 {
                EmptyStateInfoView(title: "No summary was available. Start your workout.")
            } else {
                List(0..<data.count, id: \.self) { index in
                    BodyPartSummaryRow(summary: self.data[index], bodyPart: self.bodyPart, total: self.total).environmentObject(self.appSettings)
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationBarTitle(Text("\(bodyPart.rawValue)"))
        .onAppear {
            WorkoutHistory.fetchBodyPartSummary(startedAgo: appSettings.historySelectedTimePeriod.rawValue, context: self.managedObjectContext, of: self.bodyPart) { (data) in
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
