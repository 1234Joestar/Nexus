import Foundation

enum AchievementStatus: String, Codable {
    case completed
    case incomplete
}

enum AchievementEvent: String, Codable {
    case done          // 用户点 Done
    case abandoned     // 用户点 Delete（放弃）
    case toggled       // 在 Achievements 里手动切换状态
}

struct AchievementRecord: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var details: String
    var status: AchievementStatus
    var event: AchievementEvent
    /// “这条记录最后一次被确认/变更的时间”，用于排序（最新在最上面）
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
