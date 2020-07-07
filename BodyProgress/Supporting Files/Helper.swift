//
//  Helper.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 31/05/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import UIKit
import AVFoundation

class Helper: NSObject {
    
    class func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .rigid) {
        if AppSettings.isHapticEnabled() {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
 
    class func informDuration(duration: Int16) {
        let minutes = Int16(duration / 60)
        let seconds = Int16(duration % 60)
        
        print("\(minutes) \(seconds)")
        
        if seconds == 0 && minutes > 0 && minutes % 10 == 0 {
            let speechText = duration.speechDuration()
            speak(word: speechText)
        }
    }
    
    /**Speaks given string as audio. Not using this currently, need to use it soon*/
    class func speak(word: String) {
        let utterance = AVSpeechUtterance(string: word)
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
}
