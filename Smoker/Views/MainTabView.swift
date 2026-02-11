//
//  MainTabView.swift
//  SmokeCounter
//
//  メインタブビュー - ホーム、AIニュース、統計、設定のタブナビゲーション
//

import SwiftUI

/// メインタブビュー
@available(iOS 26.0, macOS 26.0, *)
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // ホーム画面（履歴はホーム画面下部に統合）
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(0)
            
            // AIニュース画面
            AINewsView()
                .tabItem {
                    Label("AIニュース", systemImage: "newspaper.fill")
                }
                .tag(1)
            
            // 統計画面
            StatisticsView()
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            // 設定画面
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
    }
}

//#Preview {
//    MainTabView()
//        .modelContainer(for: [SmokingRecord.self, CigaretteBrand.self, AppSettings.self], inMemory: true)
//}
