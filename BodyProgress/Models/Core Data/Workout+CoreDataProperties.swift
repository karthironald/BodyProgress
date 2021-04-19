//
//  Workout+CoreDataProperties.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//
//

import Foundation
import CoreData


extension Workout: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }

    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var lastTrainedAt: Date?
    @NSManaged public var imagePath: String?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var isFavourite: Bool
    @NSManaged public var bodyPart: String?
    @NSManaged public var exercises: NSSet?

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
    var wExercises: [Exercise] {
        let set = exercises as? Set<Exercise> ?? []
        return set.sorted {
            $0.displayOrder < $1.displayOrder
        }
    }
    
    func lastTrainedAtString() -> String {
        if let lastTrainedAt = lastTrainedAt {
            let previousDate = lastTrainedAt
            let now = Date()

            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .full
            formatter.allowedUnits = [.day, .hour, .minute, .second]
            formatter.maximumUnitCount = 1

            return "\(formatter.string(from: previousDate, to: now) ?? "") ago" 
        }
        return ""
    }
}

// MARK: Generated accessors for exercises
extension Workout {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSSet)

}
