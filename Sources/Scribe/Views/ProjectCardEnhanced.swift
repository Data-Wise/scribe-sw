import SwiftUI

/// Enhanced project card with context menu and stats
struct ProjectCardEnhanced: View {
    @EnvironmentObject var appState: AppState
    let project: Project
    var onEdit: () -> Void
    var onArchive: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        Button {
            appState.selectedProjectId = project.id
        } label: {
            card
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Edit Project", systemImage: "pencil")
            }
            
            Button {
                onArchive()
            } label: {
                Label("Archive", systemImage: "archivebox")
            }
            
            Divider()
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var card: some View {
        HStack(spacing: 12) {
            // Color indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(project.type.swiftuiColor)
                .frame(width: 4, height: 24)
            
            // Project info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(project.type.emoji)
                    Text(project.name)
                        .font(.body.bold())
                        .foregroundColor(.primary)
                    
                    if let description = project.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Note count
                if noteCount > 0 {
                    Text("\(noteCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            if noteCount > 0 || wordCount > 0 {
                Divider()
                
                // Stats
                HStack(spacing: 16) {
                    StatItem(icon: "doc.text", value: "\(noteCount)", label: "pages")
                    StatItem(icon: "word.count", value: "\(wordCount)", label: "words")
                    
                    Spacer()
                    
                    // Last edited
                    Text(project.modifiedDate.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            appState.selectedProjectId == project.id ? Color.accentColor.opacity(0.05) : Color.clear
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var noteCount: Int {
        appState.notes.filter { $0.projectId == project.id }.count
    }
    
    private var wordCount: Int {
        appState.notes
            .filter { $0.projectId == project.id }
            .reduce(0) { $0 + $1.wordCount }
    }
}

private struct StatItem: View {
    let icon: String
    let value: String
    let label: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
                
                if let label = label {
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
