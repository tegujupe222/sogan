//
//  Models.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/06.
//

import Foundation
import SwiftUI

// MARK: - ユーザーモデル
struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var nickname: String?
    var birthDate: Date?
    var gender: Gender?
    var profileImageData: Data?
    var createdAt: Date
    var isActive: Bool
    
    init(id: UUID = UUID(), name: String, nickname: String? = nil, birthDate: Date? = nil, gender: Gender? = nil, profileImageData: Data? = nil, createdAt: Date = Date(), isActive: Bool = true) {
        self.id = id
        self.name = name
        self.nickname = nickname
        self.birthDate = birthDate
        self.gender = gender
        self.profileImageData = profileImageData
        self.createdAt = createdAt
        self.isActive = isActive
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, nickname, birthDate, gender, profileImageData, createdAt, isActive
    }
}

// MARK: - 性別
enum Gender: String, CaseIterable, Codable {
    case male = "男性"
    case female = "女性"
    case other = "その他"
    case preferNotToSay = "回答しない"
}

// MARK: - ユーザープロフィール
struct UserProfile: Codable {
    var userId: UUID
    var totalDiagnoses: Int
    var averageLuck: Int
    var bestLuck: Int
    var favoriteFaceType: FaceType?
    var streakDays: Int
    var lastDiagnosisDate: Date?
    var diamonds: Int
    
    init(userId: UUID) {
        self.userId = userId
        self.totalDiagnoses = 0
        self.averageLuck = 0
        self.bestLuck = 0
        self.favoriteFaceType = nil
        self.streakDays = 0
        self.lastDiagnosisDate = nil
        self.diamonds = 15 // 初期ダイヤモンド数を15個に
    }
}

// MARK: - 顔相診断結果
struct FaceReadingResult: Codable, Identifiable {
    let id: UUID
    let userId: UUID // ユーザーIDを追加
    let date: Date
    let imageData: Data?
    let sessionId: String // セッションIDを追加（1日の複数回撮影を区別）
    
    // 基本運勢スコア（0-100）
    let overallLuck: Int
    let loveLuck: Int
    let healthLuck: Int
    let careerLuck: Int
    let wealthLuck: Int // 金運を追加
    
    // 表情分析
    let smileScore: Int
    let energyScore: Int
    let stressScore: Int
    
    // 顔相分類
    let faceType: FaceType
    let moodType: MoodType
    
    // 詳細な顔パーツ分析
    let faceAnalysis: FaceAnalysis
    
    // 改善アドバイス
    let advice: [String]
    let detailedAdvice: [DetailedAdvice]
    
    init(id: UUID = UUID(), userId: UUID, date: Date = Date(), imageData: Data? = nil, sessionId: String = UUID().uuidString) {
        self.id = id
        self.userId = userId
        self.date = date
        self.imageData = imageData
        self.sessionId = sessionId
        
        // 顔パーツ分析を生成
        let analysis = FaceAnalysis()
        self.faceAnalysis = analysis
        
        // 分析結果に基づいてスコアを計算
        let scores = analysis.calculateScores()
        self.overallLuck = scores.overall
        self.loveLuck = scores.love
        self.healthLuck = scores.health
        self.careerLuck = scores.career
        self.wealthLuck = scores.wealth
        
        // 表情分析（スコアに基づいて調整）
        self.smileScore = max(30, min(95, scores.overall + Int.random(in: -10...10)))
        self.energyScore = max(40, min(90, scores.health + Int.random(in: -15...15)))
        self.stressScore = max(5, min(70, 100 - scores.overall + Int.random(in: -10...10)))
        
        // 顔相分類（スコアに基づいて決定）
        self.faceType = Self.determineFaceType(from: scores)
        self.moodType = Self.determineMoodType(from: scores, smileScore: self.smileScore, stressScore: self.stressScore)
        
        // アドバイス生成
        self.advice = analysis.generateBasicAdvice()
        self.detailedAdvice = analysis.generateDetailedAdvice()
    }
    
    // API分析結果から初期化するイニシャライザ
    init(fromAPIAnalysis analysis: FaceReadingAnalysis, userId: UUID, date: Date = Date(), imageData: Data? = nil, sessionId: String = UUID().uuidString) {
        self.id = UUID()
        self.userId = userId
        self.date = date
        self.imageData = imageData
        self.sessionId = sessionId
        
        // API結果からスコアを設定
        self.overallLuck = analysis.overallScore
        self.wealthLuck = analysis.wealthLuck.score
        self.loveLuck = analysis.loveLuck.score
        self.careerLuck = analysis.careerLuck.score
        self.healthLuck = analysis.healthLuck.score
        
        // 表情分析スコアを計算
        self.smileScore = max(30, min(95, analysis.overallScore + Int.random(in: -10...10)))
        self.energyScore = max(40, min(90, analysis.healthLuck.score + Int.random(in: -15...15)))
        self.stressScore = max(5, min(70, 100 - analysis.overallScore + Int.random(in: -10...10)))
        
        // 顔相タイプと気分タイプを設定
        self.faceType = Self.convertFaceType(analysis.faceType)
        self.moodType = Self.convertMoodType(analysis.moodType)
        
        // アドバイスを設定
        self.advice = analysis.wealthLuck.advice + analysis.loveLuck.advice + analysis.careerLuck.advice + analysis.healthLuck.advice
        
        // 詳細アドバイスを生成
        self.detailedAdvice = Self.convertToDetailedAdvice(analysis)
        
        // 顔パーツ分析を生成（API結果に基づいて調整）
        self.faceAnalysis = FaceAnalysis()
    }
    
