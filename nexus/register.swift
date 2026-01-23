import SwiftUI
import FirebaseAuth

struct RegisterFormView: View {
    @Environment(\.dismiss) var dismiss
    
    /// We save this value so the app remembers you are logged in (and knows which screen to show).
    @AppStorage("isLoggedIn") var isLoggedIn = false

    @State private var email = ""
    @State private var password = ""
    @State private var isSaving = false
    @State private var message = ""
    /// We only show the "Continue" button after the verification email is successfully sent.
    @State private var showContinueButton = false

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

                    Text("Create Account")
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
                    Button(action: register) {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                            } else {
                                Text("Register")
                                    .foregroundColor(.green)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)

                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.horizontal, 20)
                    }

                    // Continue is intentionally separated from Register:
                    // the user must click the verification link first, then come back and tap Continue.
                    if showContinueButton {
                        Button(action: checkEmailVerifiedAndLogin) {
                            HStack {
                                Spacer()
                                Text("Continue")
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }


                    Spacer()
                }
            }
        }
    }

    /// Creates a Firebase account and sends a verification email.
    ///
    /// Important: Firebase completion handlers may run off the main thread.
    /// Any UI state updates are dispatched back onto the main queue.
    func register() {
        // Basic client-side validation to provide immediate feedback.
        guard !email.isEmpty, !password.isEmpty else {
            message = "Email and password cannot be empty."
            return
        }
        guard password.count >= 6 else {
            message = "Password must be at least 6 characters."
            return
        }

        isSaving = true
        message = ""

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                self.isSaving = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.message = "Register failed: \(error.localizedDescription)"
                }
                return
            }

            guard let user = authResult?.user else {
                DispatchQueue.main.async {
                    self.message = "Register failed: no user returned."
                }
                return
            }

            // Send a verification email as part of onboarding.
            user.sendEmailVerification { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.message = "Account created, but email verification failed: \(error.localizedDescription)"
                        self.showContinueButton = false
                    } else {
                        self.message = "Verification email sent. After clicking the link, come back and tap 'Continue'."
                        self.showContinueButton = true
                    }
                }
            }

        }
    }

    /// Re-checks verification status and, if verified, flips `isLoggedIn`.
    /// This is triggered by the user after they click the verification link in email.
    func checkEmailVerifiedAndLogin() {
        guard let user = Auth.auth().currentUser else {
            message = "No current user. Please register again."
            return
        }

        user.reload { _ in
            DispatchQueue.main.async {
                if user.isEmailVerified {
                    // Once verified, we let `NexusApp` switch the root view to `ContentView`.
                    self.isLoggedIn = true
                } else {
                    self.message = "Email is not verified yet. Please click the link in your email first."
                }
            }
        }
    }
}


