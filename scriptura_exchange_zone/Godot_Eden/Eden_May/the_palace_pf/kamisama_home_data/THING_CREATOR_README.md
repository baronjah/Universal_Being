# Thing Creator for Eden Space Game

The Thing Creator is an extension of the Akashic Records system that allows you to materialize dictionary words into actual objects in the game world. This integration bridges the conceptual dictionary system with the tangible, interactive game environment.

## Overview

The Thing Creator system consists of these components:

1. **ThingCreator** - Core class for creating and managing things from dictionary words
2. **ThingCreatorUI** - User interface for creating and previewing things
3. **ThingCreatorIntegration** - Connection to the Menu Keyboard Console
4. **ThingCreatorCommands** - JSH console commands for thing management

## Features

- Create physical objects from dictionary entries
- Customize object properties
- Visualize words before creation
- Position objects in 3D space
- Simulate interactions between objects
- Manage objects through JSH console commands
- Automatic visual representation based on word properties
- Physics-based interactions between objects

## Integration with Main Menu

After installation, you'll find new entries in your menu system:

- **Things → Thing Creator** - Opens the Thing Creator UI
- **Actions → Create Thing** - Quick access to Thing Creator
- **Things → Manage Things** - Lists and manages existing things

## JSH Console Commands

The following commands are available in the JSH console:

- `thing-create <word_id> <x> <y> <z> [prop1=value1 prop2=value2]` - Create a new thing
- `thing-list` - List all things in the world
- `thing-remove <thing_id>` - Remove a thing
- `thing-move <thing_id> <x> <y> <z>` - Move a thing
- `thing-interact <thing1_id> <thing2_id>` - Simulate interaction
- `thing-info <thing_id>` - Show thing information
- `thing-help` - Show help for Thing Creator commands

### Examples

```
# Create a fire element at position (0,1,0)
thing-create fire 0 1 0

# Create water with custom properties
thing-create water 2 0 3 temperature=0.8 flow=0.6

# List all things in the world
thing-list

# Show details about a specific thing
thing-info fire_12345678

# Remove a thing
thing-remove fire_12345678

# Move a thing
thing-move water_87654321 5 0 5

# Trigger interaction between two things
thing-interact fire_12345678 wood_87654321
```

## Using the Thing Creator UI

The Thing Creator UI provides a visual interface for creating things:

1. **Word Selection** - Browse and search for words in the dictionary
2. **3D Preview** - See a preview of how the thing will look
3. **Properties Display** - View the word's properties
4. **Custom Properties** - Add custom properties for this specific instance
5. **Position Control** - Set the position where the thing will be created
6. **Creation Button** - Create the thing in the game world

## Advanced Usage

### Automatic Interactions

Things can automatically interact when they come in contact with each other. The interaction engine will process these interactions based on the rules defined in the dictionary.

### Visual Representation

The visual appearance of things is determined by their word properties:

- **Elements** - Sphere meshes with color, transparency, and emission based on properties
- **Entities** - Box meshes with custom materials
- **Concepts** - Particle effects with abstract representations

### Custom Properties

Custom instance properties allow you to create variations of the same word:

- Adjust visual properties (size, color, effects)
- Modify physical properties (weight, friction)
- Control behavior (speed, aggression)
- Override default properties from the dictionary

## Implementation Details

The Thing Creator builds on the following technologies in the Eden Space Game:

- **Akashic Records** - Dictionary system for word definitions
- **Zone Manager** - Spatial organization system
- **Interaction Engine** - Rules for word interactions

## Where to Go Next

After creating your first things with the Thing Creator, try these next steps:

1. Define interactions between words in the Akashic Records
2. Create complex chains of interactions
3. Build environments using multiple things
4. Experiment with the evolution system to see how things change over time
5. Connect things to the gameplay mechanics