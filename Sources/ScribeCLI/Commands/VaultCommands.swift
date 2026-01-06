import Foundation

/// Vault management commands
enum VaultCommands {
    
    // MARK: - Create Vault
    
    @MainActor
    static func create(name: String, path: String?, type: String?) async throws {
        var globalConfig = try ConfigService.shared.loadGlobalConfig()
        
        // Check if vault already exists
        if globalConfig.vaults[name] != nil {
            throw ConfigError.vaultAlreadyExists(name)
        }
        
        // Determine vault directory
        let vaultDir: String
        if let providedPath = path {
            vaultDir = (providedPath as NSString).expandingTildeInPath
        } else {
            // Default to ~/Documents/{name}
            vaultDir = (FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Documents")
                .appendingPathComponent(name).path)
        }
        
        // Create vault directory if needed
        try FileManager.default.createDirectory(atPath: vaultDir, withIntermediateDirectories: true)
        
        // Create database path
        let dbFileName = "\(name)-cli.sqlite"
        let dbPath = GlobalConfig.vaultsDirectory.appendingPathComponent(dbFileName).path
        
        // Create vault config
        let vaultType = type ?? "generic"
        let vaultInfo = VaultInfo(name: name, type: vaultType)
        let vaultConfig = VaultConfig(vault: vaultInfo, settings: VaultSettings())
        
        // Create CLI settings
        let cliSettings = CLISettings(databasePath: dbPath)
        
        // Save vault configs
        try ConfigService.shared.saveVaultConfig(vaultConfig, cliSettings: cliSettings, toDirectory: vaultDir)
        
        // Add to global config
        let metadata = VaultMetadata(name: name, databasePath: dbPath, rootDirectory: vaultDir)
        globalConfig.vaults[name] = metadata
        
        // Set as current if first vault
        if globalConfig.currentVault == nil {
            globalConfig.currentVault = name
        }
        
        try ConfigService.shared.saveGlobalConfig(globalConfig)
        
        print("✅ Created vault '\(name)'")
        print("   Location: \(vaultDir)")
        print("   Database: \(dbPath)")
        print("   Type: \(vaultType)")
    }
    
    // MARK: - List Vaults
    
    @MainActor
    static func list() async throws {
        let globalConfig = try ConfigService.shared.loadGlobalConfig()
        
        if globalConfig.vaults.isEmpty {
            print("📁 No vaults found")
            print("💡 Create one with: scribe-cli vault create <name>")
            return
        }
        
        print("📁 Vaults:\n")
        for (key, vault) in globalConfig.vaults.sorted(by: { $0.key < $1.key }) {
            let current = (key == globalConfig.currentVault) ? "* " : "  "
            print("\(current)\(vault.name)")
            if let dir = vault.rootDirectory {
                print("     \(dir)")
            }
        }
        
        if let current = globalConfig.currentVault {
            print("\n✓ Current: \(current)")
        }
    }
    
    // MARK: - Switch Vault
    
    @MainActor
    static func switchVault(to name: String) async throws {
        var globalConfig = try ConfigService.shared.loadGlobalConfig()
        
        guard globalConfig.vaults[name] != nil else {
            throw ConfigError.vaultNotFound(name)
        }
        
        globalConfig.currentVault = name
        try ConfigService.shared.saveGlobalConfig(globalConfig)
        
        print("✅ Switched to vault '\(name)'")
    }
    
    // MARK: - Show Context
    
    @MainActor
    static func showContext() async throws {
        let context = ConfigService.shared.detectVaultFromDirectory()
        
        switch context {
        case .vaultRoot(let vault):
            print("📍 Context: Vault Root")
            print("   Vault: \(vault)")
            if let dir = ConfigService.shared.findVaultDirectory() {
                print("   Path: \(dir)")
            }
            
        case .inbox(let vault):
            print("📍 Context: Inbox")
            print("   Vault: \(vault)")
            
        case .project(let vault, let project):
            print("📍 Context: Project")
            print("   Vault: \(vault)")
            print("   Project: \(project)")
            
        case .outside:
            print("📍 Context: Outside any vault")
            
            let globalConfig = try ConfigService.shared.loadGlobalConfig()
            if let current = globalConfig.currentVault {
                print("   Current vault (from config): \(current)")
            } else {
                print("💡 Create a vault with: scribe-cli vault create <name>")
            }
        }
    }
    
    // MARK: - Vault Info
    
    @MainActor
    static func info(name: String?) async throws {
        let globalConfig = try ConfigService.shared.loadGlobalConfig()
        
        let vaultName: String
        if let providedName = name {
            vaultName = providedName
        } else if let current = globalConfig.currentVault {
            vaultName = current
        } else {
            print("❌ No current vault set")
            return
        }
        
        guard let metadata = globalConfig.vaults[vaultName] else {
            throw ConfigError.vaultNotFound(vaultName)
        }
        
        print("📊 Vault: \(metadata.name)")
        print("   Database: \(metadata.databasePath)")
        if let dir = metadata.rootDirectory {
            print("   Directory: \(dir)")
            
            // Load vault config if available
            if let vaultDir = metadata.rootDirectory {
                do {
                    let config = try ConfigService.shared.loadVaultConfig(from: vaultDir)
                    print("   Type: \(config.vault.vault.type)")
                    print("   Created: \(formatDate(config.vault.vault.created))")
                    
                    if let bib = config.vault.settings.bibliography {
                        print("   Bibliography: \(bib)")
                    }
                    if let style = config.vault.settings.citationStyle {
                        print("   Citation Style: \(style)")
                    }
                } catch {
                    // Config not found or couldn't load
                }
            }
        }
        
        print("   Created: \(formatDate(metadata.createdAt))")
        
        // TODO: Show note count, project count, etc. when database integration is added
    }
    
    // MARK: - Delete Vault
    
    @MainActor
    static func delete(name: String, force: Bool = false) async throws {
        var globalConfig = try ConfigService.shared.loadGlobalConfig()
        
        guard let metadata = globalConfig.vaults[name] else {
            throw ConfigError.vaultNotFound(name)
        }
        
        if !force {
            print("⚠️  Delete vault '\(name)'?")
            print("   This will remove the vault configuration.")
            print("   Database and files will NOT be deleted.")
            print("   Continue? (y/N) ", terminator: "")
            
            guard let response = readLine()?.lowercased(), response == "y" else {
                print("Cancelled")
                return
            }
        }
        
        // Remove from global config
        globalConfig.vaults.removeValue(forKey: name)
        
        // If this was current vault, unset it
        if globalConfig.currentVault == name {
            globalConfig.currentVault = globalConfig.vaults.keys.first
        }
        
        try ConfigService.shared.saveGlobalConfig(globalConfig)
        
        print("✅ Removed vault '\(name)' from configuration")
        print("💡 Database at: \(metadata.databasePath)")
        if let dir = metadata.rootDirectory {
            print("💡 Files at: \(dir)")
        }
    }
    
    // MARK: - Helpers
    
    private static func formatDate(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