    // API結果の顔相タイプを既存のenumに変換
    private static func convertFaceType(_ apiFaceType: String) -> FaceType {
        switch apiFaceType {
        case "福相": return .fortunate
        case "元気相": return .energetic
        case "疲労相": return .tired
        case "ストレス相": return .stressed
        case "バランス相": return .balanced
        default: return .balanced
        }
    }
    
    // API結果の気分タイプを既存のenumに変換
    private static func convertMoodType(_ apiMoodType: String) -> MoodType {
        switch apiMoodType {
        case "明るい": return .happy
        case "落ち着いた": return .calm
        case "興奮": return .excited
        case "心配": return .worried
        case "普通": return .neutral
        default: return .neutral
        }
    }
    
    // API結果を詳細アドバイスに変換
    private static func convertToDetailedAdvice(_ analysis: FaceReadingAnalysis) -> [DetailedAdvice] {
        var detailedAdvice: [DetailedAdvice] = []
        
        // 各運勢のアドバイスを詳細アドバイスに変換
        detailedAdvice.append(contentsOf: analysis.wealthLuck.advice.enumerated().map { index, advice in
            DetailedAdvice(
                category: .lifestyle,
                title: "金運アドバイス \(index + 1)",
                description: advice,
                priority: .medium
            )
        })
        
        detailedAdvice.append(contentsOf: analysis.loveLuck.advice.enumerated().map { index, advice in
            DetailedAdvice(
                category: .communication,
                title: "恋愛運アドバイス \(index + 1)",
                description: advice,
                priority: .medium
            )
        })
        
        detailedAdvice.append(contentsOf: analysis.careerLuck.advice.enumerated().map { index, advice in
            DetailedAdvice(
                category: .lifestyle,
                title: "仕事運アドバイス \(index + 1)",
                description: advice,
                priority: .medium
            )
        })
        
        detailedAdvice.append(contentsOf: analysis.healthLuck.advice.enumerated().map { index, advice in
            DetailedAdvice(
                category: .health,
                title: "健康運アドバイス \(index + 1)",
                description: advice,
                priority: .medium
            )
        })
        
        return detailedAdvice
    }
    
    // スコアに基づいて顔相タイプを決定
    private static func determineFaceType(from scores: (overall: Int, love: Int, health: Int, career: Int, wealth: Int)) -> FaceType {
        let overall = scores.overall
        
        if overall >= 80 {
            return .fortunate
        } else if overall >= 70 {
            return .energetic
        } else if overall >= 50 {
            return .balanced
        } else if scores.health < 50 {
            return .tired
        } else {
            return .stressed
        }
    }
    
    // スコアに基づいて気分タイプを決定
    private static func determineMoodType(from scores: (overall: Int, love: Int, health: Int, career: Int, wealth: Int), smileScore: Int, stressScore: Int) -> MoodType {
        let overall = scores.overall
        
        if overall >= 80 && smileScore >= 80 {
            return .excited
        } else if overall >= 70 && stressScore < 30 {
            return .happy
        } else if overall >= 60 && stressScore < 50 {
            return .calm
        } else if stressScore > 60 || overall < 40 {
            return .worried
        } else {
            return .neutral
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, userId, date, imageData, sessionId, overallLuck, loveLuck, healthLuck, careerLuck, wealthLuck, smileScore, energyScore, stressScore, faceType, moodType, faceAnalysis, advice, detailedAdvice
    }
}

// MARK: - 詳細な顔パーツ分析
struct FaceAnalysis: Codable {
    // 額の分析
    let forehead: ForeheadAnalysis
    // 眉の分析
    let eyebrows: EyebrowAnalysis
    // 目の分析
    let eyes: EyeAnalysis
    // 鼻の分析
    let nose: NoseAnalysis
    // 口・唇の分析
    let mouth: MouthAnalysis
    // 頬の分析
    let cheeks: CheekAnalysis
    // 耳の分析
    let ears: EarAnalysis
    // 顎・輪郭の分析
    let jaw: JawAnalysis
    // 肌の分析
    let skin: SkinAnalysis
    
    init() {
        self.forehead = ForeheadAnalysis()
        self.eyebrows = EyebrowAnalysis()
        self.eyes = EyeAnalysis()
        self.nose = NoseAnalysis()
        self.mouth = MouthAnalysis()
        self.cheeks = CheekAnalysis()
        self.ears = EarAnalysis()
        self.jaw = JawAnalysis()
        self.skin = SkinAnalysis()
    }
    
    // スコア計算
    func calculateScores() -> (overall: Int, love: Int, health: Int, career: Int, wealth: Int) {
        let loveScore = calculateLoveScore()
        let healthScore = calculateHealthScore()
        let careerScore = calculateCareerScore()
        let wealthScore = calculateWealthScore()
        let overallScore = (loveScore + healthScore + careerScore + wealthScore) / 4
        
        return (
            overall: overallScore,
            love: loveScore,
            health: healthScore,
            career: careerScore,
            wealth: wealthScore
        )
    }
    
    private func calculateLoveScore() -> Int {
        var score = 50 // ベーススコア
        
        // 各パーツの恋愛運への影響を計算
        score += forehead.loveImpact
        score += eyebrows.loveImpact
        score += eyes.loveImpact
        score += nose.loveImpact
        score += mouth.loveImpact
        score += cheeks.loveImpact
        score += ears.loveImpact
        score += jaw.loveImpact
        
        return max(0, min(100, score))
    }
    
    private func calculateHealthScore() -> Int {
        var score = 50
        
        score += forehead.healthImpact
        score += eyebrows.healthImpact
        score += eyes.healthImpact
        score += nose.healthImpact
        score += mouth.healthImpact
        score += cheeks.healthImpact
        score += ears.healthImpact
        score += jaw.healthImpact
        score += skin.healthImpact
        
        return max(0, min(100, score))
    }
    
