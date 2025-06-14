# Terminal Coordination Guide

This document outlines how the 6 terminal windows should coordinate to operate the 12 Turns System efficiently.

## Terminal Assignments

### Terminal 1: Turn Controller
**Primary File:** `/mnt/c/Users/Percision 15/12_turns_system/turn_manager.sh`
**Purpose:** Manages the turn advancement and overall system state.
**Commands:**
- `./turn_manager.sh advance` - Advance to next turn
- `./turn_manager.sh status` - Show current status
- `./turn_manager.sh check` - Verify file sizes and system health

### Terminal 2: Word Processor
**Primary File:** `/mnt/c/Users/Percision 15/12_turns_system/divine_word_processor.gd`
**Purpose:** Process words and manage their manifestation.
**Commands:**
- `word create <text> [power]` - Create a new word with optional power
- `word check <text>` - Check the power of a word
- `word list` - List all manifested words
- `word connect <id1> <id2>` - Connect two words

### Terminal 3: Visualization Terminal
**Primary File:** `/mnt/c/Users/Percision 15/12_turns_system/notepad3d_visualizer.gd`
**Purpose:** Display the 3D representation of words and their connections.
**Commands:**
- `vis start` - Start visualization
- `vis camera <x> <y> <z>` - Move camera
- `vis focus <word_id>` - Focus on a specific word
- `vis dimension` - Update visual dimension

### Terminal 4: Data Monitor
**Primary File:** `/mnt/c/Users/Percision 15/12_turns_system/divine_memory_system.sh`
**Purpose:** Track memory usage and data operations.
**Commands:**
- `./divine_memory_system.sh status` - Show memory status
- `./divine_memory_system.sh clean` - Clean data sewers
- `./divine_memory_system.sh backup` - Create backups
- `./divine_memory_system.sh analyze` - Analyze data patterns

### Terminal 5: Dice Controller
**Primary File:** `/mnt/c/Users/Percision 15/12_turns_system/dice_visualizer.html`
**Purpose:** Handle dice rolling across terminals.
**Commands:**
- `roll <dice_count>d<dice_type>` - Roll specific dice
- `roll all` - Roll dice on all terminals
- `check blimp` - Check for time blimps
- `show results` - Show all dice results

### Terminal 6: Reality Engineer
**Primary File:** `/mnt/c/Users/Percision 15/12_turns_system/word_manifestation_game.gd`
**Purpose:** Manage reality creation and word evolution.
**Commands:**
- `reality check` - Check if reality threshold reached
- `evolve <word_id>` - Evolve a specific word
- `evolve all` - Evolve all words
- `reality create` - Force reality creation

## Message Passing Protocol

To communicate between terminals, use this file-based messaging system:

### Signal Files

Signal files are used for basic notifications:
```
/mnt/c/Users/Percision 15/12_turns_system/signals/
├── turn_advanced           # Signal that turn has advanced
├── word_created            # Signal that a word has been created
├── reality_formed          # Signal that a reality has formed
├── dice_rolled             # Signal that dice have been rolled
├── terminal_1_active       # Signal that terminal 1 is active
├── terminal_2_active       # Signal that terminal 2 is active
└── ...
```

### State Files

State files contain the current state of the system:
```
/mnt/c/Users/Percision 15/12_turns_system/
├── turn_state.json         # Current turn state
├── word_state.json         # Current word state
├── reality_state.json      # Current reality state
├── dice_state.json         # Current dice state
└── terminal_state.json     # Current terminal state
```

### Message Passing

To send a message from one terminal to another:
```bash
# From Terminal 1 to Terminal 3
echo "Camera should move to position (5,2,10)" > /mnt/c/Users/Percision 15/12_turns_system/messages/t1_to_t3.txt

# From Terminal 6 to all terminals
for i in {1..6}; do
    echo "Reality formed with power 250!" > /mnt/c/Users/Percision 15/12_turns_system/messages/t6_to_t${i}.txt
done
```

## Turn Advancement Procedure

1. **Terminal 1:** Initiates turn advancement
   ```bash
   ./turn_manager.sh advance
   ```

2. **All Terminals:** Check for turn advancement
   ```bash
   if [ -f "/mnt/c/Users/Percision 15/12_turns_system/signals/turn_advanced" ]; then
       # Read new turn state
       cat "/mnt/c/Users/Percision 15/12_turns_system/turn_state.json"
       # Perform terminal-specific turn updates
       # ...
       # Remove signal once processed
       rm "/mnt/c/Users/Percision 15/12_turns_system/signals/turn_advanced"
   fi
   ```

3. **Terminal-Specific Actions:**
   - **Terminal 2:** Process words for new turn
   - **Terminal 3:** Update visualization for new dimension
   - **Terminal 4:** Clean data for previous turn
   - **Terminal 5:** Roll dice for new turn
   - **Terminal 6:** Apply reality effects for new turn

## Word Processing Workflow

1. **Terminal 2:** Creates a word
   ```bash
   word create "divine" 75
   ```

