#!/bin/bash

# Local testing script for the Copyleft License Checker
# This script allows testing the action locally without act

set -euo pipefail

echo "=== Local Testing of Copyleft License Checker ==="
echo ""

# Initialize git repo if not already done
if [[ ! -d .git ]]; then
    echo "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit with test files"
fi

echo "Test 1: Default settings (should find GPL and AGPL violations)"
echo "================================================================"
export EXCLUDE_PATTERNS="*.md,*.txt,LICENSE*,COPYING*,docs/*,*.rst"
export FAIL_ON_FOUND=false
./check-licenses.sh
echo ""

echo "Test 3: Custom excludes (should exclude GPL violation file)"
echo "=========================================================="
export EXCLUDE_PATTERNS="*.md,*.txt,LICENSE*,COPYING*,docs/*,*.rst,test-files/gpl-violation.java"
export FAIL_ON_FOUND=false
./check-licenses.sh
echo ""

echo "Test 4: Fail on found (should exit with code 1)"
echo "==============================================="
export EXCLUDE_PATTERNS="*.md,*.txt,LICENSE*,COPYING*,docs/*,*.rst"
export FAIL_ON_FOUND=true
echo "Note: This test will exit with code 1 if violations are found"
./check-licenses.sh || echo "Exit code: $?"

echo ""
echo "=== Local Testing Complete ==="
