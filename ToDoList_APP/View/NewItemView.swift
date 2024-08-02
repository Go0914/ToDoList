import SwiftUI

struct NewItemView: View {
    // ビューモデルの初期化
    @StateObject var viewModel: NewItemViewViewModel
    // 新規アイテム追加ビューの表示状態を管理するバインディング
    @Binding var newItemPresented: Bool
    
    // イニシャライザ：新規アイテム追加ビューの表示状態とToDoリストのビューモデルを受け取る
    init(newItemPresented: Binding<Bool>, toDoListViewModel: ToDoListViewViewModel) {
        self._newItemPresented = newItemPresented
        self._viewModel = StateObject(wrappedValue: NewItemViewViewModel(toDoListViewModel: toDoListViewModel))
    }
    
    var body: some View {
        VStack {
            // タイトル
            Text("New Item")
                .font(.system(size: 32))
                .bold()
                .padding(.top, 100)
            
            Form {
                // タイトル入力フィールド
                TextField("Title", text: $viewModel.title)
                    .textFieldStyle(DefaultTextFieldStyle())
                
                // 期日選択
                DatePicker("Due Date", selection: $viewModel.dueDate)
                    .datePickerStyle(GraphicalDatePickerStyle())
                
                // 予測時間選択
                Picker("Estimated Time", selection: $viewModel.estimatedTimeIndex) {
                    Text("15分").tag(0)
                    Text("30分").tag(1)
                    Text("1時間").tag(2)
                    Text("1.5時間").tag(3)
                    Text("2時間").tag(4)
                    Text("2.5時間").tag(5)
                    Text("3時間").tag(6)
                }
                
                // 保存ボタン
                TLButton(
                    title: "Save",
                    backgroud: .pink
                ) {
                    if viewModel.canSave {
                        viewModel.save()
                        newItemPresented = false
                    } else {
                        viewModel.showAlert = true
                    }
                }
                .padding()
            }
            // エラーアラート
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text("Please fill in all fields and select due date that is today or newer.")
                )
            }
        }
    }
}

// プレビュー用の設定
#Preview {
    NewItemView(
        newItemPresented: .constant(true),
        toDoListViewModel: ToDoListViewViewModel(userId: "preview_user_id")
    )
}
