# Complete Test Case Index - Leaf.sh

## test-leaf-cli.sh (18 tests)

1. `test_no_args_shows_usage` - Verify usage shown without arguments
2. `test_help_flag` - Verify --help shows usage
3. `test_help_short_flag` - Verify -h shows usage
4. `test_version_flag` - Verify --version shows version
5. `test_landing_mode_flag` - Verify --landing switches to landing mode
6. `test_output_flag` - Verify --output sets custom directory
7. `test_output_short_flag` - Verify -o short flag works
8. `test_logo_flag` - Verify --logo accepts custom logo
9. `test_base_path_flag` - Verify --base-path sets base path
10. `test_github_flag` - Verify --github sets GitHub URL
11. `test_debug_flag` - Verify --debug enables debug output
12. `test_unknown_option` - Verify unknown option shows error
13. `test_usage_shows_examples` - Verify usage shows examples section
14. `test_usage_shows_dependencies` - Verify usage shows dependencies
15. `test_usage_shows_project_structure` - Verify usage shows project structure
16. `test_usage_shows_json_format` - Verify usage shows JSON format
17. `test_usage_shows_file_types` - Verify usage shows supported file types
18. `test_command_line_parsing` - Verify command line parsing works correctly

## test-leaf-dependencies.sh (7 tests)

1. `test_check_dependencies_missing_yq` - Detect missing yq
2. `test_check_dependencies_missing_jq` - Detect missing jq
3. `test_check_dependencies_success` - Success when both present
4. `test_dependency_install_links` - Show installation links
5. `test_dependency_exit_code` - Return proper exit code
6. `test_main_exits_on_missing_deps` - Main function exits on missing deps
7. `test_dependency_check_early` - Dependency check happens early

## test-leaf-yaml.sh (10 tests)

1. `test_parse_yaml_simple_field` - Retrieve simple field
2. `test_parse_yaml_version` - Retrieve version field
3. `test_parse_yaml_missing_file` - Handle missing file
4. `test_parse_yaml_missing_field` - Handle missing field
5. `test_parse_yaml_nested` - Handle nested fields
6. `test_parse_yaml_null` - Handle null values
7. `test_parse_yaml_quoted_strings` - Handle quoted strings
8. `test_parse_yaml_multiline` - Handle multiline strings
9. `test_parse_yaml_special_chars` - Handle special characters
10. `test_parse_yaml_arrays` - Handle array access

## test-leaf-json.sh (14 tests)

1. `test_parse_json_valid` - Parse valid JSON
2. `test_parse_json_with_query` - Extract field with query
3. `test_parse_json_invalid` - Detect invalid JSON
4. `test_parse_json_empty` - Handle empty input
5. `test_validate_projects_json_valid` - Accept valid array
6. `test_validate_projects_json_not_array` - Reject non-array
7. `test_validate_projects_json_empty` - Handle empty array
8. `test_validate_projects_json_missing_fields` - Check required fields
9. `test_validate_projects_json_complete` - Accept complete projects
10. `test_read_json_file_valid` - Read valid file
11. `test_read_json_file_missing` - Handle missing file
12. `test_read_json_file_invalid` - Handle invalid JSON in file
13. `test_parse_json_nested` - Handle nested objects
14. `test_parse_json_arrays` - Handle array indexing

## test-leaf-helpers.sh (16 tests)

1. `test_detect_language_shell` - Detect shell files (.sh, .bash)
2. `test_detect_language_various` - Detect various languages (js, py, rb, go, rs)
3. `test_detect_language_unknown` - Handle unknown extensions
4. `test_read_file_exists` - Read existing file
5. `test_read_file_missing` - Handle missing file
6. `test_get_icon_standard` - Find icon in standard location
7. `test_get_icon_priority` - Icon file priority (icon.svg first)
8. `test_get_icon_custom` - Use custom logo
9. `test_get_icon_none` - Return empty when no icon found
10. `test_logging_functions` - Test log_info, log_success, log_warn, log_error
11. `test_log_debug` - Debug logging when enabled
12. `test_log_debug_hidden` - Debug logging hidden by default
13. `test_scan_source_files` - Find shell files in project
14. `test_scan_examples` - Find example files
15. `test_scan_examples_no_directory` - Handle missing examples directory
16. `test_helper_functions_work` - General helper function validation

## test-leaf-docs.sh (16 tests)

1. `test_generate_docs_creates_output` - Create index.html output
2. `test_docs_contains_project_name` - Include project name
3. `test_docs_contains_version` - Include version number
4. `test_docs_contains_description` - Include description
5. `test_docs_includes_readme` - Include README content
6. `test_docs_handles_missing_readme` - Handle missing README
7. `test_docs_includes_source_files` - Include source code
8. `test_docs_escapes_html` - Escape HTML in source code
9. `test_docs_includes_examples` - Include example files
10. `test_docs_html_structure` - Proper HTML structure (DOCTYPE, html, head, body)
11. `test_docs_includes_tailwind` - Include Tailwind CSS
12. `test_docs_includes_highlightjs` - Include Highlight.js
13. `test_docs_includes_theme_toggle` - Include theme toggle functionality
14. `test_docs_custom_base_path` - Custom base path in HTML
15. `test_docs_custom_icon` - Custom icon inclusion
16. `test_docs_generation_progress` - Report generation progress

## test-leaf-landing.sh (22 tests)

