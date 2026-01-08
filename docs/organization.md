---
layout: page
title: Tags & Links
permalink: /organization/
---

# Organization

Organize notes with tags, wiki links, and projects.

---

## Tags

### Using Tags

Add `#hashtags` anywhere in your notes:

```markdown
Meeting notes from today #work #standup

Research idea about [[machine learning]] #research #ml #ideas
```

Tags are **automatically extracted** and indexed.

### Tag Commands

```bash
# List all tags with counts
scribe-cli tags list

# Find notes with specific tag
scribe-cli tags search research

# Tag statistics
scribe-cli tags stats
```

### Tag Best Practices

**Be consistent**:

- Use lowercase: `#research` not `#Research`
- Use hyphens: `#machine-learning` not `#machine_learning`
- Keep short: `#ml` better than `#machine-learning-notes`

**Common patterns**:

- **Context**: `#work`, `#personal`, `#research`
- **Type**: `#idea`, `#todo`, `#question`, `#note`
- **Topic**: `#ml`, `#stats`, `#r`, `#python`
- **Status**: `#draft`, `#review`, `#done`

**Example tagging**:

```markdown
Paper review: Smith et al. (2023) #research #ml #paper #review

Todo: Update documentation #work #todo #docs

Idea: New feature for package #r-pkg #idea #feature
```

---

## Wiki Links

### Creating Links

Use `[[double brackets]]` to link notes:

```markdown
See [[Machine Learning Basics]] for introduction.

Related: [[Supervised Learning]] and [[Unsupervised Learning]]
```

**With custom text**:

```markdown
Learn about [[machine-learning|ML fundamentals]] first.
```

### Link Commands

```bash
# Show outgoing links from a note
scribe-cli links list <note-id>

# Show backlinks to a note
scribe-cli links backlinks <note-id>

# Find orphaned notes
scribe-cli links orphans

# Validate all links
scribe-cli links validate
```

### Building Knowledge Graphs

**Start with main concepts**:

```markdown
# Machine Learning

Overview of [[Supervised Learning]] and [[Unsupervised Learning]].

Key algorithms:
- [[Linear Regression]]
- [[Decision Trees]]
- [[Neural Networks]]
```

**Create detail notes**:

```markdown
# Supervised Learning

Type of [[Machine Learning]] where...

Examples:
- [[Linear Regression]]
- [[Logistic Regression]]
```

**Find connections**:

```bash
# What links to this note?
scribe-cli links backlinks <ml-note-id>

# What does this note link to?
scribe-cli links list <ml-note-id>
```

---

## Projects

### Creating Projects

```bash
scribe-cli project create <name> [type]
```

**Types**: `research`, `teaching`, `r-pkg`, `dev`, `generic`

**Examples**:

```bash
scribe-cli project create "ML Research" research
scribe-cli project create "Stats 101" teaching
scribe-cli project create "mypackage" r-pkg
```

### Listing Projects

```bash
scribe-cli project list
```

**Output**:

```
📁 Projects (3)
───────────────

ID    Project       Description              Notes
────  ────────────  ───────────────────────  ─────
1     🔬 ML Research  Machine learning study   12
2     📚 Stats 101    Statistics course        8
3     📦 mypackage    R package development    5
```

### Moving Notes to Projects

```bash
# List inbox notes
scribe-cli inbox list

# Move to project
scribe-cli inbox move <note-id> <project-id>
```

---

## Inbox Management

### Quick Capture

Capture thoughts instantly:

```bash
scribe-cli quick "Meeting notes #work"
scribe-cli q "Research idea #ml"
```

Notes go to **inbox** by default.

### Triage Workflow

**Daily**:

```bash
# Review inbox
scribe-cli inbox list

# Move to projects
scribe-cli inbox move <id> <project-id>
```

**Weekly**:

```bash
# Check inbox size
scribe-cli stats

# Process all inbox notes
scribe-cli inbox list
# Move each to appropriate project
```

---

## Organization Workflows

### Tag-Based

**Capture with tags**:

```bash
scribe-cli q "Paper idea #research #paper"
scribe-cli q "Code review #work #dev"
```

**Find by tag**:

```bash
scribe-cli tags search research
scribe-cli tags search paper
```

**Organize**:

```bash
scribe-cli tags list
scribe-cli inbox move <id> <project-id>
```

### Link-Based

**Create connected notes**:

```bash
scribe-cli create "Main Topic"
# Add [[Sub Topic 1]] and [[Sub Topic 2]]

scribe-cli create "Sub Topic 1"
# Links back to [[Main Topic]]
```

**Navigate**:

```bash
scribe-cli links list <main-id>
scribe-cli links backlinks <sub-id>
```

**Maintain**:

```bash
scribe-cli links orphans
scribe-cli links validate
```

### Project-Based

**Create projects**:

```bash
scribe-cli project create "Research" research
scribe-cli project create "Teaching" teaching
```

**Capture to inbox**:

```bash
scribe-cli q "Lecture idea #teaching"
scribe-cli q "Experiment result #research"
```

**Organize later**:

```bash
scribe-cli inbox list
scribe-cli inbox move <id> <project-id>
```

---

## Best Practices

### Tagging

- **Start simple**: 3-5 core tags
- **Add gradually**: New tags as needed
- **Review regularly**: `scribe-cli tags list`
- **Consolidate**: Merge similar tags

### Linking

- **Link early**: Add links while writing
- **Link often**: Connect related ideas
- **Check orphans**: `scribe-cli links orphans`
- **Validate**: `scribe-cli links validate`

### Projects

- **Few projects**: 3-5 active projects
- **Clear names**: Descriptive, unique
- **Regular review**: Move inbox notes
- **Archive old**: Delete completed projects

### Inbox

- **Capture freely**: Don't overthink
- **Process daily**: Review inbox
- **Move quickly**: Don't let inbox grow
- **Tag while capturing**: Easier to organize later

---

## Examples

### Research Workflow

```bash
# Capture while reading
scribe-cli q "Smith et al. - novel approach #research #ml #paper"

# Create detailed note
scribe-cli create "Attention Mechanisms"
# Content with [[related concepts]] and #tags

# Find related
scribe-cli tags search ml
scribe-cli links backlinks <note-id>

# Organize
scribe-cli inbox move <id> <research-project-id>
```

### Teaching Workflow

```bash
# Capture ideas
scribe-cli q "Example: CLT with dice #stats101 #example"

# Create lecture
scribe-cli create "Week 3: Hypothesis Testing"
# Link to [[Week 2: Distributions]]

# Find all lectures
scribe-cli tags search stats101
scribe-cli project list
```

---

[← Vaults](vaults.html) | [Completions →](completions.html)
