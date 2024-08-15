import SwiftUI

struct TaskCompletionView: View {
    @ObservedObject var viewModel: TaskCompletionViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var animateCheckmark = false
    @State private var animateTimeCards = false
    @State private var animateMetricCards = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                    .scaleEffect(animateCheckmark ? 1.0 : 0.85)
                    .opacity(animateCheckmark ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.1).delay(0.1), value: animateCheckmark)
                    .onAppear { animateCheckmark = true }
                
                timeComparisonView
                    .offset(y: animateTimeCards ? 0 : 50)
                    .opacity(animateTimeCards ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.7).delay(0.3), value: animateTimeCards)
                    .onAppear { animateTimeCards = true }
                
                metricsView
                    .offset(y: animateMetricCards ? 0 : 50)
                    .opacity(animateMetricCards ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.5), value: animateMetricCards)
                    .onAppear { animateMetricCards = true }
            }
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
    
    private var headerView: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.8, blue: 0.6))
                    .frame(width: 44, height: 44)
                    .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.6).opacity(0.3), radius: 7, x: 0, y: 3)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.item.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("タスク完了")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(red: 1.0, green: 0.9, blue: 0.7))
                    .cornerRadius(6)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var timeComparisonView: some View {
        HStack(spacing: 16) {
            if let estimatedTime = viewModel.item.estimatedTime {
                timeCard(title: "予測時間", time: estimatedTime, icon: "hourglass", color: Color(red: 1.0, green: 0.75, blue: 0.5))
            }
            timeCard(title: "実際の時間", time: viewModel.item.elapsedTime, icon: "stopwatch", color: Color(red: 0.5, green: 0.75, blue: 0.5))
        }
    }
    
    private func timeCard(title: String, time: Double, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            Text(viewModel.formatTime(time))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 7, x: 0, y: 4)
        )
    }
    
    private var metricsView: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.detailedMetrics, id: \.title) { metric in
                metricCard(metric: metric)
            }
        }
    }
    
    private func metricCard(metric: DetailedMetric) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconForMetric(metric.title))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(metric.color.opacity(0.8))
                    )
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(metric.title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text(String(format: "%.1f%%", metric.value))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(metric.color.opacity(0.8))
                }
                
                Spacer()
            }
            
            ProgressView(value: viewModel.normalizedValue(for: metric.value, title: metric.title))
                .progressViewStyle(SimpleProgressViewStyle(color: metric.color.opacity(0.8)))
            
            Text(metric.message)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 7, x: 0, y: 4)
        )
    }
    
    private func iconForMetric(_ title: String) -> String {
        switch title {
        case "予測精度":
            return "scope"
        case "効率性指標":
            return "speedometer"
        case "時間節約達成度":
            return "clock.arrow.circlepath"
        default:
            return "questionmark.circle"
        }
    }
}

struct SimpleProgressViewStyle: ProgressViewStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .fill(color.opacity(0.2))
                    .frame(height: geometry.size.height)
                
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .fill(color)
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width, height: geometry.size.height)
            }
        }
        .frame(height: 8)
    }
}

struct TaskCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleItem = ToDoListItem(
            id: "123",
            title: "重要なプレゼンテーションの準備",
            dueDate: Date().timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: true,
            estimatedTime: 2.0,
            progress: 1.0,
            lastUpdated: Date().timeIntervalSince1970,
            actualTime: nil,
            elapsedTime: 5400
        )
        
        var updatedItem = sampleItem
        updatedItem.efficiencyIndex = 0.9
        updatedItem.timeSavingAchievement = 10
        updatedItem.predictionAccuracy = 85
        
        let viewModel = TaskCompletionViewModel(item: updatedItem)
        
        return Group {
            TaskCompletionView(viewModel: viewModel)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Light Mode")
            
            TaskCompletionView(viewModel: viewModel)
                .previewLayout(.sizeThatFits)
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
