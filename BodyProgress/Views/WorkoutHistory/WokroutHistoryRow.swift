//
//  WokroutHistoryRow.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 15/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct WokroutHistoryRow: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var appSettings: AppSettings
    
    @ObservedObject var workoutHistory: WorkoutHistory
    
    var body: some View {
        NavigationLink(destination: WorkoutHistroyDetails(selectedWorkout: workoutHistory).environmentObject(self.appSettings).environment(\.managedObjectContext, self.managedObjectContext)) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workoutHistory.wName)
                        .font(kPrimaryHeadlineFont)
                        .fontWeight(.bold)
                    HStack {
                        Text("\(workoutHistory.wBodyPart.rawValue)")
                            .font(kPrimarySubheadlineFont)
                            .foregroundColor(.secondary)
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 5, height: 5)
                        Text("\(workoutHistory.wCreatedAt, formatter: DateFormatter().appDormatter)")
                            .font(kPrimarySubheadlineFont)
                            .foregroundColor(.secondary)
                    }
                }
                .padding([.top, .bottom], 5)
                Spacer()
                Image(systemName: workoutHistory.isAllSetCompleted() ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .imageScale(.large)
                    .foregroundColor(workoutHistory.isAllSetCompleted() ? Color(AppThemeColours.green.uiColor()) : Color(AppThemeColours.orange.uiColor()))
                    .font(kPrimaryBodyFont)
                    .padding(.trailing, 10)
            }
        }
    }
    
}

struct WokroutHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        Text("Sample")
    }
}
