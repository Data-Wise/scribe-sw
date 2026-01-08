---
layout: page
title: Examples
permalink: /examples/
---

# Examples

Real-world workflows and use cases for Scribe CLI.

---

## Quick Capture Workflow

**Scenario**: Capture thoughts instantly without breaking flow.

```bash
# During a meeting
scribe-cli q "Action item: Review PR #work"
scribe-cli q "Follow up with Sarah about budget #work"

# Reading a paper
scribe-cli q "Interesting approach to feature selection #research #ml"

# Random idea
scribe-cli q "Blog post idea: ADHD-friendly tools"
```

**Review later**:

```bash
scribe-cli inbox list
scribe-cli inbox move <id> <project-id>
```

---

## Research Workflow

**Setup**:

```bash
# Create research vault
scribe-cli vault create research ~/Documents/research generic

# Create projects
scribe-cli project create "ML Paper" research
scribe-cli project create "Literature Review" research
```

**Daily use**:

```bash
# Quick notes while reading
scribe-cli q "Smith et al. (2023) - novel approach to [[attention mechanisms]] #ml #papers"

# Create detailed note
scribe-cli create "Attention Mechanisms Survey"
# Add content with [[wiki links]] and #tags

# Find related notes
scribe-cli tags search ml
scribe-cli links backlinks <note-id>
```

**Weekly review**:

```bash
scribe-cli stats
scribe-cli tags list
scribe-cli links orphans
```

---

## Teaching Workflow

**Setup**:

```bash
# Create teaching vault
scribe-cli vault create teaching ~/Documents/teaching generic

# Create course projects
scribe-cli project create "Stats 101" teaching
scribe-cli project create "R Programming" teaching
```

**Lecture prep**:

```bash
# Capture ideas
scribe-cli q "Example: Central Limit Theorem with dice #stats101"
scribe-cli q "Demo: ggplot2 scatter plots #rprog"

# Create lecture notes
scribe-cli create "Week 3: Hypothesis Testing"
# Link to previous lectures with [[Week 2: Distributions]]

# Review all lecture notes
scribe-cli tags search stats101
scribe-cli project list
```

---

## Multi-Vault Context Switching

**Scenario**: Separate work, research, and personal notes.

```bash
# Morning: Work
scribe-cli vault switch work
scribe-cli q "Sprint planning notes #standup"
scribe-cli inbox list

# Afternoon: Research
scribe-cli vault switch research
scribe-cli search "machine learning"
scribe-cli create "Experiment Results"

# Evening: Personal
scribe-cli vault switch personal
scribe-cli q "Grocery list: milk, eggs #todo"

# Check current context
scribe-cli vault context
```

---

## Tag-Based Organization

**Capture with tags**:

```bash
scribe-cli q "Paper idea: ADHD tools survey #research #paper #adhd"
scribe-cli q "Code review feedback #work #dev"
scribe-cli q "R package update needed #r-pkg #maintenance"
```

**Find by tag**:

```bash
# All research notes
scribe-cli tags search research

# All paper-related notes
scribe-cli tags search paper

# Tag statistics
scribe-cli tags stats
```

**Organize**:

```bash
# List all tags
scribe-cli tags list

# Move tagged notes to projects
scribe-cli inbox list
scribe-cli inbox move <id> <project-id>
```

---

## Wiki Link Knowledge Graph

**Create connected notes**:

```bash
# Main concept note
scribe-cli create "Machine Learning"
# Content: Overview of [[Supervised Learning]] and [[Unsupervised Learning]]

# Detail notes
scribe-cli create "Supervised Learning"
# Content: Includes [[Linear Regression]] and [[Decision Trees]]

# Find connections
scribe-cli links list <ml-note-id>
scribe-cli links backlinks <supervised-note-id>
```

**Discover orphans**:

```bash
scribe-cli links orphans
# Shows notes with no incoming or outgoing links
```

---

## Daily Review Routine

**Morning**:

```bash
# Check inbox
scribe-cli inbox list

# Review yesterday's notes
scribe-cli list 10

# Check stats
scribe-cli stats
```

**Evening**:

```bash
# Triage inbox
scribe-cli inbox list
scribe-cli inbox move <id> <project-id>

# Tag review
scribe-cli tags list
scribe-cli tags search todo
```

**Weekly**:

```bash
# Full stats
scribe-cli stats

# Find orphaned notes
scribe-cli links orphans

# Validate all links
scribe-cli links validate
```

---

## R Package Development

**Setup**:

```bash
scribe-cli vault create r-dev ~/Documents/r-packages generic
scribe-cli project create "mypackage" r-pkg
```

**Development notes**:

```bash
# Feature ideas
scribe-cli q "Add support for [[tidyverse]] syntax #mypackage #feature"

# Bug tracking
scribe-cli q "Fix: Error in plot function when data is NULL #mypackage #bug"

# Documentation notes
scribe-cli create "Function Documentation"
# Link to related functions with [[other_function]]

# Find all package notes
scribe-cli tags search mypackage
scribe-cli project list
```

---

## Search & Discovery

**Full-text search**:

```bash
# Find specific content
scribe-cli search "hypothesis testing"
scribe-cli search "ggplot2"

# Search within tags
scribe-cli tags search research
scribe-cli tags search work
```

**Browse by project**:

```bash
scribe-cli project list
# Shows all projects with note counts
```

**Follow links**:

```bash
# See what links to a note
scribe-cli links backlinks <note-id>

# See what a note links to
scribe-cli links list <note-id>
```

---

[← Organization](organization.html) | [Completions →](completions.html)
