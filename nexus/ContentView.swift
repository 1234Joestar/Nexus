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

    /// Achievements persistent store (local JSON persistence).
    @StateObject private var achievementsStore = AchievementsStore(
        userId: Auth.auth().currentUser?.uid ?? "local"
    )

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
                                // 'Me' is for account/settings.
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
        // ✅ Key: inject achievements store globally
        .environmentObject(achievementsStore)
    }

    // UI helpers
    // `tabItem` builds one button in the bottom bar.
    // `logout` signs out from Firebase and marks you as logged out in the app.

    private func tabItem(title: String,
                         isSelected: Bool,
                         action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .black : .gray)
                .padding(.horizontal, 28)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    Group {
                        if isSelected {
                            Capsule()
                                .fill(Color.black.opacity(0.08))
                                .shadow(color: Color.black.opacity(0.15),
                                        radius: 4, x: 0, y: 2)
                        } else {
                            Capsule().fill(Color.clear)
                        }
                    }
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }

        isLoggedIn = false
    }
}
