//
//  SmokeCounterTimelineProvider.swift
//  SmokeCounterWidget
//
//  ウィジェットのタイムラインを提供するプロバイダー
//

import WidgetKit
import AppIntents
import SwiftData

/// ウィジェットのタイムラインを提供するプロバイダー
struct SmokeCounterTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = SmokeCounterEntry
    typealias Intent = SmokeCounterWidgetIntent
    
    /// プレースホルダーエントリーを返す
    func placeholder(in context: Context) -> SmokeCounterEntry {
        SmokeCounterEntry(date: Date(), count: 0, goal: 10)
    }
    
    /// ウィジェットギャラリーでのスナップショットを返す
    func snapshot(for configuration: SmokeCounterWidgetIntent, in context: Context) async -> SmokeCounterEntry {
        await getEntry()
    }
    
    /// タイムラインを返す
    func timeline(for configuration: SmokeCounterWidgetIntent, in context: Context) async -> Timeline<SmokeCounterEntry> {
        let currentEntry = await getEntry()
        
        // 現在のエントリーと、次の日の0時用のエントリーを作成
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
        
        // 次の日の0時にカウントを0にリセットしたエントリー
        let midnightEntry = SmokeCounterEntry(
            date: tomorrow,
            count: 0,
            goal: currentEntry.goal,
            timeSinceLastSmoke: nil
        )
        
        return Timeline(entries: [currentEntry, midnightEntry], policy: .atEnd)
    }
    
    /// SwiftDataから直接エントリーを取得
    @MainActor
    private func getEntry() -> SmokeCounterEntry {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print("🟢 Timeline: エントリー取得開始 - \(formatter.string(from: now))")
        
        // SwiftDataから今日のカウントを取得
        var todayCount = 0
        var lastSmokeTime: Date? = nil
        var dailyGoal: Int? = nil
        
        do {
            // App GroupのURLを確認
            if let url = SharedModelContainer.databaseURL {
                print("🟢 データベースURL: \(url.path)")
                print("🟢 ファイル存在: \(FileManager.default.fileExists(atPath: url.path))")
            }
            
            let container = try SharedModelContainer.createContainer()
            let context = ModelContext(container)
            
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: now)
            let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now
            
            print("🟢 検索範囲: \(formatter.string(from: startOfToday)) 〜 \(formatter.string(from: endOfToday))")
            
            let predicate = #Predicate<SmokingRecord> { record in
                record.timestamp >= startOfToday && record.timestamp < endOfToday
            }
            
            let descriptor = FetchDescriptor<SmokingRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            
            let records = try context.fetch(descriptor)
            todayCount = records.reduce(0) { $0 + $1.count }
            lastSmokeTime = records.first?.timestamp
            
            // 目標も取得
            let settingsDescriptor = FetchDescriptor<AppSettings>()
            if let settings = try context.fetch(settingsDescriptor).first {
                dailyGoal = settings.dailyGoal
            }
            
            print("🟢 取得成功: カウント=\(todayCount), 目標=\(dailyGoal ?? -1), レコード数=\(records.count)")
        } catch {
            print("🔴 SwiftDataからの取得に失敗: \(error)")
        }
        
        var timeSinceLastSmoke: TimeInterval? = nil
        if let lastSmoke = lastSmokeTime {
            timeSinceLastSmoke = Date().timeIntervalSince(lastSmoke)
        }
        
        return SmokeCounterEntry(
            date: now,
            count: todayCount,
            goal: dailyGoal,
            timeSinceLastSmoke: timeSinceLastSmoke
        )
    }
}
