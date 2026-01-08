# Scribe CLI

<div class="grid cards" markdown>

- :rocket:{ .lg .middle } __Zero Friction__

    ---

    Capture thoughts in < 3 seconds. Quick capture, auto-save, escape hatches.

- :file_folder:{ .lg .middle } __Multi-Vault__

    ---

    Separate work, research, personal. Easy switching, context-aware commands.

- :label:{ .lg .middle } __Smart Organization__

    ---

    Tags, wiki links, projects, backlinks. Build your knowledge graph.

- :mag:{ .lg .middle } __Powerful Search__

    ---

    Full-text search with SQLite FTS5. Find anything instantly.

</div>

---

## Quick Start

```bash
# Install via Homebrew
brew tap data-wise/tap
brew install scribe-cli

# Create your first vault
scribe-cli vault create my-notes ~/Documents/notes generic

# Quick capture
scribe-cli quick "Meeting notes from today #work"

# List notes
scribe-cli list
```

---

## Features

### ADHD-Friendly Design

- __< 3 Second Capture__: Thought → saved before you forget
- __One Thing at a Time__: Single note focus
- __Visible Progress__: Stats show your work

### Professional Output

- __Beautiful Tables__: Aligned, readable
- __Color-Coded__: Success (green), errors (red), tips (cyan)
- __Helpful Tips__: Every error includes next steps

### Shell Completions

- __Bash, Zsh, Fish__: Tab completion for all commands
- __Subcommands__: Complete `project`, `vault`, `tags`, etc.
- __Aliases__: `ls`, `rm`, `mv`, `q`, `st`, and more

---

## Commands

| Command | Description | Aliases |
|---------|-------------|---------|
| `list` | List notes | `ls`, `l` |
| `create` | Create new note | - |
| `quick` | Quick capture | `q`, `capture` |
| `project` | Project management | `proj`, `p` |
| `vault` | Vault management | - |
| `tags` | Tag management | - |
| `links` | Link management | - |
| `stats` | Statistics | `st` |

[See all commands →](commands.md){ .md-button .md-button--primary }

---

## Why Scribe CLI?

!!! success "For ADHD Brains"
    - < 3 second capture
    - One thing at a time
    - Escape hatches
    - Visible progress

!!! info "For Researchers"
    - Multi-vault support
    - Wiki links & knowledge graphs
    - Tags & flexible categorization
    - Full-text search

!!! tip "For Everyone"
    - Beautiful output
    - Shell completions
    - Zero config
    - Open source (MIT)

---

## Requirements

- __macOS__: 14.0+ (Sonoma)
- __Xcode__: 14.0+ (for building from source)
- __Homebrew__: For easy installation

---

## Links

- [GitHub Repository](https://github.com/Data-Wise/scribe-sw)
- [Issue Tracker](https://github.com/Data-Wise/scribe-sw/issues)
- [Changelog](CHANGELOG.md)
- [Data-Wise Homebrew Tap](https://github.com/Data-Wise/homebrew-tap)

---

__Version__: 0.3.0 | __License__: MIT | __Maintained by__: [Data-Wise](https://github.com/Data-Wise)
