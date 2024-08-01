//
//  ProfileView.swift
//  ToDoList_APP
//
//  Created by 清水豪 on 2024/07/06.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var ViewModel = ProfileViewViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if let user = ViewModel.user {
                    profile(user: user)
                } else {
                    Text("Loading Profile...")
                }
                
            }
            .navigationTitle("Profile")
        }
        .onAppear {
            ViewModel.fechUser()
        }
    }
        
        
    @ViewBuilder
    func profile(user: User) -> some View {
        Image(systemName: "person.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color.blue)
            .frame(width: 125, height: 125)
            .padding()
        
        // Info: Name, Email, Member since
        VStack(alignment: .leading) {
            HStack {
                Text("Name: ")
                    .bold()
                Text(user.name)
            }
            .padding()
            HStack {
                Text("Email: ")
                    .bold()
                Text(user.email)
            }
            .padding()
            HStack {
                Text("Member Since: ")
                    .bold()
                Text("\(Date(timeIntervalSince1970: user.joined).formatted(date: .abbreviated, time: .shortened))")
            }
            .padding()
        }
        .padding()
        
        // Sign out
        Button("Log Out") {
            ViewModel.logOut()
        }
        .tint(.red)
        .padding()
        
        Spacer()
    }
}

            
#Preview {
    ProfileView()
}
