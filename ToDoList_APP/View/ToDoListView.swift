import SwiftUI
import FirebaseAuth

struct ToDoListView: View {
    @StateObject var viewModel: ToDoListViewViewModel
    @State private var showingLoginView = false
    @Namespace private var animation
    @State private var selectedTab = 0
    @State private var showProfile = false
    @State private var animateGradient = false
    
    init(userId: String) {
        self._viewModel = StateObject(wrappedValue: ToDoListViewViewModel(userId: userId))
    }
    
    var body: some View {
        ZStack {
            // トレンディなグラデーション背景
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#A8C0FF"), Color(hex: "#3F2B96")]),
                           startPoint: animateGradient ? .topLeading : .bottomLeading,
                           endPoint: animateGradient ? .bottomTrailing : .topTrailing)
                .ignoresSafeArea()
                .opacity(0.15)
                .onAppear {
                    withAnimation(.linear(duration: 7.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
            
            VStack(spacing: 10) {
                // モダンなカスタムナビゲーションバー
                HStack {
                    Text("Tasks")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#3F2B96"))
                    Spacer()
                    Button(action: { showProfile.toggle() }) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#3F2B96"))
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#A8C0FF").opacity(0.2))
                                    .shadow(color: Color(hex: "#3F2B96").opacity(0.2), radius: 8, x: 0, y: 4)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // スタイリッシュなタブビュー
                HStack(spacing: 0) {
                    TabButton(title: "All", isSelected: selectedTab == 0, namespace: animation) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = 0
                        }
                    }
                    TabButton(title: "Completed", isSelected: selectedTab == 1, namespace: animation) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = 1
                        }
                    }
                }
                .padding(6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.8))
                        .shadow(color: Color(hex: "#3F2B96").opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // タスクリスト
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredItems) { item in
                            ToDoListItemView(item: item)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color(hex: "#3F2B96").opacity(0.1), radius: 8, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "#A8C0FF"), lineWidth: 1)
                                )
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.delete(id: item.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                                        removal: .opacity))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                }
                .scrollIndicators(.hidden)
            }
            
            // 魅力的な新規タスク追加ボタン
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.showingNewItemView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#3F2B96"))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                            .shadow(color: Color(hex: "#3F2B96").opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    .padding(.trailing, 25)
                    .padding(.bottom, 25)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingNewItemView) {
            NewItemView(newItemPresented: $viewModel.showingNewItemView, toDoListViewModel: viewModel)
        }
        .sheet(isPresented: $showingLoginView) {
            LoginView()
        }
        .sheet(isPresented: $showProfile) {
            ProfileView() // プロフィールビューを実装する必要があります
        }
        .onAppear {
            if Auth.auth().currentUser != nil {
                print("ユーザーはサインインしています")
            } else {
                print("ユーザーはサインインしていません")
                showingLoginView = true
            }
        }
    }
    
    var filteredItems: [ToDoListItem] {
        switch selectedTab {
        case 0: return viewModel.items
        case 1: return viewModel.items.filter { $0.isDone }
        default: return viewModel.items
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    var namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : Color(hex: "#3F2B96"))
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    ZStack {
                        if isSelected {
                            Capsule()
                                .fill(Color(hex: "#3F2B96"))
                                .matchedGeometryEffect(id: "TAB", in: namespace)
                        }
                    }
                )
        }
    }
}

struct ToDoListView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListView(userId: "HKdvXLQ7WhY1qQaEhmOT8gXnWH93")
    }
}
