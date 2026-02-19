//
//  SharedModelContainer.swift
//  SmokeCounter
//
//  メインアプリとウィジェットで共有するModelContainer設定
//

import Foundation
import SwiftData

/// 共有ModelContainerの設定
enum SharedModelContainer {
    /// App Group識別子
    static let appGroupIdentifier = "group.jp.junya.smoker.data"
    
    /// App GroupのコンテナURL
    static var appGroupContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }
    
    /// 共有データベースのURL
    static var databaseURL: URL? {
        appGroupContainerURL?.appendingPathComponent("SmokeCounter.sqlite")
    }
    
    /// スキーマ
    static var schema: Schema {
        Schema([
            SmokingRecord.self,
            CigaretteBrand.self,
            AppSettings.self
        ])
    }
    
    /// 共有ModelContainerを作成
    /// - Returns: ModelContainer
    static func createContainer() throws -> ModelContainer {
        // App Groupのデータベースを使用（ウィジェットと共有するため必須）
        guard let url = databaseURL else {
            // App Groupが利用できない場合はデフォルトの場所を使用
            print("⚠️ App Groupが利用できません。デフォルトの場所を使用します。")
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        }
        
        print("✅ App Groupデータベースを使用: \(url.path)")
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: url,
            cloudKitDatabase: .none  // CloudKitは一旦無効化
        )
        
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}
