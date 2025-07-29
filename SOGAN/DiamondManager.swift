import Foundation
import SwiftUI

class DiamondManager: ObservableObject {
    @Published var diamonds: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://sogan.vercel.app" // Vercelの実際のURL
    
    enum DiamondAction: Int, CaseIterable {
        case camera = 3
        case viewResult = 4
        case addUser = 3
        case adviceView = 2
        case historyView = 1
        
        var description: String {
            switch self {
            case .camera: return "カメラで写真を撮る"
            case .viewResult: return "結果を見る"
            case .addUser: return "ユーザーを追加"
            case .adviceView: return "アドバイスを見る"
            case .historyView: return "履歴を見る"
            }
        }
    }
    
    struct DiamondResponse: Codable {
        let success: Bool
        let diamonds: Int?
        let message: String?
        let error: String?
    }
    
    struct DiamondPurchaseOption {
        let id: String
        let diamonds: Int
        let price: Int
        let description: String
        
        static let options: [DiamondPurchaseOption] = [
            DiamondPurchaseOption(id: "standard", diamonds: 50, price: 120, description: "スタンダードパック"),
            DiamondPurchaseOption(id: "value", diamonds: 150, price: 300, description: "お得パック"),
            DiamondPurchaseOption(id: "premium", diamonds: 500, price: 800, description: "プレミアムパック")
        ]
    }
    
    init() {
        loadDiamonds()
    }
    
    func loadDiamonds() {
        isLoading = true
        errorMessage = nil
        
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            // ユーザーIDがない場合は新規作成
            createUserAndLoadDiamonds()
            return
        }
        
        let url = URL(string: "\(baseURL)/api/diamonds-new")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "action": "get",
            "userId": userId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "リクエストの作成に失敗しました"
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "ネットワークエラー: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "データが受信できませんでした"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(DiamondResponse.self, from: data)
                    if response.success {
                        self.diamonds = response.diamonds ?? 0
                    } else {
                        self.errorMessage = response.error ?? "ダイヤの取得に失敗しました"
                    }
                } catch {
                    self.errorMessage = "レスポンスの解析に失敗しました"
                }
            }
        }.resume()
    }
    
    private func createUserAndLoadDiamonds() {
        let userId = UUID().uuidString
        UserDefaults.standard.set(userId, forKey: "userId")
        loadDiamonds()
    }
    
    func consumeDiamonds(for action: DiamondAction) -> Bool {
        guard diamonds >= action.rawValue else {
            return false
        }
        
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            return false
        }
        
        let url = URL(string: "\(baseURL)/api/diamonds-new")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "action": "consume",
            "userId": userId,
            "amount": action.rawValue
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            return false
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            
            if let data = data,
               let response = try? JSONDecoder().decode(DiamondResponse.self, from: data),
               response.success {
                DispatchQueue.main.async {
                    self.diamonds = response.diamonds ?? 0
                }
                success = true
            }
        }.resume()
        
        _ = semaphore.wait(timeout: .now() + 5.0)
        return success
    }
    
    func purchaseDiamonds(option: DiamondPurchaseOption) {
        // 実際のIn-App Purchase実装はここに追加
        // 現在はプレースホルダー
        print("Purchasing \(option.diamonds) diamonds for ¥\(option.price)")
    }
    
    func canPerformAction(_ action: DiamondAction) -> Bool {
        return diamonds >= action.rawValue
    }
    
    func formatDiamonds(_ count: Int) -> String {
        return "💎 \(count)"
    }
    
    func getNextRefillTime() -> Date {
        // 毎日午前0時にリフィル
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let startOfTomorrow = calendar.startOfDay(for: tomorrow)
        return startOfTomorrow
    }
    
    func getRefillTimeString() -> String {
        let nextRefill = getNextRefillTime()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: nextRefill)
    }
} 