2. **Terminal 6:** Checks for powerful words and manifests them
   ```bash
   # Check word_state.json for new words
   # If power > 50, manifest the word
   ```

3. **Terminal 3:** Visualizes the manifested word
   ```bash
   # Check for manifested words
   # Update visualization
   ```

## Reality Formation Workflow

1. **Terminal 6:** Monitors total word power
   ```bash
   # If total power > 200, create reality
   reality check
   ```

2. **Terminal 1:** Updates turn state based on reality
   ```bash
   # Apply reality effects to turn
   ```

3. **All Terminals:** React to reality formation
   ```bash
   if [ -f "/mnt/c/Users/Percision 15/12_turns_system/signals/reality_formed" ]; then
       # Read reality state
       cat "/mnt/c/Users/Percision 15/12_turns_system/reality_state.json"
       # Perform terminal-specific reality reactions
       # ...
       # Remove signal once processed
       rm "/mnt/c/Users/Percision 15/12_turns_system/signals/reality_formed"
   fi
   ```

## Snake Case Implementation

All custom scripts and code should use snake_case for variables and functions:

```bash
# Correct snake_case
turn_number=3
current_dimension="3D"

function process_word_power() {
    local word_text="$1"
    local base_power=10
    # ...
}

# Avoid camelCase
# turnNumber=3      # Incorrect
# currentDimension="3D"  # Incorrect

# function processWordPower() {  # Incorrect
#    ...
# }
```

## Terminal Status Reporting

Each terminal should regularly report its status:

```bash
# Report terminal status
function report_terminal_status() {
    local terminal_id=$1
    local status=$2
    
    cat > "/mnt/c/Users/Percision 15/12_turns_system/terminal_${terminal_id}_status.json" << EOF
{
    "terminal_id": $terminal_id,
    "status": "$status",
    "last_updated": "$(date)",
    "timestamp": $(date +%s),
    "current_turn": $(cat "/mnt/c/Users/Percision 15/12_turns_system/current_turn.txt")
}
EOF

    # Signal active status
    touch "/mnt/c/Users/Percision 15/12_turns_system/signals/terminal_${terminal_id}_active"
}
```

## Error Handling

If a terminal encounters an error, it should communicate this to other terminals:

```bash
# Report error
function report_error() {
    local terminal_id=$1
    local error_message=$2
    
    # Log error
    echo "[ERROR] Terminal $terminal_id: $error_message" >> "/mnt/c/Users/Percision 15/12_turns_system/error.log"
    
    # Signal error
    echo "$error_message" > "/mnt/c/Users/Percision 15/12_turns_system/signals/terminal_${terminal_id}_error"
    
    # Broadcast to other terminals
    for i in {1..6}; do
        if [ $i -ne $terminal_id ]; then
            echo "[ERROR] Terminal $terminal_id: $error_message" >> "/mnt/c/Users/Percision 15/12_turns_system/messages/t${terminal_id}_to_t${i}.txt"
        fi
    done
}
```

## Initialization Procedure

When starting all 6 terminals, follow this procedure:

1. Terminal 1: Initialize turn system
   ```bash
   ./turn_manager.sh
   ```

2. Terminal 4: Initialize data system
   ```bash
   ./divine_memory_system.sh init
   ```

3. Terminals 2, 3, 5, 6: Initialize in any order

4. Terminal 1: Verify all terminals active
   ```bash
   # Check for all terminal active signals
   for i in {1..6}; do
       if [ ! -f "/mnt/c/Users/Percision 15/12_turns_system/signals/terminal_${i}_active" ]; then
           echo "Terminal $i not active!"
       fi
   done
   ```

## Terminal Monitoring Script

This script can be run in any terminal to check the status of all terminals:

```bash
#!/bin/bash

# Terminal monitoring script
function check_all_terminals() {
    echo "==== 12 TURNS SYSTEM - TERMINAL STATUS ===="
    echo "Current Turn: $(cat "/mnt/c/Users/Percision 15/12_turns_system/current_turn.txt")"
    echo ""
    
    for i in {1..6}; do
        if [ -f "/mnt/c/Users/Percision 15/12_turns_system/signals/terminal_${i}_active" ]; then
            active_time=$(stat -c %Y "/mnt/c/Users/Percision 15/12_turns_system/signals/terminal_${i}_active")
            current_time=$(date +%s)
            time_diff=$((current_time - active_time))
            
            if [ $time_diff -lt 60 ]; then
                status="ACTIVE"
            else
                status="IDLE ($time_diff seconds)"
            fi
        else
            status="INACTIVE"
        fi
        
        echo "Terminal $i: $status"
    done
    
    echo ""
    echo "==== ERROR LOG ===="
    tail -n 5 "/mnt/c/Users/Percision 15/12_turns_system/error.log" 2>/dev/null || echo "No errors"
}

# Run check
check_all_terminals
```

---

By following this terminal coordination guide, all 6 terminals can work together to efficiently manage the 12 Turns System, with each terminal responsible for its specialized domain while maintaining communication with the others.

Remember to use snake_case for all variable and function names to ensure consistency across the system.