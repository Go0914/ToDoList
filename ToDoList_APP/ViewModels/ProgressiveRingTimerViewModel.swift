import Foundation

class ProgressiveRingTimerViewModel: ObservableObject {
    @Published var remainingTime: TimeInterval
    @Published var isRunning = false
    private var timer: Timer?
    private let totalTime: TimeInterval

    init(estimatedTime: Double?) {
        self.totalTime = estimatedTime.map { $0 * 3600 } ?? 3600 // デフォルトは1時間
        self.remainingTime = self.totalTime
    }

    var progress: Double {
        (totalTime - remainingTime) / totalTime
    }

    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 0.1
            } else {
                self.stopTimer()
            }
        }
    }

    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        stopTimer()
        remainingTime = totalTime
    }
}
