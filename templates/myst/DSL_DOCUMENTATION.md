# Template Engine DSL Documentation

## myst.sh Domain-Specific Language (DSL)

The myst template engine uses a clean, intuitive DSL based on the mustache templating philosophy with extensions for more powerful features.

## Syntax Overview

### 1. Variable Interpolation

**Syntax**: `{{variable_name}}`

**Description**: Replaces the placeholder with the value of the variable.

**Example**:
```mustache
Hello, {{name}}!
Welcome to {{site_name}}.
```

**With data**:
```json
{
  "name": "Alice",
  "site_name": "MyApp"
}
```

**Output**:
```
Hello, Alice!
Welcome to MyApp.
```

**Variable Naming Rules**:
- Must start with a letter or underscore
- Can contain letters, numbers, and underscores
- Case-sensitive
- No spaces or special characters

### 2. Conditional Blocks

#### If Statement

**Syntax**: `{{#if variable}}...{{/if}}`

**Description**: Renders content if variable is truthy.

**Truthy values**: Any non-empty value except `false`, `0`, or empty string

**Example**:
```mustache
{{#if is_admin}}
<button>Admin Panel</button>
{{/if}}
```

**With nested content**:
```mustache
{{#if user_logged_in}}
  Welcome back, {{username}}!
  {{#if has_notifications}}
    You have new messages.
  {{/if}}
{{/if}}
```

#### Unless Statement

**Syntax**: `{{#unless variable}}...{{/unless}}`

**Description**: Renders content if variable is falsy (inverse of if).

**Example**:
```mustache
{{#unless premium_user}}
<a href="/upgrade">Upgrade to Premium</a>
{{/unless}}
```

### 3. Loop Structures

**Syntax**: `{{#each collection}}...{{/each}}`

**Description**: Iterates over a collection of items.

**Current Item Reference**:
- `{{this}}` - refers to current item
- `{{.}}` - alternative syntax for current item

**Example**:
```mustache
<ul>
{{#each fruits}}
  <li>{{this}}</li>
{{/each}}
</ul>
```

**With data**:
```bash
-v fruits="Apple,Banana,Cherry,Date"
```

**Output**:
```html
<ul>
  <li>Apple</li>
  <li>Banana</li>
  <li>Cherry</li>
  <li>Date</li>
</ul>
```

**Nested Loops**:
```mustache
{{#each categories}}
Category: {{this}}
  {{#each items}}
  - {{this}}
  {{/each}}
{{/each}}
```

### 4. Partials (Template Transclusion)

**Syntax**: `{{> partial_name}}`

**Description**: Includes content from another template file.

**Partial File Naming**:
- Can be `partial_name.myst`
- Or just `partial_name`
- Located in partials directory or current directory

**Example**:

Main template `page.myst`:
```mustache
<!DOCTYPE html>
<html>
{{> head}}
<body>
  {{> header}}
  <main>{{content}}</main>
  {{> footer}}
</body>
</html>
```

Partial `_header.myst`:
```mustache
<header>
  <h1>{{site_title}}</h1>
  <nav>{{> navigation}}</nav>
</header>
```

**Usage**:
```bash
./myst.sh render page.myst -p ./partials -v site_title="My Site" -v content="Hello"
```

**Partial Variables**: Partials have access to all variables in the rendering context.

### 5. Template Inheritance

Template inheritance allows you to define a base layout and override specific sections.

#### Parent Layout

**Syntax**: `{{slot:slot_name}}`

**Description**: Defines a slot that child templates can fill.

**Example** - `layout.myst`:
```mustache
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>{{slot:title}}</title>
  {{slot:head_extra}}
</head>
<body>
  <header>{{slot:header}}</header>
  <main>{{slot:content}}</main>
  <footer>{{slot:footer}}</footer>
</body>
</html>
```

#### Child Template

**Syntax**: 
```mustache
{{#extend layout_name}}
  {{#slot slot_name}}content{{/slot}}
{{/extend}}
```

