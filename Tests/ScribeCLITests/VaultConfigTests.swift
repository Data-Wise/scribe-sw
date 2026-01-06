import XCTest
@testable import ScribeCLI

/// Unit tests for vault configuration models
final class VaultConfigTests: XCTestCase {
    
    // MARK: - GlobalConfig Tests
    
    func testGlobalConfigInitialization() {
        let config = GlobalConfig()
        
        XCTAssertEqual(config.version, "1.0")
        XCTAssertNil(config.currentVault)
        XCTAssertTrue(config.vaults.isEmpty)
    }
    
    func testGlobalConfigEncoding() throws {
        var config = GlobalConfig()
        config.currentVault = "teaching"
        config.vaults["teaching"] = VaultMetadata(
            name: "teaching",
            databasePath: "/path/to/teaching-cli.sqlite",
            rootDirectory: "/Users/test/teaching"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(config)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(GlobalConfig.self, from: data)
        
        XCTAssertEqual(decoded.currentVault, "teaching")
        XCTAssertEqual(decoded.vaults.count, 1)
        XCTAssertEqual(decoded.vaults["teaching"]?.name, "teaching")
    }
    
    // MARK: - VaultConfig Tests
    
    func testVaultConfigInitialization() {
        let vaultInfo = VaultInfo(name: "research", type: "research")
        let config = VaultConfig(vault: vaultInfo)
        
        XCTAssertEqual(config.version, "1.0")
        XCTAssertEqual(config.vault.name, "research")
        XCTAssertEqual(config.vault.type, "research")
    }
    
    func testVaultSettingsDefaults() {
        let settings = VaultSettings()
        
        XCTAssertNil(settings.bibliography)
        XCTAssertNil(settings.citationStyle)
        XCTAssertNil(settings.defaultProject)
        XCTAssertNil(settings.aiContext)
    }
    
    func testVaultSettingsWithValues() {
        let settings = VaultSettings(
            bibliography: "refs.bib",
            citationStyle: "apa",
            aiContext: "Statistics teaching"
        )
        
        XCTAssertEqual(settings.bibliography, "refs.bib")
        XCTAssertEqual(settings.citationStyle, "apa")
        XCTAssertEqual(settings.aiContext, "Statistics teaching")
    }
    
    // MARK: - CLISettings Tests
    
    func testCLISettingsInitialization() {
        let settings = CLISettings(databasePath: "/tmp/test.sqlite")
        
        XCTAssertEqual(settings.version, "1.0")
        XCTAssertEqual(settings.databasePath, "/tmp/test.sqlite")
        XCTAssertNil(settings.editor)
        XCTAssertEqual(settings.defaultFolder, "inbox")
    }
    
    func testCLISettingsWithEditor() {
        let settings = CLISettings(
            databasePath: "/tmp/test.sqlite",
            editor: "nvim"
        )
        
        XCTAssertEqual(settings.editor, "nvim")
    }
    
    func testCLISettingsWithAliases() {
        let aliases = ["q": "quick", "i": "inbox"]
        let settings = CLISettings(
            databasePath: "/tmp/test.sqlite",
            aliases: aliases
        )
        
        XCTAssertEqual(settings.aliases?["q"], "quick")
        XCTAssertEqual(settings.aliases?["i"], "inbox")
    }
    
    // MARK: - VaultContext Tests
    
    func testVaultContextCases() {
        let root = VaultContext.vaultRoot(vault: "teaching")
        let inbox = VaultContext.inbox(vault: "research")
        let project = VaultContext.project(vault: "r-pkg", project: "tidybayes")
        let outside = VaultContext.outside
        
        // Verify cases exist and can be pattern matched
        switch root {
        case .vaultRoot(let vault):
            XCTAssertEqual(vault, "teaching")
        default:
            XCTFail("Expected vaultRoot")
        }
        
        switch inbox {
        case .inbox(let vault):
            XCTAssertEqual(vault, "research")
        default:
            XCTFail("Expected inbox")
        }
        
        switch project {
        case .project(let vault, let proj):
            XCTAssertEqual(vault, "r-pkg")
            XCTAssertEqual(proj, "tidybayes")
        default:
            XCTFail("Expected project")
        }
        
        switch outside {
        case .outside:
            break  // Success
        default:
            XCTFail("Expected outside")
        }
    }
    
    // MARK: - VaultMetadata Tests
    
    func testVaultMetadataInitialization() {
        let metadata = VaultMetadata(
            name: "dev",
            databasePath: "/path/to/dev-cli.sqlite"
        )
        
        XCTAssertEqual(metadata.name, "dev")
        XCTAssertEqual(metadata.databasePath, "/path/to/dev-cli.sqlite")
        XCTAssertNil(metadata.rootDirectory)
        XCTAssertGreaterThan(metadata.createdAt, 0)
    }
    
    func testVaultMetadataWithRootDirectory() {
        let metadata = VaultMetadata(
            name: "dev",
            databasePath: "/path/to/dev-cli.sqlite",
            rootDirectory: "/Users/test/dev"
        )
        
        XCTAssertEqual(metadata.rootDirectory, "/Users/test/dev")
    }
}
