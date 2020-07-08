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
        
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
            if enabledReminder {
                NotificationHelper.addLocalNoification(at: notificationTime)
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
            NotificationHelper.addLocalNoification(at: notificationTime)
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
    
    init() {
        self.userName = AppSettings.userName()
        self.enabledReminder =  UserDefaults.standard.value(forKey: "enabledReminder") as? Bool ?? false
        self.notificationTime = UserDefaults.standard.value(forKey: "notificationTime") as? Date ?? Date().advanced(by: 3600)
        self.themeColorIndex = UserDefaults.standard.value(forKey: "themeColorIndex") as? Int ?? 0
        self.enabledHaptic = AppSettings.isHapticEnabled()
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
