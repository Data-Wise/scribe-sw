---
layout: page
title: Command Reference
permalink: /commands/
---

# Command Reference

Complete reference for all Scribe CLI commands.

---

## Core Commands

### list

List notes in current vault.

```bash
scribe-cli list [count]
scribe-cli ls          # Alias
scribe-cli l           # Alias
```

**Examples**:

```bash
scribe-cli list        # List 20 most recent notes
scribe-cli list 50     # List 50 notes
scribe-cli ls          # Using alias
```

---

### create

Create and edit a new note.

```bash
scribe-cli create <title>
```

**Examples**:

```bash
scribe-cli create "Meeting Notes"
scribe-cli create "Research Ideas"
```

---

### edit

Edit an existing note.

```bash
scribe-cli edit <note-id>
```

**Examples**:

```bash
scribe-cli edit c40974e7
scribe-cli edit c409      # Partial ID works
```

---

### show

Display note content.

```bash
scribe-cli show <note-id>
```

**Examples**:

```bash
scribe-cli show c40974e7
scribe-cli show c409
```

---

### delete

Delete a note.

```bash
scribe-cli delete <note-id>
scribe-cli rm <note-id>     # Alias
scribe-cli del <note-id>    # Alias
```

**Examples**:

```bash
scribe-cli delete c40974e7
scribe-cli rm c409
```

---

### search

Full-text search across all notes.

```bash
scribe-cli search <query>
```

**Examples**:

```bash
scribe-cli search "machine learning"
scribe-cli search python
```

---

## Organization Commands

### quick

Quick capture - create note without opening editor.

```bash
scribe-cli quick <content>
scribe-cli q <content>        # Alias
scribe-cli capture <content>  # Alias
```

**Examples**:

```bash
scribe-cli quick "Remember to review paper #research"
scribe-cli q "Meeting at 2pm #work"
scribe-cli capture "Idea: new feature"
```

---

### project

Manage projects.

```bash
scribe-cli project list
scribe-cli project create <name> [type]

# Aliases
scribe-cli proj list
scribe-cli p list
```

**Project Types**: `research`, `teaching`, `r-pkg`, `dev`, `generic`

**Examples**:

```bash
scribe-cli project list
scribe-cli project create "ML Research" research
scribe-cli proj create "Stats 101" teaching
```

---

### vault

Manage vaults.

```bash
scribe-cli vault create <name> <path> <type>
scribe-cli vault list
scribe-cli vault switch <name>
scribe-cli vault context
scribe-cli vault info
scribe-cli vault delete <name>
```

**Examples**:

```bash
scribe-cli vault create work ~/Documents/work generic
scribe-cli vault list
scribe-cli vault switch work
scribe-cli vault context
```

---

### inbox

Manage inbox notes.

```bash
scribe-cli inbox list
scribe-cli inbox move <note-id> <project-id>
```

**Examples**:

```bash
scribe-cli inbox list
scribe-cli inbox move c409 proj-123
```

---

## Info Commands

### tags

Manage tags.

```bash
scribe-cli tags list
scribe-cli tags search <tag>
scribe-cli tags stats
```

**Examples**:

```bash
scribe-cli tags list
scribe-cli tags search research
scribe-cli tags stats
```

---

### links

Manage wiki links.

```bash
scribe-cli links list <note-id>
scribe-cli links backlinks <note-id>
scribe-cli links orphans
scribe-cli links validate
```

**Examples**:

```bash
scribe-cli links list c409
scribe-cli links backlinks c409
scribe-cli links orphans
scribe-cli links validate
```

---

### stats

Show vault statistics.

```bash
scribe-cli stats
scribe-cli st      # Alias
```

**Output**:

- Total notes, words, characters
- Notes by project
- Writing activity
- Top tags

---

### help

Show help information.

```bash
scribe-cli help [command]
scribe-cli h [command]    # Alias
scribe-cli ?              # Alias
```

**Examples**:

```bash
scribe-cli help
scribe-cli help vault
scribe-cli h project
```

---

## Alias Reference

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `list` | List notes |
| `l` | `list` | List notes (short) |
| `rm` | `delete` | Remove note |
| `del` | `delete` | Delete note |
| `mv` | `inbox move` | Move note |
| `q` | `quick` | Quick capture |
| `capture` | `quick` | Quick capture |
| `h` | `help` | Show help |
| `?` | `help` | Show help |
| `st` | `stats` | Show stats |
| `proj` | `project` | Project commands |
| `p` | `project` | Project (short) |

---

## Global Options

All commands support:

- **Partial IDs**: Use first 4+ characters of note ID
- **Tab Completion**: Press TAB for command/subcommand completion
- **Help**: Add `--help` or use `help <command>`

---

[← Installation](installation.html) | [Vaults →](vaults.html)
