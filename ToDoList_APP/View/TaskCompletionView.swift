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
                    .scaleEffect(animateCheckmark ? 1.2 : 0.8)
                    .animation(.interpolatingSpring(stiffness: 70, damping: 10).delay(0.1), value: animateCheckmark)
                    .onAppear {
                        animateCheckmark = true
                    }
                
                timeComparisonView
                    .scaleEffect(animateTimeCards ? 1.0 : 0.5)
                    .opacity(animateTimeCards ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: animateTimeCards)
                    .onAppear {
                        animateTimeCards = true
                    }
                
                metricsView
                    .offset(y: animateMetricCards ? 0 : 50)
                    .opacity(animateMetricCards ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.7).delay(0.4), value: animateMetricCards)
                    .onAppear {
                        animateMetricCards = true
                    }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var headerView: some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.item.title)
                    .font(.headline)
                
                Text("タスク完了")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
    
    private var timeComparisonView: some View {
        HStack(spacing: 20) {
            timeCard(title: "予測時間", time: viewModel.item.estimatedTime ?? 0, icon: "hourglass")
            timeCard(title: "実際の時間", time: viewModel.item.elapsedTime, icon: "stopwatch")
        }
    }
    
    private func timeCard(title: String, time: Double, icon: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
            
            Text(viewModel.formatTime(time))
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor.secondarySystemBackground), Color(UIColor.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private var metricsView: some View {
        VStack(spacing: 20) {
            ForEach(viewModel.detailedMetrics, id: \.title) { metric in
                metricCard(metric: metric)
            }
        }
    }
    
    private func metricCard(metric: DetailedMetric) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconForMetric(metric.title))
                    .font(.system(size: 24))
                    .foregroundColor(metric.color)
                
                Text(metric.title)
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "%.1f", metric.value))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(metric.color)
            }
            
            VStack(alignment: .leading) {
                ProgressView(value: viewModel.normalizedValue(for: metric.value, title: metric.title))
                    .progressViewStyle(ThickProgressViewStyle(color: metric.color))
                
                Text(metric.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor.secondarySystemBackground), Color(UIColor.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .offset(y: animateMetricCards ? 0 : 50)
        .opacity(animateMetricCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.7).delay(0.4), value: animateMetricCards)
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

struct ThickProgressViewStyle: ProgressViewStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .frame(height: geometry.size.height)
                    .foregroundColor(color.opacity(0.3))
                
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width, height: geometry.size.height)
                    .foregroundColor(color)
            }
        }
        .frame(height: 12)  // バーの厚みを設定
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
            estimatedTime: 2.0,  // 2時間
            progress: 1.0,
            lastUpdated: Date().timeIntervalSince1970,
            actualTime: nil,
            elapsedTime: 5400  // 1時間30分（秒単位）
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
