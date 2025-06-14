# Screen Capture & OCR System

A comprehensive screen capture and OCR (Optical Character Recognition) system implemented in Godot, with support for automatic updates, connections, theming, and animations.

## Features

### Screen Capture
- Multiple capture methods (native, GDI, DirectX)
- Support for capturing full screen, specific windows, or regions
- Clipboard image extraction
- Automatic saving with configurable format and quality
- Hotkey support (Ctrl+Shift+P)

### OCR Processing
- Online and offline OCR capabilities
- Multiple language support
- Text recognition with confidence scoring
- Emotion detection in text
- Caching system for improved performance
- Fallback mechanism when online services are unavailable
- Hotkey support (Ctrl+Shift+O)

### Auto-Update System
- Version checking against remote server
- Automatic download of updates
- Support for multiple update channels (stable, beta, dev)
- Detailed release notes
- Configurable update behavior

### Auto-Connection System
- Automatic connection to various services (API, drive, OCR, network)
- Connection status monitoring
- Automatic reconnection with exponential backoff
- Priority-based connection sequence

### Extended Color Theme System
- Support for 16, 24, and 32-bit color depths
- HDR color support
- Multiple preset themes (default, dark, light, high-contrast, ethereal, akashic)
- Dynamic theme creation based on base colors
- Smooth transitions between themes
- Time-based automatic theme switching
- Accessibility features (contrast ratio enforcement)

### Task Transition Animation
- Multiple transition types (fade, slide, zoom, flip, dissolve, etc.)
- Integration with color theme system
- Customizable durations and easing functions
- Support for particle effects
- Task focus/blur effects

### Main Controller
- Central management of all subsystems
- Automatic initialization and component discovery
- Signal connections between components
- Default settings configuration
- Debug mode for detailed logging

## Architecture

The system is composed of the following main components:

1. **ScreenCaptureUtility**: Handles all screen capture operations
2. **OCRProcessor**: Processes images for text recognition
3. **OfflineOCRProcessor**: Provides offline OCR capabilities as fallback
4. **AutoUpdater**: Manages software updates
5. **AutoConnector**: Handles connections to external services
6. **ExtendedColorThemeSystem**: Manages color themes and transitions
7. **TaskTransitionAnimator**: Provides animations for task transitions
8. **MainController**: Coordinates all components

## Usage

### Basic Usage

```gdscript
# Get reference to the main controller
var controller = get_node("/root/MainController")

# Capture screen
controller.capture_screen()

# Perform OCR on an image
controller.perform_ocr("/path/to/image.png")

# Capture screen and perform OCR in one step
controller.capture_and_ocr()

# Change theme
controller.change_theme("dark")

# Check for updates
controller.check_for_updates()

# Connect to services
controller.connect_services()
```

### Advanced Usage

#### Screen Capture

```gdscript
var screen_capture = get_node("/root/ScreenCaptureUtility")

# Capture specific region
screen_capture.capture_region(100, 100, 400, 300)

# Capture specific window
screen_capture.capture_window("Notepad")

# Capture from clipboard
screen_capture.capture_from_clipboard()

# Configure capture format
screen_capture.set_capture_format("jpg")
screen_capture.set_capture_quality(90)
```

#### OCR Processing

```gdscript
var ocr_processor = get_node("/root/OCRProcessor")

# Process image with specific options
ocr_processor.process_image("/path/to/image.png", "ocr_1", {
    "language": "eng",
    "preprocessing": true,
    "confidence_threshold": 0.7
})

# Get statistics
var stats = ocr_processor.get_statistics()
print("Images processed: " + str(stats.images_processed))
```

#### Color Theming

```gdscript
var theme_system = get_node("/root/ExtendedColorThemeSystem")

# Create custom theme
theme_system.create_theme("custom", Color(0.2, 0.5, 0.8))

# Create color scheme
var scheme = theme_system.create_color_scheme(Color(0.7, 0.2, 0.3), "triadic")
print("Triadic colors: ", scheme)

# Set color temperature
theme_system.set_color_temperature(5500)
```

#### Task Animation

```gdscript
var animator = get_node("/root/TaskTransitionAnimator")

# Register UI nodes
animator.register_ui_node("task1", $Task1Panel)
animator.register_ui_node("task2", $Task2Panel)

# Perform transition
animator.transition("task1", "task2", animator.TransitionType.ZOOM)

# Focus/blur tasks
animator.focus_task("task1")
animator.blur_task("task2")
```

## Installation

1. Copy all script files to your Godot project
2. Add the MainController script to a node in your scene
3. Set `auto_initialize` to true
4. Configure as needed

## Requirements

- Godot 4.x
- Windows 11 (for native screen capture features)
- Internet connection (for online OCR and updates)

## Notes

- For offline OCR to work properly, language data files must be installed
- Some transition effects require shader support
- For screen capture in sandboxed environments, additional permissions may be needed