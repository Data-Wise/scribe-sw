import XCTest

final class ScribeUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testSidebarTabSwitching() throws {
        // Find Right Sidebar Tab Picker
        let picker = app.segmentedControls["Sidebar Tab"]
        XCTAssertTrue(picker.exists, "Right sidebar tab picker should exist")
        
        // Switch to Tags
        picker.buttons["Tags"].click()
        XCTAssertTrue(app.staticTexts["Tags"].exists, "Tags panel should be visible")
        
        // Switch to Properties
        picker.buttons["Properties"].click()
        XCTAssertTrue(app.staticTexts["Properties"].exists, "Properties panel should be visible")
        
        // Switch back to Backlinks
        picker.buttons["Backlinks"].click()
        XCTAssertTrue(app.staticTexts["Backlinks"].exists, "Backlinks panel should be visible")
    }

    func testEditorModeSwitching() throws {
        // Test ⌘1 (Markdown)
        app.typeKey("1", modifierFlags: .command)
        XCTAssertTrue(app.staticTexts["Markdown"].exists || app.buttons["Markdown"].isSelected, "Markdown mode should be active")
        
        // Test ⌘2 (Live Edit)
        app.typeKey("2", modifierFlags: .command)
        XCTAssertTrue(app.staticTexts["Live Edit"].exists || app.buttons["Live Edit"].isSelected, "Live Edit mode should be active")
        
        // Test ⌘3 (Preview)
        app.typeKey("3", modifierFlags: .command)
        XCTAssertTrue(app.staticTexts["Preview"].exists || app.buttons["Preview"].isSelected, "Preview mode should be active")
    }

    func testPropertyGridVisibility() throws {
        // Navigate to Properties tab
        let picker = app.segmentedControls["Sidebar Tab"]
        picker.buttons["Properties"].click()
        
        // Verify core properties are visible in the grid
        XCTAssertTrue(app.staticTexts["Folder"].exists, "Folder property should be visible")
        XCTAssertTrue(app.staticTexts["Created"].exists, "Created date should be visible")
        XCTAssertTrue(app.staticTexts["Modified"].exists, "Modified date should be visible")
    }

    func testSidebarToggle() throws {
        let sidebar = app.otherElements["Right Sidebar"] // Assuming we added an accessibility identifier
        let initialExists = sidebar.exists
        
        // Toggle off ⌘⌥R
        app.typeKey("r", modifierFlags: [.command, .option])
        XCTAssertNotEqual(sidebar.exists, initialExists, "Sidebar visibility should change after toggle")
        
        // Toggle back on
        app.typeKey("r", modifierFlags: [.command, .option])
        XCTAssertEqual(sidebar.exists, initialExists, "Sidebar should return to original visibility")
    }

    func testCommandPaletteTrigger() throws {
        // Trigger ⌘K
        app.typeKey("k", modifierFlags: .command)
        
        // Check if palette exists
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 2), "Command palette should appear")
        
        // Escape to close
        app.typeKey(.escape, modifierFlags: [])
        XCTAssertFalse(searchField.exists, "Command palette should close on Escape")
    }

    func testQuickCaptureTrigger() throws {
        // Trigger ⌘⇧C
        app.typeKey("c", modifierFlags: [.command, .shift])
        
        // Check for Quick Capture window/sheet
        XCTAssertTrue(app.staticTexts["Quick Capture"].exists, "Quick Capture sheet should be visible")
        
        // Close
        app.buttons["Cancel"].click()
    }
}
