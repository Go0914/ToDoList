import Foundation

struct ToDoListItem: Codable, Identifiable {
    let id: String
    let title: String
    let dueDate: TimeInterval
    let createdDate: TimeInterval
    var isDone: Bool
    let estimatedTime: Double?
    var progress: Double
    var lastUpdated: TimeInterval
    var actualTime: TimeInterval?
    var elapsedTime: Double
    var predictionAccuracy: Double?
    var efficiencyIndex: Double?
    var timeSavingAchievement: Double?
    var timerState: TimerState = .notStarted // TimerStateに修正

    // TimerState列挙型を定義
    enum TimerState: Codable { // TimeStateからTimerStateに修正
        case notStarted
        case running
        case paused
        case completed
    }

    // イニシャライザ
    init(id: String, title: String, dueDate: TimeInterval, createdDate: TimeInterval, isDone: Bool, estimatedTime: Double? = nil, progress: Double = 0.0, lastUpdated: TimeInterval = Date().timeIntervalSince1970, actualTime: TimeInterval? = nil, elapsedTime: Double = 0.0) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.createdDate = createdDate
        self.isDone = isDone
        self.estimatedTime = estimatedTime
        self.progress = progress
        self.lastUpdated = lastUpdated
        self.actualTime = actualTime
        self.elapsedTime = elapsedTime
        self.predictionAccuracy = nil
        self.efficiencyIndex = nil
        self.timeSavingAchievement = nil
        self.calculateMetrics()
    }
    
    // メトリクスを計算するメソッド
    mutating func calculateMetrics() {
        print("開始: calculateMetrics()")
        print("入力値 - elapsedTime: \(elapsedTime), estimatedTime: \(estimatedTime ?? 0), isDone: \(isDone)")

        guard isDone, let estimatedTime = estimatedTime, estimatedTime > 0 else {
            print("タスクが完了していないか、予測時間が無効です")
            predictionAccuracy = nil
            efficiencyIndex = nil
            timeSavingAchievement = nil
            return
        }

        let estimatedTimeInSeconds = estimatedTime * 3600
        let minimumElapsedTime = max(elapsedTime, 60)
        let maximumElapsedTime = min(elapsedTime, estimatedTimeInSeconds * 5)

        predictionAccuracy = max(0, min(100, 100 - abs(maximumElapsedTime - estimatedTimeInSeconds) / estimatedTimeInSeconds * 100))
        print("計算済み - predictionAccuracy: \(predictionAccuracy ?? 0)")

        efficiencyIndex = max(0.1, min(5, maximumElapsedTime / estimatedTimeInSeconds))
        print("計算済み - efficiencyIndex: \(efficiencyIndex ?? 0)")

        timeSavingAchievement = max(-400, min(100, (estimatedTimeInSeconds - maximumElapsedTime) / estimatedTimeInSeconds * 100))
        print("計算済み - timeSavingAchievement: \(timeSavingAchievement ?? 0)")

        print("完了: calculateMetrics()")
    }
}
