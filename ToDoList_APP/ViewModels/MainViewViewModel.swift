//
//  MainViewViewModel.swift
//  ToDoList_APP
//
//  Created by 清水豪 on 2024/07/06.
//

import FirebaseAuth
import Foundation

class MainViewViewModel: ObservableObject {
    @Published var currentUserId: String = ""
    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        self.handler = Auth.auth().addStateDidChangeListener {[weak self]_, user in
            DispatchQueue.main.async{
                self? .currentUserId = user?.uid ?? ""
            }
        }
    }
    
    public var isSinedIn: Bool {
        return Auth.auth().currentUser != nil
        
    }
}
