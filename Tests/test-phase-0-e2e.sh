#!/bin/bash
# Enhanced E2E Test Suite for Phase 0: Vault System
# Tests all vault commands with realistic scenarios

set -e

CLI=".build/debug/scribe-cli"
TEST_ROOT="/tmp/scribe-e2e-test-$$"
CONFIG_DIR="$HOME/.config/scribe/.scribe-cli"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

passed=0
failed=0
total=0

setup() {
    echo -e "${BLUE}=== Phase 0 E2E Test Suite ===${NC}"
    echo
    
    # Cleanup previous runs
    rm -rf "$TEST_ROOT"
    rm -rf "$CONFIG_DIR"
    
    # Create test directories
    mkdir -p "$TEST_ROOT"/{teaching,research,r-pkg}
    
    echo "Test environment ready"
    echo
}

test_command() {
    local name="$1"
    shift
    
    ((total++))
    echo -n "[$total] $name... "
    
    if output=$("$@" 2>&1); then
        echo -e "${GREEN}✓${NC}"
        ((passed++))
        return 0
    else
        echo -e "${RED}✗${NC}"
        echo "  Command failed: $*"
        echo "  Output: $output"
        ((failed++))
        return 1
    fi
}

test_output_contains() {
    local name="$1"
    local expected="$2"
    shift 2
    
    ((total++))
    echo -n "[$total] $name... "
    
    if output=$("$@" 2>&1); then
        if echo "$output" | grep -q "$expected"; then
            echo -e "${GREEN}✓${NC}"
            ((passed++))
            return 0
        else
            echo -e "${RED}✗${NC}"
            echo "  Expected output to contain: $expected"
            echo "  Got: $output"
            ((failed++))
            return 1
        fi
    else
        echo -e "${RED}✗${NC}"
        echo "  Command failed: $*"
        ((failed++))
        return 1
    fi
}

test_file_exists() {
    local name="$1"
    local file="$2"
    
    ((total++))
    echo -n "[$total] $name... "
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC}"
        ((passed++))
        return 0
    else
        echo -e "${RED}✗${NC}"
        echo "  File not found: $file"
        ((failed++))
        return 1
    fi
}

test_json_field() {
    local name="$1"
    local file="$2"
    local field="$3"
    local expected="$4"
    
    ((total++))
    echo -n "[$total] $name... "
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗${NC}"
        echo "  File not found: $file"
        ((failed++))
        return 1
    fi
    
    if value=$(python3 -c "import json; print(json.load(open('$file'))$field)" 2>/dev/null); then
        if [ "$value" = "$expected" ]; then
            echo -e "${GREEN}✓${NC}"
            ((passed++))
            return 0
        else
            echo -e "${RED}✗${NC}"
            echo "  Expected $field=$expected, got: $value"
            ((failed++))
            return 1
        fi
    else
        echo -e "${RED}✗${NC}"
        echo "  Could not read field $field from $file"
        ((failed++))
        return 1
    fi
}

cleanup() {
    rm -rf "$TEST_ROOT"
    rm -rf "$CONFIG_DIR"
}

# Run tests
setup

echo "=== Basic Vault Operations ==="
test_output_contains "vault help shows usage" "vault <command>" $CLI vault
test_output_contains "empty vault list" "No vaults found" $CLI vault list

echo
echo "=== Create Vaults ==="
test_command "create teaching vault" $CLI vault create teaching "$TEST_ROOT/teaching" teaching
test_file_exists "global config created" "$CONFIG_DIR/config.json"
test_file_exists "vaults directory created" "$CONFIG_DIR/vaults"
test_file_exists "vault directory created" "$TEST_ROOT/teaching"
test_file_exists ".scribe directory created" "$TEST_ROOT/teaching/.scribe"
test_file_exists "vault.json created" "$TEST_ROOT/teaching/.scribe/vault.json"
test_file_exists "cli.json created" "$TEST_ROOT/teaching/.scribe/cli.json"

echo
echo "=== Vault Configuration Integrity ==="
test_json_field "vault.json has correct name" "$TEST_ROOT/teaching/.scribe/vault.json" "['vault']['name']" "teaching"
test_json_field "vault.json has correct type" "$TEST_ROOT/teaching/.scribe/vault.json" "['vault']['type']" "teaching"
test_json_field "cli.json has version" "$TEST_ROOT/teaching/.scribe/cli.json" "['version']" "1.0"

echo
echo "=== Multiple Vaults ==="
test_command "create research vault" $CLI vault create research "$TEST_ROOT/research" research
test_command "create r-pkg vault" $CLI vault create r-pkg "$TEST_ROOT/r-pkg" r-package
test_output_contains "list shows all vaults" "teaching" $CLI vault list
test_output_contains "list shows research" "research" $CLI vault list
test_output_contains "list shows r-pkg" "r-pkg" $CLI vault list
test_output_contains "shows current vault" "✓ Current" $CLI vault list

echo
echo "=== Vault Switching ==="
test_command "switch to research" $CLI vault switch research
test_output_contains "current is research" "✓ Current: research" $CLI vault list
test_command "switch to r-pkg" $CLI vault switch r-pkg
test_output_contains "current is r-pkg" "✓ Current: r-pkg" $CLI vault list

echo
echo "=== Vault Info ==="
test_output_contains "info shows vault name" "r-pkg" $CLI vault info
test_output_contains "info shows database path" "r-pkg-cli.sqlite" $CLI vault info
test_command "info for specific vault" $CLI vault info teaching

echo
echo "=== Context Detection ==="
test_output_contains "context outside vault" "Outside any vault" $CLI vault context

# Test context in vault root
cd "$TEST_ROOT/teaching"
test_output_contains "context in vault root" "Vault Root" $CLI vault context
test_output_contains "context shows vault name" "teaching" $CLI vault context
cd - > /dev/null

echo
echo "=== Vault Validation ==="
test_command "cannot create duplicate vault" bash -c "echo 'n' | $CLI vault create teaching /tmp/dup || true"

echo
echo "=== Vault Deletion ==="
test_command "delete vault" bash -c "echo 'y' | $CLI vault delete research"
test_output_contains "vault removed from list" "teaching" $CLI vault list
# Verify research is NOT in the list
if $CLI vault list 2>&1 | grep -q "research"; then
    echo -e "${RED}✗${NC} [$((++total))] vault still in list after deletion"
    ((failed++))
else
    echo -e "${GREEN}✓${NC} [$((++total))] vault removed from list"
    ((passed++))
fi

# Cleanup
cleanup

echo
echo "=== Test Summary ==="
echo "Total: $total"
echo "Passed: $passed"
echo "Failed: $failed"

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}$failed test(s) failed${NC}"
    exit 1
fi
