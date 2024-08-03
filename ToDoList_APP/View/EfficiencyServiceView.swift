import SwiftUI

struct PreviewToDoListItem {
    var title: String
    var estimatedTime: TimeInterval
    var elapsedTime: TimeInterval
    
    var predictionAccuracy: Double {
        return 100 - abs(elapsedTime - estimatedTime) / estimatedTime * 100
    }
    
    var efficiencyIndex: Double {
        return elapsedTime / estimatedTime
    }
    
    var timeSavingAchievement: Double {
        return (estimatedTime - elapsedTime) / estimatedTime * 100
    }
}

struct TaskCompletionView: View {
    let item: PreviewToDoListItem
    @State private var animateProgress = false
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            timeComparisonView
            keyMetricsView
            
            if showDetails {
                detailedMetricsView
            }
            
            toggleDetailsButton
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                animateProgress = true
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.headline)
                Text("タスク完了")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.green)
        }
    }
    
    private var timeComparisonView: some View {
        HStack {
            timeCard(title: "予測時間", time: item.estimatedTime)
            timeCard(title: "実際の時間", time: item.elapsedTime)
        }
    }
    
    private func timeCard(title: String, time: TimeInterval) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(formatTime(time))
                .font(.system(.body, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var keyMetricsView: some View {
        HStack(spacing: 15) {
            metricView(title: "予測精度", value: item.predictionAccuracy, format: "%.1f%%", color: .blue)
            metricView(title: "効率指数", value: item.efficiencyIndex, format: "%.2f", color: .orange)
            metricView(title: "時間節約", value: item.timeSavingAchievement, format: "%.1f%%", color: .green)
        }
    }
    
    private func metricView(title: String, value: Double, format: String, color: Color) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(String(format: format, value))
                .font(.system(.body, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var detailedMetricsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            metricDetailRow(title: "予測精度", value: item.predictionAccuracy, description: "予測時間と実際の時間の差を示します。100%に近いほど予測が正確です。")
            metricDetailRow(title: "効率指数", value: item.efficiencyIndex, description: "1.0未満は予測より早く、1.0超は予測より遅く完了したことを示します。")
            metricDetailRow(title: "時間節約達成度", value: item.timeSavingAchievement, description: "正の値は時間を節約し、負の値は予測より時間がかかったことを示します。")
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
    }
    
    private func metricDetailRow(title: String, value: Double, description: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            Text(String(format: "%.2f", value))
                .font(.system(.body, design: .rounded))
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var toggleDetailsButton: some View {
        Button(action: {
            withAnimation {
                showDetails.toggle()
            }
        }) {
            Text(showDetails ? "詳細を隠す" : "詳細を表示")
                .font(.footnote)
                .foregroundColor(.blue)
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? "N/A"
    }
}

struct TaskCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        TaskCompletionView(item: PreviewToDoListItem(
            title: "重要なプレゼンテーションの準備",
            estimatedTime: 7200, // 2時間
            elapsedTime: 5400    // 1時間30分
        ))
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
