//
//  ContentView.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/06.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingUserManagement = false
    
    var body: some View {
        Group {
            if dataManager.getSelectedUser() != nil {
                // ユーザーが選択されている場合は通常のタブビュー
                TabView {
                    DiagnosisView()
                        .tabItem {
                            Image(systemName: "camera.fill")
                            Text("診断")
                        }
                    
                    HistoryView()
                        .tabItem {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("履歴")
                        }
                    
                    AdviceView()
                        .tabItem {
                            Image(systemName: "sparkles")
                            Text("アドバイス")
                        }
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("設定")
                        }
                }
                .accentColor(.orange)
                .preferredColorScheme(.light)
            } else {
                // ユーザーが選択されていない場合はユーザー管理画面
                UserManagementView()
            }
        }
        .onAppear {
            // アプリ起動時にユーザーが未選択の場合はユーザー管理画面を表示
            if dataManager.getSelectedUser() == nil && !dataManager.users.isEmpty {
                showingUserManagement = true
            }
        }
        .sheet(isPresented: $showingUserManagement) {
            UserManagementView()
        }
    }
}

#Preview {
    ContentView()
}
