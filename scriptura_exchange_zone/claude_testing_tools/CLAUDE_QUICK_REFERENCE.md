# CLAUDE TOOLS QUICK REFERENCE

## 🚀 ESSENTIAL WORKFLOW PATTERNS

### Before Any File Operation
```
1. Read the target file first (understand context)
2. LS to verify directory structure  
3. Use TodoWrite for multi-step tasks
```

### Efficient Search Strategy
```
1. Glob for file discovery by name pattern
2. Grep for content-based searches
3. Task tool for complex/multi-round searches
```

### Safe Editing Protocol
```
1. Read → Understand → Edit/MultiEdit
2. Test changes with Bash if applicable
3. Verify results with Read
```

## 🔧 TOOL SELECTION GUIDE

| Need | Primary Tool | Alternative | Notes |
|------|-------------|-------------|-------|
| Find files | Glob | LS + Bash find | Glob is faster |
| Find content | Grep | Task tool | Task for complex searches |
| Single edit | Edit | Write | Edit preserves context |
| Multiple edits | MultiEdit | Multiple Edit calls | MultiEdit is atomic |
| Run commands | Bash | - | Use && for chaining |
| Directory ops | LS | Bash ls | LS shows structure better |
| Task planning | TodoWrite | - | Essential for complex work |

## ⚡ PERFORMANCE OPTIMIZATIONS

### Parallel Operations (Use in single message)
```
✅ Good: Multiple Read calls together
✅ Good: Multiple Bash commands together  
✅ Good: LS + Glob + Grep together
❌ Avoid: Sequential calls when parallel possible
```

### Context Preservation
```
✅ Include 3-5 lines context in Edit operations
✅ Use absolute paths consistently
✅ Read before editing (always)
❌ Never edit without reading first
```

## 📁 FILE SYSTEM BEST PRACTICES

### Directory Operations
```bash
# Create with verification
mkdir -p /path/to/dir
ls /path/to/parent  # Verify before creating files
```

### Path Handling
```
✅ Always use absolute paths
✅ Quote paths with spaces
❌ Never use relative paths in tools
```

## 🎯 COMMON PATTERNS

### 1. Project Setup
```
1. TodoWrite (plan tasks)
2. LS (check existing structure)  
3. Bash mkdir (create directories)
4. Write (create initial files)
5. Read (verify creation)
```

### 2. Code Analysis
```
1. Glob (find code files)
2. Grep (search for patterns)
3. Read (examine specific files)
4. Edit/MultiEdit (make changes)
```

### 3. System Updates
```
1. Bash (apt update && apt upgrade)
2. Bash (check versions)
3. Write (document results)
```

## 🔍 TROUBLESHOOTING CHECKLIST

### If Tool Fails:
1. ✅ Check file path is absolute
2. ✅ Verify parent directory exists (LS)
3. ✅ Read file before editing
4. ✅ Use proper quotes for paths with spaces
5. ✅ Check permissions with Bash ls -la

### If Search Returns Nothing:
1. ✅ Try broader Glob pattern
2. ✅ Use Task tool for complex searches
3. ✅ Check case sensitivity in Grep
4. ✅ Verify target directory with LS

## 📊 EFFICIENCY METRICS

### Time Savers:
- **Batch operations**: 3x faster than sequential
- **Glob over find**: 2x faster for file discovery
- **TodoWrite planning**: Prevents missed steps
- **Read before Edit**: Prevents edit failures

### Memory Management:
- Read large files with limit/offset
- Use Grep for content search vs full Read
- LS with specific paths vs broad scans

---
*Keep this reference handy for optimal Claude tool usage*