import SwiftUI

struct IntroView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack {
            Spacer()

            // Split the intro text into multiple lines for clean spacing and readability.
            VStack(spacing: 10) {
                Text("Welcome to")
                Text("Nexus")
                    .font(.title)  // Slightly larger to emphasize the app name.
                Text("your personalized AI")
                Text("time management app")
            }
            .font(.title2)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)

            Spacer()

            Button(action: onContinue) {
                HStack {
                    Spacer()
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.green)
                    Spacer()
                }
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white.ignoresSafeArea())
    }
}
