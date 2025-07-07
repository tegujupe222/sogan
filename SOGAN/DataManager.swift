//
//  DataManager.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/06.
//

import Foundation
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var users: [User] = []
    @Published var userProfiles: [UserProfile] = []
    @Published var faceReadingHistory: [FaceReadingResult] = []
    @Published var selectedUserId: UUID?
    
    private let usersKey = "Users"
    private let userProfilesKey = "UserProfiles"
    private let selectedUserIdKey = "SelectedUserId"
    private let historyFileName = "FaceReadingHistory.json"
    
    private init() {
        loadUsers()
        loadUserProfiles()
        loadSelectedUserId()
        loadHistory()
    }
    
    // MARK: - ユーザー管理
    func addUser(_ user: User) {
        users.append(user)
        saveUsers()
        
        // ユーザープロフィールを作成
        let profile = UserProfile(userId: user.id)
        userProfiles.append(profile)
        saveUserProfiles()
        
        // 初回ユーザーの場合、選択状態にする
        if users.count == 1 {
            selectedUserId = user.id
            saveSelectedUserId()
        }
    }
    
    func updateUser(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            saveUsers()
        }
    }
    
    func deleteUser(_ user: User) {
        users.removeAll { $0.id == user.id }
        userProfiles.removeAll { $0.userId == user.id }
        
        // 削除されたユーザーの履歴も削除
        faceReadingHistory.removeAll { $0.userId == user.id }
        saveHistory()
        
        // 選択中のユーザーが削除された場合
        if selectedUserId == user.id {
            selectedUserId = users.first?.id
            saveSelectedUserId()
        }
        
        saveUsers()
        saveUserProfiles()
    }
    
    func selectUser(_ userId: UUID) {
        selectedUserId = userId
        saveSelectedUserId()
    }
    
    // MARK: - 履歴管理
    func addHistory(_ result: FaceReadingResult) {
        faceReadingHistory.append(result)
        saveHistory()
        
        // ユーザープロフィールを更新
        if let index = userProfiles.firstIndex(where: { $0.userId == result.userId }) {
            userProfiles[index].totalDiagnoses += 1
            userProfiles[index].lastDiagnosisDate = result.date
            
            // 平均運勢を更新
            let userResults = faceReadingHistory.filter { $0.userId == result.userId }
            let totalLuck = userResults.reduce(0) { $0 + $1.overallLuck }
            userProfiles[index].averageLuck = totalLuck / userResults.count
            
            // 最高運勢を更新
            if result.overallLuck > userProfiles[index].bestLuck {
                userProfiles[index].bestLuck = result.overallLuck
            }
            
            saveUserProfiles()
        }
    }
    
    func getHistoryForUser(_ userId: UUID) -> [FaceReadingResult] {
        return faceReadingHistory.filter { $0.userId == userId }
    }
    
    func getHistoryForUserAndDate(_ userId: UUID, date: Date) -> [FaceReadingResult] {
        let calendar = Calendar.current
        return faceReadingHistory.filter { result in
            result.userId == userId && calendar.isDate(result.date, inSameDayAs: date)
        }
    }
    
    // MARK: - データ保存・読み込み
    private func saveUsers() {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: usersKey)
        }
    }
    
    private func loadUsers() {
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let decoded = try? JSONDecoder().decode([User].self, from: data) {
            users = decoded
        }
    }
    
    private func saveUserProfiles() {
        if let encoded = try? JSONEncoder().encode(userProfiles) {
            UserDefaults.standard.set(encoded, forKey: userProfilesKey)
        }
    }
    
    private func loadUserProfiles() {
        if let data = UserDefaults.standard.data(forKey: userProfilesKey),
           let decoded = try? JSONDecoder().decode([UserProfile].self, from: data) {
            userProfiles = decoded
        }
    }
    
    private func saveSelectedUserId() {
        UserDefaults.standard.set(selectedUserId?.uuidString, forKey: selectedUserIdKey)
    }
    
    private func loadSelectedUserId() {
        if let uuidString = UserDefaults.standard.string(forKey: selectedUserIdKey) {
            selectedUserId = UUID(uuidString: uuidString)
        }
    }
    
    // ファイルベースの履歴保存
    private func saveHistory() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsPath.appendingPathComponent(historyFileName)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(faceReadingHistory)
            try data.write(to: fileURL)
        } catch {
            print("履歴の保存に失敗しました: \(error)")
        }
    }
    
    private func loadHistory() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsPath.appendingPathComponent(historyFileName)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            faceReadingHistory = try decoder.decode([FaceReadingResult].self, from: data)
        } catch {
            print("履歴の読み込みに失敗しました: \(error)")
            faceReadingHistory = []
        }
    }
    
    // MARK: - ユーティリティ
    func getSelectedUser() -> User? {
        return users.first { $0.id == selectedUserId }
    }
    
    func getUserProfile(for userId: UUID) -> UserProfile? {
        return userProfiles.first { $0.userId == userId }
    }
    
    func clearAllHistory() {
        faceReadingHistory.removeAll()
        saveHistory()
        
        // ユーザープロフィールもリセット
        for i in userProfiles.indices {
            userProfiles[i].totalDiagnoses = 0
            userProfiles[i].averageLuck = 0
            userProfiles[i].bestLuck = 0
            userProfiles[i].lastDiagnosisDate = nil
        }
        saveUserProfiles()
    }
    
    // MARK: - 統計メソッド
    func getAverageLuck() -> Int {
        guard !faceReadingHistory.isEmpty else { return 0 }
        let totalLuck = faceReadingHistory.reduce(0) { $0 + $1.overallLuck }
        return totalLuck / faceReadingHistory.count
    }
    
    func getHighestLuck() -> Int {
        return faceReadingHistory.map { $0.overallLuck }.max() ?? 0
    }
    
    func hasTodayDiagnosis() -> Bool {
        guard let selectedUserId = selectedUserId else { return false }
        let today = Date()
        let calendar = Calendar.current
        return faceReadingHistory.contains { result in
            result.userId == selectedUserId && calendar.isDate(result.date, inSameDayAs: today)
        }
    }
    
    func getTodayResults() -> [FaceReadingResult] {
        guard let selectedUserId = selectedUserId else { return [] }
        let today = Date()
        let calendar = Calendar.current
        return faceReadingHistory.filter { result in
            result.userId == selectedUserId && calendar.isDate(result.date, inSameDayAs: today)
        }
    }
}