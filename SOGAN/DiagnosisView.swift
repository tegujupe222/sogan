//
//  DiagnosisView.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/06.
//

import SwiftUI
import AVFoundation

struct DiagnosisView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var showingResult = false
    @State private var diagnosisResult: FaceReadingResult?
    @State private var animateGradient = false
    @State private var showingUserManagement = false
    @State private var showingPurchase = false
    
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
                            // タイトルと課金ボタン
                            HStack {
                                VStack(spacing: 8) {
                                    Text("今日の顔相診断")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.primary, .orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    
                                    Text("カメラで自撮りして運気をチェック")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // 課金ボタン
                                PremiumButton {
                                    showingPurchase = true
                                }
                            }
                            .padding(.top, 20)
                            
                            // 装飾的な要素
                            HStack(spacing: 20) {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.orange.opacity(0.6), .pink.opacity(0.6)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(animateGradient ? 1.2 : 1.0)
                                        .animation(
                                            Animation.easeInOut(duration: 1.5)
                                                .repeatForever(autoreverses: true)
                                                .delay(Double(index) * 0.3),
                                            value: animateGradient
                                        )
                                }
                            }
                        }
                        
                        // ユーザー選択・管理
                        if let currentUser = dataManager.getSelectedUser() {
                            CurrentUserBanner(user: currentUser) {
                                showingUserManagement = true
                            }
                        } else {
                            NoUserBanner {
                                showingUserManagement = true
                            }
                        }
                        
                        // メインコンテンツ
                        VStack(spacing: 40) {
                            // 今日の診断状況
                            if dataManager.hasTodayDiagnosis() {
                                TodayResultsCard(results: dataManager.getTodayResults())
                            } else {
                                // 診断開始カード
                                DiagnosisStartCard(
                                    onCameraTap: { showingCamera = true },
                                    onPhotoTap: { showingImagePicker = true }
                                )
                            }
                            
                            // 統計情報
                            if !dataManager.faceReadingHistory.isEmpty {
                                StatisticsCard()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            animateGradient = true
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                selectedImage = image
                performDiagnosis(with: image)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, onImageSelected: { image in
                performDiagnosis(with: image)
            })
        }
        .sheet(isPresented: $showingResult) {
            if let result = diagnosisResult {
                DiagnosisResultView(result: result)
            }
        }
        .sheet(isPresented: $showingUserManagement) {
            UserManagementView()
        }
        .sheet(isPresented: $showingPurchase) {
            PurchaseView()
        }
        .overlay(
            Group {
                if isAnalyzing {
                    AnalyzingView()
                }
            }
        )
    }
    
    private func performDiagnosis(with image: UIImage) {
        guard let currentUserId = dataManager.selectedUserId else {
            // ユーザーが選択されていない場合はユーザー管理画面を表示
            showingUserManagement = true
            return
        }
        
        isAnalyzing = true
        
        // 実際のアプリではここでAI分析を行う
        // 現在はダミーデータを使用
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let result = FaceReadingResult(
                userId: currentUserId,
                imageData: image.jpegData(compressionQuality: 0.8)
            )
            diagnosisResult = result
            dataManager.addHistory(result)
            isAnalyzing = false
            showingResult = true
        }
    }
}

// MARK: - 現在のユーザーバナー
struct CurrentUserBanner: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // プロフィール画像
                if let imageData = user.profileImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.orange, lineWidth: 2))
                } else {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.orange)
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if let nickname = user.nickname {
                        Text(nickname)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

// MARK: - ユーザー未選択バナー
struct NoUserBanner: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 18))
                            .foregroundColor(.orange)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("ユーザーを選択してください")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("診断を開始するにはユーザーを登録・選択してください")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

// MARK: - 今日の診断結果カード（複数回対応）
struct TodayResultsCard: View {
    let results: [FaceReadingResult]
    @State private var selectedResult: FaceReadingResult?
    @State private var showingResult = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("今日の診断結果")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(results.count)回")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
            
