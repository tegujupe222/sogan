//
//  SettingsView.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/06.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingPrivacyPolicy = false
    @State private var showingLegalDocuments = false
    @State private var showingPurchase = false
    @State private var showingDeleteConfirmation = false
    @State private var showingAbout = false
    @State private var showingUserManagement = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("dailyReminderTime") private var dailyReminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
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
                            Text("設定")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.primary, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        .padding(.top, 20)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : -20)
                        .animation(.easeOut(duration: 0.6), value: animateContent)
                        
                        // ユーザー管理
                        SettingsSection(
                            title: "ユーザー管理",
                            icon: "person.2.fill",
                            color: .orange
                        ) {
                            VStack(spacing: 16) {
                                if let currentUser = dataManager.getSelectedUser() {
                                    SettingsInfoRow(
                                        title: "現在のユーザー",
                                        value: currentUser.name,
                                        icon: "person.fill"
                                    )
                                    
                                    if let profile = dataManager.getUserProfile(for: currentUser.id) {
                                        SettingsInfoRow(
                                            title: "総診断回数",
                                            value: "\(profile.totalDiagnoses)回",
                                            icon: "chart.bar.fill"
                                        )
                                        
                                        SettingsInfoRow(
                                            title: "連続診断日数",
                                            value: "\(profile.streakDays)日",
                                            icon: "flame.fill"
                                        )
                                    }
                                }
                                
                                SettingsButtonRow(
                                    title: "ユーザー管理",
                                    icon: "person.badge.plus",
                                    color: .blue
                                ) {
                                    showingUserManagement = true
                                }
                            }
                        }
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.1), value: animateContent)
                        
                        // 通知設定
                        SettingsSection(
                            title: "通知設定",
                            icon: "bell.fill",
                            color: .green
                        ) {
                            VStack(spacing: 16) {
                                SettingsToggleRow(
                                    title: "毎日の診断リマインダー",
                                    isOn: $notificationsEnabled,
                                    icon: "bell.badge"
                                )
                                
                                if notificationsEnabled {
                                    SettingsDateRow(
                                        title: "通知時間",
                                        date: $dailyReminderTime,
                                        icon: "clock.fill"
                                    )
                                }
                            }
                        }
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateContent)
                        
                        // プレミアム機能
                        SettingsSection(
                            title: "プレミアム機能",
                            icon: "crown.fill",
                            color: .orange
                        ) {
                            VStack(spacing: 16) {
                                // プレミアム機能の説明
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.orange)
                                        
                                        Text("プレミアム機能でさらに詳しく")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        PremiumFeatureRow(
                                            icon: "chart.line.uptrend.xyaxis",
                                            title: "詳細分析アンロック",
                                            description: "より詳細な運気分析を確認"
                                        )
                                        
                                        PremiumFeatureRow(
                                            icon: "clock.arrow.circlepath",
                                            title: "履歴保存期間延長",
                                            description: "診断履歴を長期間保存"
                                        )
                                        
                                        PremiumFeatureRow(
                                            icon: "square.and.arrow.up",
                                            title: "結果エクスポート",
                                            description: "診断結果を画像で保存"
                                        )
                                    }
                                    .padding(.leading, 28)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.orange.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                
                                // プレミアムボタン
                                Button(action: {
                                    showingPurchase = true
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("プレミアム機能を確認")
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                            
                                            Text("詳細分析・履歴保存・エクスポート")
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    .padding(20)
                                    .background(
                                        LinearGradient(
                                            colors: [.orange, .pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                            }
                        }
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                        
                        // データ管理
                        SettingsSection(
                            title: "データ管理",
                            icon: "folder.fill",
                            color: .blue
                        ) {
                            VStack(spacing: 16) {
                                SettingsInfoRow(
                                    title: "診断履歴",
                                    value: "\(dataManager.faceReadingHistory.count)件",
                                    icon: "doc.text.fill"
                                )
                                
                                SettingsInfoRow(
                                    title: "登録ユーザー数",
                                    value: "\(dataManager.users.count)人",
                                    icon: "person.3.fill"
                                )
                                
                                SettingsButtonRow(
                                    title: "全ての履歴を削除",
                                    icon: "trash.fill",
                                    color: .red
                                ) {
                                    showingDeleteConfirmation = true
                                }
                            }
                        }
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: animateContent)
                        
                        // アプリ情報
                        SettingsSection(
                            title: "アプリ情報",
                            icon: "info.circle.fill",
                            color: .purple
                        ) {
                            VStack(spacing: 16) {
                                SettingsButtonRow(
                                    title: "アプリについて",
                                    icon: "info.circle.fill",
                                    color: .blue
                                ) {
                                    showingAbout = true
                                }
                                
                                SettingsButtonRow(
                                    title: "法的文書",
                                    icon: "doc.text.fill",
                                    color: .purple
                                ) {
                                    showingLegalDocuments = true
                                }
                                
                                SettingsInfoRow(
                                    title: "バージョン",
                                    value: "1.0.1",
                                    icon: "tag.fill"
                                )
                            }
                        }
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.5), value: animateContent)
                        
                        // 開発者情報
                        SettingsSection(
                            title: "開発者情報",
                            icon: "person.2.fill",
                            color: .pink
                        ) {
                            VStack(spacing: 16) {
                                SettingsInfoRow(
                                    title: "開発者",
                                    value: "SOGAN Team",
                                    icon: "person.fill"
                                )
                                
                                SettingsLinkRow(
                                    title: "公式ウェブサイト",
                                    icon: "globe",
                                    url: "https://example.com"
                                )
                            }
                        }
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.6), value: animateContent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            animateContent = true
        }
        .sheet(isPresented: $showingLegalDocuments) {
            LegalDocumentsView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingUserManagement) {
            UserManagementView()
        }
        .sheet(isPresented: $showingPurchase) {
            PurchaseView()
        }
        .alert("履歴を削除", isPresented: $showingDeleteConfirmation) {
            Button("削除", role: .destructive) {
                deleteAllHistory()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("全ての診断履歴が削除されます。この操作は取り消せません。")
        }
    }
    
    private func deleteAllHistory() {
        dataManager.faceReadingHistory.removeAll()
        dataManager.clearAllHistory()
    }
}

