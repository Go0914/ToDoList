import SwiftUI

struct TaskCompletionView: View {
    @ObservedObject var viewModel: TaskCompletionViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var animateCheckmark = false
    @State private var animateTimeCards = false
    @State private var animateMetricCards = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                headerView
                    .scaleEffect(animateCheckmark ? 1.0 : 0.8)
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
        .background(Color(UIColor.systemBackground))
    }
    
    private var headerView: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 50, height: 50)
                    .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 3)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.item.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                Text("タスク完了")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(6)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
    
    private var timeComparisonView: some View {
        HStack(spacing: 18) {
            timeCard(title: "予測時間", time: viewModel.item.estimatedTime ?? 0, icon: "hourglass")
            timeCard(title: "実際の時間", time: viewModel.item.elapsedTime, icon: "stopwatch")
        }
    }
    
    private func timeCard(title: String, time: Double, icon: String) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            
            Text(viewModel.formatTime(time))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.tertiarySystemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private var metricsView: some View {
        VStack(spacing: 18) {
            ForEach(viewModel.detailedMetrics, id: \.title) { metric in
                metricCard(metric: metric)
            }
        }
    }
    
    private func metricCard(metric: DetailedMetric) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconForMetric(metric.title))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 35, height: 35)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(metric.color)
                    )
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(metric.title)
                        .font(.headline)
                    
                    Text(String(format: "%.1f", metric.value))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(metric.color)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: viewModel.normalizedValue(for: metric.value, title: metric.title))
                    .progressViewStyle(SimpleProgressViewStyle(color: metric.color))
                
                Text(metric.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private func iconForMetric(_ title: String) -> String {
        switch title {
        case "予測精度":
            return "scope"
        case "効率指数":
            return "speedometer"
        case "時間節約":
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
        .frame(height: 10)
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
        
        let viewModel = TaskCompletionViewModel(item: sampleItem)
        
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