    private func calculateCareerScore() -> Int {
        var score = 50
        
        score += forehead.careerImpact
        score += eyebrows.careerImpact
        score += eyes.careerImpact
        score += nose.careerImpact
        score += mouth.careerImpact
        score += cheeks.careerImpact
        score += ears.careerImpact
        score += jaw.careerImpact
        
        return max(0, min(100, score))
    }
    
    private func calculateWealthScore() -> Int {
        var score = 50
        
        score += forehead.wealthImpact
        score += eyebrows.wealthImpact
        score += eyes.wealthImpact
        score += nose.wealthImpact
        score += mouth.wealthImpact
        score += cheeks.wealthImpact
        score += ears.wealthImpact
        score += jaw.wealthImpact
        
        return max(0, min(100, score))
    }
    
    // 基本アドバイス生成（個人の診断結果に基づく）
    func generateBasicAdvice() -> [String] {
        var advice: [String] = []
        
        // スコアに基づいてアドバイスを選択
        let scores = calculateScores()
        
        // 恋愛運が低い場合のアドバイス
        if scores.love < 60 {
            if scores.love < 40 {
                advice.append("眉と目の間隔を意識して、明るい表情を心がけましょう。特に笑顔の練習を毎日5分行うことで恋愛運が向上します")
            } else {
                advice.append("眉の形を整え、目元を明るくすることで恋愛運がアップします")
            }
        }
        
        // 健康運が低い場合のアドバイス
        if scores.health < 60 {
            if scores.health < 40 {
                advice.append("十分な睡眠と水分補給で肌の調子を整えましょう。特に額の艶を保つことが重要です")
            } else {
                advice.append("肌の状態を整え、十分な休息を取ることで健康運が向上します")
            }
        }
        
        // 仕事運が低い場合のアドバイス
        if scores.career < 60 {
            if scores.career < 40 {
                advice.append("額のマッサージで運気を開き、自信を持って行動しましょう。特に朝のルーティンに取り入れることをお勧めします")
            } else {
                advice.append("額を清潔に保ち、明るい表情で仕事に臨むことで仕事運がアップします")
            }
        }
        
        // 金運が低い場合のアドバイス
        if scores.wealth < 60 {
            if scores.wealth < 40 {
                advice.append("鼻の周りを清潔に保ち、金運アップを図りましょう。特に鼻のマッサージが効果的です")
            } else {
                advice.append("鼻の状態を整え、清潔感を保つことで金運が向上します")
            }
        }
        
        // 全体的な運気が高い場合のアドバイス
        if scores.overall >= 80 {
            advice.append("現在の運気は非常に良好です。積極的に新しいことにチャレンジしましょう")
        } else if scores.overall >= 60 {
            advice.append("運気は安定しています。現状維持を心がけつつ、小さな改善を積み重ねましょう")
        }
        
        // デフォルトアドバイス（運気が全体的に良好な場合）
        if advice.isEmpty {
            advice = [
                "朝日を浴びて体内時計を整えましょう",
                "笑顔の練習を毎日5分行いましょう",
                "水分を十分に摂取して肌の調子を整えましょう"
            ]
        }
        
        return advice
    }
    
    // 詳細アドバイス生成（個人の診断結果に基づく）
    func generateDetailedAdvice() -> [DetailedAdvice] {
        var detailedAdvice: [DetailedAdvice] = []
        
        // 各パーツの詳細アドバイスを生成
        detailedAdvice.append(contentsOf: forehead.generateAdvice())
        detailedAdvice.append(contentsOf: eyebrows.generateAdvice())
        detailedAdvice.append(contentsOf: eyes.generateAdvice())
        detailedAdvice.append(contentsOf: nose.generateAdvice())
        detailedAdvice.append(contentsOf: mouth.generateAdvice())
        detailedAdvice.append(contentsOf: cheeks.generateAdvice())
        detailedAdvice.append(contentsOf: ears.generateAdvice())
        detailedAdvice.append(contentsOf: jaw.generateAdvice())
        detailedAdvice.append(contentsOf: skin.generateAdvice())
        
        // スコアに基づく追加アドバイス
        let scores = calculateScores()
        
        // 恋愛運が特に低い場合の特別アドバイス
        if scores.love < 40 {
            detailedAdvice.append(DetailedAdvice(
                category: .communication,
                title: "恋愛運アップの表情トレーニング",
                description: "眉と目の間隔を意識した表情練習を毎日10分。特に笑顔の練習と目元の明るさを重視しましょう",
                priority: .high
            ))
        }
        
        // 健康運が特に低い場合の特別アドバイス
        if scores.health < 40 {
            detailedAdvice.append(DetailedAdvice(
                category: .health,
                title: "健康運回復のための生活習慣改善",
                description: "睡眠時間を7-8時間確保し、朝日を浴びる習慣をつけましょう。肌の状態改善が健康運向上につながります",
                priority: .high
            ))
        }
        
        // 仕事運が特に低い場合の特別アドバイス
        if scores.career < 40 {
            detailedAdvice.append(DetailedAdvice(
                category: .lifestyle,
                title: "仕事運向上のための朝ルーティン",
                description: "朝起きてから額のマッサージを5分。その後、明るい表情で鏡を見て自己暗示をかけましょう",
                priority: .high
            ))
        }
        
        // 金運が特に低い場合の特別アドバイス
        if scores.wealth < 40 {
            detailedAdvice.append(DetailedAdvice(
                category: .beauty,
                title: "金運アップのための鼻ケア",
                description: "鼻の周りを清潔に保ち、毎日マッサージを3分。特に鼻の先端を優しく揉むことで金運が向上します",
                priority: .high
            ))
        }
        
        return detailedAdvice
    }
}

// MARK: - 額の分析
struct ForeheadAnalysis: Codable {
    let shape: ForeheadShape
    let luster: Int // 艶（0-100）
    let width: Int // 幅（0-100）
    let height: Int // 高さ（0-100）
    let condition: ForeheadCondition
    
