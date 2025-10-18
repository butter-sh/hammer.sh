#!/usr/bin/env bash
# Quick test to see if myst rendering works

cd "$(dirname "$0")"

# Create a simple test case
TEST_DIR=$(mktemp -d)
echo "Test directory: $TEST_DIR"

# Create minimal project
mkdir -p "$TEST_DIR/test-project"
cat > "$TEST_DIR/test-project/arty.yml" << 'EOF'
name: "test-project"
version: "1.0.0"
description: "A test project"
EOF

# Run leaf.sh with debug enabled
echo "Running leaf.sh..."
DEBUG=1 bash ./leaf.sh "$TEST_DIR/test-project" -o "$TEST_DIR/output"

# Check if output was created
if [[ -f "$TEST_DIR/output/index.html" ]]; then
    echo "✓ SUCCESS: HTML file created"
    echo "File size: $(wc -c < "$TEST_DIR/output/index.html") bytes"
    echo "First 200 characters:"
    head -c 200 "$TEST_DIR/output/index.html"
else
    echo "✗ FAIL: HTML file not created"
    echo "Contents of output directory:"
    ls -la "$TEST_DIR/output" 2>&1 || echo "Output directory doesn't exist"
fi

# Cleanup
# rm -rf "$TEST_DIR"
echo ""
echo "Test directory preserved at: $TEST_DIR"
