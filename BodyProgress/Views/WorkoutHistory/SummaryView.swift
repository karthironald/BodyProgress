//
//  SummaryView.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 08/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI
import CoreData

enum TimePeriod: Int, CaseIterable {
    case last7Days = 7
    case last30Days = 30
    case last60Days = 60
    case last90Days = 90
    case all = 999 // We can't choose 0 a common index in widget, so used 999.
    
    func title() -> String {
        switch self {
        case .last7Days: return "Last 7D"
        case .last30Days: return "Last 30D"
        case .last60Days: return "Last 60D"
        case .last90Days: return "Last 90D"
        case .all: return "All"
        }
    }
}

struct SummaryView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var totalWorkoutTime: Int16 = 0
    @State var progress: [(Double, BodyParts, Double)] = []
    var total : Double {
        let durations = progress.map { $0.0 }
        return durations.reduce(0.0, +)
    }
    @State var segments: [SegmentData] = []
    
    var timePeriodString: String {
        let dates = Helper.startDate(from: appSettings.historySelectedTimePeriod.rawValue)
        
        if let startDate = dates.startDate, let endDate = dates.endDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "\(formatter.string(from: startDate)) to \(formatter.string(from: endDate))"
        }
        return "All Time"
    }
    
    var body: some View {
        ZStack {
            if progress.count == 0 {
                EmptyStateInfoView(title: "No workout summary is available. Start your workout.")
            } else {
                List {
                    VStack(spacing: 0) {
                        PieChart(progress: self.progress, segments: self.segments)
                        Text(timePeriodString)
                            .font(kPrimaryFootnoteFont)
                            .foregroundColor(.secondary)
                            .frame(alignment: .center)
                    }
                    ForEach(0..<self.progress.count, id: \.self) { segIndex in
                        NavigationLink(destination: BodyPartSummary(bodyPart: self.progress[segIndex].1).environment(\.managedObjectContext, self.managedObjectContext).environmentObject(self.appSettings)) {
                            HStack {
                                Circle()
                                    .fill(self.progress[segIndex].1.piechartColor())
                                    .frame(width: 10, height: 10)
                                HStack(alignment: .center) {
                                    Text("\(self.progress[segIndex].1.rawValue)")
                                        .font(kPrimaryBodyFont)
                                    Spacer()
                                    HStack {
                                        Text("\(self.progress[segIndex].0.detailedDisplayDuration())")
                                            .font(kPrimaryCalloutFont)
                                            .foregroundColor(.secondary)
                                        Text("(\(self.percentage(of: self.progress[segIndex].0), specifier: "%.2f")%)")
                                            .font(kPrimaryBodyFont)
                                    }
                                }
                            }
                            .padding([.top, .bottom], 10)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationBarItems(trailing:
                                Menu(content: {
                                    Section {
                                        ForEach(0..<TimePeriod.allCases.count - 1, id: \.self) { index in
                                            Button(TimePeriod.allCases[index].title()) {
                                                self.appSettings.historySelectedTimePeriod = TimePeriod.allCases[index]
                                                WorkoutHistory.fetchSummary(startedAgo: appSettings.historySelectedTimePeriod.rawValue, context: self.managedObjectContext) { (data) in
                                                    self.progress = data
                                                    self.chartData()
                                                }
                                            }
                                        }
                                    }
                                    
                                    Section {
                                        Button(TimePeriod.all.title()) {
                                            self.appSettings.historySelectedTimePeriod = TimePeriod.all
                                            WorkoutHistory.fetchSummary(startedAgo: appSettings.historySelectedTimePeriod.rawValue, context: self.managedObjectContext) { (data) in
                                                self.progress = data
                                                self.chartData()
                                            }
                                        }
                                    }
                                }, label: {
                                    Text(appSettings.historySelectedTimePeriod.title())
                                        .frame(width: 100, height: 30, alignment: .trailing)
                                })
        )
        .onAppear {
            WorkoutHistory.fetchSummary(startedAgo: appSettings.historySelectedTimePeriod.rawValue, context: self.managedObjectContext) { (data) in
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
        segments = []
        
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
    
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        return SummaryView(totalWorkoutTime: 100, progress: [(70, BodyParts.arms, 10), (30, BodyParts.chest, 10)], segments: [SegmentData(percentage: 70, startAngle: 0, endAngle: 252), SegmentData(percentage: 30, startAngle: 252, endAngle: 360)]).environment(\.managedObjectContext, moc).environmentObject(AppSettings())
    }
}

struct PieChart: View {
    
    var progress: [(Double, BodyParts, Double)] = []
    var total : Double {
        let durations = progress.map { $0.0 }
        return durations.reduce(0.0, +)
    }
    var totalSessions: Double {
        let durations = progress.map { $0.2 }
        return durations.reduce(0.0, +)
    }
    
    var segments: [SegmentData] = []
    @State private var shouldShowChart = false
    
    var body: some View {
        GeometryReader { geoProxy in
            if self.shouldShowChart {
                ZStack {
                    ForEach(0..<self.segments.count, id: \.self) { segIndex in
                        Segment(radius: geoProxy.size.width / 3, startAngle: self.segments[segIndex].startAngle, endAngle: self.segments[segIndex].endAngle)
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
                                .foregroundColor(.secondary)
                        }
                        .rotationEffect(.degrees(90))
                    )
                }
                .transition(.scale)
                .rotationEffect(.degrees(-90))
            }
        }
        .animation(Animation.spring())
        .frame(height: 250)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.shouldShowChart = true
            }
        }
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
