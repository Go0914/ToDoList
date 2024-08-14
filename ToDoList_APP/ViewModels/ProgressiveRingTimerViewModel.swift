import Foundation

class ProgressiveRingTimerViewModel: ObservableObject {
    @Published var remainingTime: TimeInterval
    @Published var isRunning = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var isCountingUp = false
    @Published var isTaskCompleted = false
    @Published var timerState: ToDoListItem.TimerState = .notStarted
    private var timer: Timer?
    private let totalTime: TimeInterval

    init(estimatedTime: Double?) {
        self.totalTime = estimatedTime.map { $0 * 3600 } ?? 3600
        self.remainingTime = self.totalTime
    }

    var progress: Double {
        elapsedTime / totalTime
    }
    
    func updateTimerState(_ state: ToDoListItem.TimerState) {
        timerState = state
        isRunning = (state == .running)
        if state == .completed {
            isTaskCompleted = true
        }
        objectWillChange.send()
    }

    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        updateTimerState(.running)
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        elapsedTime += 0.1
        if remainingTime > 0 {
            remainingTime -= 0.1
        } else if !isCountingUp {
            isCountingUp = true
            remainingTime = 0
        }
        
        if Int(elapsedTime * 10) % 10 == 0 {
            objectWillChange.send()
        }
    }

    func pauseTimer() {
        isRunning = false
        updateTimerState(.paused)
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        pauseTimer()
        remainingTime = totalTime
        elapsedTime = 0
        isCountingUp = false
        isTaskCompleted = false
        updateTimerState(.notStarted)
    }

    func completeTask() -> (elapsedTime: TimeInterval, isOvertime: Bool) {
        pauseTimer()
        isTaskCompleted = true
        updateTimerState(.completed)
        let isOvertime = elapsedTime > totalTime
        return (elapsedTime, isOvertime)
    }

    func canStartNewTask() -> Bool {
        return !isRunning && (isTaskCompleted || elapsedTime == 0)
    }
}
