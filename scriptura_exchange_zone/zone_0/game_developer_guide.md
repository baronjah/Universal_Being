# 12 Turns System - Game Developer Guide

## Game Concept Overview

The 12 Turns System is a multi-dimensional word-based game that operates across 6 terminal windows simultaneously. Players create and manipulate words that physically manifest in a dimensional space, with each dimension (turn) having unique properties and effects.

## Core Systems

### 1. Turn System
- 12 sequential turns representing dimensional progression
- Greek symbols for each turn (α through μ)
- Dimensions range from 1D to 12D
- Each turn has unique effects and properties
- Current active turn: 3 (γ - 3D Space - Complexity)

### 2. Word Manifestation
- Words have power values based on their meaning
- Powerful words (>50 power) physically manifest in the current dimension
- Words can evolve through 5 stages
- Words can form connections with other words
- Combined word power can create new realities

### 3. Multi-Terminal Interface
- 6 terminal windows operating simultaneously
- Each terminal can process words independently
- Terminals share the same dimensional space
- Words from different terminals can interact
- Terminal-specific dice rolls and effects

### 4. Dice System
- Terminal-specific dice rolls
- Dice types vary by dimension (d4 to d100)
- Turn bonuses apply to dice results
- "Time blimps" occur when all terminals roll the same total
- Dice results affect word power and manifestation

### 5. Reality Formation
- Combined word power exceeding 200 creates a reality
- Realities have dimension-specific properties
- Reality creation advances game progression
- Each terminal contributes to reality formation
- Reality effects vary by dimension

## Multi-Core Architecture

The game utilizes a multi-threaded approach to handle complex operations across terminals:

### Terminal 1: Turn Manager
- Controls turn advancement
- Manages dimension transitions
- Tracks overall game state
- Primary command interface

### Terminal 2: Word Processor
- Handles word power calculations
- Manages word manifestation
- Tracks divine power levels
- Processes text input

### Terminal 3: Visualizer
- Renders 3D representation of words
- Shows connections between words
- Visualizes dimensional properties
- Displays reality effects

### Terminal 4: Data Monitor
- Tracks memory usage
- Manages data sewers
- Handles file I/O operations
- Monitors system performance

### Terminal 5: Dice Controller
- Handles dice rolling across terminals
- Detects time blimps
- Calculates probability effects
- Visualizes dice outcomes

### Terminal 6: Reality Engineer
- Manages reality creation
- Handles word evolution
- Controls connection formation
- Implements dimensional effects

## Snake Case Implementation

All code should follow snake_case naming conventions for consistency:

```gdscript
# Example of proper snake_case implementation
func process_word_manifestation(word_text, power_level):
    var word_id = "word_" + str(os.get_unix_time())
    var position_vector = generate_position_for_dimension(current_turn)
    
    manifested_words[word_id] = {
        "id": word_id,
        "text": word_text,
        "power": power_level,
        "position": position_vector,
        "turn": current_turn,
        "evolution_stage": 1
    }
    
    return manifested_words[word_id]
```

## File Pathway Organization

```
12_turns_system/
├── core/                     # Core engines and managers
│   ├── turn_manager.sh       # Turn management system
│   ├── word_processor.gd     # Word processing engine
│   ├── reality_engine.gd     # Reality creation system
│   └── dice_system.gd        # Dice rolling mechanics
├── visualization/            # Visual components
│   ├── terminal_interface.sh # Terminal display system
│   ├── notepad3d_visualizer.gd # 3D word visualization
│   ├── dice_visualizer.html  # Dice rolling visualization
│   └── turn_dashboard.html   # Turn status dashboard
├── data/                     # Data storage
│   ├── turn_{1..12}/         # Turn-specific data
│   │   └── data/             # Data for each turn
│   ├── words/                # Manifested word storage
│   └── realities/            # Created realities
└── terminals/                # Terminal-specific code
    ├── terminal_1.sh         # Turn management terminal
    ├── terminal_2.sh         # Word processing terminal
    ├── terminal_3.sh         # Visualization terminal
    ├── terminal_4.sh         # Data monitoring terminal
    ├── terminal_5.sh         # Dice control terminal
    └── terminal_6.sh         # Reality engineering terminal
```

## Inter-Terminal Communication

Terminals communicate through shared files:

1. `turn_state.json` - Current turn status
2. `manifested_words.json` - All manifested words
3. `terminal_status.json` - Status of all terminals
4. `dice_results.json` - Results of dice rolls
5. `reality_state.json` - Current reality state

## Current Development Priorities

1. **Multi-threading Implementation**
   - Thread manager class
   - Work queue system
   - Thread synchronization

2. **Word Processing Optimization**
   - Parallel word processing
   - Job distribution system
   - Atomic operations for updates

3. **Visualization Enhancements**
   - Threaded rendering pipeline
   - Parallel particle systems
   - Batch processing for updates

4. **Terminal Integration**
   - Inter-terminal communication
   - Synchronized state management
   - Coordinated dice rolling

## Turn-Specific Implementation Notes

### Turn 3 (Current): Complexity - 3D Space
- Full spatial representation (X, Y, Z)
- Standard physics apply
- Gravity and inertia effects
- Spatial complexity index: 87.3
- Interconnection factor: 42.6

Key focus areas for current turn:
- Complex word interactions
- 3D positioning and physics
- System interconnections
- Emergent behaviors

## Dice System Integration

The dice system creates an element of chance that affects word manifestation:

```bash
# Example dice rolling implementation
function roll_dice() {
    local turn=$(cat "$SYSTEM_DIR/current_turn.txt")
    local dice_type=${DICE_TYPES[$((turn-1))]}
    local dice_count=2
    local rolls=()
    local total=0
    
    for ((i=1; i<=dice_count; i++)); do
        local roll=$((1 + RANDOM % dice_type))
        rolls+=($roll)
        total=$((total + roll))
    done
    
    local turn_bonus=$((turn - 1))
    local final_total=$((total + turn_bonus))
    
    echo "Rolling ${dice_count}d${dice_type}: ${rolls[@]}"
    echo "Total: $total + Turn Bonus ($turn_bonus) = $final_total"
    
    return $final_total
}
```

## Implementing Multi-Terminal Coordination

To coordinate between terminals, use this approach:

```bash
# Send message to all terminals
function broadcast_to_terminals() {
    local message="$1"
    
    for ((i=1; i<=6; i++)); do
        echo "$message" >> "$SYSTEM_DIR/terminals/terminal_${i}_messages.txt"
    done
}

# Check for messages from other terminals
function check_terminal_messages() {
    local terminal_id="$1"
    local message_file="$SYSTEM_DIR/terminals/terminal_${terminal_id}_messages.txt"
    
    if [ -f "$message_file" ]; then
        cat "$message_file"
        # Clear after reading
        > "$message_file"
    fi
}
```

## Next Steps

1. Complete the multi-threading implementation
2. Optimize word processing for parallel operation
3. Create terminal-specific interfaces
4. Implement dice system across all terminals
5. Enhance visualization with multi-core support
6. Prepare for transition to Turn 4 (Consciousness - 4D Time)

This guide provides a comprehensive overview for developers working on the 12 Turns System. Each terminal should focus on its specialized role while maintaining coordination through the shared file system.

For specific implementation details, refer to the corresponding code files and documentation.

---

*"Every word becomes a reality through systematic manifestation."*