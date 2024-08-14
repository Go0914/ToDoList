import SwiftUI

struct ProgressiveRingTimerView: View {
    @ObservedObject var viewModel: ProgressiveRingTimerViewModel
    var color: Color

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 6)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(viewModel.progress.truncatingRemainder(dividingBy: 1)))
                .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .foregroundColor(viewModel.isCountingUp ? .red : color)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear(duration: 0.1), value: viewModel.progress)
            
            VStack(spacing: 4) {
                Text(timeString)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(viewModel.isCountingUp ? .red : .primary)
                
                Text(progressString)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    // Reset button
                    if !viewModel.isRunning {
                        Button(action: viewModel.resetTimer) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(color)
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.opacity)
                    }
                    
                    // Start/Stop button
                    Button(action: {
                        if viewModel.isRunning {
                            viewModel.pauseTimer()
                        } else {
                            viewModel.startTimer()
                        }
                    }) {
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 32)
                            .background(viewModel.isCountingUp ? Color.red : color)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .animation(.easeInOut, value: viewModel.isRunning)
            }
        }
    }
    
    private var timeString: String {
        let time = viewModel.isCountingUp ? Int(viewModel.elapsedTime) : Int(viewModel.remainingTime)
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private var progressString: String {
        String(format: "%.0f%%", viewModel.progress * 100)
    }
}

struct ProgressiveRingTimerView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressiveRingTimerView(viewModel: ProgressiveRingTimerViewModel(estimatedTime: 0.25), color: .blue)
            .frame(width: 120, height: 120)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .light)
        
        ProgressiveRingTimerView(viewModel: ProgressiveRingTimerViewModel(estimatedTime: 0.25), color: .blue)
            .frame(width: 120, height: 120)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
    }
}
