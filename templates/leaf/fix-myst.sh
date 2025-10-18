#!/usr/bin/env bash
# Quick fix script for myst line 368/581

MYST_FILE="/home/valknar/Projects/hammer.sh/templates/leaf/.arty/bin/myst"

echo "Fixing myst.sh line 581..."

# Use perl to fix the problematic line
perl -i -pe 's/if \[\[ "\$2" =~ \^MYST_ \]\]; then/if [[ -n "${2:-}" ]]; then/g' "$MYST_FILE"

echo "✓ Fixed!"
echo ""
echo "Verifying fix:"
grep -n 'if \[\[.*2.*MYST' "$MYST_FILE" || echo "Old pattern not found (good!)"
grep -n 'if \[\[ -n.*{2:-}' "$MYST_FILE" || echo "New pattern not found (bad!)"