    init() {
        self.shape = ForeheadShape.allCases.randomElement() ?? .round
        self.luster = Int.random(in: 30...90)
        self.width = Int.random(in: 40...90)
        self.height = Int.random(in: 30...80)
        self.condition = ForeheadCondition.allCases.randomElement() ?? .good
    }
    
    var loveImpact: Int {
        var impact = 0
        if width > 70 { impact += 5 } // 広い額は心に余裕
        if luster > 70 { impact += 8 } // 艶があると全体運上昇
        if shape == .round { impact += 3 }
        if condition == .good { impact += 5 }
        return impact
    }
    
    var healthImpact: Int {
        var impact = 0
        if luster > 70 { impact += 10 } // 艶があり明るい額は気力充実
        if condition == .good { impact += 8 }
        if condition == .stress { impact -= 10 } // ストレス反映
        return impact
    }
    
    var careerImpact: Int {
        var impact = 0
        if luster > 70 { impact += 10 } // ピンクで輝けば上司運・出世運良好
        if height > 60 { impact += 5 } // 高い額は知性
        if condition == .good { impact += 8 }
        return impact
    }
    
    var wealthImpact: Int {
        var impact = 0
        if shape == .round && width > 70 { impact += 10 } // 高く広く丸い額は成功と財を呼ぶ
        if luster > 70 { impact += 8 } // 額の艶が良いと目上運◎
        if condition == .good { impact += 5 }
        return impact
    }
    
    func generateAdvice() -> [DetailedAdvice] {
        var advice: [DetailedAdvice] = []
        
        if luster < 60 {
            advice.append(DetailedAdvice(
                category: .beauty,
                title: "額の艶をアップ",
                description: "額にハイライトを足し明るい印象にすると上司運が向上します",
                priority: .medium
            ))
        }
        
        if condition == .stress {
            advice.append(DetailedAdvice(
                category: .lifestyle,
                title: "ストレスケア",
                description: "ストレスを感じたら額や眉間のマッサージを。印堂をクリアに保つことで運気が開けます",
                priority: .high
            ))
        }
        
        return advice
    }
}

// MARK: - 眉の分析
struct EyebrowAnalysis: Codable {
    let shape: EyebrowShape
    let thickness: Int // 濃さ（0-100）
    let length: Int // 長さ（0-100）
    let position: EyebrowPosition
    let condition: EyebrowCondition
    
    init() {
        self.shape = EyebrowShape.allCases.randomElement() ?? .natural
        self.thickness = Int.random(in: 30...90)
        self.length = Int.random(in: 40...90)
        self.position = EyebrowPosition.allCases.randomElement() ?? .normal
        self.condition = EyebrowCondition.allCases.randomElement() ?? .good
    }
    
    var loveImpact: Int {
        var impact = 0
        if position == .close { impact -= 8 } // 眉目間隔が狭いと恋愛で意思疎通難
        if shape == .natural { impact += 5 } // 滑らかな弧を描く眉は愛嬌があり異性運◎
        if shape == .angry { impact -= 10 } // 吊り上がり眉は激情型で要注意
        if thickness > 60 { impact += 3 }
        return impact
    }
    
    var healthImpact: Int {
        var impact = 0
        if condition == .good { impact += 8 } // 整った眉は精力旺盛で健康
        if thickness > 50 { impact += 5 }
        if condition == .thin { impact -= 5 } // 眉毛が薄くなるのは老化現象で気力低下傾向
        return impact
    }
    
    var careerImpact: Int {
        var impact = 0
        if shape == .straight && thickness > 70 { impact += 10 } // 一文字眉は意志強くリーダー向き
        if condition == .good { impact += 8 }
        if position == .high { impact += 5 } // 眉上（福徳宮）に艶ありは収入・人気運良し
        return impact
    }
    
    var wealthImpact: Int {
        var impact = 0
        if thickness > 60 && length > 60 { impact += 8 } // 濃く適度に長い眉は信用を集め財運底上げ
        if condition == .good { impact += 5 }
        if condition == .thin { impact -= 5 } // 薄い眉は貯蓄より散財傾向
        return impact
    }
    
    func generateAdvice() -> [DetailedAdvice] {
        var advice: [DetailedAdvice] = []
        
        if position == .close {
            advice.append(DetailedAdvice(
                category: .communication,
                title: "コミュニケーション改善",
                description: "眉と目の間が狭く自己表現が苦手な傾向があります。意識的に相手に気持ちを伝えるコミュニケーションを心がけましょう",
                priority: .high
            ))
        }
        
        if condition == .thin {
            advice.append(DetailedAdvice(
                category: .beauty,
                title: "眉のケア",
                description: "眉を整えて濃さを調整することで、より好印象な表情になります",
                priority: .medium
            ))
        }
        
        return advice
    }
}

// MARK: - 目の分析
struct EyeAnalysis: Codable {
    let size: Int // 大きさ（0-100）
    let shape: EyeShape
    let tearBag: Int // 涙袋（0-100）
    let brightness: Int // 輝き（0-100）
    let condition: EyeCondition
    
    init() {
        self.size = Int.random(in: 40...90)
        self.shape = EyeShape.allCases.randomElement() ?? .normal
        self.tearBag = Int.random(in: 20...80)
        self.brightness = Int.random(in: 30...90)
        self.condition = EyeCondition.allCases.randomElement() ?? .good
    }
    
