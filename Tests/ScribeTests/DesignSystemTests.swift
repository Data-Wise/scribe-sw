import XCTest
@testable import Scribe

/// Unit tests for DesignSystem constants
final class DesignSystemTests: XCTestCase {
    
    // MARK: - Colors
    
    func testScribeColorsExist() {
        // Verify all colors are defined and accessible
        XCTAssertNotNil(ScribeColors.background)
        XCTAssertNotNil(ScribeColors.surface)
        XCTAssertNotNil(ScribeColors.textPrimary)
        XCTAssertNotNil(ScribeColors.textSecondary)
        XCTAssertNotNil(ScribeColors.textTertiary)
        XCTAssertNotNil(ScribeColors.accent)
        XCTAssertNotNil(ScribeColors.border)
        XCTAssertNotNil(ScribeColors.success)
        XCTAssertNotNil(ScribeColors.warning)
        XCTAssertNotNil(ScribeColors.error)
        XCTAssertNotNil(ScribeColors.streak)
    }
    
    func testProjectTypeColors() {
        XCTAssertNotNil(ScribeColors.research)
        XCTAssertNotNil(ScribeColors.teaching)
        XCTAssertNotNil(ScribeColors.rPackage)
        XCTAssertNotNil(ScribeColors.rDev)
        XCTAssertNotNil(ScribeColors.generic)
    }
    
    func testSpecialColors() {
        XCTAssertNotNil(ScribeColors.latex)
        XCTAssertNotNil(ScribeColors.wikiLink)
        XCTAssertNotNil(ScribeColors.tag)
    }
    
    // MARK: - Fonts
    
    func testScribeFontsExist() {
        XCTAssertNotNil(ScribeFonts.editor)
        XCTAssertNotNil(ScribeFonts.editorLarge)
        XCTAssertNotNil(ScribeFonts.editorSmall)
        XCTAssertNotNil(ScribeFonts.preview)
        XCTAssertNotNil(ScribeFonts.noteTitle)
        XCTAssertNotNil(ScribeFonts.uiTitle)
        XCTAssertNotNil(ScribeFonts.uiBody)
        XCTAssertNotNil(ScribeFonts.uiCaption)
        XCTAssertNotNil(ScribeFonts.statsLarge)
        XCTAssertNotNil(ScribeFonts.statsSmall)
    }
    
    // MARK: - Spacing
    
    func testScribeSpacingValues() {
        // Verify spacing values are positive and in ascending order
        XCTAssertGreaterThan(ScribeSpacing.xs, 0)
        XCTAssertGreaterThan(ScribeSpacing.sm, ScribeSpacing.xs)
        XCTAssertGreaterThan(ScribeSpacing.md, ScribeSpacing.sm)
        XCTAssertGreaterThan(ScribeSpacing.lg, ScribeSpacing.md)
        XCTAssertGreaterThan(ScribeSpacing.xl, ScribeSpacing.lg)
        XCTAssertGreaterThan(ScribeSpacing.xxl, ScribeSpacing.xl)
    }
    
    // MARK: - Layout
    
    func testScribeLayoutValues() {
        XCTAssertGreaterThan(ScribeLayout.sidebarWidth, 0)
        XCTAssertGreaterThan(ScribeLayout.minWindowWidth, 0)
        XCTAssertGreaterThan(ScribeLayout.minWindowHeight, 0)
        XCTAssertGreaterThan(ScribeLayout.statsFooterHeight, 0)
        XCTAssertGreaterThan(ScribeLayout.cornerRadius, 0)
    }
    
    func testMinWindowSizeIsReasonable() {
        // Min window should be at least 600x400 for usability
        XCTAssertGreaterThanOrEqual(ScribeLayout.minWindowWidth, 600)
        XCTAssertGreaterThanOrEqual(ScribeLayout.minWindowHeight, 400)
    }
    
    func testSidebarWidthIsReasonable() {
        // Sidebar should be between 150-400 for readability
        XCTAssertGreaterThanOrEqual(ScribeLayout.sidebarWidth, 150)
        XCTAssertLessThanOrEqual(ScribeLayout.sidebarWidth, 400)
    }
}
