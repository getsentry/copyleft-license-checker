# Copyleft License Checker

A GitHub Action that checks files for strong copyleft licenses (GPL, AGPL, QPL) with configurable handling of GPL with Classpath Exception.

## Features

- Detects GPL, AGPL, and QPL licenses in files
- Configurable handling of GPL with Classpath Exception (allow or treat as violation)
- Configurable file exclusion patterns
- Easy local testing with act

## Usage

### As a Reusable Action

Add this to your workflow:

```yaml
- name: Check for copyleft licenses
  uses: your-org/copyleft-license-checker@main
  with:
    exclude-patterns: '*.md,*.txt,LICENSE*,COPYING*,docs/*'
    fail-on-found: 'true'
    allow-gpl-classpath: 'true'  # Set to 'false' to treat GPL with Classpath Exception as violation
```

### Local Development

This repository includes a workflow at `.github/workflows/copyleft-check.yml` that uses the local action for testing.

## Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `exclude-patterns` | File patterns to exclude | `*.md,*.txt,LICENSE*,COPYING*,docs/*` |
| `fail-on-found` | Fail when licenses found | `true` |
| `allow-gpl-classpath` | Allow GPL with Classpath Exception | `true` |

## Local Testing

Test with act:
```bash
act push -j check-licenses
```

Or run the script directly:
```bash
# Default behavior (allows GPL with Classpath Exception)
./check-licenses.sh

# Disable GPL with Classpath Exception (treat as violation)
ALLOW_GPL_CLASSPATH=false ./check-licenses.sh

# Combine with other options
ALLOW_GPL_CLASSPATH=false FAIL_ON_FOUND=false ./check-licenses.sh
```

## What It Detects

- **GPL** (v1, v2, v3) - GNU General Public License
- **AGPL** (v1, v3) - GNU Affero General Public License  
- **QPL** - Q Public License (Qt Public License)
- **GPL with Classpath Exception** - Configurable (allowed by default, can be disabled)

## Example: GPL with Classpath Exception

```java
/*
 * Copyright (c) 2023 Example Corp. All rights reserved.
 * 
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation. Example Corp designates this
 * particular file as subject to the "Classpath" exception as provided
 * in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * version 2 for more details.
 */
```

This would be **allowed by default** because it contains "Classpath exception". Set `allow-gpl-classpath: false` to treat this as a violation.

## Configuration Examples

### Allow GPL with Classpath Exception (Default)
```yaml
- uses: your-org/copyleft-license-checker@main
  with:
    allow-gpl-classpath: 'true'  # or omit this line for default behavior
```

### Strict Mode - Treat GPL with Classpath Exception as Violation
```yaml
- uses: your-org/copyleft-license-checker@main
  with:
    allow-gpl-classpath: 'false'
    fail-on-found: 'true'
```

### Warning Mode - Detect but Don't Fail
```yaml
- uses: your-org/copyleft-license-checker@main
  with:
    allow-gpl-classpath: 'false'
    fail-on-found: 'false'  # Will report violations but not fail the build
```

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.
