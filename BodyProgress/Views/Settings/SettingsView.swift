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
    @State private var forceRender = true // We need this for allowing user to change the app theme color. Currently not using it.
    
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
                Section {
                    ZStack {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.clear)
                        if forceRender {
                            Toggle(isOn: $appSettings.enabledReminder.animation()) {
                                Text("Workout Reminder")
                            }
                        }
                    }
                    if appSettings.enabledReminder {
                        DatePicker("Remind me daily at", selection: $appSettings.notificationTime, displayedComponents: .hourAndMinute)
                        .foregroundColor(.secondary)
                        .accentColor(appSettings.themeColorView())
                    }
                }
                
                Section(footer: Text("Rest timer will start automatically as soon as you mark a set as completed")) {
                    Toggle(isOn: $appSettings.shouldAutoStartRestTimer.animation()) {
                        Text("Auto Rest Timer")
                    }
                    if appSettings.shouldAutoStartRestTimer {
                        Stepper(value: $appSettings.workoutTimerInterval) {
                            Text("Rest duration")
                                .foregroundColor(.secondary)
                            Text("\(Int(appSettings.workoutTimerInterval)) Secs")
                                .modifier(CustomInfoTextStyle(appSettings: appSettings))
                        }
                    }
                }
                
                // Don't need this theme changing option
                
//                Section(header: Text("Theme Color")) {
//                    HStack() {
//                        ForEach(0..<AppThemeColours.allCases.count, id: \.self) { index in
//                            Button(action: {
//                                self.appSettings.themeColorIndex = index
//                                self.forceRender = false
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                    self.forceRender = true
//                                }
//                            }) {
//                                Circle()
//                                    .fill(Color(AppThemeColours.allCases[index].uiColor()))
//                                    .overlay(
//                                        Group {
//                                            if index == self.appSettings.themeColorIndex {
//                                                Image(systemName: "checkmark.circle.fill")
//                                                .imageScale(.medium)
//                                                .foregroundColor(.white)
//                                            }
//                                        }
//                                    )
//                            }
//                            .buttonStyle(BorderlessButtonStyle())
//                        }
//                    }
//                }
                
                
                
                Section {
                    if forceRender {
                        Toggle(isOn: $appSettings.enabledHaptic) {
                            Text("Haptic Feedback")
                        }
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
    }
    
    #warning("Need to use this share option soon")
    func actionSheet() {
        guard let data = URL(string: "https://www.apple.com") else { return }
        let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AppSettings())
    }
}
