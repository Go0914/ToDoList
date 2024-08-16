import SwiftUI

struct ProgressiveRingTimerView: View {
    @ObservedObject var viewModel: ProgressiveRingTimerViewModel
    var color: Color

    var body: some View {
        ZStack {
            // Background circle with soft and pale gradient
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(.systemGray5).opacity(0.3), Color(.systemGray2).opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 6)
            
            // Progress ring with softer, pale color tones
            Circle()
                .trim(from: 0, to: CGFloat(viewModel.progress.truncatingRemainder(dividingBy: 1)))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.4), color.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))

            VStack(spacing: 8) {
                Text(timeString)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.isCountingUp ? .orange.opacity(0.8) : .primary)
                
                Text(progressString)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 10) {
                    // Reset button with pale gradient
                    if !viewModel.isRunning {
                        Button(action: viewModel.resetTimer) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [color.opacity(0.5), color.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.opacity)
                    }
                    
                    // Start/Stop button with pale gradient
                    Button(action: {
                        if viewModel.isRunning {
                            viewModel.pauseTimer()
                        } else {
                            viewModel.startTimer()
                        }
                    }) {
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [viewModel.isCountingUp ? .orange.opacity(0.5) : color.opacity(0.5), viewModel.isCountingUp ? .orange.opacity(0.7) : color.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
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
        ProgressiveRingTimerView(viewModel: ProgressiveRingTimerViewModel(estimatedTime: 0.25), color: .orange)
            .frame(width: 120, height: 120)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .light)
        
        ProgressiveRingTimerView(viewModel: ProgressiveRingTimerViewModel(estimatedTime: 0.25), color: .orange)
            .frame(width: 120, height: 120)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
    }
}
