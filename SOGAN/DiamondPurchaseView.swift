//
//  DiamondPurchaseView.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/01/27.
//

import SwiftUI
import StoreKit

struct DiamondPurchaseView: View {
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingPurchaseAlert = false
    @State private var selectedOption: DataManager.DiamondPurchaseOption?
    @State private var purchaseMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 現在のダイヤ表示
                    currentDiamondsView
                    
                    // ダイヤモンドの説明
                    diamondExplanationView
                    
                    // 購入オプション
                    purchaseOptionsView
                    
                    // 補填情報
                    refillInfoView
                    
                    // 利用規約
                    termsView
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("💎 ダイヤモンド購入")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .alert("購入確認", isPresented: $showingPurchaseAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("購入") {
                    if let option = selectedOption,
                       let userId = dataManager.selectedUserId {
                        dataManager.purchaseDiamonds(option.diamonds, for: userId)
                        // 購入成功メッセージを表示
                        purchaseMessage = "\(option.diamonds)ダイヤモンドを購入しました！\n\n即座に利用可能です。"
                    }
                }
            } message: {
                Text(purchaseMessage)
            }
        }
    }
    
    // MARK: - 現在のダイヤ表示
    private var currentDiamondsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("現在のダイヤモンド")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                if let userId = dataManager.selectedUserId {
                    Text("💎 \(dataManager.getDiamonds(for: userId))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                } else {
                    Text("💎 15") // 初期ダイヤ数を表示
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            
            Text("ダイヤモンドは機能利用時に消費されます")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - ダイヤモンドの説明
    private var diamondExplanationView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("ダイヤモンドの使い方")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                UsageRow(icon: "camera.fill", title: "顔相診断", cost: "3ダイヤ", description: "AIによる詳細な顔相分析")
                UsageRow(icon: "sparkles", title: "AIアドバイス", cost: "1ダイヤ", description: "パーソナライズされた改善アドバイス")
                UsageRow(icon: "person.badge.plus", title: "ユーザー追加", cost: "3ダイヤ", description: "新しいユーザーを登録")
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - 購入オプション
    private var purchaseOptionsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("購入プラン")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(DataManager.DiamondPurchaseOption.options) { option in
                    purchaseOptionCard(option)
                }
            }
        }
    }
    
    private func purchaseOptionCard(_ option: DataManager.DiamondPurchaseOption) -> some View {
        VStack(spacing: 16) {
            // 人気バッジ
            if option.isPopular {
                Text("おすすめ")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(12)
            } else {
                Spacer()
                    .frame(height: 20)
            }
            
            // ダイヤ数
            Text("💎 \(option.diamonds)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            // 説明
            Text(option.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // 価格
            VStack(spacing: 4) {
                Text("¥\(option.price)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // 1ダイヤあたりの価格
                let pricePerDiamond = Double(option.price) / Double(option.diamonds)
                Text("1ダイヤ ¥\(String(format: "%.1f", pricePerDiamond))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 購入ボタン
            Button(action: {
                selectedOption = option
                purchaseMessage = "\(option.diamonds)ダイヤモンドを¥\(option.price)で購入しますか？\n\n購入後は即座に利用可能です。"
                showingPurchaseAlert = true
            }) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("購入する")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(false)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(option.isPopular ? Color.orange : Color.clear, lineWidth: 2)
        )
    }
    
    // MARK: - 補填情報
    private var refillInfoView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("💡 ダイヤモンドについて")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(icon: "clock", title: "毎日補填", description: "毎日0時に10ダイヤまで自動補填されます")
                InfoRow(icon: "infinity", title: "無期限", description: "購入したダイヤモンドは無期限で使用可能")
                InfoRow(icon: "gift", title: "お得", description: "まとめて購入するとお得になります")
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - 利用規約
    private var termsView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("利用規約")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• 購入したダイヤモンドは返金できません")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("• ダイヤモンドは機能利用時に消費されます")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("• 課金はApple StoreKitを通じて処理されます")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
}

// MARK: - 使用法行
struct UsageRow: View {
    let icon: String
    let title: String
    let cost: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(cost)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                
                Text(description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - プレビュー
#Preview {
    DiamondPurchaseView()
} 