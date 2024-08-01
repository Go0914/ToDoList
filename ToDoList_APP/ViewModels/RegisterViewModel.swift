//
//  RegisterViewModel.swift
//  ToDoList_APP
//
//  Created by 清水豪 on 2024/07/06.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation

class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    
    init() {}
    
    func register() {
        guard validate() else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userId = result?.user.uid else {
                return
            }
            
            self?.insertUserData(Id: userId)
        }
    }
    
    private func insertUserData(Id: String) {
        let newUser = User(id: Id, 
                           name: name,
                           email: email,
                           joined: Date().timeIntervalSince1970)
                           
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(Id)
            .setData(newUser.asDictionary())
                           
        
        
        
    }
    
    private func validate() -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            return false
        }
        
        guard password.count >= 6 else {
            return false //password
        }
        
        return true // この行を追加
    }
} 
