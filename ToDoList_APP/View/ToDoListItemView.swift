import SwiftUI

struct ToDoListItemView: View {
    @StateObject private var viewModel: ToDoListItemViewViewModel
    @State private var item: ToDoListItem
    @State private var showCompletionView = false
    
    init(item: ToDoListItem) {
        _item = State(initialValue: item)
        _viewModel = StateObject(wrappedValue: ToDoListItemViewViewModel(item: item))
    }
    
    var body: some View {
        ZStack {
            itemContent
            
            if showCompletionView {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showCompletionView = false
                        }
                    }
                
                VStack {
                    TaskCompletionView(viewModel: TaskCompletionViewModel(item: item))
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            showCompletionView = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                            .background(Color(hex: "#3F2B96").opacity(0.8))
                            .clipShape(Circle())
                    }
                }
                .padding()
            }
        }
        .animation(.spring(), value: showCompletionView)
        .onAppear {
            viewModel.setCurrentItem(item)
        }
        .onChange(of: viewModel.currentItem?.elapsedTime) { _ in
            if let updatedItem = viewModel.currentItem {
                item = updatedItem
            }
        }
        .onChange(of: item.isDone) { isDone in
            if isDone {
                withAnimation(.spring()) {
                    showCompletionView = true
                }
            }
        }
    }
    
    private var itemContent: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(color: Color(hex: "#3F2B96").opacity(0.1), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "#A8C0FF"), lineWidth: 2)
            )
            .frame(height: 120)
            .overlay(
                HStack(spacing: 16) {
                    if let timerViewModel = viewModel.timerViewModel {
                        ProgressiveRingTimerView(viewModel: timerViewModel, color: ringColor)
                            .frame(width: 80, height: 80)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "#3F2B96"))
                            .lineLimit(2)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#3F2B96"))
                            Text(Date(timeIntervalSince1970: item.dueDate).formatted(.dateTime.month(.defaultDigits).day(.defaultDigits)))
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#666666"))
                        }
                        
                        if let estimatedTime = item.estimatedTime {
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                    .font(.footnote)
                                Text(formattedTime(from: estimatedTime))
                                    .font(.footnote)
                            }
                            .foregroundColor(Color(hex: "#3F2B96"))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color(hex: "#E8EDF5"))
                            .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: toggleItemCompletion) {
                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(item.isDone ? Color(hex: "#3F2B96") : Color(hex: "#A8C0FF"))
                            .frame(width: 44, height: 44)
                    }
                    .contentShape(Rectangle())
                }
                .padding()
            )
    }
    
    private func toggleItemCompletion() {
        viewModel.toggleIsDone(item: item)
    }
    
    var ringColor: Color {
        if item.isDone {
            return Color(hex: "#3F2B96")
        } else {
            return Color(hex: "#A8C0FF")
        }
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
        ToDoListItemView(item: ToDoListItem(
            id: "123",
            title: "テストタスク",
            dueDate: Date().timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            estimatedTime: 2.5,
            progress: 0.5,
            lastUpdated: Date().timeIntervalSince1970,
            elapsedTime: 0
        ))
        .padding()
        .background(Color(hex: "#F4F6F9"))
    }
}
