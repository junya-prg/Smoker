//
//  SharedModelContainer.swift
//  SmokeCounterWidget
//
//  メインアプリとウィジェットで共有するModelContainer設定（ウィジェット用）
//

import Foundation
import SwiftData

/// 共有ModelContainerの設定
enum SharedModelContainer {
    /// App Group識別子
    static let appGroupIdentifier = "group.jp.junya.SmokeCounter"
    
    /// App GroupのコンテナURL
    static var appGroupContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }
    
    /// 共有データベースのURL
    static var databaseURL: URL? {
        appGroupContainerURL?.appendingPathComponent("SmokeCounter.sqlite")
    }
    
    /// スキーマ（メインアプリと同一にする必要がある）
    static var schema: Schema {
        Schema([
            SmokingRecord.self,
            CigaretteBrand.self,
            AppSettings.self
        ])
    }
    
    /// 共有ModelContainerを作成（ウィジェット用）
    /// - Returns: ModelContainer
    static func createContainer() throws -> ModelContainer {
        guard let url = databaseURL else {
            throw NSError(domain: "SharedModelContainer", code: 1, userInfo: [NSLocalizedDescriptionKey: "App Groupのコンテナにアクセスできません"])
        }
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: url,
            cloudKitDatabase: .none
        )
        
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}
