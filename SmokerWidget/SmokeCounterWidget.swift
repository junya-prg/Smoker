//
//  SmokerWidget.swift
//  SmokerWidget
//
//  ホーム画面に今日の喫煙カウントを表示するウィジェット
//

import WidgetKit
import SwiftUI

/// ウィジェットのメインエントリーポイント
@main
struct SmokeCounterWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmokeCounterWidget()
    }
}

/// 喫煙カウンターウィジェット
struct SmokeCounterWidget: Widget {
    let kind: String = "SmokeCounterWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SmokeCounterWidgetIntent.self,
            provider: SmokeCounterTimelineProvider()
        ) { entry in
            SmokeCounterWidgetEntryView(entry: entry)
                .containerBackground(Color.black, for: .widget)
        }
        .configurationDisplayName("喫煙カウンター")
        .description("今日の喫煙本数を表示します")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - プレビュー

#Preview(as: .systemSmall) {
    SmokeCounterWidget()
} timeline: {
    SmokeCounterEntry(date: Date(), count: 5, goal: 10)
    SmokeCounterEntry(date: Date(), count: 12, goal: 10)
}

#Preview(as: .systemMedium) {
    SmokeCounterWidget()
} timeline: {
    SmokeCounterEntry(date: Date(), count: 5, goal: 10)
}

#Preview(as: .accessoryCircular) {
    SmokeCounterWidget()
} timeline: {
    SmokeCounterEntry(date: Date(), count: 5, goal: 10)
}

#Preview(as: .accessoryRectangular) {
    SmokeCounterWidget()
} timeline: {
    SmokeCounterEntry(date: Date(), count: 5, goal: 10)
}
