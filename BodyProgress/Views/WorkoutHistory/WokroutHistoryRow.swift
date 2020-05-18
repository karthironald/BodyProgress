//
//  WokroutHistoryRow.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 15/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct WokroutHistoryRow: View {
    
    @ObservedObject var workoutHistory: WorkoutHistory
    
    var body: some View {
        ZStack {
            kPrimaryBackgroundColour
            HStack(alignment: .center) {
                Image(systemName: "clock.fill")
                    .imageScale(.large)
                    .font(kPrimaryTitleFont)
                    .foregroundColor(Color.gray)
                    .padding([.leading], 15)
                    .opacity(0.5)
                VStack(alignment: .leading) {
                    Text(workoutHistory.wName)
                        .font(kPrimaryHeadlineFont)
                        .fontWeight(.bold)
                    HStack {
                        Text("\(workoutHistory.wCreatedAt, formatter: DateFormatter().appDormatter)")
                        .font(kPrimarySubheadlineFont)
                        .opacity(0.5)
                        if !workoutHistory.wDuration.detailedDisplayDuration().isEmpty {
                            Text("(\(workoutHistory.wDuration.detailedDisplayDuration()))")
                                .font(kPrimarySubheadlineFont)
                                .opacity(0.5)
                        }
                    }
                    Text("\(workoutHistory.wBodyPart.rawValue)")
                        .font(kPrimarySubheadlineFont)
                        .opacity(0.5)
                }
                .padding(5)
                Spacer()
                Image(systemName: workoutHistory.isAllSetCompleted() ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .imageScale(.large)
                    .foregroundColor(workoutHistory.isAllSetCompleted() ? kPrimaryColour : .orange)
                    .font(kPrimaryBodyFont)
                    .padding()
            }
        }
        .frame(height: 90)
        .cornerRadius(kCornerRadius)
    }
    
}

struct WokroutHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        Text("Sample")
    }
}
