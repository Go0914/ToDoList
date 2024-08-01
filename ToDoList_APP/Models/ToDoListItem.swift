import Foundation

struct ToDoListItem: Codable, Identifiable {
    let id: String
    let title: String
    let dueDate: TimeInterval
    let createdDate: TimeInterval
    var isDone: Bool
    let estimatedTime: Double?
    var progress: Double
    var lastUpdated: Date
    var actualTime: TimeInterval?  // Changed to optional
    var elapsedTime: TimeInterval?
    
    init(id: String, title: String, dueDate: TimeInterval, createdDate: TimeInterval, isDone: Bool, estimatedTime: Double? = nil, progress: Double = 0.0, lastUpdated: Date = Date(), actualTime: TimeInterval? = nil, elapsedTime: TimeInterval? = nil) {
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
    
    func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "dueDate": dueDate,
            "createdDate": createdDate,
            "isDone": isDone,
            "estimatedTime": estimatedTime as Any,
            "progress": progress,
            "lastUpdated": lastUpdated
        ]
    }
}
