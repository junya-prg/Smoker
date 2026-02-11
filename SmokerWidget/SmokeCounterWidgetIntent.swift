//
//  SmokeCounterWidgetIntent.swift
//  SmokeCounterWidget
//
//  ウィジェットの設定用Intent
//

import WidgetKit
import AppIntents
import SwiftData

/// ウィジェットの設定用Intent
struct SmokeCounterWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "喫煙カウンター"
    static var description = IntentDescription("今日の喫煙本数を表示します")
}

/// カウントアップ用のIntent
struct IncrementCountIntent: AppIntent {
    static var title: LocalizedStringResource = "喫煙を記録"
    static var description = IntentDescription("喫煙カウントを1増やします")
    
    /// ウィジェットからの実行時にアプリを開かない
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print("🔵 ウィジェット: カウントアップ開始 - \(formatter.string(from: now))")
        
        // SwiftDataに直接記録を追加
        do {
            // App GroupのURLを確認
            if let url = SharedModelContainer.databaseURL {
                print("🔵 データベースURL: \(url.path)")
            } else {
                print("🔴 App Groupコンテナにアクセスできません")
            }
            
            let container = try SharedModelContainer.createContainer()
            print("🔵 ModelContainer作成成功")
            
            let context = ModelContext(container)
            
            // デフォルト銘柄を取得
            let defaultBrand = try getDefaultBrand(context: context)
            
            // 銘柄情報を含めて記録を作成
            let record = SmokingRecord(
                brandId: defaultBrand?.id,
                brandName: defaultBrand?.name,
                pricePerCigarette: defaultBrand?.pricePerCigarette
            )
            context.insert(record)
            print("🔵 レコード挿入完了 - timestamp: \(formatter.string(from: record.timestamp)), 銘柄: \(defaultBrand?.name ?? "なし")")
            
            try context.save()
            print("🔵 保存成功")
            
            // 保存後に今日のカウントを確認
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: now)
            let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now
            
            let predicate = #Predicate<SmokingRecord> { r in
                r.timestamp >= startOfToday && r.timestamp < endOfToday
            }
            let descriptor = FetchDescriptor<SmokingRecord>(predicate: predicate)
            let todayRecords = try context.fetch(descriptor)
            print("🔵 今日のレコード数: \(todayRecords.count)")
            
        } catch {
            print("🔴 ウィジェットからの記録保存に失敗: \(error)")
        }
        
        // ウィジェットのタイムラインを更新
        WidgetCenter.shared.reloadAllTimelines()
        print("🔵 タイムライン更新リクエスト完了")
        
        return .result()
    }
    
    /// デフォルト銘柄を取得
    private func getDefaultBrand(context: ModelContext) throws -> CigaretteBrand? {
        // 全銘柄を取得してデフォルト銘柄を探す
        let allDescriptor = FetchDescriptor<CigaretteBrand>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        let allBrands = try context.fetch(allDescriptor)
        
        // isDefaultBrandがtrueの銘柄を探す
        if let defaultBrand = allBrands.first(where: { $0.isDefaultBrand }) {
            return defaultBrand
        }
        
        // デフォルト銘柄がない場合は最初の銘柄を返す
        return allBrands.first
    }
}
