//
//  AppSettings.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 07/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import Foundation
import SwiftUI

enum AppThemeColours: String, CaseIterable {
    case green = "systemGreen"
    case red = "systemRed"
    case orange = "systemOrange"
    case blue = "systemBlue"
    case yellow = "systemYellow"
    case indigo = "systemIndigo"
    
    func uiColor() -> UIColor {
        switch self {
        case .green: return UIColor.systemGreen
        case .red: return UIColor.systemRed
        case .orange: return UIColor.systemOrange
        case .blue: return UIColor.systemBlue
        case .yellow: return UIColor.systemYellow
        case .indigo: return UIColor.systemIndigo
        }
    }
    
    func appIconName() -> String {
        switch self {
        case .green: return "GreenIcon"
        case .red: return "RedIcon"
        case .orange: return "OrangeIcon"
        case .blue: return "BlueIcon"
        case .yellow: return "YellowIcon"
        case .indigo: return "IndigoIcon"
        }
    }
    
}
class AppSettings: ObservableObject {
        
    @Published var addedDefaultWorkouts: Bool {
        didSet {
            UserDefaults.standard.set(addedDefaultWorkouts, forKey: "addedDefaultWorkouts")
        }
    }
    
    @Published var workoutTimerInterval: TimeInterval {
        didSet {
            UserDefaults.standard.set(workoutTimerInterval, forKey: "workoutTimerInterval")
        }
    }
    
    @Published var selectedTab: Int {
        didSet {
            UserDefaults.standard.set(selectedTab, forKey: "selectedTab")
        }
    }
    
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
            if enabledReminder {
                NotificationHelper.addLocalNoification(type: .date(notificationTime))
            }
        }
    }
        
    @Published var enabledReminder: Bool {
        didSet {
            UserDefaults.standard.set(enabledReminder, forKey: "enabledReminder")
            if enabledReminder {
                notificationTime = Date().advanced(by: 3600)
            } else {
                NotificationHelper.resetNotifications()
            }
        }
    }
    
    @Published var notificationTime: Date {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
            NotificationHelper.addLocalNoification(type: .date(notificationTime))
        }
    }
    
    @Published var enabledHaptic: Bool {
        didSet {
            UserDefaults.standard.set(enabledHaptic, forKey: "enabledHaptic")
        }
    }
    
    @Published var themeColorIndex: Int {
        didSet {
            UserDefaults.standard.set(themeColorIndex, forKey: "themeColorIndex")
            kAppDelegate.configureAppearances(color: AppThemeColours.allCases[themeColorIndex].uiColor())
            kAppDelegate.changeAppIcon(for: themeColorIndex)
        }
    }
    
    @Published var historySelectedBodyParts: [BodyParts] {
        didSet {
            let rawValues = historySelectedBodyParts.map { $0.rawValue }
            UserDefaults.standard.set(rawValues, forKey: "historySelectedBodyParts")
        }
    }
    
    @Published var referenceSelectedBodyParts: [BodyParts] {
        didSet {
            let rawValues = referenceSelectedBodyParts.map { $0.rawValue }
            UserDefaults.standard.set(rawValues, forKey: "referenceSelectedBodyParts")
        }
    }
    
    @Published var historySelectedCompletionStatus: WorkoutHistoryStatusSort {
        didSet {
            let rawValues = historySelectedCompletionStatus.rawValue
            UserDefaults.standard.set(rawValues, forKey: "historySelectedCompletionStatus")
        }
    }
    
    @Published var historySelectedTimePeriod: TimePeriod {
        didSet {
            let rawValues = historySelectedTimePeriod.rawValue
            UserDefaults.standard.set(rawValues, forKey: "historySelectedTimePeriod")
        }
    }

    @Published var shouldAutoStartRestTimer: Bool {
        didSet {
            UserDefaults.standard.set(shouldAutoStartRestTimer, forKey: "shouldAutoStartRestTimer")
        }
    }
    
    var isDBLocationMigrated: Bool {
        didSet {
            UserDefaults.standard.set(isDBLocationMigrated, forKey: "isDBLocationMigrated")
        }
    }
    
    init() {
        self.userName = AppSettings.userName()
        self.enabledReminder =  UserDefaults.standard.value(forKey: "enabledReminder") as? Bool ?? false
        self.notificationTime = UserDefaults.standard.value(forKey: "notificationTime") as? Date ?? Date().advanced(by: 3600)
        self.themeColorIndex = UserDefaults.standard.value(forKey: "themeColorIndex") as? Int ?? 0
        self.enabledHaptic = AppSettings.isHapticEnabled()
        
        let historyRawValues = UserDefaults.standard.value(forKey: "historySelectedBodyParts") as? [String] ?? BodyParts.allCases.map { $0.rawValue }
        self.historySelectedBodyParts = historyRawValues.map { (BodyParts(rawValue: $0) ?? BodyParts.others) }
        
        let referenceRawValues = UserDefaults.standard.value(forKey: "referenceSelectedBodyParts") as? [String] ?? BodyParts.allCases.map { $0.rawValue }
        self.referenceSelectedBodyParts = referenceRawValues.map { (BodyParts(rawValue: $0) ?? BodyParts.others) }
        
        let selectionRawValue = UserDefaults.standard.value(forKey: "historySelectedCompletionStatus") as? String ?? WorkoutHistoryStatusSort.Both.rawValue
        self.historySelectedCompletionStatus = WorkoutHistoryStatusSort(rawValue: selectionRawValue) ?? WorkoutHistoryStatusSort.Both
        
        let timePeriodSelectionRawValue = UserDefaults.standard.value(forKey: "historySelectedTimePeriod") as? Int ?? TimePeriod.last30Days.rawValue
        self.historySelectedTimePeriod = TimePeriod(rawValue: timePeriodSelectionRawValue) ?? TimePeriod.last30Days
        
        self.shouldAutoStartRestTimer =  UserDefaults.standard.value(forKey: "shouldAutoStartRestTimer") as? Bool ?? false
        
        self.selectedTab = UserDefaults.standard.value(forKey: "selectedTab") as? Int ?? 0
        self.workoutTimerInterval = UserDefaults.standard.value(forKey: "workoutTimerInterval") as? TimeInterval ?? 30
        self.addedDefaultWorkouts = UserDefaults.standard.value(forKey: "addedDefaultWorkouts") as? Bool ?? false
        self.isDBLocationMigrated = UserDefaults.standard.value(forKey: "isDBLocationMigrated") as? Bool ?? false
    }
    
    
    // MARK: - Custom methods
    class func isHapticEnabled() -> Bool {
        UserDefaults.standard.value(forKey: "enabledHaptic") as? Bool ?? true
    }
    
    class func userName() -> String {
        let name = UserDefaults.standard.value(forKey: "userName") as? String
        return name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    func themeColorView() -> Color { Color(AppThemeColours.allCases[themeColorIndex].uiColor()) }
    
}
