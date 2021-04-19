//
//  BodyPartSummaryRow.swift
//  BodyProgress
//
//  Created by Karthick Selvaraj on 13/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import SwiftUI

struct BodyPartSummaryRow: View {
    
    @EnvironmentObject var appSettings: AppSettings
    
    var summary: (sum: Double, min: Double, max: Double, average: Double, count: Double, workout: String)
    var bodyPart: BodyParts
    var total: Double
    
    var percentage: Double {
        summary.sum / total * 100.0
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("\(self.summary.workout)")
                        .font(kPrimaryBodyFont)
                        .bold()
                        .lineLimit(1)
                    Spacer()
                    Group {
                        Text("\(Int(self.summary.count))")
                        Text("sessions")
                            .foregroundColor(.secondary)
                    }
                    .font(kPrimaryFootnoteFont)
                }
                .padding(.top)
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 12.5)
                                .fill(self.bodyPart.color())
                                .frame(width: geo.size.width, height: 25)
                            RoundedRectangle(cornerRadius: 12.5)
                                .fill(self.appSettings.themeColorView())
                                .frame(width: (geo.size.width / 100) * CGFloat(self.percentage), height: 25)
                                .overlay(
                                    Text("\(self.percentage, specifier: "%0.2f")%")
                                        .font(kPrimaryFootnoteFont)
                                        .foregroundColor(.white)
                                        .padding([.leading, .trailing], 5)
                                    , alignment: .trailing)
                        }
                    }
                    Group {
                        HStack {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.secondary)
                                    .padding([.leading], 10)
                                Text("Total:")
                                    .foregroundColor(.secondary)
                                Text("\(self.summary.sum.detailedDisplayDuration())")
                                Spacer()
                            }
                            .modifier(SummaryModifier(geo: geo, bodyPart: self.bodyPart))
                            Spacer()
                            HStack() {
                                Image(systemName: "clock")
                                    .foregroundColor(.secondary)
                                    .padding([.leading], 10)
                                Text("Avg:")
                                    .foregroundColor(.secondary)
                                Text("\(self.summary.average.detailedDisplayDuration())")
                                Spacer()
                            }
                            .modifier(SummaryModifier(geo: geo, bodyPart: self.bodyPart))
                        }
                        HStack {
                            HStack() {
                                Image(systemName: "clock")
                                    .foregroundColor(.secondary)
                                    .padding([.leading], 10)
                                Text("Min:")
                                    .foregroundColor(.secondary)
                                Text("\(self.summary.min.detailedDisplayDuration())")
                                Spacer()
                            }
                            .modifier(SummaryModifier(geo: geo, bodyPart: self.bodyPart))
                            Spacer()
                            HStack() {
                                Image(systemName: "clock")
                                    .foregroundColor(.secondary)
                                    .padding([.leading], 10)
                                Text("Max:")
                                    .foregroundColor(.secondary)
                                Text("\(self.summary.max.detailedDisplayDuration())")
                                Spacer()
                            }
                            .modifier(SummaryModifier(geo: geo, bodyPart: self.bodyPart))
                        }
                    }
                }
            }
        }
        .frame(height: 150)
    }
}

struct BodyPartSummaryRow_Previews: PreviewProvider {
    static var previews: some View {
        BodyPartSummaryRow(summary: (3600, 1200000, 34809999, 360, 10, "Biceps"), bodyPart: .arms, total: 7200).environmentObject(AppSettings())
            .previewLayout(.fixed(width: 400, height: 150))
    }
}

struct SummaryModifier: ViewModifier {
    
    var geo: GeometryProxy
    var bodyPart: BodyParts
    
    func body(content: Content) -> some View {
        content
            .font(kPrimaryFootnoteFont)
            .frame(width: geo.size.width / 2 - 5, height: 25)
            .background(bodyPart.color())
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
