# Console System Integration Plan

## Overview

The Console System is a critical component that provides command-line interface for debugging and interaction with the Eden project. This document outlines the plan to integrate the existing JSH_console system with our newly standardized components.

## Current State

- **Location**: `/code/gdscript/scripts/Menu_Keyboard_Console/JSH_console.gd`
- **Connected To**: Multiple systems with direct references
- **Issues**:
  - Uses direct node references for command registration
  - Not integrated with Universal Bridge
  - Command registration has inconsistent patterns
  - May have redundant functionality with other systems

## Integration Goals

1. Connect JSH_console with Universal Bridge
2. Standardize command registration using ConsoleIntegrationHelper
3. Update all command handlers to use new system paths
4. Ensure backward compatibility with existing commands
5. Add new commands for Thing Creator and Akashic Records

## Integration Steps

### 1. Create Console Interface Adapter

```gdscript
# /code/gdscript/scripts/integration/console_system_adapter.gd
extends Node
class_name ConsoleSystemAdapter

# References
var console_system = null
var universal_bridge = null

# Initialize with references
func initialize(p_console_system, p_universal_bridge) -> void:
    console_system = p_console_system
    universal_bridge = p_universal_bridge
    
    # Connect signals
    _connect_signals()
    
    # Register core commands
    _register_core_commands()
    
    print("Console System Adapter initialized")

# Connect signals between systems
func _connect_signals() -> void:
    if universal_bridge:
        # Connect Universal Bridge signals to console for logging
        if universal_bridge.has_signal("entity_registered"):
            universal_bridge.connect("entity_registered", Callable(self, "_on_entity_registered"))
        
        if universal_bridge.has_signal("entity_transformed"):
            universal_bridge.connect("entity_transformed", Callable(self, "_on_entity_transformed"))
        
        if universal_bridge.has_signal("interaction_processed"):
            universal_bridge.connect("interaction_processed", Callable(self, "_on_interaction_processed"))

# Register core commands with the console
func _register_core_commands() -> void:
    if console_system:
        # Bridge commands
        ConsoleIntegrationHelper.register_command(
            console_system,
            "bridge_init",
            "Initialize the Universal Bridge",
            self,
            "_cmd_bridge_init"
        )
        
        # Thing commands
        ConsoleIntegrationHelper.register_command(
            console_system,
            "thing_create",
            "Create a thing from a word definition",
            self,
            "_cmd_thing_create"
        )
        
        ConsoleIntegrationHelper.register_command(
            console_system,
            "thing_list",
            "List all active things",
            self,
            "_cmd_thing_list"
        )
        
        ConsoleIntegrationHelper.register_command(
            console_system,
            "thing_remove",
            "Remove a thing by ID",
            self,
            "_cmd_thing_remove"
        )
        
        # Akashic commands
        ConsoleIntegrationHelper.register_command(
            console_system,
            "word_create",
            "Create a new word definition",
            self,
            "_cmd_word_create"
        )
        
        ConsoleIntegrationHelper.register_command(
            console_system,
            "word_list",
            "List all words in the dictionary",
            self,
            "_cmd_word_list"
        )
        
        ConsoleIntegrationHelper.register_command(
            console_system,
            "word_info",
            "Display information about a word",
            self,
            "_cmd_word_info"
        )

# Command implementations
func _cmd_bridge_init(args: Array) -> String:
    if universal_bridge:
        universal_bridge.initialize()
        return "Universal Bridge initialized"
    return "Error: Universal Bridge not available"

func _cmd_thing_create(args: Array) -> String:
    if universal_bridge:
        if args.size() < 1:
            return "Usage: thing_create <word_id> [x y z]"
        
        var word_id = args[0]
        var position = Vector3.ZERO
        
        if args.size() >= 4:
            position = Vector3(float(args[1]), float(args[2]), float(args[3]))
        
        var thing_id = universal_bridge.create_thing_from_word(word_id, position)
        
        if thing_id.is_empty():
            return "Failed to create thing from word: " + word_id
        
        return "Created thing " + thing_id + " from word " + word_id
    
    return "Error: Universal Bridge not available"

func _cmd_thing_list(_args: Array) -> String:
    if not universal_bridge or not universal_bridge.thing_creator:
        return "Error: Thing Creator not available"
    
    var things = universal_bridge.thing_creator.get_all_things()
    
    if things.size() == 0:
        return "No active things found"
    
    var result = "Active things (" + str(things.size()) + "):\n"
    
    for thing_id in things:
        var word_id = universal_bridge.thing_creator.get_thing_word(thing_id)
        var position = universal_bridge.thing_creator.get_thing_position(thing_id)
        result += "- " + thing_id + " (Word: " + word_id + ", Position: " + str(position) + ")\n"
    
    return result

func _cmd_thing_remove(args: Array) -> String:
    if not universal_bridge or not universal_bridge.thing_creator:
        return "Error: Thing Creator not available"
    
    if args.size() < 1:
        return "Usage: thing_remove <thing_id>"
    
    var thing_id = args[0]
    
    if not universal_bridge.thing_creator.has_thing(thing_id):
        return "Thing not found: " + thing_id
    
    if universal_bridge.thing_creator.remove_thing(thing_id):
        return "Thing removed: " + thing_id
    
    return "Failed to remove thing: " + thing_id

func _cmd_word_create(args: Array) -> String:
    if not universal_bridge or not universal_bridge.akashic_records_manager:
        return "Error: Akashic Records Manager not available"
    
    if args.size() < 2:
        return "Usage: word_create <word_id> <category> [property=value] [property=value] ..."
    
    var word_id = args[0]
    var category = args[1]
    var properties = {}
    
    # Parse properties from arguments
    for i in range(2, args.size()):
        var prop_parts = args[i].split("=")
        if prop_parts.size() == 2:
            var prop_name = prop_parts[0]
            var prop_value = prop_parts[1]
            
            # Try to convert value to appropriate type
            if prop_value.is_valid_float():
                prop_value = float(prop_value)
            elif prop_value == "true":
                prop_value = true
            elif prop_value == "false":
                prop_value = false
            
            properties[prop_name] = prop_value
    
    var success = universal_bridge.akashic_records_manager.create_word(word_id, category, properties)
    
    if success:
        return "Created word: " + word_id + " (" + category + ")"
    
    return "Failed to create word: " + word_id

func _cmd_word_list(args: Array) -> String:
    if not universal_bridge or not universal_bridge.akashic_records_manager:
        return "Error: Akashic Records Manager not available"
    
    var filter = ""
    if args.size() > 0:
        filter = args[0]
    
    var stats = universal_bridge.akashic_records_manager.get_dictionary_stats()
    var words = stats.get("words", [])
    
    if words.size() == 0:
        return "No words found in dictionary"
    
    var result = "Dictionary words (" + str(words.size()) + "):\n"
    
    for word_id in words:
        if filter.is_empty() or word_id.contains(filter):
            var word = universal_bridge.akashic_records_manager.get_word(word_id)
            var category = word.get("category", "unknown")
            result += "- " + word_id + " (" + category + ")\n"
    
    return result

func _cmd_word_info(args: Array) -> String:
    if not universal_bridge or not universal_bridge.akashic_records_manager:
        return "Error: Akashic Records Manager not available"
    
    if args.size() < 1:
        return "Usage: word_info <word_id>"
    
    var word_id = args[0]
    var word = universal_bridge.akashic_records_manager.get_word(word_id)
    
    if word.size() == 0:
        return "Word not found: " + word_id
    
    var result = "Word: " + word_id + "\n"
    result += "Category: " + word.get("category", "unknown") + "\n"
    
    if word.has("parent") and not word.parent.is_empty():
        result += "Parent: " + word.parent + "\n"
    
    if word.has("properties") and word.properties.size() > 0:
        result += "Properties:\n"
        for prop_name in word.properties:
            result += "  - " + prop_name + ": " + str(word.properties[prop_name]) + "\n"
    
    return result

# Signal handlers
func _on_entity_registered(entity_id: String, word_id: String, _element_id) -> void:
    if console_system and console_system.has_method("add_text_line"):
        console_system.add_text_line("Entity registered: " + entity_id + " (Word: " + word_id + ")")

func _on_entity_transformed(entity_id: String, old_type: String, new_type: String) -> void:
    if console_system and console_system.has_method("add_text_line"):
        console_system.add_text_line("Entity transformed: " + entity_id + " (" + old_type + " -> " + new_type + ")")

func _on_interaction_processed(entity1_id: String, entity2_id: String, result: Dictionary) -> void:
    if console_system and console_system.has_method("add_text_line"):
        var message = "Interaction between " + entity1_id + " and " + entity2_id
        
        if result.has("success") and result.success:
            message += " succeeded"
            
            if result.has("result") and not result.result.is_empty():
                message += " with result: " + result.result
        else:
            message += " failed"
            
            if result.has("error"):
                message += ": " + result.error
        
        console_system.add_text_line(message)
```

