#!/bin/bash
# E2E tests for Tags Phase 2
# Tests tag parsing, tag commands, and enhanced search

set -e

echo "🧪 Running Tags Phase 2 E2E Tests..."
echo "======================================"

# Build CLI
echo ""
echo "📦 Building scribe-cli..."
swift build --product scribe-cli > /dev/null 2>&1
CLI=".build/debug/scribe-cli"

TESTS_RUN=0
TESTS_PASSED=0

run_test() {
    local test_name="$1"
    shift
    local expected_pattern="$1"
    shift
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo ""
    echo "Test $TESTS_RUN: $test_name"
    
    output=$("$@" 2>&1 || true)
    
    if echo "$output" | grep -q "$expected_pattern"; then
        echo "  ✅ PASS"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ❌ FAIL"
        echo "  Expected: $expected_pattern"
        echo "  Got: $output"
    fi
}

# Test 1-5: Create notes with tags
run_test "Create note with single tag" \
    "Captured to inbox" \
    $CLI quick "Research note #research"

run_test "Create note with multiple tags" \
    "Captured to inbox" \
    $CLI quick "Stats paper #research #statistics #causal-inference"

run_test "Create note with tags in title" \
    "Created" \
    $CLI create "#meeting notes"

run_test "Tags list shows tags" \
    "#research" \
    $CLI tags list

run_test "Tags list shows multiple tags" \
    "#statistics" \
    $CLI tags list

# Test 6-10: Tag search
run_test "Search by tag finds notes" \
    "Research note" \
    $CLI tags search research

run_test "Search by tag case insensitive" \
    "Research note" \
    $CLI tags search RESEARCH

run_test "Search nonexistent tag" \
    "No notes found" \
    $CLI tags search nonexistent

run_test "Tag stats shows counts" \
    "Total tags" \
    $CLI tags stats

run_test "Tag stats shows top tags" \
    "Top 5 tags" \
    $CLI tags stats

# Test 11-15: Enhanced search
run_test "Search with tag filter" \
    "research" \
    $CLI search "note" --tag research

run_test "Search with title-only flag" \
    "meeting" \
    $CLI search "meeting" --title-only

run_test "Help shows tags command" \
    "tags \[cmd\]" \
    $CLI help

run_test "Tags help shows subcommands" \
    "Valid subcommands" \
    $CLI tags invalid

run_test "Search help shows filters" \
    "--tag" \
    $CLI search

# Summary
echo ""
echo "======================================"
echo "📊 Test Summary"
echo "======================================"
echo "Tests run: $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $((TESTS_RUN - TESTS_PASSED))"

if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    echo ""
    echo "✅ All tests passed!"
    exit 0
else
    echo ""
    echo "❌ Some tests failed"
    exit 1
fi
