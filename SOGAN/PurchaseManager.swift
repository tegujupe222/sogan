//
//  PurchaseManager.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/07.
//

import Foundation
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 課金プランのID
    enum PurchaseType: String, CaseIterable {
        case detailedAnalysis = "com.igafactory.sogan.detailed_analysis"
        case unlimitedHistory = "com.igafactory.sogan.unlimited_history"
        case exportFeature = "com.igafactory.sogan.export_feature"
        case allFeatures = "com.igafactory.sogan.all_features"
        
        var displayName: String {
            switch self {
            case .detailedAnalysis: return "詳細分析アンロック"
            case .unlimitedHistory: return "履歴保存拡張"
            case .exportFeature: return "エクスポート機能"
            case .allFeatures: return "全機能パック"
            }
        }
        
        var description: String {
            switch self {
            case .detailedAnalysis: return "より詳細な顔相分析と運勢解説"
            case .unlimitedHistory: return "無制限の診断履歴保存"
            case .exportFeature: return "高画質画像・PDF出力"
            case .allFeatures: return "すべての機能をまとめてお得に"
            }
        }
        
        var price: String {
            switch self {
            case .detailedAnalysis: return "¥350"
            case .unlimitedHistory: return "¥450"
            case .exportFeature: return "¥550"
            case .allFeatures: return "¥950"
            }
        }
    }
    
    private init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    // 商品情報を読み込み
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let productIDs = PurchaseType.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
        } catch {
            errorMessage = "商品情報の読み込みに失敗しました: \(error.localizedDescription)"
        }
    }
    
    // 購入済み商品を更新
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }
    
    // 商品を購入
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
            }
        case .userCancelled:
            throw PurchaseError.userCancelled
        case .pending:
            throw PurchaseError.pending
        @unknown default:
            throw PurchaseError.unknown
        }
    }
    
    // 機能の利用可能状態をチェック
    func hasFeature(_ type: PurchaseType) -> Bool {
        switch type {
        case .detailedAnalysis:
            return purchasedProductIDs.contains(type.rawValue) || 
                   purchasedProductIDs.contains(PurchaseType.allFeatures.rawValue)
        case .unlimitedHistory:
            return purchasedProductIDs.contains(type.rawValue) || 
                   purchasedProductIDs.contains(PurchaseType.allFeatures.rawValue)
        case .exportFeature:
            return purchasedProductIDs.contains(type.rawValue) || 
                   purchasedProductIDs.contains(PurchaseType.allFeatures.rawValue)
        case .allFeatures:
            return purchasedProductIDs.contains(type.rawValue)
        }
    }
    
    // 復元
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "購入の復元に失敗しました: \(error.localizedDescription)"
        }
    }
}

// 購入エラー
enum PurchaseError: LocalizedError {
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "購入がキャンセルされました"
        case .pending:
            return "購入が保留中です"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}

// 旧課金ロジックはダイヤ消費型に移行のため無効化
/*
// ... 既存の全コード ...
*/ 