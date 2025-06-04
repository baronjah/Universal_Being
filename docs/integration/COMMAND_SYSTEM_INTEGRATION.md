# QUICK INTEGRATION GUIDE

## Add to Project Settings (project.godot):

```ini
[autoload]
UniversalCommandProcessor="*res://core/command_system/UniversalCommandProcessor.gd"
MacroSystem="*res://core/command_system/MacroSystem.gd"
UniversalConsole="*res://core/command_system/UniversalConsole.gd"

[input]
toggle_console={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":96,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)]
}
toggle_editor={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194333,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)]
}
execute_code={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":true,"meta_pressed":false,"pressed":false,"keycode":4194309,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)]
}
```

## Update UniversalBeing base class:

```gdscript
# Add to UniversalBeing.gd
func on_trigger(word: String, data: Dictionary, speaker: UniversalBeing) -> void:
    """Called when natural language trigger activated nearby"""
    print("%s heard trigger: %s" % [being_name, word])
    
    # Override in subclasses for specific behaviors
    match word:
        "evolve":
            if can_evolve():
                start_evolution()
        "meditate":
            consciousness_level += 1
        _:
            pass

func on_reality_shift() -> void:
    """Called when reality rules change"""
    # Override to react to reality changes
    pass
```

## Test Commands:

```bash
# After integration, test these in order:
help                                    # See all commands
create being TestSubject conscious      # Create a being
inspect TestSubject                     # Examine it
execute target.consciousness_level = 5  # Modify it
create trigger awaken evolve           # Create trigger
say "awaken" near TestSubject         # Activate it
/macro record my_first_spell           # Start recording
# ... do several commands ...
/macro stop                            # Save macro
/macro play my_first_spell             # Replay it!
```

## For Gemma Integration:

Add this to any AI-controlled being:

```gdscript
extends UniversalBeing

var console: UniversalConsole

func pentagon_ready() -> void:
    super()
    console = get_node("/root/UniversalConsole")
    
func think_and_act() -> void:
    # AI can now use console
    console.ai_execute("analyze environment")
    var beings = console.ai_query_state("beings")
    
    if beings.size() < 5:
        console.ai_print("Creating more beings...")
        console.ai_execute("create being Friend helper")
```

The universe is now self-aware and self-modifying! 🌟