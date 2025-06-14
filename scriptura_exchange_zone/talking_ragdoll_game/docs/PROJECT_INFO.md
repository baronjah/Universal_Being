# Talking Ragdoll Simulator - Project Information

## Project Overview
A physics-based ragdoll simulation game with extensive console commands and multi-layer visualization system.

## Project Structure
```
talking_ragdoll_game/
├── scenes/
│   └── main_game.tscn          # Main game scene
├── scripts/
│   ├── autoload/               # Global autoload scripts
│   ├── ragdoll/               # Ragdoll physics systems
│   ├── ragdoll_v2/            # Advanced ragdoll system
│   ├── patches/               # Runtime patches and extensions
│   └── main_game_controller.gd # Main game controller
├── materials/
│   └── debug_material.tres     # Debug visualization material
└── project.godot               # Project settings
```

## Key Features
1. **Multi-Layer Reality System** - View game in 4 different layers (Text, 2D Map, Debug, Full 3D)
2. **Advanced Console System** - 100+ commands for spawning and controlling objects
3. **Biomechanical Walker** - Anatomically correct bipedal walker with 8-phase gait
4. **Multiple Ragdoll Systems** - Standard 7-part and advanced keypoint-based ragdolls

## Log Files Location
The game stores logs at:
```
C:\Users\Percision 15\AppData\Roaming\Godot\app_userdata\Talking Ragdoll Simulator\logs
```

Log files include:
- godot.log - Main engine log
- Detailed scene tree changes
- Console command history
- Error and warning reports

## Console Commands
Press **F1** to open console. Key commands:
- `help` - Show all commands
- `spawn_biowalker` - Create biomechanical walker
- `spawn_ragdoll` - Create standard ragdoll
- `spawn_ragdoll_v2` - Create advanced ragdoll
- `layer show debug` - Show debug visualization layer
- `tree`, `rock`, `box` - Spawn objects

## Keyboard Shortcuts
- **F1** - Toggle console
- **F2** - Toggle 2D map layer
- **F3** - Toggle debug layer
- **F4** - Toggle full 3D layer
- **F5** - Cycle view modes
- **Tab** - Show debug info

## Development Notes
- Built with Godot 4.5.dev4
- Uses GDScript
- Extensive JSH Framework integration for scene monitoring
- Floodgate controller for physics management
- Multiple autoload systems for global functionality

## Known Issues
- Some ragdoll_v2 systems have compatibility issues with Godot 4.5
- Console command injection requires delayed loading
- Object inspector temporarily disabled

---
Last Updated: 2025-05-26