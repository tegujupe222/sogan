// 仮想的なデータベース（実際の実装ではVercel KVやPostgreSQLを使用）
let userDiamonds = {};

// CORSヘッダーを設定する関数
function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
}

// ユーザーのダイヤモンド情報を取得
function getUserDiamonds(userId) {
  if (!userDiamonds[userId]) {
    userDiamonds[userId] = {
      diamonds: 10, // 初期ダイヤモンド数
      lastRefill: new Date().toISOString(),
      purchaseHistory: []
    };
  }
  return userDiamonds[userId];
}

// ダイヤモンドを消費
function consumeDiamonds(userId, amount, description) {
  const user = getUserDiamonds(userId);
  
  if (user.diamonds < amount) {
    return false;
  }
  
  user.diamonds -= amount;
  user.purchaseHistory.push({
    id: Date.now().toString(),
    amount: -amount,
    price: 0,
    timestamp: new Date().toISOString(),
    type: 'consumption',
    description
  });
  
  return true;
}

// ダイヤモンドを購入
function purchaseDiamonds(userId, amount, price) {
  const user = getUserDiamonds(userId);
  
  user.diamonds += amount;
  user.purchaseHistory.push({
    id: Date.now().toString(),
    amount: amount,
    price: price,
    timestamp: new Date().toISOString(),
    type: 'purchase',
    description: `${amount}ダイヤモンドを購入`
  });
  
  return true;
}

// 日次ダイヤモンド補填
function refillDailyDiamonds(userId) {
  const user = getUserDiamonds(userId);
  const now = new Date();
  const lastRefill = new Date(user.lastRefill);
  
  // 前回の補填から24時間経過しているかチェック
  const hoursSinceLastRefill = (now.getTime() - lastRefill.getTime()) / (1000 * 60 * 60);
  
  if (hoursSinceLastRefill >= 24) {
    const refillAmount = 10; // 1日10ダイヤ補填（最大10個）
    const maxDiamonds = 10;
    const currentDiamonds = user.diamonds;
    const actualRefill = Math.min(refillAmount, maxDiamonds - currentDiamonds);
    
    if (actualRefill > 0) {
      user.diamonds += actualRefill;
      user.lastRefill = now.toISOString();
      user.purchaseHistory.push({
        id: Date.now().toString(),
        amount: actualRefill,
        price: 0,
        timestamp: now.toISOString(),
        type: 'refill',
        description: '日次ダイヤモンド補填'
      });
      return true;
    }
  }
  
  return false;
}

// APIハンドラー
export default function handler(req, res) {
  // CORSヘッダーを設定
  setCorsHeaders(res);

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    const { action, userId, amount, price, description } = req.body;

    if (!userId) {
      return res.status(400).json({ error: 'ユーザーIDが必要です' });
    }

    switch (action) {
      case 'get':
        // ダイヤモンド情報取得
        const user = getUserDiamonds(userId);
        return res.status(200).json({
          success: true,
          diamonds: user.diamonds,
          lastRefill: user.lastRefill,
          purchaseHistory: user.purchaseHistory.slice(-10) // 最新10件
        });

      case 'consume':
        // ダイヤモンド消費
        if (!amount || amount <= 0) {
          return res.status(400).json({ error: '消費量を指定してください' });
        }
        
        const consumed = consumeDiamonds(userId, amount, description || 'ダイヤモンド消費');
        if (!consumed) {
          return res.status(402).json({ error: 'ダイヤモンドが不足しています' });
        }
        
        return res.status(200).json({
          success: true,
          diamonds: getUserDiamonds(userId).diamonds,
          consumed: amount
        });

      case 'purchase':
        // ダイヤモンド購入
        if (!amount || amount <= 0 || !price || price <= 0) {
          return res.status(400).json({ error: '購入量と価格を指定してください' });
        }
        
        purchaseDiamonds(userId, amount, price);
        return res.status(200).json({
          success: true,
          diamonds: getUserDiamonds(userId).diamonds,
          purchased: amount
        });

      case 'refill':
        // 日次補填
        const refilled = refillDailyDiamonds(userId);
        return res.status(200).json({
          success: true,
          diamonds: getUserDiamonds(userId).diamonds,
          refilled: refilled,
          lastRefill: getUserDiamonds(userId).lastRefill
        });

      case 'history':
        // 購入履歴取得
        const history = getUserDiamonds(userId).purchaseHistory;
        return res.status(200).json({
          success: true,
          history: history
        });

      default:
        return res.status(400).json({ error: '無効なアクションです' });
    }

  } catch (error) {
    console.error('ダイヤモンド管理エラー:', error);
    res.status(500).json({
      error: 'ダイヤモンド管理中にエラーが発生しました',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
} 