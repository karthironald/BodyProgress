//
//  NotificationHelper.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 04/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import UIKit

private let kLocalNotificationIdentifier = "kLocalNotificationIdentifier"

class NotificationHelper: NSObject {

    /**We need to post local notification for everyday at `kShiftStartTime`*/
    static private func configureLocalNotification(at hour: Int?, minute: Int?) {
        invalidateLocalNotification(with: [kLocalNotificationIdentifier])
        
        let centre = UNUserNotificationCenter.current()
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Hey, \(AppSettings.userName().isEmpty ? kCommonUserName : AppSettings.userName())!"
        notificationContent.body = "It's time to start your workout 💪🏻"
        
        notificationContent.sound = UNNotificationSound.default
        
        // Configure trigger time for posting the local notification
        var dateComponent = DateComponents()
        dateComponent.hour = hour
        dateComponent.minute = minute
        
        let triggerAt = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        
        let request = UNNotificationRequest(identifier: kLocalNotificationIdentifier, content: notificationContent, trigger: triggerAt)
        centre.add(request) { (error) in
            if error != nil {
                print(error ?? "")
            }
        }
    }
 
    /**Invalidate local notification which we configured in `configureLocalNotification()`*/
    static private func invalidateLocalNotification(with identifiers: [String]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    static func resetNotifications() {
        invalidateLocalNotification(with: [kLocalNotificationIdentifier])
    }
    
    static func addLocalNoification(at date: Date?) {
        if let date = date {
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            
            let userNotification = UNUserNotificationCenter.current()
            userNotification.getNotificationSettings { (setting) in
                if setting.authorizationStatus == .authorized {
                    NotificationHelper.configureLocalNotification(at: hour, minute: minute)
                } else {
                    registerForPushNotification(at: date)
                }
            }
            
        }
    }
    
    static private func registerForPushNotification(at date: Date?) {
        let userNotification = UNUserNotificationCenter.current()
        userNotification.requestAuthorization(options: [.sound, .badge, .alert]) { (status, error) in
            if status && error == nil {
                addLocalNoification(at: date)
            }
        }
    }
    
}
