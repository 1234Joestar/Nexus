import Foundation
import SwiftUI

final class TaskModel: ObservableObject {
    @Published var hasActiveTask: Bool = false

    @Published var name: String = ""
    @Published var details: String = ""
    @Published var durationHours: String = ""
    @Published var durationMinutes: String = ""

    @Published var elapsedSeconds: Int = 0
    @Published var isTimerRunning: Bool = false
    @Published var showAfterPauseOptions: Bool = false
}
