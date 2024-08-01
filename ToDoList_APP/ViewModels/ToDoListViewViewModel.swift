import FirebaseFirestore
import Foundation

class ToDoListViewViewModel: ObservableObject {
    @Published var showingNewItemView = false
    @Published var items: [ToDoListItem] = []
    
    private var userId: String
    private var listenerRegistration: ListenerRegistration?
    
    init(userId: String) {
        self.userId = userId
        setupRealtimeUpdates()
    }
    
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
                    self.items.removeAll { $0.id == id }
                }
            }
    }
    
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
                
                self.items = querySnapshot?.documents.compactMap { document in
                    do {
                        let item = try document.data(as: ToDoListItem.self)
                        print("Successfully parsed item: \(item)")
                        return item
                    } catch {
                        print("Error parsing document \(document.documentID): \(error)")
                        // Attempt to create a ToDoListItem with available data
                        if let title = document.data()["title"] as? String,
                           let dueDate = document.data()["dueDate"] as? TimeInterval,
                           let createdDate = document.data()["createdDate"] as? TimeInterval {
                            return ToDoListItem(id: document.documentID,
                                                title: title,
                                                dueDate: dueDate,
                                                createdDate: createdDate,
                                                isDone: document.data()["isDone"] as? Bool ?? false,
                                                estimatedTime: document.data()["estimatedTime"] as? Double,
                                                progress: document.data()["progress"] as? Double ?? 0.0)
                        }
                        return nil
                    }
                } ?? []
                
                print("Fetched \(self.items.count) items")
            }
    }
    
    func addItem(_ item: ToDoListItem) {
        print("Adding item: \(item)")
        let db = Firestore.firestore()
        do {
            try db.collection("users")
                .document(userId)
                .collection("todos")
                .document(item.id)
                .setData(from: item)
            
            print("Item added successfully")
        } catch {
            print("Error adding document: \(error)")
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}

// プレビュー用の拡張
extension ToDoListViewViewModel {
    static var preview: ToDoListViewViewModel {
        let viewModel = ToDoListViewViewModel(userId: "HKdvXLQ7WhY1qQaEhmOT8gXnWH93")
        viewModel.items = [
            ToDoListItem(id: "1", title: "テストタスク1", dueDate: Date().timeIntervalSince1970, createdDate: Date().timeIntervalSince1970, isDone: false, estimatedTime: 1.0),
            ToDoListItem(id: "2", title: "テストタスク2", dueDate: Date().timeIntervalSince1970, createdDate: Date().timeIntervalSince1970, isDone: true, estimatedTime: 2.0)
        ]
        return viewModel
    }
}
