import SwiftUI
import FirebaseAuth
 
struct LoginFormView: View {
    @Environment(\.dismiss) var dismiss
    /// We save this value so the app remembers you are logged in (and knows which screen to show).
    @AppStorage("isLoggedIn") var isLoggedIn = false
 
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var message = ""
    /// Used to open the 'reset password' page as a pop-up sheet.
    @State private var showResetPassword = false

 
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
 
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                        Text("Back")
                            .font(.system(size: 18))
                    }
                    .foregroundColor(.black)
                }
                .padding(.top, 20)
                .padding(.leading, 20)
 
                Spacer().frame(height: 20)
 
                VStack(spacing: 24) {
 
                    Text("Login")
                        .font(.title2)
                        .padding(.top, 20)
 
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal, 20)
 
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 20)
 
                    Button(action: login) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Login")
                                    .foregroundColor(.green)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)

 
                    // Forgot password: open the reset-password sheet.
                    Button {
                        showResetPassword = true
                    } label: {
                        Text("Forgot password?")
                            .font(.footnote)
                            .foregroundColor(.green)
                    }
                    .padding(.top, 4)
                    .padding(.horizontal, 20)
                    .sheet(isPresented: $showResetPassword) {
                        // Prefill the email the user already typed to reduce re-entry.
                        ResetPasswordView(initialEmail: email)
                    }


                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.horizontal, 20)
                    }

 
                    Spacer()
                }
            }
        }
    }
 
    /// Logs the user in using Firebase.
    ///
    /// Note: Firebase callbacks may arrive on a background thread, so UI state changes
    /// are wrapped in `DispatchQueue.main.async`.
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            message = "Email and password cannot be empty."
            return
        }
 
        isLoading = true
        message = ""
 
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
 
            if let error = error {
                DispatchQueue.main.async {
                    self.message = "Login failed: \(error.localizedDescription)"
                }
                return
            }
 
            guard let user = authResult?.user else {
                DispatchQueue.main.async {
                    self.message = "Login failed: no user returned."
                }
                return
            }
 
            // Optional: require email verification (basic safety + helps avoid fake accounts).
            user.reload { _ in
                DispatchQueue.main.async {
                    if !user.isEmailVerified {
                        self.message = "Please verify your email before logging in."
                    } else {
                        // Success: go to the main app screen
                        self.isLoggedIn = true
                        // The sheet closes automatically because the app switches screens
                    }
                }
            }
        }
    }
    


    
}
