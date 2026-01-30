import Foundation
import SwiftUI
import Combine

final class TaskModel: ObservableObject {
    @Published var hasActiveTask: Bool = false

    @Published var name: String = ""
    @Published var details: String = ""
    @Published var durationHours: String = ""
    @Published var durationMinutes: String = ""

    @Published var elapsedSeconds: Int = 0
    @Published var isTimerRunning: Bool = false
    @Published var showAfterPauseOptions: Bool = false

    // Keep the timer alive in the model so it continues across tab switches.
    private var timerCancellable: AnyCancellable?

    init() {
        // Tick every second on the main run loop.
        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard self.hasActiveTask, self.isTimerRunning else { return }
                self.elapsedSeconds += 1
            }
    }

    deinit {
        timerCancellable?.cancel()
    }
}