// MARK: - 設定セクション
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
        }
    }
}

// MARK: - 設定トグル行
struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.orange)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .orange))
        }
        .padding(20)
    }
}

// MARK: - 設定日付行
struct SettingsDateRow: View {
    let title: String
    @Binding var date: Date
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.orange)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .padding(20)
    }
}

// MARK: - 設定情報行
struct SettingsInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(20)
    }
}

// MARK: - 設定ボタン行
struct SettingsButtonRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 設定リンク行
struct SettingsLinkRow: View {
    let title: String
    let icon: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .padding(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - プライバシーポリシービュー
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                    VStack(alignment: .leading, spacing: 25) {
                        Text("プライバシーポリシー")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            PolicySection(
                                title: "1. データの収集について",
                                content: "SOGANアプリは、顔相診断のために撮影された写真を端末内でのみ処理します。写真は外部サーバーに送信されることはありません。"
                            )
                            
                            PolicySection(
                                title: "2. データの保存について",
                                content: "診断結果と写真は、ユーザーの端末内にのみ保存されます。iCloud同期機能を使用する場合を除き、データは外部に送信されません。"
                            )
                            
                            PolicySection(
                                title: "3. データの使用について",
                                content: "収集されたデータは、顔相診断機能の提供のみに使用されます。広告配信や第三者への提供には使用されません。"
                            )
                            
                            PolicySection(
                                title: "4. データの削除について",
                                content: "ユーザーは設定画面からいつでも診断履歴を削除できます。アプリを削除した場合、端末内のデータも削除されます。"
                            )
                            
                            PolicySection(
                                title: "5. カメラアクセスについて",
                                content: "アプリは顔相診断のためにカメラへのアクセスを要求します。カメラで撮影された写真は診断処理のみに使用されます。"
                            )
                            
                            PolicySection(
                                title: "6. お問い合わせ",
                                content: "プライバシーポリシーに関するご質問は、設定画面の「アプリについて」からお問い合わせください。"
                            )
                        }
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
    }
}

// MARK: - アプリについてビュー
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateIcon = false
    
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
                    VStack(spacing: 40) {
                        // アプリアイコン
                        VStack(spacing: 20) {
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
                                
                                Image(systemName: "face.smiling")
                                    .font(.system(size: 60, weight: .semibold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .pink],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            VStack(spacing: 8) {
                                Text("SOGAN")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.primary, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("顔相診断アプリ")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // アプリ説明
                        VStack(spacing: 20) {
                            AboutSection(
                                title: "アプリについて",
                                content: "SOGANは、伝統的な顔相学と現代のAI技術を組み合わせた顔相診断アプリです。あなたの表情から運気を分析し、改善のためのアドバイスを提供します。"
                            )
                            
                            AboutSection(
                                title: "主な機能",
                                content: "• 顔相診断\n• 運気スコア表示\n• 詳細なアドバイス\n• 診断履歴管理\n• 統計情報表示"
                            )
                            
                            AboutSection(
                                title: "開発チーム",
                                content: "SOGANは、顔相学の専門家とエンジニアが協力して開発したアプリです。科学的根拠に基づいた分析と、伝統的な知恵を融合させています。"
                            )
                        }
                        .padding(.horizontal, 20)
                    }
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
            animateIcon = true
        }
    }
}

// MARK: - アプリについてセクション
struct AboutSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(content)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - ポリシーセクション
struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(content)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - プレミアム機能行
struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.orange)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
} 