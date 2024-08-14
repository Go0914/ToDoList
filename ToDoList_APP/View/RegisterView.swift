import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView {
                VStack(spacing: 40) {
                    titleSection
                    formSection
                    registerButton
                }
                .padding(.horizontal, 30)
                .padding(.top, 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 15) {
            Text("Welcome")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                .overlay(
                    LinearGradient(colors: [.white.opacity(0.4), .clear],
                                   startPoint: .top,
                                   endPoint: .bottom)
                        .mask(Text("Welcome")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                        )
                        .blendMode(.overlay)
                )
            
            Text("Create your account")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.7))
        }
        .scaleEffect(isAnimating ? 1 : 0.9)
        .opacity(isAnimating ? 1 : 0)
    }
    
    private var formSection: some View {
        VStack(spacing: 25) {
            FloatingInputField(text: $viewModel.name, placeholder: "Full Name", systemImage: "person.fill")
            FloatingInputField(text: $viewModel.email, placeholder: "Email", systemImage: "envelope.fill")
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            FloatingInputField(text: $viewModel.password, placeholder: "Password", systemImage: "lock.fill", isSecure: true)
        }
        .offset(y: isAnimating ? 0 : 50)
        .opacity(isAnimating ? 1 : 0)
    }
    
    private var registerButton: some View {
        Button(action: viewModel.register) {
            Text("Create Account")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
        }
        .padding(.top, 20)
        .scaleEffect(isAnimating ? 1 : 0.9)
        .opacity(isAnimating ? 1 : 0)
    }
}

struct AnimatedBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(colors: [.blue, .purple, .pink],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .hueRotation(.degrees(animateGradient ? 45 : 0))
            .ignoresSafeArea()
            .blur(radius: 5)
            .onAppear {
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
    }
}

struct FloatingInputField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    var isSecure: Bool = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 8)
                    .background(Color.clear)
                    .padding(.leading, 8)
            }
            
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.white.opacity(0.7))
                
                if isSecure {
                    SecureField("", text: $text)
                        .focused($isFocused)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(isFocused ? 0.5 : 0.3), Color.purple.opacity(isFocused ? 0.5 : 0.3)]),
                                                     startPoint: .topLeading,
                                                     endPoint: .bottomTrailing))
                                .shadow(color: .blue.opacity(isFocused ? 0.7 : 0.2), radius: 10, x: 0, y: 10)
                        )
                        .scaleEffect(isFocused ? 1.05 : 1)
                        .animation(.easeInOut(duration: 0.3), value: isFocused)
                } else {
                    TextField("", text: $text)
                        .focused($isFocused)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(isFocused ? 0.5 : 0.3), Color.purple.opacity(isFocused ? 0.5 : 0.3)]),
                                                     startPoint: .topLeading,
                                                     endPoint: .bottomTrailing))
                                .shadow(color: .blue.opacity(isFocused ? 0.7 : 0.2), radius: 10, x: 0, y: 10)
                        )
                        .scaleEffect(isFocused ? 1.05 : 1)
                        .animation(.easeInOut(duration: 0.3), value: isFocused)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: text)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
