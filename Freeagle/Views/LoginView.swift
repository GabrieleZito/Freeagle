import SwiftUI
import Combine

struct LoginView: View {
    
    @State private var user: User?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var username: String = ""
    @State private var isLoggedIn: Bool = false
    
    private let api = APIService()
    private let textLimit = 15
    
    var body: some View {
        if isLoggedIn {
            MainView()
        } else {
            loginScreen
        }
    }
    
    var loginScreen: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.cyan.opacity(0.8),
                        Color(red: 0/255, green: 0/255, blue: 173/255).opacity(0.8),
                        Color(red: 0/255, green: 0/255, blue: 173/255).opacity(0.9)]),
                    
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Titolo dell'app
                    VStack(spacing: 8) {
                        Text("Welcome")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        
                        Text("Enter a nickname to continue")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Campo di input
                    VStack(spacing: 16) {
                        TextField("", text: $username)
                            .placeholder(when: username.isEmpty) {
                                Text("Nickname")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.title2)
                            }
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .onReceive(Just(username)) { _ in
                                limitText(textLimit)
                            }
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        // Mostra errore se presente
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red.opacity(0.9))
                                .font(.caption)
                                .padding(.horizontal)
                        }
                        
                        // Bottone di login
                        Button(action: {
                            if username == ""{
                                errorMessage = "Username can't be empty"
                            }else{
                                fetchUserByUsername(username)
                            }
                            //loginAction()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                        .frame(width: 20, height: 20)
                                } else {
                                    Text("Login")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                            )
                        }
                        .disabled(isLoading || username.isEmpty)
                        .opacity(username.isEmpty ? 0.6 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: username.isEmpty)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Logo dell'app
                    VStack(spacing: 12) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .scaleEffect(2.5)
                        
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private func loginAction() {
        if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "The nickname field cannot be empty"
            return
        }
        
        fetchUserByUsername(username.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    private func fetchUserByUsername(_ username: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                //let fetchedUser = try await userService.getUserByUsername(username: username)
                let isUsernameTaken = try await api.getUser(username: username)
                print("risultato prova: \(isUsernameTaken)")
                print(isUsernameTaken)
                if isUsernameTaken {
                    self.errorMessage = "Username already taken"
                } else {
                    UserDefaults.standard.set(username, forKey: "username")
                    try await api.setUser(username: username)
                    self.isLoggedIn = true
                }
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    print(self.errorMessage ?? "no")
                    self.isLoading = false
                }
            }
        }
    }
    
    private func limitText(_ upper: Int) {
        if username.count > upper {
            username = String(username.prefix(upper))
        }
    }
}

// Extension per il placeholder personalizzato
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

#Preview {
    LoginView()
}
