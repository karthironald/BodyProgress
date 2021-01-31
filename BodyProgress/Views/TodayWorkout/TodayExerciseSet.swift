//
//  TodayExerciseSet.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 08/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

struct TodayExerciseSet: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var exerciseSet: ExerciseSetHistory
    @State private var status: Bool = false
    var isViewOnly = false
    
    var body: some View {
        GeometryReader { geo in
            HStack() {
                Text(self.exerciseSet.wName)
                    .font(kPrimaryBodyFont)
                    .foregroundColor(.secondary)
                    .frame(width: geo.size.width / 4, alignment: .leading)
                Spacer()
                HStack() {
                    Text(String(self.exerciseSet.wWeight))
                        .font(kPrimaryBodyFont)
                    Text("kgs")
                        .font(kPrimaryBodyFont)
                        .foregroundColor(.secondary)
                }
                .frame(width: geo.size.width / 4, alignment: .trailing)
                Spacer()
                HStack() {
                    Text(String(self.exerciseSet.wReputation))
                        .font(kPrimaryBodyFont)
                    Text("rps")
                        .font(kPrimaryBodyFont)
                        .foregroundColor(.secondary)
                }
                .frame(width: geo.size.width / 4, alignment: .trailing)
                Spacer()
                if self.isViewOnly {
                    self.statusImageView(status: self.exerciseSet.status)
                } else {
                    self.statusImageView(status: self.exerciseSet.status)
                        .onTapGesture {
                            Helper.hapticFeedback()
                            withAnimation() {
                                self.exerciseSet.status.toggle()
                                self.status = self.exerciseSet.status
                            }
                            self.save()
                    }
                }
            }
            .multilineTextAlignment(.leading)
        }
    }
    
    func statusImageView(status: Bool) -> some View {
        Image(systemName: status ? "burst.fill" : "burst")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .imageScale(.large)
            .frame(width: 25, height: 20)
            .foregroundColor(status ? appSettings.themeColorView() : .secondary)
            .padding(.leading)
    }
    
    func save() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                if appSettings.shouldAutoStartRestTimer { // Check whether auto rest timer is enabled.
                    NotificationCenter.default.post(name: .didSaveTodayWorkoutSet, object: nil)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct TodayExerciseSet_Previews: PreviewProvider {
    static var previews: some View {
        TodayExerciseSet(exerciseSet: ExerciseSetHistory())
    }
}
