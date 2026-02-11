//
//  CompactHistoryView.swift
//  SmokeCounter
//
//  ホーム画面用のコンパクトな履歴表示コンポーネント
//

import SwiftUI
import SwiftData

/// コンパクト履歴表示（ホーム画面下部用）
struct CompactHistoryView: View {
    /// 今日の喫煙記録（最新5件）
    @Query private var recentRecords: [SmokingRecord]
    
    /// 表示する最大件数
    private let maxDisplayCount = 5
    
    init() {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? Date()
        
        _recentRecords = Query(
            filter: #Predicate<SmokingRecord> { record in
                record.timestamp >= startOfToday && record.timestamp < endOfToday
            },
            sort: [SortDescriptor(\SmokingRecord.timestamp, order: .reverse)]
        )
    }
    
    /// 表示用の記録（最大件数で制限）
    private var displayRecords: [SmokingRecord] {
        Array(recentRecords.prefix(maxDisplayCount))
    }
    
    /// 非表示の記録数
    private var hiddenCount: Int {
        max(0, recentRecords.count - maxDisplayCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Label("今日の履歴", systemImage: "clock.fill")
                    .font(.headline)
                
                Spacer()
                
                if recentRecords.count > 0 {
                    Text("\(recentRecords.count)件")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            if displayRecords.isEmpty {
                // 記録がない場合
                EmptyHistoryView()
            } else {
                // 履歴一覧
                VStack(spacing: 8) {
                    ForEach(displayRecords) { record in
                        CompactHistoryRowView(
                            record: record,
                            previousRecord: previousRecord(for: record)
                        )
                    }
                    
                    // 非表示の記録がある場合
                    if hiddenCount > 0 {
                        HStack {
                            Spacer()
                            Text("他 \(hiddenCount)件")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    /// 指定した記録の前の記録を取得
    private func previousRecord(for record: SmokingRecord) -> SmokingRecord? {
        guard let index = displayRecords.firstIndex(where: { $0.id == record.id }),
              index + 1 < displayRecords.count else {
            return nil
        }
        return displayRecords[index + 1]
    }
}

/// 履歴が空の場合のビュー
private struct EmptyHistoryView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "smoke")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("今日の記録はまだありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
}

/// コンパクト履歴行ビュー
struct CompactHistoryRowView: View {
    let record: SmokingRecord
    let previousRecord: SmokingRecord?
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    /// 前回からの経過時間
    private var intervalText: String? {
        guard let previous = previousRecord else { return nil }
        let interval = record.timestamp.timeIntervalSince(previous.timestamp)
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "+\(hours)h\(minutes)m"
        } else {
            return "+\(minutes)m"
        }
    }
    
    var body: some View {
        HStack {
            // 時刻インジケーター
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
            
            // 時刻
            Text(timeFormatter.string(from: record.timestamp))
                .font(.subheadline)
                .monospacedDigit()
            
            Spacer()
            
            // 前回からの経過時間
            if let interval = intervalText {
                Text(interval)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CompactHistoryView()
        .modelContainer(for: SmokingRecord.self, inMemory: true)
        .padding()
}
