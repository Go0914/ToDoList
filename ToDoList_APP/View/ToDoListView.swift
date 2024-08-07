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
                    // スタイリッシュなタブビュー
                    Picker("", selection: $selectedTab) {
                        Text("All").tag(0)
                        Text("Completed").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // タスクリスト
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredItems) { item in
                                ToDoListItemView(item: item)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showProfile.toggle() }) {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.appleBlue)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showingNewItemView = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.appleBlue)
                    }
                }
            }
        }
        .accentColor(.appleBlue)
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
                    // 完了したタスクは完了日時の逆順（最近完了したものが先）
                    return item1.lastUpdated > item2.lastUpdated
                } else {
                    // 未完了のタスクは期日順（期日が近いものが先）
                    return item1.dueDate < item2.dueDate
                }
            }
            // 未完了のタスクを先に、完了したタスクを後ろに
            return !item1.isDone && item2.isDone
        }
        
        switch selectedTab {
        case 0: return sortedItems // All tasks
        case 1: return sortedItems.filter { $0.isDone } // Completed tasks only
        default: return sortedItems
        }
    }
}

struct ToDoListView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListView(userId: "HKdvXLQ7WhY1qQaEhmOT8gXnWH93")
    }
}
