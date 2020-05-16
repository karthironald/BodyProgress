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
    
    func detailedDisplayDuration() -> String {
        let duration = self
        let hours = duration / kOneHour
        let minutes = (duration % kOneHour) / kOneMinute
        let seconds = (duration % kOneHour) % kOneMinute
        var hourString = ""
        var minuteString = ""
        var secondsString = ""
        
        if hours > 0 {
            hourString.append("\(hours)")
            hourString.append(" \(hours == 1 ? "hr" : "hrs")")
        }
        if minutes > 0 {
            minuteString.append("\(minutes)")
            minuteString.append(" \(minutes == 1 ? "mnt" : "mnts")")
        }
        if seconds > 0 {
            secondsString.append("\(seconds)")
            secondsString.append(" \(seconds == 1 ? "sec" : "secs")")
        }
        let sample: [String] = [hourString, minuteString, secondsString]
        return sample.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
