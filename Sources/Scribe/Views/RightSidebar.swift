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
            switch selectedTab {
            case .backlinks:
                BacklinksPanel(note: note)
            case .tags:
                TagsPanel(note: note)
            case .properties:
                PropertiesPanel(note: note)
            }
        }
        .frame(width: 300)
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
        appState.notes.filter { $0.tags.contains(tag) }.count
    }
}

// MARK: - Properties Panel

private struct PropertiesPanel: View {
    let note: Note
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Label("Properties", systemImage: "list.bullet")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    PropertyRow(label: "Created", value: note.date.formatted(date: .abbreviated, time: .shortened))
                    PropertyRow(label: "Modified", value: note.modifiedDate.formatted(date: .abbreviated, time: .shortened))
                    PropertyRow(label: "Folder", value: note.folder)
                    PropertyRow(label: "Word Count", value: "\(note.wordCount)")
                    PropertyRow(label: "Character Count", value: "\(note.content.count)")
                    
                    if note.isDaily {
                        PropertyRow(label: "Type", value: "Daily Note")
                    }
                    
                    if note.isPinned {
                        PropertyRow(label: "Pinned", value: "Yes")
                    }
                    
                    // Custom properties
                    if let properties = note.metadata?.properties, !properties.isEmpty {
                        Divider()
                        
                        Text("Custom Properties")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        
                        ForEach(Array(properties.keys.sorted()), id: \.self) { key in
                            if let value = properties[key] {
                                PropertyRow(label: key, value: value)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
}

private struct PropertyRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
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
    .environmentObject(AppState())
    .frame(height: 600)
}
