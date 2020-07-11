//
//  WorkoutHistory+CoreDataProperties.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 13/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//
//

import Foundation
import CoreData


extension WorkoutHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutHistory> {
        return NSFetchRequest<WorkoutHistory>(entityName: "WorkoutHistory")
    }

    @NSManaged public var bodyPart: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var imagePath: String?
    @NSManaged public var isFavourite: Bool
    @NSManaged public var lastTrainedAt: Date?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var duration: Int16
    @NSManaged public var status: Bool
    @NSManaged public var exercises: NSSet?
    @NSManaged public var workout: Workout?

    var wName: String { name ?? kDefaultValue }
    var wNotes: String { notes ?? kDefaultValue }
    var wCreatedAt: Date { createdAt ?? Date() }
    var wUpdatedAt: Date { updatedAt ?? Date() }
    var wId: UUID { id ?? UUID() }
    var wLastTrainedAt: Date { lastTrainedAt ?? Date() }
    var wImagePath: String { imagePath ?? kDefaultValue }
    var wDeletedAt: Date { deletedAt ?? Date() }
    var wIsFavourite: Bool { isFavourite }
    var wBodyPart: BodyParts { BodyParts(rawValue: bodyPart ?? kDefaultValue) ?? BodyParts.others }
    var wExercises: [ExerciseHistory] {
        let set = exercises as? Set<ExerciseHistory> ?? []
        return set.sorted {
            $0.createdAt ?? Date() < $1.createdAt ?? Date()
        }
    }
    var wDuration: Int16 { duration }
    var wStatus: Bool { status }
    var wWorkout: Workout { workout ?? Workout() }
    
    /**Check whether all sets are completed*/
    func isAllSetCompleted() -> Bool {
        for exercise in wExercises {
            for sets in exercise.wExerciseSets {
                if sets.wStatus == false {
                    return false
                }
            }
        }
        return true
    }
    
}

// MARK: Generated accessors for exercises
extension WorkoutHistory {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: ExerciseHistory)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: ExerciseHistory)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSSet)

}

extension WorkoutHistory {
    
    static func fetchSum(context: NSManagedObjectContext, completion: @escaping ([(sum: Double, bodyPart: BodyParts)]) -> ()) {
        
        let keypathDuration = NSExpression(forKeyPath: \WorkoutHistory.duration)
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathDuration])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer16AttributeType
        
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: WorkoutHistory.entity().name ?? "WorkoutHistory")
        req.returnsObjectsAsFaults = false
        req.propertiesToGroupBy = ["bodyPart"]
        req.propertiesToFetch = [sumDesc, "bodyPart"]
        req.resultType = .dictionaryResultType
        
        context.perform {
            do {
                let results = try req.execute()
                let data = results.map { (result) -> (Double, BodyParts)? in
                    guard let resultDict = result as? [String: Any], let amount = resultDict["sum"] as? Double, amount > 0.0, let bodyPart = resultDict["bodyPart"] as? String else { return nil }
                    let part = BodyParts(rawValue: bodyPart) ?? BodyParts.others
                    return (amount, part)
                }.compactMap { $0 }
                completion(data.sorted { $0.0 > $1.0 })
            } catch {
                print((error.localizedDescription))
                completion([])
            }
        }
    }
}
