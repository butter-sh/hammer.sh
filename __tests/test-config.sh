#!/usr/bin/env bash
# Test configuration for hammer.sh test suite
# This file is sourced by test files to set common configuration

export TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test directory structure
export HAMMER_SH_ROOT="$(cd "$TEST_ROOT/.." && pwd)"
export HAMMER_SH="$HAMMER_SH_ROOT/hammer.sh"

# Debug: Print path (only if VERBOSE is set)
if [[ "${VERBOSE:-0}" == "1" ]]; then
    echo "[DEBUG test-config.sh] TEST_ROOT=$TEST_ROOT"
    echo "[DEBUG test-config.sh] HAMMER_SH_ROOT=$HAMMER_SH_ROOT"
    echo "[DEBUG test-config.sh] HAMMER_SH=$HAMMER_SH"
    if [[ -f "$HAMMER_SH" ]]; then
        echo "[DEBUG test-config.sh] hammer.sh exists: YES"
        echo "[DEBUG test-config.sh] hammer.sh executable: $(test -x "$HAMMER_SH" && echo YES || echo NO)"
    else
        echo "[DEBUG test-config.sh] hammer.sh exists: NO"
    fi
fi

# Verify hammer.sh exists
if [[ ! -f "$HAMMER_SH" ]]; then
    echo "ERROR: hammer.sh not found at: $HAMMER_SH" >&2
    echo "TEST_ROOT: $TEST_ROOT" >&2
    echo "HAMMER_SH_ROOT: $HAMMER_SH_ROOT" >&2
    exit 1
fi

# Test behavior flags
export HAMMER_TEST_MODE=1
export HAMMER_TEST_COLORS=1
export DEBUG=0
