import SwiftUI

struct ProgressiveRingTimerView: View {
    @ObservedObject var viewModel: ProgressiveRingTimerViewModel
    var color: Color

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 5)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(viewModel.progress.truncatingRemainder(dividingBy: 1)))
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .foregroundColor(viewModel.isCountingUp ? Color(hex: "#E74C3C") : color)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear(duration: 0.1), value: viewModel.progress)
            
            VStack(spacing: 2) {
                Text(timeString)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(viewModel.isCountingUp ? Color(hex: "#E74C3C") : color)
                
                Text(progressString)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(viewModel.isCountingUp ? Color(hex: "#E74C3C") : color)
                
                Button(action: {
                    if viewModel.isRunning {
                        viewModel.stopTimer()
                    } else {
                        viewModel.startTimer()
                    }
                }) {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(viewModel.isCountingUp ? Color(hex: "#E74C3C") : color)
                }
                .frame(width: 24, height: 24)
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
        ProgressiveRingTimerView(viewModel: ProgressiveRingTimerViewModel(estimatedTime: 0.25), color: Color(hex: "#4A69BD"))
            .frame(width: 80, height: 80)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(hex: "#F4F6F9"))
    }
}
