# Test Files

This directory contains test files with various license scenarios:

## Files that should be flagged (copyleft violations):
- `gpl-violation.java` - Contains GPL v3 license
- `agpl-violation.py` - Contains AGPL v3 license  
- `lgpl-violation.c` - Contains LGPL v2.1 license (only when CHECK_LGPL=true)

## Files that should be allowed:
- `gpl-classpath-allowed.java` - GPL with Classpath Exception (explicitly allowed)
- `mit-license-ok.js` - MIT License (permissive)
- `apache-license-ok.go` - Apache License 2.0 (permissive)
- `no-license.rs` - No license header
- `README.md` - Documentation file (excluded by default)

## Testing Notes

The action should:
1. Flag GPL and AGPL files as violations
2. Allow GPL with Classpath Exception
3. Skip documentation files by default
4. Only flag LGPL when CHECK_LGPL=true
