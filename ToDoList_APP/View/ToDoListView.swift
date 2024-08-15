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
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // カラフルなタブバー
                    HStack(spacing: 20) {
                        TabButton(title: "All", isSelected: selectedTab == 0, color: .blue) {
                            withAnimation(.spring()) {
                                selectedTab = 0
                            }
                        }
                        TabButton(title: "Completed", isSelected: selectedTab == 1, color: .orange) {
                            withAnimation(.spring()) {
                                selectedTab = 1
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // アンダーライン
                    HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(selectedTab == 0 ? Color.blue : Color.orange)
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)
                            .offset(x: selectedTab == 0 ? -UIScreen.main.bounds.width / 4 : UIScreen.main.bounds.width / 4)
                    }
                    .frame(height: 4)
                    .padding(.top, -8)
                    .animation(.spring(), value: selectedTab)
                    
                    // タスクリスト
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredItems) { item in
                                ToDoListItemView(item: item)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(item.isDone ? Color.green : Color.purple, lineWidth: 2)
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
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showingNewItemView = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                    }
                }
            }
        }
        .accentColor(.purple)
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
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isSelected ? color : .gray)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? color.opacity(0.1) : Color.clear)
                .cornerRadius(10)
                .shadow(color: isSelected ? color.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 2)
        }
    }
}

struct ToDoListView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListView(userId: "HKdvXLQ7WhY1qQaEhmOT8gXnWH93")
    }
}
