//
//  RestTimerView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 09/08/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import Combine

enum RestTimerStatus {
    case notStarted, playing, paused
}

struct RestTimerView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @State private var offset: CGFloat = 70
    @State private var completedTime: TimeInterval = 0
    @State private var shouldShowMenus = false
    @State private var status: RestTimerStatus = .notStarted
    @State private var timer = Timer.publish(every: 5000, on: .main, in: .common).autoconnect() // Dummy initialiser with summy TimeInterval
    @State private var backgroundAt = Date()
    @Binding var alignment: Alignment
    
    var progress: CGFloat {
        CGFloat((appSettings.workoutTimerInterval - completedTime) / appSettings.workoutTimerInterval)
    }
    
    var body: some View {
        ZStack {
            
            Button(action: {
                Helper.hapticFeedback()
                self.shouldShowMenus.toggle()
                self.alignment = shouldShowMenus ? .center : .bottomLeading
            }) {
                Image(systemName: shouldShowMenus ? "xmark" : "timer")
                    .font(kPrimaryTitleFont)
                    .frame(width: 50, height: 50)
                    .background(shouldShowMenus ? Color(.lightGray) : appSettings.themeColorView())
                    .foregroundColor(shouldShowMenus ? .secondary : .white)
                    .clipShape(Circle())
            }
            .shadow(radius: 5)
            .zIndex((status == .playing || status == .paused) ? 0 : 10)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { (_) in
                self.stopTimer()
                self.backgroundAt = Date()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { (_) in
                if self.status == .playing {
                    let backgroundInterval = TimeInterval(Int(Date().timeIntervalSince(self.backgroundAt) + 1))
                    
                    if (self.completedTime + backgroundInterval) >= (self.appSettings.workoutTimerInterval - 1) {
                        self.resetDetails()
                    } else {
                        self.completedTime += backgroundInterval
                        self.startTimer()
                    }
                }
            }

            if status != .playing {
                Button(action: {
                    Helper.hapticFeedback(style: .soft)
                    if self.appSettings.workoutTimerInterval > 5 {
                        self.appSettings.workoutTimerInterval = self.appSettings.workoutTimerInterval - 5
                    }
                }) {
                    Image(systemName: "minus")
                        .timerControlStyle(backgroundColor: Color.blue)
                }
                .shadow(radius: shouldShowMenus ? 5 : 0)
                .offset(x: shouldShowMenus ? offset : 0)
                .animation(.spring())
                
                Button(action: {
                    Helper.hapticFeedback(style: .soft)
                    self.appSettings.workoutTimerInterval = self.appSettings.workoutTimerInterval + 5
                }) {
                    Image(systemName: "plus")
                        .timerControlStyle(backgroundColor: Color.blue)
                }
                .shadow(radius: shouldShowMenus ? 5 : 0)
                .offset(x: shouldShowMenus ? offset * 2 : 0)
                .animation(.spring())
            }

            if status == .playing {
                Button(action: {
                    Helper.hapticFeedback()
                    self.resetDetails()
                    NotificationHelper.resetTimerNotification()
                }) {
                    Image(systemName: "stop")
                        .timerControlStyle(backgroundColor: Color.red)
                }
                .shadow(radius: shouldShowMenus ? 5 : 0)
                .offset(x: shouldShowMenus ? offset : 0)
                .animation(.spring())
            }
            
            
            Button(action: {
                Helper.hapticFeedback()
                self.shouldShowMenus.toggle()
            }) {
                Text("\((Int(appSettings.workoutTimerInterval - completedTime) == 0) ? Int(appSettings.workoutTimerInterval) : Int(appSettings.workoutTimerInterval - completedTime))s")
                    .font(kPrimaryBodyFont)
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(appSettings.themeColorView())
                    .clipShape(Circle())
            }
            .padding(10)
            .overlay(
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(appSettings.themeColorView(), style: StrokeStyle(lineWidth: (status == .playing || status == .paused) ? 7 : 0, lineCap: .round))
                    .animation(Animation.linear(duration: 1))
                    .rotationEffect(.degrees(-90))
            )
            .shadow(radius: shouldShowMenus ? 5 : 0)
            .offset(y: shouldShowMenus ? -offset * 2 : 0)
            .animation(.spring())
            .zIndex((status == .playing || status == .paused) ? 10 : 0)
            
            
            Button(action: {
                Helper.hapticFeedback()
                if self.status == .playing {
                    self.status = .paused
                } else if self.status == .paused || self.status == .notStarted {
                    self.status = .playing
                }
                if self.status == .playing {
                    self.startTimer()
                    NotificationHelper.addLocalNoification(type: .interval(TimeInterval(self.appSettings.workoutTimerInterval - self.completedTime)))
                } else if self.status == .paused {
                    self.stopTimer()
                    NotificationHelper.resetTimerNotification()
                }
            }) {
                Image(systemName: (status == .playing) ? "pause" : "play")
                    .imageScale(.large)
                    .frame(width: 50, height: 50)
                    .background(appSettings.themeColorView())
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .shadow(radius: shouldShowMenus ? 5 : 0)
            .offset(y: shouldShowMenus ? -offset : 0)
            .animation(.spring())
            
        }
        .padding(.leading, (status == .playing || status == .paused) ? 20 : 10)
        .onReceive(timer, perform: { (_) in
            if self.status == .playing {
                self.completedTime += 1
                if self.completedTime >= self.appSettings.workoutTimerInterval - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.resetDetails()
                    }
                }
            }
            print("⚠️ \(self.completedTime)")
        })
    }
    
    func resetDetails() {
        self.status = .notStarted
        self.stopTimer()
        self.completedTime = 0
        self.shouldShowMenus = false
    }
    
    func stopTimer() {
        self.timer.upstream.connect().cancel()
    }
    
    func startTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        RestTimerView(alignment: .constant(.bottomLeading)).environmentObject(AppSettings())
    }
}

struct TimerControlStyle: ViewModifier {
    
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(kPrimaryTitleFont)
            .frame(width: 50, height: 50)
            .background(backgroundColor)
            .foregroundColor(.white)
            .clipShape(Circle())
    }
}

extension View {
    
    func timerControlStyle(backgroundColor: Color) -> some View {
        self.modifier(TimerControlStyle(backgroundColor: backgroundColor))
    }
    
}
