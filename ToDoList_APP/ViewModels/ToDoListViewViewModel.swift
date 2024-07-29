import FirebaseFirestore
import Foundation

class ToDoListViewViewModel: ObservableObject {
    @Published var showingNewItemView = false
    @Published var items: [ToDoListItem] = []
    
    private var userId: String
    
    init(userId: String) {
        self.userId = userId
        fetchTodos()
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
    
    func fetchTodos() {
        print("Fetching todos for user: \(userId)")
        let db = Firestore.firestore()
        db.collection("users")
          .document(userId)
          .collection("todos")
          .getDocuments { [weak self] (querySnapshot, error) in
              if let error = error {
                  print("Error getting documents: \(error)")
              } else {
                  if let querySnapshot = querySnapshot {
                      print("Number of documents: \(querySnapshot.documents.count)")
                      self?.items = querySnapshot.documents.compactMap { document in
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
                      }
                  } else {
                      print("QuerySnapshot is nil")
                  }
                  print("Fetched \(self?.items.count ?? 0) items")
              }
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
            
            // ローカルの配列に新しいアイテムを追加
            self.items.append(item)
            print("Item added successfully")
        } catch {
            print("Error adding document: \(error)")
        }
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
