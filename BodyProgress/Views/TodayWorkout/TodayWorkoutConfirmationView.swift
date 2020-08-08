//
//  TodayWorkoutConfirmationView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 07/08/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct TodayWorkoutConfirmationView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack {
            Text("Ready to start Biceps?")
                .font(kPrimaryTitleFont)
                .bold()
                .padding(.bottom)
            
            HStack() {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                    .padding([.leading], 10)
                Text("Last session:")
                    .foregroundColor(.secondary)
                Text("1h 12m 30s")
            }
            
            HStack(spacing: 0) {
                Text("You might complete the workout at ")
                    .font(kPrimaryCalloutFont)
                    .padding([.leading, .top, .bottom])
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Text("10.15 pm")
                    .font(kPrimaryCalloutFont)
            }
            Button("Start") {
                // todo
            }
            .font(kPrimaryBodyFont)
            .frame(width: 250, height: 50)
            .foregroundColor(.white)
            .background(appSettings.themeColorView())
            .cornerRadius(kCornerRadius)
            .padding(.bottom)
            
            Button("Cancel") {
                // todo
            }
            .frame(width: 250, height: 50)
            .background(Color.secondary.opacity(0.2))
            .foregroundColor(.secondary)
            .cornerRadius(kCornerRadius)
        }
        .padding()
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(kCornerRadius)
    }
}

struct TodayWorkoutConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        TodayWorkoutConfirmationView().preferredColorScheme(.dark).environmentObject(AppSettings())
    }
}