    var loveImpact: Int {
        var impact = 0
        if tearBag > 60 { impact += 8 } // 涙袋ぷっくり＋優しい目尻はモテ要素
        if brightness > 70 { impact += 10 } // 潤んだ瞳は異性を惹きつけ総合的に幸運
        if shape == .sharp { impact -= 5 } // 鋭すぎる目つきは嫉妬・喧嘩の火種
        if size > 60 { impact += 3 }
        return impact
    }
    
    var healthImpact: Int {
        var impact = 0
        if condition == .good { impact += 10 } // 白目の濁り・充血は体調不良のサイン
        if brightness > 70 { impact += 8 } // 大きく澄んだ瞳孔はエネルギッシュで健康
        if condition == .tired { impact -= 10 }
        return impact
    }
    
    var careerImpact: Int {
        var impact = 0
        if brightness > 70 { impact += 10 } // 目力ある人は有能に見え評価UP
        if condition == .good { impact += 8 }
        if shape == .sharp { impact -= 5 } // 三白眼など極端だと対人摩擦も
        return impact
    }
    
    var wealthImpact: Int {
        var impact = 0
        if brightness > 70 { impact += 8 } // 黒白はっきりした目は洞察力と財運をもたらす
        if condition == .good { impact += 5 }
        if condition == .tired { impact -= 8 } // 目に輝きがないとチャンス逃し金運停滞
        return impact
    }
    
    func generateAdvice() -> [DetailedAdvice] {
        var advice: [DetailedAdvice] = []
        
        if brightness < 60 {
            advice.append(DetailedAdvice(
                category: .beauty,
                title: "目の輝きアップ",
                description: "目尻をアイラインで少し下げて柔らかな目元を演出すると恋愛運アップ",
                priority: .medium
            ))
        }
        
        if condition == .tired {
            advice.append(DetailedAdvice(
                category: .lifestyle,
                title: "目の疲労ケア",
                description: "睡眠を十分に取り目の下のクマをケアすることで健康運・対人運が回復します",
                priority: .high
            ))
        }
        
        return advice
    }
}

// MARK: - 鼻の分析
struct NoseAnalysis: Codable {
    let height: Int // 高さ（0-100）
    let width: Int // 幅（0-100）
    let shape: NoseShape
    let tip: NoseTip
    let condition: NoseCondition
    
    init() {
        self.height = Int.random(in: 30...90)
        self.width = Int.random(in: 40...90)
        self.shape = NoseShape.allCases.randomElement() ?? .straight
        self.tip = NoseTip.allCases.randomElement() ?? .round
        self.condition = NoseCondition.allCases.randomElement() ?? .good
    }
    
    var loveImpact: Int {
        var impact = 0
        if height > 80 { impact -= 5 } // 高すぎる鼻はプライド過剰で恋愛に障害
        if shape == .straight { impact += 5 } // 調和の取れた鼻は良縁を引き寄せる
        if tip == .round { impact += 3 }
        if condition == .good { impact += 5 }
        return impact
    }
    
    var healthImpact: Int {
        var impact = 0
        if condition == .good { impact += 10 } // 鼻は健康運（特に胃腸・心臓）を映す
        if height > 60 { impact += 5 } // 高く立派な鼻は健康良好の証
        if condition == .red { impact -= 8 } // 赤い鼻先は高血圧注意
        return impact
    }
    
    var careerImpact: Int {
        var impact = 0
        if shape == .straight { impact += 8 } // 通った鼻筋は自信と権威の象徴で出世運良し
        if width > 60 { impact += 5 } // 小鼻の張りは稼ぐ力
        if condition == .good { impact += 8 } // 鼻に艶ありは交渉運◎
        return impact
    }
    
    var wealthImpact: Int {
        var impact = 0
        if width > 70 && tip == .round { impact += 10 } // 大きく肉厚で丸い鼻は財産運◎
        if width > 60 { impact += 5 } // 小鼻もしっかり張れば蓄財上手
        if condition == .good { impact += 8 }
        if tip == .pointed { impact -= 5 } // 鼻先尖りや曲がりは金運不安定
        return impact
    }
    
    func generateAdvice() -> [DetailedAdvice] {
        var advice: [DetailedAdvice] = []
        
        if condition == .red {
            advice.append(DetailedAdvice(
                category: .health,
                title: "血圧ケア",
                description: "鼻先が赤い場合は血圧に注意が必要です。塩分控えめの食事を心がけましょう",
                priority: .high
            ))
        }
        
        if tip == .pointed {
            advice.append(DetailedAdvice(
                category: .lifestyle,
                title: "金運安定",
                description: "鼻の周りを清潔に保ち、金運アップを図りましょう",
                priority: .medium
            ))
        }
        
        return advice
    }
}

// MARK: - 口・唇の分析
struct MouthAnalysis: Codable {
    let size: Int // 大きさ（0-100）
    let lipThickness: Int // 唇の厚み（0-100）
    let cornerAngle: Int // 口角角度（0-100）
    let shape: MouthShape
    let condition: MouthCondition
    
    init() {
        self.size = Int.random(in: 40...90)
        self.lipThickness = Int.random(in: 30...90)
        self.cornerAngle = Int.random(in: 20...80)
        self.shape = MouthShape.allCases.randomElement() ?? .natural
        self.condition = MouthCondition.allCases.randomElement() ?? .good
    }
    
    var loveImpact: Int {
        var impact = 0
        if lipThickness > 60 { impact += 8 } // 厚い唇は愛情深く恋愛運◎
        if cornerAngle > 60 { impact += 10 } // 上向き口角はモテ要素
        if shape == .natural { impact += 5 }
        if condition == .good { impact += 5 }
        return impact
    }
    
