# Multi-Model Coordinator System

## Overview

The Multi-Model Coordinator is a central system that integrates multiple AI models (Gemini, Claude, and OpenAI) into your Godot project. This system includes advanced features such as automatic API selection, parallel processing, data parsing, and a visual color progression system that reflects the state of AI integration.

## Key Components

### API Coordinator (`api_coordinator.gd`)

The core component that manages connections to different AI APIs:

- **Multiple API Integration**
  - Gemini (Standard)
  - Gemini Advanced
  - Claude (Anthropic)
  - Claude Luna (Anthropic's newest model)
  - OpenAI (GPT models)

- **Smart Request Routing**
  - Automatic API selection based on content analysis
  - Manual API selection override
  - Parallel request processing across multiple APIs

- **Data Parsing System**
  - Connections to multiple data sources (local, Google Drive, OneDrive)
  - Automatic format detection (JSON, CSV, XML, text)
  - Result caching for improved performance

- **Visual Color Progression**
  - Color state transitions that reflect system evolution
  - From dark/void (black) to transcendent (azure blue)
  - Visual feedback for connection status

### API Coordinator UI (`api_coordinator_ui.gd` and `api_coordinator.tscn`)

User interface for interacting with the Multi-Model Coordinator:

- **Connection Management**
  - Individual API connect/disconnect controls
  - Status indicators for each API
  - "Connect All" functionality

- **Request Interface**
  - API selection dropdown
  - Request input field
  - Response display

- **Data Parsing Interface**
  - Source and path inputs
  - Format selection
  - Force refresh option
  - Parsed data display

## Color Progression System

The system uses a color progression that reflects the integration state:

1. **Void** (Black) - No connections
2. **Emerging** (Deep Red) - First connection established
3. **Forming** (Dark Orange) - Second connection established
4. **Developing** (Orange) - Third connection established
5. **Evolving** (Light Orange) - Fourth connection established
6. **Maturing** (White Light) - All five connections established
7. **Transcending** (Light Blue) - Advanced models connected (Gemini Advanced, Claude Luna, OpenAI)
8. **Ascending** (Azure Blue) - Full integration with all advanced capabilities

This color progression provides visual feedback about the system's state and creates an evolving atmosphere as the integration deepens.

## Integration with Layer 0 and Main.gd

The Multi-Model Coordinator integrates seamlessly with your existing Layer 0 and main.gd systems:

1. **Initialization in main.gd**
   ```gdscript
   # Add to imports section
   const MultiModelCoordinator = preload("res://Eden_May/api_coordinator.gd")
   
   # Add to variables
   var api_coordinator = null
   
   # Add to _ready() function
   # Initialize Multi-Model Coordinator
   api_coordinator = MultiModelCoordinator.new()
   add_child(api_coordinator)
   api_coordinator.initialize_connections()
   ```

2. **Access Method in main.gd**
   ```gdscript
   # Get the API Coordinator
   func get_api_coordinator():
       return api_coordinator
   ```

3. **ViewArea Integration**
   ```gdscript
   # Add API UI to view area
   func show_api_coordinator_ui():
       var ui_scene = load("res://Eden_May/api_coordinator.tscn")
       var ui_instance = ui_scene.instance()
       add_to_view_area(ui_instance)
   ```

4. **Register with System Registry**
   ```gdscript
   # In _ready() after initialization
   register_system(api_coordinator, "api_coordinator")
   ```

## Drive Connections for Data Integration

The system supports connecting to various data sources:

1. **Local Files**
   ```gdscript
   api_coordinator.connect_to_drive("local", {
       "path": "res://",
       "type": "local"
   })
   ```

2. **Google Drive** (configuration required)
   ```gdscript
   api_coordinator.connect_to_drive("gdrive", {
       "path": "https://drive.google.com/drive/folders/your-folder-id",
       "type": "gdrive",
       "auth_token": "your-auth-token"
   })
   ```

3. **OneDrive** (configuration required)
   ```gdscript
   api_coordinator.connect_to_drive("onedrive", {
       "path": "https://onedrive.live.com/your-folder-path",
       "type": "onedrive",
       "auth_token": "your-auth-token"
   })
   ```

## Using the Multi-Model Coordinator

### Basic API Requests

```gdscript
# Send request to a specific API
api_coordinator.send_request("gemini", "What is the capital of France?")

# Auto-select the best API for this request
api_coordinator.send_request("auto", "Analyze the following data...")

# Send to all APIs in parallel
api_coordinator.send_request("parallel", "Compare how different models answer this...")
```

### Data Parsing

```gdscript
# Parse JSON data
var result = api_coordinator.parse_data("local", "dictionary/root_dictionary.json")

# Parse CSV with specific options
var csv_result = api_coordinator.parse_data("local", "data/metrics.csv", {
    "format": "csv",
    "delimiter": ",",
    "has_header": true
})
```

### Handling Responses

```gdscript
# Connect to the response signal
api_coordinator.connect("api_response_received", self, "_on_api_response")

# Handle response
func _on_api_response(api_name, response, request_id):
    print("Got response from " + api_name + ": " + response)
```

## Command Interface

The system also provides convenient commands for the Eden_May console:

1. `/api connect <api_name>` - Connect to a specific API
2. `/api disconnect <api_name>` - Disconnect from a specific API
3. `/api status` - Show current connection status
4. `/api request <api_name> <text>` - Send a request to an API
5. `/api show` - Show the API Coordinator UI
6. `/api colors` - Show the color progression explanation

## Color Transition In-Game Effects

The color state can be used for in-game visual effects:

```gdscript
# Get current color
var current_color = api_coordinator.get_current_color()

# Apply to game elements
$Background.modulate = current_color
$ParticleSystem.color = current_color

# Listen for changes
api_coordinator.connect("color_state_changed", self, "_on_color_changed")

func _on_color_changed(state_name, color):
    # Create transition effect
    $Tween.interpolate_property($Background, "modulate", 
                               $Background.modulate, color, 1.0,
                               Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
    $Tween.start()
```

## Security Notes

1. API keys should be stored securely and never committed to version control
2. Use environment variables or a secure configuration file for API keys
3. Implement rate limiting to avoid excessive API usage
4. Be mindful of data privacy when parsing and processing information

## Next Steps for Integration

1. Complete the Layer 0 integration by adding the API Coordinator to your scene
2. Create menu entries for accessing the API Coordinator
3. Configure your API keys for the services you have accounts for
4. Set up data sources for your specific needs
5. Add game-specific visual effects based on the color progression system