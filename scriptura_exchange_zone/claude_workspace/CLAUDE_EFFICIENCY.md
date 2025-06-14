# Claude Code Efficiency Guide (May 2025)

## Magic Thinking Commands (NEW!)
- `think` - Basic extended reasoning
- `think hard` - Enhanced cognitive processing  
- `think harder` - Deep analysis mode
- `ultrathink` - Maximum thinking budget allocation

## Quick Command Reference
- `claude init` - Initialize new project (CLI currently broken)
- `claude status` - Check current setup (CLI currently broken)
- `claude --help` - Get help for specific command (CLI currently broken)

⚠️  **CLI Status**: Currently broken (yoga.wasm module issue) - Core tools still functional

## File Operation Best Practices
1. **Always Read Before Edit**: Understand file structure first
2. **Use MultiEdit for Bulk Changes**: More efficient than multiple edits
3. **Combine Bash Commands**: Use && for sequential operations
4. **Cache Search Results**: Store glob/grep results for reuse

## Project Setup Best Practices (2025)
1. **Create CLAUDE.md in project root** - Provides context to Claude
2. **Write clear prompt_plan.md** - Systematic development approach
3. **Set up pre-commit hooks** - Automatic code quality checks
4. **Use uv for Python dependencies** - Modern package management
5. **Enable thinking modes for complex tasks** - Better problem solving

## Enhanced Workflow Patterns
```bash
# Modern Project Setup Pattern
WRITE(CLAUDE.md) → WRITE(prompt_plan.md) → BASH(uv init) → BASH(git init)

# Thinking-Enhanced Analysis Pattern  
ultrathink "analyze this codebase" → GLOB(*.py) → GREP(patterns) → READ(findings)

# Quality-First Development Pattern
WRITE(code) → BASH(ruff check) → BASH(pre-commit run) → EDIT(fixes)
```

## Performance Tips
- Batch multiple READ operations
- Use specific paths in LS calls
- Combine BASH commands with &&
- Use TASK tool for complex searches
- Leverage TODO tools for project management

## Directory Structure
```
claude_workspace/
├── projects/     # Active development
├── templates/    # Reusable patterns
├── scripts/      # Helper scripts
└── logs/         # Operation logs
```

## Working Tools (All Functional)
✅ READ - File content reading
✅ WRITE - File creation/overwriting  
✅ EDIT - Precise string replacement
✅ MULTIEDIT - Bulk modifications
✅ LS - Directory listing
✅ GLOB - Pattern file discovery
✅ GREP - Content searching
✅ BASH - Command execution
✅ TASK - Agent-based searches
✅ WEBFETCH - URL content retrieval
✅ WEBSEARCH - Web searching
✅ NOTEBOOKREAD/EDIT - Jupyter notebooks
✅ TODO tools - Task management

## CLI Workaround
Since the Claude CLI is currently broken, use the core tools directly:
- File operations: READ, WRITE, EDIT, MULTIEDIT
- System operations: BASH commands
- Project management: TODO tools
- Search operations: GLOB, GREP, TASK

*All essential functionality is available through the core tools.*