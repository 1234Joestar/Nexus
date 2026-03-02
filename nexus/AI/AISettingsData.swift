import Foundation
import FirebaseAuth

// MARK: - Provider

enum AIProvider: String, CaseIterable, Identifiable, Codable {
    case deepseek = "DeepSeek"
    case chatgpt = "ChatGPT"
    case qwen = "Qwen"

    var id: String { rawValue }

    /// A reasonable default model name per provider (user can edit).
    var defaultModel: String {
        switch self {
        case .deepseek:
            return "deepseek-chat"
        case .chatgpt:
            // Many OpenAI-compatible gateways accept OpenAI model names;
            // user can change depending on their provider.
            return "gpt-4o-mini"
        case .qwen:
            return "qwen2.5-7b-instruct"
        }
    }
}

// MARK: - Data Model

struct AISettingsData: Codable {
    var provider: AIProvider = .chatgpt
    var apiKey: String = ""
    var baseURL: String = ""      // must be user-provided
    var model: String = ""        // default derived from provider if empty
}

// MARK: - Store

final class AISettingsStore: ObservableObject {
    @Published var data: AISettingsData = AISettingsData()

    private let userId: String?

    init(userId: String?) {
        self.userId = userId
        load()
        // Ensure model has a default if empty
        if data.model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            data.model = data.provider.defaultModel
        }
    }

    private var storageKey: String {
        let id = userId ?? "anonymous"
        return "aiSettings.\(id)"
    }

    func load() {
        guard let raw = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode(AISettingsData.self, from: raw)
            self.data = decoded
        } catch {
            print("Failed to load AISettingsData: \(error)")
        }
    }

    func save() {
        do {
            let encoded = try JSONEncoder().encode(data)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Failed to save AISettingsData: \(error)")
        }
    }

    static func makeDefaultStoreForCurrentUser() -> AISettingsStore {
        let uid = Auth.auth().currentUser?.uid
        return AISettingsStore(userId: uid)
    }
}
