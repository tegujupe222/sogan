//
//  DiagnosisResultView.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/06.
//

import SwiftUI

struct DiagnosisResultView: View {
    let result: FaceReadingResult
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var animateContent = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // ヘッダー
                        VStack(spacing: 15) {
                            Text("診断結果")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.primary, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text(result.date, style: .date)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : -20)
                        .animation(.easeOut(duration: 0.6), value: animateContent)
                        
                        // 顔相タイプカード
                        FaceTypeCard(result: result)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.1), value: animateContent)
                        
                        // 運気スコア
                        LuckScoresView(result: result)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.2), value: animateContent)
                        
                        // 表情分析
                        ExpressionAnalysisView(result: result)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                        
                        // 詳細な顔パーツ分析
                        DetailedFaceAnalysisView(result: result)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.4), value: animateContent)
                        
                        // 詳細アドバイス
                        DetailedAdviceView(result: result)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.5), value: animateContent)
                        
                        // 基本アドバイス
                        BasicAdviceView(result: result)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.6), value: animateContent)
                        
                        // アクションボタン
                        ActionButtonsView(showingShareSheet: $showingShareSheet)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.7), value: animateContent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("閉じる")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.orange)
                    }
                }
            }
        }
        .onAppear {
            animateContent = true
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: ["今日の顔相診断結果をシェアしました！"])
        }
    }
}

// MARK: - 顔相タイプカード
struct FaceTypeCard: View {
    let result: FaceReadingResult
    @State private var animateCard = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(result.faceType.rawValue)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(result.faceType.description)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                
                Spacer()
                
                Text(result.moodType.emoji)
                    .font(.system(size: 48))
                    .scaleEffect(animateCard ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: animateCard
                    )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [result.faceType.color, result.faceType.color.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: result.faceType.color.opacity(0.3), radius: 15, x: 0, y: 8)
        )
        .onAppear {
            animateCard = true
        }
    }
}

// MARK: - 運気スコアビュー
struct LuckScoresView: View {
    let result: FaceReadingResult
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("運気スコア")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                LuckScoreCard(title: "総合運", score: result.overallLuck, color: .orange, icon: "star.fill")
                LuckScoreCard(title: "恋愛運", score: result.loveLuck, color: .pink, icon: "heart.fill")
                LuckScoreCard(title: "健康運", score: result.healthLuck, color: .green, icon: "leaf.fill")
                LuckScoreCard(title: "仕事運", score: result.careerLuck, color: .blue, icon: "briefcase.fill")
                LuckScoreCard(title: "金運", score: result.wealthLuck, color: .yellow, icon: "dollarsign.circle.fill")
            }
        }
    }
}

// MARK: - 運気スコアカード
struct LuckScoreCard: View {
    let title: String
    let score: Int
    let color: Color
    let icon: String
    @State private var animateProgress = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack {
                Text("\(score)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text("/ 100")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            ProgressView(value: animateProgress ? Double(score) : 0, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .frame(height: 6)
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateProgress = true
            }
        }
    }
}

// MARK: - 表情分析ビュー
struct ExpressionAnalysisView: View {
    let result: FaceReadingResult
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("表情分析")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 16) {
                ExpressionScoreRow(title: "笑顔度", score: result.smileScore, color: .orange, icon: "face.smiling")
                ExpressionScoreRow(title: "エネルギー", score: result.energyScore, color: .green, icon: "bolt.fill")
                ExpressionScoreRow(title: "ストレス", score: result.stressScore, color: .red, icon: "exclamationmark.triangle.fill", isReversed: true)
            }
        }
    }
}

// MARK: - 表情スコア行
struct ExpressionScoreRow: View {
    let title: String
    let score: Int
    let color: Color
    let icon: String
    let isReversed: Bool
    @State private var animateProgress = false
    
    init(title: String, score: Int, color: Color, icon: String, isReversed: Bool = false) {
        self.title = title
        self.score = score
        self.color = color
        self.icon = icon
        self.isReversed = isReversed
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(score)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                }
                
                ProgressView(value: animateProgress ? Double(score) : 0, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .frame(height: 6)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                animateProgress = true
            }
        }
    }
}

// MARK: - 詳細な顔パーツ分析ビュー
struct DetailedFaceAnalysisView: View {
    let result: FaceReadingResult
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("詳細な顔パーツ分析")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 16) {
                FacePartAnalysisCard(
                    title: "額",
                    analysis: result.faceAnalysis.forehead,
                    icon: "brain.head.profile",
                    color: .blue
                )
                FacePartAnalysisCard(
                    title: "眉",
                    analysis: result.faceAnalysis.eyebrows,
                    icon: "eyebrow",
                    color: .brown
                )
                FacePartAnalysisCard(
                    title: "目",
                    analysis: result.faceAnalysis.eyes,
                    icon: "eye",
                    color: .purple
                )
                FacePartAnalysisCard(
                    title: "鼻",
                    analysis: result.faceAnalysis.nose,
                    icon: "nose",
                    color: .orange
                )
                FacePartAnalysisCard(
                    title: "口・唇",
                    analysis: result.faceAnalysis.mouth,
                    icon: "mouth",
                    color: .pink
                )
                FacePartAnalysisCard(
                    title: "頬",
                    analysis: result.faceAnalysis.cheeks,
                    icon: "face.smiling",
                    color: .red
                )
                FacePartAnalysisCard(
                    title: "耳",
                    analysis: result.faceAnalysis.ears,
                    icon: "ear",
                    color: .green
                )
                FacePartAnalysisCard(
                    title: "顎・輪郭",
                    analysis: result.faceAnalysis.jaw,
                    icon: "face.smiling",
                    color: .gray
                )
                FacePartAnalysisCard(
                    title: "肌",
                    analysis: result.faceAnalysis.skin,
                    icon: "sparkles",
                    color: .yellow
                )
            }
        }
    }
}

