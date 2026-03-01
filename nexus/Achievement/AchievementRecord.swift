import Foundation

enum AchievementStatus: String, Codable {
    case completed
    case incomplete
}

enum AchievementEvent: String, Codable {
    case done          // User Done
    case abandoned     // User Delete（放弃）
    case toggled       // Chaging Status at Achievements
}

struct AchievementRecord: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var details: String
    var status: AchievementStatus
    var event: AchievementEvent
    /// "The time when this record was last confirmed/changed", used for sorting (the latest is at the top)
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        details: String,
        status: AchievementStatus,
        event: AchievementEvent,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.status = status
        self.event = event
        self.updatedAt = updatedAt
    }
}
