# SmokeCounter 要件定義書

## 1. 目的

1日の喫煙本数を手軽にカウントし、節煙につなげることを目的とする。

## 2. 対象プラットフォーム

| プラットフォーム | 最小バージョン | 備考 |
|----------------|--------------|------|
| iOS | 26.0+ | iPhone メインアプリ（Foundation Models対応） |
| watchOS | 10.0+ | Apple Watch アプリ |

## 3. 機能要件

### 3.1 カウント機能

| 機能ID | 機能名 | 詳細 |
|--------|-------|------|
| CNT-001 | カウントアップ | 喫煙時にワンタップでカウントを+1する |
| CNT-002 | カウントダウン | 誤操作時にカウントを-1できる |
| CNT-003 | 日次リセット | 毎日0時に自動的にカウントをリセットする |
| CNT-004 | 手動リセット | ユーザーが任意のタイミングでリセットできる |

### 3.2 ウィジェット機能

| 機能ID | 機能名 | 詳細 |
|--------|-------|------|
| WDG-001 | iOSウィジェット表示 | ホーム画面に今日のカウントを表示 |
| WDG-002 | iOSウィジェット操作 | ウィジェットからカウントアップ可能 |
| WDG-003 | watchOSウィジェット | Apple Watchの文字盤にカウントを表示 |
| WDG-004 | watchOSコンプリケーション | 文字盤からアプリへ素早くアクセス |

### 3.3 統計・グラフ機能

| 機能ID | 機能名 | 詳細 |
|--------|-------|------|
| STS-001 | 日別グラフ | 過去の日別喫煙本数を棒グラフで表示 |
| STS-002 | 月別グラフ | 月ごとの合計本数を折れ線グラフで表示 |
| STS-003 | 年間グラフ | 年間の推移をグラフで表示 |
| STS-004 | 期間選択 | 表示する期間を選択できる |
| STS-005 | 平均値表示 | 期間内の1日あたり平均本数を表示 |

### 3.4 銘柄・金額管理機能

| 機能ID | 機能名 | 詳細 |
|--------|-------|------|
| BRD-001 | 銘柄登録 | タバコの銘柄名を登録できる |
| BRD-002 | 価格設定 | 1箱あたりの価格を設定できる |
| BRD-003 | 本数設定 | 1箱あたりの本数を設定できる |
| BRD-004 | 金額算出 | 喫煙本数から消費金額を自動算出 |
| BRD-005 | 累計金額表示 | 日別・月別・年間の累計金額を表示 |

### 3.5 目標設定機能

| 機能ID | 機能名 | 詳細 |
|--------|-------|------|
| GOL-001 | 目標本数設定 | 1日の目標本数を設定できる |
| GOL-002 | 達成状況表示 | 目標に対する達成状況を表示（残り本数など） |
| GOL-003 | 目標達成インジケータ | 目標達成/超過を視覚的に表示 |

### 3.6 喫煙履歴機能

| 機能ID | 機能名 | 詳細 |
|--------|-------|------|
| HST-001 | 時刻記録 | 喫煙した時刻を記録する |
| HST-002 | 履歴一覧表示 | 今日の喫煙時刻を一覧で表示 |
| HST-003 | 履歴削除 | 誤って記録した履歴を個別に削除できる |
| HST-004 | 間隔表示 | 前回の喫煙からの経過時間を表示 |

### 3.7 HealthKit連携機能（未実装・将来計画）

> [!NOTE]
> 本機能は未実装です。データモデル（`AppSettings.healthKitEnabled`）のみ定義済みで、
> HealthKitフレームワークの実際の連携処理は実装されていません。

| 機能ID | 機能名 | 詳細 | 状態 |
|--------|-------|------|------|
| HLT-001 | HealthKit認証 | HealthKitへのアクセス許可を取得 | 未実装 |
| HLT-002 | データ登録 | 喫煙データをHealthKitにカスタムデータとして登録 | 未実装 |
| HLT-003 | 連携ON/OFF | HealthKit連携の有効/無効を切り替え | 未実装 |

### 3.8 データ同期機能

| 機能ID | 機能名 | 詳細 |
|--------|-------|------|
| SYN-001 | iCloud同期 | iPhone-Watch間でデータを自動同期 |
| SYN-002 | バックアップ | iCloudにデータを自動バックアップ |
| SYN-003 | 復元 | iCloudからデータを復元 |

