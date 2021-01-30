//
//  ExerciseSetsList.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

enum BulkUpdateType: String, CaseIterable {
    case weight = "weight"
    case reps = "reps"
}

struct ExerciseSetsList: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var selectedExercise: Exercise
    
    @State private var shouldPresentAddNewExerciseSet = false
    @State private var shouldShowDeleteConfirmation = false
    @State private var deleteIndex = kCommonListIndex
    
    @State private var shouldShowBulkUpdateView = false
    @State private var weight: Double = 0
    @State private var reputation: Double = 0
    
    var body: some View {
        ZStack {
            if selectedExercise.wExerciseSets.count == 0 {
                EmptyStateInfoView(title: NSLocalizedString("kInfoMsgNoExercisesSetsAddedTitle", comment: "Info message"), message: NSLocalizedString("kInfoMsgNoExercisesSetsAddedMessage", comment: "Info message"))
            }
            List {
                ForEach(selectedExercise.wExerciseSets) { exerciseSet in
                    ExerciseSetRow(selectedExercise: selectedExercise, exerciseSet: exerciseSet).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
                }
                .onDelete { (indexSet) in
                    if let index = indexSet.first, index < self.selectedExercise.wExerciseSets.count {
                        self.deleteIndex = index
                        self.shouldShowDeleteConfirmation.toggle()
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle(selectedExercise.wName)
            .navigationBarItems(trailing:
                                    HStack(spacing: 10) {
                                        Button(action: {
                                            self.reputation = 0
                                            self.weight = 0
                                            withAnimation(.spring()) {
                                                self.shouldShowBulkUpdateView.toggle()
                                            }
                                        }) {
                                            Text(shouldShowBulkUpdateView ? "Cancel" : "Bulk Update")
                                        }
                                        Button(action: {
                                            self.shouldPresentAddNewExerciseSet.toggle()
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(kPrimaryTitleFont)
                                                .foregroundColor(appSettings.themeColorView())
                                        }
                                    }
                                    .frame(width: 150, height: 30, alignment: .trailing)
                                    .sheet(isPresented: $shouldPresentAddNewExerciseSet) {
                                        AddExerciseSet(shouldPresentAddNewExerciseSet: self.$shouldPresentAddNewExerciseSet, selectedExercise: self.selectedExercise).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)
                                    }
            )
            
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Rep: \(Int(reputation))")
                    Slider(value: $reputation, in: -20...20, step: 1)
                }
                .padding([.top, .bottom])
                VStack(alignment: .leading, spacing: 0) {
                    Text("Weight: \(Int(weight)) kgs")
                    Slider(value: $weight, in: -20...20, step: 1)
                }
                HStack(spacing: 10) {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.shouldShowBulkUpdateView.toggle()
                        }
                    }) {
                        Text("Cancel")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    Button(action: {
                        proceedBulkUpdate()
                    }) {
                        CustomBarButton(title: NSLocalizedString("kButtonTitleSave", comment: "Button title"))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(25)
            .padding()
            .offset(y: shouldShowBulkUpdateView ? UIScreen.main.bounds.height * 0.20 : UIScreen.main.bounds.height)
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
    
    func proceedBulkUpdate() {
        if weight != 0 {
            selectedExercise.exerciseSets?.forEach({ (exSet) in
                (exSet as? ExerciseSet)?.weight += weight
            })
        }
        if reputation != 0 {
            selectedExercise.exerciseSets?.forEach({ (exSet) in
                (exSet as? ExerciseSet)?.reputation += Int16(reputation)
            })
        }
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Do nothing
            }
            withAnimation(.spring()) { shouldShowBulkUpdateView = false }
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
