#!/bin/bash
# Run Scribe with filtered console output
# Removes common SPM bundle warnings

set -e

echo "🔨 Building Scribe..."
swift build -c release 2>&1 | grep -v "note:"

echo "✍️  Ad-hoc signing..."
codesign --force --deep --sign - --entitlements Scribe.entitlements .build/release/Scribe 2>/dev/null || \
    codesign --force --deep --sign - .build/release/Scribe 2>/dev/null

echo "🚀 Launching Scribe..."
echo ""

# Run and filter out the known warnings
.build/release/Scribe 2>&1 | grep -v "Cannot index window tabs" | grep -v "Unable to obtain a task name port"
