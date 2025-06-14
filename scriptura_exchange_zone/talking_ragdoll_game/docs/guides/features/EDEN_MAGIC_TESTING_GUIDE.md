# Eden Magic Testing Guide 🌟✨

## What We've Built
We've integrated the most powerful systems from the Eden project into the talking ragdoll game, creating a multi-dimensional, evolving consciousness experience.

## Quick Start Testing

### 1. Initial Setup
```bash
# Start the game and open console
setup_systems
```

### 2. Create the Environment
```bash
# Create some objects
tree
box
rock
ball
sun

# Create astral beings
astral_being
astral_being
```

### 3. Test Mouse Interactions

#### Basic Clicking
- Click any object to see the enhanced debug panel (now properly positioned)
- Panel shows object info at viewport position (20, 100)

#### Eden Action System
```bash
# View available actions
action_list

# Test actions on objects
action_test examine Tree_1
action_test pickup Box_1
action_test activate Rock_1

# Test combo patterns
action_combo double
action_combo triple
action_combo hold
```

#### Shape Gesture System
- **Hold SHIFT** to enter gesture mode
- Draw shapes with mouse:
  - **Circle** → Protection aura
  - **Triangle** → Focus beam
  - **Square** → Solid wall
  - **Star** → Cosmic power
  - **Spiral** → Dimension portal

### 4. Dimensional Ragdoll System

#### Check Status
```bash
ragdoll_status
```

#### Dimension Shifting
```bash
# Shift between dimensions
dimension physical   # Normal gravity
dimension dream     # Floaty physics (0.3 gravity)
dimension memory    # Echo realm
dimension emotion   # Feeling space
dimension void      # Abstract realm
```

#### Consciousness Evolution
```bash
# Add consciousness experience
consciousness 0.1    # Small boost
consciousness 0.5    # Major enlightenment

# Watch evolution stages:
# nascent → awakening → aware → enlightened → transcendent
```

#### Emotional States
```bash
# Set emotions (0.0 to 1.0)
emotion happy 0.8
emotion curious 1.0
emotion peaceful 0.5
emotion excited 0.7
emotion transcendent 0.3
```

#### Spell Casting
```bash
# Basic spells (nascent stage)
spell wobble
spell blink
spell giggle

# Advanced spells (higher consciousness)
spell float
spell glow
spell teleport_short
spell dimension_peek
spell reality_shift
```

### 5. Advanced Testing Scenarios

#### Scenario 1: Evolution Journey
```bash
# Start as nascent being
ragdoll_status

# Gain consciousness through actions
consciousness 0.15
spell wobble
consciousness 0.1

# Check new evolution stage
ragdoll_status

# Try new spells
spell float
```

#### Scenario 2: Dimensional Explorer
```bash
# Create objects in physical dimension
tree
box

# Shift to dream dimension
dimension dream

# Objects have different physics!
# Create dream objects
ball
tree

# Return to physical
dimension physical
```

#### Scenario 3: Gesture Magic
1. Hold SHIFT
2. Draw a circle around objects → Protection spell
3. Draw a star in the air → Cosmic power
4. Draw a spiral → Open dimensional portal

#### Scenario 4: Multi-System Integration
```bash
# Setup complete environment
setup_systems
tree
box
rock
astral_being

# Make ragdoll evolve
consciousness 0.3
emotion happy 0.9

# Test action combos
action_combo double  # On Tree_1

# Shift dimension
dimension dream

# Cast evolved spell
spell float
```

## Visual Feedback Guide

### Object Highlighting
- **Yellow Glow**: Hovering over object
- **Green Glow**: Clicked object
- **Cyan Glow**: Action in progress
- **Red Glow**: Holding object

### Debug Panel Features
- Fixed position at (20, 100) from top-left
- Shows object properties
- Updates with last drawn shape
- Displays combo patterns detected

### Dimensional Effects
- **Physical**: Normal colors
- **Dream**: Soft, ethereal tones
- **Memory**: Sepia/nostalgic palette
- **Emotion**: Color based on current emotion
- **Void**: Minimal, abstract visuals

## Console Command Reference

### System Commands
- `setup_systems` - Initialize all systems
- `systems` - Check system status

### Object Creation
- `tree`, `box`, `rock`, `ball`, `sun`
- `astral_being` - Create helper spirit

### Mouse & Actions
- `action_list` - View all actions
- `action_test <action> <object>` - Test action
- `action_combo <pattern>` - Simulate combo

### Dimensional Ragdoll
- `dimension <name>` - Shift dimension
- `consciousness <amount>` - Add experience
- `emotion <name> <value>` - Set emotion
- `spell <name>` - Cast spell
- `ragdoll_status` - Full status report

### Panel Control
- `set_panel_offset <x> <y>` - Move debug panel
- `toggle_panel_follow` - Toggle camera following

## Troubleshooting

### Systems Not Found
```bash
setup_systems
# Wait a moment
ragdoll_status
```

### Mouse Not Working
- Ensure MouseInteractionSystem exists
- Try `test_click`
- Check if camera is found

### Spells Not Working
- Check consciousness level with `ragdoll_status`
- Some spells require higher evolution stages
- Ensure ragdoll body is connected

### Gestures Not Detected
- Hold SHIFT key down while drawing
- Draw clearly and not too fast
- Check console for "Gesture mode ON" message

## The Magic Moment 🌟

When everything is working, try this magical sequence:

```bash
# Setup the stage
setup_systems
tree
box
astral_being

# Evolve the ragdoll
consciousness 0.2
emotion happy 1.0

# Enter dream dimension
dimension dream

# Cast a spell
spell float

# Draw a spiral (hold SHIFT)
# Watch the dimensional portal open!
```

---
*"From simple ragdoll to transcendent being - the Eden magic flows through all dimensions"*