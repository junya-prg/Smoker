//
//  SettingsView.swift
//  SmokeCounter
//
//  設定画面 - 銘柄設定、金額設定、目標本数設定
//

import SwiftUI
import SwiftData

/// 設定画面
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var brands: [CigaretteBrand]
    @Query private var settings: [AppSettings]
    @FocusState private var isGoalFieldFocused: Bool
    
    @State private var showAddBrandSheet = false
    @State private var showPrivacyPolicy = false
    @State private var dailyGoal: String = ""
    
    private var currentSettings: AppSettings? {
        settings.first
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 目標設定セクション
                Section("目標設定") {
                    HStack {
                        Text("1日の目標本数")
                        Spacer()
                        TextField("未設定", text: $dailyGoal)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .focused($isGoalFieldFocused)
                        Text("本")
                    }
                }
                
                // 銘柄設定セクション
                Section {
                    ForEach(brands) { brand in
                        BrandRowView(
                            brand: brand,
                            isActive: currentSettings?.activeBrandId == brand.id,
                            isDefault: brand.isDefaultBrand,
                            onSelect: { selectBrand(brand) },
                            onSetDefault: { setDefaultBrand(brand) }
                        )
                    }
                    .onDelete(perform: deleteBrands)
                    
                    Button(action: { showAddBrandSheet = true }) {
                        Label("銘柄を追加", systemImage: "plus")
                    }
                } header: {
                    Text("銘柄設定")
                } footer: {
                    Text("★マークの銘柄がウィジェットからのカウントアップ時に使用されます")
                }
                
                // データ管理セクション
                Section("データ管理") {
                    NavigationLink {
                        DataManagementView()
                    } label: {
                        Label("データのバックアップと復元", systemImage: "icloud")
                    }
                }
                
                // 開発者支援セクション
                TipJarSection()
                
                // アプリ情報セクション
                Section("アプリ情報") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    Button(action: { showPrivacyPolicy = true }) {
                        HStack {
                            Label("プライバシーポリシー", systemImage: "hand.raised")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("設定")
            .toolbar {
                // キーボードが表示されている時に「完了」ボタンを表示
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完了") {
                        isGoalFieldFocused = false
                    }
                }
            }
            .sheet(isPresented: $showAddBrandSheet) {
                AddBrandView()
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .onAppear {
                loadSettings()
            }
            .onChange(of: dailyGoal) { _, newValue in
                saveGoal(newValue)
            }
        }
    }
    
    /// 設定を読み込む
    private func loadSettings() {
        if let settings = currentSettings {
            dailyGoal = settings.dailyGoal.map { String($0) } ?? ""
        } else {
            // 設定が存在しない場合は作成
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            saveContext()
        }
    }
    
    /// 目標を保存
    private func saveGoal(_ value: String) {
        guard let settings = currentSettings else { return }
        settings.dailyGoal = Int(value)
        saveContext()
        
        // ウィジェット用の共有データも更新
        SharedDataManager.shared.dailyGoal = Int(value)
    }
    
    /// 銘柄を選択
    private func selectBrand(_ brand: CigaretteBrand) {
        guard let settings = currentSettings else { return }
        settings.activeBrandId = brand.id
        saveContext()
    }
    
    /// 銘柄を削除
    private func deleteBrands(offsets: IndexSet) {
        for index in offsets {
            let brand = brands[index]
            // アクティブな銘柄が削除される場合はクリア
            if currentSettings?.activeBrandId == brand.id {
                currentSettings?.activeBrandId = nil
            }
            modelContext.delete(brand)
        }
        saveContext()
    }
    
    /// デフォルト銘柄を設定
    private func setDefaultBrand(_ brand: CigaretteBrand) {
        // 他の銘柄のデフォルトフラグをオフにする
        for b in brands {
            b.isDefault = (b.id == brand.id)
        }
        saveContext()
    }
    
    /// コンテキストを保存（エラーハンドリング付き）
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("設定の保存に失敗しました: \(error)")
        }
    }
}

/// 銘柄行ビュー
struct BrandRowView: View {
    let brand: CigaretteBrand
    let isActive: Bool
    let isDefault: Bool
    let onSelect: () -> Void
    let onSetDefault: () -> Void
    
    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: brand.pricePerPack as NSDecimalNumber) ?? "¥0"
    }
    
    var body: some View {
        HStack {
            Button(action: onSelect) {
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        Text(brand.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if isDefault {
                            Text("デフォルト")
                                .font(.caption2)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .clipShape(Capsule())
                        }
                    }
                    Text("\(formattedPrice) / \(brand.countPerPack)本")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // デフォルト設定ボタン
            Button(action: onSetDefault) {
                Image(systemName: isDefault ? "star.fill" : "star")
                    .foregroundStyle(isDefault ? .orange : .gray)
            }
            .buttonStyle(.plain)
            
            if isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
    }
}

/// 銘柄追加ビュー
struct AddBrandView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: AddBrandField?
    
    @State private var name = ""
    @State private var countPerPack = "20"
    @State private var pricePerPack = ""
    
    enum AddBrandField {
        case name, count, price
    }
    
    private var isValid: Bool {
        !name.isEmpty && !pricePerPack.isEmpty && Int(countPerPack) != nil && Decimal(string: pricePerPack) != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("銘柄情報") {
                    TextField("銘柄名", text: $name)
                        .focused($focusedField, equals: .name)
                    
                    HStack {
                        Text("1箱あたりの本数")
                        Spacer()
                        TextField("20", text: $countPerPack)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .focused($focusedField, equals: .count)
                        Text("本")
                    }
                    
                    HStack {
                        Text("1箱あたりの価格")
                        Spacer()
                        Text("¥")
                        TextField("600", text: $pricePerPack)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .focused($focusedField, equals: .price)
                    }
                }
            }
            .navigationTitle("銘柄を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        addBrand()
                    }
                    .disabled(!isValid)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完了") {
                        focusedField = nil
                    }
                }
            }
        }
    }
    
    /// 銘柄を追加
    private func addBrand() {
        guard let count = Int(countPerPack),
              let price = Decimal(string: pricePerPack) else { return }
        
        let brand = CigaretteBrand(
            name: name,
            countPerPack: count,
            pricePerPack: price
        )
        
        modelContext.insert(brand)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("銘柄の保存に失敗しました: \(error)")
        }
    }
}

/// データ管理ビュー
struct DataManagementView: View {
    var body: some View {
        Form {
            Section {
                Text("iCloudでデータが自動的に同期されます")
                    .foregroundStyle(.secondary)
            }
            
            Section("iCloud同期") {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("同期が有効です")
                }
            }
        }
        .navigationTitle("データ管理")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [CigaretteBrand.self, AppSettings.self], inMemory: true)
}
