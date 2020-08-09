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
    @State private var totalTime: TimeInterval = 5
    @State private var completedTime: TimeInterval = 0
    @State private var shouldShowMenus = false
    @State private var status: RestTimerStatus = .notStarted
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var progress: CGFloat {
        CGFloat((totalTime - completedTime) / totalTime)
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                self.shouldShowMenus.toggle()
            }) {
                Image(systemName: shouldShowMenus ? "xmark" : "timer")
                    .font(kPrimaryTitleFont)
                    .frame(width: 50, height: 50)
                    .background(shouldShowMenus ? Color.secondary : appSettings.themeColorView())
                    .foregroundColor(shouldShowMenus ? .secondary : .white)
                    .clipShape(Circle())
            }
            .shadow(radius: 5)
            .zIndex(10)
            
            Button(action: {
                if self.totalTime > 5 {
                    self.totalTime -= 5
                }
            }) {
                Image(systemName: "minus")
                    .font(kPrimaryTitleFont)
                    .frame(width: 50, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .shadow(radius: shouldShowMenus ? 5 : 0)
            .offset(y: shouldShowMenus ? offset : 0)
            .animation(.spring())
            
            Button(action: {
                self.totalTime += 5
            }) {
                Image(systemName: "plus")
                    .font(kPrimaryTitleFont)
                    .frame(width: 50, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .shadow(radius: shouldShowMenus ? 5 : 0)
            .offset(y: shouldShowMenus ? -offset : 0)
            .animation(.spring())
            
            Button(action: {
                // Do nothing
            }) {
                Text("\(Int(totalTime - completedTime))s")
                    .font(kPrimaryBodyFont)
                    .bold()
                    .frame(width: 50, height: 50)
                    .background(appSettings.themeColorView())
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .animation(nil)
            }
            .padding(10)
            .overlay(
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: (status == .playing || status == .paused) ? 5 : 0, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear)
            )
            .shadow(radius: shouldShowMenus ? 5 : 0)
            .offset(x: shouldShowMenus ? offset : 0)
            .animation(.spring())
            
            Button(action: {
                if self.status == .playing {
                    self.status = .paused
                } else if self.status == .paused || self.status == .notStarted {
                    self.status = .playing
                }
                if self.status == .playing {
                    self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                    NotificationHelper.addLocalNoification(type: .interval(TimeInterval(self.totalTime - self.completedTime)))
                } else if self.status == .paused {
                    self.timer.upstream.connect().cancel()
                    NotificationHelper.resetTimerNotification()
                }
                self.shouldShowMenus = false
            }) {
                Image(systemName: (status == .playing) ? "pause" : "play")
                    .imageScale(.large)
                    .frame(width: 50, height: 50)
                    .background(appSettings.themeColorView())
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .animation(nil)
            }
            .shadow(radius: shouldShowMenus ? 5 : 0)
            .offset(x: shouldShowMenus ? offset * 2 : 0)
            .animation(.spring())
        }
        .padding(.leading, (status == .playing || status == .paused) ? 20 : 0)
        .onReceive(timer, perform: { (_) in
            if self.status == .playing {
                self.completedTime += 1
                if self.completedTime == self.totalTime {
                    self.resetDetails()
                }
            }
        })
    }
    
    func resetDetails() {
        self.status = .notStarted
        self.timer.upstream.connect().cancel()
        self.completedTime = 0
        self.totalTime = 5
        self.shouldShowMenus = false
        NotificationHelper.resetTimerNotification()
    }
    
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        RestTimerView().environmentObject(AppSettings())
    }
}
