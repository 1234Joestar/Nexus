import SwiftUI
import FirebaseAuth

struct MeView: View {
    var onLogout: () -> Void

    @State private var showResetPassword = false
    @State private var showProfileSurvey = false

    private var username: String {
        // If Firebase displayName exists, use it; else try email prefix; else fallback
        if let name = Auth.auth().currentUser?.displayName,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }

        if let email = Auth.auth().currentUser?.email,
           let prefix = email.split(separator: "@").first {
            return String(prefix)
        }

        return "Joe Zhang"
    }

    var body: some View {
        VStack(spacing: 0) {

            // Top area: username capsule + custom button
            VStack(spacing: 18) {

                // Username capsule (ellipse-like)
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.gray.opacity(0.7))

                    Text(username)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.gray.opacity(0.9))

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.black.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal, 24)
                .padding(.top, 32)

                // Custom button (same style as Change Password / Logout)
                Button {
                    showProfileSurvey = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Profile Setting")
                            .font(.headline)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    .padding()
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
            }

            // Push account buttons to bottom
            Spacer()

            // Bottom area: Account + Change Password + Logout (moved down)
            VStack(alignment: .leading, spacing: 12) {
                Text("Account")
                    .font(.headline)
                    .padding(.bottom, 4)

                Button {
                    showResetPassword = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Change Password")
                            .font(.headline)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    .padding()
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(12)
                }

                Button(action: onLogout) {
                    HStack {
                        Spacer()
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    .padding()
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)

        // Reset password sheet (unchanged)
        .sheet(isPresented: $showResetPassword) {
            let currentEmail = Auth.auth().currentUser?.email ?? ""
            ResetPasswordView(
                initialEmail: currentEmail,
                forceLogoutAfterSend: true
            )
        }

        // Survey sheet (new)
        .sheet(isPresented: $showProfileSurvey) {
            ProfileSurveyView()
        }
    }
}

//testing git
