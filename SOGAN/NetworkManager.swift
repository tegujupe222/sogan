//
//  NetworkManager.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/01/27.
//

import Foundation
import UIKit

// MARK: - APIレスポンス構造
struct FaceReadingResponse: Codable {
    let success: Bool
    let analysis: FaceReadingAnalysis
    let timestamp: String
}

struct AdviceResponse: Codable {
    let success: Bool
    let advice: AdviceData
    let diamondsUsed: Int
    let timestamp: String
}

struct AdviceData: Codable {
    let title: String
    let description: String
    let steps: [String]
    let tips: [String]
    let duration: String
    let difficulty: String
}

struct FaceReadingAnalysis: Codable {
    let overallScore: Int
    let wealthLuck: LuckAnalysis
    let loveLuck: LuckAnalysis
    let careerLuck: LuckAnalysis
    let healthLuck: LuckAnalysis
    let faceType: String
    let moodType: String
    let detailedAnalysis: DetailedAnalysis
}

struct LuckAnalysis: Codable {
    let score: Int
    let description: String
    let strengths: [String]
    let weaknesses: [String]
    let advice: [String]
}

struct DetailedAnalysis: Codable {
    let forehead: String
    let eyebrows: String
    let eyes: String
    let nose: String
    let mouth: String
    let cheeks: String
    let ears: String
    let jaw: String
    let skin: String
}

// MARK: - ダイヤモンドAPIレスポンス
struct DiamondResponse: Codable {
    let success: Bool
    let diamonds: Int
}

// MARK: - AIアドバイスAPIレスポンス
struct AIAdviceResponse: Codable {
    let success: Bool
    let advice: AdviceData
    let diamondsUsed: Int
    let timestamp: String
}

// MARK: - ネットワークマネージャー
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    // Vercelの実際のURLに更新
    private let baseURL = "https://sogan-ai.vercel.app/api"
    
    private init() {}
    
    // 顔相診断APIを呼び出す
    func performFaceReading(image: UIImage) async throws -> FaceReadingAnalysis {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkError.invalidImageData
        }
        
        let base64String = imageData.base64EncodedString()
        
        let url = URL(string: "\(baseURL)/face-reading")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["image": base64String]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let faceReadingResponse = try JSONDecoder().decode(FaceReadingResponse.self, from: data)
        
        guard faceReadingResponse.success else {
            throw NetworkError.apiError("顔相診断に失敗しました")
        }
        
        return faceReadingResponse.analysis
    }
    
    // 画像をBase64エンコードする
    private func encodeImageToBase64(_ image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        return imageData.base64EncodedString()
    }
    
    // アドバイス生成APIを呼び出す
    func generateAdvice(diagnosisData: String, category: String, diamonds: Int) async throws -> AdviceData {
        let url = URL(string: "\(baseURL)/advice")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "diagnosisData": diagnosisData,
            "category": category,
            "diamonds": diamonds
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 402 {
                throw NetworkError.apiError("ダイヤモンドが不足しています")
            }
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let adviceResponse = try JSONDecoder().decode(AdviceResponse.self, from: data)
        
        guard adviceResponse.success else {
            throw NetworkError.apiError("アドバイス生成に失敗しました")
        }
        
        return adviceResponse.advice
    }
}

extension NetworkManager {
    // ダイヤ残高取得
    func fetchDiamonds(userId: UUID) async throws -> Int {
        let url = URL(string: "\(baseURL)/diamonds?userId=\(userId.uuidString)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        let result = try JSONDecoder().decode(DiamondResponse.self, from: data)
        guard result.success else { throw NetworkError.apiError("ダイヤ取得失敗") }
        return result.diamonds
    }
    // ダイヤ消費
    func consumeDiamonds(userId: UUID, amount: Int) async throws -> Int {
        let url = URL(string: "\(baseURL)/diamonds/consume")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["userId": userId.uuidString, "amount": amount] as [String : Any]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        let result = try JSONDecoder().decode(DiamondResponse.self, from: data)
        guard result.success else { throw NetworkError.apiError("ダイヤ消費失敗") }
        return result.diamonds
    }
    // ダイヤ加算
    func addDiamonds(userId: UUID, amount: Int) async throws -> Int {
        let url = URL(string: "\(baseURL)/diamonds/add")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["userId": userId.uuidString, "amount": amount] as [String : Any]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        let result = try JSONDecoder().decode(DiamondResponse.self, from: data)
        guard result.success else { throw NetworkError.apiError("ダイヤ加算失敗") }
        return result.diamonds
    }

    func fetchAIAdvice(diagnosisData: String, category: String, diamonds: Int) async throws -> AdviceData {
        let url = URL(string: "\(baseURL)/advice")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "diagnosisData": diagnosisData,
            "category": category,
            "diamonds": diamonds
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        let result = try JSONDecoder().decode(AIAdviceResponse.self, from: data)
        guard result.success else { throw NetworkError.apiError("AIアドバイス生成に失敗しました") }
        return result.advice
    }
}

// MARK: - ネットワークエラー
enum NetworkError: Error, LocalizedError {
    case invalidImageData
    case invalidResponse
    case serverError(Int)
    case apiError(String)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "画像データの処理に失敗しました"
        case .invalidResponse:
            return "サーバーからの応答が無効です"
        case .serverError(let code):
            return "サーバーエラー: \(code)"
        case .apiError(let message):
            return message
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        }
    }
}

// MARK: - 顔相診断サービス
class FaceReadingService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var analysisResult: FaceReadingAnalysis?
    
    private let networkManager = NetworkManager.shared
    
    func analyzeFace(image: UIImage) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let result = try await networkManager.performFaceReading(image: image)
            await MainActor.run {
                self.analysisResult = result
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func resetAnalysis() {
        analysisResult = nil
        errorMessage = nil
    }
}

// MARK: - アドバイス生成サービス
class AdviceService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var generatedAdvice: AdviceData?
    
    private let networkManager = NetworkManager.shared
    
    func generateAdvice(diagnosisData: String, category: String, diamonds: Int) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let result = try await networkManager.fetchAIAdvice(
                diagnosisData: diagnosisData,
                category: category,
                diamonds: diamonds
            )
            await MainActor.run {
                self.generatedAdvice = result
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func resetAdvice() {
        generatedAdvice = nil
        errorMessage = nil
    }
} 