//
//  SmokingRecord.swift
//  SmokeCounter
//
//  喫煙記録を表すSwiftDataモデル
//

import Foundation
import SwiftData

/// 個々の喫煙記録を表すモデル
@Model
final class SmokingRecord {
    /// 一意識別子
    var id: UUID
    
    /// 喫煙日時
    var timestamp: Date
    
    /// カウント数（通常は1）
    var count: Int
    
    /// 記録時の銘柄ID（nilの場合は未分類）
    var brandId: UUID?
    
    /// 記録時の銘柄名（履歴表示用、銘柄が削除されても表示できるように保存）
    var brandName: String?
    
    /// 記録時の1本あたり価格（値上げ前の記録を正確に計算するため）
    var pricePerCigarette: Decimal?
    
    /// 初期化
    /// - Parameters:
    ///   - timestamp: 喫煙日時（デフォルトは現在時刻）
    ///   - count: カウント数（デフォルトは1）
    ///   - brandId: 銘柄ID
    ///   - brandName: 銘柄名
    ///   - pricePerCigarette: 1本あたりの価格
    init(timestamp: Date = Date(), count: Int = 1, brandId: UUID? = nil, brandName: String? = nil, pricePerCigarette: Decimal? = nil) {
        self.id = UUID()
        self.timestamp = timestamp
        self.count = count
        self.brandId = brandId
        self.brandName = brandName
        self.pricePerCigarette = pricePerCigarette
    }
    
    /// 記録の日付部分のみを取得（時間を切り捨て）
    var dateOnly: Date {
        Calendar.current.startOfDay(for: timestamp)
    }
    
    /// この記録の金額を計算
    var amount: Decimal {
        guard let price = pricePerCigarette else { return 0 }
        return price * Decimal(count)
    }
}
