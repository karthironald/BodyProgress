//
//  Exercise+CoreDataProperties.swift
//  
//
//  Created by Karthick Selvaraj on 30/07/20.
//
//

import Foundation
import CoreData


extension Exercise: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var actualRestDuration: Int16
    @NSManaged public var actualTotalDuration: Int16
    @NSManaged public var bodyPart: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var displayOrder: Int16
    @NSManaged public var expectedRestDuration: Int16
    @NSManaged public var expectedTotalDuration: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var isFavourite: Bool
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var exerciseSets: NSSet?
    @NSManaged public var references: NSSet?
    @NSManaged public var workout: Workout?

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
    var wReferences: [ReferenceLinks] {
        let set = references as? Set<ReferenceLinks> ?? []
        return set.sorted {
            $0.createdAt ?? Date() < $1.createdAt ?? Date()
        }
    }
    
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

// MARK: Generated accessors for references
extension Exercise {

    @objc(addReferencesObject:)
    @NSManaged public func addToReferences(_ value: ReferenceLinks)

    @objc(removeReferencesObject:)
    @NSManaged public func removeFromReferences(_ value: ReferenceLinks)

    @objc(addReferences:)
    @NSManaged public func addToReferences(_ values: NSSet)

    @objc(removeReferences:)
    @NSManaged public func removeFromReferences(_ values: NSSet)

}
