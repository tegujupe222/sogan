//
//  AdviceView.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/06.
//

import SwiftUI

struct AdviceView: View {
    @State private var selectedCategory: AdviceCategory = .lifestyle
    @State private var showingExerciseDetail = false
    @State private var selectedExercise: ExerciseItem?
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
                
                VStack(spacing: 0) {
                    // ヘッダー
                    VStack(spacing: 15) {
                        Text("改善アドバイス")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("顔相を改善するためのアドバイス")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .opacity(animateContent ? 1.0 : 0.0)
                    .offset(y: animateContent ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animateContent)
                    
                    // カテゴリ選択
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(Array(AdviceCategory.allCases.enumerated()), id: \.element) { index, category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedCategory = category
                                    }
                                }
                                .opacity(animateContent ? 1.0 : 0.0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: animateContent)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 10)
                    
                    // コンテンツ
                    ScrollView {
                        VStack(spacing: 25) {
                            switch selectedCategory {
                            case .lifestyle:
                                LifestyleAdviceView()
                                    .opacity(animateContent ? 1.0 : 0.0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                            case .beauty:
                                BeautyAdviceView()
                                    .opacity(animateContent ? 1.0 : 0.0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                            case .health:
                                HealthAdviceView()
                                    .opacity(animateContent ? 1.0 : 0.0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                            case .communication:
                                CommunicationAdviceView()
                                    .opacity(animateContent ? 1.0 : 0.0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                            case .exercise:
                                ExerciseAdviceView(
                                    onExerciseSelected: { exercise in
                                        selectedExercise = exercise
                                        showingExerciseDetail = true
                                    }
                                )
                                .opacity(animateContent ? 1.0 : 0.0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                            case .diet:
                                DietAdviceView()
                                    .opacity(animateContent ? 1.0 : 0.0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                            case .mental:
                                MentalAdviceView()
                                    .opacity(animateContent ? 1.0 : 0.0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            animateContent = true
        }
        .sheet(isPresented: $showingExerciseDetail) {
            if let exercise = selectedExercise {
                ExerciseDetailView(exercise: exercise)
            }
        }
    }
}

// MARK: - カテゴリボタン
struct CategoryButton: View {
    let category: AdviceCategory
    let isSelected: Bool
    let action: () -> Void
    @State private var animateButton = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? .white : category.color)
                    .scaleEffect(animateButton ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.3)
                            .repeatForever(autoreverses: true),
                        value: animateButton
                    )
                
                Text(category.rawValue)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 90, height: 90)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ? 
                        LinearGradient(
                            colors: [category.color, category.color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color(.systemBackground), Color(.systemBackground)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: isSelected ? category.color.opacity(0.3) : .black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            animateButton = true
        }
    }
}

// MARK: - ライフスタイルアドバイス
struct LifestyleAdviceView: View {
    let lifestyleAdvice = [
        AdviceItem(
            category: .lifestyle,
            title: "朝日を浴びる",
            description: "朝日を浴びることで体内時計が整い、表情が明るくなります。",
            duration: "5-10分",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .lifestyle,
            title: "十分な睡眠",
            description: "7-8時間の質の良い睡眠を取ることで、目の下のクマや疲労感が改善されます。",
            duration: "7-8時間",
            difficulty: "普通"
        ),
        AdviceItem(
            category: .lifestyle,
            title: "正しい姿勢",
            description: "猫背を直し、背筋を伸ばすことで顔の表情筋が自然に整います。",
            duration: "常時",
            difficulty: "普通"
        ),
        AdviceItem(
            category: .lifestyle,
            title: "水分補給",
            description: "1日2リットルの水を飲むことで、肌の調子が良くなり表情が豊かになります。",
            duration: "1日",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .lifestyle,
            title: "額のマッサージ",
            description: "額や眉間のマッサージで運気を開き、ストレスを軽減します。",
            duration: "5分",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .lifestyle,
            title: "貯蓄習慣",
            description: "計画的にお金を使う習慣を身につけ、金運アップを図りましょう。",
            duration: "常時",
            difficulty: "普通"
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("ライフスタイル改善")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            LazyVStack(spacing: 16) {
                ForEach(Array(lifestyleAdvice.enumerated()), id: \.element.id) { index, advice in
                    AdviceCard(advice: advice)
                        .opacity(0)
                        .offset(y: 20)
                        .animation(
                            .easeOut(duration: 0.6)
                                .delay(Double(index) * 0.1),
                            value: lifestyleAdvice.count
                        )
                }
            }
        }
    }
}

// MARK: - 美容アドバイス
struct BeautyAdviceView: View {
    let beautyAdvice = [
        AdviceItem(
            category: .beauty,
            title: "額のハイライト",
            description: "額にハイライトを足し明るい印象にすると上司運が向上します。",
            duration: "5分",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .beauty,
            title: "目尻アイライン",
            description: "目尻をアイラインで少し下げて柔らかな目元を演出すると恋愛運アップ。",
            duration: "3分",
            difficulty: "普通"
        ),
        AdviceItem(
            category: .beauty,
            title: "口角アップ練習",
            description: "口角を意識的に上げる練習をして、明るい表情を心がけましょう。",
            duration: "5分",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .beauty,
            title: "眉のケア",
            description: "眉を整えて濃さを調整することで、より好印象な表情になります。",
            duration: "10分",
            difficulty: "普通"
        ),
        AdviceItem(
            category: .beauty,
            title: "保湿ケア",
            description: "肌が乾燥している場合は保湿ケアを徹底しましょう。水分補給も重要です。",
            duration: "10分",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .beauty,
            title: "血色改善",
            description: "頬の血色を良くするために、適度な運動と十分な睡眠を心がけましょう。",
            duration: "30分",
            difficulty: "普通"
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("美容アドバイス")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            LazyVStack(spacing: 16) {
                ForEach(Array(beautyAdvice.enumerated()), id: \.element.id) { index, advice in
                    AdviceCard(advice: advice)
                        .opacity(0)
                        .offset(y: 20)
                        .animation(
                            .easeOut(duration: 0.6)
                                .delay(Double(index) * 0.1),
                            value: beautyAdvice.count
                        )
                }
            }
        }
    }
}

// MARK: - 健康アドバイス
struct HealthAdviceView: View {
    let healthAdvice = [
        AdviceItem(
            category: .health,
            title: "血圧ケア",
            description: "鼻先が赤い場合は血圧に注意が必要です。塩分控えめの食事を心がけましょう。",
            duration: "常時",
            difficulty: "普通"
        ),
        AdviceItem(
            category: .health,
            title: "水分補給",
            description: "唇が乾燥している場合は水分不足のサインです。十分な水分補給を心がけましょう。",
            duration: "1日",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .health,
            title: "栄養改善",
            description: "頬が痩せている場合は栄養不足の可能性があります。バランスの良い食事を心がけましょう。",
            duration: "1日",
            difficulty: "普通"
        ),
        AdviceItem(
            category: .health,
            title: "体力強化",
            description: "耳が薄い場合は体力強化を心がけましょう。適度な運動と十分な休息を取ることが大切です。",
            duration: "30分",
            difficulty: "普通"
        ),
        AdviceItem(
            category: .health,
            title: "ホルモンバランス",
            description: "顎ニキビはホルモンバランス不調のサインです。規則正しい生活を心がけましょう。",
            duration: "常時",
            difficulty: "普通"
        )
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("健康管理")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVStack(spacing: 12) {
                ForEach(healthAdvice) { advice in
                    AdviceCard(advice: advice)
                }
            }
        }
    }
}

// MARK: - コミュニケーションアドバイス
struct CommunicationAdviceView: View {
    let communicationAdvice = [
        AdviceItem(
            category: .communication,
            title: "コミュニケーション改善",
            description: "眉と目の間が狭く自己表現が苦手な傾向があります。意識的に相手に気持ちを伝えるコミュニケーションを心がけましょう。",
            duration: "常時",
            difficulty: "普通"
        ),
        AdviceItem(
            category: .communication,
            title: "表情豊かな会話",
            description: "会話中は表情を豊かにして、相手に好印象を与えましょう。",
            duration: "常時",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .communication,
            title: "アイコンタクト",
            description: "適度なアイコンタクトを心がけて、信頼関係を築きましょう。",
            duration: "常時",
            difficulty: "普通"
        ),
        AdviceItem(
            category: .communication,
            title: "積極的な自己表現",
            description: "自分の意見や気持ちを積極的に表現することで、対人関係が改善されます。",
            duration: "常時",
            difficulty: "普通"
        )
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("コミュニケーション改善")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVStack(spacing: 12) {
                ForEach(communicationAdvice) { advice in
                    AdviceCard(advice: advice)
                }
            }
        }
    }
}

// MARK: - 表情筋エクササイズ
struct ExerciseAdviceView: View {
    let exercises = [
        ExerciseItem(
            title: "笑顔トレーニング",
            description: "口角を上げて笑顔を作り、10秒間キープします。",
            duration: "5分",
            difficulty: "簡単",
            steps: [
                "鏡の前で口角を上げる",
                "10秒間キープ",
                "5回繰り返す",
                "1日3セット行う"
            ],
            benefits: ["表情筋の強化", "自然な笑顔の習得", "ストレス軽減"]
        ),
        ExerciseItem(
            title: "目のエクササイズ",
            description: "目を大きく開いて閉じる動作を繰り返し、目の周りの筋肉を鍛えます。",
            duration: "3分",
            difficulty: "簡単",
            steps: [
                "目を大きく開く",
                "5秒間キープ",
                "ゆっくり閉じる",
                "10回繰り返す"
            ],
            benefits: ["目の疲労軽減", "目の周りの筋肉強化", "視力維持"]
        ),
        ExerciseItem(
            title: "舌回し運動",
            description: "舌を口の中で回すことで、口周りの筋肉を鍛えます。",
            duration: "2分",
            difficulty: "普通",
            steps: [
                "口を閉じる",
                "舌を右回りに10回回す",
                "左回りに10回回す",
                "1日2セット行う"
            ],
            benefits: ["口周りの筋肉強化", "滑舌改善", "小顔効果"]
        ),
        ExerciseItem(
            title: "額のマッサージ",
            description: "額や眉間を優しくマッサージして、ストレスを軽減します。",
            duration: "5分",
            difficulty: "簡単",
            steps: [
                "額を優しく円を描くようにマッサージ",
                "眉間を上下にマッサージ",
                "目頭から目尻に向かってマッサージ",
                "1日2回行う"
            ],
            benefits: ["ストレス軽減", "運気アップ", "リラックス効果"]
        )
    ]
    
    let onExerciseSelected: (ExerciseItem) -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text("表情筋エクササイズ")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVStack(spacing: 12) {
                ForEach(exercises) { exercise in
                    ExerciseCard(exercise: exercise) {
                        onExerciseSelected(exercise)
                    }
                }
            }
        }
    }
}

// MARK: - 食事アドバイス
struct DietAdviceView: View {
    let dietAdvice = [
        AdviceItem(
            category: .diet,
            title: "ビタミンC摂取",
            description: "ビタミンCを多く含む果物や野菜を摂取して、肌の調子を整えましょう。",
            duration: "1日",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .diet,
            title: "コラーゲン摂取",
            description: "コラーゲンを多く含む食品を摂取して、肌の弾力を保ちましょう。",
            duration: "1日",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .diet,
            title: "抗酸化物質",
            description: "抗酸化物質を多く含む食品を摂取して、肌の老化を防ぎましょう。",
            duration: "1日",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .diet,
            title: "水分補給",
            description: "十分な水分を摂取して、肌の乾燥を防ぎましょう。",
            duration: "1日",
            difficulty: "簡単"
        )
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("食事改善")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVStack(spacing: 12) {
                ForEach(dietAdvice) { advice in
                    AdviceCard(advice: advice)
                }
            }
        }
    }
}

