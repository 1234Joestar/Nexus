import SwiftUI
 
struct EntryView: View {
    /// Used to show/hide the login pop-up.
    @State private var showLogin = false
    /// Used to show/hide the register pop-up.
    @State private var showRegister = false
 
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
 
                VStack(spacing: 0) {
 
                    Spacer().frame(height: 120)
 
                    // App brand title (custom font).
                    Text("Nexus")
                        .font(Font.custom("Hurricane", size: 96))
                        .foregroundColor(.black)
                        .padding(.bottom, 80)
 
                    // Login flow presented as a sheet so the EntryView remains the root.
                    Button {
                        showLogin = true
                    } label: {
                        Text("Login")
                            .font(Font.custom("Ibarra Real Nova", size: 30))
                            .foregroundColor(.black)
                    }
                    .padding(.bottom, 12)
                        .sheet(isPresented: $showLogin) {
                            LoginFormView()   // Presents the authentication form.
                        }
 
                    Spacer().frame(height: 44)
 
                    // Register flow presented as a sheet.
                    Button {
                        showRegister = true
                    } label: {
                        Text("Register")
                            .font(Font.custom("Ibarra Real Nova", size: 30))
                            .foregroundColor(.black)
                    }
                    .padding(.bottom, 12)
                        .sheet(isPresented: $showRegister) {
                            RegisterFormView()   // Creates a new account + email verification.
                        }
 
                    Spacer()
                }
            }
        }
    }
}
 
#Preview {
    EntryView()
}
 
