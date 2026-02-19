//
//  SharedDataManager.swift
//  SmokeCounterWidget
//
//  メインアプリとウィジェット間でデータを共有するためのマネージャー
//

import Foundation
import WidgetKit

/// App Groupを使用してメインアプリとウィジェット間でデータを共有するマネージャー
final class SharedDataManager {
    /// シングルトンインスタンス
    static let shared = SharedDataManager()
    
    /// App Group識別子
    static let appGroupIdentifier = "group.jp.junya.smoker.data"
    
    /// UserDefaultsのキー
    private enum Keys {
        static let todayCount = "todayCount"
        static let dailyGoal = "dailyGoal"
        static let lastUpdateDate = "lastUpdateDate"
        static let lastSmokeTime = "lastSmokeTime"
    }
    
    /// 共有UserDefaults
    private let userDefaults: UserDefaults?
    
    private init() {
        userDefaults = UserDefaults(suiteName: SharedDataManager.appGroupIdentifier)
    }
    
    // MARK: - 今日のカウント
    
    /// 今日の喫煙本数を取得
    var todayCount: Int {
        get {
            // 日付が変わっていたら0を返す
            if !isToday(lastUpdateDate) {
                return 0
            }
            return userDefaults?.integer(forKey: Keys.todayCount) ?? 0
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.todayCount)
            userDefaults?.set(Date(), forKey: Keys.lastUpdateDate)
        }
    }
    
    /// 1日の目標本数を取得/設定
    var dailyGoal: Int? {
        get {
            guard let value = userDefaults?.object(forKey: Keys.dailyGoal) as? Int else {
                return nil
            }
            return value
        }
        set {
            if let newValue = newValue {
                userDefaults?.set(newValue, forKey: Keys.dailyGoal)
            } else {
                userDefaults?.removeObject(forKey: Keys.dailyGoal)
            }
        }
    }
    
    /// 最後の更新日を取得
    var lastUpdateDate: Date? {
        get {
            return userDefaults?.object(forKey: Keys.lastUpdateDate) as? Date
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.lastUpdateDate)
        }
    }
    
    /// 最後の喫煙時刻を取得/設定
    var lastSmokeTime: Date? {
        get {
            return userDefaults?.object(forKey: Keys.lastSmokeTime) as? Date
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.lastSmokeTime)
        }
    }
    
    // MARK: - 操作
    
    /// カウントを1増やす
    func incrementCount() {
        // 日付が変わっていたらリセット
        if !isToday(lastUpdateDate) {
            todayCount = 1
        } else {
            todayCount += 1
        }
        lastSmokeTime = Date()
        
        // ウィジェットを更新
        reloadWidgets()
    }
    
    /// 共有データを更新
    /// - Parameters:
    ///   - count: 今日のカウント
    ///   - goal: 目標本数
    ///   - lastSmoke: 最後の喫煙時刻
    func updateSharedData(count: Int, goal: Int?, lastSmoke: Date?) {
        todayCount = count
        dailyGoal = goal
        lastSmokeTime = lastSmoke
        
        // ウィジェットを更新
        reloadWidgets()
    }
    
    /// ウィジェットを更新
    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - ヘルパー
    
    /// 指定した日付が今日かどうかを判定
    private func isToday(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return Calendar.current.isDateInToday(date)
    }
    
    /// 目標に対する残り本数
    var remainingCount: Int? {
        guard let goal = dailyGoal else { return nil }
        return max(0, goal - todayCount)
    }
    
    /// 目標を超過しているかどうか
    var isOverGoal: Bool {
        guard let goal = dailyGoal else { return false }
        return todayCount > goal
    }
    
    /// 目標達成率（0.0〜1.0、超過時は1.0以上）
    var goalProgress: Double {
        guard let goal = dailyGoal, goal > 0 else { return 0 }
        return Double(todayCount) / Double(goal)
    }
}