// MARK: - 顔パーツ分析カード
struct FacePartAnalysisCard: View {
    let title: String
    let analysis: Any
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // 各パーツの特徴を表示
                if let forehead = analysis as? ForeheadAnalysis {
                    AnalysisDetailRow(label: "形状", value: forehead.shape.rawValue)
                    AnalysisDetailRow(label: "艶", value: "\(forehead.luster)")
                    AnalysisDetailRow(label: "幅", value: "\(forehead.width)")
                    AnalysisDetailRow(label: "高さ", value: "\(forehead.height)")
                } else if let eyebrows = analysis as? EyebrowAnalysis {
                    AnalysisDetailRow(label: "形状", value: eyebrows.shape.rawValue)
                    AnalysisDetailRow(label: "濃さ", value: "\(eyebrows.thickness)")
                    AnalysisDetailRow(label: "長さ", value: "\(eyebrows.length)")
                    AnalysisDetailRow(label: "位置", value: eyebrows.position.rawValue)
                } else if let eyes = analysis as? EyeAnalysis {
                    AnalysisDetailRow(label: "大きさ", value: "\(eyes.size)")
                    AnalysisDetailRow(label: "形状", value: eyes.shape.rawValue)
                    AnalysisDetailRow(label: "涙袋", value: "\(eyes.tearBag)")
                    AnalysisDetailRow(label: "輝き", value: "\(eyes.brightness)")
                } else if let nose = analysis as? NoseAnalysis {
                    AnalysisDetailRow(label: "高さ", value: "\(nose.height)")
                    AnalysisDetailRow(label: "幅", value: "\(nose.width)")
                    AnalysisDetailRow(label: "形状", value: nose.shape.rawValue)
                    AnalysisDetailRow(label: "鼻先", value: nose.tip.rawValue)
                } else if let mouth = analysis as? MouthAnalysis {
                    AnalysisDetailRow(label: "大きさ", value: "\(mouth.size)")
                    AnalysisDetailRow(label: "唇厚み", value: "\(mouth.lipThickness)")
                    AnalysisDetailRow(label: "口角角度", value: "\(mouth.cornerAngle)")
                    AnalysisDetailRow(label: "形状", value: mouth.shape.rawValue)
                } else if let cheeks = analysis as? CheekAnalysis {
                    AnalysisDetailRow(label: "肉付き", value: "\(cheeks.fullness)")
                    AnalysisDetailRow(label: "血色", value: "\(cheeks.color)")
                    AnalysisDetailRow(label: "頬骨高さ", value: "\(cheeks.boneHeight)")
                } else if let ears = analysis as? EarAnalysis {
                    AnalysisDetailRow(label: "大きさ", value: "\(ears.size)")
                    AnalysisDetailRow(label: "厚み", value: "\(ears.thickness)")
                    AnalysisDetailRow(label: "位置", value: ears.position.rawValue)
                    AnalysisDetailRow(label: "形状", value: ears.shape.rawValue)
                } else if let jaw = analysis as? JawAnalysis {
                    AnalysisDetailRow(label: "形状", value: jaw.shape.rawValue)
                    AnalysisDetailRow(label: "強さ", value: "\(jaw.strength)")
                    AnalysisDetailRow(label: "大きさ", value: "\(jaw.size)")
                } else if let skin = analysis as? SkinAnalysis {
                    AnalysisDetailRow(label: "肌質", value: "\(skin.texture)")
                    AnalysisDetailRow(label: "色艶", value: "\(skin.color)")
                    AnalysisDetailRow(label: "シミ・ホクロ", value: "\(skin.spots)")
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - 分析詳細行
struct AnalysisDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - 詳細アドバイスビュー
struct DetailedAdviceView: View {
    let result: FaceReadingResult
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("詳細アドバイス")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            LazyVStack(spacing: 16) {
                ForEach(result.detailedAdvice) { advice in
                    DetailedAdviceCard(advice: advice)
                }
            }
        }
    }
}

// MARK: - 詳細アドバイスカード
struct DetailedAdviceCard: View {
    let advice: DetailedAdvice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: advice.category.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(advice.category.color)
                    .frame(width: 24)
                
                Text(advice.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(advice.priority.rawValue)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(advice.priority.color)
                    .clipShape(Capsule())
            }
            
            Text(advice.description)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - 基本アドバイスビュー
struct BasicAdviceView: View {
    let result: FaceReadingResult
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("基本アドバイス")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            LazyVStack(spacing: 16) {
                ForEach(Array(result.advice.enumerated()), id: \.offset) { index, advice in
                    BasicAdviceCard(advice: advice, index: index + 1)
                }
            }
        }
    }
}

// MARK: - 基本アドバイスカード
struct BasicAdviceCard: View {
    let advice: String
    let index: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 番号
            Circle()
                .fill(Color.orange)
                .frame(width: 24, height: 24)
                .overlay(
                    Text("\(index)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                )
            
            // アドバイステキスト
            Text(advice)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - アクションボタンビュー
struct ActionButtonsView: View {
    @Binding var showingShareSheet: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Button(action: {
                showingShareSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("結果をシェア")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.orange)
                .cornerRadius(25)
            }
            
            Button(action: {
                // 履歴に保存する処理は既に完了済み
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("履歴に保存済み")
                }
                .font(.headline)
                .foregroundColor(.green)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.green.opacity(0.1))
                .cornerRadius(25)
            }
            .disabled(true)
        }
    }
}

// MARK: - シェアシート
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    DiagnosisResultView(result: FaceReadingResult(userId: UUID()))
} 