            if results.count == 1 {
                // 1回のみの場合は大きなカード
                SingleResultCard(result: results[0]) {
                    selectedResult = results[0]
                    showingResult = true
                }
            } else {
                // 複数回の場合はリスト表示
                LazyVStack(spacing: 12) {
                    ForEach(results) { result in
                        ResultListItem(result: result) {
                            selectedResult = result
                            showingResult = true
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .sheet(isPresented: $showingResult) {
            if let result = selectedResult {
                DiagnosisResultView(result: result)
            }
        }
    }
}

// MARK: - 単一結果カード
struct SingleResultCard: View {
    let result: FaceReadingResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 画像
                if let imageData = result.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(result.faceType.rawValue)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(result.moodType.emoji)
                            .font(.system(size: 24))
                    }
                    
                    Text("総合運: \(result.overallLuck)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(result.date, style: .time)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 結果リストアイテム
struct ResultListItem: View {
    let result: FaceReadingResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 画像
                if let imageData = result.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 16))
                                .foregroundColor(.orange)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(result.faceType.rawValue)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(result.moodType.emoji)
                            .font(.system(size: 16))
                    }
                    
                    Text("総合運: \(result.overallLuck) | \(result.date, style: .time)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 診断開始カード
struct DiagnosisStartCard: View {
    let onCameraTap: () -> Void
    let onPhotoTap: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            // メインアイコン
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.2), .pink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Image(systemName: "camera.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // テキスト
            VStack(spacing: 12) {
                Text("診断を開始")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("カメラで自撮りして顔相を診断しましょう")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // アクションボタン
            VStack(spacing: 16) {
                // カメラボタン
                Button(action: onCameraTap) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("カメラで撮影")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(28)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                // 写真選択ボタン
                Button(action: onPhotoTap) {
                    HStack(spacing: 12) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("写真を選択")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.orange.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - 今日の結果カード
struct TodayResultCard: View {
    let result: FaceReadingResult
    @State private var animateScores = false
    
    var body: some View {
        VStack(spacing: 20) {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日の診断結果")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("\(result.date, style: .date)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(result.moodType.emoji)
                    .font(.system(size: 32))
            }
            
            // 運気スコア
            HStack(spacing: 20) {
                LuckScoreView(title: "総合運", score: result.overallLuck, color: .orange)
                LuckScoreView(title: "恋愛運", score: result.loveLuck, color: .pink)
                LuckScoreView(title: "健康運", score: result.healthLuck, color: .green)
                LuckScoreView(title: "金運", score: result.wealthLuck, color: .yellow)
            }
            .opacity(animateScores ? 1.0 : 0.0)
            .offset(y: animateScores ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.2), value: animateScores)
            
            // 顔相タイプ
            HStack {
                Text(result.faceType.rawValue)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [result.faceType.color, result.faceType.color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                
                Spacer()
                
                Text("詳細を見る")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.orange)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            animateScores = true
        }
    }
}

// MARK: - 運気スコアビュー
struct LuckScoreView: View {
    let title: String
    let score: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("\(score)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            // プログレスバー
            ProgressView(value: Double(score), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .frame(width: 40, height: 4)
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 統計カード
struct StatisticsCard: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var animateStats = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("統計情報")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 20) {
                StatItem(
                    title: "平均運気",
                    value: "\(dataManager.getAverageLuck())",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )
                StatItem(
                    title: "診断回数",
                    value: "\(dataManager.faceReadingHistory.count)",
                    icon: "number.circle.fill",
                    color: .blue
                )
                StatItem(
                    title: "最高運気",
                    value: "\(dataManager.getHighestLuck())",
                    icon: "star.fill",
                    color: .yellow
                )
            }
            .opacity(animateStats ? 1.0 : 0.0)
            .offset(y: animateStats ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.1), value: animateStats)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            animateStats = true
        }
    }
}

// MARK: - 統計アイテム
struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 分析中ビュー
struct AnalyzingView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // 背景ブラー
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .blur(radius: 3)
            
            VStack(spacing: 24) {
                // アニメーションアイコン
                ZStack {
                    Circle()
                        .stroke(Color.orange.opacity(0.3), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(
                            Animation.linear(duration: 1.0)
                                .repeatForever(autoreverses: false),
                            value: rotationAngle
                        )
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.orange)
                }
                
                VStack(spacing: 8) {
                    Text("顔相を分析中...")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("しばらくお待ちください")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(isAnimating ? 1.0 : 0.9)
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.3), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
            rotationAngle = 360
        }
    }
}

#Preview {
    DiagnosisView()
}

// MARK: - プレミアムボタン
struct PremiumButton: View {
    let onTap: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isAnimating ? 15 : -15))
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Text("プレミアム")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [.orange, .pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .animation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
        }
        .onAppear {
            isAnimating = true
        }
    }
} 