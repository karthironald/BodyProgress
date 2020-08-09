//
//  Helper.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 31/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import UIKit
import AVFoundation

class Helper: NSObject {
    
    class func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .rigid) {
        if AppSettings.isHapticEnabled() {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
 
    class func informDuration(duration: Int16) {
        let minutes = Int16(duration / 60)
        let seconds = Int16(duration % 60)
        
        print("\(minutes) \(seconds)")
        
        if seconds == 0 && minutes > 0 && minutes % 10 == 0 {
            let speechText = duration.speechDuration()
            speak(word: speechText)
        }
    }
    
    /**Speaks given string as audio. Not using this currently, need to use it soon*/
    class func speak(word: String) {
        let utterance = AVSpeechUtterance(string: word)
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
 
    class func createDefaultWorkouts() {
    
        let appSettings = AppSettings()
        if !appSettings.addedDefaultWorkouts {
            let exampleWorkouts = ["Bicpes", "Chest"]
            let exampleExercises = [["Concentration curls", "Hammer curls", "Barbell curls", "Dumbbell curls"], ["BB incline bench press", "Barbell bench press", "Dumbbell fly", "Dumbbell bench press"]]
            
            let moc = kAppDelegate.persistentContainer.viewContext
            
            for (index, eWorkout) in exampleWorkouts.enumerated() {
                let workout = Workout(context: moc)
                workout.name = eWorkout
                workout.notes = "\"This is the example workout\"."
                workout.bodyPart = (index == 0) ? BodyParts.arms.rawValue : BodyParts.chest.rawValue
                workout.id = UUID()
                workout.createdAt = Date().advanced(by: TimeInterval.random(in: 10...100))
                workout.updatedAt = Date().advanced(by: TimeInterval.random(in: 10...100))
                
                for (_, name) in exampleExercises[index].enumerated() {
                    let exercise = Exercise(context: moc)
                    exercise.name = name
                    exercise.bodyPart = workout.bodyPart
                    exercise.id = UUID()
                    exercise.createdAt = Date().advanced(by: TimeInterval.random(in: 10...100))
                    exercise.updatedAt = Date().advanced(by: TimeInterval.random(in: 10...100))
                    
                    for j in 1...3 {
                        let newExerciseSet = ExerciseSet(context: moc)
                        newExerciseSet.name = "Set \(j)"
                        newExerciseSet.id = UUID()
                        newExerciseSet.createdAt = Date().advanced(by: TimeInterval.random(in: 10...100))
                        newExerciseSet.updatedAt = Date().advanced(by: TimeInterval.random(in: 10...100))
                        newExerciseSet.weight = Double(5 * j)
                        newExerciseSet.reputation = 12
                        
                        exercise.addToExerciseSets(newExerciseSet)
                    }
                    
                    workout.addToExercises(exercise)
                }
                if moc.hasChanges {
                    do {
                        try moc.save()
                        appSettings.addedDefaultWorkouts = true
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
