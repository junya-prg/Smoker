//
//  SmokerWidgetEntryView.swift
//  SmokerWidget
//
//  ウィジェットの表示ビュー
//

import SwiftUI
import WidgetKit
import AppIntents
import UIKit

/// ウィジェットのエントリービュー
struct SmokeCounterWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    
    var entry: SmokeCounterEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - 小サイズウィジェット

/// 小サイズウィジェットのビュー
struct SmallWidgetView: View {
    let entry: SmokeCounterEntry
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // メインコンテンツ
            VStack(spacing: 8) {
                // カウント表示
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(entry.count)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(entry.isOverGoal ? .red : .white)
                    Text("本")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                // 目標表示
                if let goal = entry.goal {
                    HStack(spacing: 4) {
                        Image(systemName: "flag.fill")
                            .font(.caption2)
                        Text("目標: \(goal)本")
                            .font(.caption2)
                    }
                    .foregroundStyle(entry.isOverGoal ? .red : .white.opacity(0.7))
                }
                
                // カウントアップボタン
                Button(intent: IncrementCountIntent()) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("記録")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
            
            // 右上のアプリアイコン
            WidgetAppIcon(size: 22)
                .padding(6)
        }
    }
}

// MARK: - ウィジェット用アプリアイコン

/// ウィジェット用のアプリアイコン表示
struct WidgetAppIcon: View {
    let size: CGFloat
    
    var body: some View {
        // ウィジェット用の小さい画像を使用（画像サイズ制限対応）
        if let resizedImage = resizedAppIcon() {
            Image(uiImage: resizedImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
        } else {
            // フォールバック: SF Symbolsを使用
            Image(systemName: "app.fill")
                .font(.system(size: size))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
        }
    }
    
    /// アプリアイコンをウィジェット用に取得（適切なサイズの画像を使用）
    private func resizedAppIcon() -> UIImage? {
        // ウィジェット用の適切なサイズの画像を使用（256x256, 512x512, 768x768）
        // これにより、ウィジェットのサイズ制限エラーを回避
        return UIImage(named: "WidgetIcon")
    }
}

// MARK: - 中サイズウィジェット

/// 中サイズウィジェットのビュー
struct MediumWidgetView: View {
    let entry: SmokeCounterEntry
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // メインコンテンツ
            HStack(spacing: 16) {
                // 左側: カウント
                VStack(spacing: 4) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text("\(entry.count)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(entry.isOverGoal ? .red : .white)
                        Text("本")
                            .font(.callout)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    if let goal = entry.goal {
                        Text("目標: \(goal)本")
                            .font(.caption)
                            .foregroundStyle(entry.isOverGoal ? .red : .white.opacity(0.7))
                    }
                }
                .frame(minWidth: 100)
                
                Divider()
                    .background(.white.opacity(0.3))
                
                // 右側: 操作と情報
                VStack(spacing: 12) {
                    // 進捗バー（目標がある場合）
                    if let goal = entry.goal, goal > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("本日の進捗")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.7))
                            
                            ProgressView(value: min(1.0, entry.goalProgress))
                                .progressViewStyle(.linear)
                                .tint(entry.isOverGoal ? .red : .accentColor)
                            
                            if let remaining = entry.remainingCount, remaining > 0 {
                                Text("残り \(remaining)本")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.7))
                            } else if entry.isOverGoal {
                                Text("\(entry.count - goal)本超過")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    
                    // カウントアップボタン
                    Button(intent: IncrementCountIntent()) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("喫煙を記録")
                        }
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 右上のアプリアイコン
            WidgetAppIcon(size: 28)
        }
    }
}

// MARK: - ロック画面用ウィジェット（円形）

/// ロック画面用の円形ウィジェットのビュー
struct CircularWidgetView: View {
    let entry: SmokeCounterEntry
    
    var body: some View {
        ZStack {
            // 進捗リング
            if let goal = entry.goal, goal > 0 {
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 4)
                
                Circle()
                    .trim(from: 0, to: min(1.0, entry.goalProgress))
                    .stroke(
                        entry.isOverGoal ? Color.red : Color.accentColor,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
            
            // カウント表示
            VStack(spacing: 0) {
                Text("\(entry.count)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("本")
                    .font(.system(size: 8))
            }
        }
    }
}

// MARK: - ロック画面用ウィジェット（長方形）

/// ロック画面用の長方形ウィジェットのビュー
struct RectangularWidgetView: View {
    let entry: SmokeCounterEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("喫煙カウンター")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(entry.count)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("本")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let goal = entry.goal {
                    Text("目標: \(goal)本")
                        .font(.caption2)
                        .foregroundStyle(entry.isOverGoal ? .red : .secondary)
                }
            }
            
            Spacer()
            
            // 進捗インジケータ
            if let goal = entry.goal, goal > 0 {
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 3)
                    
                    Circle()
                        .trim(from: 0, to: min(1.0, entry.goalProgress))
                        .stroke(
                            entry.isOverGoal ? Color.red : Color.accentColor,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 32, height: 32)
            }
        }
    }
}

// MARK: - プレビュー

#Preview("Small Widget") {
    SmallWidgetView(entry: SmokeCounterEntry(date: Date(), count: 5, goal: 10))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
}

#Preview("Medium Widget") {
    MediumWidgetView(entry: SmokeCounterEntry(date: Date(), count: 5, goal: 10))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
}

#Preview("Over Goal") {
    SmallWidgetView(entry: SmokeCounterEntry(date: Date(), count: 12, goal: 10))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
}
