//
//  ExerciseSetsList.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct ExerciseSetsList: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var selectedExercise: Exercise
    @State private var shouldPresentAddNewExerciseSet = false
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var shouldPresentEditExerciseSet: Bool = false
    @State private var editExerciseSetIndex: Int = kCommonListIndex
    
    @State private var shouldShowDeleteConfirmation = false
    @State private var deleteIndex = kCommonListIndex
    
    var body: some View {
        ZStack {
            if selectedExercise.wExerciseSets.count == 0 {
                EmptyStateInfoView(title: NSLocalizedString("kInfoMsgNoExercisesSetsAddedTitle", comment: "Info message"), message: NSLocalizedString("kInfoMsgNoExercisesSetsAddedMessage", comment: "Info message"))
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
                    ).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
                })
                    .navigationBarTitle(selectedExercise.wName)
                    .navigationBarItems(trailing:
                        Button(action: {
                            self.shouldPresentAddNewExerciseSet.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(kPrimaryTitleFont)
                                .foregroundColor(appSettings.themeColorView())
                        }.sheet(isPresented: $shouldPresentAddNewExerciseSet) {
                            AddExerciseSet(shouldPresentAddNewExerciseSet: self.$shouldPresentAddNewExerciseSet, selectedExercise: self.selectedExercise).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
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
