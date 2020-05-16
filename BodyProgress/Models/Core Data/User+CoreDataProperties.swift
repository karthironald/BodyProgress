//
//  User+CoreDataProperties.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 03/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var dob: Date?
    @NSManaged public var gender: String?
    @NSManaged public var height: Double
    @NSManaged public var mass: Double
    @NSManaged public var id: UUID?

    var wFirstName: String { firstName ?? kDefaultValue }
    var wLastName: String { lastName ?? kDefaultValue }
    var wDob: Date { dob ?? Date() }
    var wGender: String { gender ?? kDefaultValue }
    var wHeight: Double { height }
    var wMass: Double  { mass }
    var wId: UUID? { id ?? UUID() }
    
}