// MARK: - メンタルケアアドバイス
struct MentalAdviceView: View {
    let mentalAdvice = [
        AdviceItem(
            category: .mental,
            title: "ストレスケア",
            description: "ストレスを感じたら額や眉間のマッサージを。印堂をクリアに保つことで運気が開けます。",
            duration: "10分",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .mental,
            title: "リラックス時間",
            description: "1日10分のリラックス時間を作って、心身の疲労を回復させましょう。",
            duration: "10分",
            difficulty: "簡単"
        ),
        AdviceItem(
            category: .mental,
            title: "ポジティブ思考",
            description: "前向きな考え方を心がけて、表情を明るく保ちましょう。",
            duration: "常時",
            difficulty: "普通"
        ),
        AdviceItem(
            category: .mental,
            title: "自己肯定感向上",
            description: "自分の良いところを認めて、自信を持って行動しましょう。",
            duration: "常時",
            difficulty: "普通"
        )
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("メンタルケア")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVStack(spacing: 12) {
                ForEach(mentalAdvice) { advice in
                    AdviceCard(advice: advice)
                }
            }
        }
    }
}

// MARK: - アドバイスカード
struct AdviceCard: View {
    let advice: AdviceItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: advice.category.icon)
                    .foregroundColor(advice.category.color)
                    .frame(width: 20)
                
                Text(advice.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(advice.difficulty)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(difficultyColor)
                    .cornerRadius(8)
            }
            
            Text(advice.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text(advice.duration)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var difficultyColor: Color {
        switch advice.difficulty {
        case "簡単": return .green
        case "普通": return .orange
        case "難しい": return .red
        default: return .gray
        }
    }
}

