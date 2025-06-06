# Agent Collaboration Guide

Welcome to the **Universal Being** repository. This project uses a four-agent workflow. Each agent performs specialized tasks so that the game architecture stays clean and functional.

## Roles
1. **🏗️ Architect** – plan features and design new systems.
2. **🎮 Programmer** – implement GDScript and fix issues.
3. **🧪 Validator** – run tests and verify behaviour.
4. **📚 Documentation** – update guides and maintain docs.

Refer to `CLAUDE.md` and `CLAUDE_CODE.md` for the full multi-agent workflow.

## Conventions
- Scripts use `snake_case.gd` and classes use PascalCase.
- Scenes end with `.tscn`.
- Use `res://scenes/main/camera_point.tscn` for any camera socket.

## Development Flow
1. Start tasks from the repository root.
2. After modifications, run the Godot test suite:
   ```bash
   godot --headless --script tests/run_tests.gd
   ```
3. Keep commit messages short and descriptive.
4. Ensure documentation stays up to date with code changes.
