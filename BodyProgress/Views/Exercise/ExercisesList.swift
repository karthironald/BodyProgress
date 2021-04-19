//
//  ExercisesList.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 23/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct ExercisesList: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var selectedWorkout: Workout
    @State private var shouldPresentAddNewExercise = false
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var shouldShowDeleteConfirmation = false
    @State private var deleteIndex = kCommonListIndex
    
    var body: some View {
        ZStack {
            if selectedWorkout.wExercises.count == 0 {
                EmptyStateInfoView(title: NSLocalizedString("kInfoMsgNoExercisesAddedTitle", comment: "Info messages"), message: NSLocalizedString("kInfoMsgNoExercisesAddedMessage", comment: "Info messages"))
            }
            List {
                ForEach(selectedWorkout.wExercises) { exercise in
                    ExerciseRow(exercise: exercise, selectedWorkout: selectedWorkout).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
                }
                .onDelete { (indexSet) in
                    if let index = indexSet.first, index < self.selectedWorkout.wExercises.count {
                        self.deleteIndex = index
                        self.shouldShowDeleteConfirmation.toggle()
                    }
                }
                .onMove { (indexSet, index) in
                    self.move(from: indexSet, to: index)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(trailing:
                                    HStack(spacing: 20) {
                                        EditButton()
                                        Button(action: {
                                            self.shouldPresentAddNewExercise.toggle()
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(kPrimaryTitleFont)
                                                .foregroundColor(appSettings.themeColorView())
                                        }.sheet(isPresented: $shouldPresentAddNewExercise) {
                                            AddExercise(shouldPresentAddNewExercise: self.$shouldPresentAddNewExercise, selectedWorkout: self.selectedWorkout).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
                                        }
                                    }
            )
            
        }
        .onAppear {
            kAppDelegate.removeSeparatorLineAppearance()
        }
        .alert(isPresented: $shouldShowDeleteConfirmation, content: { () -> Alert in
            Alert(title: Text("kAlertTitleConfirm"), message: Text("kAlertMsgDeleteExercise"), primaryButton: .cancel(), secondaryButton: .destructive(Text("kButtonTitleDelete"), action: {
                withAnimation {
                    if self.deleteIndex != kCommonListIndex {
                        self.deleteExercise(exercise: self.selectedWorkout.wExercises[self.deleteIndex])
                    }
                }
            }))
        })
        .navigationBarTitle(Text(selectedWorkout.wName))
    }
    
    /**Deletes the given exercise*/
    func deleteExercise(exercise: Exercise) {
        managedObjectContext.delete(exercise)
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    private func move( from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [Exercise] = selectedWorkout.wExercises
        print(revisedItems.forEach({ print("\($0.wName) \($0.displayOrder)") }))
        
        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)
        
        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[ reverseIndex ].displayOrder = Int16(reverseIndex)
        }
        
        print(revisedItems.forEach({ print("\($0.wName) \($0.displayOrder)") }))
        selectedWorkout.exercises = NSSet(array: revisedItems)
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
}

struct WorkoutDetail_Previews: PreviewProvider {
    static var previews: some View {
        Text("kPreviewYtb")
    }
}
