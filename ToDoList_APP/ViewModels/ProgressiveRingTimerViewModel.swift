import Foundation

// プログレッシブリングタイマーのビューモデルクラス
class ProgressiveRingTimerViewModel: ObservableObject {
    @Published var remainingTime: TimeInterval // 残り時間を保持するプロパティ
    @Published var isRunning = false // タイマーが実行中かどうかを示すフラグ
    @Published var elapsedTime: TimeInterval = 0 // 経過時間を保持するプロパティ
    private var timer: Timer? // タイマーオブジェクト
    private let totalTime: TimeInterval // 合計時間を保持するプロパティ

    // イニシャライザ
    // estimatedTime: 予想時間（時間単位）。nilの場合はデフォルトで1時間
    init(estimatedTime: Double?) {
        self.totalTime = estimatedTime.map { $0 * 3600 } ?? 3600 // 時間を秒に変換。デフォルトは1時間（3600秒）
        self.remainingTime = self.totalTime // 残り時間を合計時間で初期化
    }

    // 進捗率を計算するプロパティ（0.0 〜 1.0の範囲）
    var progress: Double {
        (totalTime - remainingTime) / totalTime // 進捗率を計算して返す
    }

    // タイマーを開始する関数
    func startTimer() {
        guard !isRunning else { return } // すでに実行中の場合は何もしない
        isRunning = true // タイマーを実行中に設定
        // 0.1秒ごとにタイマーを更新
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 0.1 // 残り時間を0.1秒減らす
            } else {
                self.stopTimer() // 残り時間が0になったらタイマーを停止
            }
        }
    }

    // タイマーを停止する関数
    func stopTimer() {
        isRunning = false // タイマーを停止中に設定
        timer?.invalidate() // タイマーを無効化
        timer = nil // タイマーを解除
        elapsedTime = totalTime - remainingTime
    }

    // タイマーをリセットする関数
    func resetTimer() {
        stopTimer() // まずタイマーを停止
        remainingTime = totalTime // 残り時間を合計時間にリセット
    }
}
