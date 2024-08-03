import SwiftUI

struct ProgressiveRingTimerView: View {
    @StateObject var viewModel: ProgressiveRingTimerViewModel
    var color: Color

    init(estimatedTime: Double?, color: Color) {
        _viewModel = StateObject(wrappedValue: ProgressiveRingTimerViewModel(estimatedTime: estimatedTime))
        self.color = color
    }

    var body: some View {
        ZStack {
            // 背景の薄いグレーの円
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 5)
            
            // 進行状況を示す色付きの円
            Circle()
                .trim(from: 0, to: CGFloat(viewModel.progress.truncatingRemainder(dividingBy: 1)))
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .foregroundColor(viewModel.isCountingUp ? .red : color)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear(duration: 0.1), value: viewModel.progress)
            
            VStack {
                Text(timeString)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                
                Text(progressString)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(viewModel.isCountingUp ? .red : color)
                
                Button(action: {
                    if viewModel.isRunning {
                        viewModel.stopTimer()
                    } else {
                        viewModel.startTimer()
                    }
                }) {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .foregroundColor(viewModel.isCountingUp ? .red : color)
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
        ProgressiveRingTimerView(estimatedTime: 0.25, color: .blue)
            .frame(width: 100, height: 100)
    }
}
