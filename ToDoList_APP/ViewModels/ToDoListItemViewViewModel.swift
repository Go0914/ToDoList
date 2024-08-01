import FirebaseAuth
import FirebaseFirestore
import Foundation
class ToDoListItemViewViewModel: ObservableObject {
    private var progressUpdateTimer: Timer?
    @Published var currentItem: ToDoListItem?
    @Published var progress: Double = 0.0

    init() {
        startProgressUpdateTimer()
    }

    func toggleIsDone(item: ToDoListItem) {
        var itemCopy = item
        itemCopy.isDone = !itemCopy.isDone

        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .document(uid)
            .collection("todos")
            .document(itemCopy.id)
            .setData(itemCopy.asDictionary()) { [weak self] error in
                if let error = error {
                    print("ドキュメント更新エラー: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self?.currentItem = itemCopy
                        self?.updateProgress(for: itemCopy)
                    }
                }
            }
    }

    private func startProgressUpdateTimer() {
        progressUpdateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self, let item = self.currentItem else { return }
            self.updateProgress(for: item)
        }
    }

    private func stopProgressUpdateTimer() {
        progressUpdateTimer?.invalidate()
        progressUpdateTimer = nil
    }

    func setCurrentItem(_ item: ToDoListItem) {
        currentItem = item
        updateProgress(for: item)
    }

    deinit {
        stopProgressUpdateTimer()
    }

    private func updateProgress(for item: ToDoListItem) {
        guard let estimatedTime = item.estimatedTime else {
            progress = 0.0
            return
        }

        if item.isDone {
            progress = 1.0
        } else {
            let currentTime = Date().timeIntervalSince1970
            let elapsedTime = currentTime - item.createdDate
            progress = min(elapsedTime / (estimatedTime * 3600), 1.0)
        }
    }

    func updateProgressManually(_ newProgress: Double) {
        progress = min(max(newProgress, 0.0), 1.0)
        updateFirestore()
    }
    private func updateFirestore() {
        guard let uid = Auth.auth().currentUser?.uid, let itemId = currentItem?.id else {
            print("Error: User not authenticated or item ID not available")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("todos").document(itemId).updateData([
            "progress": progress,
            "lastUpdated": Date()
        ]) { [weak self] error in
            if let error = error {
                print("Firestore update error: \(error)")
            } else {
                self?.currentItem?.progress = self?.progress ?? 0.0
                self?.currentItem?.lastUpdated = Date()
            }
        }
    }
}
