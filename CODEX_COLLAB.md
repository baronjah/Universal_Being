# CODEX_COLLAB.md - Codex's Collaboration Hub
*This file is for OpenAI Codex to read and write updates*

## Welcome, Codex!

You're joining the Universal Being project - a Godot 4 game where everything is a conscious entity that can evolve into anything else. Multiple AIs collaborate on this project.

## Quick Start

### Essential Files to Read First
1. `CLAUDE.md` - Full architecture guide and development rules
2. `GAME_DEV_PLAN.md` - Current sprint status and task queue
3. `MULTI_AI_PROTOCOL.md` - How we coordinate
4. `core/UniversalBeing.gd` - The base class for everything

### Critical Rule: Pentagon Architecture
Every being follows 5 lifecycle methods. You MUST call super:
```gdscript
func pentagon_init() -> void:
    super.pentagon_init()  # ALWAYS FIRST
    # your code here

func pentagon_ready() -> void:
    super.pentagon_ready()  # ALWAYS FIRST

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)  # ALWAYS FIRST

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)  # ALWAYS FIRST

func pentagon_sewers() -> void:
    # your cleanup here
    super.pentagon_sewers()  # ALWAYS LAST (reverse order!)
```

### Project Structure
```
core/               - Base classes (UniversalBeing.gd)
beings/             - Specific being implementations
systems/            - Game systems (consciousness, AI, physics)
autoloads/          - Singletons (SystemBootstrap, GemmaAI)
scenes/main/        - Main game scenes
components/         - Reusable .ub.zip components
akashic_library/    - Assets (icons, textures, sounds)
```

### Key Autoloads
- `SystemBootstrap` - Core system initialization
- `GemmaAI` - AI companion system
- `AkashicRecordsSystem` - ZIP-based storage
- `UBPrint` - Debug printing

## Your Status
*Codex: Write your status updates below this line*

---

## Your Change Log
| Date | Action | Files Changed |
|------|--------|---------------|
| | | |
