//
//  SettingsView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 04/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @State private var forceRender = true
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack(spacing: 30) {
                        Text("Name")
                        TextField("Fitness Freak", text: $appSettings.userName)
                            .multilineTextAlignment(.trailing)
                            
                    }
                }
                Section(header: Text("Workout Reminder")) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.clear)
                        if forceRender {
                            Toggle(isOn: $appSettings.enabledReminder) {
                                Text("Reminder")
                            }
                        }
                    }
                    if appSettings.enabledReminder {
                        DatePicker("Remind me daily at", selection: $appSettings.notificationTime, displayedComponents: .hourAndMinute)
                        .accentColor(appSettings.themeColorView())
                    }
                }
                Section(header: Text("Theme Color")) {
                    HStack() {
                        ForEach(0..<AppThemeColours.allCases.count, id: \.self) { index in
                            Button(action: {
                                self.appSettings.themeColorIndex = index
                                self.forceRender = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.forceRender = true
                                }
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
                    if forceRender {
                        Toggle(isOn: $appSettings.enabledHaptic) {
                            Text("Enable haptic feedback")
                        }
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AppSettings())
    }
}
