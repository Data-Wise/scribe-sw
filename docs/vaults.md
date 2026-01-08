---
layout: page
title: Vault Management
permalink: /vaults/
---

# Vault Management

Multi-vault support for separate contexts and projects.

---

## What are Vaults?

**Vaults** are separate note collections with their own:

- Database
- Configuration
- Notes and projects
- Tags and links

**Use cases**:

- Separate work and personal notes
- Different research projects
- Teaching vs. research
- Client projects

---

## Creating Vaults

```bash
scribe-cli vault create <name> <path> <type>
```

**Types**: `research`, `teaching`, `r-pkg`, `dev`, `generic`

**Examples**:

```bash
# Work vault
scribe-cli vault create work ~/Documents/work generic

# Research vault
scribe-cli vault create research ~/Documents/research research

# Teaching vault
scribe-cli vault create teaching ~/Documents/teaching teaching
```

**What gets created**:

- Vault directory at specified path
- `.scribe/` folder with configuration
- SQLite database
- Initial setup

---

## Listing Vaults

```bash
scribe-cli vault list
```

**Output**:

```
📁 Vaults
──────────

Name       Location                    Type      
─────────  ──────────────────────────  ────────
work       ~/Documents/work            generic   
research   ~/Documents/research        research  
teaching   ~/Documents/teaching        teaching  

✅ Current: work
```

---

## Switching Vaults

```bash
scribe-cli vault switch <name>
```

**Examples**:

```bash
# Switch to research
scribe-cli vault switch research

# Switch to work
scribe-cli vault switch work
```

**What happens**:

- All commands now operate on new vault
- Context persists across sessions
- Previous vault unchanged

---

## Current Context

Check which vault is active:

```bash
scribe-cli vault context
```

**Output**:

```
📍 Vault Context
────────────────

Current Vault: work
Location: ~/Documents/work
Type: generic
Database: ~/.config/scribe/.scribe-cli/vaults/work-cli.sqlite
```

---

## Vault Info

Get detailed vault information:

```bash
scribe-cli vault info
```

**Output**:

```
📊 Vault: work
──────────────

Location: ~/Documents/work
Type: generic
Database: ~/.config/scribe/.scribe-cli/vaults/work-cli.sqlite

Notes: 42
Projects: 3
Tags: 15
```

---

## Deleting Vaults

```bash
scribe-cli vault delete <name>
```

**Warning**: This removes the vault configuration, not the notes!

**What gets deleted**:

- Vault configuration
- Database
- CLI metadata

**What stays**:

- Your note files in the vault directory
- Vault directory itself

---

## Multi-Vault Workflows

### Context Switching

```bash
# Morning: Work
scribe-cli vault switch work
scribe-cli q "Sprint planning #standup"

# Afternoon: Research
scribe-cli vault switch research
scribe-cli create "Experiment Results"

# Evening: Personal
scribe-cli vault switch personal
scribe-cli q "Grocery list #todo"
```

### Separate Concerns

**Work vault**:

- Client projects
- Meeting notes
- Work tasks

**Research vault**:

- Papers and literature
- Experiment notes
- Research ideas

**Personal vault**:

- Personal projects
- Learning notes
- Todo lists

### Project-Based Vaults

```bash
# One vault per major project
scribe-cli vault create ml-project ~/Projects/ml-research research
scribe-cli vault create stats-course ~/Teaching/stats-101 teaching
scribe-cli vault create r-package ~/Code/mypackage r-pkg
```

---

## Best Practices

### Naming

- **Short names**: Easy to type and switch
- **Descriptive**: Clear purpose
- **Consistent**: Use same naming pattern

**Good**: `work`, `research`, `personal`  
**Avoid**: `my-work-vault-2023`, `temp`, `test`

### Organization

**By context**:

```bash
work      # All work-related
research  # All research
personal  # All personal
```

**By project**:

```bash
ml-research    # Machine learning project
stats-course   # Teaching stats
r-package      # R package development
```

**Hybrid**:

```bash
work           # General work
client-acme    # Specific client
research       # General research
ml-project     # Specific research project
```

### Paths

- Use consistent base directory
- Keep vaults organized
- Use descriptive folder names

**Example structure**:

```
~/Documents/
├── work/           # Work vault
├── research/       # Research vault
├── teaching/       # Teaching vault
└── personal/       # Personal vault
```

---

## Vault Types

### Generic

- General-purpose notes
- No special features
- Most flexible

### Research

- Academic research
- Literature notes
- Experiment tracking

### Teaching

- Course materials
- Lecture notes
- Student resources

### R-Package

- Package development
- Function documentation
- Development notes

### Dev

- Software development
- Code snippets
- Technical notes

---

## Configuration

Vaults store configuration in:

- **Global**: `~/.config/scribe/.scribe-cli/config.json`
- **Per-vault**: `<vault-path>/.scribe/vault.json`

**vault.json** contains:

- Vault name
- Type
- Creation date
- Metadata

---

## Troubleshooting

### "Vault not found"

Check vault list:

```bash
scribe-cli vault list
```

### "No active vault"

Switch to a vault:

```bash
scribe-cli vault switch <name>
```

### "Database error"

Check vault info:

```bash
scribe-cli vault info
```

---

[← Commands](commands.html) | [Organization →](organization.html)
