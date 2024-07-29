import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewItemViewViewModel: ObservableObject {
    @Published var title = ""
    @Published var dueDate = Date()
    @Published var showAlert = false
    @Published var estimatedTimeIndex = 0
    @Published var estimatedTime: Double? = 0.0
    let estimatedTimes = [0.25, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]

    var toDoListViewModel: ToDoListViewViewModel?

    init(toDoListViewModel: ToDoListViewViewModel? = nil) {
        self.toDoListViewModel = toDoListViewModel
    }
    
    func save() {
        guard canSave else {
            return
        }
        
        guard let uId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let newId = UUID().uuidString
        let newItem = ToDoListItem(
            id: newId,
            title: title,
            dueDate: dueDate.timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            estimatedTime: estimatedTimes[estimatedTimeIndex]
        )
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(uId)
            .collection("todos")
            .document(newId)
            .setData(newItem.asDictionary()) { [weak self] error in
                if let error = error {
                    print("Error writing document: \(error)")
                } else {
                    print("Document successfully written!")
                    // ToDoListViewViewModel の items 配列を更新
                    self?.toDoListViewModel?.addItem(newItem)
                }
            }
    }
    
    var canSave: Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        guard dueDate >= Date().addingTimeInterval(-86400) else {
            return false
        }
        
        if let estimatedTime = estimatedTime, estimatedTime < 0 {
            return false
        }
        
        return true
    }
}
