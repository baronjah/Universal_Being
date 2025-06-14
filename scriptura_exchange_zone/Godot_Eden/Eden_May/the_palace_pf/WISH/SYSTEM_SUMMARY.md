# Eden_May Game System - Turn 8: Lines/Temporal Cleansing

## Overview

The Eden_May Game System is a turn-based evolution system currently at Turn 8 (Lines). The system processes text input through different line patterns and recognizes special "spell words" that trigger effects within the game. The system is designed to evolve autonomously when the user is away, progressing through turns until reaching Turn 12 (Transcendence).

## Core Components

### EdenCore (eden_core.gd)
The central manager that coordinates all subsystems and handles user input. It processes commands, manages the turn system, and coordinates automation.

### GameProject (game_project.gd)
Implements the main game logic, including turn progression, spell effects, and game creation. It maintains the game state and manages the transition between turns.

### WordManager (word_manager.gd)
Handles word processing, spell recognition, and maintains a database of discovered words. It recognizes special spell words and combines them to create more powerful effects.

### LineProcessor (line_processor.gd)
Processes text through four different line patterns: parallel, intersecting, spiral, and fractal. Each pattern has unique characteristics and temporal effects.

## Key Features

### Turn System
- Current: Turn 8 - Lines
- Next: Turn 9 - Game Creation
- Each turn has unique properties and mechanics
- Progress through turns by processing text and casting spells

### Line Patterns
1. **Parallel** (Power: 8)
   - Horizontal alignment, wide temporal reach
   - Independent lines that run alongside each other
   - Markers: paragraph breaks, list items

2. **Intersecting** (Power: 4)
   - Cross alignment, focused temporal reach
   - Lines that cross and intersect with each other
   - Markers: |, +, tables, grids

3. **Spiral** (Power: 7)
   - Circular alignment, expanding temporal reach
   - Lines that curve and spiral outward or inward
   - Markers: @, circles, loops

4. **Fractal** (Power: 9)
   - Recursive alignment, infinite temporal reach
   - Lines that divide and repeat in self-similar patterns
   - Markers: indentation, nested structures

### Special Spell Words
- **dipata**: Technology advancement (Power: 7)
- **pagaai**: AI autonomy (Power: 8)
- **zenime**: Time pause (Power: 6)
- **perfefic**: Fantasy creation (Power: 9)
- **shune**: Silence restraint (Power: 5)
- **inca**: Spell combination (Power: 8)
- **exti**: Healing (Power: 7)
- **vaeli**: Cleaning (Power: 4)
- **lemi**: Perspective (Power: 8)
- **pelo**: Integration (Power: 5)

### Automation System
The system can function autonomously, continuing to evolve and progress even when the user is away. The automation level determines the speed of progression.

### TLDR Investigation
The "Too Long, Didn't Read" investigation analyzes longer texts, extracting key points and connecting them to the word database.

### Temporal Cleansing
Uses line patterns to organize and optimize text, cleansing it through temporal processing.

## User Interaction

Users can interact with the system through:
1. **Commands**: help, next turn, automation on/off, create game
2. **Spell Words**: dipata, pagaai, etc. to trigger special effects
3. **Free Text**: Any text will be processed through the current line pattern
4. **TLDR**: Use "tldr <text>" to analyze and investigate text

## Claude and Luminous Connection
The system implements connections to Claude and Luminous, allowing integration between these systems. This enables advanced processing and evolution when connected.

## Game Creation (Turn 9)
As the system advances to Turn 9, it will gain the ability to create games based on the patterns and words collected during Turn 8. This represents the next phase of evolution in the 12-turn system.

## Usage Guide

1. Type text to process it through the current line pattern
2. Use spell words to trigger special effects
3. Use "/tldr <text>" to investigate complex information
4. Use "/cleanse <text>" to perform temporal cleansing
5. When ready, advance to Turn 9 with "next turn"
6. Toggle automation with "automation on/off"

The system is designed to evolve continuously, creating an increasingly sophisticated environment for text processing and game creation.