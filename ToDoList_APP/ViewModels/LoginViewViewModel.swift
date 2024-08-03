//
//  LoginViewViewModel.swift
//  ToDoList_APP
//
//  Created by 清水豪 on 2024/07/06.
//

import FirebaseAuth
import Foundation

// LoginViewViewModelクラスは、ログイン画面のビューとモデルを接続するViewModelです。
// ObservableObjectプロトコルを採用しており、SwiftUIと連携して画面の再描画を行います。
class LoginViewViewModel: ObservableObject {
    
    // ユーザーが入力したメールアドレスを保持するプロパティ
    @Published var email = ""
    
    // ユーザーが入力したパスワードを保持するプロパティ
    @Published var password = ""
    
    // エラーメッセージを保持するプロパティ
    @Published var errorMessage = ""
    
    // イニシャライザ
    init() {}
    
    // ログインを試みる関数
    func login() {
        // 入力のバリデーションを行い、失敗した場合は処理を終了する
        guard validate() else {
            return
        }
        // Firebaseを使用してログインを試みる
        Auth.auth().signIn(withEmail: email, password: password)
    }
    
    // 入力のバリデーションを行うプライベート関数
    private func validate() -> Bool {
        // エラーメッセージをクリア
        errorMessage = ""
        
        // メールアドレスとパスワードが空でないか確認
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            
            // 空のフィールドがある場合のエラーメッセージ
            errorMessage = "すべてのフィールドに入力してください。"
            return false
        }
        
        // メールアドレスが正しい形式であるか確認
        guard email.contains("@") && email.contains(".") else {
            // メールアドレスが無効な場合のエラーメッセージ
            errorMessage = "有効なメールアドレスを入力してください。"
            return false
        }
        
        // バリデーション成功
        return true
    }
}