### 3.9 AIニュース機能（Foundation Models）

| 機能ID | 機能名 | 詳細 |
|--------|-------|------|
| AIN-001 | 記事取得 | Google News RSSからタバコ関連記事を自動取得 |
| AIN-002 | AI要約 | Foundation Modelsを使用して記事を要約 |
| AIN-003 | カテゴリ分類 | AIが記事を自動分類（節煙、健康、新商品、業界） |
| AIN-004 | おすすめ度計算 | ユーザーの喫煙データに基づきおすすめ度を算出 |
| AIN-005 | 記事一覧表示 | カテゴリフィルター付きの記事一覧を表示 |
| AIN-006 | 記事詳細表示 | 記事の詳細とAI要約を表示 |
| AIN-007 | オフライン対応 | Foundation Modelsはオンデバイスで動作、オフラインでもAI機能利用可能 |

### 3.10 リラックスモード機能

| 機能ID | 機能名 | 詳細 |
|--------|-------|------|
| RLX-001 | リラックスモード起動 | ホーム画面の背景タップで全画面リラックスモードに切り替え |
| RLX-002 | 背景エフェクト | 焚き火など癒し系パーティクルアニメーションを全画面表示（ランダム切替） |
| RLX-003 | AI癒しメッセージ | Foundation Modelsで癒しメッセージを自動生成して表示 |
| RLX-004 | リラックスモード解除 | 画面タップでリラックスモードを解除し通常画面に復帰 |
| RLX-005 | ハプティクスフィードバック | Core Hapticsで「呼吸」のようなゆるやかな振動パターンを再生 |

## 4. 非機能要件

### 4.1 パフォーマンス

| 項目 | 要件 |
|-----|------|
| アプリ起動時間 | 2秒以内 |
| カウント操作レスポンス | 即時（0.1秒以内） |
| グラフ描画時間 | 1秒以内 |

### 4.2 データ

| 項目 | 要件 |
|-----|------|
| データ保存方式 | SwiftData（ローカル） |
| データ同期方式 | iCloud（CloudKit） |
| データ保持期間 | 無期限 |

### 4.3 セキュリティ

| 項目 | 要件 |
|-----|------|
| データ暗号化 | iCloudの暗号化機能を利用 |
| プライバシー | 個人の喫煙データはローカル/iCloud内に保持（HealthKit連携は将来計画） |

### 4.4 ユーザビリティ

| 項目 | 要件 |
|-----|------|
| アクセシビリティ | VoiceOver対応 |
| ダークモード | システム設定に連動 |
| 多言語対応 | 日本語（初期リリース） |

## 5. アーキテクチャ

### 5.1 全体構成

```mermaid
graph TB
    subgraph iOS [iOS App]
        iPhoneApp[iPhone App]
        iOSWidget[iOS Widget]
    end
    
    subgraph watchOS [watchOS App]
        WatchApp[Watch App]
        WatchWidget[Watch Widget]
    end
    
    subgraph DataLayer [Data Layer]
        SwiftData[SwiftData]
        iCloud[iCloud Sync]
    end
    
    iPhoneApp --> SwiftData
    iOSWidget --> SwiftData
    WatchApp --> SwiftData
    WatchWidget --> SwiftData
    SwiftData <--> iCloud
```

### 5.2 採用アーキテクチャ

- **パターン**: MVVM（Model-View-ViewModel）
- **理由**: SwiftUIとの親和性が高く、テスタビリティを確保できる

### 5.3 レイヤー構成

| レイヤー | 責務 |
|---------|-----|
| View | UI表示、ユーザー操作の受付 |
| ViewModel | UIロジック、状態管理 |
| Model | データ構造、ビジネスロジック |
| Repository | データアクセス、外部サービス連携 |

## 6. 画面構成

### 6.1 iPhone アプリ

| 画面ID | 画面名 | 概要 |
|--------|-------|------|
| SCR-001 | ホーム画面 | 今日のカウント表示、カウントアップボタン、目標達成状況、今日の履歴（コンパクト表示） |
| SCR-002 | AIニュース画面 | タバコ関連記事一覧、カテゴリフィルター、AI要約表示 |
| SCR-003 | 統計画面 | 日別・月別・年間グラフ、金額集計 |
| SCR-004 | 設定画面 | 銘柄設定、金額設定、目標本数設定 |
| SCR-005 | 記事詳細画面 | 記事の詳細表示、AI要約の全文、関連記事 |

