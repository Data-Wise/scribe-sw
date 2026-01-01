import Testing
@testable import Scribe
import Foundation

@Suite("Model Tests")
struct ModelTests {
    @Test("Note initialization")
    func noteInit() {
        let note = Note(
            id: "test-id",
            projectId: nil,
            title: "Test Note",
            content: "Content",
            folder: "inbox",
            wordCount: 2
        )
        
        #expect(note.id == "test-id")
        #expect(note.title == "Test Note")
        #expect(note.content == "Content")
        #expect(note.wordCount == 2)
    }
    
    @Test("Note deleted status")
    func noteDeleted() {
        let note = Note(
            title: "Test",
            content: "",
            deletedAt: Date().unixTimestamp
        )
        #expect(note.isDeleted == true)
    }
    
    @Test("Note not deleted status")
    func noteNotDeleted() {
        let note = Note(title: "Test", content: "")
        #expect(note.isDeleted == false)
    }
    
    @Test("Note word count calculation")
    func noteWordCount() {
        let note = Note(
            title: "Test",
            content: "Hello world this is a test"
        )
        #expect(note.calculateWordCount() == 6)
    }
    
    @Test("Note word count ignores code blocks")
    func noteWordCountIgnoresCode() {
        let note = Note(
            title: "Test",
            content: """
            ```swift
            let code = "word"
            ```
            Hello world
            """
        )
        #expect(note.calculateWordCount() == 2)
    }
    
    @Test("Project type display names")
    func projectTypeDisplayNames() {
        #expect(ProjectType.research.displayName == "Research")
        #expect(ProjectType.teaching.displayName == "Teaching")
        #expect(ProjectType.rPackage.displayName == "R Package")
        #expect(ProjectType.rDev.displayName == "R Dev")
        #expect(ProjectType.generic.displayName == "Generic")
    }
    
    @Test("Project type emojis")
    func projectTypeEmojis() {
        #expect(ProjectType.research.emoji == "🔬")
        #expect(ProjectType.teaching.emoji == "📚")
        #expect(ProjectType.rPackage.emoji == "📦")
        #expect(ProjectType.rDev.emoji == "🛠️")
        #expect(ProjectType.generic.emoji == "📁")
    }
    
    @Test("Project type default colors")
    func projectTypeDefaultColors() {
        #expect(ProjectType.research.defaultColor == "#3b82f6")
        #expect(ProjectType.teaching.defaultColor == "#10b981")
        #expect(ProjectType.rPackage.defaultColor == "#f59e0b")
        #expect(ProjectType.rDev.defaultColor == "#6b7280")
        #expect(ProjectType.generic.defaultColor == "#8b5cf6")
    }
    
    @Test("NoteMetadata initialization")
    func noteMetadataInit() {
        let metadata = NoteMetadata(
            tags: ["#test", "#demo"],
            aliases: ["alias"],
            isDaily: true,
            isPinned: false
        )
        
        #expect(metadata.tags == ["#test", "#demo"])
        #expect(metadata.aliases == ["alias"])
        #expect(metadata.isDaily == true)
        #expect(metadata.isPinned == false)
    }
    
    @Test("ProjectSettings initialization")
    func projectSettingsInit() {
        let settings = ProjectSettings(
            bibliography: "test.bib",
            citationStyle: "mla",
            aiContext: "context"
        )
        
        #expect(settings.bibliography == "test.bib")
        #expect(settings.citationStyle == "mla")
        #expect(settings.aiContext == "context")
    }
    
    @Test("Link type display names")
    func linkTypeDisplayNames() {
        #expect(LinkType.wiki.displayName == "Wiki Link")
        #expect(LinkType.cite.displayName == "Citation")
        #expect(LinkType.embed.displayName == "Embed")
    }
    
    @Test("Link initialization")
    func linkInit() {
        let link = Link(
            sourceNoteId: "source-1",
            targetNoteId: "target-1",
            linkType: .wiki
        )
        
        #expect(link.sourceNoteId == "source-1")
        #expect(link.targetNoteId == "target-1")
        #expect(link.linkType == .wiki)
    }
    
    @Test("Tag initialization")
    func tagInit() {
        let tag = Tag(
            name: "#test",
            color: "#ff0000"
        )
        
        #expect(tag.name == "#test")
        #expect(tag.color == "#ff0000")
    }
    
    @Test("Citation APA formatting")
    func citationAPA() {
        let citation = Citation(
            id: "smith2023",
            title: "Test Paper",
            author: "Smith, J.",
            year: "2023",
            journal: "Journal of Testing"
        )
        
        let apa = citation.apaCitation
        #expect(apa.contains("Smith, J."))
        #expect(apa.contains("(2023)"))
        #expect(apa.contains("Test Paper"))
    }
    
    @Test("Date unix timestamp conversion")
    func dateUnixTimestamp() {
        let date = Date(timeIntervalSince1970: 946684800) // 2000-01-01
        let timestamp = date.unixTimestamp
        #expect(timestamp == 946684800)
        
        let date2 = Date(unixTimestamp: timestamp)
        #expect(abs(date2.timeIntervalSince(date)) < 1) // Within 1 second
    }
}
