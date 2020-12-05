//
//  WidgetSummaryView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 14/11/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData
import WidgetKit

struct WidgetSummaryContent: TimelineEntry {
    var totalWorkoutTime: Int16 = 0
    var progress: [(Double, BodyParts, Double)] = []
    var total : Double {
        let durations = progress.map { $0.0 }
        return durations.reduce(0.0, +)
    }
    var totalSessions: Double {
        let durations = progress.map { $0.2 }
        return durations.reduce(0.0, +)
    }
    var segments: [WidgetSegmentData] = []
    var date = Date()
}

struct WidgetPieChart: View {
    
    let content: WidgetSummaryContent
    var progress: [(Double, BodyParts, Double)] { content.progress }
    var total : Double { content.total }
    var totalSessions: Double { content.totalSessions }
    var segments: [WidgetSegmentData] { content.segments }
    
    var gridLayout = Array.init(repeating: GridItem(.fixed(100), spacing: 10, alignment: .leading), count: 3)
    
    var body: some View {
        VStack(spacing: 5) {
            GeometryReader { geometry in
                LazyVGrid(columns: gridLayout, alignment: .center, spacing: 10) {
                    if self.progress.count > 0 {
                        ForEach(0..<(self.progress.count + 2), id: \.self) { index in
                            if index == 0 {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray, lineWidth: 2)
                                    .overlay(
                                        HStack {
                                            Spacer()
                                            VStack(spacing: 3) {
                                                Text(total.detailedDisplayDuration())
                                                    .font(.title)
                                                    .bold()
                                                Divider()
                                                    .frame(width: 50)
                                                HStack(spacing: 2) {
                                                    Text("\(Int(totalSessions))")
                                                        .bold()
                                                    Text("sessions").font(.caption)
                                                }
                                            }
                                            Spacer()
                                        }
                                        .padding(5)
                                    )
                                    .frame(width: 210, height: 80, alignment: .center) // Using 2nd cell space as well as spacing between first 2 cells

                            }
                            if index == 1 { Color.clear}
                            if index > 1 {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(progress[index - 2].1.piechartColor())
                                    .overlay(
                                        VStack {
                                            Text(progress[index - 2].1.rawValue)
                                                .font(.caption2)
                                            Divider()
                                                .frame(width: 20)
                                            Text(progress[index - 2].0.detailedDisplayDuration())
                                                .font(.footnote)
                                                .bold()
                                            Text("\(Int(progress[index - 2].2)) sessions")
                                                .font(.caption)
                                        }
                                        .font(.caption2)
                                        .padding(5)
                                        .lineLimit(1)
                                        
                                    )
                                    .frame(width: 100, height: 80, alignment: .center)
                                    .foregroundColor(.white)
                            }
                            
                        }
                    }
                }
                
            }
        }
        .padding()
    }
    
}

struct WidgetSegmentData {
    var percentage: Double
    var startAngle: Double
    var endAngle: Double
}

struct WidgetSegment: Shape {
    
    var radius: CGFloat
    var startAngle: Double
    var endAngle: Double
    
    func path(in rect: CGRect) -> Path {
        var segmentPath = Path()
        segmentPath.move(to: CGPoint(x: rect.midX, y: rect.midY))
        segmentPath.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: radius, startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), clockwise: false)
        return segmentPath
    }
    
}
