//
//  SplashView.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/07.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    
    var body: some View {
        ZStack {
            // 背景色
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // アプリアイコン
                Image(systemName: "face.smiling")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // アプリ名
                Text("SOGAN")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                // サブタイトル
                Text("顔相診断アプリ")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .opacity(opacity)
            }
        }
        .onAppear {
            // フェードインアニメーション
            withAnimation(.easeInOut(duration: 1.0)) {
                opacity = 1.0
                scale = 1.0
            }
            
            // 2秒後にフェードアウトしてメイン画面に遷移
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    opacity = 0.0
                    scale = 1.2
                }
                
                // フェードアウト完了後にメイン画面に遷移
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            ContentView()
        }
    }
}

#Preview {
    SplashView()
} 