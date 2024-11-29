//
//  AnalyticsView.swift
//  BabyFeedTracking
//
//  Created by Bhumika Patel on 29/11/24.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    var feedings: [FeedingLog]

    var body: some View {
        VStack {
            Text("Feeding Trends")
                .font(.headline)

            Chart(feedings) {
                LineMark(
                    x: .value("Date", $0.date),
                    y: .value("Amount", $0.amount)
                )
            }
            .frame(height: 300)
        }
        .padding()
    }
}
