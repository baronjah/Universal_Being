# Wish Maker System Guide

## Overview

The Wish Maker system is an extension to the Eden_May game that allows users to make "wishes" using tokens. These wishes are processed through either the Gemini API (for data-focused requests) or Claude (for creative requests). The system manages token economy, tracks wish history, and provides rewards based on successful wishes.

## Key Features

### Token Management
- Default starting balance: 2,000,000 tokens (equivalent to about $1 worth of tokens)
- Wish costs scale based on complexity and user-defined token amount
- Token rewards are provided for successful wishes
- Turn-based multipliers increase rewards as you progress through turns

### API Integration
- **Gemini API Integration**: Optimized for data retrieval, analysis, and factual responses
- **Claude Integration**: Optimized for creative and generative content 
- Automatic API selection based on wish content
- Manual override available when needed

### Game Integration
- Full integration with the Turn system (turns 8-12)
- Token multipliers increase with each turn advancement
- Wish power and effectiveness scales with turn progress
- Automated wishing available during idle periods

### Wish History
- Complete tracking of all wishes
- Success/failure status for each wish
- Token amounts used and gained
- API used for processing

## How To Use

### Opening the Wish Maker

1. From the main Eden_May interface, click on the "Wish Maker" tab or button
2. Alternatively, use the command `/wish` in the main console

### Making a Wish

1. Enter your wish in the text input field
2. Adjust the token amount using the slider
   - Higher token amounts increase success chance and potential reward
   - Minimum threshold is 50 tokens
3. The API indicator will show which API will be used (Gemini or Claude)
4. Click "Make Wish" to process

### Types of Wishes

#### Data-Focused Wishes (Gemini API)
- Information retrieval 
- Data analysis
- Pattern recognition
- Statistical generation
- Search and comparison operations

#### Creative Wishes (Claude)
- Game concept generation
- Narrative creation
- Visual descriptions
- Character development
- System design and evolution

### Auto-Wish Feature

1. Enable the "Auto-Wish" toggle to automate wish making
2. System will automatically generate and process wishes every 10 seconds
3. Token amounts will vary within your specified min/max range
4. Useful for background evolution of your game while you focus on other tasks

## Token Economy

### Earning Tokens
- Initial balance: 2,000,000 tokens
- Successful wishes provide rewards based on token amount and turn multiplier
- Button to add 1,000 tokens for testing/development

### Spending Tokens
- Each wish costs a user-defined amount (minimum 50)
- Higher token amounts:
  - Increase chance of success
  - Improve quality of results
  - Increase potential reward if successful

### Turn Multipliers
- Turn 8: 1.0x reward multiplier
- Turn 9: 1.5x reward multiplier
- Turn 10: 2.0x reward multiplier
- Turn 11: 3.0x reward multiplier
- Turn 12: 5.0x reward multiplier

## Integration with Main Game

### Turn 8 (Lines) Integration
- Wishes can be used to detect and enhance line patterns
- Token rewards contribute to turn progress
- Successful wishes can trigger special line pattern configurations

### Turn 9 (Game Creation) Integration
- Wishes can generate game concepts or elements
- Token economy becomes game mechanic within created games
- Wish history influences game design options

### Gemini API Focus
The Gemini API integration provides specialized capabilities for:
- Data processing and analysis
- Information retrieval and comparison
- Pattern recognition and classification
- Learning from existing data
- Statistical calculations and number crunching

### Wish Trigger Mechanics
- Wishes require a minimum message length from the user to "trigger"
- If message is too short, the wish may fail but tokens may still be consumed
- This creates a game mechanic where precise communication matters
- Think of it as a "word power" mechanic

## Example Wishes

### Data-Focused (Gemini)
- "Analyze my wish history and show me patterns in my token usage"
- "Find correlations between token amounts and wish success rates"
- "Show me statistics on which line patterns have been most effective"
- "Search my previous wish results for insights on game creation"
- "Calculate the optimal token amount for maximum returns"

### Creative (Claude)
- "Create a new game concept that combines line patterns with wish making"
- "Design a character who represents the essence of Turn 8"
- "Generate a storyline that explains the transition from Turn 8 to Turn 9"
- "Imagine a visualization of the token economy as a physical space"
- "Develop a mini-game that could be played within the wish maker interface"

## Technical Implementation

The Wish Maker system consists of three main components:

1. **wish_maker.gd**: Core functionality for wish processing, token management, and API integration
2. **wish_maker_ui.gd**: User interface controller for wish input, token adjustment, and result display
3. **wish_maker.tscn**: Scene file that combines the system and UI

To extend or customize the system, focus on modifying:
- `determine_api_for_wish()` function to change API selection logic
- `calculate_reward()` function to adjust token rewards
- Token thresholds in the WishMaker class

## Future Development

As the Eden_May game advances through turns, the Wish Maker system will evolve:

- **Turn 9**: Integration with game creation mechanics
- **Turn 10**: Connection to multiple games and systems
- **Turn 11**: Physical manifestation of wish results
- **Turn 12**: Transcendent wishes that affect the entire system architecture