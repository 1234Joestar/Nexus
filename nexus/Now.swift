import SwiftUI
import Combine

struct NowView: View {
    @ObservedObject var taskModel: TaskModel

    /// A timer that ticks every 1 second. We use it to add 1 to `elapsedSeconds` when running.
    /// We use `Timer.publish` + `onReceive` so the UI updates automatically.
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    /// Used to show/hide the 'Modify Task' pop-up sheet.
    @State private var taskModelShowingModify: Bool = false

    var body: some View {
        VStack {
            Spacer()

            if taskModel.hasActiveTask {
                // Active task UI: task info + timer + (optionally) post-pause actions.
                VStack(spacing: 24) {

                    // Top area: task name, optional details, and planned duration.
                    VStack(alignment: .leading, spacing: 8) {
                        Text(taskModel.name)
                            .font(.title2)
                            .fontWeight(.semibold)

                        if !taskModel.details.isEmpty {
                            Text(taskModel.details)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Text("Planned: \(taskModel.durationHours.ifEmptyReturnZero()) h \(taskModel.durationMinutes.ifEmptyReturnZero()) min")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                    // Middle area: circular timer view.
                    ZStack {
                        // Circular background.
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 240, height: 240)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                        // Timer contents.
                        VStack(spacing: 12) {
                            Text("Time Studied")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Text(formattedElapsedTime())
                                .font(.title2)
                                .fontWeight(.semibold)

                            // Tap to pause / resume the timer.
                            Button {
                                // Pause / resume logic:
                                // - Pausing reveals post-pause options (Continue / Modify / Done / Delete).
                                // - Resuming hides them to reduce clutter.
                                if taskModel.isTimerRunning {
                                    // Running -> pause.
                                    taskModel.isTimerRunning = false
                                    taskModel.showAfterPauseOptions = true
                                } else {
                                    // Paused -> resume.
                                    taskModel.isTimerRunning = true
                                    taskModel.showAfterPauseOptions = false
                                }
                            } label: {
                                Image(systemName: taskModel.isTimerRunning ? "pause.fill" : "play.fill")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.green)
                                    .padding(12)
                                    .background(
                                        Circle()
                                            .fill(Color.white.opacity(0.9))
                                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 8)
                        }
                    }

                    // Bottom area: actions only shown after pausing.
                    if taskModel.showAfterPauseOptions {
                        VStack(spacing: 16) {

                            // Continue: resume the timer.
                            Button {
                                taskModel.isTimerRunning = true
                                taskModel.showAfterPauseOptions = false
                            } label: {
                                Text("Continue")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule().fill(Color.black.opacity(0.1))
                                    )
                            }
                            .buttonStyle(.plain)

                            // Modify: open task editing sheet.
                            Button {
                                taskModel.isTimerRunning = false
                                taskModel.showAfterPauseOptions = true
                                taskModelShowingModify = true
                            } label: {
                                Text("Modify")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule().fill(Color.black.opacity(0.1))
                                    )
                            }
                            .buttonStyle(.plain)

                            // Done: treat the task as finished and clear it.
                            Button {
                                // "Done" and "Delete" currently share the same implementation:
                                // they clear the active task and reset the timer state.
                                // Later, you could differentiate them (e.g., Done writes a history record).
                                clearTask()
                            } label: {
                                Text("Done")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule().fill(Color.black.opacity(0.1))
                                    )
                            }
                            .buttonStyle(.plain)

                            // Delete: remove the task and clear it.
                            Button {
                                clearTask()
                            } label: {
                                Text("Delete")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule().fill(Color.black.opacity(0.1))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)
                    }

                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)

            } else {
                // No task state
                VStack(spacing: 16) {
                    Text("No Task for Now")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)

                    NavigationLink(
                        destination: CreateTaskView(taskModel: taskModel, isModifyMode: false)
                    ) {
                        Text("Create")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(Color.black.opacity(0.1)))
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .onReceive(timer) { _ in
            // Only count time when there is a task AND the timer is running.
            // This stops the timer from counting when you paused it.
            guard taskModel.hasActiveTask, taskModel.isTimerRunning else { return }
            taskModel.elapsedSeconds += 1
        }
        .sheet(isPresented: $taskModelShowingModify) {
            CreateTaskView(taskModel: taskModel, isModifyMode: true)
        }
    }

    private func clearTask() {
        // Reset all task + timer state back to the beginning.
        // Putting it in one function avoids repeating the same reset code.
        taskModel.hasActiveTask = false
        taskModel.elapsedSeconds = 0
        taskModel.isTimerRunning = false
        taskModel.showAfterPauseOptions = false
        taskModel.name = ""
        taskModel.details = ""
        taskModel.durationHours = ""
        taskModel.durationMinutes = ""
    }

    private func formattedElapsedTime() -> String {
        // Turn seconds into a readable text like 1m 05s.
        // Example: 65 -> "1m 05s", 3661 -> "1h 01m 01s".
        let seconds = taskModel.elapsedSeconds
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, minutes, secs)
        } else {
            return String(format: "%dm %02ds", minutes, secs)
        }
    }
}

fileprivate extension String {
    /// Helper for the duration text fields.
    /// If the user leaves it blank, we treat it as 0 so the UI does not look broken.
    func ifEmptyReturnZero() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0" : self
    }
}
