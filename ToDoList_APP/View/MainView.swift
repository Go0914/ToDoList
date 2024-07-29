//
//  ContentView.swift
//  ToDoList_APP
//
//  Created by 清水豪 on 2024/07/05.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()
    
    var body: some View {
        if viewModel.isSinedIn, !viewModel.currentUserId.isEmpty{
            accountView()
        } else {
            LoginView()
        }
    }
    
    @ViewBuilder
    func accountView() -> some View {
        TabView{
            ToDoListView(userId: viewModel.currentUserId)
                .tabItem {
                    Label("home", systemImage: "house")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    MainView()
}
