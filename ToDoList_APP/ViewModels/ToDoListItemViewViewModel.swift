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
        itemCopy.isDone = !itemCopy.isDone
        if itemCopy.isDone {
            // タスク完了時の処理
            if let elapsedTime = timerViewModel?.elapsedTime {
                itemCopy.elapsedTime = elapsedTime
            }
            timerViewModel?.completeTask()
            itemCopy.calculateMetrics()
        } else {
            // タスクを未完了に戻す処理
            timerViewModel?.resetTimer()
            itemCopy.elapsedTime = 0
            itemCopy.predictionAccuracy = nil
            itemCopy.efficiencyIndex = nil
            itemCopy.timeSavingAchievement = nil
        }
        
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
            "lastUpdated": Date().timeIntervalSince1970
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
}
