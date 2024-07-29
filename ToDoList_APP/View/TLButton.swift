//
//  TLButton.swift
//  ToDoList_APP
//
//  Created by 清水豪 on 2024/07/08.
//

import SwiftUI

struct TLButton: View {
    
    let title: String
    let backgroud: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(backgroud)
                
                Text(title)
                    .foregroundColor(.white)
                    .bold()
            }
        }
        .padding()

    }
}

#Preview {
    TLButton(title: "Value",
             backgroud: .pink) {
        //Action
    }
}
