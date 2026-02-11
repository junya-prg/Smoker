//
//  AppSettings.swift
//  SmokeCounterWidget
//
//  アプリの設定を表すSwiftDataモデル（ウィジェット用）
//

import Foundation
import SwiftData

/// アプリの設定を表すモデル
@Model
final class AppSettings {
    /// 一意識別子
    var id: UUID
    
    /// HealthKit連携の有効/無効
    var healthKitEnabled: Bool
    
    /// 現在選択中の銘柄ID
    var activeBrandId: UUID?
    
    /// 1日の目標本数（nilで目標未設定）
    var dailyGoal: Int?
    
    /// 初期化
    /// - Parameters:
    ///   - healthKitEnabled: HealthKit連携の有効/無効（デフォルトfalse）
    ///   - activeBrandId: 選択中の銘柄ID
    ///   - dailyGoal: 1日の目標本数
    init(healthKitEnabled: Bool = false, activeBrandId: UUID? = nil, dailyGoal: Int? = nil) {
        self.id = UUID()
        self.healthKitEnabled = healthKitEnabled
        self.activeBrandId = activeBrandId
        self.dailyGoal = dailyGoal
    }
}
