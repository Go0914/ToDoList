import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                HeaderView(title: "To Do List",
                           subtitle: "Get Things Done",
                           angle: 15,
                           background: .pink)
            
                
                Form {
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                        
                    }
                    
                    TextField("Email Address",
                              text: $viewModel.email)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    SecureField("Password",
                                text: $viewModel.password)
                        .textFieldStyle(DefaultTextFieldStyle())
                    
                    TLButton(
                        title: "Log In",
                        backgroud: .blue){
                        viewModel.login()
                    }
                    
                    .padding()
                }
                .offset(y: -50)
                
                // Create Account
                VStack {
                    Text("Don't have an account?")
                    NavigationLink("Create An Account", destination: RegisterView())
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.bottom, 50)
            
        }
    }
}


#Preview {
    LoginView()
}
