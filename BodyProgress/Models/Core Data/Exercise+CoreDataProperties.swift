//
//  Exercise+CoreDataProperties.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//
//

import Foundation
import CoreData


extension Exercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var expectedTotalDuration: Int16
    @NSManaged public var index: Int16
    @NSManaged public var actualTotalDuration: Int16
    @NSManaged public var expectedRestDuration: Int16
    @NSManaged public var actualRestDuration: Int16
    @NSManaged public var isFavourite: Bool
    @NSManaged public var bodyPart: String?
    @NSManaged public var workout: Workout?
    @NSManaged public var exerciseSets: NSSet?

    var wId: UUID { id ?? UUID() }
    var wName: String { name ?? kDefaultValue }
    var wNotes: String { notes ?? kDefaultValue }
    var wCreatedAt: Date { createdAt ?? Date() }
    var wUpdatedAt: Date { updatedAt ?? Date() }
    var wDeletedAt: Date { deletedAt ?? Date() }
    var wExpectedTotalDuration: Int16 { expectedTotalDuration }
    var wActualTotalDuration: Int16 { actualTotalDuration }
    var wExpectedRestDuration: Int16 { expectedRestDuration }
    var wActualRestDuration: Int16 { actualRestDuration }
    var wIsFavourite: Bool { isFavourite }
    var wBodyPart: BodyParts { BodyParts(rawValue: bodyPart ?? kDefaultValue) ?? BodyParts.others }
    var wWorkout: Workout { workout ?? Workout() }
    var wExerciseSets: [ExerciseSet] {
        let set = exerciseSets as? Set<ExerciseSet> ?? []
        return set.sorted {
            $0.createdAt ?? Date() < $1.createdAt ?? Date()
        }
    }
    var wIndex: Int16 { index }
    
}

// MARK: Generated accessors for exerciseSets
extension Exercise {

    @objc(addExerciseSetsObject:)
    @NSManaged public func addToExerciseSets(_ value: ExerciseSet)

    @objc(removeExerciseSetsObject:)
    @NSManaged public func removeFromExerciseSets(_ value: ExerciseSet)

    @objc(addExerciseSets:)
    @NSManaged public func addToExerciseSets(_ values: NSSet)

    @objc(removeExerciseSets:)
    @NSManaged public func removeFromExerciseSets(_ values: NSSet)

}
