//
//  HistoryView.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/06.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showingDetail = false
    @State private var selectedResult: FaceReadingResult?
    @State private var animateContent = false
    @State private var showingUserManagement = false
    @State private var selectedDate: Date = Date()
    @State private var showingDatePicker = false
    
    enum TimeRange: String, CaseIterable {
        case week = "1週間"
        case month = "1ヶ月"
        case all = "全て"
        case daily = "日別"
        
        var days: Int? {
            switch self {
            case .week: return 7
            case .month: return 30
            case .all, .daily: return nil
            }
        }
    }
    
    var filteredResults: [FaceReadingResult] {
        switch selectedTimeRange {
        case .daily:
            if let currentUser = dataManager.getSelectedUser() {
                return dataManager.getHistoryForUserAndDate(currentUser.id, date: selectedDate)
            } else {
                return []
            }
        default:
            guard let days = selectedTimeRange.days else {
                return dataManager.faceReadingHistory
            }
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            return dataManager.faceReadingHistory.filter { $0.date >= startDate }
        }
    }
    
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
                
                VStack(spacing: 0) {
                    // ヘッダー
                    VStack(spacing: 20) {
                        Text("診断履歴")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // ユーザー情報
                        if let currentUser = dataManager.getSelectedUser() {
                            CurrentUserInfoCard(user: currentUser) {
                                showingUserManagement = true
                            }
                        } else {
                            NoUserInfoCard {
                                showingUserManagement = true
                            }
                        }
                        
                        // 期間選択
                        VStack(spacing: 12) {
                            HStack {
                                Text("期間")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            Picker("期間", selection: $selectedTimeRange) {
                                ForEach(TimeRange.allCases, id: \.self) { range in
                                    Text(range.rawValue).tag(range)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            // 日別選択の場合の日付選択
                            if selectedTimeRange == .daily {
                                HStack {
                                    Text("日付")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    
                                    Button(action: { showingDatePicker = true }) {
                                        HStack(spacing: 8) {
                                            Text(selectedDate, style: .date)
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(.primary)
                                            Image(systemName: "calendar")
                                                .font(.system(size: 14))
                                                .foregroundColor(.orange)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .opacity(animateContent ? 1.0 : 0.0)
                    .offset(y: animateContent ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animateContent)
                    
                    if dataManager.faceReadingHistory.isEmpty {
                        EmptyHistoryView()
                            .opacity(animateContent ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.6).delay(0.2), value: animateContent)
                    } else {
                        ScrollView {
                            VStack(spacing: 25) {
                                // 統計サマリー
                                StatisticsSummaryView(results: filteredResults)
                                    .opacity(animateContent ? 1.0 : 0.0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                                
                                // 履歴リスト
                                if selectedTimeRange == .daily {
                                    DailyHistoryListView(
                                        results: filteredResults,
                                        selectedDate: selectedDate,
                                        onResultSelected: { result in
                                            selectedResult = result
                                            showingDetail = true
                                        }
                                    )
                                    .opacity(animateContent ? 1.0 : 0.0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.6).delay(0.4), value: animateContent)
                                } else {
                                    HistoryListView(
                                        results: filteredResults,
                                        onResultSelected: { result in
                                            selectedResult = result
                                            showingDetail = true
                                        }
                                    )
                                    .opacity(animateContent ? 1.0 : 0.0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.6).delay(0.4), value: animateContent)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            animateContent = true
        }
        .sheet(isPresented: $showingDetail) {
            if let result = selectedResult {
                DiagnosisResultView(result: result)
            }
        }
        .sheet(isPresented: $showingUserManagement) {
            UserManagementView()
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerView(date: $selectedDate, title: "日付を選択")
        }
    }
}

// MARK: - 現在のユーザー情報カード
struct CurrentUserInfoCard: View {
    let user: User
    let onTap: () -> Void
    @ObservedObject var dataManager = DataManager.shared
    
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
                    
                    if let profile = dataManager.getUserProfile(for: user.id) {
                        Text("総診断回数: \(profile.totalDiagnoses)回 | 連続: \(profile.streakDays)日")
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

// MARK: - ユーザー未選択情報カード
struct NoUserInfoCard: View {
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
                    
                    Text("履歴を表示するにはユーザーを選択してください")
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

// MARK: - 日別履歴リストビュー
struct DailyHistoryListView: View {
    let results: [FaceReadingResult]
    let selectedDate: Date
    let onResultSelected: (FaceReadingResult) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(selectedDate, style: .date)
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
            
            if results.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(.orange.opacity(0.6))
                    
                    Text("この日は診断がありません")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(results) { result in
                        DailyResultCard(result: result) {
                            onResultSelected(result)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 日別結果カード
struct DailyResultCard: View {
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
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                        )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(result.faceType.rawValue)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(result.moodType.emoji)
                            .font(.system(size: 18))
                        
                        Spacer()
                        
                        Text(result.date, style: .time)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 16) {
                        LuckScoreMini(title: "総合", score: result.overallLuck, color: .orange)
                        LuckScoreMini(title: "恋愛", score: result.loveLuck, color: .pink)
                        LuckScoreMini(title: "健康", score: result.healthLuck, color: .green)
                        LuckScoreMini(title: "仕事", score: result.careerLuck, color: .blue)
                        LuckScoreMini(title: "金運", score: result.wealthLuck, color: .yellow)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
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
    }
}

// MARK: - 運気スコアミニ
struct LuckScoreMini: View {
    let title: String
    let score: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("\(score)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }
}

// MARK: - 空の履歴ビュー
struct EmptyHistoryView: View {
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // アニメーションアイコン
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
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: animateIcon
                    )
                
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("まだ診断履歴がありません")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("最初の診断を行って\nあなたの顔相を記録しましょう")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding(30)
        .onAppear {
            animateIcon = true
        }
    }
}

// MARK: - 統計サマリービュー
struct StatisticsSummaryView: View {
    let results: [FaceReadingResult]
    @State private var animateStats = false
    
    private var averageLuck: Int {
        guard !results.isEmpty else { return 0 }
        let total = results.reduce(0) { $0 + $1.overallLuck }
        return total / results.count
    }
    
    private var mostCommonFaceType: FaceType {
        let distribution = results.reduce(into: [FaceType: Int]()) { counts, result in
            counts[result.faceType, default: 0] += 1
        }
        return distribution.max(by: { $0.value < $1.value })?.key ?? .balanced
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("統計サマリー")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatSummaryCard(
                    title: "平均運気",
                    value: "\(averageLuck)",
                    subtitle: "ポイント",
                    color: .orange,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                StatSummaryCard(
                    title: "最多顔相",
                    value: mostCommonFaceType.rawValue,
                    subtitle: "タイプ",
                    color: mostCommonFaceType.color,
                    icon: "face.smiling"
                )
            }
            .opacity(animateStats ? 1.0 : 0.0)
            .offset(y: animateStats ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.2), value: animateStats)
        }
        .onAppear {
            animateStats = true
        }
    }
}

// MARK: - 統計サマリーカード
struct StatSummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    @State private var animateValue = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .scaleEffect(animateValue ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true),
                    value: animateValue
                )
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .onAppear {
            animateValue = true
        }
    }
}

// MARK: - 履歴リストビュー
struct HistoryListView: View {
    let results: [FaceReadingResult]
    let onResultSelected: (FaceReadingResult) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("診断履歴")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            LazyVStack(spacing: 16) {
                ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                    HistoryCard(
                        result: result,
                        onTap: { onResultSelected(result) }
                    )
                    .opacity(0)
                    .offset(y: 20)
                    .animation(
                        .easeOut(duration: 0.6)
                            .delay(Double(index) * 0.1),
                        value: results.count
                    )
                }
            }
        }
    }
}

// MARK: - 履歴カード
struct HistoryCard: View {
    let result: FaceReadingResult
    let onTap: () -> Void
    @State private var animateCard = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 日付とアイコン
                VStack(spacing: 8) {
                    Text(result.date, style: .date)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(result.moodType.emoji)
                        .font(.system(size: 24))
                        .scaleEffect(animateCard ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: animateCard
                        )
                }
                .frame(width: 60)
                
                // 顔相タイプ
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.faceType.rawValue)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(result.faceType.description)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // 運気スコア
                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(result.overallLuck)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Text("総合運")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                // 矢印アイコン
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            animateCard = true
        }
    }
}

#Preview {
    HistoryView()
} 