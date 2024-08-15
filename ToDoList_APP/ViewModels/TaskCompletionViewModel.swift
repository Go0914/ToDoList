import SwiftUI

struct DetailedMetric {
    let title: String
    let value: Double
    let description: String
    let color: Color
    let message: String
}

class TaskCompletionViewModel: ObservableObject {
    @Published var item: ToDoListItem
    
    var detailedMetrics: [DetailedMetric] {
        [
            createPredictionAccuracyMetric(),
            createEfficiencyMetric(),
            createTimeSavingMetric()
        ]
    }
    
    init(item: ToDoListItem) {
        self.item = item
    }
    
    private func createPredictionAccuracyMetric() -> DetailedMetric {
        let accuracy = item.predictionAccuracy ?? 0
        let (level, message) = getPredictionAccuracyLevelAndMessage(accuracy)
        
        return DetailedMetric(
            title: "予測精度",
            value: accuracy,
            description: "100%に近いほど正確な予測",
            color: .purple,
            message: message
        )
    }
    
    private func createEfficiencyMetric() -> DetailedMetric {
        let efficiencyPercentage = calculateEfficiencyPercentage(item.efficiencyIndex ?? 1.0)
        let (level, message) = getEfficiencyLevelAndMessage(efficiencyPercentage)
        
        return DetailedMetric(
            title: "効率性指標",
            value: efficiencyPercentage,
            description: "200%に近いほど効率的",
            color: .orange,
            message: message
        )
    }
    
    private func createTimeSavingMetric() -> DetailedMetric {
        let timeSavingPercentage = item.timeSavingAchievement ?? 0
        let (level, message) = getTimeSavingLevelAndMessage(timeSavingPercentage)
        
        return DetailedMetric(
            title: "時間節約達成度",
            value: timeSavingPercentage,
            description: "正の値は時間節約を示す",
            color: .blue,
            message: message
        )
    }
    
    func formatTime(_ interval: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        
        // estimatedTime は時間単位、elapsedTime は秒単位で扱う
        let timeInterval = interval < 100 ? interval * 3600 : interval
        
        return formatter.string(from: TimeInterval(timeInterval)) ?? "N/A"
    }
    
    func normalizedValue(for value: Double, title: String) -> Double {
        switch title {
        case "予測精度":
            return value / 100
        case "効率性指標":
            return min(value / 200, 1.0)
        case "時間節約達成度":
            return (value + 400) / 500  // -400%から100%の範囲を0から1に正規化
        default:
            return 0
        }
    }
    
    private func getPredictionAccuracyLevelAndMessage(_ accuracy: Double) -> (String, String) {
        switch accuracy {
        case 90...100:
            return ("驚異的", "素晴らしい予測精度です！🎯 あなたの時間感覚は天才レベルです。この才能を活かして、さらなる挑戦をしてみませんか？")
        case 70..<90:
            return ("優秀", "とても高い予測精度です。👏 あなたの計画性が光っています。この調子で、さらなる正確さを目指しましょう！")
        case 50..<70:
            return ("良好", "良好な予測精度です。👍 経験を重ねるごとに、さらに正確になっていくでしょう。頑張り続けてください！")
        case 30..<50:
            return ("改善中", "予測精度は改善の余地があります。🌱 でも心配いりません。実践を重ねることで、必ず上達していきますよ！")
        default:
            return ("チャレンジ", "予測は難しかったようですね。😊 でも、これも大切な学びです。次回は今回の経験を活かして、より正確な予測にチャレンジしましょう！")
        }
    }
    
    private func calculateEfficiencyPercentage(_ efficiencyIndex: Double) -> Double {
        return (5 - efficiencyIndex) / 4.9 * 200
    }
    
    private func getEfficiencyLevelAndMessage(_ percentage: Double) -> (String, String) {
        switch percentage {
        case 175...200:
            return ("超効率", "驚異の効率性\(String(format: "%.0f", percentage))%達成！🚀 あなたの生産性は宇宙レベルです。次の挑戦も楽々クリアできるはず！")
        case 125..<175:
            return ("高効率", "効率性\(String(format: "%.0f", percentage))%の素晴らしい仕事ぶり！🌟 あなたの集中力と技術が光っています。この調子でどんどん前進しましょう！")
        case 75..<125:
            return ("標準効率", "効率性\(String(format: "%.0f", percentage))%で安定したパフォーマンス！💪 コンスタントな努力が実を結んでいますね。次は高効率を目指してさらなる高みへ！")
        case 25..<75:
            return ("成長の機会", "効率性\(String(format: "%.0f", percentage))%を記録。あなたの中に眠る可能性は無限大！✨ 新しいアプローチを試して、次は100%超えを目指しましょう。")
        default:
            return ("チャレンジ", "効率性\(String(format: "%.0f", percentage))%での完了、お疲れさま！🌈 難しい課題に立ち向かう勇気が素晴らしいです。この経験は必ず次に活きます。")
        }
    }
    
    private func getTimeSavingLevelAndMessage(_ percentage: Double) -> (String, String) {
        switch percentage {
        case 75...100:
            return ("大幅時間節約", "驚異の\(String(format: "%.0f", percentage))%時間節約を達成！⏱️✨ あなたの時間管理スキルはまさに魔法使いレベル！この節約した時間で、次の大きな目標に挑戦してみませんか？")
        case 25..<75:
            return ("適度な時間節約", "\(String(format: "%.0f", percentage))%の時間節約、素晴らしい成果です！🎉 効率的な仕事ぶりがあなたの強み。この調子で、さらなる時間の達人を目指しましょう！")
        case -24..<25:
            return ("バランス型", "予定通りの完璧なタイミング！⚖️ 計画性と実行力のバランスが取れています。安定感のある仕事ぶりは、チームの模範となるでしょう！")
        case -74..<(-24):
            return ("品質重視", "予定より\(String(format: "%.0f", abs(percentage)))%多く時間を使いました。きっと素晴らしい品質の仕事ができたはずです！🏆 次回は、この経験を活かしてさらなる効率アップにつなげましょう。")
        default:
            return ("学習機会", "予想以上に時間がかかりましたが、大きな学びがあったはずです。🌱 この経験は必ず次に活きます。諦めずに取り組んだあなたの根性に拍手喝采です！")
        }
    }
}