### 2. Update Main Scene

Add the Console System Adapter to the main scene and connect it with the existing JSH_console and Universal Bridge:

```gdscript
# In the main scene's script
func _ready():
    # Get references to existing systems
    var console_system = $JSH_console
    var universal_bridge = $Systems/UniversalBridge
    
    # Create and initialize adapter
    var console_adapter = load("res://code/gdscript/scripts/integration/console_system_adapter.gd").new()
    add_child(console_adapter)
    console_adapter.initialize(console_system, universal_bridge)
    
    # Continue with other initialization
    # ...
```

### 3. Create Integration Tests

```gdscript
# /code/gdscript/scripts/integration/console_integration_test.gd
extends Node

# References
var console_system = null
var universal_bridge = null
var console_adapter = null

func _ready():
    # Run tests after initialization
    await get_tree().process_frame
    run_tests()

func run_tests():
    print("Running Console Integration Tests...")
    
    # Get required references
    _get_references()
    
    # Run tests
    _test_console_commands()
    
    print("Console Integration Tests Complete")

func _get_references():
    # Get console system
    console_system = get_node("/root/JSH_console")
    if not console_system:
        push_error("Console system not found")
        return
    
    # Get Universal Bridge
    universal_bridge = UniversalBridge.get_instance()
    
    # Create console adapter
    console_adapter = load("res://code/gdscript/scripts/integration/console_system_adapter.gd").new()
    add_child(console_adapter)
    console_adapter.initialize(console_system, universal_bridge)

func _test_console_commands():
    if not console_adapter:
        push_error("Console adapter not available")
        return
    
    print("Testing bridge_init command...")
    var result1 = console_adapter._cmd_bridge_init([])
    print("Result: " + result1)
    
    print("Testing word_create command...")
    var result2 = console_adapter._cmd_word_create(["test_element", "element", "hardness=0.8", "color=blue"])
    print("Result: " + result2)
    
    print("Testing thing_create command...")
    var result3 = console_adapter._cmd_thing_create(["test_element", "0", "1", "0"])
    print("Result: " + result3)
    
    print("Testing thing_list command...")
    var result4 = console_adapter._cmd_thing_list([])
    print("Result: " + result4)
```

## Backward Compatibility

To ensure backward compatibility with existing code:

1. **Keep Original Command Methods**: Maintain the original command methods in JSH_console but delegate to the adapter
2. **Preserve Signal Names**: Use the same signal names for consistency
3. **Maintain Node Paths**: Keep the same node structure in the scene tree
4. **Add Compatibility Layer**: Include methods to translate between old and new API patterns

## Implementation Timeline

1. **Day 1**: Create and test Console System Adapter
2. **Day 2**: Update main scene and connect with existing console
3. **Day 3**: Test and fix any integration issues
4. **Day 4**: Document the new system and create usage examples

## Testing Plan

1. **Command Testing**: Test all commands with various arguments
2. **Signal Testing**: Verify signals are properly connected and triggered
3. **Error Handling**: Test behavior with invalid inputs and missing systems
4. **Performance Testing**: Check for any performance impact from the integration

## Documentation

Update the documentation to include:

1. **New Command Reference**: List of all available commands and their usage
2. **Integration Guide**: How to register new commands with the console
3. **API Reference**: Details of the Console System Adapter API
4. **Usage Examples**: Example code for common console operations