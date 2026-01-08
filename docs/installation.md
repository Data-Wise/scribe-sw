---
layout: page
title: Installation
permalink: /installation/
---

# Installation Guide

Multiple ways to install Scribe CLI on macOS.

---

## Homebrew (Recommended)

The easiest way to install Scribe CLI with automatic shell completion setup.

```bash
# Add the Data-Wise tap
brew tap data-wise/tap

# Install scribe-cli
brew install data-wise/tap/scribe-cli
```

**What gets installed**:

- Binary: `/usr/local/bin/scribe-cli`
- Bash completion: `/usr/local/etc/bash_completion.d/`
- Zsh completion: `/usr/local/share/zsh/site-functions/`
- Fish completion: `/usr/local/share/fish/vendor_completions.d/`

---

## Local Install

Build and install from source to `~/.local/bin`.

```bash
# Clone the repository
git clone https://github.com/Data-Wise/scribe-sw
cd scribe-sw

# Run install script
bash scripts/install.sh
```

**What gets installed**:

- Binary: `~/.local/bin/scribe-cli`
- Bash completion: `~/.local/share/bash-completion/completions/`
- Zsh completion: `~/.zsh/completions/`
- Fish completion: `~/.config/fish/completions/`

**Add to PATH**:

```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
```

---

## Shell Completions

### Bash

Completions install automatically with Homebrew. For local install:

```bash
# Add to ~/.bashrc or ~/.bash_profile
source ~/.local/share/bash-completion/completions/scribe-cli
```

### Zsh

For local install, add to `~/.zshrc`:

```bash
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit
```

### Fish

Completions auto-load on next shell start. No configuration needed!

---

## Verification

Test your installation:

```bash
# Check version
scribe-cli help

# Test completion (type TAB after scribe-cli)
scribe-cli <TAB>

# Create test vault
scribe-cli vault create test ~/Documents/test generic
```

---

## Requirements

- **macOS**: 14.0+ (Sonoma)
- **Xcode**: 14.0+ (for building from source)
- **Homebrew**: For Homebrew installation method

---

## Uninstall

### Homebrew

```bash
brew uninstall scribe-cli
brew untap data-wise/tap  # Optional
```

### Local Install

```bash
bash scripts/uninstall.sh
```

---

## Troubleshooting

### Command not found

Make sure `~/.local/bin` is in your PATH:

```bash
echo $PATH | grep ".local/bin"
```

### Completions not working

**Bash**: Source the completion file manually  
**Zsh**: Clear cache with `rm -f ~/.zcompdump && compinit`  
**Fish**: Run `fish_update_completions`

### Build fails

Ensure Xcode Command Line Tools are installed:

```bash
xcode-select --install
```

---

[← Back to Home](index.html) | [Commands →](commands.html)
