import SwiftUI

struct ProgressiveRingTimerView: View {
    @ObservedObject var viewModel: ProgressiveRingTimerViewModel
    var color: Color

    var body: some View {
        ZStack {
            // Background circle with gradient
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 6)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(viewModel.progress.truncatingRemainder(dividingBy: 1)))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.7), color]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 4)

            VStack(spacing: 8) {
                Text(timeString)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.isCountingUp ? .red : .primary)
                
                Text(progressString)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 10) {
                    // Reset button with shadow and gradient
                    if !viewModel.isRunning {
                        Button(action: viewModel.resetTimer) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [color.opacity(0.8), color]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: color.opacity(0.5), radius: 5, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.opacity)
                    }
                    
                    // Start/Stop button with shadow and gradient
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
                                    gradient: Gradient(colors: [viewModel.isCountingUp ? .red.opacity(0.8) : color.opacity(0.8), viewModel.isCountingUp ? .red : color]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: viewModel.isCountingUp ? .red.opacity(0.5) : color.opacity(0.5), radius: 5, x: 0, y: 4)
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
