import Foundation
import Combine

final class AchievementsStore: ObservableObject {
    @Published private(set) var records: [AchievementRecord] = []

    private let userId: String
    private var saveCancellable: AnyCancellable?

    init(userId: String) {
        self.userId = userId.isEmpty ? "local" : userId
        load()

        // Auto-save: records are saved once every 0.35 seconds after changes (anti-shake, stable and resource-saving)
        saveCancellable = $records
            .dropFirst()
            .debounce(for: .milliseconds(350), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.save()
            }
    }

    // MARK: - Public API

    func addDone(title: String, details: String, at date: Date = Date()) {
        let item = AchievementRecord(
            title: title,
            details: details,
            status: .completed,
            event: .done,
            updatedAt: date
        )
        insertToTop(item)
    }

    func addAbandoned(title: String, details: String, at date: Date = Date()) {
        let item = AchievementRecord(
            title: title,
            details: details,
            status: .incomplete,
            event: .abandoned,
            updatedAt: date
        )
        insertToTop(item)
    }

    func toggleStatus(recordId: UUID) {
        guard let idx = records.firstIndex(where: { $0.id == recordId }) else { return }
        records[idx].status = (records[idx].status == .completed ? .incomplete : .completed)
        records[idx].event = .toggled
        records[idx].updatedAt = Date()

        // After switching, it should also be "latest on top".
        let moved = records.remove(at: idx)
        records.insert(moved, at: 0)
    }

    func filtered(_ status: AchievementStatus) -> [AchievementRecord] {
        records.filter { $0.status == status }
    }

    // MARK: - Insert & Sort

    private func insertToTop(_ item: AchievementRecord) {
        records.insert(item, at: 0)
        // Double insurance: Even if there is another insertion in the future, the sorting can still remain stable
        records.sort { $0.updatedAt > $1.updatedAt }
    }

    // MARK: - Persistence (JSON in Documents)

    private var fileURL: URL {
        let filename = "achievements_\(userId).json"
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent(filename)
    }

    private func load() {
        do {
            let url = fileURL
            guard FileManager.default.fileExists(atPath: url.path) else {
                records = []
                return
            }
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([AchievementRecord].self, from: data)
            records = decoded.sorted { $0.updatedAt > $1.updatedAt }
        } catch {
            // Even if the read is bad, it won't crash: Roll back to empty to ensure stability
            print("Achievements load failed: \(error)")
            records = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // No crash even if write fails: Only print the log
            print("Achievements save failed: \(error)")
        }
    }
}
