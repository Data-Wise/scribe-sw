# Vault Management Guide

**Scribe CLI - Multi-Vault System**

## Quick Start

```bash
# Create your first vault
scribe-cli vault create research ~/Documents/research research

# List all vaults
scribe-cli vault list

# Create more vaults
scribe-cli vault create teaching ~/Documents/teaching teaching
scribe-cli vault create r-pkg ~/Documents/r-packages r-package

# Switch between vaults
scribe-cli vault switch teaching

# Check where you are
scribe-cli vault context
```

## What is a Vault?

A **vault** is an independent workspace for your notes. Each vault has:

- Its own database (`~/.config/scribe/.scribe-cli/vaults/{name}-cli.sqlite`)
- Its own folder structure (optional)
- Separate projects and inbox
- Independent settings (bibliography, citation style)

**Use cases:**

- `teaching` - Course notes, lecture materials
- `research` - Papers, experiments, data
- `r-pkg` - R package documentation
- `dev` - Development notes, code snippets

## Vault Commands

### Create a Vault

```bash
scribe-cli vault create <name> [path] [type]
```

**Arguments:**

- `name` - Vault name (required)
- `path` - Directory location (optional, defaults to `~/Documents/{name}`)
- `type` - Vault type (optional: `teaching`, `research`, `r-package`, `r-dev`, `generic`)

**Examples:**

```bash
# Minimal - uses defaults
scribe-cli vault create mynotes

# With custom path
scribe-cli vault create research ~/work/research-vault

# With type
scribe-cli vault create teaching ~/Documents/teaching teaching
```

**What happens:**

1. Creates vault directory (if it doesn't exist)
2. Creates `.scribe/` marker directory
3. Generates `vault.json` (shared config)
4. Generates `cli.json` (CLI settings)
5. Creates database file
6. Registers vault in global config

### List Vaults

```bash
scribe-cli vault list
```

Shows all vaults with:

- Current vault indicator (`*`)
- Vault name
- Directory path

**Example output:**

```
📁 Vaults:

* teaching
     /Users/you/Documents/teaching
  research
     /Users/you/Documents/research

✓ Current: teaching
```

### Switch Vaults

```bash
scribe-cli vault switch <name>
```

Changes the active vault. All subsequent commands (create, edit, list) will use the selected vault.

**Example:**

```bash
scribe-cli vault switch research
# Now all note commands affect the research vault
```

### Show Context

```bash
scribe-cli vault context
```

Detects your current location:

- **Outside vault** - Not in any vault directory
- **Vault Root** - In vault's top-level directory
- **Inbox** - In vault's inbox folder
- **Project** - In a project folder (future)

**Example:**

```bash
cd ~/Documents/teaching
scribe-cli vault context
# Output: 📍 Context: Vault Root
#         Vault: teaching
```

### Vault Info

```bash
scribe-cli vault info [name]
```

Shows detailed information about a vault:

- Database location
- Directory path
- Vault type
- Creation date
- Settings (bibliography, citation style)

**Example:**

```bash
scribe-cli vault info teaching
```

### Delete Vault

```bash
scribe-cli vault delete <name>
```

Removes vault from configuration. **Note:** This does NOT delete:

- The database file
- The vault directory
- Your notes

You'll be prompted for confirmation.

## Configuration Files

### Global Config

**Location:** `~/.config/scribe/.scribe-cli/config.json`

**Contains:**

- List of all vaults
- Current active vault
- Global preferences

**Example:**

```json
{
  "version": "1.0",
  "currentVault": "teaching",
  "vaults": {
    "teaching": {
      "name": "teaching",
      "databasePath": "~/.config/scribe/.scribe-cli/vaults/teaching-cli.sqlite",
      "rootDirectory": "/Users/you/Documents/teaching",
      "createdAt": 1704268800
    }
  },
  "preferences": {
    "editor": "micro"
  }
}
```

### Vault Config (Shared)

**Location:** `{vault-root}/.scribe/vault.json`

**Shared by:** CLI and future GUI

**Contains:**

- Vault metadata (name, type, created date)
- Shared settings (bibliography, citation style, AI context)

**Example:**

```json
{
  "version": "1.0",
  "vault": {
    "name": "teaching",
    "created": 1704268800,
    "type": "teaching"
  },
  "settings": {
    "bibliography": "refs.bib",
    "citationStyle": "apa",
    "aiContext": "Statistics teaching materials"
  }
}
```

### CLI Config

**Location:** `{vault-root}/.scribe/cli.json`

**CLI-specific settings**

**Example:**

```json
{
  "version": "1.0",
  "databasePath": "~/.config/scribe/.scribe-cli/vaults/teaching-cli.sqlite",
  "editor": "micro",
  "defaultFolder": "inbox",
  "aliases": {
    "q": "quick"
  }
}
```

## Workflows

### Starting Fresh

```bash
# 1. Create your vaults
scribe-cli vault create teaching ~/Documents/teaching teaching
scribe-cli vault create research ~/Documents/research research

# 2. Start working
scribe-cli vault switch teaching
scribe-cli create "Lecture 1 Notes"
```

### Switching Contexts

```bash
# Morning: Teaching
scribe-cli vault switch teaching
scribe-cli create "Lab Exercise"

# Afternoon: Research
scribe-cli vault switch research
scribe-cli create "Experiment Results"
```

### Directory-Based Work

```bash
# Navigate to vault
cd ~/Documents/teaching

# Check context
scribe-cli vault context
# Shows: Vault Root - teaching

# Work on notes
scribe-cli create "New Topic"
scribe-cli list
```

## Tips

1. **Organize by context** - Use separate vaults for distinctly different areas of work
2. **Use types** - Vault types help organize and configure defaults
3. **Directory optional** - You can have vaults without directories (database-only)
4. **Check context** - Use `vault context` to verify which vault you're working in
5. **List often** - Use `vault list` to see all your vaults and the current one

## Troubleshooting

**Q: How do I know which vault is active?**  
A: Run `scribe-cli vault list` - the current vault has a `*` marker

**Q: Can I rename a vault?**  
A: Not directly. Create a new vault and migrate notes manually.

**Q: What if I delete a vault by accident?**  
A: The database and files are NOT deleted, only the registration. Recreate the vault with the same name and path.

**Q: Can vaults share notes?**  
A: No. Each vault is completely independent. Wiki links don't work cross-vault.

## Next Steps

- **Phase 1:** Inbox and project management →
- **Phase 2:** Tag system
- **Phase 3:** Wiki links and backlinks
- **Phase 4:** Full metadata support

---

**Version:** 0.2.0-cli  
**Updated:** January 2, 2026
