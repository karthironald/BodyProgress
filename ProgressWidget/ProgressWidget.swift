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

let placeholderSummary = WidgetSummaryContent(totalWorkoutTime: 100, progress: [(70, BodyParts.arms, 10), (30, BodyParts.chest, 10)], segments: [WidgetSegmentData(percentage: 70, startAngle: 0, endAngle: 252), WidgetSegmentData(percentage: 30, startAngle: 252, endAngle: 360)])

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> WidgetSummaryContent {
        placeholderSummary
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetSummaryContent) -> ()) {
        let entry = placeholderSummary
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        func data() {
            var progress: [(Double, BodyParts, Double)] = []
            var segments: [WidgetSegmentData] = []
            
            WorkoutHistory.fetchSummary(context: container.viewContext) { (data) in
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
                
                let summary = WidgetSummaryContent(progress: progress, segments: segments)

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
                data()
            }
        })

    }
}

@main
struct ProgressWidget: Widget {
    let kind: String = "ProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetPieChart(content: entry)
        }
        .configurationDisplayName("Workout Summary")
        .description("Get your workout history summary at glance.")
        .supportedFamilies([.systemLarge])
    }
}

struct ProgressWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetPieChart(content: placeholderSummary)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
