import SwiftUI

struct ToDoListItemView: View {
    // ビューモデルの初期化
    @StateObject private var viewModel = ToDoListItemViewViewModel()
    // 表示するToDoリスト項目
    let item: ToDoListItem
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(lineWidth: 1)
            // 完了状態に応じて色を変更
            .foregroundColor(item.isDone ? Color.green : Color("toDoListItemColor"))
            .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
            .frame(height: 105)
            .overlay(
                HStack(spacing: 16) {
                    // 進行状況を表す円形タイマービュー
                    ProgressiveRingTimerView(estimatedTime: item.estimatedTime, color: ringColor)
                        .frame(width: 80, height: 80)
                        .padding(CGFloat(item.progress))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // タスクのタイトル
                        Text(item.title)
                            .font(.callout)
                            .lineLimit(2)
                        
                        // 期日の表示
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.subheadline)
                            Text(Date(timeIntervalSince1970: item.dueDate).formatted(.dateTime.month(.defaultDigits).day(.defaultDigits)))
                                .font(.subheadline)
                                .foregroundColor(Color(.secondaryLabel))
                        }
                        
                        // 推定時間の表示（設定されている場合）
                        if let estimatedTime = item.estimatedTime {
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                    .font(.footnote)
                                Text(formattedTime(from: estimatedTime))
                                    .font(.footnote)
                            }
                            .foregroundColor(Color(.secondaryLabel))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color("toDoListItemColor"))
                            .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    // 完了/未完了を切り替えるボタン
                    Button {
                        viewModel.toggleIsDone(item: item)
                    } label: {
                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor(Color.blue)
                            .frame(width: 44, height: 44)
                    }
                    .contentShape(Rectangle()) // タップ可能な領域を明示的に定義
                }
                .padding()
            )
            .onAppear {
                viewModel.setCurrentItem(item)
            }
    }
    
    // リングの色を決定するプロパティ
    var ringColor: Color {
        if item.isDone {
            return .green
        } else if viewModel.progress >= 1.0 {
            return .red
        } else {
            return .blue
        }
    }
    
    // 推定時間をフォーマットする関数
    func formattedTime(from time: Double) -> String {
        let hours = Int(time)
        let minutes = Int((time - Double(hours)) * 60)
        
        if hours == 0 {
            return "\(minutes)min"
        }
        return "\(hours)h\(minutes)min"
    }
}

// プレビュー用の構造体
struct ToDoListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListItemView(item: ToDoListItem(
            id: "123",
            title: "テストタスク",
            dueDate: Date().timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            estimatedTime: 2.5
        ))
    }
}
