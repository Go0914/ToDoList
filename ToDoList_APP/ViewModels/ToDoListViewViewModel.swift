import FirebaseFirestore
import Foundation

// ToDoリストのビューモデルクラス
class ToDoListViewViewModel: ObservableObject {
    // 新しいアイテムを追加するビューを表示するかどうかのフラグ
    @Published var showingNewItemView = false
    // ToDoリストのアイテム配列
    @Published var items: [ToDoListItem] = []
    
    // ユーザーID
    private var userId: String
    // Firestoreのリアルタイムリスナー
    private var listenerRegistration: ListenerRegistration?
    
    // イニシャライザ
    init(userId: String) {
        self.userId = userId
        setupRealtimeUpdates()
    }
    
    // アイテムを削除する関数
    func delete(id: String) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("todos")
            .document(id)
            .delete() { error in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                    // ローカルの配列からも削除
                    self.items.removeAll { $0.id == id }
                }
            }
    }
    
    // Firestoreのリアルタイム更新をセットアップする関数
    func setupRealtimeUpdates() {
        print("Setting up realtime updates for user: \(userId)")
        let db = Firestore.firestore()
        listenerRegistration = db.collection("users")
            .document(userId)
            .collection("todos")
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                // ドキュメントをToDoListItemオブジェクトに変換
                self.items = querySnapshot?.documents.compactMap { document in
                    do {
                        var item = try document.data(as: ToDoListItem.self)
                        item.calculateMetrics()
                        print("Successfully parsed item: \(item)")
                        print("Parsed item metrics - predictionAccuracy: \(item.predictionAccuracy ?? 0), efficiencyIndex: \(item.efficiencyIndex ?? 0), timeSavingAchievement: \(item.timeSavingAchievement ?? 0)")
                        return item
                    } catch {
                        print("Error parsing document \(document.documentID): \(error)")
                        // パースに失敗した場合、利用可能なデータでToDoListItemを作成
                        if let title = document.data()["title"] as? String,
                           let dueDate = document.data()["dueDate"] as? TimeInterval,
                           let createdDate = document.data()["createdDate"] as? TimeInterval {
                            var item = ToDoListItem(id: document.documentID,
                                                    title: title,
                                                    dueDate: dueDate,
                                                    createdDate: createdDate,
                                                    isDone: document.data()["isDone"] as? Bool ?? false,
                                                    estimatedTime: document.data()["estimatedTime"] as? Double,
                                                    progress: document.data()["progress"] as? Double ?? 0.0,
                                                    elapsedTime: document.data()["elapsedTime"] as? Double ?? 0)
                            item.calculateMetrics()
                            print("Parsed item metrics (from partial data) - predictionAccuracy: \(item.predictionAccuracy ?? 0), efficiencyIndex: \(item.efficiencyIndex ?? 0), timeSavingAchievement: \(item.timeSavingAchievement ?? 0)")
                            return item
                        }
                        return nil
                    }
                } ?? []
                
                print("Fetched \(self.items.count) items")
            }
    }
    
    // 新しいアイテムを追加する関数
    func addItem(_ item: ToDoListItem) {
        print("Adding item: \(item)")
        var newItem = item
        newItem.elapsedTime = 0
        let db = Firestore.firestore()
        do {
            try db.collection("users")
                .document(userId)
                .collection("todos")
                .document(newItem.id)
                .setData(from: newItem)
            
            print("Item added successfully")
        } catch {
            print("Error adding document: \(error)")
        }
    }
    
    // デイニシャライザ：リスナーを解除
    deinit {
        listenerRegistration?.remove()
    }
}

// プレビュー用の拡張
extension ToDoListViewViewModel {
    // プレビュー用のダミーデータを持つビューモデルを生成
    static var preview: ToDoListViewViewModel {
        let viewModel = ToDoListViewViewModel(userId: "HKdvXLQ7WhY1qQaEhmOT8gXnWH93")
        viewModel.items = [
            ToDoListItem(id: "1", title: "テストタスク1", dueDate: Date().timeIntervalSince1970, createdDate: Date().timeIntervalSince1970, isDone: false, estimatedTime: 1.0),
            ToDoListItem(id: "2", title: "テストタスク2", dueDate: Date().timeIntervalSince1970, createdDate: Date().timeIntervalSince1970, isDone: true, estimatedTime: 2.0)
        ]
        return viewModel
    }
}
