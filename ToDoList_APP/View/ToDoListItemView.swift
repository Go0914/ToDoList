import SwiftUI

struct ToDoListItemView: View {
    @StateObject private var viewModel: ToDoListItemViewViewModel
    @State private var item: ToDoListItem
    @State private var showCompletionView = false
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var showDeleteConfirmation = false
    
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
        .animation(.spring(), value: showCompletionView)
        .onChange(of: viewModel.item.elapsedTime) { _ in
            item = viewModel.item
        }
        .onChange(of: item.isDone) { isDone in
            if isDone {
                withAnimation(.spring()) {
                    showCompletionView = true
                }
                feedbackMessage = viewModel.generateFeedbackMessage(for: item)
                showFeedback = true
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
        RoundedRectangle(cornerRadius: 20)
            .fill(item.isDone ? Color(.systemGray5) : Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appleBlue.opacity(0.3), lineWidth: 1)
            )
            .frame(height: 120)
            .overlay(
                HStack(spacing: 16) {
                    if let timerViewModel = viewModel.timerViewModel {
                        ProgressiveRingTimerView(viewModel: timerViewModel, color: ringColor)
                            .frame(width: 100, height: 100)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.subheadline)
                                .foregroundColor(.appleBlue)
                            Text(Date(timeIntervalSince1970: item.dueDate).formatted(.dateTime.month(.defaultDigits).day(.defaultDigits)))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let estimatedTime = item.estimatedTime {
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                    .font(.footnote)
                                Text(formattedTime(from: estimatedTime))
                                    .font(.footnote)
                            }
                            .foregroundColor(.appleBlue)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.appleBlue.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: toggleItemCompletion) {
                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(item.isDone ? .appleLightBlue : .appleBlue)
                            .frame(width: 44, height: 44)
                    }
                    .contentShape(Rectangle())
                }
                .padding()
            )
    }
    
    private func toggleItemCompletion() {
        viewModel.toggleIsDone()
        item = viewModel.item
    }
    
    var ringColor: Color {
        item.isDone ? .appleLightBlue : .appleBlue
    }
    
    func formattedTime(from time: Double) -> String {
        let hours = Int(time)
        let minutes = Int((time - Double(hours)) * 60)
        
        if hours == 0 {
            return "\(minutes)min"
        }
        return "\(hours)h\(minutes)min"
    }
}

struct ToDoListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleItem = ToDoListItem(
            id: UUID().uuidString,
            title: "Sample Task",
            dueDate: Date().timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            estimatedTime: 1.5
        )
        ToDoListItemView(item: sampleItem)
    }
}
