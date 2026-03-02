import SwiftUI

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var achievements: AchievementsStore

    @State private var selectedStatus: AchievementStatus = .completed
    @State private var currentPage: Int = 1

    private let pageSize = 7

    var body: some View {
        VStack(spacing: 0) {
            header

            statusSwitcher

            Divider().opacity(0.6)

            listArea

            Divider().opacity(0.6)

            pageBar
        }
        .background(Color.white)
        .onChange(of: selectedStatus) { _ in
            currentPage = 1
        }
        .onAppear {
            currentPage = 1
            selectedStatus = .completed
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Achievements")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white.opacity(0.18)))
                }
                .buttonStyle(.plain)
            }

            Text("Your task records (latest first)")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 18)
        .background(Color.green.opacity(0.75))
    }

    // MARK: - Status Switcher

    private var statusSwitcher: some View {
        HStack(spacing: 10) {
            statusPill(title: "Completed", isOn: selectedStatus == .completed) {
                selectedStatus = .completed
            }
            statusPill(title: "Incomplete", isOn: selectedStatus == .incomplete) {
                selectedStatus = .incomplete
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white)
    }

    private func statusPill(title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isOn ? .black : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(isOn ? Color.black.opacity(0.10) : Color.black.opacity(0.04))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - List + Pagination

    private var listArea: some View {
        let all = achievements.filtered(selectedStatus)
        let totalPages = max(1, Int(ceil(Double(all.count) / Double(pageSize))))
        let safePage = min(max(1, currentPage), totalPages)
        let start = (safePage - 1) * pageSize
        let end = min(start + pageSize, all.count)
        let pageItems = (start < end) ? Array(all[start..<end]) : []

        return ScrollView {
            VStack(spacing: 12) {
                if pageItems.isEmpty {
                    emptyState
                        .padding(.top, 26)
                } else {
                    ForEach(pageItems) { item in
                        recordCard(item)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color.white)
        .onChange(of: all.count) { _ in
            // 如果过滤后页数变少，确保页码合法
            let newTotal = max(1, Int(ceil(Double(all.count) / Double(pageSize))))
            if currentPage > newTotal { currentPage = newTotal }
            if currentPage < 1 { currentPage = 1 }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text(selectedStatus == .completed ? "No completed tasks yet." : "No incomplete tasks yet.")
                .font(.headline)
                .foregroundColor(.gray)

            Text("Finish or abandon a task, and it will appear here permanently.")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.04)))
    }

    private func recordCard(_ item: AchievementRecord) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(alignment: .top) {
                Text(item.title.isEmpty ? "(Untitled Task)" : item.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)

                Spacer()

                Text(statusTag(item.status))
                    .font(.footnote)
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.green.opacity(0.12)))
            }

            if !item.details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(item.details)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Text(metaLine(item))
                .font(.footnote)
                .foregroundColor(.gray.opacity(0.9))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.05))
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                achievements.toggleStatus(recordId: item.id)
            } label: {
                Text(item.status == .completed ? "Mark Incomplete" : "Mark Completed")
            }
            .tint(.green)
        }
    }

    private func statusTag(_ status: AchievementStatus) -> String {
        status == .completed ? "Completed" : "Incomplete"
    }

    private func metaLine(_ item: AchievementRecord) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short

        let time = df.string(from: item.updatedAt)

        switch item.event {
        case .done:
            return "Done at \(time)"
        case .abandoned:
            return "Abandoned at \(time)"
        case .toggled:
            return "Updated at \(time)"
        }
    }

    // MARK: - Page Bar

    private var pageBar: some View {
        let all = achievements.filtered(selectedStatus)
        let totalPages = max(1, Int(ceil(Double(all.count) / Double(pageSize))))

        return VStack(spacing: 10) {
            if totalPages > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(1...totalPages, id: \.self) { p in
                            Button {
                                currentPage = p
                            } label: {
                                Text("\(p)")
                                    .font(.headline)
                                    .foregroundColor(currentPage == p ? .black : .gray)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(currentPage == p ? Color.black.opacity(0.12) : Color.black.opacity(0.05))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            } else {
                Text("Page 1")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 12)
        .background(Color.white)
    }
}
