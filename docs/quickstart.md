# Quick Start

Get started with Scribe CLI in 5 minutes.

---

## 1. Install

=== "Homebrew"

    ```bash
    brew tap data-wise/tap
    brew install scribe-cli
    ```

=== "Local Install"

    ```bash
    git clone https://github.com/Data-Wise/scribe-sw
    cd scribe-sw
    bash scripts/install.sh
    ```

---

## 2. Create Your First Vault

```bash
scribe-cli vault create my-notes ~/Documents/notes generic
```

!!! tip
    Vaults are separate note collections. Start with one, add more later for work/personal/research.

---

## 3. Quick Capture

```bash
scribe-cli quick "My first note #test"
scribe-cli q "Another thought #idea"
```

!!! success
    Notes go to inbox by default. Organize them later!

---

## 4. List Notes

```bash
scribe-cli list
# or
scribe-cli ls
```

---

## 5. Create Detailed Note

```bash
scribe-cli create "My Project Ideas"
```

This opens your default editor. Add content with:

- `#tags` for organization
- `[[wiki links]]` for connections

---

## 6. Organize

```bash
# Create a project
scribe-cli project create "Research" research

# Move notes from inbox
scribe-cli inbox list
scribe-cli inbox move <note-id> <project-id>
```

---

## Next Steps

### Learn More

- [Commands](commands.md) - Full command reference
- [Vaults](vaults.md) - Multi-vault management
- [Organization](organization.md) - Tags & links
- [Examples](examples.md) - Real-world workflows

### Try These

```bash
# Search notes
scribe-cli search "keyword"

# View stats
scribe-cli stats

# List tags
scribe-cli tags list

# Shell completion (press TAB)
scribe-cli <TAB>
```

---

!!! question "Need Help?"
    - Check [Commands](commands.md) for syntax
    - See [Examples](examples.md) for workflows
    - Visit [GitHub Issues](https://github.com/Data-Wise/scribe-sw/issues)
