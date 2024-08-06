import Foundation
import SwiftUI

class TaskCompletionViewModel: ObservableObject {
    @Published var item: ToDoListItem
    @Published var showDetails = false
    @Published var detailHeight: CGFloat = 0
    
    // カスタムカラーをプロパティとして定義
    let primaryColor = Color(hex: "#4A69BD")
    let accentColor = Color(hex: "#8E44AD")
    let bgColor = Color(hex: "#F4F6F9")
    let textColor = Color(hex: "#333333")
    let subTextColor = Color(hex: "#666666")
    let successColor = Color(hex: "#27AE60")
    let warningColor = Color(hex: "#F39C12")
    let cardBgColor = Color.white
    
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
    
    var detailedMetrics: [(title: String, value: Double, description: String, color: Color)] {
        return [
            (title: "予測精度", value: item.predictionAccuracy ?? 0, description: "100%に近いほど正確", color: successColor),
            (title: "効率指数", value: item.efficiencyIndex ?? 0, description: "1.0未満は予測より早く完了", color: warningColor),
            (title: "時間節約", value: item.timeSavingAchievement ?? 0, description: "正の値は時間節約を示す", color: accentColor)
        ]
    }
    
    func timeCardView(title: String, time: Double, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(subTextColor)
            
            Text(formatTime(time))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    func metricView(title: String, value: Double, format: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(subTextColor)
            
            Spacer()
            
            Text(String(format: format, value))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(textColor)
        }
        .padding(12)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
