#!/bin/bash
# Phase 0 Vault Commands Test Suite

set -e

CLI=".build/debug/scribe-cli"
TEST_DIR="/tmp/scribe-test-$$"
CONFIG_DIR="$HOME/.config/scribe/.scribe-cli"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

passed=0
failed=0

test() {
    local name="$1"
    shift
    echo -n "Testing: $name... "
    if "$@" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((passed++))
        return 0
    else
        echo -e "${RED}✗${NC}"
        ((failed++))
        return 1
    fi
}

test_output() {
    local name="$1"
    local expected="$2"
    shift 2
    echo -n "Testing: $name... "
    output=$("$@" 2>&1)
    if echo "$output" | grep -q "$expected"; then
        echo -e "${GREEN}✓${NC}"
        ((passed++))
    else
        echo -e "${RED}✗${NC}"
        echo "  Expected: $expected"
        echo "  Got: $output"
        ((failed++))
    fi
}

cleanup() {
    rm -rf "$TEST_DIR"
    rm -rf "$CONFIG_DIR"
}

echo "=== Phase 0: Vault Commands Test Suite ==="
echo

# Cleanup before tests
cleanup
mkdir -p "$TEST_DIR"

# Test 1: Vault help
test_output "vault help" "vault <command>" $CLI vault

# Test 2: List vaults (should be empty)
test_output "list empty vaults" "No vaults found" $CLI vault list

# Test 3: Create vault (teaching)
test "create teaching vault" $CLI vault create teaching "$TEST_DIR/teaching" teaching

# Test 4: Verify config directory created
test "config directory exists" test -d "$CONFIG_DIR"

# Test 5: Verify global config created
test "global config exists" test -f "$CONFIG_DIR/config.json"

# Test 6: Verify vault directory created
test "vault directory exists" test -d "$TEST_DIR/teaching"

# Test 7: Verify .scribe directory created
test "vault .scribe exists" test -d "$TEST_DIR/teaching/.scribe"

# Test 8: Verify vault.json created
test "vault.json exists" test -f "$TEST_DIR/teaching/.scribe/vault.json"

# Test 9: Verify cli.json created
test "cli.json exists" test -f "$TEST_DIR/teaching/.scribe/cli.json"

# Test 10: List vaults (should show teaching)
test_output "list vaults shows teaching" "teaching" $CLI vault list

# Test 11: Create second vault (research)
test "create research vault" $CLI vault create research "$TEST_DIR/research" research

# Test 12: List vaults (should show both)
test_output "list vaults shows both" "teaching" $CLI vault list

# Test 13: Check current vault is teaching (first created)
test_output "current vault is teaching" "✓ Current: teaching" $CLI vault list

# Test 14: Switch to research vault
test "switch to research" $CLI vault switch research

# Test 15: Verify switched
test_output "current is now research" "✓ Current: research" $CLI vault list

# Test 16: Show vault info
test_output "vault info shows name" "research" $CLI vault info

# Test 17: Context detection (outside vault)
test_output "context outside vault" "Outside any vault" $CLI vault context

# Test 18: Context detection (in vault root)
cd "$TEST_DIR/teaching"
test_output "context in vault root" "Vault Root" $CLI vault context

# Test 19: Delete vault
cd /tmp
test "delete research vault" echo "y" | $CLI vault delete research

# Test 20: Verify deleted from list
output=$($CLI vault list 2>&1)
if echo "$output" | grep -q "research"; then
    echo -e "${RED}✗${NC} Vault not deleted"
    ((failed++))
else
    echo -e "${GREEN}✓${NC} Testing: vault deleted"
    ((passed++))
fi

# Cleanup
cleanup

echo
echo "=== Summary ==="
echo "Passed: $passed"
echo "Failed: $failed"

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed${NC}"
    exit 1
fi
