import FirebaseAuth
import FirebaseFirestore
import Foundation

// 新しいToDoアイテムを作成するためのビューモデルクラス
class NewItemViewViewModel: ObservableObject {
    @Published var title = "" // アイテムのタイトル
    @Published var dueDate = Date() // アイテムの期限
    @Published var showAlert = false // アラートを表示するかどうかのフラグ
    @Published var estimatedTimeIndex = 0 // 選択された予想時間のインデックス
    @Published var estimatedTime: Double? = 0.0 // アイテムの予想時間
    let estimatedTimes = [0.25, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0] // 予想時間の選択肢（時間単位）
    var timerViewModel: ProgressiveRingTimerViewModel?
    var toDoListViewModel: ToDoListViewViewModel? // ToDoリストのビューモデルへの参照

    // イニシャライザ
    init(toDoListViewModel: ToDoListViewViewModel? = nil) {
        self.toDoListViewModel = toDoListViewModel
    }
    
    // 新しいアイテムを保存する関数
    func save() {
        guard canSave else {
            return // 保存条件を満たさない場合は何もしない
        }
        
        guard let uId = Auth.auth().currentUser?.uid else {
            return // ユーザーが認証されていない場合は何もしない
        }
        
        let newId = UUID().uuidString // 新しいアイテムのユニークIDを生成
        let newItem = ToDoListItem(
            id: newId, // アイテムのID
            title: title, // アイテムのタイトル
            dueDate: dueDate.timeIntervalSince1970, // アイテムの期限（タイムスタンプ）
            createdDate: Date().timeIntervalSince1970, // 作成日時（タイムスタンプ）
            isDone: false, // アイテムが完了しているかどうかのフラグ
            estimatedTime: estimatedTimes[estimatedTimeIndex], // 予想時間
            elapsedTime: timerViewModel?.elapsedTime ?? 0.0 //経過時間
        )
        
        let db = Firestore.firestore() // Firestoreデータベースの参照
        
        db.collection("users")
            .document(uId) // 現在のユーザーのドキュメントを参照
            .collection("todos")
            .document(newId) // 新しいToDoアイテムのドキュメントを作成
            .setData(newItem.asDictionary()) { [weak self] error in
                if let error = error {
                    print("Error writing document: \(error)") // エラーが発生した場合はエラーメッセージを表示
                } else {
                    print("Document successfully written!") // 成功した場合は成功メッセージを表示
                    self?.toDoListViewModel?.addItem(newItem) // ToDoリストのビューモデルにアイテムを追加
                }
            }
    }
    
    // アイテムを保存できるかどうかを判断するプロパティ
    var canSave: Bool {
        // タイトルが空でないことを確認
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false // タイトルが空の場合は保存不可
        }
        
        // 期限が現在時刻から24時間以内でないことを確認
        guard dueDate >= Date().addingTimeInterval(-86400) else {
            return false // 期限が24時間以内の場合は保存不可
        }
        
        // 予想時間が負の値でないことを確認
        if let estimatedTime = estimatedTime, estimatedTime < 0 {
            return false // 予想時間が負の値の場合は保存不可
        }
        
        return true // 全ての条件を満たした場合は保存可能
    }
}
