import Foundation

// ToDoリストの各項目を表現する構造体
struct ToDoListItem: Codable, Identifiable {
    let id: String            // 項目の一意識別子
    let title: String         // 項目のタイトル
    let dueDate: TimeInterval // 期限（UNIX時間）
    let createdDate: TimeInterval // 作成日時（UNIX時間）
    var isDone: Bool          // 完了状態
    let estimatedTime: Double? // 見積もり時間（オプショナル）
    var progress: Double      // 進捗状況（0.0 〜 1.0）
    var lastUpdated: Date     // 最終更新日時
    var actualTime: TimeInterval?  // 実際にかかった時間（オプショナル）
    var elapsedTime: Double // 経過時間
    
    // イニシャライザ
    init(id: String, title: String, dueDate: TimeInterval, createdDate: TimeInterval, isDone: Bool, estimatedTime: Double? = nil, progress: Double = 0.0, lastUpdated: Date = Date(), actualTime: TimeInterval? = nil, elapsedTime: Double = 0.0) {
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
    }
    
    // 構造体をディクショナリに変換するメソッド
    func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "dueDate": dueDate,
            "createdDate": createdDate,
            "isDone": isDone,
            "estimatedTime": estimatedTime as Any, // オプショナル値をAnyにキャスト
            "progress": progress,
            "lastUpdated": lastUpdated
            // 注意: actualTimeとelapsedTimeはディクショナリに含まれていません
        ]
    }
}
