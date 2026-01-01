import SwiftUI

// MARK: - Color System

/// Scribe color palette - ADHD-friendly dark theme
struct ScribeColors {
    // MARK: - Base Colors
    static let background = Color(hex: "#1e1e1e")      // VSCode dark background
    static let surface = Color(hex: "#252526")         // Slightly lighter surface
    static let border = Color(hex: "#3e3e42")          // Subtle borders
    
    // MARK: - Text Colors
    static let textPrimary = Color(hex: "#d4d4d4")     // Main text (high contrast)
    static let textSecondary = Color(hex: "#858585")   // Metadata, labels
    static let textTertiary = Color(hex: "#6a6a6a")    // Placeholders, hints
    
    // MARK: - Accent Colors
    static let accent = Color(hex: "#007acc")          // Blue - links, focus states
    static let success = Color(hex: "#4ec9b0")         // Green - positive actions
    static let warning = Color(hex: "#ce9178")         // Orange - warnings
    static let error = Color(hex: "#f48771")           // Red - errors
    
    // MARK: - Project Type Colors
    static let research = Color(hex: "#569cd6")        // Blue - research projects
    static let teaching = Color(hex: "#4ec9b0")        // Teal - teaching
    static let rPackage = Color(hex: "#dcdcaa")        // Yellow - R packages
    static let rDev = Color(hex: "#808080")            // Gray - R dev tools
    static let generic = Color(hex: "#c586c0")         // Purple - generic projects
    
    // MARK: - Special Colors
    static let streak = Color(hex: "#ff6b35")          // Flame orange - streak indicator
    static let latex = Color(hex: "#b5cea8")           // Math green - LaTeX elements
    static let wikiLink = Color(hex: "#4ec9b0")        // Teal - wiki links
    static let tag = Color(hex: "#dcdcaa")             // Yellow - tags
}

// MARK: - Typography System

/// Scribe typography - optimized for reading and writing
struct ScribeFonts {
    // MARK: - Editor Fonts (Monospace)
    static let editor = Font.custom("SF Mono", size: 16)
    static let editorLarge = Font.custom("SF Mono", size: 18)
    static let editorSmall = Font.custom("SF Mono", size: 14)
    
    // MARK: - Preview Fonts (Sans-serif)
    static let preview = Font.system(size: 16, design: .default)
    static let previewH1 = Font.system(size: 32, weight: .bold)
    static let previewH2 = Font.system(size: 24, weight: .semibold)
    static let previewH3 = Font.system(size: 20, weight: .semibold)
    
    // MARK: - UI Element Fonts
    static let uiBody = Font.system(size: 13)
    static let uiCaption = Font.system(size: 11)
    static let uiTitle = Font.system(size: 14, weight: .semibold)
    static let uiLarge = Font.system(size: 16, weight: .medium)
    
    // MARK: - Title Font
    static let noteTitle = Font.system(size: 24, weight: .bold, design: .default)
    static let noteTitleLarge = Font.system(size: 32, weight: .bold, design: .default)
    
    // MARK: - Stats Fonts
    static let statsLarge = Font.system(size: 36, weight: .bold, design: .rounded)
    static let statsMedium = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let statsSmall = Font.system(size: 12, weight: .medium, design: .rounded)
}

// MARK: - Spacing System

/// Consistent spacing values
struct ScribeSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Layout Constants

/// Standard layout measurements
struct ScribeLayout {
    static let sidebarWidth: CGFloat = 200
    static let statsFooterHeight: CGFloat = 32
    static let minWindowWidth: CGFloat = 800
    static let minWindowHeight: CGFloat = 600
    static let cornerRadius: CGFloat = 8
}

// Note: Color(hex:) extension is defined in Models/Project.swift
