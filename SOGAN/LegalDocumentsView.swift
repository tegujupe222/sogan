//
//  LegalDocumentsView.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/07.
//

import SwiftUI

struct LegalDocumentsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDocument: LegalDocument = .privacyPolicy
    
    enum LegalDocument: String, CaseIterable {
        case privacyPolicy = "プライバシーポリシー"
        case termsOfService = "利用規約"
        case userPrivacyPolicy = "ユーザープライバシーポリシー"
        case eula = "EULA"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ドキュメント選択タブ
                Picker("ドキュメント", selection: $selectedDocument) {
                    ForEach(LegalDocument.allCases, id: \.self) { document in
                        Text(document.rawValue).tag(document)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // ドキュメント内容
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        switch selectedDocument {
                        case .privacyPolicy:
                            PrivacyPolicyContent()
                        case .termsOfService:
                            TermsOfServiceContent()
                        case .userPrivacyPolicy:
                            UserPrivacyPolicyContent()
                        case .eula:
                            EULAContent()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("法的文書")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - プライバシーポリシー
struct PrivacyPolicyContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("プライバシーポリシー")
                .font(.title)
                .fontWeight(.bold)
            
            Text("更新日: 2025年7月7日")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Group {
                Text("1. 情報の収集")
                    .font(.headline)
                Text("当アプリは、顔相診断機能を提供するために、ユーザーが撮影した写真を一時的に処理します。これらの写真は、診断処理のためだけに使用され、デバイス上で処理されます。")
                
                Text("2. 情報の使用")
                    .font(.headline)
                Text("収集された情報は、顔相診断の実行とアプリの機能向上のみに使用されます。第三者への情報提供は行いません。")
                
                Text("3. 情報の保存")
                    .font(.headline)
                Text("診断結果は、ユーザーの同意に基づいてデバイス上に保存されます。写真データは診断処理後に自動的に削除されます。")
                
                Text("4. 情報の共有")
                    .font(.headline)
                Text("当アプリは、ユーザーの明示的な同意なしに、個人情報を第三者と共有することはありません。")
                
                Text("5. セキュリティ")
                    .font(.headline)
                Text("ユーザーのプライバシーを保護するため、適切なセキュリティ対策を実施しています。")
                
                Text("6. お問い合わせ")
                    .font(.headline)
                Text("プライバシーポリシーに関するご質問やご意見がございましたら、以下の連絡先までお気軽にお問い合わせください。")
                
                Text("連絡先: igafactory2023@gmail.com")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - 利用規約
struct TermsOfServiceContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("利用規約")
                .font(.title)
                .fontWeight(.bold)
            
            Text("更新日: 2025年7月7日")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Group {
                Text("1. 利用条件")
                    .font(.headline)
                Text("本アプリの利用により、本規約に同意したものとみなされます。")
                
                Text("2. 利用目的")
                    .font(.headline)
                Text("本アプリは、顔相診断の参考情報を提供することを目的としています。診断結果は参考情報であり、医療診断ではありません。")
                
                Text("3. 禁止事項")
                    .font(.headline)
                Text("以下の行為を禁止します：\n• アプリの改変や逆コンパイル\n• 他のユーザーへの迷惑行為\n• 法令違反行為\n• 著作権侵害行為")
                
                Text("4. 免責事項")
                    .font(.headline)
                Text("当アプリの診断結果は参考情報であり、医療診断ではありません。重要な判断を行う際は、専門家にご相談ください。")
                
                Text("5. サービスの変更・終了")
                    .font(.headline)
                Text("当社は、事前の通知なく、サービスの内容を変更または終了する場合があります。")
                
                Text("6. 準拠法")
                    .font(.headline)
                Text("本規約は日本法に準拠し、解釈されます。")
                
                Text("7. お問い合わせ")
                    .font(.headline)
                Text("利用規約に関するご質問がございましたら、以下の連絡先までお問い合わせください。")
                
                Text("連絡先: igafactory2023@gmail.com")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - ユーザープライバシーポリシー
struct UserPrivacyPolicyContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ユーザープライバシーポリシー")
                .font(.title)
                .fontWeight(.bold)
            
            Text("更新日: 2025年7月7日")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Group {
                Text("1. 収集する情報")
                    .font(.headline)
                Text("• ユーザーが登録したプロフィール情報（名前、年齢、性別）\n• 顔相診断用の写真\n• 診断結果と履歴\n• アプリの使用統計データ")
                
                Text("2. 情報の使用目的")
                    .font(.headline)
                Text("• 顔相診断の実行\n• 診断結果の保存と履歴管理\n• アプリの機能向上\n• ユーザーサポート")
                
                Text("3. 情報の保存期間")
                    .font(.headline)
                Text("• プロフィール情報: アカウント削除まで\n• 診断結果: ユーザーが削除するまで\n• 写真データ: 診断処理後即座に削除")
                
                Text("4. 情報の共有")
                    .font(.headline)
                Text("ユーザーの個人情報は、以下の場合を除き、第三者と共有されません：\n• ユーザーの明示的な同意がある場合\n• 法令に基づく要求がある場合")
                
                Text("5. ユーザーの権利")
                    .font(.headline)
                Text("ユーザーは以下の権利を有します：\n• 個人情報の確認\n• 個人情報の修正・削除\n• データのエクスポート\n• アカウントの削除")
                
                Text("6. お問い合わせ")
                    .font(.headline)
                Text("プライバシーに関するご質問やご要望がございましたら、以下の連絡先までお問い合わせください。")
                
                Text("連絡先: igafactory2023@gmail.com")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - EULA
struct EULAContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("エンドユーザーライセンス契約（EULA）")
                .font(.title)
                .fontWeight(.bold)
            
            Text("更新日: 2025年7月7日")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Group {
                Text("1. ライセンスの付与")
                    .font(.headline)
                Text("当社は、本ソフトウェアの使用権を、本契約の条件に従って、非独占的、譲渡不可、取消可能な形で付与します。")
                
                Text("2. 使用制限")
                    .font(.headline)
                Text("• 本ソフトウェアは個人使用目的でのみ使用可能です\n• 商業目的での使用は禁止されています\n• リバースエンジニアリングは禁止されています")
                
                Text("3. 知的財産権")
                    .font(.headline)
                Text("本ソフトウェアおよびその関連文書の著作権、商標権、その他の知的財産権は、当社またはそのライセンサーに帰属します。")
                
                Text("4. 保証の否認")
                    .font(.headline)
                Text("本ソフトウェアは「現状のまま」提供され、明示または黙示の保証は一切ありません。")
                
                Text("5. 責任の制限")
                    .font(.headline)
                Text("当社は、本ソフトウェアの使用により生じる損害について、一切の責任を負いません。")
                
                Text("6. 契約の終了")
                    .font(.headline)
                Text("本契約は、以下の場合に終了します：\n• ユーザーが本契約に違反した場合\n• アプリの削除時")
                
                Text("7. 準拠法")
                    .font(.headline)
                Text("本契約は日本法に準拠し、解釈されます。")
                
                Text("8. お問い合わせ")
                    .font(.headline)
                Text("本契約に関するご質問がございましたら、以下の連絡先までお問い合わせください。")
                
                Text("連絡先: igafactory2023@gmail.com")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    LegalDocumentsView()
} 