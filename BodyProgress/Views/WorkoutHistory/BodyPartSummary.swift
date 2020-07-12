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
    
    @State var histories: [WorkoutHistory] = []
    
    var bodyPart: BodyParts
    var total: Int { histories.count }
    var completed: Int { histories.filter { $0.status == true }.count }
    
    var body: some View {
        VStack {
            HStack(spacing: 50) {
                Text("Completed: \(completed)")
                    .font(kPrimaryBodyFont)
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 150, height: 60)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Text("Gaveup: \(total - completed)")
                    .font(kPrimaryBodyFont)
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 150, height: 60)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding()
            
            HStack{
                ForEach(1...15, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.pink)
                        .frame(width: 10, height: 150)
                }
            }
            Spacer()
            
        }
        .onAppear {
            WorkoutHistory.fetchBodyPartSummary(context: self.managedObjectContext, of: self.bodyPart) { (result) in
                print(result)
            }
//            WorkoutHistory.fetchDetails(of: self.bodyPart, context: self.managedObjectContext) { (histories) in
//                self.histories = histories
//            }
        }
    }
}

struct BodyPartSummary_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        BodyPartSummary(bodyPart: .arms).environment(\.managedObjectContext, moc).environmentObject(AppSettings())
    }
}
