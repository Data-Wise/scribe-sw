import Foundation

/// Global configuration stored at ~/.config/scribe/.scribe-cli/config.json
struct GlobalConfig: Codable {
    var version: String
    var currentVault: String?
    var vaults: [String: VaultMetadata]
    var preferences: GlobalPreferences
    
    init(
        version: String = "1.0",
        currentVault: String? = nil,
        vaults: [String: VaultMetadata] = [:],
        preferences: GlobalPreferences = GlobalPreferences()
    ) {
        self.version = version
        self.currentVault = currentVault
        self.vaults = vaults
        self.preferences = preferences
    }
}

/// Metadata about a vault stored in global config
struct VaultMetadata: Codable {
    var name: String
    var databasePath: String
    var rootDirectory: String?  // Optional filesystem location
    var createdAt: Int64
    
    init(name: String, databasePath: String, rootDirectory: String? = nil, createdAt: Int64 = Date().unixTimestamp) {
        self.name = name
        self.databasePath = databasePath
        self.rootDirectory = rootDirectory
        self.createdAt = createdAt
    }
}

/// Global preferences
struct GlobalPreferences: Codable {
    var editor: String?
    var defaultVault: String?
    
    init(editor: String? = nil, defaultVault: String? = nil) {
        self.editor = editor
        self.defaultVault = defaultVault
    }
}

/// Extension for global config paths
extension GlobalConfig {
    static var configDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config")
            .appendingPathComponent("scribe")
            .appendingPathComponent(".scribe-cli")
    }
    
    static var configPath: URL {
        configDirectory.appendingPathComponent("config.json")
    }
    
    static var vaultsDirectory:URL {
        configDirectory.appendingPathComponent("vaults")
    }
}
