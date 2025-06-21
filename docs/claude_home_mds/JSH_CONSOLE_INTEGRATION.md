# Akashic Records JSH Console Integration

This document provides specific instructions for integrating the Akashic Records system with your JSH console in the Eden Space Game.

## Integration Files

In this package, you'll find the following files related to JSH console integration:

1. `akashic_records_commands.gd` - Script to add Akashic Records commands to the JSH console
2. `akashic_records_main_integration.gd` - Code to integrate with main.gd

## JSH Console Integration Steps

### Step 1: Add Command Registration

1. Copy the `akashic_records_commands.gd` file to your project's Menu_Keyboard_Console folder:
   ```
   D:/GodotEden/godot luminus copy/eden feb/code/gdscript/scripts/Menu_Keyboard_Console/akashic_records_commands.gd
   ```

2. In your `main.gd` file, add the following import near other imports:
   ```gdscript
   const AkashicRecordsCommands = preload("res://code/gdscript/scripts/Menu_Keyboard_Console/akashic_records_commands.gd")
   ```

3. Add a variable for the commands handler:
   ```gdscript
   # Akashic Records commands
   var akashic_records_commands = null
   ```

4. Initialize the commands in the `_initialize_akashic_records()` function after initializing the integration:
   ```gdscript
   # Add this to the _initialize_akashic_records() function
   # Initialize Akashic Records commands for JSH console
   akashic_records_commands = AkashicRecordsCommands.new()
   add_child(akashic_records_commands)
   akashic_records_commands.initialize(self, akashic_records_integration)
   ```

5. Ensure your main.gd implements the command registration system. If it doesn't already have a command registration system, you'll need to add one. The `akashic_records_commands.gd` script assumes that your JSH console has a `register_command` method.

### Step 2: Test the Command Registration

1. Run your game and access the JSH console
2. Type `akashic-help` to see the list of available Akashic Records commands
3. Verify that all commands are registered and working correctly

## Available JSH Console Commands

After integration, the following commands will be available in your JSH console:

- `akashic-add <id> <category> [parent_id]` - Add a new word to the dictionary
- `akashic-get <id>` - Get details about a specific word
- `akashic-list [category]` - List all words or words in a specific category
- `akashic-interact <word1_id> <word2_id>` - Perform an interaction between two words
- `akashic-save` - Save the dictionary to disk
- `akashic-status` - Display the current status of the Akashic Records system
- `akashic-help` - Show help for Akashic Records commands

## Example Usage

Here's an example session using the JSH console commands:

```
> akashic-add water element
Word 'water' added to category 'element'

> akashic-add fire element
Word 'fire' added to category 'element'

> akashic-list
Dictionary words:
- water (element)
- fire (element)

Total: 2 words

> akashic-interact water fire
Interaction result: No result data

> akashic-save
Akashic Records dictionary saved successfully

> akashic-status
Akashic Records Status:
Dictionary word count: 2
Zones: 1
Active zones: 1
Evolution rate: 0.05
```

## Customizing Command Behavior

If you need to customize the behavior of the commands, you can modify the `akashic_records_commands.gd` file. Each command is implemented as a separate method with a `_cmd_` prefix.

## Troubleshooting

- **Commands not appearing**: Make sure the commands script is properly initialized in `main.gd`
- **Command errors**: Check that your JSH console implements the `register_command` method correctly
- **System not initialized**: Verify that the Akashic Records integration is initialized before the commands

## Next Steps

After verifying that the JSH console integration works correctly, you can proceed to implement the UI integration following the main integration guide.