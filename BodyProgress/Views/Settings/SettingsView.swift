//
//  SettingsView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 04/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

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
        self.notificationTime = UserDefaults.standard.value(forKey: "notificationTime") as? Date ?? Date().advanced(by: 3600)
        self.themeColorIndex = UserDefaults.standard.value(forKey: "themeColorIndex") as? Int ?? 0
        self.enabledHaptic = UserDefaults.standard.value(forKey: "enabledHaptic") as? Bool ?? true
    }
    
    
    // MARK: - Custom methods
    class func isHapticEnabled() -> Bool {
        UserDefaults.standard.value(forKey: "enabledHaptic") as? Bool ?? true
    }
    
    func themeColorView() -> Color { Color(AppThemeColours.allCases[themeColorIndex].uiColor()) }
    
}

struct SettingsView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @State private var forceRender = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Reminder")) {
                    DatePicker("Remind me daily at", selection: $appSettings.notificationTime, displayedComponents: .hourAndMinute)
                        .accentColor(appSettings.themeColorView())
                }
                Section(header: Text("Theme Color")) {
                    HStack() {
                        ForEach(0..<AppThemeColours.allCases.count, id: \.self) { index in
                            Button(action: {
                                self.appSettings.themeColorIndex = index
                            }) {
                                Circle()
                                    .fill(Color(AppThemeColours.allCases[index].uiColor()))
                                    .overlay(
                                        Group {
                                            if index == self.appSettings.themeColorIndex {
                                                Image(systemName: "checkmark.circle.fill")
                                                .imageScale(.medium)
                                                .foregroundColor(.white)
                                            }
                                        }
                                    )
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                Section(header: Text("Haptic")) {
                    Toggle(isOn: $appSettings.enabledHaptic) {
                        Text("Enable haptic feedback")
                    }
                    .accentColor(forceRender ? appSettings.themeColorView() : .blue)
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
