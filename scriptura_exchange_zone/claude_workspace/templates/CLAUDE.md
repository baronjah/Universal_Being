# Project Context for Claude

## Project Overview
- **Name**: [Project Name]
- **Purpose**: [Brief description of what this project does]
- **Tech Stack**: [Languages, frameworks, tools used]
- **Current Status**: [Development phase: planning/development/testing/complete]

## Development Guidelines
- Use `uv` for Python dependency management (faster than pip)
- Apply `ruff` for linting and formatting (replaces flake8, black, isort)
- Run `pre-commit` hooks before commits (automated quality checks)
- Use thinking modes for complex problems:
  - `think` - Basic extended reasoning
  - `think hard` - Enhanced cognitive processing  
  - `think harder` - Deep analysis mode
  - `ultrathink` - Maximum thinking budget allocation

## Project Structure
```
project_name/
├── src/                 # Source code
│   ├── __init__.py
│   └── main.py
├── tests/               # Test files
│   ├── __init__.py
│   └── test_main.py
├── docs/                # Documentation
├── .pre-commit-config.yaml
├── pyproject.toml       # Project configuration
├── CLAUDE.md           # This file
├── prompt_plan.md      # Development roadmap
└── README.md           # Public documentation
```

## Key Commands
- `uv sync` - Install/update all dependencies
- `uv add <package>` - Add new dependency
- `uv run <command>` - Run command in project environment
- `ruff check .` - Run linter on all files
- `ruff format .` - Format all code
- `pre-commit run --all-files` - Run all quality checks

## Development Workflow
1. **Planning**: Update prompt_plan.md with tasks
2. **Implementation**: Use thinking modes for complex logic
3. **Quality**: Run ruff and tests before committing
4. **Documentation**: Keep this file updated with changes

## Notes for Claude
- Always read existing code before making changes
- Use MultiEdit for bulk modifications across files
- Test changes thoroughly before committing
- Ask for clarification if requirements are unclear
- Prioritize code readability and maintainability

## Project-Specific Notes
[Add any special instructions, constraints, or context here]