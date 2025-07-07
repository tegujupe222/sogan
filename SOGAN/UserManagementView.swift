//
//  UserManagementView.swift
//  SOGAN
//
//  Created by Igasaki Gouta on 2025/07/06.
//

import SwiftUI
import PhotosUI

struct UserManagementView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var showingAddUser = false
    @State private var selectedUser: User?
    @State private var showingEditUser = false
    
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
                
                VStack(spacing: 20) {
                    // 現在のユーザー表示
                    if let currentUser = dataManager.getSelectedUser() {
                        CurrentUserCard(user: currentUser)
                    }
                    
                    // ユーザーリスト
                    if dataManager.users.isEmpty {
                        EmptyUserView()
                    } else {
                        UserListView(
                            users: dataManager.users,
                            selectedUserId: dataManager.selectedUserId,
                            onUserSelect: { user in
                                                                  dataManager.selectUser(user.id)
                            },
                            onUserEdit: { user in
                                selectedUser = user
                                showingEditUser = true
                            },
                            onUserDelete: { user in
                                deleteUser(user)
                            }
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("ユーザー管理")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddUser = true }) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddUser) {
            AddUserView()
        }
        .sheet(isPresented: $showingEditUser) {
            if let user = selectedUser {
                EditUserView(user: user)
            }
        }
    }
    
    private func deleteUser(_ user: User) {
        // 確認アラートを表示
        let alert = UIAlertController(
            title: "ユーザーを削除",
            message: "\(user.name)さんを削除しますか？\nこの操作は取り消せません。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: "削除", style: .destructive) { _ in
            dataManager.deleteUser(user)
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
}

// MARK: - 現在のユーザーカード
struct CurrentUserCard: View {
    let user: User
    @ObservedObject var dataManager = DataManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("現在のユーザー")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack(spacing: 16) {
                // プロフィール画像
                if let imageData = user.profileImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.orange, lineWidth: 2))
                } else {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if let nickname = user.nickname {
                        Text(nickname)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    if let profile = dataManager.getUserProfile(for: user.id) {
                        Text("診断回数: \(profile.totalDiagnoses)回")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - 空のユーザー表示
struct EmptyUserView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.6))
            
            Text("ユーザーが登録されていません")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("右上の「+」ボタンから\n最初のユーザーを登録してください")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - ユーザーリスト
struct UserListView: View {
    let users: [User]
            let selectedUserId: UUID?
    let onUserSelect: (User) -> Void
    let onUserEdit: (User) -> Void
    let onUserDelete: (User) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("登録済みユーザー")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(users) { user in
                    UserRowView(
                        user: user,
                        isCurrentUser: user.id == selectedUserId,
                        onSelect: { onUserSelect(user) },
                        onEdit: { onUserEdit(user) },
                        onDelete: { onUserDelete(user) }
                    )
                }
            }
        }
    }
}

// MARK: - ユーザー行
struct UserRowView: View {
    let user: User
    let isCurrentUser: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // プロフィール画像
            if let imageData = user.profileImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(
                            isCurrentUser ? Color.orange : Color.clear,
                            lineWidth: 2
                        )
                    )
            } else {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if isCurrentUser {
                        Text("現在")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                }
                
                if let nickname = user.nickname {
                    Text(nickname)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // アクションボタン
            HStack(spacing: 8) {
                if !isCurrentUser {
                    Button(action: onSelect) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                }
                
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - ユーザー追加画面
struct AddUserView: View {
    @ObservedObject var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var nickname = ""
    @State private var birthDate = Date()
    @State private var gender: Gender = .preferNotToSay
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImageData: Data?
    @State private var showingBirthDatePicker = false
    @State private var showingGenderPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // プロフィール画像選択
                        VStack(spacing: 16) {
                            if let imageData = profileImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.orange, lineWidth: 3))
                            } else {
                                Circle()
                                    .fill(Color.orange.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 48))
                                            .foregroundColor(.orange)
                                    )
                            }
                            
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                Text("プロフィール画像を選択")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // 基本情報
                        VStack(spacing: 20) {
                            // 名前
                            VStack(alignment: .leading, spacing: 8) {
                                Text("名前 *")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                TextField("名前を入力", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.system(size: 16, design: .rounded))
                            }
                            
                            // ニックネーム
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ニックネーム")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                TextField("ニックネームを入力（任意）", text: $nickname)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.system(size: 16, design: .rounded))
                            }
                            
                            // 生年月日
                            VStack(alignment: .leading, spacing: 8) {
                                Text("生年月日")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Button(action: { showingBirthDatePicker = true }) {
                                    HStack {
                                        Text(birthDate, style: .date)
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "calendar")
                                            .foregroundColor(.orange)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // 性別
                            VStack(alignment: .leading, spacing: 8) {
                                Text("性別")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Button(action: { showingGenderPicker = true }) {
                                    HStack {
                                        Text(gender.rawValue)
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.orange)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("ユーザー追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        addUser()
                    }
                    .foregroundColor(.orange)
                    .disabled(name.isEmpty)
                }
            }
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    profileImageData = data
                }
            }
        }
        .sheet(isPresented: $showingBirthDatePicker) {
            DatePickerView(date: $birthDate, title: "生年月日を選択")
        }
        .sheet(isPresented: $showingGenderPicker) {
            GenderPickerView(gender: $gender)
        }
    }
    
    private func addUser() {
        let user = User(
            name: name,
            nickname: nickname.isEmpty ? nil : nickname,
            birthDate: birthDate,
            gender: gender,
            profileImageData: profileImageData
        )
        
        dataManager.addUser(user)
        dismiss()
    }
}

