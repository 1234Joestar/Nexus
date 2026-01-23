import SwiftUI
import Firebase
import FirebaseAuth
 
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Firebase must be configured before any Firebase services (Auth, Firestore, etc.) are used.
        FirebaseApp.configure()
        
        // For a school/demo build, we reset login state on launch to avoid "stuck logged in" issues
        // when testing on shared devices. In a production app, you usually would NOT do this.
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        
        // Also sign out Firebase so the persisted auth session does not auto-restore.
        try? Auth.auth().signOut()
        
        return true
    }
}

 
@main
struct NexusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // Global login state shared across the app via `UserDefaults`.
    @AppStorage("isLoggedIn") var isLoggedIn = false
 
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                // Authenticated experience.
                ContentView()
            } else {
                // Unauthenticated experience.
                EntryView()
            }
        }
    }
}

