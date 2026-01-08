---
layout: page
title: Shell Completions
permalink: /completions/
---

# Shell Completions

Tab completion for bash, zsh, and fish.

---

## What are Shell Completions?

Press **TAB** to:

- Complete commands
- Complete subcommands
- See available options
- Speed up typing

**Example**:

```bash
scribe-cli <TAB>
# Shows: list create edit show delete search project vault...

scribe-cli proj<TAB>
# Completes to: scribe-cli project

scribe-cli project <TAB>
# Shows: list create
```

---

## Installation

### Homebrew (Automatic)

Completions install automatically:

```bash
brew install data-wise/tap/scribe-cli
```

**Locations**:

- Bash: `/usr/local/etc/bash_completion.d/`
- Zsh: `/usr/local/share/zsh/site-functions/`
- Fish: `/usr/local/share/fish/vendor_completions.d/`

### Local Install

```bash
bash scripts/install.sh
```

**Locations**:

- Bash: `~/.local/share/bash-completion/completions/`
- Zsh: `~/.zsh/completions/`
- Fish: `~/.config/fish/completions/`

---

## Setup by Shell

### Bash

**Homebrew**: Works automatically

**Local install**: Add to `~/.bashrc` or `~/.bash_profile`:

```bash
source ~/.local/share/bash-completion/completions/scribe-cli
```

**Reload**:

```bash
source ~/.bashrc
```

### Zsh

**Homebrew**: Works automatically

**Local install**: Add to `~/.zshrc`:

```bash
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit
```

**Reload**:

```bash
source ~/.zshrc
```

### Fish

**All methods**: Auto-loads on next shell start

**Manual reload**:

```fish
fish_update_completions
```

---

## Features

### Commands

All main commands complete:

```bash
scribe-cli <TAB>
# list, create, edit, show, delete, search, project, vault, inbox, quick, tags, links, stats, help
```

### Subcommands

Context-aware completion:

```bash
scribe-cli project <TAB>
# list, create

scribe-cli vault <TAB>
# create, list, switch, context, info, delete

scribe-cli tags <TAB>
# list, search, stats
```

### Aliases

All aliases complete:

```bash
scribe-cli ls<TAB>    # → list
scribe-cli proj<TAB>  # → project
scribe-cli st<TAB>    # → stats
```

### Descriptions (Zsh/Fish)

Zsh and Fish show descriptions:

```bash
scribe-cli <TAB>
# list    -- List notes
# create  -- Create new note
# edit    -- Edit existing note
# ...
```

---

## Usage Examples

### Basic Completion

```bash
# Type partial command + TAB
scribe-cli li<TAB>
# Completes to: scribe-cli list

# See all commands
scribe-cli <TAB>
```

### Subcommand Completion

```bash
# Complete subcommands
scribe-cli project <TAB>
# Shows: list create

# Complete vault commands
scribe-cli vault <TAB>
# Shows: create list switch context info delete
```

### Alias Completion

```bash
# Aliases work too
scribe-cli ls<TAB>
# Completes to: scribe-cli list

scribe-cli q<TAB>
# Completes to: scribe-cli quick
```

---

## Troubleshooting

### Bash: Not Working

**Check bash-completion installed**:

```bash
brew install bash-completion@2
```

**Add to ~/.bash_profile**:

```bash
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
```

**Verify**:

```bash
complete -p scribe-cli
```

### Zsh: Not Working

**Check fpath**:

```bash
echo $fpath
# Should include completion directory
```

**Clear cache**:

```bash
rm -f ~/.zcompdump
compinit
```

**Verify in ~/.zshrc**:

```bash
autoload -Uz compinit && compinit
```

### Fish: Not Working

**Check file exists**:

```fish
ls ~/.config/fish/completions/scribe-cli.fish
```

**Reload**:

```fish
fish_update_completions
```

**Restart fish**:

```fish
exec fish
```

---

## Supported Completions

### Commands (15+)

- `list` (`ls`, `l`)
- `create`
- `edit`
- `show`
- `delete` (`rm`, `del`)
- `search`
- `quick` (`q`, `capture`)
- `project` (`proj`, `p`)
- `vault`
- `inbox`
- `tags`
- `links`
- `stats` (`st`)
- `help` (`h`, `?`)

### Subcommands

**project**:

- `list`
- `create`

**vault**:

- `create`
- `list`
- `switch`
- `context`
- `info`
- `delete`

**inbox**:

- `list`
- `move`

**tags**:

- `list`
- `search`
- `stats`

**links**:

- `list`
- `backlinks`
- `orphans`
- `validate`

---

## Advanced

### Fuzzy Matching (Zsh)

Zsh supports fuzzy matching:

```bash
scribe-cli prj<TAB>
# Matches: project

scribe-cli vlt<TAB>
# Matches: vault
```

### Completion Scripts

**Locations**:

- Bash: `completions/scribe-cli.bash`
- Zsh: `completions/_scribe-cli`
- Fish: `completions/scribe-cli.fish`

**Customize**: Edit completion files for custom behavior

---

[← Examples](examples.html) | [Home](index.html)
