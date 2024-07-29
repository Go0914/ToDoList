import SwiftUI
import FirebaseAuth

struct ToDoListView: View {
    @StateObject var viewModel: ToDoListViewViewModel
    
    init(userId: String) {
        self._viewModel = StateObject(wrappedValue: ToDoListViewViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.items) { item in
                        ToDoListItemView(item: item)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.delete(id: item.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("To Do List")
            .toolbar {
                Button {
                    viewModel.showingNewItemView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewItemView, onDismiss: {
                viewModel.fetchTodos()
            }) {
                NewItemView(newItemPresented: $viewModel.showingNewItemView, toDoListViewModel: viewModel)
            }
            .onAppear {
                if let user = Auth.auth().currentUser {
                    print("User is signed in with uid: \(user.uid)")
                    viewModel.fetchTodos()
                } else {
                    print("User is not signed in.")
                    // ログイン画面を表示するコードをここに追加
                }
            }
        }
    }
}

#Preview {
    ToDoListView(userId: "HKdvXLQ7WhY1qQaEhmOT8gXnWH93")
}
