import SwiftUI

struct NowView: View {
    @ObservedObject var taskModel: TaskModel

    /// Used to show/hide the 'Modify Task' pop-up sheet.
    @State private var taskModelShowingModify: Bool = false

    /// Confirmation for destructive actions after pausing.
    private enum PauseAction: String, Identifiable {
        case done
        case delete
        var id: String { rawValue }
    }

    @State private var pendingPauseAction: PauseAction? = nil

    // Achievements store injected from ContentView
    @EnvironmentObject var achievementsStore: AchievementsStore

    // MARK: - Visual constants (UI only)
    private let themeGreen = Color(hex: "4AF692")
    private let circleSize: CGFloat = 310   // bigger circle
    private let iconGray = Color.gray.opacity(0.78)

    var body: some View {
        VStack(spacing: 0) {

            // Title higher (use space better)
            Text(taskModel.hasActiveTask ? (taskModel.isTimerRunning ? "Task Running" : "Task Paused") : "Now")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.gray.opacity(0.8))
                .padding(.top, 18)
                .padding(.bottom, 10)

            if taskModel.hasActiveTask {

                VStack(spacing: 18) {

                    // Current Task area (same info, just spacing/visual)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Task")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.black.opacity(0.9))

                        Text(taskModel.name.isEmpty ? "Task Detail" : taskModel.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black.opacity(0.85))

                        if !taskModel.details.isEmpty {
                            Text(taskModel.details)
                                .font(.system(size: 13))
                                .foregroundColor(.gray.opacity(0.9))
                                .lineLimit(2)
                        } else {
                            Text("......")
                                .font(.system(size: 13))
                                .foregroundColor(.gray.opacity(0.9))
                        }

                        Text("Planned: \(taskModel.durationHours.ifEmptyReturnZero()) h \(taskModel.durationMinutes.ifEmptyReturnZero()) min")
                            .font(.footnote)
                            .foregroundColor(.gray.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 6)

                    //Bigger main circle + solid #4AF692
                    ZStack {
                        Circle()
                            .fill(themeGreen)
                            .frame(width: circleSize, height: circleSize)
                            .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 10)

                        VStack(spacing: 14) {

                            // Keep label (optional), but subtle so center time dominates
                            Text("Time Studied")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.top, 8)

                            //Studied time near center, white, wider/bolder
                            Text(formattedElapsedTime())
                                .font(.system(size: 34, weight: .heavy, design: .monospaced))
                                .foregroundColor(.white)
                                .kerning(1.2)               // “wider”
                                .padding(.top, 2)

                            //Play/Pause button:
                            // background circle SAME as big circle (not white)
                            // icon gray and prominent
                            Button {
                                if taskModel.isTimerRunning {
                                    taskModel.isTimerRunning = false
                                    taskModel.showAfterPauseOptions = true
                                } else {
                                    taskModel.isTimerRunning = true
                                    taskModel.showAfterPauseOptions = false
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(themeGreen)     // same as background (no white)
                                        .frame(width: 86, height: 86)

                                    Image(systemName: taskModel.isTimerRunning ? "pause.fill" : "play.fill")
                                        .font(.system(size: 40, weight: .heavy))
                                        .foregroundColor(iconGray)
                                }
                                .contentShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 6)
                        }
                        .frame(width: circleSize * 0.86)
                    }
                    .padding(.top, 6)

                    //Keep your pause-options area exactly the same behavior, just spacing is cleaner
                    if taskModel.showAfterPauseOptions {
                        VStack(spacing: 14) {

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
                                    .background(Capsule().fill(Color.black.opacity(0.1)))
                            }
                            .buttonStyle(.plain)

                            Button {
                                pendingPauseAction = .done
                            } label: {
                                Text("Done")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color.black.opacity(0.1)))
                            }
                            .buttonStyle(.plain)

                            Button {
                                pendingPauseAction = .delete
                            } label: {
                                Text("Delete")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color.black.opacity(0.1)))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 6)
                    }

                    Spacer(minLength: 16)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 6)

            } else {

                // Center "No Task for Now" + "Create" both horizontally and vertically
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $taskModelShowingModify) {
            CreateTaskView(taskModel: taskModel, isModifyMode: true)
        }
        .alert(item: $pendingPauseAction) { action in
            let title = action == .done ? "Confirm Done" : "Confirm Delete"
            let message = action == .done
            ? "Mark this task as done? This will clear the current task and timer."
            : "Delete this task? This will clear the current task and timer."

            return Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: .default(Text("Confirm")) {
                    handlePauseAction(action)
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }

    //Write Achievements record THEN clear task (UNCHANGED)
    private func handlePauseAction(_ action: PauseAction) {
        let title = taskModel.name
        let details = taskModel.details

        switch action {
        case .done:
            achievementsStore.addDone(title: title, details: details)
        case .delete:
            achievementsStore.addAbandoned(title: title, details: details)
        }

        clearTask()
    }

    // UNCHANGED
    private func clearTask() {
        taskModel.hasActiveTask = false
        taskModel.elapsedSeconds = 0
        taskModel.isTimerRunning = false
        taskModel.showAfterPauseOptions = false
        taskModel.name = ""
        taskModel.details = ""
        taskModel.durationHours = ""
        taskModel.durationMinutes = ""
    }

    // UNCHANGED (format stays exactly as your existing file)
    private func formattedElapsedTime() -> String {
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
    func ifEmptyReturnZero() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0" : self
    }
}

fileprivate extension Color {
    /// Supports "4AF692" or "#4AF692"
    init(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }

        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
