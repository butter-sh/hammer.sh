#!/usr/bin/env bash
# Quick test to see actual output

INIT_SH="/home/valknar/Projects/hammer.sh/templates/init/init.sh"

echo "=== Testing play without args ==="
bash "$INIT_SH" play 2>&1 || true
echo ""

echo "=== Testing upload without args ==="
bash "$INIT_SH" upload 2>&1 || true
echo ""

echo "=== Testing with FORCE_COLOR ==="
export FORCE_COLOR=1
bash -c "source '$INIT_SH' && echo \"GREEN=\${GREEN}\""
