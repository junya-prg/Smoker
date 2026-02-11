//
//  CigaretteBrand.swift
//  SmokeCounterWidget
//
//  タバコの銘柄情報を表すSwiftDataモデル（ウィジェット用）
//

import Foundation
import SwiftData

/// タバコの銘柄を表すモデル
@Model
final class CigaretteBrand {
    /// 一意識別子
    var id: UUID
    
    /// 銘柄名
    var name: String
    
    /// 1箱あたりの本数
    var countPerPack: Int
    
    /// 1箱あたりの価格
    var pricePerPack: Decimal
    
    /// 現在使用中かどうか
    var isActive: Bool
    
    /// 作成日時
    var createdAt: Date
    
    /// デフォルト銘柄かどうか（ウィジェットからのカウントアップ時に使用）
    /// オプショナルにすることでマイグレーション時にnilが設定される
    var isDefault: Bool?
    
    /// デフォルト銘柄かどうかを安全に取得（nilの場合はfalse）
    var isDefaultBrand: Bool {
        isDefault ?? false
    }
    
    /// 初期化
    /// - Parameters:
    ///   - name: 銘柄名
    ///   - countPerPack: 1箱あたりの本数（デフォルト20本）
    ///   - pricePerPack: 1箱あたりの価格
    ///   - isActive: 使用中かどうか（デフォルトtrue）
    ///   - isDefault: デフォルト銘柄かどうか（デフォルトfalse）
    init(name: String, countPerPack: Int = 20, pricePerPack: Decimal, isActive: Bool = true, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.countPerPack = countPerPack
        self.pricePerPack = pricePerPack
        self.isActive = isActive
        self.createdAt = Date()
        self.isDefault = isDefault
    }
    
    /// 1本あたりの価格を計算
    var pricePerCigarette: Decimal {
        guard countPerPack > 0 else { return 0 }
        return pricePerPack / Decimal(countPerPack)
    }
}
