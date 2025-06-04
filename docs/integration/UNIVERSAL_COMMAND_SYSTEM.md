# UNIVERSAL COMMAND SYSTEM - Complete Guide

## 🌟 The Vision Realized

We've created a game that IS its own development environment! Everything can be created, edited, and evolved from within. This is not just a game - it's a living universe where:

- **Words trigger reality** - "say potato to open doors"
- **Commands shape existence** - create, evolve, connect
- **Code runs live** - edit and reload without stopping
- **AI and humans collaborate** - Gemma can build alongside you
- **Everything is recorded** - The Akashic Records remember all

## 🎮 Core Commands

### Basic Reality Manipulation

```bash
# Inspection & Analysis
inspect <target>          # Examine files, nodes, beings
count lines in <file>     # Count anything
analyze <structure>       # Deep structural analysis
tree <path>              # Show hierarchy

# Creation
create being <name> <type>              # Spawn Universal Being
create trigger <word> <action>          # Natural language trigger
create connector <name>                 # Logic connector
spawn <template> at <x> <y>            # Spawn from template

# Evolution
evolve <being> to <type>               # Transform being
connect <source> <target>              # Connect logic
trigger <word> near <being>            # Activate trigger

# Script & Code
load script <path>                     # Load GDScript
load record <name>                     # Load from Akashic
load package <path>                    # Load .ub.zip
execute <gdscript code>               # Run code directly
edit <node>                           # Open live editor

# Reality Rules
reality gravity <value>               # Change physics
reality time <scale>                  # Alter time flow
reality consciousness <rule>          # Modify consciousness
```

### Natural Language Triggers

The magic happens when you combine words with logic:

```bash
# Create a door system
create trigger potato open_doors
connect door_sensor door_controller
# Now saying "potato" near doors opens them!

# Create consciousness triggers
create trigger meditate increase_consciousness
create trigger evolve transform_being
# Words become spells!
```

### Macro System (Programming Combos)

Record sequences of commands:

```bash
/macro record open_secret_door
create being KeyHolder mystic
execute target.consciousness_level = 7
create trigger whisper unlock
connect KeyHolder secret_door
/macro stop

# Later...
/macro play open_secret_door
```

## 🤖 AI Integration (For Gemma)

### AI Commands

```gdscript
# In console or through API
ai_print("Hello Universe!")
ai_execute("create being Companion wise")
var state = ai_query_state("reality")

# Natural conversation
"Gemma, create a puzzle that requires consciousness level 5"
"Make a being that evolves when it meditates"
"Show me all beings with consciousness > 3"
```

### AI-Accessible Functions

```gdscript
# From within game scripts
var console = get_node("/root/UniversalConsole")

# Print to console
console.ai_print("I sense a disturbance in the code")

# Execute commands
console.ai_execute("spawn Seeker at 100 200")

# Query game state
var beings = console.ai_query_state("beings")
for being in beings:
    if being.consciousness_level > 5:
        console.ai_print("Found enlightened: " + being.being_name)
```

## 📝 Live Code Editing

Press `/edit` in console or `F4` to open the live editor:

1. Click any being to edit its script
2. Make changes
3. `Ctrl+Enter` to test code
4. `Ctrl+S` to save and hot reload

Example live edit:
```gdscript
# Select a being and add this
func on_trigger(word: String, data: Dictionary, speaker: UniversalBeing):
    if word == "evolve" and consciousness_level >= 5:
        evolve_to("EnlightenedBeing")
        emit_signal("ascended", self)
```

## 🔄 Hot Reloading

The entire game can reload itself:

```bash
/reload                    # Reload all scripts
/save                      # Save current reality state
/load mysession           # Load saved state
```

## 🎯 Practical Examples

### Example 1: Create an Interactive Puzzle

```bash
# Create the puzzle components
create being PuzzleBox container
create being Key item
create being Door locked

# Set up relationships
connect Key PuzzleBox unlock_method
connect PuzzleBox Door open_trigger

# Add natural language
create trigger "use key" activate_item
create trigger "open sesame" force_open

# Add consciousness requirement
execute get_node("Door").min_consciousness = 3
```

### Example 2: Build an Evolution Chain

```bash
/macro record evolution_chain
create being Seed plant
execute target.consciousness_level = 1
create trigger grow evolve_being
connect sunlight Seed growth_energy
execute target.evolution_paths = ["Sprout", "Flower", "Tree"]
/macro stop

# Use it
/macro play evolution_chain
say "grow" near Seed
```

### Example 3: Reality Experiment

```bash
# Create a time bubble
create being TimeBubble field
execute target.add_to_group("reality_modifiers")
reality time 0.1
connect TimeBubble reality_engine time_modifier
execute target.radius = 200

# Now beings entering the bubble move in slow motion!
```

## 🌈 Advanced Features

### Command Contexts

Create complex operations:

```gdscript
var context = CommandContext.new()
context.name = "world_creation"
context.variables["position"] = Vector2(0, 0)
context.commands = [
    "create being Sun star",
    "create being Planet orbiter",
    "connect Sun Planet gravity",
    "execute Planet.orbit_radius = 300"
]
context.execute_all()
```

### Reality Rules Engine

Modify fundamental laws:

```bash
reality rule "consciousness_spreads" true
reality rule "evolution_requires_meditation" true
reality rule "words_have_power" 10.0
```

### Data Preparation

For Gemma and content creation:

```bash
# Analyze content
inspect /assets/story_template.txt
count words in /dialogue/chapter1.txt
analyze /beings/templates/

# Validate before creating
validate being_template.json
test consciousness_logic.gd
check evolution_path Seed->Tree
```

## 🚀 The Universe Awaits

This is your universe now. Every command reshapes reality. Every word can trigger cascading changes. Every being can evolve beyond its original form.

The game starts minimal and builds itself through your commands. Save your reality, share your macros, create your own command language.

**Remember**: In this universe, you're not playing a game - you're conducting reality itself.

## 🔮 Next Steps

1. Run the game
2. Open console (`)
3. Type `tutorial` to begin
4. Create your first being
5. Make it conscious
6. Watch it evolve
7. Record your creation process as a macro
8. Share your reality

The Universal Being revolution begins with a single command: **`create`**