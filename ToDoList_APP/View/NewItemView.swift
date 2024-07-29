import SwiftUI

struct NewItemView: View {
    @StateObject var viewModel: NewItemViewViewModel
    @Binding var newItemPresented: Bool
    
    init(newItemPresented: Binding<Bool>, toDoListViewModel: ToDoListViewViewModel) {
        self._newItemPresented = newItemPresented
        self._viewModel = StateObject(wrappedValue: NewItemViewViewModel(toDoListViewModel: toDoListViewModel))
    }
    
    var body: some View {
        VStack {
            Text("New Item")
                .font(.system(size: 32))
                .bold()
                .padding(.top, 100)
            
            Form {
                // title
                TextField("Title", text: $viewModel.title)
                    .textFieldStyle(DefaultTextFieldStyle())
                
                // Due Date
                DatePicker("Due Date", selection: $viewModel.dueDate)
                    .datePickerStyle(GraphicalDatePickerStyle())
                
                // 予測時間フィールドを追加
                Picker("Estimated Time", selection: $viewModel.estimatedTimeIndex) {
                    Text("15分").tag(0)
                    Text("30分").tag(1)
                    Text("1時間").tag(2)
                    Text("1.5時間").tag(3)
                    Text("2時間").tag(4)
                    Text("2.5時間").tag(5)
                    Text("3時間").tag(6)
                }
                
                // Button
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
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text("Please fill in all fields and select due date that is today or newer.")
                )
            }
        }
    }
}

#Preview {
    NewItemView(
        newItemPresented: .constant(true),
        toDoListViewModel: ToDoListViewViewModel(userId: "preview_user_id")
    )
}
