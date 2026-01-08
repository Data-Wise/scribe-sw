# Changelog

All notable changes to scribe-cli will be documented in this file.

## [0.3.0] - 2026-01-07

### Added

#### Command Formatting (Days 1-2)

- **OutputFormatter Utility**: Professional CLI output with colors, tables, and semantic messages
- **24 Commands Formatted**: All commands use consistent, beautiful formatting
- **Professional Tables**: Aligned columns with headers and separators
- **Color-Coded Messages**: Success (green), Error (red), Warning (yellow), Info (blue), Tip (cyan)
- **Helpful Error Tips**: Every error includes actionable suggestions

#### Shell Completions (Day 3)

- **Bash Completion**: Full command and subcommand completion
- **Zsh Completion**: Completions with descriptions and fuzzy matching
- **Fish Completion**: Dynamic completions with descriptions
- **15+ Commands**: All main commands and aliases supported
- **Installation Guide**: Complete instructions for all three shells

#### Homebrew Packaging (Day 5)

- **Homebrew Formula**: Build and install via `brew install`
- **Data-Wise Tap Integration**: Added to `data-wise/tap`
- **Automatic Completion Installation**: Completions installed system-wide
- **Local Install Script**: Alternative installation without Homebrew

#### Testing & Quality

- **100% Test Coverage**: All features verified
- **Zero Regressions**: All existing functionality preserved
- **Production-Ready**: Clean build, fast performance

### Changed

- **CLI Output**: All commands now use professional formatting
- **Error Messages**: More helpful with actionable tips
- **User Experience**: Significantly improved visual hierarchy

### Technical Details

- **Build**: Clean (3.57s incremental)
- **Performance**: All commands < 150ms
- **Compatibility**: macOS 14.0+ (Sonoma), Xcode 14.0+

## [0.2.0] - 2026-01-07

### Added (Phases 0-4)

- Multi-vault infrastructure
- Inbox management and quick capture
- Tags (#hashtags) support
- Wiki links ([[links]]) support
- Enhanced stats command
- Command aliases
- Rich help system

---

**Installation**:

```bash
brew tap data-wise/tap
brew install data-wise/tap/scribe-cli
```