// MARK: - エクササイズカード
struct ExerciseCard: View {
    let exercise: ExerciseItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.purple)
                        .frame(width: 20)
                    
                    Text(exercise.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(exercise.difficulty)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor)
                        .cornerRadius(8)
                }
                
                Text(exercise.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(exercise.duration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("詳細を見る")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var difficultyColor: Color {
        switch exercise.difficulty {
        case "簡単": return .green
        case "普通": return .orange
        case "難しい": return .red
        default: return .gray
        }
    }
}

// MARK: - エクササイズ詳細ビュー
struct ExerciseDetailView: View {
    let exercise: ExerciseItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ヘッダー
                    VStack(alignment: .leading, spacing: 10) {
                        Text(exercise.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(exercise.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // 基本情報
                    VStack(alignment: .leading, spacing: 15) {
                        Text("基本情報")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            InfoItem(icon: "clock", title: "所要時間", value: exercise.duration)
                            Spacer()
                            InfoItem(icon: "star", title: "難易度", value: exercise.difficulty)
                        }
                    }
                    
                    // 手順
                    VStack(alignment: .leading, spacing: 15) {
                        Text("手順")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(exercise.steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(Color.orange)
                                        .clipShape(Circle())
                                    
                                    Text(step)
                                        .font(.body)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    // 効果
                    VStack(alignment: .leading, spacing: 15) {
                        Text("期待される効果")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(exercise.benefits, id: \.self) { benefit in
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .frame(width: 20)
                                    
                                    Text(benefit)
                                        .font(.body)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 情報アイテム
struct InfoItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .font(.title2)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - エクササイズアイテム
struct ExerciseItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let duration: String
    let difficulty: String
    let steps: [String]
    let benefits: [String]
}

#Preview {
    AdviceView()
} 