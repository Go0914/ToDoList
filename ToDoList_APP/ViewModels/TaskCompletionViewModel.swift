import SwiftUI

struct DetailedMetric {
    let title: String
    let value: Double
    let description: String
    let color: Color
}

class TaskCompletionViewModel: ObservableObject {
    @Published var item: ToDoListItem
    
    var detailedMetrics: [DetailedMetric] {
        [
            DetailedMetric(title: "予測精度", value: item.predictionAccuracy ?? 0, description: "100%に近いほど正確", color: .green),
            DetailedMetric(title: "効率指数", value: item.efficiencyIndex ?? 0, description: "1.0未満は予測より早く完了", color: .orange),
            DetailedMetric(title: "時間節約", value: item.timeSavingAchievement ?? 0, description: "正の値は時間節約を示す", color: .blue)
        ]
    }
    
    init(item: ToDoListItem) {
        self.item = item
    }
    
    func formatTime(_ interval: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(interval)) ?? "N/A"
    }
    
    func normalizedValue(for value: Double, title: String) -> Double {
        switch title {
        case "予測精度":
            return value / 100
        case "効率指数":
            return value > 2 ? 1 : value / 2
        case "時間節約":
            return (value + 100) / 200
        default:
            return 0
        }
    }
}
