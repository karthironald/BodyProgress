//
//  Extensions.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 27/04/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

extension Int16 {
    
    func displayDuration() -> String {
        let duration = self
        return "\(String(format: "%02d", duration / kOneHour)):\(String(format: "%02d", (duration % kOneHour) / kOneMinute)):\(String(format: "%02d", (duration % kOneHour) % kOneMinute))"
    }
    
    func speechDuration() -> String {
        let duration = self
        let hours = duration / kOneHour
        let minutes = (duration % kOneHour) / kOneMinute
        var hourString = ""
        var minuteString = ""
        
        if hours > 0 {
            if hours == 1 {
                hourString.append("\(hours) hour")
            } else {
                hourString.append("\(hours) hours")
            }
        }
        if minutes > 0 {
            if minutes == 1 {
                minuteString.append("\(minutes) minute")
            } else {
                minuteString.append("\(minutes) minutes")
            }
        }
        let sample: [String] = [hourString, minuteString]
        return sample.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func detailedDisplayDuration(shouldIncludeSeconds: Bool = true) -> String {
        let duration = self
        let hours = duration / kOneHour
        let minutes = (duration % kOneHour) / kOneMinute
        let seconds = (duration % kOneHour) % kOneMinute
        var hourString = ""
        var minuteString = ""
        var secondsString = ""
        
        if hours > 0 {
            hourString.append("\(hours)h")
        }
        if minutes > 0 {
            minuteString.append("\(minutes)m")
        }
        if seconds > 0 {
            secondsString.append("\(seconds)s")
        }
        let sample: [String] = [hourString, minuteString, secondsString]
        return sample.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}

extension DateFormatter {
    
    var appDormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    
}

public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
