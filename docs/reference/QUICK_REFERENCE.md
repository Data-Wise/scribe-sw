# Scribe CLI - Quick Reference Card

**Version:** 0.2.0-cli | **Cheat Sheet for ADHD-Friendly Note-Taking**

---

## Essential Commands

```bash
# Quick Capture (fastest)
scribe quick "Text with #tags"

# Navigation
scribe pick                  # Smart navigator
scribe vault pick            # Switch vaults

# Notes
scribe list                  # Recent notes
scribe show <id>             # Display note
scribe search "query"        # Find notes

# Tags
scribe tags list             # All tags + counts
scribe tags search <tag>     # Find by tag
scribe tags stats            # Tag analytics
```

---

## Search Filters

```bash
scribe search "text" --tag work        # Filter by tag
scribe search "text" --title-only      # Search titles only
scribe search "keyword"                # Full content
```

---

## Vaults

```bash
scribe vault create <name> <path> <type>
scribe vault list
scribe vault pick            # Interactive
scribe vault switch <name>
scribe vault context
```

---

## Projects

```bash
scribe project create "Name" <type>
scribe project list
```

**Types:** teaching, research, r-package, generic

---

## Shortcuts

| Key | Action |
|-----|--------|
| `v` | List vaults |
| `p` | List projects |
| `i` | Show inbox |
| `n` | List notes |
| `q` | Quit |

---

## Tag Syntax

- **Single:** `#research`
- **Multi-word:** `#causal-inference`
- **Multiple:** `#research #statistics #r-code`

**Case-insensitive:** #Research = #research

---

## Pro Tips

1. **Alias:** `alias s=".build/debug/scribe-cli"`
2. **Partial IDs:** First 5-8 chars work
3. **Auto-tags:** Extracted from content automatically
4. **Vault isolation:** Tags/notes don't cross vaults

---

**One-Page Print & Keep!** 📄
