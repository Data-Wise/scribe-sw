import XCTest
import Foundation
@testable import ScribeCLI

/// Unit tests for ConfigService
final class ConfigServiceTests: XCTestCase {
    
    var tempDir: URL!
    var configService: ConfigService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create temporary directory for test configs
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("scribe-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        configService = ConfigService.shared
    }
    
    override func tearDown() async throws {
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDir)
        try await super.tearDown()
    }
    
    // MARK: - Vault Detection Tests
    
    func testFindVaultDirectoryWhenInVault() throws {
        // Create mock vault structure
        let vaultDir = tempDir.appendingPathComponent("test-vault")
        let scribeDir = vaultDir.appendingPathComponent(".scribe")
        try FileManager.default.createDirectory(at: scribeDir, withIntermediateDirectories: true)
        
        // Change to vault directory
        let originalDir = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(vaultDir.path)
        
        defer {
            FileManager.default.changeCurrentDirectoryPath(originalDir)
        }
        
        // Test
        let found = configService.findVaultDirectory()
        XCTAssertNotNil(found)
        XCTAssertTrue(found?.hasSuffix("test-vault") ?? false)
    }
    
    func testFindVaultDirectoryWhenOutside() {
        // Test from root directory
        let originalDir = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath("/tmp")
        
        defer {
            FileManager.default.changeCurrentDirectoryPath(originalDir)
        }
        
        let found = configService.findVaultDirectory()
        XCTAssertNil(found)
    }
    
    func testDetectVaultContextOutside() {
        let originalDir = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath("/tmp")
        
        defer {
            FileManager.default.changeCurrentDirectoryPath(originalDir)
        }
        
        let context = configService.detectVaultFromDirectory()
        
        switch context {
        case .outside:
            break  // Success
        default:
            XCTFail("Expected outside context")
        }
    }
    
    // MARK: - Config Save/Load Tests
    
    func testSaveAndLoadVaultConfig() throws {
        let vaultDir = tempDir.appendingPathComponent("test-vault")
        try FileManager.default.createDirectory(at: vaultDir, withIntermediateDirectories: true)
        
        // Create config
        let vaultInfo = VaultInfo(name: "test", type: "generic")
        let vaultConfig = VaultConfig(vault: vaultInfo, settings: VaultSettings())
        let cliSettings = CLISettings(databasePath: "/tmp/test.sqlite")
        
        // Save
        try configService.saveVaultConfig(vaultConfig, cliSettings: cliSettings, toDirectory: vaultDir.path)
        
        // Verify files exist
        XCTAssertTrue(FileManager.default.fileExists(atPath: vaultDir.appendingPathComponent(".scribe/vault.json").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: vaultDir.appendingPathComponent(".scribe/cli.json").path))
        
        // Load and verify
        let loaded = try configService.loadVaultConfig(from: vaultDir.path)
        XCTAssertEqual(loaded.vault.vault.name, "test")
        XCTAssertEqual(loaded.cli.databasePath, "/tmp/test.sqlite")
    }
    
    func testLoadVaultConfigThrowsWhenMissing() {
        let vaultDir = tempDir.appendingPathComponent("nonexistent")
        
        XCTAssertThrowsError(try configService.loadVaultConfig(from: vaultDir.path)) { error in
            XCTAssertTrue(error is ConfigError)
        }
    }
}