**Description**: Extends a layout and fills its slots.

**Example** - `page.myst`:
```mustache
{{#extend layout}}

{{#slot title}}
{{page_title}} - {{site_name}}
{{/slot}}

{{#slot head_extra}}
<link rel="stylesheet" href="{{css_file}}">
{{/slot}}

{{#slot header}}
<h1>{{page_title}}</h1>
<nav>{{> navigation}}</nav>
{{/slot}}

{{#slot content}}
<article>
  <h2>{{article_title}}</h2>
  <p>{{article_content}}</p>
</article>
{{/slot}}

{{#slot footer}}
<p>&copy; {{year}} {{site_name}}</p>
{{/slot}}

{{/extend}}
```

**Usage**:
```bash
./myst.sh render page.myst \
  -l layout.myst \
  -v page_title="About Us" \
  -v site_name="MyCompany" \
  -v year=2025
```

### 6. Comments

**Syntax**: `{{! comment text }}`

**Description**: Comments are ignored during rendering.

**Example**:
```mustache
{{! This is a comment and won't appear in output }}
<h1>{{title}}</h1>
{{! TODO: Add more content here }}
```

**Note**: Comment support may be limited in current version.

## Variable Sources

### 1. Command Line Arguments

```bash
./myst.sh render template.myst -v key1=value1 -v key2=value2
```

**Use case**: Quick testing, overriding specific values

### 2. JSON Files

```bash
./myst.sh render template.myst -j data.json
```

**data.json**:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30,
  "active": true
}
```

**Use case**: Structured data, API responses, configuration files

### 3. YAML Files

```bash
./myst.sh render template.myst -y config.yml
```

**config.yml**:
```yaml
site:
  name: MyWebsite
  url: https://example.com
author:
  name: Jane Smith
  email: jane@example.com
```

**Use case**: Configuration files, human-readable data

**Note**: Requires `yq` to be installed

### 4. Environment Variables

```bash
export MYST_USERNAME=alice
export MYST_ROLE=admin
./myst.sh render template.myst -e
```

**Custom prefix**:
```bash
export APP_TITLE="My Application"
export APP_VERSION="1.0.0"
./myst.sh render template.myst -e APP_
```

**Use case**: CI/CD pipelines, container environments, secrets

### 5. Standard Input

**Variables from stdin**:
```bash
echo '{"name":"Bob","role":"user"}' | ./myst.sh render template.myst --stdin-vars
```

**Template from stdin**:
```bash
echo 'Hello {{name}}!' | ./myst.sh render --stdin -v name=World
```

**Use case**: Piping data, dynamic generation

## Advanced DSL Features

### Nested Variable Access

For nested data structures, flatten the JSON first or use dot notation:

```bash
echo '{"user":{"name":"Alice","profile":{"age":30}}}' | \
  jq -r 'to_entries | map({key: .key, value: .value}) | 
  [.[] | {key: .key, value: (.value | tostring)}] | 
  from_entries' > flat.json

./myst.sh render template.myst -j flat.json
```

### Combining Multiple Sources

Variables from different sources can be combined. Later sources override earlier ones:

```bash
./myst.sh render template.myst \
  -j defaults.json \      # Base values
  -y config.yml \         # Config overrides
  -e \                    # Environment overrides
  -v final_override=value # Explicit override
```

**Precedence** (highest to lowest):
1. Command-line `-v` arguments
2. Environment variables (`-e`)
3. YAML files (`-y`)
4. JSON files (`-j`)

### Escaping

To include literal mustache syntax in output:

```mustache
To print a variable, use \{{variable\}} syntax.
```

**Note**: Escaping support may be limited in current version.

## Best Practices

### 1. Variable Naming

```mustache
✅ Good:
{{user_name}}
{{site_title}}
{{is_active}}

