import Foundation

class ProgressiveRingTimerViewModel: ObservableObject {
    @Published var remainingTime: TimeInterval
    @Published var isRunning = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var isCountingUp = false
    private var timer: Timer?
    private let totalTime: TimeInterval

    init(estimatedTime: Double?) {
        self.totalTime = estimatedTime.map { $0 * 3600 } ?? 3600
        self.remainingTime = self.totalTime
    }

    var progress: Double {
        elapsedTime / totalTime
    }

    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 0.1
            if self.remainingTime > 0 {
                self.remainingTime -= 0.1
            } else if !self.isCountingUp {
                self.isCountingUp = true
                self.remainingTime = 0
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
        elapsedTime = 0
        isCountingUp = false
    }

    func completeTask() -> (elapsedTime: TimeInterval, isOvertime: Bool) {
        stopTimer()
        let isOvertime = elapsedTime > totalTime
        return (elapsedTime, isOvertime)
    }
}
