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
    
    @State var shouldShowDeleteConfirmation = false
    @State var deleteIndex = kCommonListIndex
    
    var body: some View {
        ZStack {
            if selectedExercise.wExerciseSets.count == 0 {
                EmptyStateInfoView(message: NSLocalizedString("kInfoMsgNoExercisesSetsAdded", comment: "Info message"))
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
                                        Text("kButtonTitleEdit")
                                    }
                                    Button(action: {
                                        withAnimation {
                                            self.toggleFav(exerciseSet: self.selectedExercise.wExerciseSets[exerciseSetIndex])
                                        }
                                    }) {
                                        Image(systemName: self.selectedExercise.wExerciseSets[exerciseSetIndex].wIsFavourite  ? "star.fill" : "star")
                                        Text(self.selectedExercise.wExerciseSets[exerciseSetIndex].wIsFavourite  ? "kButtonTitleUnfavourite" : "kButtonTitleFavourite")
                                    }
                                    Button(action: {
                                        self.deleteIndex = exerciseSetIndex
                                        self.shouldShowDeleteConfirmation.toggle()
                                    }) {
                                        Image(systemName: "trash")
                                        Text("kButtonTitleDelete")
                                    }
                            }
                        }
                    }
                    .onDelete { (indexSet) in
                        if let index = indexSet.first, index < self.selectedExercise.wExerciseSets.count {
                            self.deleteIndex = index
                            self.shouldShowDeleteConfirmation.toggle()
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
                        weight: self.selectedExercise.wExerciseSets[self.editExerciseSetIndex].wWeight,
                        reputation: Double(self.selectedExercise.wExerciseSets[self.editExerciseSetIndex].wReputation),
                        selectedExerciseSet: self.selectedExercise.wExerciseSets[self.editExerciseSetIndex]
                    ).environment(\.managedObjectContext, self.managedObjectContext)
                })
                    .navigationBarTitle(selectedExercise.wName)
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
        .alert(isPresented: $shouldShowDeleteConfirmation, content: { () -> Alert in
            Alert(title: Text("kAlertTitleConfirm"), message: Text("kAlertMsgDeleteExerciseSet"), primaryButton: .cancel(), secondaryButton: .destructive(Text("kButtonTitleDelete"), action: {
                withAnimation {
                    if self.deleteIndex != kCommonListIndex {
                        self.deleteExerciseSet(set: self.selectedExercise.wExerciseSets[self.deleteIndex])
                    }
                }
            }))
        })
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
        Text("kPreviewYtb")
    }
}
