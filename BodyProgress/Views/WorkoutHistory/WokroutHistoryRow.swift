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
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        ZStack {
            kPrimaryBackgroundColour
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(workoutHistory.wName)
                        .font(kPrimaryHeadlineFont)
                        .fontWeight(.bold)
                    HStack {
                        Text("\(workoutHistory.wBodyPart.rawValue)")
                            .font(kPrimarySubheadlineFont)
                            .opacity(0.75)
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 5, height: 5)
                        Text("\(workoutHistory.wCreatedAt, formatter: DateFormatter().appDormatter)")
                            .font(kPrimarySubheadlineFont)
                            .opacity(0.75)
                    }
                }
                .padding()
                Spacer()
                Image(systemName: workoutHistory.isAllSetCompleted() ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .imageScale(.large)
                    .foregroundColor(workoutHistory.isAllSetCompleted() ? .green : .orange)
                    .font(kPrimaryBodyFont)
                    .padding(.trailing, 10)
                Image(systemName: "arrowtriangle.right.fill")
                    .foregroundColor(.secondary)
                    .opacity(0.2)
                    .padding([.top, .bottom, .trailing])
            }
        }
        .frame(height: 80)
        .cornerRadius(kCornerRadius)
    }
    
}

struct WokroutHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        Text("Sample")
    }
}
