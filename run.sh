#!/bin/bash
# Development run script for Scribe
# Builds and runs with ad-hoc code signing

set -e

echo "🔨 Building Scribe..."
swift build

echo "✍️  Ad-hoc signing for development..."
codesign --force --deep --sign - --entitlements Scribe.entitlements .build/debug/Scribe 2>/dev/null || {
    echo "⚠️  Entitlements file not found, signing without entitlements"
    codesign --force --deep --sign - .build/debug/Scribe
}

echo "🚀 Launching Scribe..."
.build/debug/Scribe
