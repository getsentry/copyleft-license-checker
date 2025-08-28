# Copyleft License Checker

A GitHub Action that checks files for strong copyleft licenses (GPL, AGPL) while allowing GPL with Classpath Exception.

## Features

- Detects GPL and AGPL licenses in files
- Allows GPL with Classpath Exception
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
```

### Local Development

This repository includes a workflow at `.github/workflows/copyleft-check.yml` that uses the local action for testing.

## Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `exclude-patterns` | File patterns to exclude | `*.md,*.txt,LICENSE*,COPYING*,docs/*` |
| `fail-on-found` | Fail when licenses found | `true` |

## Local Testing

Test with act:
```bash
act push -j check-licenses
```

Or run the script directly:
```bash
./check-licenses.sh
```

## What It Detects

- **GPL** (v1, v2, v3) - GNU General Public License
- **AGPL** (v1, v3) - GNU Affero General Public License
- **GPL with Classpath Exception** - Allowed (common in Java)

## Example: GPL with Classpath Exception (Allowed)

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

This would be **allowed** because it contains "Classpath exception".

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.
