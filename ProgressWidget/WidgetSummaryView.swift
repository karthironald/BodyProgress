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
    
    var body: some View {
        GeometryReader { geoProxy in
            ZStack {
                ForEach(0..<self.segments.count, id: \.self) { segIndex in
                    WidgetSegment(radius: geoProxy.size.width / 3, startAngle: self.segments[segIndex].startAngle, endAngle: self.segments[segIndex].endAngle)
                        .fill(self.progress[segIndex].1.piechartColor())
                }
                Circle()
                    .fill(Color(UIColor.systemBackground))
                    .frame(width: geoProxy.size.width / 2, height: geoProxy.size.width / 2)
                .overlay(
                    VStack {
                        Text("\(self.total.detailedDisplayDuration())")
                            .font(kPrimaryBodyFont)
                            .bold()
                            .padding([.leading, .trailing, .top])
                            .multilineTextAlignment(.center)
                        Divider()
                            .frame(width: 50)
                            .padding([.leading, .trailing])
                        Text("\(Int64(self.totalSessions)) sessions")
                            .font(kPrimaryFootnoteFont)
                            .padding([.leading, .trailing])
                    }
                    .rotationEffect(.degrees(90))
                )
            }
            .rotationEffect(.degrees(-90))
        }
        .background(Color.white)
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
