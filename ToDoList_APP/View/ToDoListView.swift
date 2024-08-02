import SwiftUI
import FirebaseAuth

struct ToDoListView: View {
    // ビューモデルの初期化
    @StateObject var viewModel: ToDoListViewViewModel
    
    // イニシャライザ：ユーザーIDを受け取ってビューモデルを初期化
    init(userId: String) {
        self._viewModel = StateObject(wrappedValue: ToDoListViewViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    // ToDoリストの各項目を表示
                    ForEach(viewModel.items) { item in
                        ToDoListItemView(item: item)
                            .contextMenu {
                                // 各項目の削除ボタン
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
                // 新しい項目を追加するボタン
                Button {
                    viewModel.showingNewItemView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            // 新しい項目追加ビューをシートとして表示
            .sheet(isPresented: $viewModel.showingNewItemView) {
                NewItemView(newItemPresented: $viewModel.showingNewItemView, toDoListViewModel: viewModel)
            }
            .onAppear {
                // ビュー表示時にユーザーのログイン状態を確認
                if let user = Auth.auth().currentUser {
                    print("User is signed in with uid: \(user.uid)")
                } else {
                    print("User is not signed in.")
                    // ログイン画面を表示するコードをここに追加
                }
            }
        }
    }
}

// プレビュー用の設定
#Preview {
    ToDoListView(userId: "HKdvXLQ7WhY1qQaEhmOT8gXnWH93")
}
