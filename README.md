# SOGAN - 顔相診断アプリ

## 📱 アプリ概要

SOGANは、スマートフォンのカメラで自撮りするだけで、「今の顔相からあなたの運気や体調、気分傾向を診断」できるアプリです。

さらに、改善アドバイスや日々の変化を記録し、**「顔つきから幸運を引き寄せる」**体験を提供します。

## 🎯 主な機能

### 🔍 AI顔相診断
- **OpenAI GPT-4 Vision API**: 高度なAIによる顔相分析
- **顔パーツ自動検出**: 額・眉・目・鼻・口・顎などを自動で判定
- **表情スキャン**: 目の輝き、口角、表情筋の動きから「笑顔度」「怒相度」などを算出

### 📈 結果表示
- **顔相スコア**: 総合運・恋愛運・健康運などをスコアで表示
- **相の傾向分類**: 福相・怒相・疲労相などを分類表示

### 🗓 ログ管理
- **顔相履歴**: 毎日の診断結果をカレンダーやグラフで表示
- **写真比較**: 過去の顔と現在を比較して「相の変化」を可視化

### 💡 AI改善提案
- **AIアドバイス生成**: ダイヤモンドを消費してパーソナライズされたアドバイスを生成
- **アドバイスカテゴリ**: ライフスタイル、美容、健康、コミュニケーション、エクササイズ、食事、メンタル
- **ライフスタイルアドバイス**: 食事・姿勢・表情トレーニングの提案
- **表情筋エクササイズ**: 顔ヨガや笑顔トレーニングのガイド付き

### 💎 ダイヤモンドシステム
- **AIアドバイス生成**: 1個のダイヤモンドでAIがパーソナライズされたアドバイスを生成
- **ダイヤモンド獲得**: 診断やログインでダイヤモンドを獲得

### 🔔 通知機能
- **朝の顔チェック通知**: ルーティン化をサポート

### 📸 SNS共有
- **「今日の顔相」を画像付きでシェアできる**

## ⚙️ 技術構成

| 要素 | 技術・ライブラリ |
|------|------------------|
| UI | SwiftUI |
| 顔検出 | Vision Framework（Apple） |
| AI分析 | OpenAI GPT-4 Vision API |
| 画像処理 | Metal / Core Image |
| データ管理 | UserDefaults |
| 顔履歴保存 | ローカル保存 |
| バックエンド | Vercel Functions |
| API | OpenAI API |

## 🔑 差別化ポイント

### 特徴
- **東洋相術ベース**: 水野南北や中国観相術の思想に基づく独自ロジック
- **内面改善重視**: 診断結果から食事・感情・生活習慣の改善アドバイス
- **長期観察機能**: 毎日の変化を見える化する「相の記録簿」あり
- **表情筋エクササイズ**: 顔相改善のためのトレーニングを動画や音声で提供

## 🛡 プライバシー配慮

- 顔画像はユーザーの端末内でのみ保存・解析（外部送信なし）
- 診断はオフラインで可能
- アプリ起動時にプライバシーポリシー表示

## 📦 今後の追加機能（将来的に）

- AIカウンセラーによる「運命相談」チャット
- 「開運メイク」提案機能（顔相に合わせて）
- 有名人の顔相比較機能
- Apple Vision Pro対応の顔トラッキング診断

## 🚀 セットアップ手順

### 必要条件
- Xcode 15.0以上
- iOS 15.0以上
- macOS 13.0以上
- Node.js 18.0以上（バックエンド用）
- OpenAI APIキー

### インストール手順

1. **リポジトリのクローン**
   ```bash
   git clone https://github.com/your-username/SOGAN.git
   cd SOGAN
   ```

2. **バックエンドのセットアップ**
   ```bash
   # 依存関係をインストール
   npm install
   
   # 環境変数を設定
   cp env.example .env.local
   # .env.localファイルを編集してOpenAI APIキーを設定
   ```

3. **Vercelにデプロイ**
   ```bash
   # Vercel CLIをインストール（初回のみ）
   npm install -g vercel
   
   # プロジェクトをデプロイ
   vercel --prod
   ```

4. **iOSアプリの設定**
   ```bash
   open SOGAN.xcodeproj
   ```
   
   - プロジェクト設定で「Bundle Identifier」を設定
   - 「Signing & Capabilities」で適切な開発チームを選択
   - `NetworkManager.swift`の`baseURL`をVercelのデプロイURLに更新

5. **シミュレーターまたは実機で実行**
   - iOS Simulatorでテストする場合: `Cmd + R`
   - 実機でテストする場合: デバイスを接続して実行

### 権限設定

アプリは以下の権限を要求します：

- **カメラ**: 顔相診断のための自撮り機能
- **写真ライブラリ**: 既存の写真から診断を行う機能

これらの権限は`Info.plist`で設定されており、初回起動時にユーザーに許可を求めます。

## 📁 プロジェクト構造

```
SOGAN/
├── SOGAN/                      # iOSアプリ
│   ├── SOGANApp.swift          # アプリのエントリーポイント
│   ├── ContentView.swift       # メインのタブビュー
│   ├── Models.swift            # データモデル
│   ├── DataManager.swift       # データ管理クラス
│   ├── NetworkManager.swift    # API通信管理
│   ├── DiagnosisView.swift     # 診断画面
│   ├── CameraView.swift        # カメラ機能
│   ├── ImagePicker.swift       # 画像選択機能
│   ├── DiagnosisResultView.swift # 診断結果表示
│   ├── HistoryView.swift       # 履歴画面
│   ├── AdviceView.swift        # アドバイス画面
│   ├── SettingsView.swift      # 設定画面
│   ├── Info.plist              # アプリ設定
│   └── Assets.xcassets/        # アセット
├── api/                        # Vercel Functions
│   ├── face-reading.ts         # 顔相診断API
│   ├── advice.ts               # AIアドバイス生成API
│   └── diamonds.ts             # ダイヤモンド管理API
├── SOGANTests/                 # ユニットテスト
├── SOGANUITests/               # UIテスト
├── package.json                # Node.js依存関係
├── vercel.json                 # Vercel設定
├── env.example                 # 環境変数例
└── README.md                   # このファイル
```

## 🧪 テスト

### ユニットテストの実行
```bash
xcodebuild test -project SOGAN.xcodeproj -scheme SOGAN -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UIテストの実行
```bash
xcodebuild test -project SOGAN.xcodeproj -scheme SOGANUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 📱 使用方法

1. **アプリを起動**
   - 初回起動時にプライバシーポリシーが表示されます

2. **診断を開始**
   - 「診断」タブで「カメラで撮影」または「写真を選択」をタップ
   - 顔を画面中央に配置して撮影

3. **結果を確認**
   - 診断結果画面で運気スコアやアドバイスを確認
   - 「履歴」タブで過去の診断結果を閲覧

4. **改善に取り組む**
   - 「アドバイス」タブで表情筋エクササイズやライフスタイル改善の提案を確認
   - ダイヤモンドを消費してAIが生成するパーソナライズされたアドバイスを取得

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 📞 サポート

- **バグ報告**: [Issues](https://github.com/your-username/SOGAN/issues)で報告してください
- **機能要望**: [Issues](https://github.com/your-username/SOGAN/issues)で提案してください
- **その他の質問**: [Discussions](https://github.com/your-username/SOGAN/discussions)でお気軽にお聞かせください

## 🙏 謝辞

- 東洋相術の思想に基づく診断ロジックの参考資料
- SwiftUIコミュニティの素晴らしいリソース
- テストに協力してくださったユーザーの皆様

---

**SOGAN Team** - 顔相から幸運を引き寄せるアプリ 