❌ Avoid:
{{UserName}}
{{sitetitle}}
{{x}}
```

Use descriptive, lowercase names with underscores.

### 2. Template Organization

```
templates/
  ├── layouts/
  │   └── main.myst
  ├── partials/
  │   ├── _header.myst
  │   ├── _footer.myst
  │   └── _nav.myst
  └── pages/
      ├── index.myst
      ├── about.myst
      └── contact.myst
```

### 3. Conditional Logic

```mustache
✅ Simple and clear:
{{#if show_menu}}
  {{> navigation}}
{{/if}}

⚠️ Nested but readable:
{{#if user_logged_in}}
  {{#if is_admin}}
    {{> admin_panel}}
  {{/if}}
  {{#unless is_admin}}
    {{> user_panel}}
  {{/unless}}
{{/if}}
```

Keep conditionals simple and well-indented.

### 4. Loop Usage

```mustache
✅ Clear iteration:
{{#each products}}
  <div class="product">
    <h3>{{this}}</h3>
  </div>
{{/each}}

✅ With context:
Products: {{product_count}}
{{#each products}}
  - {{this}}
{{/each}}
```

### 5. Partial Reuse

Create reusable partials for common elements:

```mustache
✅ Reusable card partial (_card.myst):
<div class="card">
  <h3>{{card_title}}</h3>
  <p>{{card_content}}</p>
</div>

Usage in multiple templates:
{{> card}}
```

## Error Handling

### Missing Variables

Missing variables are replaced with empty strings:

```mustache
Hello, {{missing_var}}!
```

Output: `Hello, !`

### Missing Partials

If a partial is not found, a warning is logged and it's replaced with empty string:

```mustache
{{> nonexistent_partial}}
```

Output: (empty)
Log: `[WARN] Partial 'nonexistent_partial' not loaded`

### Invalid Syntax

Malformed template syntax may not be caught:

```mustache
{{#if broken      ← Missing closing }}
```

Use `--debug` flag to troubleshoot.

## Performance Considerations

### Template Size

- Small templates (<100 KB): Excellent performance
- Medium templates (100 KB - 1 MB): Good performance
- Large templates (>1 MB): May be slow, consider splitting

### Optimization Tips

1. **Cache partials**: Load partials once, render multiple templates
2. **Minimize nesting**: Deep nesting slows rendering
3. **Simplify conditionals**: Fewer conditions = faster render
4. **Pre-process data**: Use `jq` for complex transformations

## Examples Library

See the `examples/` directory for complete examples:

- Basic interpolation
- Conditionals and loops
- Partials and inheritance
- Multi-source data loading
- Static site generation
- Configuration templating
- Email templates

## Extending the DSL

For custom functionality, fork `myst.sh` and add:

1. New functions following `myst_render_*` pattern
2. New syntax patterns in regular expressions
3. Call new functions in `myst_render()` pipeline

Example custom function:

```bash
myst_render_uppercase() {
    local content="$1"
    # Replace {{UPPER:var}} with uppercase value
    # ... implementation ...
    echo "$content"
}
```

## DSL Grammar (EBNF-style)

```ebnf
template     = ( text | expression )*

expression   = variable
             | conditional
             | loop
             | partial
             | inheritance
             | comment

variable     = "{{" identifier "}}"

conditional  = "{{#if" identifier "}}" template "{{/if}}"
             | "{{#unless" identifier "}}" template "{{/unless}}"

loop         = "{{#each" identifier "}}" template "{{/each}}"

partial      = "{{>" identifier "}}"

inheritance  = "{{#extend" identifier "}}" slot* "{{/extend}}"

slot         = "{{#slot" identifier "}}" template "{{/slot}}"

slot_ref     = "{{slot:" identifier "}}"

comment      = "{{!" text "}}"

identifier   = [a-zA-Z_][a-zA-Z0-9_]*

text         = any characters except "{{"
```

---

**For more information, see the main [README.md](README.md)**