    var healthImpact: Int {
        var impact = 0
        if condition == .good { impact += 10 } // 唇の色艶で体調判断
        if lipThickness > 50 { impact += 5 }
        if condition == .dry { impact -= 8 } // 唇荒れは胃腸不調・脱水のサイン
        return impact
    }
    
    var careerImpact: Int {
        var impact = 0
        if size > 70 { impact += 8 } // 大きい口はカリスマ性（リーダーシップ）あり仕事成功しやすい
        if cornerAngle > 60 { impact += 5 } // 口角横の艶は部下運良し
        if condition == .good { impact += 5 }
        return impact
    }
    
    var wealthImpact: Int {
        var impact = 0
        if size > 70 && condition == .good { impact += 8 } // 大きな口＋赤い唇は富を得る器
        if cornerAngle > 60 { impact += 5 }
        if cornerAngle < 40 { impact -= 5 } // 口角下がりは金運も下向きに
        return impact
    }
    
    func generateAdvice() -> [DetailedAdvice] {
        var advice: [DetailedAdvice] = []
        
        if cornerAngle < 40 {
            advice.append(DetailedAdvice(
                category: .beauty,
                title: "口角アップ",
                description: "口角を意識的に上げる練習をして、明るい表情を心がけましょう",
                priority: .medium
            ))
        }
        
        if condition == .dry {
            advice.append(DetailedAdvice(
                category: .health,
                title: "水分補給",
                description: "唇が乾燥している場合は水分不足のサインです。十分な水分補給を心がけましょう",
                priority: .high
            ))
        }
        
        return advice
    }
}

// MARK: - 頬の分析
struct CheekAnalysis: Codable {
    let fullness: Int // 肉付き（0-100）
    let color: Int // 血色（0-100）
    let boneHeight: Int // 頬骨の高さ（0-100）
    let condition: CheekCondition
    
    init() {
        self.fullness = Int.random(in: 30...90)
        self.color = Int.random(in: 40...90)
        self.boneHeight = Int.random(in: 30...80)
        self.condition = CheekCondition.allCases.randomElement() ?? .good
    }
    
    var loveImpact: Int {
        var impact = 0
        if fullness > 60 { impact += 8 } // 丸いふっくら頬は愛されキャラで恋愛◎
        if color > 70 { impact += 5 }
        if condition == .good { impact += 5 }
        return impact
    }
    
    var healthImpact: Int {
        var impact = 0
        if color > 70 { impact += 8 } // 頬は肺や呼吸器の状態反映
        if fullness > 50 { impact += 5 } // 張りのある頬は活力十分
        if condition == .thin { impact -= 5 } // 頬痩せは栄養不良の兆候
        return impact
    }
    
    var careerImpact: Int {
        var impact = 0
        if boneHeight > 60 { impact += 8 } // 高い頬骨は闘志と統率力を示す
        if color > 70 { impact += 5 } // 頬に艶があれば周囲の評価UP
        if condition == .good { impact += 5 }
        return impact
    }
    
    var wealthImpact: Int {
        var impact = 0
        if fullness > 60 && color > 70 { impact += 8 } // 肉付き良く血色の良い頬は人望を集め金運を呼ぶ
        if condition == .good { impact += 5 }
        return impact
    }
    
    func generateAdvice() -> [DetailedAdvice] {
        var advice: [DetailedAdvice] = []
        
        if fullness < 40 {
            advice.append(DetailedAdvice(
                category: .health,
                title: "栄養改善",
                description: "頬が痩せている場合は栄養不足の可能性があります。バランスの良い食事を心がけましょう",
                priority: .medium
            ))
        }
        
        if color < 50 {
            advice.append(DetailedAdvice(
                category: .beauty,
                title: "血色改善",
                description: "頬の血色を良くするために、適度な運動と十分な睡眠を心がけましょう",
                priority: .medium
            ))
        }
        
        return advice
    }
}

// MARK: - 耳の分析
struct EarAnalysis: Codable {
    let size: Int // 大きさ（0-100）
    let thickness: Int // 厚み（0-100）
    let position: EarPosition
    let shape: EarShape
    let condition: EarCondition
    
    init() {
        self.size = Int.random(in: 30...90)
        self.thickness = Int.random(in: 40...90)
        self.position = EarPosition.allCases.randomElement() ?? .normal
        self.shape = EarShape.allCases.randomElement() ?? .round
        self.condition = EarCondition.allCases.randomElement() ?? .good
    }
    
    var loveImpact: Int {
        var impact = 0
        if condition == .good { impact += 5 } // 耳が美しい人は育ちの良さが出て良縁を得やすい
        if shape == .round { impact += 3 }
        if thickness < 40 { impact -= 3 } // 耳薄い人は気弱でアプローチ下手
        return impact
    }
    
    var healthImpact: Int {
        var impact = 0
        if thickness > 60 { impact += 8 } // 耳朶が厚く色白は腎気旺盛で健康長寿
        if condition == .good { impact += 5 }
        if size < 40 { impact -= 3 } // 小さく薄い耳は体力弱め
        return impact
    }
    
    var careerImpact: Int {
        var impact = 0
        if thickness > 60 { impact += 8 } // 厚い耳は粘り強く成功しやすい
        if position == .high { impact += 5 } // 耳が顔より高め位置にある人は頭脳明晰で仕事運良
        if condition == .good { impact += 5 }
        return impact
    }
    
