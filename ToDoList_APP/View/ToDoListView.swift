import SwiftUI
import FirebaseAuth

struct ToDoListView: View {
    @StateObject var viewModel: ToDoListViewViewModel
    @State private var showingLoginView = false
    @State private var selectedTab = 0
    @State private var showProfile = false
    
    init(userId: String) {
        self._viewModel = StateObject(wrappedValue: ToDoListViewViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景にさらに薄いグラデーションを追加
                LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.98, blue: 0.95), Color(red: 0.98, green: 0.92, blue: 0.88)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // 柔らかいタブバー
                    HStack(spacing: 15) {
                        TabButton(title: "All", isSelected: selectedTab == 0, color: Color(red: 0.8, green: 0.7, blue: 0.6)) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = 0
                            }
                        }
                        TabButton(title: "Completed", isSelected: selectedTab == 1, color: Color(red: 0.9, green: 0.7, blue: 0.6)) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = 1
                            }
                        }
                    }
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // タスクリスト
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredItems) { item in
                                ToDoListItemView(item: item)
                                    .cornerRadius(25)
                                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color.white, Color(red: 1.0, green: 0.98, blue: 0.95)]),
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing)
                                            .cornerRadius(25)
                                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(item.isDone ? Color(red: 0.85, green: 0.9, blue: 0.8) : Color(red: 0.9, green: 0.8, blue: 0.7), lineWidth: 1.5)
                                    )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showProfile.toggle() }) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(Color(red: 0.9, green: 0.75, blue: 0.7))
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showingNewItemView = true }) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(Color(red: 0.9, green: 0.75, blue: 0.7))
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
        .accentColor(Color(red: 0.85, green: 0.6, blue: 0.5))
        .sheet(isPresented: $viewModel.showingNewItemView) {
            NewItemView(newItemPresented: $viewModel.showingNewItemView, toDoListViewModel: viewModel)
        }
        .sheet(isPresented: $showingLoginView) {
            LoginView()
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .onAppear {
            if Auth.auth().currentUser == nil {
                showingLoginView = true
            }
        }
    }
    
    var filteredItems: [ToDoListItem] {
        let sortedItems = viewModel.items.sorted { item1, item2 in
            if item1.isDone == item2.isDone {
                if item1.isDone {
                    return item1.lastUpdated > item2.lastUpdated
                } else {
                    return item1.dueDate < item2.dueDate
                }
            }
            return !item1.isDone && item2.isDone
        }
        
        switch selectedTab {
        case 0: return sortedItems // All tasks
        case 1: return sortedItems.filter { $0.isDone } // Completed tasks only
        default: return sortedItems
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? color : Color.primary)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isSelected ? color.opacity(0.2) : Color.clear)
                .cornerRadius(10)
                .shadow(color: isSelected ? color.opacity(0.2) : Color.clear, radius: 4, x: 0, y: 2)
        }
    }
}

struct ToDoListView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListView(userId: "HKdvXLQ7WhY1qQaEhmOT8gXnWH93")
    }
}
