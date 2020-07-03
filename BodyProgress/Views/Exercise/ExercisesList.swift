//
//  ExercisesList.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 23/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct ExercisesList: View {
    
    @ObservedObject var selectedWorkout: Workout
    @State var shouldPresentAddNewExercise = false
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var shouldPresentEditExercise: Bool = false
    @State var editExerciseIndex: Int = kCommonListIndex
    
    @State var shouldShowDeleteConfirmation = false
    @State var deleteIndex = kCommonListIndex
    
    var body: some View {
        ZStack {
            if selectedWorkout.wExercises.count == 0 {
                EmptyStateInfoView(message: NSLocalizedString("kInfoMsgNoExercisesAdded", comment: "Info messages"))
            }
            VStack {
                List {
                    ForEach(0..<selectedWorkout.wExercises.count, id: \.self) { exerciseIndex in
                        ZStack {
                            ExerciseRow(exercise: self.selectedWorkout.wExercises[exerciseIndex])
                                .contextMenu {
                                    Button(action: {
                                        self.editExerciseIndex = exerciseIndex
                                        self.shouldPresentEditExercise = true
                                    }) {
                                        Image(systemName: "square.and.pencil")
                                        Text("kButtonTitleEdit")
                                    }
                                    Button(action: {
                                        withAnimation {
                                            self.toggleFav(exercise: self.selectedWorkout.wExercises[exerciseIndex])
                                        }
                                    }) {
                                        Image(systemName: self.selectedWorkout.wExercises[exerciseIndex].wIsFavourite  ? "star.fill" : "star")
                                        Text(self.selectedWorkout.wExercises[exerciseIndex].wIsFavourite  ? "kButtonTitleUnfavourite" : "kButtonTitleFavourite")
                                    }
                                    Button(action: {
                                        self.deleteIndex = exerciseIndex
                                        self.shouldShowDeleteConfirmation.toggle()
                                    }) {
                                        Image(systemName: "trash")
                                        Text("kButtonTitleDelete")
                                    }
                            }
                            NavigationLink(destination: ExerciseSetsList(selectedExercise: self.selectedWorkout.wExercises[exerciseIndex])) {
                                EmptyView()
                            }
                        }
                    }
                    .onDelete { (indexSet) in
                        if let index = indexSet.first, index < self.selectedWorkout.wExercises.count {
                            self.deleteIndex = index
                            self.shouldShowDeleteConfirmation.toggle()
                        }
                    }
                }
                .padding([.top, .bottom], 10)
                .sheet(isPresented: $shouldPresentEditExercise, content: {
                    AddExercise(shouldPresentAddNewExercise: self.$shouldPresentEditExercise, selectedWorkout: self.selectedWorkout, name: self.selectedWorkout.wExercises[self.editExerciseIndex].wName, notes: self.selectedWorkout.wExercises[self.editExerciseIndex].wNotes, selectedExercise: self.selectedWorkout.wExercises[self.editExerciseIndex]).environment(\.managedObjectContext, self.managedObjectContext)
                })
                    .navigationBarItems(trailing:
                        Button(action: {
                            self.shouldPresentAddNewExercise.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(kPrimaryTitleFont)
                                .foregroundColor(kPrimaryColour)
                        }.sheet(isPresented: $shouldPresentAddNewExercise) {
                            AddExercise(shouldPresentAddNewExercise: self.$shouldPresentAddNewExercise, selectedWorkout: self.selectedWorkout).environment(\.managedObjectContext, self.managedObjectContext)
                        }
                )
            }
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
    
    /**Toggles the favourite status of the exercise*/
    func toggleFav(exercise: Exercise) {
        exercise.isFavourite.toggle()
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
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
    
}

struct WorkoutDetail_Previews: PreviewProvider {
    static var previews: some View {
        Text("kPreviewYtb")
    }
}