    var wealthImpact: Int {
        var impact = 0
        if thickness > 70 { impact += 10 } // 大きな耳たぶ（福耳）は生涯金に困らない
        if condition == .good { impact += 5 }
        if position == .protruding { impact -= 5 } // 耳が前にせり出す（招風耳）は浪費暗示
        return impact
    }
    
    func generateAdvice() -> [DetailedAdvice] {
        var advice: [DetailedAdvice] = []
        
        if thickness < 40 {
            advice.append(DetailedAdvice(
                category: .lifestyle,
                title: "体力強化",
                description: "耳が薄い場合は体力強化を心がけましょう。適度な運動と十分な休息を取ることが大切です",
                priority: .medium
            ))
        }
        
        return advice
    }
}

// MARK: - 顎・輪郭の分析
struct JawAnalysis: Codable {
    let shape: JawShape
    let strength: Int // 強さ（0-100）
    let size: Int // 大きさ（0-100）
    let condition: JawCondition
    
    init() {
        self.shape = JawShape.allCases.randomElement() ?? .round
        self.strength = Int.random(in: 30...90)
        self.size = Int.random(in: 40...90)
        self.condition = JawCondition.allCases.randomElement() ?? .good
    }
    
    var loveImpact: Int {
        var impact = 0
        if shape == .round { impact += 8 } // 丸い顎先は包容力があり家庭運◎
        if size > 50 { impact += 3 }
        if size < 30 { impact -= 5 } // 小さすぎる顎は他者への関心薄く独りを好む傾向
        return impact
    }
    
    var healthImpact: Int {
        var impact = 0
        if shape == .round { impact += 8 } // 丸い顎の人は胃腸強く長命傾向
        if strength > 60 { impact += 5 }
        if condition == .good { impact += 5 }
        return impact
    }
    
    var careerImpact: Int {
        var impact = 0
        if shape == .square && strength > 70 { impact += 10 } // 四角いしっかりした顎は強い信念で仕事を成し遂げる力
        if size > 60 { impact += 5 } // 顎先に肉がある人は粘り強く経営者タイプ
        if condition == .good { impact += 5 }
        return impact
    }
    
    var wealthImpact: Int {
        var impact = 0
        if shape == .round && size > 60 { impact += 8 } // 丸くふくよかな顎は老後の財運◎
        if condition == .good { impact += 5 }
        if shape == .pointed { impact -= 5 } // しゃくれ・尖り顎はお金を貯める執着に欠け散財しやすい
        return impact
    }
    
    func generateAdvice() -> [DetailedAdvice] {
        var advice: [DetailedAdvice] = []
        
        if shape == .pointed {
            advice.append(DetailedAdvice(
                category: .lifestyle,
                title: "貯蓄習慣",
                description: "尖った顎の人は散財しやすい傾向があります。計画的にお金を使う習慣を身につけましょう",
                priority: .medium
            ))
        }
        
        if strength < 40 {
            advice.append(DetailedAdvice(
                category: .lifestyle,
                title: "決断力強化",
                description: "顎が弱い人は決断力に欠ける恐れがあります。小さな決断から練習して自信をつけましょう",
                priority: .medium
            ))
        }
        
        return advice
    }
}

// MARK: - 肌の分析
struct SkinAnalysis: Codable {
    let texture: Int // 肌質（0-100）
    let color: Int // 色艶（0-100）
    let spots: Int // シミ・ホクロ（0-100）
    let condition: SkinCondition
    
    init() {
        self.texture = Int.random(in: 40...90)
        self.color = Int.random(in: 30...90)
        self.spots = Int.random(in: 10...70)
        self.condition = SkinCondition.allCases.randomElement() ?? .good
    }
    
    var healthImpact: Int {
        var impact = 0
        if condition == .good { impact += 10 }
        if texture > 70 { impact += 5 }
        if color > 70 { impact += 5 }
        if spots < 30 { impact += 5 }
        if condition == .dry { impact -= 5 }
        if condition == .acne { impact -= 8 }
        return impact
    }
    
    func generateAdvice() -> [DetailedAdvice] {
        var advice: [DetailedAdvice] = []
        
        if condition == .dry {
            advice.append(DetailedAdvice(
                category: .beauty,
                title: "保湿ケア",
                description: "肌が乾燥している場合は保湿ケアを徹底しましょう。水分補給も重要です",
                priority: .medium
            ))
        }
        
        if condition == .acne {
            advice.append(DetailedAdvice(
                category: .health,
                title: "ホルモンバランス",
                description: "顎ニキビはホルモンバランス不調のサインです。規則正しい生活を心がけましょう",
                priority: .high
            ))
        }
        
        return advice
    }
}

// MARK: - 詳細アドバイス
struct DetailedAdvice: Codable, Identifiable {
    let id: UUID
    let category: AdviceCategory
    let title: String
    let description: String
    let priority: AdvicePriority
    
    init(id: UUID = UUID(), category: AdviceCategory, title: String, description: String, priority: AdvicePriority) {
        self.id = id
        self.category = category
        self.title = title
        self.description = description
        self.priority = priority
    }
    
    enum CodingKeys: String, CodingKey {
        case id, category, title, description, priority
    }
}

// MARK: - アドバイス優先度
enum AdvicePriority: String, CaseIterable, Codable {
    case low = "低"
    case medium = "中"
    case high = "高"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - 顔相タイプ
enum FaceType: String, CaseIterable, Codable {
    case fortunate = "福相"
    case energetic = "元気相"
    case tired = "疲労相"
    case stressed = "ストレス相"
    case balanced = "バランス相"
    
