import Foundation

final class BibTeXService {
    static let shared = BibTeXService()
    
    private init() {}
    
    func parse(content: String) -> [Citation] {
        var citations: [Citation] = []
        
        let entryPattern = #"@(\w+)\s*\{\s*([^,]+),"#
        guard let entryRegex = try? NSRegularExpression(pattern: entryPattern) else {
            return []
        }
        
        let nsContent = content as NSString
        let entries = content.components(separatedBy: "@")
        
        for entry in entries where !entry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let entryContent = "@" + entry
            let nsEntry = entryContent as NSString
            
            if let match = entryRegex.firstMatch(in: entryContent, range: NSRange(location: 0, length: nsEntry.length)) {
                let key = nsEntry.substring(with: match.range(at: 2))
                
                var fields: [String: String] = [:]
                let fieldPattern = #"(\w+)\s*=\s*[\{"](.+?)[\}"]"#
                if let fieldRegex = try? NSRegularExpression(pattern: fieldPattern) {
                    let fieldMatches = fieldRegex.matches(in: entryContent, range: NSRange(location: 0, length: nsEntry.length))
                    for fieldMatch in fieldMatches {
                        let name = nsEntry.substring(with: fieldMatch.range(at: 1)).lowercased()
                        let value = nsEntry.substring(with: fieldMatch.range(at: 2))
                        fields[name] = value
                    }
                }
                
                let citation = Citation(
                    id: key,
                    title: fields["title"] ?? "Unknown Title",
                    author: fields["author"] ?? "Unknown Author",
                    year: fields["year"] ?? "",
                    journal: fields["journal"],
                    booktitle: fields["booktitle"],
                    doi: fields["doi"],
                    url: fields["url"]
                )
                citations.append(citation)
            }
        }
        
        return citations
    }
    
    func loadFromPath(_ path: String) throws -> [Citation] {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        return parse(content: content)
    }
}
