//
//  PurchaseView.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/07.
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var showingPurchaseAlert = false
    @State private var purchaseError: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // ヘッダー
                        VStack(spacing: 16) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("プレミアム機能")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("SOGANをさらに便利に")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // 課金プラン一覧
                        VStack(spacing: 20) {
                            ForEach(purchaseManager.products, id: \.id) { product in
                                PurchaseCard(
                                    product: product,
                                    isPurchased: purchaseManager.purchasedProductIDs.contains(product.id),
                                    onPurchase: {
                                        selectedProduct = product
                                        showingPurchaseAlert = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 復元ボタン
                        Button(action: {
                            Task {
                                await purchaseManager.restorePurchases()
                            }
                        }) {
                            Text("購入を復元")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("プレミアム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .alert("購入確認", isPresented: $showingPurchaseAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("購入") {
                Task {
                    await purchaseProduct()
                }
            }
        } message: {
            if let product = selectedProduct {
                Text("\(product.displayName)を購入しますか？\n価格: \(product.displayPrice)")
            }
        }
        .alert("エラー", isPresented: .constant(purchaseError != nil)) {
            Button("OK") {
                purchaseError = nil
            }
        } message: {
            if let error = purchaseError {
                Text(error)
            }
        }
        .onAppear {
            Task {
                await purchaseManager.loadProducts()
            }
        }
    }
    
    private func purchaseProduct() async {
        guard let product = selectedProduct else { return }
        
        do {
            try await purchaseManager.purchase(product)
        } catch {
            purchaseError = error.localizedDescription
        }
    }
}

struct PurchaseCard: View {
    let product: Product
    let isPurchased: Bool
    let onPurchase: () -> Void
    
    private var purchaseType: PurchaseManager.PurchaseType? {
        PurchaseManager.PurchaseType.allCases.first { $0.rawValue == product.id }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(purchaseType?.displayName ?? product.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(purchaseType?.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(product.displayPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    if product.id == PurchaseManager.PurchaseType.allFeatures.rawValue {
                        Text("お得パック")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                }
            }
            
            // 機能詳細
            if let type = purchaseType {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(getFeatureList(for: type), id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 14))
                            
                            Text(feature)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                }
            }
            
            // 購入ボタン
            Button(action: onPurchase) {
                HStack {
                    if isPurchased {
                        Image(systemName: "checkmark.circle.fill")
                        Text("購入済み")
                    } else {
                        Image(systemName: "cart.badge.plus")
                        Text("購入する")
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isPurchased ? Color.gray : Color.orange)
                .cornerRadius(10)
            }
            .disabled(isPurchased)
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isPurchased ? Color.green : Color.clear, lineWidth: 2)
        )
    }
    
    private func getFeatureList(for type: PurchaseManager.PurchaseType) -> [String] {
        switch type {
        case .detailedAnalysis:
            return [
                "詳細な顔相分析",
                "運勢の詳細解説",
                "パーソナリティ分析",
                "相性診断機能"
            ]
        case .unlimitedHistory:
            return [
                "無制限の診断履歴保存",
                "日付別・月別・年別統計",
                "運勢変化グラフ",
                "履歴検索機能"
            ]
        case .exportFeature:
            return [
                "高画質画像出力",
                "PDFレポート生成",
                "SNSシェア用画像",
                "印刷用レイアウト"
            ]
        case .allFeatures:
            return [
                "詳細分析アンロック",
                "履歴保存拡張",
                "エクスポート機能",
                "すべての機能をまとめてお得に"
            ]
        }
    }
}

#Preview {
    PurchaseView()
} 