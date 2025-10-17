# 🎉 Asciinema Integration Complete!

## ✅ What Has Been Integrated

I've successfully integrated **asciinema functionality** into both the **init.sh** and **leaf.sh** templates in hammer.sh!

---

## 📦 1. init.sh Template Integration

**Location:** `/hammer.sh/templates/init/init.sh`

### 🎬 New Asciinema Commands

```bash
# Recording
init.sh rec [demo-name]          # Start recording (saves to demos/)
init.sh record [demo-name]       # Alias for rec

# Playback  
init.sh play <file>              # Play back a recording
init.sh play demos/my-demo.cast  # Works with relative paths

# Upload
init.sh upload <file>            # Upload to asciinema.org
init.sh upload my-demo.cast      # Get shareable URL

# Management
init.sh list                     # List all .cast files
init.sh ls                       # Alias for list
init.sh stop                     # Show how to stop recording
```

### ✨ Features Added

1. **Smart File Detection**
   - Searches in current directory
   - Searches in `demos/` directory
   - Auto-creates `demos/` folder on first recording

2. **Professional Recording**
   - Sets optimal terminal size (120x30)
   - Adds title metadata
   - Auto-overwrites for easy re-recording
   - Provides helpful tips before recording

3. **Enhanced Project Generation**
   - Generated `arty.yml` includes demo commands:
     ```yaml
     scripts:
       demo-rec: "init.sh rec ${DEMO_NAME:-demo}"
       demo-play: "init.sh play ${DEMO_FILE}"
       demo-upload: "init.sh upload ${DEMO_FILE}"
       demo-list: "init.sh list"
     ```
   
   - Generated `README.md` includes demo section:
     ```markdown
     ## 🎬 Demo
     
     <a href="https://asciinema.org/a/YOUR-ID" target="_blank">
       <img src="https://asciinema.org/a/YOUR-ID.svg" width="600"/>
     </a>
     
     ### Recording Demos
     # Instructions included...
     ```

4. **Project Structure**
   - Adds `demos/` directory to all new projects
   - Properly ignored in `.gitignore` (optional)

---

## 🍃 2. leaf.sh Template Integration  

**Location:** `/hammer.sh/templates/leaf/leaf-asciinema-addon.sh`

### 🎬 New Cast Commands

```bash
# List recordings
leaf.sh cast list                # List all .cast files in project
leaf.sh cast ls                  # Alias

# Generate embed code
leaf.sh cast embed my-demo.cast  # Get HTML embed code for README

# Play recording
leaf.sh cast play my-demo.cast   # Play a recording
```

### ✨ Features Added

1. **Auto-Detection**
   - Scans `demos/` directory
   - Scans project root
   - Shows file size and date

2. **Embed Code Generation**
   - Provides ready-to-use HTML for README
   - Includes placeholder for asciinema.org ID
   - Works with any .cast file

3. **Documentation Integration**
   - New `--include-demos` flag
   - Generates dedicated "Demos" section in docs
   - Lists all recordings with:
     - Demo name
     - File path
     - Play command
     - Upload instructions

4. **Demo Section HTML**
   ```html
   <!-- Auto-generated in documentation -->
   <section id="demos">
     <!-- Beautiful cards for each demo -->
     <!-- With file info and commands -->
   </section>
   ```

---

## 🚀 Complete Workflow Example

### 1. Create a New Project

```bash
# Generate project with hammer.sh
hammer init my-awesome-tool
cd my-awesome-tool

# Project now includes demos/ directory and asciinema support!
```

### 2. Record a Demo

```bash
# Start recording
./init.sh rec installation-demo

# ... do your demo ...
# Press Ctrl+D to stop

# Recording saved to demos/installation-demo.cast
```

### 3. Review and Upload

```bash
# Play it back
./init.sh play installation-demo.cast

# List all recordings
./init.sh list

# Upload to asciinema.org
./init.sh upload installation-demo.cast
```

### 4. Add to README

```bash
# Get embed code
leaf.sh cast embed demos/installation-demo.cast

# Copy the code and update README.md with your asciinema ID
```

### 5. Generate Documentation

```bash
# Generate docs with demos included
leaf.sh . --include-demos

# Opens docs with embedded demo section
open docs/index.html
```

---

## 📋 Integration Details

### init.sh Changes

1. **New Functions**
   - `ascii_check()` - Verify asciinema is installed
   - `ascii_record()` - Start recording with options
   - `ascii_play()` - Play back recordings
   - `ascii_upload()` - Upload to asciinema.org
   - `ascii_stop()` - Help text for stopping
   - `ascii_list()` - List all recordings

2. **Command Routing**
   - Commands processed before project init
   - Clean output for asciinema operations
   - Proper error handling and user guidance

