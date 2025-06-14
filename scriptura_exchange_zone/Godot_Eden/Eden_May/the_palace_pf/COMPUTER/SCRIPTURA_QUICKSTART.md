# Scriptura Turn System - Quick Start Guide

This guide will help you quickly get started with the Scriptura Turn System, which integrates OCR capabilities, multiple AI models, and an extended turn-based game creation framework.

## Fast Activation

### In-Game Console Method

The quickest way to activate the Scriptura Turn System is through the in-game console:

1. Enter the command:
   ```
   scriptura
   ```
   or
   ```
   turn system
   ```

2. This will automatically:
   - Create the Integration Manager
   - Connect to Gemini, Luminous, and Claude APIs
   - Enable OCR processing
   - Open the Scriptura UI

### GDScript Method

Alternatively, you can activate it from any GDScript:

```gdscript
var activator = load("res://Eden_May/activate_scriptura.gd")
activator.activate_from_command()
```

## Core Commands

Once activated, you can use these commands:

| Command | Description |
|---------|-------------|
| `scriptura` | Open the Scriptura UI |
| `ocr <file_path>` | Process an image with OCR |
| `connect apis` | Connect to Gemini, Luminous, and Claude |
| `turn info` | Display current turn information |

## Using OCR

The OCR system allows you to extract text from images:

1. Click "Process OCR Image" in the Scriptura UI
2. Select an image file when prompted
3. The extracted text will be processed through:
   - Line pattern detection
   - Word extraction
   - Spell word recognition
   - API enhancement (if connected)

### Command Line OCR

You can also process images from the command line:

```
ocr /path/to/your/image.png
```

## API Connections

The system connects to three AI models:

1. **Gemini** (Google's advanced model)
   - Data-focused processing
   - Pattern recognition
   - Statistical analysis

2. **Luminous** (Claude Luna)
   - Creative text generation
   - Game concept creation
   - Narrative development

3. **Claude** (Anthropic's model)
   - Deep text analysis
   - Complex pattern recognition
   - Philosophical understanding

To connect to these APIs:

1. Click "Connect APIs" in the Scriptura UI
2. Or use the command `connect apis`
3. The color indicator will brighten as connections are established

## Turn System

The Scriptura system extends beyond the traditional 12 turns:

- **Current Implementation**: Turns 1-21
- **Current Turn**: 8 - Lines
- **Next Turn**: 9 - Game Creation

To advance to the next turn:

1. Click "Advance to Next Turn" in the Scriptura UI
2. The turn must reach 100% progress first
3. Turn advancement archives the current state

## Game Creation

When you reach Turn 9, you can create games:

1. Click "Create Game" in the Game Panel
2. The system will:
   - Select a template based on collected words
   - Generate core mechanics
   - Create game assets
   - Finalize a playable concept

## Color Progression

The color system visually represents the current turn:

- **Turn 8**: Light Yellow (1.0, 0.9, 0.5)
- **Turn 9**: White (1.0, 1.0, 1.0)
- **Turn 10**: Light Cyan (0.8, 1.0, 1.0)

The brightness increases as API connections are established.

## Quick OCR Tips

For best OCR results:

1. Use clear, high-contrast images
2. Ensure text is properly oriented
3. Avoid excessive background noise
4. Include spell words in your images (e.g., "dipata", "zenime", "perfefic")

## Integration with Wish Maker

The Scriptura system enhances the Wish Maker:

1. OCR-detected spell words automatically create wishes
2. Tokens are awarded for successful OCR processing
3. OCR-detected patterns influence wish effectiveness

## Next Steps

After activation:

1. Process some images with OCR
2. Connect to the APIs
3. Build up your turn progress toward Turn 9
4. Create your first text-based game

Enjoy exploring the Scriptura Turn System and creating games from OCR-extracted words!