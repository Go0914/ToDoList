import SwiftUI

struct NewItemView: View {
    @StateObject var viewModel: NewItemViewViewModel
    @Binding var newItemPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var animationAmount: CGFloat = 1.0
    @State private var showCustomPicker = false
    @State private var selectedQuickDate: Int? = nil
    @Namespace private var animation
    @FocusState private var isTitleFocused: Bool
    
    init(newItemPresented: Binding<Bool>, toDoListViewModel: ToDoListViewViewModel) {
        self._newItemPresented = newItemPresented
        self._viewModel = StateObject(wrappedValue: NewItemViewViewModel(toDoListViewModel: toDoListViewModel))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                
                ScrollView {
                    VStack(spacing: 20) {
                        titleField
                        dateSelectionView
                        estimatedTimePicker
                        saveButton
                    }
                    .padding(.vertical, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                }
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Incomplete Task"), message: Text("Please fill in all fields and select a valid due date."))
        }
    }
    
    private var backgroundColor: some View {
        Color(red: 1.0, green: 0.99, blue: 0.95) // さらに薄い黄色に調整
            .ignoresSafeArea()
    }
    
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What's your task?")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("Enter task title", text: $viewModel.title)
                .padding()
                .background(
                    Color.white
                        .cornerRadius(12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isTitleFocused ? Color.teal.opacity(0.7) : Color(.systemGray4), lineWidth: 2)
                )
                .focused($isTitleFocused)
            
            Text("Task title is required")
                .font(.caption)
                .foregroundColor(.red)
                .opacity(viewModel.title.isEmpty && !isTitleFocused ? 1 : 0)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .padding(.horizontal)
    }
    
    private var dateSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When is it due?")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<quickSelectTitles.count, id: \.self) { index in
                        QuickSelectButton(title: quickSelectTitles[index],
                                          date: quickSelectDates[index],
                                          selectedDate: $viewModel.dueDate,
                                          isSelected: selectedQuickDate == index,
                                          namespace: animation,
                                          action: {
                                              withAnimation(.spring()) {
                                                  selectedQuickDate = index
                                                  viewModel.dueDate = quickSelectDates[index]
                                                  showCustomPicker = false
                                              }
                                          })
                    }
                }
                .padding(.horizontal, 4)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    showCustomPicker.toggle()
                    selectedQuickDate = nil
                }
            }) {
                HStack {
                    Image(systemName: showCustomPicker ? "calendar.badge.minus" : "calendar.badge.plus")
                    Text(showCustomPicker ? "Hide Calendar" : "Custom Date")
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.orange)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(10)
            }
            
            if showCustomPicker {
                DatePicker("Select Date", selection: $viewModel.dueDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.teal, lineWidth: 1)
                    )
                    .transition(.scale.combined(with: .opacity))
            }
            
            Text("Selected: \(viewModel.dueDate.formatted(date: .long, time: .omitted))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.teal.opacity(0.7), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    private var estimatedTimePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How long will it take?")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(0..<estimatedTimes.count, id: \.self) { index in
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.estimatedTimeIndex = index
                        }
                    }) {
                        Text(estimatedTimes[index])
                            .font(.subheadline.weight(.medium))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(viewModel.estimatedTimeIndex == index ? Color.teal.opacity(0.9) : Color.white)
                            .foregroundColor(viewModel.estimatedTimeIndex == index ? .white : .primary)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(viewModel.estimatedTimeIndex == index ? Color.teal : Color.teal.opacity(0.7), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.teal.opacity(0.7), lineWidth: 1)
                )
        )
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
            Text("Add Task")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.canSave ?
                    Color.teal :
                    Color.gray.opacity(0.5)
                )
                .cornerRadius(16)
        }
        .padding(.horizontal)
        .scaleEffect(animationAmount)
        .disabled(!viewModel.canSave)
    }
    
    private var quickSelectTitles = ["Today", "Tomorrow", "In 2 Days", "This Week", "Next Week", "Next Month"]
    
    private var quickSelectDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        return [
            today,
            calendar.date(byAdding: .day, value: 1, to: today)!,
            calendar.date(byAdding: .day, value: 2, to: today)!,
            calendar.date(byAdding: .weekOfYear, value: 1, to: today)!,
            calendar.date(byAdding: .weekOfYear, value: 2, to: today)!,
            calendar.date(byAdding: .month, value: 1, to: today)!
        ]
    }
}

struct QuickSelectButton: View {
    let title: String
    let date: Date
    @Binding var selectedDate: Date
    let isSelected: Bool
    var namespace: Namespace.ID
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(date.formatted(.dateTime.day().month(.defaultDigits)))
                    .font(.caption2)
                    .opacity(0.7)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                ZStack {
                    if isSelected {
                        Color.teal.opacity(0.9)
                            .matchedGeometryEffect(id: "background_\(title)", in: namespace)
                    } else {
                        Color.white
                    }
                }
            )
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.teal : Color.teal.opacity(0.7), lineWidth: 1)
            )
        }
        .animation(.spring(), value: isSelected)
    }
}

private let estimatedTimes = ["15min", "30min", "1h", "1.5h", "2h", "2.5h", "3h"]

struct NewItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemView(
            newItemPresented: .constant(true),
            toDoListViewModel: ToDoListViewViewModel(userId: "preview_user_id")
        )
        .preferredColorScheme(.light)
        
        NewItemView(
            newItemPresented: .constant(true),
            toDoListViewModel: ToDoListViewViewModel(userId: "preview_user_id")
        )
        .preferredColorScheme(.dark)
    }
}
