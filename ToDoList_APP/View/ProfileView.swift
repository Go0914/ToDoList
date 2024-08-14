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
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .navigationTitle("Profile")
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(UIColor.systemGray6), Color(UIColor.systemBackground)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .onAppear {
                ViewModel.fechUser()
            }
        }
    }
    
    @ViewBuilder
    func profile(user: User) -> some View {
        VStack(spacing: 30) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.cyan]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
                .frame(width: 140, height: 140)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.top, 40)
            
            VStack(spacing: 20) {
                profileInfoCard(title: "Name", value: user.name)
                profileInfoCard(title: "Email", value: user.email)
                profileInfoCard(title: "Member Since", value: "\(Date(timeIntervalSince1970: user.joined).formatted(date: .abbreviated, time: .omitted))")
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            Button(action: {
                ViewModel.logOut()
            }) {
                Text("Log Out")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.cyan]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    func profileInfoCard(title: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
        )
    }
}

#Preview {
    ProfileView()
}
