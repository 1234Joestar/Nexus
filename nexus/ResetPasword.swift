import SwiftUI
import FirebaseAuth

struct ResetPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("isLoggedIn") var isLoggedIn = false

    /// If this is true, we log out after sending the reset email.
    /// We mainly use this when the reset starts from the account page (MeView).
    private let forceLogoutAfterSend: Bool

    @State private var email: String
    @State private var isSending = false
    @State private var message = ""

    /// Lets other pages pre-fill an email, and choose if we should log out after reset.
    init(initialEmail: String = "", forceLogoutAfterSend: Bool = false) {
        _email = State(initialValue: initialEmail)
        self.forceLogoutAfterSend = forceLogoutAfterSend
    }

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
                    Text("Reset Password")
                        .font(.title2)
                        .padding(.top, 20)

                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal, 20)

                    Button(action: sendResetEmail) {
                        HStack {
                            Spacer()
                            if isSending {
                                ProgressView()
                            } else {
                                Text("Send reset email")
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

                    Spacer()
                }
            }
        }
    }

    /// Send a Firebase 'reset password' email to this address.
    ///
    /// UI note: The Firebase callback may not arrive on the main thread, so all
    /// state updates are wrapped in `DispatchQueue.main.async`.
    private func sendResetEmail() {
        // Remove extra spaces so an email like "user@example.com " still works.
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            message = "Please enter your email."
            return
        }

        isSending = true
        message = ""

        Auth.auth().sendPasswordReset(withEmail: trimmed) { error in
            DispatchQueue.main.async {
                self.isSending = false
                if let error = error {
                    self.message = "Failed to send email: \(error.localizedDescription)"
                } else {
                    self.message = "Reset email sent. Please check your inbox."

                    if forceLogoutAfterSend {
                        // If the user is currently authenticated, signing out ensures they re-authenticate
                        // after resetting the password.
                        try? Auth.auth().signOut()
                        isLoggedIn = false
                    }

                    // Close this page after we successfully send the email.
                    dismiss()
                }
            }
        }
    }
}
