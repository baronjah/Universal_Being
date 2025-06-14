# Script Documentation: CoreCreationConsole

## Overview
CoreCreationConsole provides a user interface for entering commands and words that manifest entities in the JSH Ethereal Engine. It displays a command input field and output area, tracks command history, and handles command processing through integration with the Word Manifestor system.

## File Information
- **File Path:** `/code/core/CoreCreationConsole.gd`
- **Lines of Code:** 207
- **Class Name:** CoreCreationConsole
- **Extends:** Control

## Dependencies
- Godot 4.x UI Controls (RichTextLabel, LineEdit, Button, etc.)
- CoreWordManifestor / JSHWordManifestor (for processing commands)

## Properties

### UI Components
| Property | Type | Description |
|----------|------|-------------|
| output_display | RichTextLabel | Displays command output and messages |
| input_field | LineEdit | Input field for entering commands |
| history_button | Button | Button to display command history |
| clear_button | Button | Button to clear the output display |

### Command History
| Property | Type | Description |
|----------|------|-------------|
| command_history | Array | Stores previous commands |
| history_index | int | Current position in history when navigating |
| max_history | int | Maximum number of commands to store (20) |

### External Systems
| Property | Type | Description |
|----------|------|-------------|
| word_manifestor | Object | Reference to the word manifestation system |

## Signals
| Signal | Parameters | Description |
|--------|------------|-------------|
| command_entered | command | Emitted when a command is entered |
| command_processed | result | Emitted when a command has been processed |

## Methods

### Initialization
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _ready | | void | Connects signals and initializes the console |
| _connect_to_word_manifestor | | void | Tries to connect to available word manifestor |

### Event Handlers
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _on_text_submitted | text | void | Handles command submission from input field |
| _on_history_button_pressed | | void | Shows command history popup |
| _on_history_selected | id | void | Selects a command from history |
| _on_clear_button_pressed | | void | Clears the output display |
| _input | event | void | Handles keyboard input for history navigation and console toggle |

### Utility Methods
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| display_message | message, color | void | Displays a colored message in the output |
| toggle_visibility | | void | Shows or hides the console |
| execute_command | command | void | Externally executes a command in the console |

### Static Methods
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| create_console_scene | | CoreCreationConsole | Creates a new console scene programmatically |

## UI Structure
The console UI has the following structure:
```
CoreCreationConsole (Control)
└── VBoxContainer
    ├── OutputDisplay (RichTextLabel)
    └── HBoxContainer
        ├── InputField (LineEdit)
        ├── HistoryButton (Button)
        └── ClearButton (Button)
```

## Command Processing Flow
1. User enters text in the input field and submits (Enter key)
2. Text is added to command history
3. Command is displayed in the output display
4. Command is emitted through the `command_entered` signal
5. If a word manifestor is available, the command is passed for processing
6. Result is displayed in the output with appropriate color
7. Result is emitted through the `command_processed` signal

## Keyboard Shortcuts
| Key | Action |
|-----|--------|
| Tab | Toggle console visibility |
| Up Arrow | Navigate command history backward |
| Down Arrow | Navigate command history forward |
| Enter | Submit command |

## Usage Examples

### Adding the Console to a Scene
```gdscript
# Method 1: Using the static creator method
var console = CoreCreationConsole.create_console_scene()
add_child(console)

# Method 2: Using a premade scene
var console_scene = preload("res://path/to/creation_console.tscn")
var console = console_scene.instantiate()
add_child(console)
```

### Executing Commands Programmatically
```gdscript
# Get reference to the console
var console = get_node("CreationConsole")

# Execute a command
console.execute_command("create fireball")

# Listen for processed results
console.command_processed.connect(_on_command_result)

func _on_command_result(result):
    if result.success:
        print("Command succeeded: " + result.message)
        # Do something with result.entity if present
    else:
        print("Command failed: " + result.message)
```

### Displaying Custom Messages
```gdscript
# Get reference to the console
var console = get_node("CreationConsole")

# Display custom messages with different colors
console.display_message("Starting process...", Color.BLUE)
console.display_message("Success!", Color.GREEN)
console.display_message("Warning: Resources low", Color(0.9, 0.6, 0.1))
console.display_message("Error occurred", Color.RED)
```

## Integration Points
CoreCreationConsole integrates with:

- **Word Manifestation System**: Processes commands through the word manifestor
- **Game Controller**: Communication for system-wide events and commands
- **UI System**: Visual integration with the game's user interface

## Notes and Considerations
- The console is hidden by default and toggled with the Tab key
- Command history is stored only for the current session
- The console supports rich text for colored output
- The console is designed to have a semi-transparent black background
- Commands are processed by the word manifestor if available, with fallbacks

## Related Documentation
- [CoreWordManifestor](CoreWordManifestor.md)
- [CoreGameController](CoreGameController.md)
- [JSHWordManifestor](../word/JSHWordManifestor.md)