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
            hourString.append("\(hours) h")
        }
        if minutes > 0 {
            minuteString.append("\(minutes) m")
        }
        if seconds > 0 {
            secondsString.append("\(seconds) s")
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
