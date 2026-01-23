import SwiftUI
import FirebaseAuth

struct ProfileSurveyView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var store: ProfileSurveyStore

    @State private var showAlert = false
    @State private var alertMessage = ""

    init() {
        let uid = Auth.auth().currentUser?.uid
        _store = StateObject(wrappedValue: ProfileSurveyStore(userId: uid))
    }

    var body: some View {
        VStack(spacing: 0) {

            // Green header
            VStack(alignment: .leading, spacing: 6) {
                Text("Your Profile")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundColor(.white)

                Text("Let me know you better")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 18)
            .background(Color.green.opacity(0.75))

            // Content scroll if needed
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    questionBlock(
                        number: "1.",
                        title: "What time duration would you like to use to learn?",
                        text: binding(\.learningDuration),
                        keyboard: .default
                    )

                    questionBlock(
                        number: "2.",
                        title: "Are you a high demanded person? (1-10)",
                        text: binding(\.highDemanded),
                        keyboard: .numberPad
                    )

                    questionBlock(
                        number: "3.",
                        title: "How do you rate your usual efficiency? (1-10)",
                        text: binding(\.usualEfficiency),
                        keyboard: .numberPad
                    )

                    questionBlock(
                        number: "4.",
                        title: "What is your daily energy level when you want to learn something? (1-10)",
                        text: binding(\.energyWhenLearning),
                        keyboard: .numberPad
                    )

                    questionBlock(
                        number: "5.",
                        title: "What’s your profession?",
                        text: binding(\.profession),
                        keyboard: .default
                    )

                    Spacer().frame(height: 10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 18)
            }

            // Bottom buttons (Back / Save)
            HStack(spacing: 18) {
                Button {
                    dismiss()
                } label: {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.black.opacity(0.1)))
                }
                .buttonStyle(.plain)

                Button {
                    if !validateAll() { return }
                    store.save()
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.black.opacity(0.1)))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
        }
        .background(Color.white)
        .alert("Invalid Input", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - UI Helpers

    private func questionBlock(number: String,
                               title: String,
                               text: Binding<String>,
                               keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(number) \(title)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)

            TextField("write here", text: text)
                .keyboardType(keyboard)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func binding(_ keyPath: WritableKeyPath<ProfileSurveyData, String>) -> Binding<String> {
        Binding(
            get: { store.data[keyPath: keyPath] },
            set: { store.data[keyPath: keyPath] = $0 }
        )
    }

    // MARK: - Validation

    private func validateAll() -> Bool {
        // Only validate the 1-10 fields. Others can be empty if you want.
        if !isValidScale(store.data.highDemanded) {
            return fail("Question 2 must be a number from 1 to 10.")
        }
        if !isValidScale(store.data.usualEfficiency) {
            return fail("Question 3 must be a number from 1 to 10.")
        }
        if !isValidScale(store.data.energyWhenLearning) {
            return fail("Question 4 must be a number from 1 to 10.")
        }
        return true
    }

    private func isValidScale(_ s: String) -> Bool {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let n = Int(trimmed) else { return false }
        return (1...10).contains(n)
    }

    private func fail(_ message: String) -> Bool {
        alertMessage = message
        showAlert = true
        return false
    }
}
