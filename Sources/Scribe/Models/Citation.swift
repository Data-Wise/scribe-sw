import Foundation
import GRDB
import SwiftUI

struct Citation: Codable, FetchableRecord, PersistableRecord, Identifiable, Sendable {
    var id: String // BibTeX key
    var title: String
    var author: String
    var year: String
    var journal: String?
    var booktitle: String?
    var doi: String?
    var url: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, author, year, journal, booktitle, doi, url
    }
    
    static let databaseTableName = "citations"
    
    enum Columns {
        static let id = Column("id")
        static let title = Column("title")
        static let author = Column("author")
        static let year = Column("year")
        static let journal = Column("journal")
        static let booktitle = Column("booktitle")
        static let doi = Column("doi")
        static let url = Column("url")
    }
    
    var subtitle: String {
        var parts: [String] = []
        if !author.isEmpty { parts.append(author) }
        if !year.isEmpty { parts.append(year) }
        return parts.joined(separator: ", ")
    }
    
    var apaCitation: String {
        var parts: [String] = []
        if !author.isEmpty { parts.append(author + ".") }
        if !year.isEmpty { parts.append("(" + year + ").") }
        if !title.isEmpty { parts.append(title + ".") }
        if let journal = journal { parts.append(journal + ".") }
        return parts.joined(separator: " ")
    }
}
