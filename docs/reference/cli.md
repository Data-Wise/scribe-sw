# CLI Reference

Complete command-line interface reference for Scribe CLI.

---

## Global Options

All commands support these global options:

- `--help`, `-h` - Show help for command
- `--version`, `-v` - Show version information

---

## Command Syntax

```bash
scribe-cli <command> [subcommand] [options] [arguments]
```

---

## Core Commands

### list

List notes in current vault.

**Syntax**:

```bash
scribe-cli list [count]
scribe-cli ls [count]
scribe-cli l [count]
```

**Arguments**:

- `count` - Number of notes to display (default: 20)

**Examples**:

```bash
scribe-cli list
scribe-cli list 50
scribe-cli ls
```

---

### create

Create and edit a new note.

**Syntax**:

```bash
scribe-cli create <title>
```

**Arguments**:

- `title` - Note title (required)

**Examples**:

```bash
scribe-cli create "Meeting Notes"
scribe-cli create "Research Ideas"
```

---

### edit

Edit an existing note.

**Syntax**:

```bash
scribe-cli edit <note-id>
```

**Arguments**:

- `note-id` - Full or partial note ID (required)

**Examples**:

```bash
scribe-cli edit c40974e7
scribe-cli edit c409
```

---

### show

Display note content.

**Syntax**:

```bash
scribe-cli show <note-id>
```

**Arguments**:

- `note-id` - Full or partial note ID (required)

**Examples**:

```bash
scribe-cli show c40974e7
```

---

### delete

Delete a note.

**Syntax**:

```bash
scribe-cli delete <note-id>
scribe-cli rm <note-id>
scribe-cli del <note-id>
```

**Arguments**:

- `note-id` - Full or partial note ID (required)

**Examples**:

```bash
scribe-cli delete c40974e7
scribe-cli rm c409
```

---

### search

Full-text search across all notes.

**Syntax**:

```bash
scribe-cli search <query>
```

**Arguments**:

- `query` - Search query (required)

**Examples**:

```bash
scribe-cli search "machine learning"
scribe-cli search python
```

---

## Organization Commands

### quick

Quick capture without opening editor.

**Syntax**:

```bash
scribe-cli quick <content>
scribe-cli q <content>
scribe-cli capture <content>
```

**Arguments**:

- `content` - Note content (required)

**Examples**:

```bash
scribe-cli quick "Remember to review paper #research"
scribe-cli q "Meeting at 2pm #work"
```

---

### project

Manage projects.

**Syntax**:

```bash
scribe-cli project list
scribe-cli project create <name> [type]
scribe-cli proj list
scribe-cli p list
```

**Subcommands**:

- `list` - List all projects
- `create` - Create new project

**Arguments**:

- `name` - Project name (required for create)
- `type` - Project type: research, teaching, r-pkg, dev, generic (optional)

**Examples**:

```bash
scribe-cli project list
scribe-cli project create "ML Research" research
scribe-cli proj create "Stats 101" teaching
```

---

### vault

Manage vaults.

**Syntax**:

```bash
scribe-cli vault create <name> <path> <type>
scribe-cli vault list
scribe-cli vault switch <name>
scribe-cli vault context
scribe-cli vault info
scribe-cli vault delete <name>
```

**Subcommands**:

- `create` - Create new vault
- `list` - List all vaults
- `switch` - Switch to vault
- `context` - Show current vault
- `info` - Show vault details
- `delete` - Delete vault

**Examples**:

```bash
scribe-cli vault create work ~/Documents/work generic
scribe-cli vault list
scribe-cli vault switch work
```

---

### inbox

Manage inbox notes.

**Syntax**:

```bash
scribe-cli inbox list
scribe-cli inbox move <note-id> <project-id>
```

**Subcommands**:

- `list` - List inbox notes
- `move` - Move note to project

**Examples**:

```bash
scribe-cli inbox list
scribe-cli inbox move c409 proj-123
```

---

## Info Commands

### tags

Manage tags.

**Syntax**:

```bash
scribe-cli tags list
scribe-cli tags search <tag>
scribe-cli tags stats
```

**Subcommands**:

- `list` - List all tags
- `search` - Find notes with tag
- `stats` - Tag statistics

**Examples**:

```bash
scribe-cli tags list
scribe-cli tags search research
scribe-cli tags stats
```

---

### links

Manage wiki links.

**Syntax**:

```bash
scribe-cli links list <note-id>
scribe-cli links backlinks <note-id>
scribe-cli links orphans
scribe-cli links validate
```

**Subcommands**:

- `list` - Show outgoing links
- `backlinks` - Show incoming links
- `orphans` - Find orphaned notes
- `validate` - Validate all links

**Examples**:

```bash
scribe-cli links list c409
scribe-cli links backlinks c409
scribe-cli links orphans
```

---

### stats

Show vault statistics.

**Syntax**:

```bash
scribe-cli stats
scribe-cli st
```

**Output**:

- Total notes, words, characters
- Notes by project
- Writing activity
- Top tags

---

### help

Show help information.

**Syntax**:

```bash
scribe-cli help [command]
scribe-cli h [command]
scribe-cli ?
```

**Examples**:

```bash
scribe-cli help
scribe-cli help vault
scribe-cli h project
```

---

## Exit Codes

- `0` - Success
- `1` - General error
- `2` - Invalid arguments
- `3` - Database error
- `4` - File system error

---

## Environment Variables

- `EDITOR` - Default text editor (default: vim)
- `SCRIBE_CONFIG` - Custom config directory

---

## Configuration Files

- `~/.config/scribe/.scribe-cli/config.json` - Global config
- `<vault>/.scribe/vault.json` - Vault config
- `<vault>/.scribe/cli.json` - CLI-specific config

---

[← Back to Home](../index.md)
