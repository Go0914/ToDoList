import FirebaseAuth
import FirebaseFirestore
import Foundation

class ToDoListItemViewViewModel: ObservableObject {
    @Published var currentItem: ToDoListItem?
    var timerViewModel: ProgressiveRingTimerViewModel?

    init(item: ToDoListItem) {
        self.currentItem = item
        self.timerViewModel = ProgressiveRingTimerViewModel(estimatedTime: item.estimatedTime)
    }

    func toggleIsDone(item: ToDoListItem) {
        var itemCopy = item
        let previousState = itemCopy.isDone
        itemCopy.isDone.toggle()
        
        if itemCopy.isDone && !previousState {
            // タスク完了時の処理
            if let elapsedTime = timerViewModel?.elapsedTime {
                itemCopy.elapsedTime = elapsedTime
            }
            let (_, isOvertime) = timerViewModel?.completeTask() ?? (0, false)
            itemCopy.calculateMetrics(isOvertime: isOvertime)
        } else if !itemCopy.isDone && previousState {
            // タスクを未完了に戻す処理
            // タイマーはリセットせず、経過時間を保持
            itemCopy.predictionAccuracy = nil
            itemCopy.efficiencyIndex = nil
            itemCopy.timeSavingAchievement = nil
        }
        
        self.currentItem = itemCopy  // 即座にcurrentItemを更新
        updateFirestore(item: itemCopy)
    }

    func updateElapsedTime() {
        guard var item = currentItem else { return }
        if let elapsedTime = timerViewModel?.elapsedTime {
            item.elapsedTime = elapsedTime
            currentItem = item
            updateFirestore(item: item)
        }
    }

    private func updateFirestore(item: ToDoListItem) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("todos").document(item.id).updateData([
            "isDone": item.isDone,
            "elapsedTime": item.elapsedTime,
            "lastUpdated": Date().timeIntervalSince1970,
            "efficiencyIndex": item.efficiencyIndex ?? NSNull(),
            "predictionAccuracy": item.predictionAccuracy ?? NSNull(),
            "timeSavingAchievement": item.timeSavingAchievement ?? NSNull()
        ]) { error in
            if let error = error {
                print("Firestore update error: \(error)")
            } else {
                self.currentItem = item
            }
        }
    }

    func startTimer() {
        timerViewModel?.startTimer()
    }

    func stopTimer() {
        timerViewModel?.stopTimer()
        updateElapsedTime()
    }

    func setCurrentItem(_ item: ToDoListItem) {
        currentItem = item
        timerViewModel = ProgressiveRingTimerViewModel(estimatedTime: item.estimatedTime)
        if let elapsedTime = currentItem?.elapsedTime {
            timerViewModel?.elapsedTime = elapsedTime
        }
    }
    
    func generateFeedbackMessage(for item: ToDoListItem) -> String {
        guard let efficiency = item.efficiencyIndex else {
            return "タスクが完了しました！"
        }
        
        if efficiency >= 1.0 {
            return "素晴らしい仕事です！予定より早くタスクを完了しました。"
        } else if efficiency >= 0.8 {
            return "よくできました！ほぼ予定通りにタスクを完了しました。"
        } else {
            return "タスクを完了しました。次回はより効率的に取り組めるでしょう。"
        }
    }

    func deleteItem() {
        guard let item = currentItem, let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("todos").document(item.id).delete { error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Document successfully deleted")
                // ここで必要に応じて、親ビューモデルに削除を通知するなどの処理を追加できます
            }
        }
    }
}

extension ToDoListItem {
    mutating func calculateMetrics(isOvertime: Bool) {
        guard let estimatedTime = estimatedTime else { return }
        
        // Efficiency Index
        efficiencyIndex = estimatedTime / (elapsedTime / 3600.0) // Convert seconds to hours
        
        // Prediction Accuracy
        predictionAccuracy = isOvertime ? estimatedTime / (elapsedTime / 3600.0) : (elapsedTime / 3600.0) / estimatedTime
        
        // Time Saving Achievement
        timeSavingAchievement = isOvertime ? 0 : (estimatedTime - (elapsedTime / 3600.0)) / estimatedTime * 100
    }
}
