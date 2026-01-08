# Scribe CLI - Commands Cheat Sheet

**Organized by category for quick lookup**

---

## Quick Actions

```bash
scribe quick "<text>"        # Quick capture
scribe pick                  # Smart navigator
scribe list                  # Recent notes
scribe help                  # Show help
```

---

## Notes

```bash
scribe create "<title>"      # Create & edit
scribe edit <id>             # Edit existing
scribe show <id>             # Display
scribe delete <id>           # Remove
scribe list [count]          # List recent (default: 20)
```

---

## Search

```bash
scribe search "<query>"                    # Full-text
scribe search "<query>" --tag <tag>        # Filter by tag
scribe search "<query>" --title-only       # Titles only
scribe search "<query>" --project <id>     # Filter by project
```

---

## Tags

```bash
scribe tags list             # All tags + counts
scribe tags search <tag>     # Find notes with tag
scribe tags stats            # Statistics & analytics
```

---

## Projects

```bash
scribe project list          # All projects
scribe project create "<name>" <type>
```

**Types:** `teaching`, `research`, `r-package`, `generic`

---

## Vaults

```bash
scribe vault list            # All vaults
scribe vault pick            # Interactive picker
scribe vault switch <name>   # Switch vault
scribe vault context         # Show current
scribe vault create <name> <path> <type>
scribe vault info [name]     # Details
scribe vault delete <name>   # Remove
```

---

## Inbox

```bash
scribe inbox list            # Uncategorized notes
scribe inbox move <note-id> <project-id>
```

---

## Navigation Shortcuts

**In `scribe pick`:**

- `v` - List vaults
- `p` - List projects
- `i` - Show inbox
- `n` - List notes
- `q` - Quit
- `1-9` - Select item by number

---

## Common Patterns

### Daily Capture

```bash
scribe quick "Meeting notes #work #meeting"
scribe quick "Research idea #research #ideas"
```

### Find & Review

```bash
scribe tags search research
scribe search "experiment" --tag research
scribe list 10
```

### Organize

```bash
scribe inbox list
scribe inbox move abc123 def456
scribe tags stats
```

### Switch Context

```bash
scribe vault pick           # Choose interactively
scribe vault switch teaching
scribe vault context        # Verify
```

---

**Print & Keep Handy!** 🖨️
