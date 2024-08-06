import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewViewModel()
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                
                Text("To Do List")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                // Login Form
                VStack(spacing: 15) {
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    CustomTextField(placeholder: "Email Address", text: $viewModel.email, systemImage: "envelope")
                    
                    CustomTextField(placeholder: "Password", text: $viewModel.password, isSecure: true, systemImage: "lock")
                    
                    Button(action: {
                        withAnimation {
                            isLoading = true
                        }
                        viewModel.login()
                    }) {
                        ZStack {
                            Text("Log In")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .opacity(isLoading ? 0 : 1)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .disabled(isLoading)
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal)
                
                // Create Account Link
                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Create one")
                        .foregroundColor(.white)
                        .underline()
                }
                .padding(.top)
            }
            .padding()
        }
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.white)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
        .autocapitalization(.none)
        .autocorrectionDisabled()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