### 6.2 Apple Watch アプリ

| 画面ID | 画面名 | 概要 |
|--------|-------|------|
| WCH-001 | メイン画面 | 今日のカウント表示、カウントアップボタン、目標達成状況 |
| WCH-002 | 履歴画面 | 今日の喫煙時刻一覧 |
| WCH-003 | 簡易統計画面 | 直近7日間の推移 |

### 6.3 画面遷移図

```mermaid
graph LR
    subgraph iPhone [iPhone App]
        Home[ホーム画面]
        AINews[AIニュース画面]
        ArticleDetail[記事詳細画面]
        Stats[統計画面]
        Settings[設定画面]
        
        Home --> AINews
        Home --> Stats
        Home --> Settings
        AINews --> ArticleDetail
        AINews --> Home
        ArticleDetail --> AINews
        Stats --> Home
        Settings --> Home
    end
    
    subgraph Watch [Watch App]
        WatchHome[メイン画面]
        WatchHistory[履歴画面]
        WatchStats[簡易統計]
        
        WatchHome --> WatchHistory
        WatchHome --> WatchStats
        WatchHistory --> WatchHome
        WatchStats --> WatchHome
    end
```

## 7. データモデル

### 7.1 主要エンティティ

```mermaid
erDiagram
    SmokingRecord {
        UUID id PK
        Date timestamp
        Int count
    }
    
    DailySummary {
        UUID id PK
        Date date
        Int totalCount
        Decimal totalAmount
    }
    
    CigaretteBrand {
        UUID id PK
        String name
        Int countPerPack
        Decimal pricePerPack
        Bool isActive
    }
    
    Settings {
        UUID id PK
        Bool healthKitEnabled
        UUID activeBrandId FK
        Int dailyGoal
    }
    
    SmokingRecord ||--o{ DailySummary : "aggregates"
    Settings ||--o| CigaretteBrand : "uses"
```

### 7.2 エンティティ詳細

#### SmokingRecord（喫煙記録）
| フィールド | 型 | 説明 |
|-----------|---|------|
| id | UUID | 一意識別子 |
| timestamp | Date | 喫煙日時 |
| count | Int | カウント数（通常は1） |

#### DailySummary（日次集計）
| フィールド | 型 | 説明 |
|-----------|---|------|
| id | UUID | 一意識別子 |
| date | Date | 対象日 |
| totalCount | Int | 合計本数 |
| totalAmount | Decimal | 合計金額 |

#### CigaretteBrand（タバコ銘柄）
| フィールド | 型 | 説明 |
|-----------|---|------|
| id | UUID | 一意識別子 |
| name | String | 銘柄名 |
| countPerPack | Int | 1箱あたりの本数 |
| pricePerPack | Decimal | 1箱あたりの価格 |
| isActive | Bool | 現在使用中かどうか |

#### Settings（設定）
| フィールド | 型 | 説明 |
|-----------|---|------|
| id | UUID | 一意識別子 |
| healthKitEnabled | Bool | HealthKit連携の有効/無効（未実装・将来用に予約） |
| activeBrandId | UUID | 現在選択中の銘柄ID |
| dailyGoal | Int? | 1日の目標本数（nil: 目標未設定） |

## 8. 技術スタック

| カテゴリ | 技術 | バージョン |
|---------|-----|-----------|
| 言語 | Swift | 6.0+ |
| UIフレームワーク | SwiftUI | - |
| データ永続化 | SwiftData | - |
| 同期 | CloudKit | - |
| ヘルスケア | HealthKit | -（未実装・将来計画） |
| ウィジェット | WidgetKit | - |
| グラフ描画 | Swift Charts | - |
| AI/LLM | Foundation Models | iOS 26+ |
| RSS解析 | XMLParser | - |

## 9. 今後の拡張候補

以下の機能は初期リリース後の拡張候補として検討する。

| 機能 | 概要 |
|-----|------|
| HealthKit連携 | 喫煙データをHealthKitにカスタムデータとして登録・連携（データモデルのみ定義済み） |
| 通知機能 | 目標達成時や一定時間経過時に通知 |
| 複数銘柄対応 | 複数の銘柄を登録し、記録時に選択 |
| データエクスポート | CSVやPDFでデータを出力 |
