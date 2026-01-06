import Foundation

/// Service for managing global and vault configurations
class ConfigService {
    static let shared = ConfigService()
    
    private init() {}
    
    // MARK: - Global Config
    
    /// Load or create global configuration
    func loadGlobalConfig() throws -> GlobalConfig {
        let configPath = GlobalConfig.configPath
        
        if FileManager.default.fileExists(atPath: configPath.path) {
            let data = try Data(contentsOf: configPath)
            return try JSONDecoder().decode(GlobalConfig.self, from: data)
        }
        
        // Create default config
        let config = GlobalConfig()
        try saveGlobalConfig(config)
        return config
    }
    
    /// Save global configuration
    func saveGlobalConfig(_ config: GlobalConfig) throws {
        let configDir = GlobalConfig.configDirectory
        try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
        
        let vaultsDir = GlobalConfig.vaultsDirectory
        try FileManager.default.createDirectory(at: vaultsDir, withIntermediateDirectories: true)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        try data.write(to: GlobalConfig.configPath)
    }
    
    // MARK: - Vault Config
    
    /// Load vault configuration from directory
    func loadVaultConfig(from directory: String) throws -> FullVaultConfig {
        let dirURL = URL(fileURLWithPath: directory)
        let scribeDir = dirURL.appendingPathComponent(".scribe")
        
        // Load vault.json
        let vaultPath = scribeDir.appendingPathComponent("vault.json")
        guard FileManager.default.fileExists(atPath: vaultPath.path) else {
            throw ConfigError.vaultConfigNotFound(directory)
        }
        
        let vaultData = try Data(contentsOf: vaultPath)
        let vaultConfig = try JSONDecoder().decode(VaultConfig.self, from: vaultData)
        
        // Load cli.json
        let cliPath = scribeDir.appendingPathComponent("cli.json")
        guard FileManager.default.fileExists(atPath: cliPath.path) else {
            throw ConfigError.cliConfigNotFound(directory)
        }
        
        let cliData = try Data(contentsOf: cliPath)
        let cliSettings = try JSONDecoder().decode(CLISettings.self, from: cliData)
        
        return FullVaultConfig(vault: vaultConfig, cli: cliSettings)
    }
    
    /// Save vault configuration to directory
    func saveVaultConfig(_ config: VaultConfig, cliSettings: CLISettings, toDirectory directory: String) throws {
        let dirURL = URL(fileURLWithPath: directory)
        let scribeDir = dirURL.appendingPathComponent(".scribe")
        
        try FileManager.default.createDirectory(at: scribeDir, withIntermediateDirectories: true)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        // Save vault.json
        let vaultData = try encoder.encode(config)
        try vaultData.write(to: scribeDir.appendingPathComponent("vault.json"))
        
        // Save cli.json
        let cliData = try encoder.encode(cliSettings)
        try cliData.write(to: scribeDir.appendingPathComponent("cli.json"))
    }
    
    // MARK: - Vault Detection
    
    /// Detect vault from current working directory
    func detectVaultFromDirectory() -> VaultContext {
        var currentPath = FileManager.default.currentDirectoryPath
        
        while currentPath != "/" {
            let scribePath = (currentPath as NSString).appendingPathComponent(".scribe")
            
            if FileManager.default.fileExists(atPath: scribePath) {
                // Found vault root
                do {
                    let config = try loadVaultConfig(from: currentPath)
                    let vaultName = config.vault.vault.name
                    
                    // Check if in inbox directory
                    if currentPath.hasSuffix("/inbox") {
                        return .inbox(vault: vaultName)
                    }
                    
                    // Check if in project directory
                    // TODO: Implement project detection
                    
                    return .vaultRoot(vault: vaultName)
                } catch {
                    return .vaultRoot(vault: "unknown")
                }
            }
            
            currentPath = (currentPath as NSString).deletingLastPathComponent
        }
        
        return .outside
    }
    
    /// Find vault directory by walking up from current path
    func findVaultDirectory() -> String? {
        var currentPath = FileManager.default.currentDirectoryPath
        
        while currentPath != "/" {
            let scribePath = (currentPath as NSString).appendingPathComponent(".scribe")
            
            if FileManager.default.fileExists(atPath: scribePath) {
                return currentPath
            }
            
            currentPath = (currentPath as NSString).deletingLastPathComponent
        }
        
        return nil
    }
}

// MARK: - Errors

enum ConfigError: Error, LocalizedError {
    case vaultConfigNotFound(String)
    case cliConfigNotFound(String)
    case invalidConfig(String)
    case vaultAlreadyExists(String)
    case vaultNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .vaultConfigNotFound(let dir):
            return "Vault config not found in \(dir)/.scribe/vault.json"
        case .cliConfigNotFound(let dir):
            return "CLI config not found in \(dir)/.scribe/cli.json"
        case .invalidConfig(let msg):
            return "Invalid configuration: \(msg)"
        case .vaultAlreadyExists(let name):
            return "Vault '\(name)' already exists"
        case .vaultNotFound(let name):
            return "Vault '\(name)' not found"
        }
    }
}
