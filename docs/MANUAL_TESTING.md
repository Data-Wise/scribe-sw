# Scribe CLI - Manual Testing Guide

**Version:** 0.3.0-cli  
**Date:** 2026-01-05

---

## Setup

```bash
cd /Users/dt/projects/dev-tools/scribe-sw
swift build --product scribe-cli
alias scribe='.build/debug/scribe-cli'
```

---

## Test 1: Help & Commands

```bash
scribe help
```

**✅ Verify:**

- Shows all commands (create, edit, list, search, tags, inbox, quick, project, vault)
- Examples displayed
- Tags command listed

---

## Test 2: Quick Capture with Tags

```bash
scribe quick "Research idea #research #statistics"
scribe quick "Meeting notes #meeting #teaching"
scribe quick "Bug fix #r-package #debugging"
```

**✅ Verify:**

- 3 notes created successfully
- Success messages shown

---

## Test 3: Inbox Management

```bash
scribe inbox
```

**✅ Verify:**

- Lists all uncategorized notes
- Shows partial IDs (8 chars)
- Displays timestamps

---

## Test 4: Tag Listing

```bash
scribe tags list
```

**✅ Verify:**

- Shows all tags: #research, #statistics, #meeting, #teaching, #r-package, #debugging
- Displays note counts
- Sorted by count (descending), then alphabetically

---

## Test 5: Tag Search

```bash
scribe tags search research
scribe tags search RESEARCH  # Test case-insensitive
```

**✅ Verify:**

- Finds notes with #research tag
- Case-insensitive search works
- Shows partial IDs and titles

---

## Test 6: Tag Statistics

```bash
scribe tags stats
```

**✅ Verify:**

- Total tags count
- Notes with tags / total notes
- Average tags per note
- Top 5 tags listed

---

## Test 7: Enhanced Search

```bash
scribe search "research"
scribe search "note" --tag research
scribe search "Meeting" --title-only
```

**✅ Verify:**

- Basic search finds all matches
- Tag filter works
- Title-only filter works
- Tags displayed in results

---

## Test 8: Project Management

```bash
scribe project create "Research" research
scribe project create "Teaching" teaching
scribe project list
```

**✅ Verify:**

- Projects created with correct emojis (🔬, 📚)
- List shows partial IDs
- Descriptions displayed

---

## Test 9: Move Notes

```bash
# Get IDs from inbox and project list
scribe inbox move <note-id> <project-id>
scribe inbox  # Verify note removed
```

**✅ Verify:**

- Note moved successfully
- Removed from inbox
- Success message shown

---

## Test 10: Full Workflow

```bash
# 1. Quick capture
scribe quick "DAG visualization #research #r-package #ggdag"

# 2. List tags
scribe tags list

# 3. Search by tag
scribe tags search research

# 4. Create project
scribe project create "Causal Inference" research

# 5. Move note
scribe inbox move <note-id> <project-id>

# 6. Verify
scribe tags stats
```

**✅ Verify:** Complete workflow executes without errors

---

## Edge Cases

```bash
# Invalid command
scribe invalid-command
# ✅ Shows error + help

# No results
scribe tags search nonexistent
# ✅ Shows "No notes found"

# Empty inbox
scribe inbox
# ✅ Handles gracefully
```

---

## Summary Checklist

- [ ] Help displays correctly
- [ ] Quick capture works
- [ ] Inbox lists notes
- [ ] Tags parsed from content
- [ ] Tag list shows all tags
- [ ] Tag search works (case-insensitive)
- [ ] Tag stats calculate correctly
- [ ] Enhanced search filters work
- [ ] Projects can be created
- [ ] Notes can be moved
- [ ] Full workflow completes
- [ ] Edge cases handled

**All passing = Ready for production** ✅
