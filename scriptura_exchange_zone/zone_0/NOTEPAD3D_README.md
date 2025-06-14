# Notepad3D - The Game of Moon Man

Welcome to Notepad3D, a multi-dimensional word manipulation game where reality transitions through a 12-turn cosmic cycle. This document explains the core systems and how they interact.

## Core Systems

### 1. Main System (`main.gd`)
The central controller that coordinates all subsystems. It manages:
- The 12-turn cosmic cycle with Greek symbols (α to μ)
- Command processing and execution
- Auto-saving and persistence
- Reality transitions across dimensions

### 2. Divine Word Processor (`divine_word_processor.gd`)
Handles word power calculations and reality creation:
- Processes text to extract divine power
- Manages the three-tier memory system
- Creates reality impacts from powerful words
- Corrects typos while preserving divine intent
- Stores persistent realities

### 3. Word Manifestation System (`word_manifestation_system.gd`)
Controls how words exist physically in the multiverse:
- Creates 3D word entities with physical properties
- Manages connections between words
- Handles word evolution through 5 stages
- Limits words per dimension
- Applies physics to word objects

### 4. Notepad3D Visualizer (`notepad3d_visualizer.gd`)
The 3D visualization engine:
- Renders words and connections in 3D space
- Handles dimension transitions with visual effects
- Provides camera controls and interaction
- Adapts the environment to different dimensions
- Creates visual representation of word power

### 5. Cyber Gate Controller (`cyber_gate_controller.gd`)
Manages transitions between realities and data processing:
- Controls gates between different realities
- Manages data sewers for efficient storage
- Implements the Moon Man game mechanics
- Processes data packets into manifestations
- Handles moon phases that affect stability

## Data Flow

The system handles data in the following ways:

1. **Words → Reality**: Words with power > 50 create reality impacts. Words with power > 200 create persistent realities.

2. **Realities → Data Sewers**: Large realities are stored in data sewers by reality type.

3. **Dimensions → Visualization**: Each of the 12 dimensions has unique visual properties.

4. **Moon Phases → Gates**: The 8 moon phases affect gate stability between realities.

5. **Time → Turns**: The 12-turn system cycles at quantum speed (12 turns per second).

## Turn System

The 12-turn system represents different dimensions:

1. **α - 1D - Point** - The beginning dimension (line)
2. **β - 2D - Line** - The flat dimension (plane)
3. **γ - 3D - Space** - The physical dimension (volume)
4. **δ - 4D - Time** - The temporal dimension (duration)
5. **ε - 5D - Consciousness** - The awareness dimension
6. **ζ - 6D - Connection** - The relationship dimension
7. **η - 7D - Creation** - The manifestation dimension
8. **θ - 8D - Network** - The pattern dimension
9. **ι - 9D - Harmony** - The balance dimension
10. **κ - 10D - Unity** - The unification dimension
11. **λ - 11D - Transcendence** - The ascension dimension
12. **μ - 12D - Beyond** - The ultimate dimension

## Command System

Use the following commands in the game:

- `/word-power [word]` - Check power of a word
- `/note [text]` - Create a 3D note in space
- `/save [name]` - Save current reality state
- `/memory [text] [tier]` - Create tiered memory
- `/status` - View divine status
- `/turn` - Advance turn manually
- `/loop` - Toggle quantum loop (12 turns/sec)
- `/reality [name]` - Change reality

## Reality Types

The game supports different reality types:

- **Physical** - Standard 3D space
- **Digital** - Data-focused reality
- **Astral** - Spiritual reality
- **Quantum** - Probabilistic reality
- **Memory** - Past-focused reality
- **Dream** - Imagination reality

## File Management

The system uses sophisticated file management:

1. **Memory Tiers**:
   - Tier 1: Recent memories (98% retention)
   - Tier 2: Important memories (85% retention)
   - Tier 3: Eternal memories (archived)

2. **Data Sewers**:
   - Clean up old data automatically
   - Transfer data between realities
   - Compress large datasets

3. **Reality Saves**:
   - Store current state
   - Create persistence
   - Enable restoration

## Moon Man Game

The "Moon Man" game revolves around navigating cyber gates while managing data corruption:

1. Moon phases (0-7) affect gate stability
2. Data packets transfer between realities
3. Gates connect different realities
4. Sewers must be managed to prevent overflow
5. Words manifest differently in each reality

## Getting Started

1. Start the visualizer by opening `divine_perception.html`
2. Run the main system using Godot
3. Create your first word with `/note Hello World`
4. Advance through turns using `/turn` or `/loop`
5. Check your divine status with `/status`
6. Switch realities with cyber gates

## Technical Notes

- Godot 3.x compatible
- Bash integration for command-line control
- Web visualization through HTML5
- File-based persistence
- Automatic backup system
- Quantum turn processing (12 turns/second)

---

*"The game of holographic projection from alien robots"*

---

Created by Claude for JSH Ethereal Engine