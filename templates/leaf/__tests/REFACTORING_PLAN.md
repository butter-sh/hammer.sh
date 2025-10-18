# CRITICAL REFACTORING NEEDED: leaf.sh

## Current State
leaf.sh currently generates HTML inline using heredocs and sed replacements. This approach:
- ❌ Has sed escaping issues causing test failures
- ❌ Mixes logic and presentation
- ❌ Is hard to maintain
- ❌ Duplicates code

## Desired State
leaf.sh should use myst.sh templating engine with existing templates:
- ✅ `/templates/leaf/templates/docs.html.myst` for documentation
- ✅ `/templates/leaf/templates/landing.html.myst` for landing pages
- ✅ `/templates/leaf/templates/partials/` for shared components

## Required Changes

### 1. Remove Inline HTML Generation
Delete these functions that generate HTML inline:
- `generate_docs_html()` - lines ~650-790
- The entire heredoc blocks in `generate_landing_page()` - lines ~820-1020

### 2. Add Myst Integration
Add function to use myst.sh:
```bash
render_with_myst() {
    local template="$1"
    local output="$2"
    local json_data="$3"
    
    # Find myst.sh (should be in .arty/bin or sibling directory)
    local myst_path=""
    if [[ -x ".arty/bin/myst" ]]; then
        myst_path=".arty/bin/myst"
    elif [[ -x "../myst/myst.sh" ]]; then
        myst_path="../myst/myst.sh"
    else
        log_error "myst.sh not found"
        return 1
    fi
    
    # Write JSON data to temp file
    echo "$json_data" > /tmp/leaf_data.json
    
    # Render with myst
    bash "$myst_path" render \
        -t "$template" \
        -j /tmp/leaf_data.json \
        -p "$(dirname "$template")/partials" \
        -o "$output"
    
    rm -f /tmp/leaf_data.json
}
```

### 3. Refactor generate_docs_page()
Instead of generating HTML, prepare JSON data:
```bash
generate_docs_page() {
    # ...existing code to gather data...
    
    # Prepare JSON data for myst
    local data_json=$(jq -n \
        --arg name "$project_name" \
        --arg version "$project_version" \
        --arg desc "$project_desc" \
        --arg icon "$icon_svg" \
        --arg readme "$readme_content" \
        --arg github "$GITHUB_URL" \
        --arg base "$BASE_PATH" \
        --arg src_html "$src_html" \
        --arg ex_html "$ex_html" \
        '{
            project_name: $name,
            project_version: $version,
            project_description: $desc,
            icon: $icon,
            readme_content: $readme,
            github_url: $github,
            base_path: $base,
            source_files_html: $src_html,
            examples_html: $ex_html,
            myst_enabled: "true"
        }')
    
    # Render using myst
    render_with_myst \
        "templates/docs.html.myst" \
        "${OUTPUT_DIR}/index.html" \
        "$data_json"
}
```

### 4. Refactor generate_landing_page()
Similar approach for landing pages:
```bash
generate_landing_page() {
    # ...existing code...
    
    local data_json=$(jq -n \
        --arg logo "$logo_svg" \
        --arg base "$BASE_PATH" \
        --arg github "$GITHUB_URL" \
        --argjson projects "$projects" \
        '{
            logo: $logo,
            base_path: $base,
            github_url: $github,
            site_name: "butter.sh",
            hero_tagline: "Modern bash development tools for the command line renaissance",
            primary_cta_text: "Explore Projects",
            primary_cta_url: $github,
            secondary_cta_text: "Learn More",
            secondary_cta_url: "#projects",
            projects_section_title: "Our Projects",
            projects_json: $projects
        }')
    
    render_with_myst \
        "templates/landing.html.myst" \
        "${OUTPUT_DIR}/index.html" \
        "$data_json"
}
```

## Benefits

1. **No More Sed Escaping Issues** ✅
   - myst.sh handles all escaping internally
   - No more `${$icon}` syntax errors
   - No more "Nicht beendeter »s«-Befehl" errors

2. **Separation of Concerns** ✅
   - Templates in `.myst` files
   - Logic in `.sh` files
   - Easy to modify design without touching logic

3. **Maintainability** ✅
   - Templates can be edited by designers
   - No need to escape special characters manually
   - Reusable partials

4. **Consistency** ✅
   - Uses same templating engine as rest of butter.sh ecosystem
   - Follows established patterns

## Implementation Priority

🔴 **CRITICAL** - This refactoring will fix:
- All sed syntax errors
- Icon insertion failures
- Special character handling
- Test failures related to HTML generation

## Next Steps

1. Backup current leaf.sh
2. Refactor to use myst.sh
3. Test with existing myst templates
4. Run full test suite
5. Update documentation

---

**Status**: ANALYSIS COMPLETE - READY FOR IMPLEMENTATION
**Impact**: HIGH - Will fix majority of remaining test failures
**Complexity**: MEDIUM - Clean refactoring with clear structure
