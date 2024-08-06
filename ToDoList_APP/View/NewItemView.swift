import SwiftUI

struct NewItemView: View {
    @StateObject var viewModel: NewItemViewViewModel
    @Binding var newItemPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var animationAmount: CGFloat = 1.0
    @State private var showCustomPicker = false
    @State private var selectedQuickDate: Int? = nil
    
    init(newItemPresented: Binding<Bool>, toDoListViewModel: ToDoListViewViewModel) {
        self._newItemPresented = newItemPresented
        self._viewModel = StateObject(wrappedValue: NewItemViewViewModel(toDoListViewModel: toDoListViewModel))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 30) {
                        titleField
                        dateSelectionView
                        estimatedTimePicker
                        saveButton
                    }
                    .padding(.vertical, 30)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(hex: "#4A69BD"))
                    }
                }
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Error"), message: Text("Please fill in all fields and select a valid due date."))
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(gradient: Gradient(colors: [Color(hex: "#8E44AD").opacity(0.1), Color(hex: "#4A69BD").opacity(0.1)]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
    
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Task Title")
                .font(.headline)
                .foregroundColor(Color(hex: "#4A69BD"))
            
            TextField("Enter task title", text: $viewModel.title)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "#4A69BD").opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color(hex: "#4A69BD").opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
    
    private var dateSelectionView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Due Date")
                .font(.headline)
                .foregroundColor(Color(hex: "#4A69BD"))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<6) { index in
                        QuickSelectButton(title: quickSelectTitles[index],
                                          date: quickSelectDates[index],
                                          selectedDate: $viewModel.dueDate,
                                          isSelected: selectedQuickDate == index,
                                          action: {
                                              withAnimation(.spring()) {
                                                  selectedQuickDate = index
                                                  viewModel.dueDate = quickSelectDates[index]
                                                  showCustomPicker = false
                                              }
                                          })
                    }
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    showCustomPicker.toggle()
                    selectedQuickDate = nil
                }
            }) {
                HStack {
                    Image(systemName: "calendar")
                    Text("Custom Date")
                }
                .foregroundColor(Color(hex: "#4A69BD"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#4A69BD").opacity(0.1))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "#4A69BD").opacity(0.5), lineWidth: 1)
                )
            }
            
            if showCustomPicker {
                DatePicker("Select Date", selection: $viewModel.dueDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
                    .shadow(color: Color(hex: "#4A69BD").opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            Text("Selected: \(viewModel.dueDate, formatter: itemFormatter)")
                .foregroundColor(Color(hex: "#4A69BD"))
                .padding(.top, 5)
        }
        .padding(.horizontal)
    }
    
    private var estimatedTimePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Estimated Time")
                .font(.headline)
                .foregroundColor(Color(hex: "#4A69BD"))
            
            Picker("", selection: $viewModel.estimatedTimeIndex) {
                ForEach(0..<estimatedTimes.count) { index in
                    Text(estimatedTimes[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(hex: "#4A69BD").opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color(hex: "#4A69BD").opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
    
    private var saveButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                animationAmount += 0.2
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animationAmount = 1.0
                }
            }
            if viewModel.canSave {
                viewModel.save()
                dismiss()
            } else {
                viewModel.showAlert = true
            }
        }) {
            Text("Save Task")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(hex: "#4A69BD"), Color(hex: "#8E44AD")]),
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
                .cornerRadius(15)
                .shadow(color: Color(hex: "#4A69BD").opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .padding(.horizontal)
        .scaleEffect(animationAmount)
        .disabled(!viewModel.canSave)
    }
    
    private var quickSelectTitles = ["Today", "Tomorrow", "In 2 Days", "This Weekend", "Next Monday", "In a Week"]
    
    private var quickSelectDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        return [
            today,
            calendar.date(byAdding: .day, value: 1, to: today)!,
            calendar.date(byAdding: .day, value: 2, to: today)!,
            nextWeekend(),
            nextMonday(),
            calendar.date(byAdding: .day, value: 7, to: today)!
        ]
    }
    
    private func nextWeekend() -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysUntilWeekend = weekday > 6 ? 7 - weekday + 6 : 6 - weekday
        return calendar.date(byAdding: .day, value: daysUntilWeekend, to: today)!
    }
    
    private func nextMonday() -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysUntilMonday = weekday == 2 ? 7 : 9 - weekday
        return calendar.date(byAdding: .day, value: daysUntilMonday, to: today)!
    }
}

struct QuickSelectButton: View {
    let title: String
    let date: Date
    @Binding var selectedDate: Date
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(isSelected ? Color(hex: "#4A69BD") : Color.white.opacity(0.2))
                .foregroundColor(isSelected ? .white : Color(hex: "#4A69BD"))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#4A69BD").opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color(hex: "#4A69BD").opacity(isSelected ? 0.3 : 0.1), radius: 5, x: 0, y: 2)
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

private let estimatedTimes = ["15min", "30min", "1h", "1.5h", "2h", "2.5h", "3h"]

struct NewItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemView(
            newItemPresented: .constant(true),
            toDoListViewModel: ToDoListViewViewModel(userId: "preview_user_id")
        )
    }
}