    var description: String {
        switch self {
        case .fortunate:
            return "運気が上昇している状態です。積極的に行動すると良い結果が期待できます。"
        case .energetic:
            return "エネルギーに満ち溢れています。新しいことにチャレンジするのに適した時期です。"
        case .tired:
            return "疲労が蓄積している状態です。十分な休息を取ることをお勧めします。"
        case .stressed:
            return "ストレスが溜まっている状態です。リラックスする時間を作りましょう。"
        case .balanced:
            return "バランスの取れた状態です。現状維持を心がけると良いでしょう。"
        }
    }
    
    var color: Color {
        switch self {
        case .fortunate: return .orange
        case .energetic: return .green
        case .tired: return .blue
        case .stressed: return .red
        case .balanced: return .purple
        }
    }
}

// MARK: - 気分タイプ
enum MoodType: String, CaseIterable, Codable {
    case happy = "明るい"
    case calm = "落ち着いた"
    case excited = "興奮"
    case worried = "心配"
    case neutral = "普通"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .calm: return "😌"
        case .excited: return "🤩"
        case .worried: return "😟"
        case .neutral: return "😐"
        }
    }
}

// MARK: - アドバイスカテゴリ
enum AdviceCategory: String, CaseIterable, Codable {
    case lifestyle = "ライフスタイル"
    case beauty = "美容"
    case health = "健康"
    case communication = "コミュニケーション"
    case exercise = "表情筋エクササイズ"
    case diet = "食事"
    case mental = "メンタルケア"
    
    var icon: String {
        switch self {
        case .lifestyle: return "house.fill"
        case .beauty: return "sparkles"
        case .health: return "heart.fill"
        case .communication: return "message.fill"
        case .exercise: return "figure.walk"
        case .diet: return "leaf.fill"
        case .mental: return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .lifestyle: return .blue
        case .beauty: return .pink
        case .health: return .green
        case .communication: return .orange
        case .exercise: return .purple
        case .diet: return .mint
        case .mental: return .indigo
        }
    }
}

// MARK: - アドバイスアイテム
struct AdviceItem: Identifiable {
    let id = UUID()
    let category: AdviceCategory
    let title: String
    let description: String
    let duration: String
    let difficulty: String
    let isCompleted: Bool = false
}

// MARK: - 額の形状
enum ForeheadShape: String, CaseIterable, Codable {
    case round = "丸い"
    case square = "四角い"
    case narrow = "狭い"
    case wide = "広い"
}

// MARK: - 額の状態
enum ForeheadCondition: String, CaseIterable, Codable {
    case good = "良好"
    case stress = "ストレス"
    case wrinkle = "シワ"
    case blemish = "傷"
}

// MARK: - 眉の形状
enum EyebrowShape: String, CaseIterable, Codable {
    case natural = "自然な弧"
    case straight = "一文字"
    case angry = "吊り上がり"
    case thin = "細い"
}

// MARK: - 眉の位置
enum EyebrowPosition: String, CaseIterable, Codable {
    case close = "眉目間隔狭い"
    case normal = "普通"
    case high = "高い"
}

// MARK: - 眉の状態
enum EyebrowCondition: String, CaseIterable, Codable {
    case good = "良好"
    case thin = "薄い"
    case messy = "乱れ"
}

// MARK: - 目の形状
enum EyeShape: String, CaseIterable, Codable {
    case normal = "普通"
    case sharp = "鋭い"
    case round = "丸い"
    case narrow = "細い"
}

// MARK: - 目の状態
enum EyeCondition: String, CaseIterable, Codable {
    case good = "良好"
    case tired = "疲労"
    case red = "充血"
    case dark = "クマ"
}

// MARK: - 鼻の形状
enum NoseShape: String, CaseIterable, Codable {
    case straight = "まっすぐ"
    case curved = "曲がり"
    case wide = "幅広"
    case narrow = "細い"
}

// MARK: - 鼻先の形状
enum NoseTip: String, CaseIterable, Codable {
    case round = "丸い"
    case pointed = "尖った"
    case flat = "平ら"
}

// MARK: - 鼻の状態
enum NoseCondition: String, CaseIterable, Codable {
    case good = "良好"
    case red = "赤い"
    case black = "黒ずみ"
}

// MARK: - 口の形状
enum MouthShape: String, CaseIterable, Codable {
    case natural = "自然"
    case upturned = "上向き"
    case downturned = "下向き"
    case wide = "大きい"
}

// MARK: - 口の状態
enum MouthCondition: String, CaseIterable, Codable {
    case good = "良好"
    case dry = "乾燥"
    case chapped = "荒れ"
}

// MARK: - 頬の状態
enum CheekCondition: String, CaseIterable, Codable {
    case good = "良好"
    case thin = "痩せ"
    case red = "赤ら顔"
}

// MARK: - 耳の位置
enum EarPosition: String, CaseIterable, Codable {
    case normal = "普通"
    case high = "高い"
    case low = "低い"
    case protruding = "前に出る"
}

// MARK: - 耳の形状
enum EarShape: String, CaseIterable, Codable {
    case round = "丸い"
    case pointed = "尖った"
    case large = "大きい"
    case small = "小さい"
}

// MARK: - 耳の状態
enum EarCondition: String, CaseIterable, Codable {
    case good = "良好"
    case dark = "黒ずみ"
    case thin = "薄い"
}

// MARK: - 顎の形状
enum JawShape: String, CaseIterable, Codable {
    case round = "丸い"
    case square = "四角い"
    case pointed = "尖った"
    case weak = "弱い"
}

// MARK: - 顎の状態
enum JawCondition: String, CaseIterable, Codable {
    case good = "良好"
    case acne = "ニキビ"
    case weak = "弱い"
}

// MARK: - 肌の状態
enum SkinCondition: String, CaseIterable, Codable {
    case good = "良好"
    case dry = "乾燥"
    case oily = "脂性"
    case acne = "ニキビ"
} 