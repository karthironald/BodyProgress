//
//  ExerciseHistory+CoreDataProperties.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 13/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//
//

import Foundation
import CoreData


extension ExerciseHistory: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseHistory> {
        return NSFetchRequest<ExerciseHistory>(entityName: "ExerciseHistory")
    }

    @NSManaged public var actualRestDuration: Int16
    @NSManaged public var actualTotalDuration: Int16
    @NSManaged public var bodyPart: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var expectedRestDuration: Int16
    @NSManaged public var expectedTotalDuration: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var isFavourite: Bool
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var exerciseSets: NSSet?
    @NSManaged public var references: NSSet?
    @NSManaged public var workout: WorkoutHistory?

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
    var wWorkout: WorkoutHistory { workout ?? WorkoutHistory() }
    var wExerciseSets: [ExerciseSetHistory] {
        let set = exerciseSets as? Set<ExerciseSetHistory> ?? []
        return set.sorted {
            $0.createdAt ?? Date() < $1.createdAt ?? Date()
        }
    }
    var wReferences: [ReferenceLinks] {
        let set = references as? Set<ReferenceLinks> ?? []
        return set.sorted {
            $0.createdAt ?? Date() < $1.createdAt ?? Date()
        }
    }
    
}

// MARK: Generated accessors for exerciseSets
extension ExerciseHistory {

    @objc(addExerciseSetsObject:)
    @NSManaged public func addToExerciseSets(_ value: ExerciseSetHistory)

    @objc(removeExerciseSetsObject:)
    @NSManaged public func removeFromExerciseSets(_ value: ExerciseSetHistory)

    @objc(addExerciseSets:)
    @NSManaged public func addToExerciseSets(_ values: NSSet)

    @objc(removeExerciseSets:)
    @NSManaged public func removeFromExerciseSets(_ values: NSSet)

}

// MARK: Generated accessors for references
extension ExerciseHistory {

    @objc(addReferencesObject:)
    @NSManaged public func addToReferences(_ value: ReferenceLinks)

    @objc(removeReferencesObject:)
    @NSManaged public func removeFromReferences(_ value: ReferenceLinks)

    @objc(addReferences:)
    @NSManaged public func addToReferences(_ values: NSSet)

    @objc(removeReferences:)
    @NSManaged public func removeFromReferences(_ values: NSSet)

}
