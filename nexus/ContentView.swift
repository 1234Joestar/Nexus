import SwiftUI
import FirebaseAuth

struct ContentView: View {
    enum Tab {
        case now
        case me
    }

    /// Which bottom tab is selected right now.
    @State private var selectedTab: Tab = .now

    /// When this is true, we show the quick intro screen (IntroView).
    /// This is just UI state (not saved forever). If you restart the app, it goes back to default.
    @State private var showIntro: Bool = true

    /// A saved 'logged in' value (stored with `@AppStorage`).
    /// `NexusApp` reads this to decide: show the login entry page or the main page.
    @AppStorage("isLoggedIn") var isLoggedIn = false

    /// Shared task data for the 'Now' page.
    /// `@StateObject` means we create the model once and keep it while the view refreshes.
    @StateObject private var taskModel = TaskModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                if showIntro {
                    IntroView {
                        withAnimation {
                            // Finish the intro and go to the main 'Now' page.
                            showIntro = false
                            selectedTab = .now
                        }
                    }
                } else {
                    VStack(spacing: 0) {

                        Group {
                            switch selectedTab {
                            case .now:
                                // Pass the shared model down so the timer/task data stays the same.
                                NowView(taskModel: taskModel)
                            case .me:
                                // 'Me' is for account/settings, so it does not need the task model.
                                MeView(onLogout: logout)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Divider()

                        HStack(spacing: 0) {
                            tabItem(title: "Now", isSelected: selectedTab == .now) {
                                selectedTab = .now
                            }
                            tabItem(title: "Me", isSelected: selectedTab == .me) {
                                selectedTab = .me
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            Color.white
                                .ignoresSafeArea(edges: .bottom)
                        )
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    // UI helpers
    // `tabItem` builds one button in the bottom bar.
    // `logout` signs out from Firebase and marks you as logged out in the app.


    // Bottom bar tab item

    private func tabItem(title: String,
                         isSelected: Bool,
                         action: @escaping () -> Void) -> some View {
        // Custom bottom-tab button.
        // This is intentionally simple (text-only) to keep the UI minimal and readable.
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .black : .gray)
                Spacer()
            }
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.08))
                            .shadow(color: Color.black.opacity(0.15),
                                    radius: 4, x: 0, y: 2)
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }

    // Logout

    private func logout() {
        do {
            // Firebase sign-out can fail, so we wrap it with `do/catch`.
            try Auth.auth().signOut()
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }

        // Update the saved login value so the app goes back to the entry/login screen.
        isLoggedIn = false
    }
}
