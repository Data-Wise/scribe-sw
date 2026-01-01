import SwiftUI

/// Right sidebar with panels (backlinks, tags, properties)
struct RightSidebar: View {
    let note: Note
    @State private var selectedTab: SidebarTab = .backlinks
    
    enum SidebarTab: String, CaseIterable {
        case backlinks = "Backlinks"
        case tags = "Tags"
        case properties = "Properties"
        
        var icon: String {
            switch self {
            case .backlinks: return "link"
            case .tags: return "number"
            case .properties: return "list.bullet"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            Picker("Sidebar Tab", selection: $selectedTab) {
                ForEach(SidebarTab.allCases, id: \.self) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
            
            // Content
            Group {
                switch selectedTab {
                case .backlinks:
                    BacklinksPanel(note: note)
                case .tags:
                    TagsPanel(note: note)
                case .properties:
                    PropertiesPanel(note: note)
                }
            }
            .transition(.opacity)
            .id(selectedTab)
        }
        .frame(width: 300)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

// MARK: - Tags Panel

private struct TagsPanel: View {
    let note: Note
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Label("Tags", systemImage: "number")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 12)
            
            Divider()
            
            if note.tags.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "number.square")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No tags")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(note.tags, id: \.self) { tag in
                            TagRow(tag: tag)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            Spacer()
        }
    }
}

private struct TagRow: View {
    let tag: String
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button {
            // TODO: Filter by tag
        } label: {
            HStack {
                Text(tag)
                    .font(.body)
                Spacer()
                Text("\(tagCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.05))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
    
    private var tagCount: Int {
        appState.tagCounts[tag] ?? 0
    }
}

// MARK: - Properties Panel

private struct PropertiesPanel: View {
    let note: Note
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Label("Properties", systemImage: "list.bullet")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                Divider()
                
                // Essential Metadata Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    PropertyCard(icon: "calendar", label: "Created", value: note.date.formatted(.dateTime.month().day().year().hour().minute()))
                    PropertyCard(icon: "clock.arrow.2.circlepath", label: "Modified", value: note.modifiedDate.formatted(.dateTime.month().day().year().hour().minute()))
                    PropertyCard(icon: "folder", label: "Folder", value: note.folder)
                    PropertyCard(icon: "textformat", label: "Words", value: "\(note.wordCount)")
                }
                .padding(.horizontal, 16)
                
                if note.isDaily || note.isPinned {
                    HStack(spacing: 8) {
                        if note.isDaily {
                            StatusBadge(text: "Daily Note", icon: "calendar.badge.clock", color: .blue)
                        }
                        if note.isPinned {
                            StatusBadge(text: "Pinned", icon: "pin.fill", color: .orange)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Custom properties
                if let properties = note.metadata?.properties, !properties.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Attributes")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
                        ForEach(Array(properties.keys.sorted()), id: \.self) { key in
                            if let value = properties[key] {
                                PropertyRow(label: key, value: value)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color.accentColor.opacity(0.03))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                }
                
                Spacer()
            }
            .padding(.bottom, 20)
        }
    }
}

private struct PropertyCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 11))
                .fontWeight(.medium)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.accentColor.opacity(0.05))
        .cornerRadius(8)
        .accessibilityIdentifier(label)
    }
}

private struct StatusBadge: View {
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        Label(text, systemImage: icon)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(12)
    }
}

private struct PropertyRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

#Preview {
    RightSidebar(note: Note(
        title: "Sample Note",
        content: "This is a #test note with [[links]]",
        metadata: NoteMetadata(
            tags: ["#statistics", "#mediation", "#causal-inference"],
            properties: ["status": "in-progress", "priority": "high"]
        )
    ))
    .environmentObject(AppState(noteService: NoteService(database: DatabaseManager.shared), projectService: ProjectService(database: DatabaseManager.shared)))
    .frame(height: 600)
}
