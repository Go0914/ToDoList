import FirebaseAuth
import FirebaseFirestore
import Foundation

// ToDoリストアイテムの詳細ビュー用のビューモデルクラス
class ToDoListItemViewViewModel: ObservableObject {
    // 進捗更新用のタイマー
    private var progressUpdateTimer: Timer?
    // 現在表示中のToDoアイテム
    @Published var currentItem: ToDoListItem?
    // アイテムの進捗状況（0.0から1.0の範囲）
    @Published var progress: Double = 0.0

    // イニシャライザ
    init() {
        startProgressUpdateTimer()
    }

    // アイテムの完了状態を切り替える関数
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

    // 進捗更新タイマーを開始する関数
    private func startProgressUpdateTimer() {
        progressUpdateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self, let item = self.currentItem else { return }
            self.updateProgress(for: item)
        }
    }

    // 進捗更新タイマーを停止する関数
    private func stopProgressUpdateTimer() {
        progressUpdateTimer?.invalidate()
        progressUpdateTimer = nil
    }

    // 現在のアイテムを設定する関数
    func setCurrentItem(_ item: ToDoListItem) {
        currentItem = item
        updateProgress(for: item)
    }

    // デイニシャライザ
    deinit {
        stopProgressUpdateTimer()
    }

    // アイテムの進捗を更新する関数
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

    // 手動で進捗を更新する関数
    func updateProgressManually(_ newProgress: Double) {
        progress = min(max(newProgress, 0.0), 1.0)
        updateFirestore()
    }

    // Firestoreの進捗情報を更新する関数
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
