//
//  BannerAdView.swift
//  SmokeCounter
//
//  バナー広告コンポーネント
//  Google AdMobのバナー広告を表示
//

import SwiftUI
import GoogleMobileAds

// MARK: - バナー広告ビュー

/// バナー広告ビュー
/// 統計画面の下部に表示される控えめな広告
struct BannerAdView: View {
    var body: some View {
        VStack(spacing: 0) {
            // 広告ラベル
            HStack {
                Text("広告")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
            
            // AdMobバナー広告
            BannerAdViewRepresentable(adUnitId: AdManager.shared.bannerAdUnitId)
                .frame(height: 50)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .background(Color(.systemGray6))
    }
}

// MARK: - UIKit連携（AdMobバナー広告）

/// AdMobバナー広告のUIViewRepresentable
struct BannerAdViewRepresentable: UIViewRepresentable {
    let adUnitId: String
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitId
        
        // ルートViewControllerを取得
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
        }
        
        // 広告をロード
        bannerView.load(Request())
        
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // 更新時は何もしない
    }
}

#Preview {
    VStack {
        Spacer()
        BannerAdView()
    }
}
