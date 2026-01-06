import Foundation

/// Local vault configuration stored at {vault-root}/.scribe/vault.json
struct VaultConfig: Codable {
    var version: String
    var vault: VaultInfo
    var settings: VaultSettings
    
    init(
        version: String = "1.0",
        vault: VaultInfo,
        settings: VaultSettings = VaultSettings()
    ) {
        self.version = version
        self.vault = vault
        self.settings = settings
    }
}

/// Vault information (shared by all tools)
struct VaultInfo: Codable {
    var name: String
    var created: Int64
    var type: String  // "teaching", "research", "r-package", "r-dev", "generic"
    
    init(name: String, type: String = "generic", created: Int64 = Date().unixTimestamp) {
        self.name = name
        self.type = type
        self.created = created
    }
}

/// Vault settings (shared by CLI and GUI)
struct VaultSettings: Codable {
    var bibliography: String?
    var citationStyle: String?
    var defaultProject: String?
    var aiContext: String?
    
    init(
        bibliography: String? = nil,
        citationStyle: String? = nil,
        defaultProject: String? = nil,
        aiContext: String? = nil
    ) {
        self.bibliography = bibliography
        self.citationStyle = citationStyle
        self.defaultProject = defaultProject
        self.aiContext = aiContext
    }
}

/// CLI-specific settings stored at {vault-root}/.scribe/cli.json
struct CLISettings: Codable {
    var version: String
    var databasePath: String
    var editor: String?
    var defaultFolder: String?
    var aliases: [String: String]?
    
    init(
        version: String = "1.0",
        databasePath: String,
        editor: String? = nil,
        defaultFolder: String? = "inbox",
        aliases: [String: String]? = nil
    ) {
        self.version = version
        self.databasePath = databasePath
        self.editor = editor
        self.defaultFolder = defaultFolder
        self.aliases = aliases
    }
}

/// Combined vault configuration
struct FullVaultConfig {
    var vault: VaultConfig      // From vault.json
    var cli: CLISettings        // From cli.json
}

/// Vault context detected from filesystem
enum VaultContext {
    case vaultRoot(vault: String)
    case inbox(vault: String)
    case project(vault: String, project: String)
    case outside  // Not in any vault
}
