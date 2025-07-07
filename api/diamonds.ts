import { NextApiRequest, NextApiResponse } from 'next';
import { sql } from '@vercel/postgres';
import cors from 'cors';

// CORS設定
const corsMiddleware = cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
});

// ダイヤ消費コスト定義
export const DIAMOND_COSTS = {
  CAMERA_PHOTO: 3,
  VIEW_RESULT: 4,
  ADD_USER: 3,
  ADVICE_VIEW: 2,
  HISTORY_VIEW: 1,
} as const;

// ユーザー情報の型定義
interface User {
  id: string;
  diamonds: number;
  lastRefillDate: string;
  maxDiamonds: number;
}

// リクエストの型定義
interface DiamondRequest {
  userId: string;
  action: keyof typeof DIAMOND_COSTS;
  amount?: number; // 購入時のみ使用
}

// レスポンスの型定義
interface DiamondResponse {
  success: boolean;
  message: string;
  diamonds?: number;
  canPerform?: boolean;
}

// データベース初期化
async function initializeDatabase() {
  try {
    await sql`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(255) PRIMARY KEY,
        diamonds INTEGER DEFAULT 10,
        last_refill_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        max_diamonds INTEGER DEFAULT 10,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `;
  } catch (error) {
    console.error('Database initialization error:', error);
  }
}

// ユーザー取得または作成
async function getUserOrCreate(userId: string): Promise<User> {
  try {
    const result = await sql`
      SELECT id, diamonds, last_refill_date, max_diamonds 
      FROM users 
      WHERE id = ${userId}
    `;

    if (result.rows.length === 0) {
      // 新規ユーザー作成
      await sql`
        INSERT INTO users (id, diamonds, max_diamonds)
        VALUES (${userId}, 10, 10)
      `;
      
      return {
        id: userId,
        diamonds: 10,
        lastRefillDate: new Date().toISOString(),
        maxDiamonds: 10,
      };
    }

    const user = result.rows[0];
    return {
      id: user.id,
      diamonds: user.diamonds,
      lastRefillDate: user.last_refill_date,
      maxDiamonds: user.max_diamonds,
    };
  } catch (error) {
    console.error('Error getting user:', error);
    throw error;
  }
}

// ダイヤ補填処理
async function refillDiamonds(userId: string): Promise<number> {
  try {
    const user = await getUserOrCreate(userId);
    const now = new Date();
    const lastRefill = new Date(user.lastRefillDate);
    
    // 日付が変わっているかチェック
    const isNewDay = now.getDate() !== lastRefill.getDate() || 
                     now.getMonth() !== lastRefill.getMonth() || 
                     now.getFullYear() !== lastRefill.getFullYear();

    if (isNewDay && user.diamonds < user.maxDiamonds) {
      const newDiamonds = Math.min(user.maxDiamonds, user.diamonds + 10);
      
      await sql`
        UPDATE users 
        SET diamonds = ${newDiamonds}, 
            last_refill_date = ${now.toISOString()},
            updated_at = ${now.toISOString()}
        WHERE id = ${userId}
      `;
      
      return newDiamonds;
    }
    
    return user.diamonds;
  } catch (error) {
    console.error('Error refilling diamonds:', error);
    throw error;
  }
}

// ダイヤ消費処理
async function consumeDiamonds(userId: string, action: keyof typeof DIAMOND_COSTS): Promise<DiamondResponse> {
  try {
    const cost = DIAMOND_COSTS[action];
    const currentDiamonds = await refillDiamonds(userId);
    
    if (currentDiamonds < cost) {
      return {
        success: false,
        message: `ダイヤが不足しています。必要: ${cost}ダイヤ、所持: ${currentDiamonds}ダイヤ`,
        diamonds: currentDiamonds,
        canPerform: false,
      };
    }
    
    const newDiamonds = currentDiamonds - cost;
    
    await sql`
      UPDATE users 
      SET diamonds = ${newDiamonds},
          updated_at = ${new Date().toISOString()}
      WHERE id = ${userId}
    `;
    
    return {
      success: true,
      message: `${action}を実行しました。消費: ${cost}ダイヤ`,
      diamonds: newDiamonds,
      canPerform: true,
    };
  } catch (error) {
    console.error('Error consuming diamonds:', error);
    return {
      success: false,
      message: 'ダイヤ消費中にエラーが発生しました',
    };
  }
}

// ダイヤ購入処理
async function purchaseDiamonds(userId: string, amount: number): Promise<DiamondResponse> {
  try {
    const user = await getUserOrCreate(userId);
    const newDiamonds = user.diamonds + amount;
    
    await sql`
      UPDATE users 
      SET diamonds = ${newDiamonds},
          updated_at = ${new Date().toISOString()}
      WHERE id = ${userId}
    `;
    
    return {
      success: true,
      message: `${amount}ダイヤを購入しました`,
      diamonds: newDiamonds,
    };
  } catch (error) {
    console.error('Error purchasing diamonds:', error);
    return {
      success: false,
      message: 'ダイヤ購入中にエラーが発生しました',
    };
  }
}

// APIハンドラー
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  res.status(200).json({ message: "SOGAN Diamonds API is working!" });
} 