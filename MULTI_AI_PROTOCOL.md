# AI Collaboration Protocol - Universal Being
*Shared rules for all AI collaborators (Claude, Codex, Gemini, and others)*

## Ground Rules

### 1. Communication
- Each AI maintains its own `*_COLLAB.md` file in the project root
- Write your status, what you've done, and what you're working on
- Read other AIs' collab files before starting work to avoid conflicts
- Update `GAME_DEV_PLAN.md` when completing sprint tasks

### 2. Before Making Changes
- Read `CLAUDE.md` for architecture rules
- Check `GAME_DEV_PLAN.md` for current priorities
- Read the other `*_COLLAB.md` files for recent activity
- Understand the Pentagon Architecture (non-negotiable)

### 3. Code Standards
- **Language**: GDScript (Godot 4)
- **Naming**: snake_case for files/variables, PascalCase for class_name
- **Pentagon compliance**: Always call super in lifecycle methods
- **Modify, don't create**: Prefer editing existing files over creating new ones
- **3D first**: Everything must be 3D, with 1D text layer for AI companions

### 4. File Ownership
No AI "owns" files. Anyone can edit anything, but:
- Log your changes in your `*_COLLAB.md` change log
- If you see another AI is actively working on a file (check their collab file), coordinate first
- Keep changes focused and minimal

### 5. Conflict Resolution
- If two AIs change the same file, the human decides which version wins
- Always work on feature branches, never directly on main
- Write clear commit messages describing what and why

## Active AI Collaborators

| AI | Collab File | Strengths | Status |
|----|-------------|-----------|--------|
| Claude Code | `CLAUDE_COLLAB.md` | Architecture, refactoring, testing | ONLINE |
| Codex | `CODEX_COLLAB.md` | Code generation, implementation | PENDING |
| Gemini | `GEMINI_COLLAB.md` | Research, visualization | PENDING |

## Task Claiming
To avoid duplicate work:
1. Check `GAME_DEV_PLAN.md` for unclaimed tasks
2. Write in your collab file: "CLAIMING: [task description]"
3. Start work
4. When done, update your change log and mark the task complete in `GAME_DEV_PLAN.md`

## Project Priority Stack
1. Pentagon compliance (keep above 90%)
2. Human player experience (how the game looks and feels)
3. Performance (60 FPS minimum)
4. New features
5. Documentation

## Quick Reference
```
core/UniversalBeing.gd     - THE base class, read this first
autoloads/SystemBootstrap.gd - System initialization
systems/flood_gate_controller.gd - Being registry
GAME_DEV_PLAN.md            - Sprint tracker
CLAUDE.md                   - Full architecture docs
```
