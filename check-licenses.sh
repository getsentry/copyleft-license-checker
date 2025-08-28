#!/bin/bash

# Copyleft License Checker
# Checks changed files for strong copyleft licenses (GPL, AGPL, QPL)
# Allows GPL with Classpath Exception

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration from environment variables
EXCLUDE_PATTERNS=${EXCLUDE_PATTERNS:-"*.md,*.txt,LICENSE*,COPYING*,docs/*,*.rst"}
FAIL_ON_FOUND=${FAIL_ON_FOUND:-true}

# Convert comma-separated exclude patterns to array
IFS=',' read -ra EXCLUDE_ARRAY <<< "$EXCLUDE_PATTERNS"

# License patterns to detect
GPL_PATTERNS=(
    "GNU General Public License"
    "GPL-[123]\.0"
    "GPL v[123]"
    "GPLv[123]"
    "GPL version [123]"
    "licensed under.*GPL"
    "under the GPL"
    "GPL licensed"
)

AGPL_PATTERNS=(
    "GNU Affero General Public License"
    "AGPL-[13]\.0"
    "AGPL v[13]"
    "AGPLv[13]"
    "AGPL version [13]"
    "licensed under.*AGPL"
    "under the AGPL"
    "AGPL licensed"
)

QPL_PATTERNS=(
    "Q Public License"
    "QPL"
    "Qt Public License"
    "licensed under.*QPL"
    "under the QPL"
    "QPL licensed"
)



# Exception patterns (these are allowed)
EXCEPTION_PATTERNS=(
    "GPL.*[Cc]lasspath [Ee]xception"
    "GPL.*[Cc]lasspath [Ll]icense"
    "with the Classpath exception"
    "Classpath exception to the GPL"
)

# Function to check if a file should be excluded
should_exclude_file() {
    local file="$1"
    for pattern in "${EXCLUDE_ARRAY[@]}"; do
        # Remove leading/trailing whitespace
        pattern=$(echo "$pattern" | xargs)
        if [[ "$file" == $pattern ]]; then
            return 0
        fi
    done
    return 1
}

# Function to check if text contains exception patterns
has_exception() {
    local text="$1"
    for pattern in "${EXCEPTION_PATTERNS[@]}"; do
        if echo "$text" | grep -qi -E "$pattern"; then
            return 0
        fi
    done
    return 1
}

# Function to check for license patterns in a file
check_file_for_licenses() {
    local file="$1"
    local found_licenses=()
    local file_content
    
    if [[ ! -f "$file" ]]; then
        return 0
    fi
    
    # Read file content
    file_content=$(cat "$file" 2>/dev/null || echo "")
    
    # Check if file has exceptions first
    if has_exception "$file_content"; then
        echo -e "${BLUE}INFO:${NC} $file contains GPL with Classpath Exception (allowed)"
        return 0
    fi
    
    # Check for GPL patterns
    for pattern in "${GPL_PATTERNS[@]}"; do
        if echo "$file_content" | grep -qi -E "$pattern"; then
            found_licenses+=("GPL")
            break
        fi
    done
    
    # Check for AGPL patterns
    for pattern in "${AGPL_PATTERNS[@]}"; do
        if echo "$file_content" | grep -qi -E "$pattern"; then
            found_licenses+=("AGPL")
            break
        fi
    done
    
    # Check for QPL patterns
    for pattern in "${QPL_PATTERNS[@]}"; do
        if echo "$file_content" | grep -qi -E "$pattern"; then
            found_licenses+=("QPL")
            break
        fi
    done
    
    # Report findings
    if [[ ${#found_licenses[@]} -gt 0 ]]; then
        echo -e "${RED}FOUND:${NC} $file contains: ${found_licenses[*]}"
        
        # Show context for each found license
        for license in "${found_licenses[@]}"; do
            case $license in
                "GPL")
                    patterns=("${GPL_PATTERNS[@]}")
                    ;;
                "AGPL")
                    patterns=("${AGPL_PATTERNS[@]}")
                    ;;
                "QPL")
                    patterns=("${QPL_PATTERNS[@]}")
                    ;;
            esac
            
            for pattern in "${patterns[@]}"; do
                local line_num
                line_num=$(echo "$file_content" | grep -ni -E "$pattern" | head -1 | cut -d: -f1)
                if [[ -n "$line_num" ]]; then
                    local context
                    context=$(echo "$file_content" | sed -n "${line_num}p" | xargs)
                    echo -e "  ${YELLOW}Line $line_num:${NC} $context"
                    break
                fi
            done
        done
        return 1
    fi
    
    return 0
}

