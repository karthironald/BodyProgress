//
//  Constant.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 25/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

let kShadowRadius: CGFloat = 3.0
let kCornerRadius: CGFloat = 15.0
let kDefaultValue = "-"
let kCommonListIndex = 9999
let kOneHour: Int16 = 3600
let kOneMinute: Int16 = 60

let kPrimaryTitleFont = Font.system(.title, design: .rounded)
let kPrimaryLargeTitleFont = Font.system(.largeTitle, design: .rounded)
let kPrimaryBodyFont = Font.system(.body, design: .rounded)
let kPrimaryHeadlineFont = Font.system(.headline, design: .rounded)
let kPrimarySubheadlineFont = Font.system(.subheadline, design: .rounded)
let kPrimaryFootnoteFont = Font.system(.footnote, design: .rounded)
let kPrimaryCalloutFont = Font.system(.callout, design: .rounded)
let kPrimaryCaptionFont = Font.system(.caption, design: .rounded)

let kPrimaryListCellOpacity = 0.2
let kPrimaryBackgroundColour = Color.secondary.opacity(kPrimaryListCellOpacity)
let kFavStarColour = Color.yellow

let kCommonUserName = "Fitness Freak"

enum BodyParts: String, CaseIterable {
    case arms = "Arms"
    case chest = "Chest"
    case shoulders = "Shoulders"
    case abs = "Abs"
    case back = "Back"
    case legs = "Leg"
    case core = "Core"
    case fullBody = "Full Body"
    case cardio = "Cardio"
    case others = "Others"
    
    // We need to use different colours in for each body type in future
    func color() -> Color {
        switch self {
        case .core, .cardio, .others: return Color.secondary.opacity(kPrimaryListCellOpacity)
        case .arms: return Color.secondary.opacity(kPrimaryListCellOpacity)
        case .back: return Color.secondary.opacity(kPrimaryListCellOpacity)
        case .chest: return Color.secondary.opacity(kPrimaryListCellOpacity)
        case .legs: return Color.secondary.opacity(kPrimaryListCellOpacity)
        case .shoulders: return Color.secondary.opacity(kPrimaryListCellOpacity)
        case .abs: return Color.secondary.opacity(kPrimaryListCellOpacity)
        case .fullBody: return Color.secondary.opacity(kPrimaryListCellOpacity)
        }
    }
    
    func piechartColor() -> Color {
        switch self {
        case .arms: return Color(.systemGreen)
        case .back: return Color(.systemBlue)
        case .chest: return Color(.systemRed)
        case .legs: return Color(.systemYellow)
        case .shoulders: return Color(.systemOrange)
        case .abs: return Color(.systemPurple)
        case .fullBody: return Color(.systemIndigo)
        case .others: return Color(.systemGray)
        case .core: return Color(.systemTeal)
        case .cardio: return Color(.systemGray2)
        }
    }
}
