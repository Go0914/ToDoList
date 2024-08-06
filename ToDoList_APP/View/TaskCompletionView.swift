import SwiftUI

struct TaskCompletionView: View {
    @ObservedObject var viewModel: TaskCompletionViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            timeComparisonView
            keyMetricsView
            
            VStack {
                if viewModel.showDetails {
                    detailedMetricsView
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                }
            }
            .frame(height: viewModel.showDetails ? viewModel.detailHeight : 0)
            .clipped()
            .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: viewModel.showDetails)
            
            toggleDetailsButton
        }
        .padding(16)
        .background(viewModel.bgColor)
    }
    
    private var headerView: some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(viewModel.primaryColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.item.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.textColor)
                
                Text("タスク完了")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(viewModel.accentColor)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(viewModel.cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var timeComparisonView: some View {
        HStack(spacing: 12) {
            viewModel.timeCardView(title: "予測", time: viewModel.item.estimatedTime ?? 0, icon: "clock")
            viewModel.timeCardView(title: "実際", time: viewModel.item.elapsedTime, icon: "stopwatch")
        }
    }
    
    private var keyMetricsView: some View {
        VStack(spacing: 12) {
            viewModel.metricView(title: "予測精度", value: viewModel.item.predictionAccuracy ?? 0, format: "%.1f%%", icon: "chart.bar.fill", color: viewModel.successColor)
            viewModel.metricView(title: "効率指数", value: viewModel.item.efficiencyIndex ?? 0, format: "%.2f", icon: "speedometer", color: viewModel.warningColor)
            viewModel.metricView(title: "時間節約", value: viewModel.item.timeSavingAchievement ?? 0, format: "%.1f%%", icon: "hourglass", color: viewModel.accentColor)
        }
    }
    
    private var detailedMetricsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(viewModel.detailedMetrics, id: \.title) { metric in
                VStack(alignment: .leading, spacing: 8) {
                    Text(metric.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.textColor)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(String(format: "%.2f", metric.value))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(metric.color)
                        
                        Text(metric.description)
                            .font(.system(size: 14))
                            .foregroundColor(viewModel.subTextColor)
                    }
                    
                    ProgressView(value: viewModel.normalizedValue(for: metric.value, title: metric.title))
                        .progressViewStyle(LinearProgressViewStyle(tint: metric.color))
                }
            }
        }
        .padding(16)
        .background(viewModel.cardBgColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .background(
            GeometryReader { geometry in
                Color.clear.preference(key: ViewHeightKey.self, value: geometry.size.height)
            }
        )
        .onPreferenceChange(ViewHeightKey.self) { height in
            viewModel.detailHeight = height
        }
    }
    
    private var toggleDetailsButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                viewModel.showDetails.toggle()
            }
        }) {
            HStack {
                Text(viewModel.showDetails ? "詳細を隠す" : "詳細を表示")
                Image(systemName: viewModel.showDetails ? "chevron.up" : "chevron.down")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(viewModel.primaryColor)
            .cornerRadius(20)
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
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
                .padding()
                .background(Color(hex: "#F4F6F9"))
                .previewDisplayName("Light Mode")
            
            TaskCompletionView(viewModel: viewModel)
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color(hex: "#F4F6F9"))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
