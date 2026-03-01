import SwiftUI
import FirebaseAuth

struct AISettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var store: AISettingsStore

    @State private var status: AIConnectionStatus = .idle
    @State private var lastResponsePreview: String = ""

    init() {
        _store = StateObject(wrappedValue: AISettingsStore.makeDefaultStoreForCurrentUser())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Settings")
                        .font(.system(size: 34, weight: .regular))
                        .foregroundColor(.white)

                    Text("Support DeepSeek / ChatGPT / Qwen (OpenAI-compatible APIs)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 18)
                .background(Color.green.opacity(0.75))

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {


                        // API Key
                        VStack(alignment: .leading, spacing: 8) {
                            Text("API Key")
                                .font(.system(size: 18, weight: .semibold))

                            SecureField("paste your API key here", text: $store.data.apiKey)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                                .onChange(of: store.data.apiKey) { _ in
                                    status = .idle
                                    lastResponsePreview = ""
                                }
                        }

                        // Base URL
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Base URL")
                                .font(.system(size: 18, weight: .semibold))

                            TextField("e.g. https://api.xxx.com", text: $store.data.baseURL)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                                .onChange(of: store.data.baseURL) { _ in
                                    status = .idle
                                    lastResponsePreview = ""
                                }

                            Text("⚠️ Must be entered by the user. Many third-party / proxy providers use different Base URLs.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }

                        // Model (extra but important)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Model")
                                .font(.system(size: 18, weight: .semibold))

                            TextField("model name", text: $store.data.model)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                                .onChange(of: store.data.model) { _ in
                                    status = .idle
                                    lastResponsePreview = ""
                                }

                            Text("If your provider requires a specific model name, update it here.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }

                        // Test button
                        Button {
                            Task { await testConnection() }
                        } label: {
                            HStack {
                                Spacer()
                                switch status {
                                case .testing:
                                    ProgressView()
                                default:
                                    Text("AI Connection Test")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)

                        // Status display
                        statusView()

                        // Response preview (optional)
                        if !lastResponsePreview.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Preview")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(lastResponsePreview)
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .lineLimit(6)
                            }
                            .padding(.top, 6)
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 18)
                }

                // Bottom buttons
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
            .navigationBarBackButtonHidden(true)
        }
    }

    @ViewBuilder
    private func statusView() -> some View {
        switch status {
        case .idle:
            HStack(spacing: 8) {
                Circle().fill(Color.gray.opacity(0.5)).frame(width: 10, height: 10)
                Text("Not tested")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding(.top, 8)

        case .testing:
            HStack(spacing: 8) {
                Circle().fill(Color.gray.opacity(0.5)).frame(width: 10, height: 10)
                Text("Testing…")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding(.top, 8)

        case .connected:
            HStack(spacing: 8) {
                Circle().fill(Color.green).frame(width: 10, height: 10)
                Text("Connected")
                    .foregroundColor(.green)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.top, 8)

        case .notConnected(let reason):
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Circle().fill(Color.red).frame(width: 10, height: 10)
                    Text("Not connected")
                        .foregroundColor(.red)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(reason)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(6)
            }
            .padding(.top, 8)
        }
    }

    @MainActor
    private func testConnection() async {
        status = .testing
        lastResponsePreview = ""

        // Save first so test uses the latest values and persistence is always synced.
        store.save()

        let trimmedModel = store.data.model.trimmingCharacters(in: .whitespacesAndNewlines)
        let effectiveModel = trimmedModel.isEmpty ? "gpt-4o-mini" : trimmedModel

        let result = await AIClient.testConnection(
            baseURL: store.data.baseURL,
            apiKey: store.data.apiKey,
            model: effectiveModel
        )

        switch result {
        case .success(let text):
            status = .connected
            lastResponsePreview = String(text.prefix(300))
        case .failure(let error):
            status = .notConnected(error.localizedDescription)
            lastResponsePreview = ""
        }
    }
}
