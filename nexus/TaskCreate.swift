import SwiftUI
struct CreateTaskView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var taskModel: TaskModel
    /// `false` means create a new task. `true` means edit the current task.
    /// We reuse the same input fields for both create and edit.
    let isModifyMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            Spacer().frame(height: 40)

            Text(isModifyMode ? "Modify Task" : "Set a Task")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 24)

            // Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                TextField("Task name", text: $taskModel.name)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 24)

            // Details
            VStack(alignment: .leading, spacing: 8) {
                Text("Details")
                TextField("Describe your task", text: $taskModel.details, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 24)

            // Duration (stored as String because TextField works with String).
            // Later, you can validate these and convert them to numbers in your model.
            VStack(alignment: .leading, spacing: 8) {
                Text("Duration")
                HStack(spacing: 12) {
                    TextField("Hours", text: $taskModel.durationHours)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)

                    Text("h")

                    TextField("Minutes", text: $taskModel.durationMinutes)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)

                    Text("min")
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            HStack(spacing: 24) {
                Button {
                    dismiss()
                } label: {
                    Text("Back")
                        .foregroundColor(.green)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.black.opacity(0.1)))
                }
                .buttonStyle(.plain)

                Button {
                    let trimmed = taskModel.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.isEmpty { return }

                    // When you create/edit a task, we update the shared model.
                    // This keeps the 'Now' screen and timer synced without extra 'passing back' code.
                    taskModel.hasActiveTask = true
                    if !isModifyMode {
                        // For a new task, we reset the timer to start fresh.
                        taskModel.elapsedSeconds = 0
                        taskModel.isTimerRunning = true
                        taskModel.showAfterPauseOptions = false
                    }
                    dismiss()
                } label: {
                    Text("Continue")
                        .foregroundColor(.green)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.black.opacity(0.1)))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}