# Main execution
main() {
    echo -e "${BLUE}Copyleft License Checker${NC}"
    echo "=========================="
    echo "Checking for: GPL, AGPL"
    echo "Excluding patterns: $EXCLUDE_PATTERNS"
    echo ""
    
    local files_with_licenses=()
    local total_files=0
    local checked_files=0
    
    # Get list of changed files
    local changed_files
    if [[ -n "${GITHUB_EVENT_NAME:-}" ]]; then
        # In GitHub Actions environment
        case "${GITHUB_EVENT_NAME}" in
            "pull_request")
                changed_files=$(git diff --name-only origin/"$GITHUB_BASE_REF"...HEAD)
                ;;
            "push")
                if [[ "$GITHUB_REF" == "refs/heads/"* ]]; then
                    # For push events, compare with previous commit
                    changed_files=$(git diff --name-only HEAD~1 HEAD)
                else
                    # For other refs, get all files
                    changed_files=$(find . -type f -not -path './.git/*')
                fi
                ;;
            *)
                # Fallback: check all files
                changed_files=$(find . -type f -not -path './.git/*')
                ;;
        esac
    else
        # Local testing: check all files
        echo -e "${YELLOW}WARNING:${NC} Not in GitHub Actions environment, checking all files"
        changed_files=$(find . -type f -not -path './.git/*' -not -path './.*')
    fi
    
    # Process each file
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        total_files=$((total_files + 1))
        
        # Skip if file should be excluded
        if should_exclude_file "$file"; then
            echo -e "${BLUE}SKIP:${NC} $file (excluded by pattern)"
            continue
        fi
        
        checked_files=$((checked_files + 1))
        
        if ! check_file_for_licenses "$file"; then
            files_with_licenses+=("$file")
        fi
    done <<< "$changed_files"
    
    # Summary
    echo ""
    echo "=========================="
    echo -e "${BLUE}SUMMARY${NC}"
    echo "Total files: $total_files"
    echo "Checked files: $checked_files"
    echo "Files with copyleft licenses: ${#files_with_licenses[@]}"
    
    # Set GitHub Actions outputs
    if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
        echo "licenses-found=$([[ ${#files_with_licenses[@]} -gt 0 ]] && echo "true" || echo "false")" >> "$GITHUB_OUTPUT"
        
        # Create JSON array of found files
        local json_files="["
        for i in "${!files_with_licenses[@]}"; do
            [[ $i -gt 0 ]] && json_files+=","
            json_files+="\"${files_with_licenses[$i]}\""
        done
        json_files+="]"
        echo "found-files=$json_files" >> "$GITHUB_OUTPUT"
        
        local summary="Checked $checked_files files, found ${#files_with_licenses[@]} with copyleft licenses"
        echo "summary=$summary" >> "$GITHUB_OUTPUT"
    fi
    
    # Exit with appropriate code
    if [[ ${#files_with_licenses[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Copyleft licenses detected!${NC}"
        if [[ "$FAIL_ON_FOUND" == "true" ]]; then
            exit 1
        else
            echo -e "${YELLOW}⚠️  Continuing despite found licenses (fail-on-found=false)${NC}"
        fi
    else
        echo -e "${GREEN}✅ No copyleft licenses found${NC}"
    fi
    
    exit 0
}

# Run main function
main "$@"
