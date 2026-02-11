//
//  SmokeCounterEntry.swift
//  SmokeCounterWidget
//
//  ウィジェットのタイムラインエントリー
//

import WidgetKit

/// ウィジェットのタイムラインエントリー
struct SmokeCounterEntry: TimelineEntry {
    /// タイムラインの日時
    let date: Date
    
    /// 今日の喫煙本数
    let count: Int
    
    /// 1日の目標本数
    let goal: Int?
    
    /// 最後の喫煙からの経過時間（秒）
    var timeSinceLastSmoke: TimeInterval? = nil
    
    /// 目標に対する残り本数
    var remainingCount: Int? {
        guard let goal = goal else { return nil }
        return max(0, goal - count)
    }
    
    /// 目標を超過しているかどうか
    var isOverGoal: Bool {
        guard let goal = goal else { return false }
        return count > goal
    }
    
    /// 目標達成率（0.0〜1.0、超過時は1.0以上）
    var goalProgress: Double {
        guard let goal = goal, goal > 0 else { return 0 }
        return Double(count) / Double(goal)
    }
}
