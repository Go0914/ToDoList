import FirebaseAuth
import FirebaseFirestore
import Foundation

class ToDoListItemViewViewModel: ObservableObject {
    @Published var item: ToDoListItem
    @Published var timerViewModel: ProgressiveRingTimerViewModel?
    
    init(item: ToDoListItem) {
        self.item = item
        self.timerViewModel = ProgressiveRingTimerViewModel(estimatedTime: item.estimatedTime)
        self.timerViewModel?.elapsedTime = item.elapsedTime
        self.timerViewModel?.updateTimerState(item.timerState)
    }
    
    
    //以下の部分から始める。とくにtoggleIsDoneの部分や、ProgressiveRingTimerViewModelで定義したもの定義されていたものに対して必要、不必要性をもっと考えないといけない。currentItemの定義箇所も判断必要。
    
    func toggleTimer() {
        if let isRunning = timerViewModel?.isRunning, isRunning {
            timerViewModel?.pauseTimer()
            item.timerState = .paused
        } else {
            timerViewModel?.startTimer()
            item.timerState = .running
        }
        //まだわからない
        //updateFirestore(item: item)
    }
    
    
//必要性の議論の余地あり
    func toggleIsDone() {
        let previousState = item.isDone
        item.isDone.toggle()

        if item.isDone && !previousState {
            if let elapsedTime = timerViewModel?.elapsedTime {
                item.elapsedTime = elapsedTime
            }
            let (_, isOvertime) = timerViewModel?.completeTask() ?? (0, false)
            item.calculateMetrics(isOvertime: isOvertime)
        } else if !item.isDone && previousState {
            item.predictionAccuracy = nil
            item.efficiencyIndex = nil
            item.timeSavingAchievement = nil
        }

        updateFirestore(item: item)
    }

    
    func completeTask() {
        if let timerViewModel = timerViewModel {
            let result = timerViewModel.completeTask()
            item.isDone = true
            item.timerState = .completed
            item.elapsedTime = result.elapsedTime
            item.actualTime = result.elapsedTime
            calculateMetrics(isOvertime: result.isOvertime)
            updateFirestore(item: item) //議論の余地あり
        } else {
            // timerViewModelがnilの場合の処理が必要であれば、ここで対応
            print("ToDoListItemViewViewModelのcompleteTaskでエラーだよ")
        }
    }
    
    private func calculateMetrics(isOvertime: Bool) {
        guard let estimatedTime = item.estimatedTime else { return }
        let estimatedTimeInSeconds = estimatedTime * 3600
        item.predictionAccuracy = max(0, min(100, 100 - abs(item.elapsedTime - estimatedTimeInSeconds) / estimatedTimeInSeconds * 100))
        item.efficiencyIndex = max(0.1, min(5, item.elapsedTime / estimatedTimeInSeconds))
        item.timeSavingAchievement = max(-400, min(100, (estimatedTimeInSeconds - item.elapsedTime) / estimatedTimeInSeconds * 100))
    }
    

    func updateElapsedTime() {
        if let elapsedTime = timerViewModel?.elapsedTime {
            item.elapsedTime = elapsedTime
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
                print("Firestore update error: \\(error)")
            }
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
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
