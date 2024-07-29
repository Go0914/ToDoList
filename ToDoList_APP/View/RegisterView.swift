//
//  RegisterView.swift
//  ToDoList_APP
//
//  Created by 清水豪 on 2024/07/06.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel = RegisterViewModel()
     
    
    var body: some View {
        VStack {
            // Header
            HeaderView(title: "Register",
                       subtitle: "Start Organizing Todos",
                       angle: -15,
                       background: .orange)

            
            Form {
                TextField("Full Name", text: $viewModel.name)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocorrectionDisabled()
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(DefaultTextFieldStyle())
                
                TLButton(title: "Create Account",
                         backgroud: .green
                ){
                    viewModel.register()
                }
                
                
            }
            
            
            .offset(y: -50)
            Spacer()
            
            
            
        }
        

            
    }
   
}

#Preview {
    RegisterView()
}

