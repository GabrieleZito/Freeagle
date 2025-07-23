import SwiftUI

struct LoginView: View {
    
    @State private var user: User?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var username: String = ""
    @State private var isLoggedIn: Bool = false
    
    private let userService = UserService()
    
    var body: some View {
        if isLoggedIn{
            EventListView()
        }else{
            login
        }
    }
    
    var login: some View {
            ZStack {
                
                Color.blue.edgesIgnoringSafeArea(.all)
                Text("Nickname")
                    .padding()
                    .frame(width: 300, height: 50, alignment: .center)
                    .background(Color.orange)
                    .font(.title)
                    .fontWeight(.light)
                    .foregroundColor(.white)
                    .padding(.bottom, 0.0)
                    .border(.orange, width: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.orange, style: StrokeStyle(lineWidth: 6))
                            //.background(Color.cyan)
                    )
                    .cornerRadius(50)
                .padding(.bottom, 70)    }
        }
    
    private var loginForm: some View{
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Loading...")
            } else if user != nil {
                Text("Username already taken")
                    .foregroundStyle(.red)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            HStack(spacing: 16) {
                TextField("Enter username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Button("Save") {
                    if username == "" {
                        errorMessage = "Username cannot be empty"
                    }else{
                        fetchUserByUsername(username)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    private func fetchUserByUsername(_ username: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedUser = try await userService.getUserByUsername(username: username)
                print(fetchedUser as Any)
                if fetchedUser == nil {
                    UserDefaults.standard.set(username, forKey: "Username")
                    self.isLoggedIn = true
                }
                await MainActor.run {
                    self.user = fetchedUser
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview{
    LoginView()
}
