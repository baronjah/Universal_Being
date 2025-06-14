# Memory Investment System

The Memory Investment System is a tool for tracking, analyzing, and visualizing the directional properties of words in your project. It combines memory management with spatial visualization, allowing you to "invest" words and track their value over time.

## Key Concepts

### Memory Investment

Words can be "invested" into the system, which:
- Tracks their value growth over time
- Categorizes them based on purpose/meaning
- Analyzes their directional properties
- Visualizes connections between related words

### Directional Analysis

Each word has inherent directional properties in 3D space:
- **Forward/Backward**: Temporal direction
- **Up/Down**: Hierarchical position
- **Left/Right**: Lateral categorization
- **Inward/Outward**: Focus vs. expansion

### 12-Turn Cycle

The system operates on a 12-turn cycle:
- Each turn represents a phase of development
- Auto-pause features for coffee/smoke breaks
- Tracks ROI (Return on Investment) for words

## Getting Started

1. Launch the system using `./memory_investment_launcher.sh`
2. Enter words into the input field and select a category
3. Press "Invest Word" to add it to your portfolio
4. The 3D visualization will display words and their connections
5. Use the pause feature with `PAUSE` command in the terminal overlay

## Color System

The interface uses a dynamic color-shifting system:
- Light blue represents the base Memory state
- Colors shift based on time and word investment value
- Ghostly ethereal gradients for visualization

## Terminal Commands

Use the terminal overlay to control the system:
- `INVEST <word> <category>` - Invest a new word
- `VALUE <word>` - Check current value of a word
- `ANALYZE <word>` - Show directional analysis
- `CONNECTIONS <word>` - Show related words
- `PAUSE` - Pause the 12-turn cycle
- `RESUME` - Resume the 12-turn cycle
- `TURN [number]` - Jump to specific turn
- `VISUALIZE` - Toggle 3D visualization
- `HELP` - Show available commands

## Integration Points

The Memory Investment System connects to:
- Smart Account Manager
- AkashicDatabase
- Terminal Shape Game
- Project Memory System

## Saving & Loading

Invested words and their values are saved between sessions:
- Automatic save every turn
- Data stored in `word_investments.json`
- Relationship maps in `word_directions.json`

## Technical Details

- Uses Godot's 3D engine for visualization
- Spatial positioning based on word analysis
- Color-shifting gradient based on session time
- ROI calculation based on word rarity and usage

## Examples

Try investing these example words to see different effects:
- "memory" - Shows strong upward trajectory
- "dimension" - Creates connections to related concepts
- "ethereal" - Displays ghostly blue visualization
- "light" - Reveals forward and upward momentum

---

*"Invest words, see dimensions, discover connections."*