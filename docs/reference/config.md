# Configuration

Configuration files and settings for Scribe CLI.

---

## Configuration Hierarchy

Scribe CLI uses a hierarchical configuration system:

1. **Global Config** - `~/.config/scribe/.scribe-cli/config.json`
2. **Vault Config** - `<vault>/.scribe/vault.json`
3. **CLI Config** - `<vault>/.scribe/cli.json`

---

## Global Configuration

**Location**: `~/.config/scribe/.scribe-cli/config.json`

**Purpose**: Stores global settings and vault registry.

**Structure**:

```json
{
  "version": "0.3.0",
  "currentVault": "work",
  "vaults": [
    {
      "name": "work",
      "path": "/Users/username/Documents/work",
      "type": "generic"
    },
    {
      "name": "research",
      "path": "/Users/username/Documents/research",
      "type": "research"
    }
  ]
}
```

**Fields**:

- `version` - CLI version
- `currentVault` - Active vault name
- `vaults` - Array of registered vaults

---

## Vault Configuration

**Location**: `<vault>/.scribe/vault.json`

**Purpose**: Shared configuration between CLI and GUI.

**Structure**:

```json
{
  "name": "work",
  "type": "generic",
  "created": "2026-01-01T00:00:00Z",
  "metadata": {
    "description": "Work notes and projects"
  }
}
```

**Fields**:

- `name` - Vault name
- `type` - Vault type (generic, research, teaching, r-pkg, dev)
- `created` - Creation timestamp
- `metadata` - Custom metadata

---

## CLI Configuration

**Location**: `<vault>/.scribe/cli.json`

**Purpose**: CLI-specific settings.

**Structure**:

```json
{
  "editor": "vim",
  "defaultProject": null,
  "preferences": {
    "listLimit": 20,
    "colorOutput": true
  }
}
```

**Fields**:

- `editor` - Preferred text editor
- `defaultProject` - Default project for new notes
- `preferences` - User preferences

---

## Database Location

**Per-Vault Database**: `~/.config/scribe/.scribe-cli/vaults/<vault-name>-cli.sqlite`

**Schema**:

- `notes` - Note content and metadata
- `projects` - Project definitions
- `tags` - Tag index
- `links` - Wiki link relationships
- `fts_notes` - Full-text search index

---

## Vault Types

### Generic

General-purpose notes with no special features.

### Research

Academic research with paper tracking and literature notes.

### Teaching

Course materials, lecture notes, and student resources.

### R-Package

R package development with function documentation.

### Dev

Software development with code snippets and technical notes.

---

## Environment Variables

### EDITOR

Default text editor for creating and editing notes.

**Default**: `vim`

**Examples**:

```bash
export EDITOR=nano
export EDITOR=code
export EDITOR="subl -w"
```

### SCRIBE_CONFIG

Custom configuration directory.

**Default**: `~/.config/scribe`

**Example**:

```bash
export SCRIBE_CONFIG=~/custom/config
```

---

## Customization

### Editor Configuration

Set your preferred editor:

```bash
# In ~/.zshrc or ~/.bashrc
export EDITOR=nano
```

Or in `<vault>/.scribe/cli.json`:

```json
{
  "editor": "nano"
}
```

### List Limit

Change default number of notes shown:

```json
{
  "preferences": {
    "listLimit": 50
  }
}
```

### Color Output

Disable colored output:

```json
{
  "preferences": {
    "colorOutput": false
  }
}
```

---

## Migration

### From v0.2.x to v0.3.0

No migration needed. Configuration is backward compatible.

### Creating Backups

```bash
# Backup global config
cp ~/.config/scribe/.scribe-cli/config.json ~/backup/

# Backup vault config
cp ~/Documents/work/.scribe/vault.json ~/backup/
```

---

## Troubleshooting

### Config Not Found

If config is missing, Scribe CLI will create default configuration on first run.

### Corrupted Config

Delete and recreate:

```bash
rm ~/.config/scribe/.scribe-cli/config.json
scribe-cli vault list  # Recreates config
```

### Vault Not Registered

Re-register vault:

```bash
scribe-cli vault create work ~/Documents/work generic
```

---

[← Back to Home](../index.md)
