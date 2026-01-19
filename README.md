# SmokeCounter - 喫煙カウンター

1日の喫煙本数を手軽にカウントし、節煙をサポートするiOS/watchOSアプリです。

## 概要

SmokeCounterは、日々の喫煙本数を記録し、統計データを通じて節煙への意識を高めることを目的としたアプリです。iPhoneとApple Watchの両方で利用でき、ウィジェットからも素早くカウントできます。

## 主要機能

### カウント機能
- ワンタップで喫煙をカウント
- 日毎に自動リセット
- ウィジェットから素早くカウントアップ

### 統計・グラフ
- 日別の喫煙本数推移
- 月別の集計データ
- 年間の統計グラフ

### 金額管理
- タバコの銘柄・価格を設定
- 喫煙本数から金額を自動算出
- 期間ごとの支出額を可視化

### HealthKit連携
- Apple HealthKitへのデータ登録
- 健康管理データとの統合

## 対応プラットフォーム

| プラットフォーム | 最小バージョン |
|----------------|--------------|
| iOS | 17.0+ |
| watchOS | 10.0+ |

## 技術スタック

- **言語**: Swift
- **UI フレームワーク**: SwiftUI
- **データ永続化**: SwiftData
- **データ同期**: iCloud (CloudKit)
- **ヘルスケア連携**: HealthKit
- **ウィジェット**: WidgetKit
- **アーキテクチャ**: MVVM

## プロジェクト構成

```
SmokeCounter/
├── SmokeCounter/              # iOS メインアプリ
├── SmokeCounterWatch/         # watchOS アプリ
├── SmokeCounterWidget/        # iOS ウィジェット
├── SmokeCounterWatchWidget/   # watchOS ウィジェット
├── Shared/                    # 共有コード（モデル、ビューモデル等）
└── docs/                      # ドキュメント
    └── requirements.md        # 要件定義書
```

## セットアップ

### 必要環境
- Xcode 15.0以上
- iOS 17.0以上のデバイスまたはシミュレータ
- watchOS 10.0以上のApple Watch（オプション）

### ビルド手順

1. リポジトリをクローン
```bash
git clone https://github.com/your-username/SmokeCounter.git
cd SmokeCounter
```

2. Xcodeでプロジェクトを開く
```bash
open SmokeCounter.xcodeproj
```

3. Signing & Capabilitiesで開発チームを設定

4. ビルド＆実行

## ライセンス

MIT License
