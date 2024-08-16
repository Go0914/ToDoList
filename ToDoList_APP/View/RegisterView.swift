import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    titleSection
                    formSection
                    registerButton
                }
                .padding(.horizontal, 30)
                .padding(.top, 50)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("Welcome")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: isAnimating)
            
            Text("Create your account")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: isAnimating)
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            FloatingInputField(text: $viewModel.name, placeholder: "Full Name", systemImage: "person.fill")
            FloatingInputField(text: $viewModel.email, placeholder: "Email", systemImage: "envelope.fill")
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            FloatingInputField(text: $viewModel.password, placeholder: "Password", systemImage: "lock.fill", isSecure: true)
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .animation(.easeOut(duration: 0.5), value: isAnimating)
    }
    
    private var registerButton: some View {
        Button(action: viewModel.register) {
            Text("Create Account")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.7))
                .cornerRadius(10)
                .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .padding(.top, 20)
        .scaleEffect(isAnimating ? 1 : 0.9)
        .animation(.easeOut(duration: 0.5), value: isAnimating)
    }
}

struct FloatingInputField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    var isSecure: Bool = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.secondary)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .focused($isFocused)
                    .foregroundColor(.primary)
            } else {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: isFocused ? Color.blue.opacity(0.2) : Color.clear, radius: 5, x: 0, y: 2)
        .animation(.easeOut(duration: 0.2), value: isFocused)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
