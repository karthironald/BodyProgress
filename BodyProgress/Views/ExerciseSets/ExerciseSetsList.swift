//
//  ExerciseSetsList.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct ExerciseSetsList: View {
    
    @ObservedObject var selectedExercise: Exercise
    @State var shouldPresentAddNewExerciseSet = false
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var shouldPresentEditExerciseSet: Bool = false
    @State var editExerciseSetIndex: Int = kCommonListIndex
    
    var body: some View {
        ZStack {
            if selectedExercise.wExerciseSets.count == 0 {
                EmptyStateInfoView(message: "No sets added")
            }
            VStack {
                List{
                    ForEach(0..<selectedExercise.wExerciseSets.count, id: \.self) { exerciseSetIndex in
                        ZStack {
                            ExerciseSetRow(exerciseSet: self.selectedExercise.wExerciseSets[exerciseSetIndex])
                                .contextMenu {
                                    Button(action: {
                                        self.editExerciseSetIndex = exerciseSetIndex
                                        self.shouldPresentEditExerciseSet.toggle()
                                    }) {
                                        Image(systemName: "square.and.pencil")
                                        Text("Edit")
                                    }
                                    Button(action: {
                                        withAnimation {
                                            self.toggleFav(exerciseSet: self.selectedExercise.wExerciseSets[exerciseSetIndex])
                                        }
                                    }) {
                                        Image(systemName: self.selectedExercise.wExerciseSets[exerciseSetIndex].wIsFavourite  ? "star.fill" : "star")
                                        Text(self.selectedExercise.wExerciseSets[exerciseSetIndex].wIsFavourite  ? "Unfavourite" : "Favourite")
                                    }
                                    Button(action: {
                                        withAnimation {
                                            self.deleteExerciseSet(set: self.selectedExercise.wExerciseSets[exerciseSetIndex])
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                        Text("Delete")
                                    }
                            }
                        }
                    }
                }
                .padding([.top, .bottom], 10)
                .sheet(isPresented: $shouldPresentEditExerciseSet, content: {
                    AddExerciseSet(
                        shouldPresentAddNewExerciseSet: self.$shouldPresentEditExerciseSet,
                        selectedExercise: self.selectedExercise,
                        name: self.selectedExercise.wExerciseSets[self.editExerciseSetIndex].wName,
                        notes: self.selectedExercise.wExerciseSets[self.editExerciseSetIndex].wNotes,
                        weightIndex: AddExerciseSet.weights.firstIndex(of: self.selectedExercise.wExerciseSets[self.editExerciseSetIndex].wWeight) ?? 0,
                        reputationIndex: AddExerciseSet.reputations.firstIndex(of: Int(self.selectedExercise.wExerciseSets[self.editExerciseSetIndex].wReputation)) ?? 0,
                        selectedExerciseSet: self.selectedExercise.wExerciseSets[self.editExerciseSetIndex]
                    ).environment(\.managedObjectContext, self.managedObjectContext)
                    
                })
                    .navigationBarTitle(Text("Set"))
                    .navigationBarItems(trailing:
                        Button(action: {
                            self.shouldPresentAddNewExerciseSet.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(kPrimaryTitleFont)
                                .foregroundColor(kPrimaryColour)
                        }.sheet(isPresented: $shouldPresentAddNewExerciseSet) {
                            AddExerciseSet(shouldPresentAddNewExerciseSet: self.$shouldPresentAddNewExerciseSet, selectedExercise: self.selectedExercise).environment(\.managedObjectContext, self.managedObjectContext)
                        }
                )
            }
        }
        .onAppear {
            kAppDelegate.removeSeparatorLineAppearance()
        }
    }
    
    /**Toggle the favourite status of the set*/
    func toggleFav(exerciseSet: ExerciseSet) {
        exerciseSet.isFavourite.toggle()
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    /**Deletes the given set*/
    func deleteExerciseSet(set: ExerciseSet) {
        managedObjectContext.delete(set)
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
}

struct ExerciseSetsList_Previews: PreviewProvider {
    static var previews: some View {
        Text("Yet to configured")
    }
}
