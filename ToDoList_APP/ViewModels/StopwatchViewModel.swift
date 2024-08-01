//
//  StopwatchViewModel.swift
//  ToDoList
//
//  Created by 清水豪 on 2024/07/29.
//

import Foundation
import Combine

class StopwatchViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedTime = 0.0
    @Published var startTime = Date()
    @Published var lapTimes: [Double] = []
    @Published var isPaused = false
    private var pausedTime: Double = 0.0
    private var timer: AnyCancellable?
    
    // 時間表示の書式設定関数
    var formattedElapsedTime: String {
        return formatTime(elapsedTime)
    }
    private func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let remainingSeconds = Int(seconds.truncatingRemainder(dividingBy: 60))
        let milliseconds = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        
        //1時間を超える場合の表記
        if hours > 0 {
                return String(format: "%02d:%02d:%02d.%02d", hours, minutes, remainingSeconds, milliseconds)
            } else {
                return String(format: "%02d:%02d.%02d", minutes, remainingSeconds, milliseconds)
            }
        }
    
    //ストップウォッチを開始する関数
    func startTimer() {
        if isPaused {
            startTime = Date().addingTimeInterval(-pausedTime)
            isPaused = false
        } else {
            startTime = Date()
        }
        isRunning = true
        
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    if self.isRunning {
                        self.elapsedTime = Date().timeIntervalSince(self.startTime)
                    }
                }
    }
    
    //タイマーの一時停止する関数
    func pauseTime() {
        isRunning = false
        isPaused = true
        timer?.cancel()
        pausedTime = elapsedTime
    }
    
    //タイマーを再開する関数
    func resumeTimer() {
        startTimer()
    }

    //ストップウォッチを停止する関数
    func stopTimer() {
        isRunning = false
        isPaused = false
        timer?.cancel()
        pausedTime = 0.0
    }
    
    //ストップウォッチをリセットする関数
    func resetTimer() {
        isRunning = false
        isPaused = false
        elapsedTime = 0.0
        startTime = Date()
        pausedTime = 0.0
        timer?.cancel()
    }

    
    //ラップタイムを記録する関数
    func recordLapTime() {
        lapTimes.append(elapsedTime)
    }
    
}
