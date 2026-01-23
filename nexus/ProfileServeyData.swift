import Foundation

// MARK: - Data Model

struct ProfileSurveyData: Codable {
    var learningDuration: String = ""
    var highDemanded: String = ""          // 1-10 (stored as text for simple TextField binding)
    var usualEfficiency: String = ""       // 1-10
    var energyWhenLearning: String = ""    // 1-10
    var profession: String = ""
}

// MARK: - Store (Load / Save)

final class ProfileSurveyStore: ObservableObject {
    @Published var data: ProfileSurveyData = ProfileSurveyData()

    private let userId: String?

    init(userId: String?) {
        self.userId = userId
        load()
    }

    private var storageKey: String {
        // Save per user if logged in; otherwise fallback
        let id = userId ?? "anonymous"
        return "profileSurvey.\(id)"
    }

    func load() {
        guard let raw = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode(ProfileSurveyData.self, from: raw)
            self.data = decoded
        } catch {
            // If decode fails, do nothing (keep defaults)
            print("Failed to load ProfileSurveyData: \(error)")
        }
    }

    func save() {
        do {
            let encoded = try JSONEncoder().encode(data)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Failed to save ProfileSurveyData: \(error)")
        }
    }
}
