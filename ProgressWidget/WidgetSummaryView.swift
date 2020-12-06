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
    var totalWorkoutTime: Int64 = 0
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
    
    @State var rect: CGRect = CGRect.zero
    
    var vSpacing: CGFloat = 7
    var hSpacing: CGFloat { vSpacing / 2 }
    private var cellWidth: CGFloat {
        abs((rect.width - 2 * vSpacing) / 3)
    }
    private var cellHeight: CGFloat {
        abs((rect.height - 5 * (vSpacing / 2)) / 4)
    }
    
    var body: some View {
        let gridLayout = Array.init(repeating: GridItem(.fixed(cellWidth), spacing: vSpacing, alignment: .leading), count: 3)
 
        return VStack(spacing: hSpacing) {
            GeometryReader { geometry in
                LazyVGrid(columns: gridLayout, alignment: .center, spacing: vSpacing) {
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
                                    .frame(width: ((cellWidth * 2) + vSpacing), height: cellHeight, alignment: .center) // Using 2nd cell space as well as spacing between first 2 cells

                            }
                            if index == 1 { Color.clear }
                            if index > 1 {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(progress[index - 2].1.piechartColor())
                                    .overlay(
                                        VStack(spacing: 2) {
                                            Text(progress[index - 2].1.rawValue)
                                                .font(.caption2)
                                                .padding(0)
                                            Divider()
                                                .frame(width: 20)
                                                .padding(0)
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
                                    .frame(width: cellWidth, height: cellHeight, alignment: .center)
                                    .foregroundColor(.white)
                            }
                            
                        }
                    }
                }
                .onAppear(perform: {
                    self.rect = geometry.frame(in: .global)
                })
            }
        }
        .padding(10)
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
