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
    
    @ObservedObject var exerciseSet: ExerciseSetHistory
    @State var status: Bool = false {
        didSet { exerciseSet.status = status }
    }
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // Sample comment has been added  
    var body: some View {
        GeometryReader { geo in
            HStack() {
                Text(self.exerciseSet.wName)
                    .font(kPrimaryBodyFont)
                    .frame(width: geo.size.width / 4, alignment: .leading)
                Spacer()
                HStack() {
                    Text(String(self.exerciseSet.wWeight))
                        .font(kPrimaryBodyFont)
                    Text("kgs")
                        .font(kPrimaryBodyFont)
                        .opacity(0.5)
                }
                .frame(width: geo.size.width / 4, alignment: .trailing)
                Spacer()
                HStack() {
                    Text(String(self.exerciseSet.wReputation))
                        .font(kPrimaryBodyFont)
                    Text("rps")
                        .font(kPrimaryBodyFont)
                        .opacity(0.5)
                }
                .frame(width: geo.size.width / 4, alignment: .trailing)
                Spacer()
                Image(systemName: self.status ? "burst.fill" : "burst")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .imageScale(.large)
                    .frame(width: 25, height: 20)
                    .foregroundColor(self.status ? .green : .secondary)
                    .padding(.leading)
                    .onTapGesture {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                        withAnimation() {
                            self.status.toggle()
                        }
                        self.updateExerciseSet()
                }
            }
            .multilineTextAlignment(.leading)
        }
    }
    
    func updateExerciseSet() {
        exerciseSet.status = status
    }
    
}

struct TodayExerciseSet_Previews: PreviewProvider {
    static var previews: some View {
        TodayExerciseSet(exerciseSet: ExerciseSetHistory())
    }
}
