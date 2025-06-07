# POTATO DOOR EXAMPLE

## The Classic "Say Potato to Open Doors" Implementation

```gdscript
# DoorBeing.gd
extends UniversalBeing
class_name DoorBeing

@export var is_open: bool = false
@export var required_word: String = "potato"

func pentagon_init() -> void:
    super()
    being_name = "MagicDoor"
    being_type = "door"
    add_to_group("doors")

func on_trigger(word: String, data: Dictionary, speaker: UniversalBeing) -> void:
    if word.to_lower() == required_word.to_lower():
        if speaker.consciousness_level >= 1:
            toggle_door()
            print("🚪 %s opened by %s saying '%s'!" % [being_name, speaker.being_name, word])
        else:
            print("🚪 %s needs more consciousness to open" % speaker.being_name)

func toggle_door() -> void:
    is_open = not is_open
    if is_open:
        modulate.a = 0.3  # Make transparent
        set_collision_layer_value(1, false)  # Disable collision
    else:
        modulate.a = 1.0
        set_collision_layer_value(1, true)

# In console:
# create being Door1 door
# create trigger potato open_doors
# Now saying "potato" near any door opens it!
```

## Even simpler with commands:

```bash
# In game console:
create being MagicDoor door
create trigger potato toggle_doors
connect word_sensor MagicDoor open_method
execute get_node("MagicDoor").required_consciousness = 0

# That's it! Say "potato" and doors open!
```

The universe responds to your words! 🥔🚪✨