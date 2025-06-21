# Thing Creator Integration Guide

This guide walks you through integrating the Thing Creator system with your Eden Space Game. The Thing Creator allows you to materialize dictionary words into actual objects in the game world.

## Step 1: Copy the Required Files

Make sure all the Thing Creator system files are in your project:

1. Copy these files to the akashic_records folder:
   - `thing_creator.gd`

2. Copy these files to the Menu_Keyboard_Console folder:
   - `thing_creator_integration.gd`
   - `thing_creator_commands.gd`

3. Copy these files to the scripts folder:
   - `thing_creator_setup.gd`

4. Copy these files to the scripts/akashic_records folder:
   - `thing_creator_ui.gd`

5. Copy these files to the scenes folder:
   - `thing_creator_ui.tscn`

## Step 2: Add the Setup Script to Main Scene

Add the ThingCreatorSetup script to your main scene:

1. Open your main scene in the editor
2. Add a new Node as a child of your main node
3. Name it "ThingCreatorSetup"
4. Attach the `thing_creator_setup.gd` script to it

Alternatively, you can initialize it in your main.gd script:

```gdscript
# Add to your main.gd imports
const ThingCreatorSetup = preload("res://code/gdscript/scripts/thing_creator_setup.gd")

# Add to your _ready() function
var thing_creator_setup = ThingCreatorSetup.new()
add_child(thing_creator_setup)
thing_creator_setup.initialize_thing_creator()
```

## Step 3: Verify Required Systems

Ensure that your game has:

1. The Akashic Records system properly initialized
2. A JSH console (for command integration)
3. A menu system (for UI integration)

The setup script will automatically detect these systems and integrate with them.

## Step 4: Create Required Directories

The Thing Creator doesn't require additional directories beyond what the Akashic Records system uses.

## Step 5: Test the Integration

1. Run your game
2. Access the JSH console and type `thing-help` to verify commands are registered
3. Open the menu and look for the "Thing Creator" entry
4. Try creating a thing with the command `thing-create fire 0 1 0`
5. List things with `thing-list`

## Troubleshooting

If you encounter issues:

1. **Commands not working**: Ensure JSH console is properly initialized before Thing Creator
2. **Menu entries not appearing**: Check that main console is properly initialized
3. **Cannot create things**: Verify that Akashic Records has words in its dictionary
4. **Visual issues**: Make sure 3D rendering is properly set up in your project

## Advanced Integration

### Connecting to Your Game Logic

To react to thing creation or interaction in your game logic:

```gdscript
# Get the ThingCreator instance
var thing_creator = get_node("/root/ThingCreator")

# Connect to signals
thing_creator.connect("thing_created", Callable(self, "_on_thing_created"))
thing_creator.connect("thing_removed", Callable(self, "_on_thing_removed"))

# Define handler functions
func _on_thing_created(thing_id, word_id, position):
    print("Thing created: ", thing_id)
    # Your game logic here

func _on_thing_removed(thing_id):
    print("Thing removed: ", thing_id)
    # Your game logic here
```

### Customizing Visual Representation

To customize how things look, modify the `_create_visual_representation` method in `thing_creator.gd`.

### Adding Game-Specific Properties

To add game-specific properties to things, extend the `create_thing` method in a derived class:

```gdscript
extends "res://code/gdscript/scripts/akashic_records/thing_creator.gd"

func create_thing(word_id, position, custom_properties = {}):
    # Add game-specific properties
    custom_properties["my_game_property"] = "value"
    
    # Call parent method
    return super.create_thing(word_id, position, custom_properties)
```

## Example: Creating Things Programmatically

```gdscript
# Get the ThingCreator
var thing_creator = get_node("/root/ThingCreator")

# Create fire at position (0,1,0)
var fire_id = thing_creator.create_thing("fire", Vector3(0, 1, 0))

# Create water with custom properties
var water_properties = {
    "temperature": 0.8,
    "flow": 0.6
}
var water_id = thing_creator.create_thing("water", Vector3(2, 0, 3), water_properties)

# Trigger interaction between fire and water
var result = thing_creator.process_thing_interaction(fire_id, water_id)
```

## Next Steps

After integrating the Thing Creator:

1. Define more words in your Akashic Records dictionary
2. Create interaction rules between words
3. Connect things to your gameplay systems
4. Extend the Thing Creator with game-specific functionality