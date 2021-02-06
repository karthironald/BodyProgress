//
//  ProgressWidget.swift
//  ProgressWidget
//
//  Created by Karthick Selvaraj on 14/11/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import WidgetKit
import SwiftUI
import CoreData

let placeholderSummary = SummaryWidgetContent(totalWorkoutTime: 263075, progress: [(63800, BodyParts.arms, 18), (32345, BodyParts.chest, 8), (27342, BodyParts.shoulders, 7), (6468, BodyParts.back, 2), (16524, BodyParts.legs, 5), (35530, BodyParts.core, 32), (44675, BodyParts.cardio, 24), (24833, BodyParts.others, 17), (2500, BodyParts.fullBody, 10), (11558, BodyParts.abs, 5)], selectedTimePeriod: .last30Days, segments: [WidgetSegmentData(percentage: 70, startAngle: 0, endAngle: 252), WidgetSegmentData(percentage: 30, startAngle: 252, endAngle: 360)])

struct Provider: IntentTimelineProvider {

    func timePeriod(for config: SelectTimePeriodIntent) -> TimePeriod {
        switch config.selectedTimePeriod {
        case .last7Days: return TimePeriod.last7Days
        case .last30Days: return TimePeriod.last30Days
        case .last60Days: return TimePeriod.last60Days
        case .last90Days: return TimePeriod.last90Days
        case .all: return TimePeriod.all
        case .unknown: return TimePeriod.last30Days
        }
    }
    
    func placeholder(in context: Context) -> SummaryWidgetContent {
        placeholderSummary
    }

    func getSnapshot(for configuration: SelectTimePeriodIntent, in context: Context, completion: @escaping (SummaryWidgetContent) -> ()) {
        let entry = placeholderSummary
        completion(entry)
    }

    func getTimeline(for configuration: SelectTimePeriodIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        func fetchData() {
            var progress: [(Double, BodyParts, Double)] = []
            var segments: [WidgetSegmentData] = []

            WorkoutHistory.fetchSummary(startedAgo: configuration.selectedTimePeriod.rawValue, context: container.viewContext) { (data) in
                progress = data
                var lastEndAngle = 0.0
                var total : Double {
                    let durations = progress.map { $0.0 }
                    return durations.reduce(0.0, +)
                }
                for pro in progress {
                    let percent = (pro.0 / total) * 100.0
                    let angle = (360 / 100) * (percent)
                    let segmentData = WidgetSegmentData(percentage: percent, startAngle: lastEndAngle, endAngle: lastEndAngle + angle)
                    
                    segments.append(segmentData)
                    lastEndAngle += angle
                }
                
                let summary = SummaryWidgetContent(progress: progress, selectedTimePeriod: timePeriod(for: configuration), segments: segments)

                let timeline = Timeline(entries: [summary], policy: .atEnd)
                completion(timeline)
            }
        }
        
        let storeURL = AppGroup.group.containerURL.appendingPathComponent("BodyProgress.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)

        let container = NSPersistentContainer(name: "BodyProgress")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else if error == nil {
                fetchData()
            }
        })

    }
}

@main
struct ProgressWidget: Widget {
    let kind: String = WidgetKind.summary.rawValue

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectTimePeriodIntent.self, provider: Provider()) { entry in
            SummaryWidget(content: entry)
        }
        .configurationDisplayName("Workout Summary")
        .description("Get your total and each body part workout summary at a glance")
        .supportedFamilies([.systemLarge])
    }
}

struct ProgressWidget_Previews: PreviewProvider {
    static var previews: some View {
        SummaryWidget(content: placeholderSummary)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
