//
//  SummaryView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 08/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct SummaryView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var totalWorkoutTime: Int16 = 0
    @State var progress: [(Double, BodyParts)] = []
    var total : Double {
        let durations = progress.map { $0.0 }
        return durations.reduce(0.0, +)
    }
    @State var segments: [SegmentData] = []
    
    var body: some View {
        List {
            GeometryReader { geoProxy in
                ZStack {
                    ForEach(0..<self.segments.count, id: \.self) { segIndex in
                        Segment(radius: geoProxy.size.width / 3, startAngle: self.segments[segIndex].startAngle, endAngle: self.segments[segIndex].endAngle)
                            .fill(self.progress[segIndex].1.piechartColor())
                    }
                }
                .rotationEffect(.degrees(-90))
            }
            .frame(height: 250)
            HStack {
                Spacer()
                Text("Total: \(total.detailedDisplayDuration())")
                    .font(kPrimaryTitleFont)
                    .bold()
                    .padding()
                    .multilineTextAlignment(.center)
                Spacer()
            }
            ForEach(0..<self.progress.count, id: \.self) { segIndex in
                HStack {
                    Circle()
                        .fill(self.progress[segIndex].1.piechartColor())
                        .frame(width: 10, height: 10)
                    HStack(alignment: .center) {
                        Text("\(self.progress[segIndex].1.rawValue)")
                            .font(kPrimaryBodyFont)
                            .bold()
                        Spacer()
                        Text("\(self.progress[segIndex].0.detailedDisplayDuration()) (\(self.percentage(of: self.progress[segIndex].0), specifier: "%.2f") %)")
                            .font(kPrimaryBodyFont)
                            .bold()
                    }
                }
            }
        }
        .onAppear {
            WorkoutHistory.fetchSum(context: self.managedObjectContext) { (data) in
                self.progress = data
                self.chartData()
            }
        }
        .navigationBarTitle(Text("Summary"))
    }
    
    func percentage(of duration: Double) -> Double {
        (duration / total) * 100.0
    }
    
    func chartData() {
        var lastEndAngle = 0.0
        
        for pro in self.progress {
            let percent = percentage(of: pro.0)
            let angle = (360 / 100) * (percent)
            let segmentData = SegmentData(percentage: percent, startAngle: lastEndAngle, endAngle: lastEndAngle + angle)
            
            self.segments.append(segmentData)
            lastEndAngle += angle
        }
    }
    
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}

struct SegmentData {
    var percentage: Double
    var startAngle: Double
    var endAngle: Double
}

struct Segment: Shape {
    
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
