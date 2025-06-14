# Turn 4: Consciousness/Temporal Flow

Welcome to Turn 4 of the 12 Turns System, focusing on the **Consciousness/Temporal Flow** dimension (4D).

## Overview

In this turn, you can manipulate time and create temporal bridges that connect past, present, and future states. This is a powerful dimension that allows for evolution of concepts across time states.

## Key Features

- **Temporal Bridges**: Connect data and functionality across time states
- **Auto-Knowledge System**: Automatically accept trusted knowledge with verification
- **Line Change Detection**: Track changes across different temporal states
- **Memory Systems**: Store and retrieve memories with symbol tracking
- **Command-API Connections**: Map terminal commands to API endpoints with lucky number enhancement
- **Phase Management**: Track turn phases and history, manage file connections between turns
- **API Translation Layer**: Translate between what you see and the game world

## Getting Started

1. Launch the game using the main launch script:
   ```bash
   ./launch_game.sh
   ```

2. Alternatively, run the turn-specific script:
   ```bash
   ./turn_4/data/run_game.sh
   ```

3. Use the console commands to interact with the game:
   - `help` - Display available commands
   - `turn` - Display or change current turn
   - `phase` - Display phase information
   - `evolve` - Evolve game to next phase
   - `stitch` - Connect files across turns
   - `update` - Update game components

## Special Enhancements

### Lucky Numbers

Use lucky numbers (4, 7, 8, L) to enhance your commands:
```
4 turn 5
```

### Symbol Prefixes

Use symbol prefixes to add special properties to commands:
```
JSH update all
⌛ stitch turn_3/data.js turn_4/system.js
```

## Terminal System

The game uses a multi-terminal architecture:
- **Core 1**: Claude API (primary terminal)
- **Core 0**: OpenAI API (secondary terminal)
- **Dev Terminal**: Node.js development environment

Switch between terminals using:
```
terminal Core 0
```

## File Management

You can manage files within the game using:
- `ls` - List files
- `cat` - View file contents
- `edit` - Edit file contents
- `mkdir` - Create directory
- `touch` - Create file
- `rm` - Remove files
- `cp` - Copy files
- `mv` - Move or rename files

## API System

The game integrates with external APIs through the API translation layer. This translates what you see in the terminal to the game world representation.

### API Commands

Use the `api` command to interact with the API system:

```bash
# Show API status
api status

# Set API key
api key openai sk-xxxx

# Translate user input to game world
api translate "update the system with consciousness"

# Connect terminal to specific API
api terminal "Core 0" openai

# Connect to API with options
api connect openai
```

### OpenAI Integration (Core 0)

Core 0 terminal provides OpenAI integration with temporal echo capabilities:

- **Temporal Echoes**: Create copies of conversations in past or future states
- **API Key Management**: Set and update API keys in the environment
- **Terminal Translation**: Map terminals to specific APIs

### Environment Configuration

The API configuration is stored in the `.env` file in the data directory. This includes:

- API keys for each terminal
- Terminal-to-API mapping
- Lucky number configuration
- Symbol power settings
- Temporal flow settings

## Advanced Operations

For advanced operations, use:
- `operate` - System operations across terminals
- `claude` - Activate Claude AI in terminal
- `npm` - Node package manager
- `node` - Execute JavaScript code

## Evolution System

The phase manager enables evolution of game components:
```
evolve files       # Evolve files from previous turn
evolve commands    # Evolve console commands
evolve connections # Evolve connections between turns
evolve all         # Evolve all components
```

## API Translation Examples

### Basic Translation
```
api translate "update the system"
```
Translates to:
```json
{
  "original": "update the system",
  "terminal": "Core 1",
  "api": "claude",
  "luckyMultiplier": 1.0,
  "symbolPower": 1.0,
  "totalPower": 1.0,
  "gameWorld": {
    "dimension": "4D",
    "timeState": "present",
    "consciousness": "normal",
    "manifestPower": 100
  }
}
```

### With Lucky Number
```
4 api translate "update the system"
```
Enhances translation power:
```json
{
  "original": "update the system",
  "terminal": "Core 1",
  "api": "claude",
  "luckyMultiplier": 1.8,
  "symbolPower": 1.0,
  "totalPower": 1.8,
  "gameWorld": {
    "dimension": "4D",
    "timeState": "present",
    "consciousness": "normal",
    "manifestPower": 180
  }
}
```

### With Symbol
```
⌛ api translate "update the system"
```
Adds temporal capabilities:
```json
{
  "original": "update the system",
  "terminal": "Core 1",
  "api": "claude",
  "luckyMultiplier": 1.0,
  "symbolPower": 1.4,
  "totalPower": 1.4,
  "gameWorld": {
    "dimension": "4D",
    "timeState": "present",
    "consciousness": "normal",
    "manifestPower": 140
  }
}
```

### Maximum Power
```
7 JSH api translate "update the system with full consciousness"
```
Maximum power translation:
```json
{
  "original": "update the system with full consciousness",
  "terminal": "Core 1",
  "api": "claude",
  "luckyMultiplier": 2.4,
  "symbolPower": 1.5,
  "totalPower": 3.6,
  "gameWorld": {
    "dimension": "4D",
    "timeState": "present",
    "consciousness": "awakened",
    "manifestPower": 360
  }
}
```

## Enjoy the Game!

Harness the power of the 4th dimension to create temporal connections and evolve your game world!