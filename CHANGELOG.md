# Changelog

All notable changes to hammer.sh will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of hammer.sh
- CLI facade for myst.sh templating library
- Support for multiple variable input methods:
  - CLI variables via `-v, --var KEY=VALUE`
  - JSON files via `-j, --json FILE`
  - YAML files via `-y, --yaml FILE`
  - Interactive prompts with descriptions and defaults
- Template variable configuration in arty.yml
- Interactive mode for prompting users for input
- `--yes` flag to accept all defaults without prompting
- `--force` flag to overwrite files without confirmation
- `--list` option to show available templates
- Smart file overwrite detection and prompting
- Template organization in dedicated `templates/` directory
- Support for myst.sh partials
- Example template with partials
- Comprehensive documentation and examples
- Integration with arty.sh ecosystem
- Setup script for easy installation
- Example usage scripts

### Features
- Works in current working directory or dedicated template directory
- Reads default variables from arty.yml for each template
- Automatic detection of myst.sh installation (via arty or system)
- Color-coded console output for better UX
- Variable priority system (CLI > JSON > YAML > Interactive > Defaults)
- Partial template support via myst.sh
- Template validation and error handling

## [1.0.0] - 2025-01-XX

Initial release

---

**Legend:**
- `Added` - New features
- `Changed` - Changes in existing functionality
- `Deprecated` - Soon-to-be removed features
- `Removed` - Removed features
- `Fixed` - Bug fixes
- `Security` - Vulnerability fixes
