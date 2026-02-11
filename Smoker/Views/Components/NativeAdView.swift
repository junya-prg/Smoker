//
//  NativeAdView.swift
//  SmokeCounter
//
//  ネイティブ広告コンポーネント
//  AIニュース記事一覧に溶け込む形式の広告
//

import SwiftUI
import GoogleMobileAds
import SwiftData
import Combine

// MARK: - ネイティブ広告ビュー

/// ネイティブ広告ビュー
/// 記事カードと同じスタイルで表示される広告
struct NativeAdView: View {
    @StateObject private var adLoader = NativeAdLoader()
    
    var body: some View {
        Group {
            // 広告の読み込みに失敗した場合は非表示
            if adLoader.loadFailed {
                EmptyView()
            } else if let nativeAd = adLoader.nativeAd {
                // 広告が読み込まれた場合
                VStack(alignment: .leading, spacing: 12) {
                    // ヘッダー（広告ラベル）
                    HStack {
                        Text("広告")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Capsule())
                        
                        Spacer()
                    }
                    
                    NativeAdContentView(nativeAd: nativeAd)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            } else {
                // 読み込み中
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("広告")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Capsule())
                        
                        Spacer()
                    }
                    
                    NativeAdPlaceholder()
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
        .onAppear {
            adLoader.loadAd(adUnitId: AdManager.shared.nativeAdUnitId)
        }
    }
}

// MARK: - ネイティブ広告コンテンツビュー

/// 実際のネイティブ広告を表示するビュー
struct NativeAdContentView: View {
    let nativeAd: NativeAd
    
    var body: some View {
        HStack(spacing: 12) {
            // 広告アイコン
            if let icon = nativeAd.icon?.image {
                Image(uiImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "megaphone.fill")
                            .font(.title2)
                            .foregroundStyle(.blue.opacity(0.5))
                    }
            }
            
            // 広告テキスト
            VStack(alignment: .leading, spacing: 4) {
                if let headline = nativeAd.headline {
                    Text(headline)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                
                if let body = nativeAd.body {
                    Text(body)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                if let callToAction = nativeAd.callToAction {
                    Text(callToAction)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

/// ネイティブ広告プレースホルダー（読み込み中用）
struct NativeAdPlaceholder: View {
    var body: some View {
        HStack(spacing: 12) {
            // 広告アイコン
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay {
                    ProgressView()
                }
            
            // 広告テキスト
            VStack(alignment: .leading, spacing: 4) {
                Text("広告を読み込み中...")
                    .font(.headline)
                    .foregroundStyle(.primary.opacity(0.5))
                
                Text("しばらくお待ちください")
                    .font(.subheadline)
                    .foregroundStyle(.secondary.opacity(0.5))
                    .lineLimit(2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundStyle(.gray.opacity(0.3))
        )
    }
}

// MARK: - ネイティブ広告ローダー

/// ネイティブ広告を読み込むクラス
class NativeAdLoader: NSObject, ObservableObject, AdLoaderDelegate, NativeAdLoaderDelegate {
    @Published var nativeAd: NativeAd?
    @Published var loadFailed = false
    private var adLoader: AdLoader?
    private var timeoutTimer: Timer?
    
    /// 広告を読み込む
    func loadAd(adUnitId: String) {
        // すでに読み込み済みまたは失敗済みの場合はスキップ
        guard nativeAd == nil && !loadFailed else { return }
        
        // ルートViewControllerを取得
        var rootViewController: UIViewController?
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            rootViewController = windowScene.windows.first?.rootViewController
        }
        
        adLoader = AdLoader(
            adUnitID: adUnitId,
            rootViewController: rootViewController,
            adTypes: [.native],
            options: nil
        )
        adLoader?.delegate = self
        adLoader?.load(Request())
        
        // 10秒後にタイムアウト
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                if self?.nativeAd == nil {
                    self?.loadFailed = true
                }
            }
        }
    }
    
    // MARK: - AdLoaderDelegate
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        timeoutTimer?.invalidate()
        DispatchQueue.main.async {
            self.loadFailed = true
        }
    }
    
    // MARK: - NativeAdLoaderDelegate
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        timeoutTimer?.invalidate()
        DispatchQueue.main.async {
            self.nativeAd = nativeAd
        }
    }
}

// MARK: - 記事リストに広告を挿入するヘルパー

/// 記事と広告を混在させたリストアイテム
enum ArticleListItem: Identifiable {
    case article(Article)
    case ad(id: String)
    
    var id: String {
        switch self {
        case .article(let article):
            return article.id.uuidString
        case .ad(let id):
            return "ad_\(id)"
        }
    }
}

/// 記事リストに広告を挿入する
/// - Parameters:
///   - articles: 元の記事リスト
///   - interval: 広告を挿入する間隔（記事数）
/// - Returns: 広告が挿入されたリストアイテム
func insertAdsIntoArticles(_ articles: [Article], interval: Int = AdConfiguration.nativeAdInterval) -> [ArticleListItem] {
    guard AdConfiguration.showNativeInAINews else {
        return articles.map { .article($0) }
    }
    
    var result: [ArticleListItem] = []
    
    for (index, article) in articles.enumerated() {
        result.append(.article(article))
        
        // 指定間隔ごとに広告を挿入
        if (index + 1) % interval == 0 && index < articles.count - 1 {
            result.append(.ad(id: "\(index)"))
        }
    }
    
    return result
}

#Preview {
    VStack {
        NativeAdView()
            .padding()
    }
    .background(Color(.systemGray6))
}
