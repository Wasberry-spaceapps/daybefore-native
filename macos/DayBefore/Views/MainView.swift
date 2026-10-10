import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var db = DatabaseService.shared

    @State private var activeType: String?
    @State private var activeId: String?
    @State private var editorContent = ""
    @State private var editorTitle = ""

    @State private var journalCollapsed = false
    @State private var coreCollapsed = false
    @State private var issuesCollapsed = false

    @State private var newCoreName: String?
    @State private var newIssueName: String?

    @State private var pendingDelete: (type: String, id: String, label: String)?
    @State private var deleteTimer: Timer?

    var body: some View {
        HSplitView {
            sidebar
                .frame(minWidth: 250, maxWidth: 300)

            editor
                .frame(minWidth: 400)
        }
        .background(Color(red: 0.07, green: 0.06, blue: 0.05))
        .overlay(alignment: .bottom) {
            if let pending = pendingDelete {
                HStack {
                    Text("Deleting \"\(pending.label)\"...")
                        .foregroundColor(.secondary)
                    Button("Undo") {
                        deleteTimer?.invalidate()
                        pendingDelete = nil
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.primary)
                }
                .padding()
                .background(Color(white: 0.1))
                .cornerRadius(8)
                .padding()
            }
        }
    }

    var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Day Before")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Spacer()
                Button("New Entry") {
                    let entry = JournalEntry()
                    db.saveJournalEntry(entry)
                    openEntry(type: "journal", id: entry.id, content: "", title: entry.displayDate)
                }
                .buttonStyle(.plain)
                .fontWeight(.bold)
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionView(
                        title: "JOURNAL HISTORY",
                        collapsed: $journalCollapsed
                    ) {
                        ForEach(db.journalEntries) { entry in
                            EntryRow(
                                title: entry.displayDate,
                                subtitle: entry.snippet,
                                isActive: activeType == "journal" && activeId == entry.id
                            ) {
                                openEntry(type: "journal", id: entry.id, content: entry.content, title: entry.displayDate)
                            }
                        }
                    }

                    SectionView(
                        title: "CORE POINTS",
                        collapsed: $coreCollapsed,
                        showAdd: true,
                        onAdd: { newCoreName = "" }
                    ) {
                        if newCoreName != nil {
                            TextField("Name...", text: Binding(
                                get: { newCoreName ?? "" },
                                set: { newCoreName = $0 }
                            ))
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color(white: 0.15))
                            .cornerRadius(4)
                            .onSubmit {
                                if let name = newCoreName, !name.isEmpty {
                                    let point = CorePoint(name: name)
                                    db.saveCorePoint(point)
                                    openEntry(type: "core", id: point.id, content: "", title: name)
                                }
                                newCoreName = nil
                            }
                        }

                        ForEach(db.corePoints) { point in
                            EntryRow(
                                title: point.name,
                                subtitle: point.snippet,
                                isActive: activeType == "core" && activeId == point.id
                            ) {
                                openEntry(type: "core", id: point.id, content: point.content, title: point.name)
                            }
                        }
                    }

                    SectionView(
                        title: "ISSUES",
                        collapsed: $issuesCollapsed,
                        showAdd: true,
                        onAdd: { newIssueName = "" }
                    ) {
                        if newIssueName != nil {
                            TextField("Issue name...", text: Binding(
                                get: { newIssueName ?? "" },
                                set: { newIssueName = $0 }
                            ))
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color(white: 0.15))
                            .cornerRadius(4)
                            .onSubmit {
                                if let name = newIssueName, !name.isEmpty {
                                    let issue = Issue(name: name)
                                    db.saveIssue(issue)
                                    openEntry(type: "issue", id: issue.id, content: "", title: name)
                                }
                                newIssueName = nil
                            }
                        }

                        ForEach(db.issues) { issue in
                            EntryRow(
                                title: issue.name,
                                subtitle: issue.snippet,
                                isActive: activeType == "issue" && activeId == issue.id
                            ) {
                                openEntry(type: "issue", id: issue.id, content: issue.content ?? "", title: issue.name)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Button("Manage Subscription") {
                    Task {
                        if let token = SettingsService.shared.token {
                            if let url = try? await ApiService.shared.getPortalUrl(token: token),
                               let portalURL = URL(string: url) {
                                NSWorkspace.shared.open(portalURL)
                            } else if let mailURL = URL(string: "mailto:mutairuwasiu929@gmail.com?subject=Cancel%20Subscription") {
                                NSWorkspace.shared.open(mailURL)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.caption)

                Button("Log Out") {
                    SettingsService.shared.clear()
                    appState.isLoggedIn = false
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.caption)
            }
            .padding()
        }
        .background(Color(red: 0.07, green: 0.06, blue: 0.05))
    }

    var editor: some View {
        VStack(alignment: .leading, spacing: 0) {
            if activeId != nil {
                HStack {
                    if activeType == "journal" {
                        Text(editorTitle.replacingOccurrences(of: " ", with: "_") + ".md")
                    } else {
                        TextField("Title", text: $editorTitle)
                            .textFieldStyle(.plain)
                            .fontWeight(.bold)
                            .onChange(of: editorTitle) { _ in saveContent() }
                    }

                    Spacer()

                    Text("Autosaved")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    Button("Delete") {
                        triggerDelete()
                    }
                    .buttonStyle(.plain)
                }
                .padding()

                TextEditor(text: $editorContent)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.horizontal)
                    .onChange(of: editorContent) { _ in saveContent() }
            } else {
                VStack {
                    Spacer()
                    Button("+ Create New Entry") {
                        let entry = JournalEntry()
                        db.saveJournalEntry(entry)
                        openEntry(type: "journal", id: entry.id, content: "", title: entry.displayDate)
                    }
                    .buttonStyle(.plain)
                    .font(.title3)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color(red: 0.07, green: 0.06, blue: 0.05))
    }

    func openEntry(type: String, id: String, content: String, title: String) {
        activeType = type
        activeId = id
        editorContent = content
        editorTitle = title
    }

    func saveContent() {
        guard let id = activeId, let type = activeType else { return }
        let now = Int64(Date().timeIntervalSince1970 * 1000)

        switch type {
        case "journal":
            if let entry = db.journalEntries.first(where: { $0.id == id }) {
                var updated = entry
                updated.content = editorContent
                updated.updatedAt = now
                db.saveJournalEntry(updated)
            }
        case "core":
            if let point = db.corePoints.first(where: { $0.id == id }) {
                var updated = point
                updated.content = editorContent
                updated.name = editorTitle
                updated.updatedAt = now
                db.saveCorePoint(updated)
            }
        case "issue":
            if let issue = db.issues.first(where: { $0.id == id }) {
                var updated = issue
                updated.content = editorContent
                updated.name = editorTitle
                updated.updatedAt = now
                db.saveIssue(updated)
            }
        default:
            break
        }
    }

    func triggerDelete() {
        guard let type = activeType, let id = activeId else { return }
        let label = editorTitle

        pendingDelete = (type, id, label)
        activeType = nil
        activeId = nil

        deleteTimer?.invalidate()
        deleteTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            switch type {
            case "journal": db.deleteJournalEntry(id)
            case "core": db.deleteCorePoint(id)
            case "issue": db.deleteIssue(id)
            default: break
            }
            pendingDelete = nil
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    @Binding var collapsed: Bool
    var showAdd: Bool = false
    var onAdd: () -> Void = {}
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                if showAdd {
                    Button("+") { onAdd() }
                        .buttonStyle(.plain)
                }
                Button(collapsed ? "show" : "hide") {
                    collapsed.toggle()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.caption)
            }

            if !collapsed {
                content
            }
        }
    }
}

struct EntryRow: View {
    let title: String
    let subtitle: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(isActive ? .bold : .regular)
                    .foregroundColor(isActive ? .primary : .secondary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(isActive ? Color(white: 0.15) : Color.clear)
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}
