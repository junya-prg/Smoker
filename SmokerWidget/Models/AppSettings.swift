//
//  AppSettings.swift
//  SmokeCounterWidget
//
//  アプリの設定を表すSwiftDataモデル（ウィジェット用）
//

import Foundation
import SwiftData

/// アプリの設定を表すモデル
/// CloudKit互換のため、すべてのプロパティにデフォルト値を設定
@Model
final class AppSettings {
    /// 一意識別子
    var id: UUID = UUID()
    
    /// HealthKit連携の有効/無効
    var healthKitEnabled: Bool = false
    
    /// 現在選択中の銘柄ID
    var activeBrandId: UUID?
    
    /// 1日の目標本数（nilで目標未設定）
    var dailyGoal: Int?
    
    /// iCloud同期の有効/無効（デフォルトtrue）
    /// デフォルト値を指定してマイグレーション対応
    var iCloudSyncEnabled: Bool = true
    
    /// 初期化
    /// - Parameters:
    ///   - healthKitEnabled: HealthKit連携の有効/無効（デフォルトfalse）
    ///   - activeBrandId: 選択中の銘柄ID
    ///   - dailyGoal: 1日の目標本数
    ///   - iCloudSyncEnabled: iCloud同期の有効/無効（デフォルトtrue）
    init(healthKitEnabled: Bool = false, activeBrandId: UUID? = nil, dailyGoal: Int? = nil, iCloudSyncEnabled: Bool = true) {
        self.id = UUID()
        self.healthKitEnabled = healthKitEnabled
        self.activeBrandId = activeBrandId
        self.dailyGoal = dailyGoal
        self.iCloudSyncEnabled = iCloudSyncEnabled
    }
}