// MARK: - ユーザー編集画面
struct EditUserView: View {
    @ObservedObject var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let user: User
    @State private var name: String
    @State private var nickname: String
    @State private var birthDate: Date
    @State private var gender: Gender
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImageData: Data?
    @State private var showingBirthDatePicker = false
    @State private var showingGenderPicker = false
    
    init(user: User) {
        self.user = user
        self._name = State(initialValue: user.name)
        self._nickname = State(initialValue: user.nickname ?? "")
        self._birthDate = State(initialValue: user.birthDate ?? Date())
        self._gender = State(initialValue: user.gender ?? .preferNotToSay)
        self._profileImageData = State(initialValue: user.profileImageData)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // プロフィール画像選択
                        VStack(spacing: 16) {
                            if let imageData = profileImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.orange, lineWidth: 3))
                            } else {
                                Circle()
                                    .fill(Color.orange.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 48))
                                            .foregroundColor(.orange)
                                    )
                            }
                            
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                Text("プロフィール画像を変更")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // 基本情報
                        VStack(spacing: 20) {
                            // 名前
                            VStack(alignment: .leading, spacing: 8) {
                                Text("名前 *")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                TextField("名前を入力", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.system(size: 16, design: .rounded))
                            }
                            
                            // ニックネーム
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ニックネーム")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                TextField("ニックネームを入力（任意）", text: $nickname)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.system(size: 16, design: .rounded))
                            }
                            
                            // 生年月日
                            VStack(alignment: .leading, spacing: 8) {
                                Text("生年月日")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Button(action: { showingBirthDatePicker = true }) {
                                    HStack {
                                        Text(birthDate, style: .date)
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "calendar")
                                            .foregroundColor(.orange)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // 性別
                            VStack(alignment: .leading, spacing: 8) {
                                Text("性別")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Button(action: { showingGenderPicker = true }) {
                                    HStack {
                                        Text(gender.rawValue)
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.orange)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("ユーザー編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveUser()
                    }
                    .foregroundColor(.orange)
                    .disabled(name.isEmpty)
                }
            }
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    profileImageData = data
                }
            }
        }
        .sheet(isPresented: $showingBirthDatePicker) {
            DatePickerView(date: $birthDate, title: "生年月日を選択")
        }
        .sheet(isPresented: $showingGenderPicker) {
            GenderPickerView(gender: $gender)
        }
    }
    
    private func saveUser() {
        var updatedUser = user
        updatedUser.name = name
        updatedUser.nickname = nickname.isEmpty ? nil : nickname
        updatedUser.birthDate = birthDate
        updatedUser.gender = gender
        updatedUser.profileImageData = profileImageData
        
        dataManager.updateUser(updatedUser)
        dismiss()
    }
}

// MARK: - 日付選択ビュー
struct DatePickerView: View {
    @Binding var date: Date
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    title,
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - 性別選択ビュー
struct GenderPickerView: View {
    @Binding var gender: Gender
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Gender.allCases, id: \.self) { genderOption in
                    Button(action: {
                        gender = genderOption
                        dismiss()
                    }) {
                        HStack {
                            Text(genderOption.rawValue)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if gender == genderOption {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
            }
            .navigationTitle("性別を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
} 