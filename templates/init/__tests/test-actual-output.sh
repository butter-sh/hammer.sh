#!/usr/bin/env bash
# Direct test to see actual output

INIT_SH="../init.sh"

echo "=== Test 1: play without args ==="
bash "$INIT_SH" play 2>&1 || true
echo ""
echo "=== End of output ==="
echo ""

echo "=== Test 2: upload without args ==="
bash "$INIT_SH" upload 2>&1 || true
echo ""
echo "=== End of output ==="
echo ""

echo "=== Test 3: play with | cat to strip colors ==="
bash "$INIT_SH" play 2>&1 | cat || true
echo ""
echo "=== End of output ==="
