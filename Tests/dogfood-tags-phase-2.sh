#!/bin/bash
# Dogfooding test for Tags Phase 2
# Simulates real academic workflow with tags

set -e

echo "🐕 Tags Phase 2 Dogfooding Test"
echo "================================"
echo ""

# Build CLI
echo "📦 Building CLI..."
swift build --product scribe-cli > /dev/null 2>&1
CLI=".build/debug/scribe-cli"
echo "✅ CLI built"
echo ""

# Scenario 1: Research notes with tags
echo "📝 Scenario 1: Research Notes"
echo "-----------------------------"
$CLI quick "Review Pearl's causality book #research #causal-inference #reading"
$CLI quick "Implement DAG visualization #research #r-package #ggdag"
$CLI quick "Write methods section #research #paper #statistics"
echo "✅ Created 3 research notes"
echo ""

# Scenario 2: Teaching notes
echo "📚 Scenario 2: Teaching Notes"
echo "-----------------------------"
$CLI quick "Prepare STAT 501 lecture #teaching #lecture #regression"
$CLI quick "Grade homework assignments #teaching #grading"
$CLI quick "Office hours prep #teaching #student-questions"
echo "✅ Created 3 teaching notes"
echo ""

# Scenario 3: R package development
echo "📦 Scenario 3: R Package Notes"
echo "------------------------------"
$CLI quick "Fix tidycausal bug #r-package #tidyverse #debugging"
$CLI quick "Add new geom to ggdag #r-package #ggplot2 #visualization"
echo "✅ Created 2 R package notes"
echo ""

# Scenario 4: List all tags
echo "📌 Scenario 4: List All Tags"
echo "----------------------------"
$CLI tags list
echo ""

# Scenario 5: Search by tag
echo "🔍 Scenario 5: Search by Tag"
echo "----------------------------"
echo "Research notes:"
$CLI tags search research
echo ""
echo "Teaching notes:"
$CLI tags search teaching
echo ""

# Scenario 6: Tag statistics
echo "📊 Scenario 6: Tag Statistics"
echo "----------------------------"
$CLI tags stats
echo ""

# Scenario 7: Enhanced search
echo "🔎 Scenario 7: Enhanced Search"
echo "------------------------------"
echo "Search 'lecture' with tag filter:"
$CLI search "lecture" --tag teaching
echo ""

# Summary
echo "================================"
echo "📈 Dogfooding Summary"
echo "================================"
echo ""
echo "Scenarios Completed:"
echo "  ✅ Research notes (3 with tags)"
echo "  ✅ Teaching notes (3 with tags)"
echo "  ✅ R package notes (2 with tags)"
echo "  ✅ Tag listing"
echo "  ✅ Tag search"
echo "  ✅ Tag statistics"
echo "  ✅ Enhanced search with filters"
echo ""
echo "Total: 8 notes created with 15+ unique tags"
echo ""
echo "✅ All dogfooding scenarios completed!"
echo ""
echo "💡 Try: scribe-cli tags list"
echo "💡 Try: scribe-cli tags search research"
