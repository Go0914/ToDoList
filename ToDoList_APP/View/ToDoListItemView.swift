import SwiftUI

struct ToDoListItemView: View {
    @StateObject private var viewModel = ToDoListItemViewViewModel()
    @State private var item: ToDoListItem
    @State private var showCompletionView = false
    
    init(item: ToDoListItem) {
        _item = State(initialValue: item)
    }
    
    var body: some View {
        ZStack {
            itemContent
            
            if showCompletionView {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showCompletionView = false
                        }
                    }
                
                VStack {
                    TaskCompletionView(item: item)
                        .transition(.scale)
                        .zIndex(1)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                showCompletionView = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                                .padding()
                        }
                    }
                }
                .padding()
            }
        }
        .animation(.spring(), value: showCompletionView)
    }
    
    private var itemContent: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(lineWidth: 1)
            .foregroundColor(item.isDone ? Color.green : Color("toDoListItemColor"))
            .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
            .frame(height: 105)
            .overlay(
                HStack(spacing: 16) {
                    ProgressiveRingTimerView(estimatedTime: item.estimatedTime, color: ringColor)
                        .frame(width: 80, height: 80)
                        .padding(CGFloat(item.progress))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.callout)
                            .lineLimit(2)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.subheadline)
                            Text(Date(timeIntervalSince1970: item.dueDate).formatted(.dateTime.month(.defaultDigits).day(.defaultDigits)))
                                .font(.subheadline)
                                .foregroundColor(Color(.secondaryLabel))
                        }
                        
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
                    
                    Button(action: toggleItemCompletion) {
                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor(Color.blue)
                            .frame(width: 44, height: 44)
                    }
                    .contentShape(Rectangle())
                }
                .padding()
            )
            .onAppear {
                viewModel.setCurrentItem(item)
            }
    }
    
    private func toggleItemCompletion() {
        if !item.isDone {
            item.isDone = true
            viewModel.toggleIsDone(item: item)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    showCompletionView = true
                }
            }
        } else {
            withAnimation {
                item.isDone = false
                viewModel.toggleIsDone(item: item)
            }
        }
    }
    
    var ringColor: Color {
        if item.isDone {
            return .green
        } else if viewModel.progress >= 1.0 {
            return .red
        } else {
            return .blue
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
            lastUpdated: Date()
        ))
    }
}