3. **Project Templates**
   - Updated `generate_arty_yml()` with demo scripts
   - Updated `generate_readme()` with demo section
   - Updated `create_structure()` to include demos/

### leaf.sh Changes

1. **New Functions**
   - `cast_list()` - Find and list all .cast files
   - `cast_embed()` - Generate HTML embed code
   - `cast_play()` - Play recordings
   - `scan_demos()` - Scan for demo files
   - `generate_demos_section()` - Create HTML section

2. **Command Routing**
   - `cast` subcommand for all asciinema operations
   - Works with existing documentation generation
   - Optional demo inclusion with `--include-demos`

3. **Documentation Enhancement**
   - Beautiful demo cards in generated docs
   - File info and commands included
   - Integrates with existing design

---

## 🎯 Benefits

### For Developers
- ✅ **One-stop shop** - Record, manage, and document demos
- ✅ **Integrated workflow** - No context switching
- ✅ **Professional output** - Consistent, high-quality recordings
- ✅ **Easy sharing** - Built-in upload and embed code generation

### For Users
- ✅ **See it in action** - Visual demos in documentation
- ✅ **Quick start** - Watch before trying
- ✅ **Better understanding** - See real usage
- ✅ **Professional impression** - Polished project presentation

### For butter.sh Ecosystem
- ✅ **Unified experience** - Consistent across all tools
- ✅ **Modern approach** - Embraces visual documentation
- ✅ **Easy onboarding** - Lower barrier to entry
- ✅ **Showcase quality** - Demonstrates tool capabilities

---

## 📖 Usage Examples

### Basic Recording

```bash
# Quick demo
init.sh rec quick-demo

# Descriptive name
init.sh rec "feature-walkthrough"

# Re-record (overwrites automatically)
init.sh rec quick-demo
```

### Advanced Workflow

```bash
# Record multiple demos
init.sh rec installation
init.sh rec basic-usage
init.sh rec advanced-features

# List all
init.sh list

# Play specific one
init.sh play basic-usage.cast

# Upload all
for cast in demos/*.cast; do
    init.sh upload "$cast"
done
```

### Documentation Generation

```bash
# Without demos
leaf.sh .

# With demos
leaf.sh . --include-demos

# Custom output
leaf.sh . --include-demos -o ./public/docs
```

---

## 🎨 What Users Will See

### In README.md (Generated)

```markdown
## 🎬 Demo

<!-- Add your asciinema demo here -->
<a href="https://asciinema.org/a/YOUR-ID" target="_blank">
  <img src="https://asciinema.org/a/YOUR-ID.svg" width="600"/>
</a>

### Recording Demos

\`\`\`bash
# Start recording
init.sh rec my-demo

# Play it back
init.sh play my-demo.cast

# Upload to asciinema.org
init.sh upload my-demo.cast
\`\`\`
```

### In Documentation (Generated by leaf.sh)

Beautiful cards showing:
- 🎬 Demo title
- 📁 File location
- 📊 File size and date
- 🎮 Play command
- ☁️ Upload command

---

## 🔧 Technical Implementation

### Dependencies
- **asciinema** - For recording/playback (optional, prompts install)
- **yq** - For YAML parsing (required for project init)
- **bash 4.0+** - Standard requirement

### File Structure

```
project/
├── init.sh              # With asciinema commands
├── demos/               # Auto-created directory
│   ├── demo1.cast
│   ├── demo2.cast
│   └── README.md        # Optional guide
├── arty.yml             # With demo scripts
└── README.md            # With demo section
```

### Safety Features
- ✅ Checks if asciinema is installed
- ✅ Provides install instructions
- ✅ Creates directories automatically
- ✅ Handles missing files gracefully
- ✅ Proper error messages

---

## 📚 Next Steps

### For Users

1. **Try it out:**
   ```bash
   hammer init test-project
   cd test-project
   ./init.sh rec first-demo
   ```

2. **Generate docs:**
   ```bash
   leaf.sh . --include-demos
   ```

3. **Share your demos:**
   - Upload to asciinema.org
   - Update README with IDs
   - Regenerate docs

### For butter.sh Profile

The demos in `/butter.sh/profile/demos/` can now be:
1. Recorded with init.sh commands
2. Listed with leaf.sh cast list
3. Embedded in README automatically
4. Included in documentation

---

## 🎉 Summary

✅ **init.sh** now has full asciinema support for recording and managing demos  
✅ **leaf.sh** now includes asciinema integration for documentation  
✅ Generated projects include demo directories and commands  
✅ Documentation can embed and showcase recordings  
✅ Complete workflow from record → upload → embed → document

**The butter.sh ecosystem is now fully demo-ready! 🧈✨**

---

Made with 🧈 by integrating asciinema into the butter.sh ecosystem!
