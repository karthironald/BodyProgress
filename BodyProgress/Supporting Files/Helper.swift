//
//  Helper.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 31/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

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
        if let count = checkWorkoutsCount(), count > 0 {
            return
        }
        let appSettings = AppSettings()
        
        if !appSettings.addedDefaultWorkouts {
            let exampleWorkouts = ["Sample workout"]
            let exampleExercises = [["Sample exercise"]]
            
            let moc = kAppDelegate.persistentContainer.viewContext
            
            for (index, eWorkout) in exampleWorkouts.enumerated() {
                let workout = Workout(context: moc)
                workout.name = eWorkout
                workout.notes = "\"This is the sample workout to get the taste of this tracker app. Delete this workout and configure your workouts and exercises to get started.\""
                workout.bodyPart = BodyParts.arms.rawValue
                workout.id = UUID()
                workout.createdAt = Date()
                if index == 0 {
                    workout.isFavourite = true
                }
                workout.updatedAt = Date()
                
                for (_, name) in exampleExercises[index].enumerated() {
                    let exercise = Exercise(context: moc)
                    exercise.name = name
                    exercise.bodyPart = workout.bodyPart
                    exercise.id = UUID()
                    exercise.createdAt = Date()
                    exercise.updatedAt = Date()
                    
                    for j in 1...3 {
                        let newExerciseSet = ExerciseSet(context: moc)
                        newExerciseSet.name = "Set \(j)"
                        newExerciseSet.id = UUID()
                        newExerciseSet.createdAt = Date()
                        newExerciseSet.updatedAt = Date()
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
    
    /**Check and sends count of workouts count*/
    class func checkWorkoutsCount() -> Int? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Workout.entity().name ?? "Workout")
        do {
            let count = try kAppDelegate.persistentContainer.viewContext.count(for: fetchRequest)
            return count
        } catch {
            return nil
        }
    }
    
    class func startDate(from daysAgo: Int) -> (startDate: Date?, endDate: Date?) {
        let now = Date()
        
        var startDate: Date?
        
        // Get end of the end date
        var endDate = Calendar.current.date(byAdding: .day, value: -1, to: now)
        endDate = Calendar.current.startOfDay(for: endDate!)
        
        var components = DateComponents()
        components.day = 1
        components.second = -1
        endDate = Calendar.current.date(byAdding: components, to: endDate!)
        
        if daysAgo > 0 && daysAgo != kTimePeriodAllOptionValue {
            startDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: now)
            startDate = Calendar.current.startOfDay(for: startDate!) // Get start of the start date.
        }
        
        return (startDate, endDate)
    }
    
}
