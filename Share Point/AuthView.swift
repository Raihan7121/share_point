import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AuthView: View {
    @State private var userName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword  = ""
    @State private var isLoginMode = true
    @State private var errorMessage = ""
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_UID") var userUID: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(isLoginMode ? "Login" : "Register")
                .font(.largeTitle.bold())
            
            if !isLoginMode {
                TextField("Username", text: $userName)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            if !isLoginMode {
                SecureField("ConfirmPassword", text: $confirmPassword)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: handleAuth) {
                Text(isLoginMode ? "Login" : "Register")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button(action: {
                isLoginMode.toggle()
            }) {
                Text(isLoginMode ? "Don't have an account? Register" : "Already have an account? Login")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
    
    private func handleAuth() {
        if isLoginMode {
            loginUser()
        } else {
            signup()
        }
    }
    
    private func signup() {
        if userName.isEmpty || userName.count < 3 {
            errorMessage = "Username must be at least 3 characters"
            return
        }
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            } else if let user = result?.user {
                errorMessage = ""
                print("User signed up successfully")
                
                let newUser = User(
                    username: userName,
                    bio: "",
                    profileImageURL: "",
                    userUID: user.uid,
                    email: user.email ?? ""
                )
                
                let db = Firestore.firestore()
                do {
                    try db.collection("ios_users").document(user.uid).setData(from: newUser) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                            return
                        } else {
                            print("Document successfully written!")
                        }
                    }
                } catch let error {
                    print("Error writing user to Firestore: \(error)")
                    return
                }
                
                logStatus = true
                userUID = user.uid
            }
        }
    }
    
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            if let user = result?.user {
                logStatus = true
                userUID = user.uid
            }
        }
    }
}
