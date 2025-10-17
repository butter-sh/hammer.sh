# whip.sh Template for hammer.sh

## Summary

Successfully added a comprehensive **whip.sh** template to hammer.sh that generates release cycle management tools for arty.sh projects.

## What Was Created

### Template Location
`/home/valknar/Projects/hammer.sh/templates/whip/`

### Generated Files
1. **whip.sh** (main script, ~600 lines)
2. **arty.yml** (arty.sh integration)
3. **setup.sh** (initialization)
4. **README.md** (comprehensive docs)
5. **.template** (metadata for hammer.sh)
6. **.gitignore** (ignore patterns)
7. **LICENSE** (MIT license template)
8. **QUICKREF.md** (quick reference guide)
9. **WHIP_TEMPLATE_SUMMARY.md** (detailed summary)

## Core Features Implemented

### 1. Release Management ✅
- Semantic versioning (major, minor, patch)
- Updates version in arty.yml using yq
- Creates git commits and annotated tags
- Pushes to remote repository
- Full automated release workflow

### 2. Changelog Generation ✅
- Generates from git commit history
- Updates CHANGELOG.md automatically
- Supports version ranges
- Human-readable format
- Integrated into release process

### 3. Git Hooks Management ✅
- Pre-commit hook with bash validation
- Uses `bash -n` for syntax checking
- Integrates shellcheck if available
- Pluggable hook system (.whip/hooks/)
- Easy install/uninstall commands

### 4. Monorepo Support ✅
- Discovers arty.yml projects in subdirectories
- Batch operations (version, bump, status)
- Glob pattern filtering ("lib-*", "*-core", etc.)
- Recursive project scanning
- Individual project handling with error reporting

## Usage Examples

### Generate Project
```bash
cd /home/valknar/Projects/hammer.sh
./hammer.sh whip my-release-tool
cd my-release-tool
bash setup.sh
```

### Basic Commands
```bash
# Show version
./whip.sh version

# Bump version
./whip.sh bump patch    # 1.0.0 → 1.0.1
./whip.sh bump minor    # 1.0.0 → 1.1.0
./whip.sh bump major    # 1.0.0 → 2.0.0

# Full release
./whip.sh release patch
./whip.sh release minor
./whip.sh release major

# Release without pushing
./whip.sh release --no-push
```

### Hook Management
```bash
# Install commit hooks
./whip.sh hooks install

# Uninstall hooks
./whip.sh hooks uninstall

# Create custom hooks
./whip.sh hooks create
```

### Monorepo Operations
```bash
# List all projects
./whip.sh mono list

# Show all versions
./whip.sh mono version

# Bump all projects
./whip.sh mono bump patch

# Filter by pattern
./whip.sh mono bump minor "lib-*"

# Git status for all
./whip.sh mono status
```

## Technical Implementation

### Dependencies
- **bash** 4.0+
- **git** (required)
- **yq** (required for YAML processing)
- **shellcheck** (optional for pre-commit)

### Key Functions
- `get_current_version()` - Read version from arty.yml
- `update_version()` - Update version in arty.yml
- `bump_version()` - Calculate new semver
- `generate_changelog()` - Create from git history
- `create_release_tag()` - Git tag management
- `release()` - Full release orchestration
- `install_hooks()` - Git hooks setup
- `monorepo_batch()` - Batch operations
- `find_arty_projects()` - Project discovery

### Release Workflow
1. Check for uncommitted changes
2. Bump version based on type
3. Update arty.yml with new version
4. Generate/update CHANGELOG.md
5. Commit changes (version + changelog)
6. Create annotated git tag
7. Push commits and tags

### Pre-commit Hook
The default hook validates:
- Bash syntax with `bash -n`
- ShellCheck analysis (if available)
- Prevents commits with errors
- Shows clear error messages

## Integration with arty.sh

Projects include predefined arty.yml scripts:

```yaml
scripts:
  install: "bash whip.sh hooks install"
  release: "bash whip.sh release"
  release-major: "bash whip.sh release major"
  release-minor: "bash whip.sh release minor"
  release-patch: "bash whip.sh release patch"
```

Use via arty commands:
```bash
arty install       # Install hooks
arty release       # Patch release
arty release-major # Major release
arty release-minor # Minor release
```

## Monorepo Structure Example

```
monorepo/
├── lib-core/
│   ├── arty.yml
│   └── ...
├── lib-utils/
│   ├── arty.yml
│   └── ...
├── app-main/
│   ├── arty.yml
│   └── ...
└── whip.sh       # Can manage all subdirectories
```

Operations:
```bash
# From monorepo root
./whip.sh mono list              # Find all projects
./whip.sh mono version           # Show versions
./whip.sh mono bump patch        # Bump all
./whip.sh mono bump minor "lib-*" # Bump matching
```

## Testing

Run the test script:
```bash
cd /home/valknar/Projects/hammer.sh
bash test-whip-template.sh
```

The test validates:
- ✅ Project generation
- ✅ All required files exist
- ✅ Script permissions
- ✅ Bash syntax
- ✅ Help command works
- ✅ Variable substitution
- ✅ Setup script execution

## Verification

To verify the template is available:

```bash
# List templates (whip should appear)
./hammer.sh --list

# Expected output includes:
# whip            Release cycle management for arty.sh projects...
```

## Files in Template

```
whip/
├── .gitignore                    # Ignore .arty/, .whip/, logs
├── .template                     # Template metadata
├── LICENSE                       # MIT License (with placeholders)
├── README.md                     # Full documentation
├── QUICKREF.md                   # Quick reference
├── WHIP_TEMPLATE_SUMMARY.md     # This file
├── arty.yml                      # arty.sh config
├── setup.sh                      # Setup script
└── whip.sh                       # Main script (~600 lines)
```

## Advantages

1. **Complete Solution**: Not just a skeleton, fully functional
2. **Production Ready**: Error handling, validation, feedback
3. **Extensible**: Pluggable hook system
4. **Monorepo Native**: Built-in multi-project support
5. **Well Documented**: Comprehensive README and inline help
6. **arty.sh Native**: Designed for the ecosystem
7. **Semantic Versioning**: Proper semver support
8. **Git Integration**: Full git workflow automation

## Next Steps

1. **Generate a project**:
   ```bash
   ./hammer.sh whip my-project
   ```

2. **Run setup**:
   ```bash
   cd my-project
   bash setup.sh
   ```

3. **Install hooks** (optional):
   ```bash
   ./whip.sh hooks install
   ```

4. **Create releases**:
   ```bash
   ./whip.sh release patch
   ```

## Environment Variables

Customize behavior:
```bash
# Custom config file
WHIP_CONFIG=custom.yml ./whip.sh release

# Custom changelog
WHIP_CHANGELOG=HISTORY.md ./whip.sh release

# Both
WHIP_CONFIG=cfg.yml WHIP_CHANGELOG=CHANGES.md ./whip.sh release
```

## Future Enhancements

Possible additions:
- [ ] GitHub release creation
- [ ] Changelog template customization
- [ ] Hook templates library
- [ ] Release notes generation
- [ ] Pre-release version support
- [ ] Build metadata in versions
- [ ] Release branch management
- [ ] Automatic dependency updates

## Conclusion

The whip.sh template is now fully integrated into hammer.sh and ready for use. It provides comprehensive release management capabilities for arty.sh projects with:

- ✅ Semantic versioning
- ✅ Changelog generation
- ✅ Git tag management
- ✅ Commit hooks
- ✅ Monorepo support
- ✅ Full automation

Generate your first project with:
```bash
hammer whip my-release-manager
```

🎉 **Template successfully created and tested!**
