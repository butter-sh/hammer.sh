#!/usr/bin/env bash
# Test configuration for arty.sh test suite
# This file is sourced by test files to set common configuration

# Test directory structure
export ARTY_SH_ROOT="$PWD"

# Test behavior flags
export ARTY_TEST_MODE=1
export ARTY_SKIP_YQ_CHECK=0  # Set to 1 to skip yq availability check in tests

# Color output in tests (set to 0 to disable)
export ARTY_TEST_COLORS=1

# Snapshot configuration
export SNAPSHOT_UPDATE="${UPDATE_SNAPSHOTS:-0}"
export SNAPSHOT_VERBOSE="${VERBOSE:-0}"
