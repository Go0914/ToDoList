import SwiftUI

struct ToDoListItemView: View {
    @StateObject private var viewModel: ToDoListItemViewViewModel
    @State private var item: ToDoListItem
    @State private var showCompletionView = false
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var showDeleteConfirmation = false
    @State private var showTimerView = false
    @State private var isBlinking = false

    init(item: ToDoListItem) {
        _item = State(initialValue: item)
        _viewModel = StateObject(wrappedValue: ToDoListItemViewViewModel(item: item))
    }

    var body: some View {
        ZStack {
            itemContent
        }
        .sheet(isPresented: $showCompletionView) {
            TaskCompletionView(viewModel: TaskCompletionViewModel(item: item))
        }
        .sheet(isPresented: $showTimerView, onDismiss: {
            if let isRunning = viewModel.timerViewModel?.isRunning {
                isBlinking = isRunning
            }
        }) {
            if let timerViewModel = viewModel.timerViewModel {
                ProgressiveRingTimerView(viewModel: timerViewModel, color: ringColor)
                    .frame(width: 300, height: 300)
            }
        }
        .onChange(of: viewModel.timerViewModel?.isRunning) { isRunning in
            isBlinking = isRunning ?? false
        }
        .animation(.spring(), value: showCompletionView)
        .onChange(of: viewModel.item.elapsedTime) { _ in
            item = viewModel.item
        }
        .onChange(of: item.isDone) { isDone in
            if (isDone ?? false) == true {
                withAnimation(.spring()) {
                    showCompletionView = true
                }
                feedbackMessage = viewModel.generateFeedbackMessage(for: item)
                showFeedback = true
                isBlinking = false
            }
        }
        .alert(isPresented: $showFeedback) {
            Alert(title: Text("タスク完了"), message: Text(feedbackMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("タスクの削除"),
                message: Text("このタスクを削除してもよろしいですか？"),
                primaryButton: .destructive(Text("削除")) {
                    viewModel.deleteItem()
                },
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
        .contextMenu {
            Button(action: {
                showDeleteConfirmation = true
            }) {
                Label("タスクを削除", systemImage: "trash")
            }
        }
    }

    private var itemContent: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(item.isDone ? Color(.systemGray6) : Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
            )
            .frame(height: 110)
            .overlay(
                HStack(spacing: 16) {
                    startButton
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        HStack(spacing: 12) {
                            dateView
                            if let estimatedTime = item.estimatedTime {
                                estimatedTimeView(estimatedTime)
                            }
                        }
                    }

                    Spacer()

                    completionButton
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            )
    }

    private var startButton: some View {
        Button(action: {
            showTimerView = true
        }) {
            ZStack {
                Circle()
                    .fill(Color.teal.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "play.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.teal)
            }
            .opacity(isBlinking ? 0.6 : 1.0)
            .shadow(color: .teal.opacity(0.4), radius: isBlinking ? 8 : 0)
        }
        .animation(isBlinking ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: isBlinking)
    }

    private var dateView: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.system(size: 12))
                .foregroundColor(.orange)
            Text(Date(timeIntervalSince1970: item.dueDate).formatted(.dateTime.month(.defaultDigits).day(.defaultDigits)))
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }

    private func estimatedTimeView(_ time: Double) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.system(size: 12))
            Text(formattedTime(from: time))
                .font(.system(size: 13))
        }
        .foregroundColor(.purple)
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .background(Color.purple.opacity(0.1))
        .cornerRadius(6)
    }

    private var completionButton: some View {
        Button(action: toggleItemCompletion) {
            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(item.isDone ? .green : .teal)
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }

    private func toggleItemCompletion() {
        viewModel.toggleIsDone()
        item = viewModel.item
        isBlinking = false
    }

    var ringColor: Color {
        item.isDone ? .green : .teal
    }

    func formattedTime(from time: Double) -> String {
        let hours = Int(time)
        let minutes = Int((time - Double(hours)) * 60)

        if hours == 0 {
            return "\(minutes)分"
        }
        return "\(hours)時間\(minutes)分"
    }
}

struct ToDoListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleItem = ToDoListItem(
            id: UUID().uuidString,
            title: "重要なプレゼンテーションの準備",
            dueDate: Date().timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            estimatedTime: 2.5
        )
        ToDoListItemView(item: sampleItem)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
