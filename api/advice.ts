import { VercelRequest, VercelResponse } from '@vercel/node';
import OpenAI from 'openai';

// OpenAIクライアントの初期化
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// アドバイス生成のプロンプトテンプレート
const ADVICE_PROMPT = `
あなたは顔相学の専門家です。提供された診断結果に基づいて、具体的で実践可能なアドバイスを生成してください。

## 診断結果
{diagnosisData}

## アドバイスカテゴリ
{category}

## 出力形式
以下のJSON形式で回答してください：

{
  "advice": {
    "title": "アドバイスのタイトル",
    "description": "詳細なアドバイス内容",
    "steps": ["ステップ1", "ステップ2", "ステップ3"],
    "tips": ["コツ1", "コツ2"],
    "duration": "所要時間（例：5分/日）",
    "difficulty": "難易度（初級/中級/上級）"
  }
}

## 注意事項
- 具体的で実践可能なアドバイスを提供
- 顔相学の伝統的知識と現代的な視点を組み合わせ
- ポジティブで建設的な表現を使用
- ユーザーのモチベーションを高める内容にする
`;

// CORSヘッダーを設定する関数
function setCorsHeaders(res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
}

// アドバイス生成のメイン関数
async function generateAdvice(diagnosisData: string, category: string) {
  try {
    const prompt = ADVICE_PROMPT
      .replace('{diagnosisData}', diagnosisData)
      .replace('{category}', category);

    const response = await openai.chat.completions.create({
      model: "gpt-4",
      messages: [
        {
          role: "system",
          content: "あなたは顔相学の専門家です。提供された診断結果に基づいて、具体的で実践可能なアドバイスを生成してください。"
        },
        {
          role: "user",
          content: prompt
        }
      ],
      max_tokens: 1000,
      temperature: 0.7,
    });

    const content = response.choices[0]?.message?.content;
    if (!content) {
      throw new Error('AIアドバイス生成に失敗しました');
    }

    // JSONレスポンスを解析
    try {
      const advice = JSON.parse(content);
      return advice;
    } catch (parseError) {
      // JSON解析に失敗した場合、デフォルトアドバイスを返す
      return generateDefaultAdvice(category);
    }
  } catch (error) {
    console.error('OpenAI API エラー:', error);
    throw error;
  }
}

// デフォルトアドバイス生成
function generateDefaultAdvice(category: string) {
  const defaultAdvice = {
    lifestyle: {
      title: "ライフスタイル改善アドバイス",
      description: "規則正しい生活習慣を心がけることで運気が向上します。",
      steps: ["朝日を浴びる", "十分な睡眠を取る", "適度な運動をする"],
      tips: ["毎日同じ時間に起きる", "就寝前はスマートフォンを避ける"],
      duration: "30分/日",
      difficulty: "初級"
    },
    beauty: {
      title: "美容ケアアドバイス",
      description: "肌の状態を整えることで運気が向上します。",
      steps: ["保湿ケアを徹底する", "紫外線対策をする", "十分な水分補給"],
      tips: ["朝晩のスキンケアを習慣にする", "肌に優しい化粧品を使用"],
      duration: "10分/日",
      difficulty: "初級"
    },
    health: {
      title: "健康管理アドバイス",
      description: "体調を整えることで運気が向上します。",
      steps: ["バランスの良い食事", "適度な運動", "十分な休息"],
      tips: ["野菜を多く摂取する", "定期的な健康診断を受ける"],
      duration: "1時間/日",
      difficulty: "中級"
    },
    communication: {
      title: "コミュニケーション改善アドバイス",
      description: "対人関係を改善することで運気が向上します。",
      steps: ["積極的に挨拶する", "相手の話をよく聞く", "笑顔を心がける"],
      tips: ["相手の立場に立って考える", "感謝の気持ちを伝える"],
      duration: "5分/日",
      difficulty: "初級"
    },
    exercise: {
      title: "表情筋エクササイズアドバイス",
      description: "表情筋を鍛えることで運気が向上します。",
      steps: ["笑顔の練習", "目の周りのマッサージ", "口角を上げる練習"],
      tips: ["鏡を見ながら練習する", "毎日継続することが大切"],
      duration: "5分/日",
      difficulty: "初級"
    },
    diet: {
      title: "食事改善アドバイス",
      description: "食生活を改善することで運気が向上します。",
      steps: ["野菜を多く摂取", "水分を十分に取る", "規則正しい食事"],
      tips: ["朝食を必ず取る", "ゆっくり噛んで食べる"],
      duration: "30分/日",
      difficulty: "中級"
    },
    mental: {
      title: "メンタルケアアドバイス",
      description: "心の健康を保つことで運気が向上します。",
      steps: ["深呼吸をする", "ポジティブな思考を心がける", "趣味を持つ"],
      tips: ["ストレスを溜め込まない", "自分を褒める習慣をつける"],
      duration: "15分/日",
      difficulty: "中級"
    }
  };

  return {
    advice: defaultAdvice[category as keyof typeof defaultAdvice] || defaultAdvice.lifestyle
  };
}

// APIハンドラー
export default async function handler(req: VercelRequest, res: VercelResponse) {
  // CORSヘッダーを設定
  setCorsHeaders(res);

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { diagnosisData, category, diamonds } = req.body;

    if (!diagnosisData || !category) {
      return res.status(400).json({ error: '診断データとカテゴリが必要です' });
    }

    // ダイヤモンド消費チェック（実際のアプリではユーザーのダイヤモンド数を確認）
    if (diamonds < 1) {
      return res.status(402).json({ error: 'ダイヤモンドが不足しています' });
    }

    // アドバイス生成を実行
    const advice = await generateAdvice(diagnosisData, category);

    // 結果を返す
    res.status(200).json({
      success: true,
      advice: advice.advice,
      diamondsUsed: 1,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('アドバイス生成エラー:', error);
    res.status(500).json({
      error: 'アドバイス生成中にエラーが発生しました',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
} 