import Foundation

struct ToDoListItem: Codable, Identifiable {
    let id: String            // 項目の一意識別子
    let title: String         // 項目のタイトル
    let dueDate: TimeInterval // 期限（UNIX時間）
    let createdDate: TimeInterval // 作成日時（UNIX時間）
    var isDone: Bool          // 完了状態
    let estimatedTime: Double? // 見積もり時間（オプショナル）、時間単位
    var progress: Double      // 進捗状況（0.0 〜 1.0）
    var lastUpdated: TimeInterval // 最終更新日時
    var actualTime: TimeInterval?  // 実際にかかった時間（オプショナル）
    var elapsedTime: Double // 経過時間（秒単位）
    var predictionAccuracy: Double?
    var efficiencyIndex: Double?
    var timeSavingAchievement: Double?
    
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
        self.calculateMetrics() // 初期化時にメトリクスを計算
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

        let estimatedTimeInSeconds = estimatedTime * 3600 // 時間を秒に変換
        let minimumElapsedTime = max(elapsedTime, 60) // 最小1分
        let maximumElapsedTime = min(elapsedTime, estimatedTimeInSeconds * 5) // 予測時間の5倍を上限とする

        // 予測精度の計算（0%から100%の範囲に制限）
        predictionAccuracy = max(0, min(100, 100 - abs(maximumElapsedTime - estimatedTimeInSeconds) / estimatedTimeInSeconds * 100))
        print("計算済み - predictionAccuracy: \(predictionAccuracy ?? 0)")

        // 効率指数の計算（0.1から5の範囲に制限）
        efficiencyIndex = max(0.1, min(5, maximumElapsedTime / estimatedTimeInSeconds))
        print("計算済み - efficiencyIndex: \(efficiencyIndex ?? 0)")

        // 時間節約達成度の計算（-400%から100%の範囲に制限）
        timeSavingAchievement = max(-400, min(100, (estimatedTimeInSeconds - maximumElapsedTime) / estimatedTimeInSeconds * 100))
        print("計算済み - timeSavingAchievement: \(timeSavingAchievement ?? 0)")

        print("完了: calculateMetrics()")
    }
}