1. `test_landing_creates_output` - Create landing page output
2. `test_landing_contains_branding` - Contains butter.sh branding
3. `test_landing_default_projects` - Uses default projects (hammer, arty, leaf)
4. `test_landing_custom_projects_json` - Accepts custom projects JSON
5. `test_landing_projects_from_file` - Reads projects from file
6. `test_landing_validates_json` - Validates projects JSON
7. `test_landing_rejects_non_array` - Rejects non-array JSON
8. `test_landing_warns_empty_projects` - Warns on empty projects
9. `test_landing_warns_missing_fields` - Warns on missing required fields
10. `test_landing_custom_github` - Uses custom GitHub URL
11. `test_landing_custom_base_path` - Uses custom base path
12. `test_landing_html_structure` - Proper HTML structure
13. `test_landing_includes_tailwind` - Includes Tailwind CSS
14. `test_landing_includes_theme_toggle` - Includes theme toggle
15. `test_landing_includes_mobile_menu` - Includes mobile menu
16. `test_landing_includes_hero` - Includes hero section
17. `test_landing_includes_projects_section` - Includes projects section
18. `test_landing_includes_footer` - Includes footer
19. `test_landing_generation_progress` - Reports generation progress
20. `test_landing_projects_file_priority` - File takes priority over argument
21. `test_landing_missing_projects_file` - Handles missing projects file
22. `test_landing_page_validation` - Complete landing page validation

## test-leaf-errors.sh (19 tests)

1. `test_missing_project_directory` - Handle missing project directory
2. `test_missing_arty_yml` - Handle missing arty.yml
3. `test_corrupted_yaml` - Handle corrupted YAML
4. `test_empty_arty_yml` - Handle empty arty.yml
5. `test_no_source_files` - Handle project with no source files
6. `test_no_examples` - Handle project with no examples
7. `test_invalid_projects_json` - Handle invalid JSON in projects
8. `test_corrupted_json_file` - Handle corrupted JSON file
9. `test_special_chars_in_name` - Handle special characters in names
10. `test_very_long_description` - Handle very long descriptions
11. `test_binary_files_in_source` - Handle binary files in source
12. `test_permission_denied_output` - Handle permission denied on output
13. `test_missing_icon_file` - Handle missing icon file
14. `test_readme_special_markdown` - Handle special markdown in README
15. `test_deeply_nested_structure` - Handle deeply nested directories
16. `test_files_no_extension` - Handle files without extension
17. `test_both_projects_options` - Handle --projects and --projects-file together
18. `test_empty_output_name` - Handle empty output directory name
19. `test_circular_symlinks` - Handle circular symlinks

## test-leaf-integration.sh (9 tests)

1. `test_complete_docs_workflow` - Complete documentation generation workflow
2. `test_complete_landing_workflow` - Complete landing page generation workflow
3. `test_regenerate_docs` - Regenerate and overwrite existing docs
4. `test_docs_and_landing_separate` - Generate docs and landing in separate dirs
5. `test_multiple_file_types` - Handle multiple file types (sh, js, py, rb)
6. `test_debug_mode` - Debug mode provides verbose output
7. `test_special_directory_names` - Handle directories with spaces
8. `test_large_project` - Handle large projects (20+ files, 10+ examples)
9. `test_all_options_combined` - All command-line options together

---

## Test Statistics

- **Total Test Files:** 9
- **Total Test Cases:** 131
- **CLI Tests:** 18
- **Dependency Tests:** 7
- **YAML Tests:** 10
- **JSON Tests:** 14
- **Helper Tests:** 16
- **Docs Tests:** 16
- **Landing Tests:** 22
- **Error Tests:** 19
- **Integration Tests:** 9

## Coverage by Component

### Core Functionality
- ✅ Command-line interface and parsing
- ✅ Dependency checking (yq, jq)
- ✅ YAML parsing
- ✅ JSON parsing and validation
- ✅ Helper utilities

### Generation Features
- ✅ Documentation page generation
- ✅ Landing page generation
- ✅ HTML structure and styling
- ✅ Syntax highlighting integration
- ✅ Theme toggle
- ✅ Responsive design

### Error Handling
- ✅ Missing files and directories
- ✅ Corrupted input
- ✅ Invalid data
- ✅ Permission issues
- ✅ Edge cases

### Integration
- ✅ Complete workflows
- ✅ Multiple file types
- ✅ Large projects
- ✅ All options combined

## Test Execution

```bash
# Run all tests
../../judge/judge.sh __tests

# Run specific category
../../judge/judge.sh __tests/test-leaf-cli.sh
../../judge/judge.sh __tests/test-leaf-docs.sh
../../judge/judge.sh __tests/test-leaf-landing.sh
../../judge/judge.sh __tests/test-leaf-errors.sh
../../judge/judge.sh __tests/test-leaf-integration.sh

# Run with options
VERBOSE=1 ../../judge/judge.sh __tests
DEBUG=1 ../../judge/judge.sh __tests
UPDATE_SNAPSHOTS=1 ../../judge/judge.sh __tests
```

## Quick Reference by Feature

### Testing Documentation Generation
- test-leaf-docs.sh - All documentation tests
- test-leaf-yaml.sh - YAML parsing for arty.yml
- test-leaf-helpers.sh - Helper functions (language detection, file reading)

### Testing Landing Page Generation
- test-leaf-landing.sh - All landing page tests
- test-leaf-json.sh - JSON parsing for projects

### Testing CLI and Options
- test-leaf-cli.sh - Command-line interface
- test-leaf-dependencies.sh - Dependency checking

### Testing Error Handling
- test-leaf-errors.sh - All error cases and edge cases

### Testing Complete Workflows
- test-leaf-integration.sh - End-to-end integration tests

## Notes

- All tests use setup() and teardown() for isolation
- Tests create temporary directories automatically
- Each test is independent and can run alone
- Snapshots stored in __tests/snapshots/
- All edge cases and error paths covered
- Integration tests cover real-world usage

---

**Last Updated:** 2025-10-18  
**Version:** 1.0.0  
**Test Framework:** judge.sh (hammer.sh)  
**License:** MIT
