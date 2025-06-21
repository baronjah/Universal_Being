# 🌟 Tutorial: Living 3D Words System
*Using Godot classes to create Akashic Notepad3D's word entities*

## Core Classes Needed
- **Node3D** - Base for all 3D objects
- **Label3D** - Display text in 3D space
- **AnimationPlayer** - Animate word evolution
- **Area3D** - Detect word interactions
- **CharacterBody3D** - Make words "walk" or move

## Step 1: Basic 3D Word Entity
```gdscript
# word_entity_3d.gd
extends Node3D

@export var word_text: String = "ETHEREAL"
@export var evolution_level: int = 0

@onready var label_3d: Label3D = $Label3D
@onready var area_3d: Area3D = $Area3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
    label_3d.text = word_text
    area_3d.body_entered.connect(_on_body_entered)
    
func evolve():
    evolution_level += 1
    animation_player.play("evolve")
    # Words grow, change color, gain consciousness
```

## Step 2: Word Movement System
Using **CharacterBody3D** for words that move:
```gdscript
# walking_word.gd
extends CharacterBody3D

@export var word_speed: float = 2.0
@export var consciousness_level: float = 0.0

func _physics_process(delta):
    # Words move based on consciousness
    if consciousness_level > 0.5:
        velocity = Vector3(randf() - 0.5, 0, randf() - 0.5) * word_speed
        move_and_slide()
```

## Step 3: Layer Reality Integration
Connect to your Layer Reality System:
```gdscript
# word_layer_entity.gd
extends Node3D

var current_layer: int = 3  # Full 3D by default

func change_layer(new_layer: int):
    match new_layer:
        0:  # Text only
            $Label3D.visible = true
            $MeshInstance3D.visible = false
        1:  # 2D projection
            $Label3D.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        3:  # Full 3D
            $Label3D.billboard = BaseMaterial3D.BILLBOARD_DISABLED
            $MeshInstance3D.visible = true
```

## Key Class Combinations

### For Floating Words
- **Node3D** + **Label3D** + **AnimationPlayer**
- Add **GPUParticles3D** for magical effects

### For Interactive Words
- **CharacterBody3D** + **Label3D** + **Area3D**
- Use **AudioStreamPlayer3D** for word "speech"

### For Word Evolution
- **AnimationTree** for complex state machines
- **Tween** for smooth transitions
- **ShaderMaterial** for visual effects

## Connection to 12 Turns System
```gdscript
# word_turn_evolution.gd
signal turn_advanced(turn_number)

func on_turn_change(turn: int):
    # Words evolve differently each turn
    match turn % 12:
        0: emit_signal("rebirth")
        3: scale *= 1.1  # Growth turns
        6: modulate.a = 0.7  # Ethereal turns
        9: consciousness_level += 0.1
```

## Advanced: Word Consciousness
Using **Area3D** for word awareness:
```gdscript
func _on_area_3d_body_entered(body):
    if body.has_method("is_word"):
        # Words recognize each other
        form_connection(body)
        
func form_connection(other_word):
    # Create visual link between words
    var line = Line3D.new()
    add_child(line)
    line.add_point(global_position)
    line.add_point(other_word.global_position)
```

## Performance Tips
1. Use **MultiMeshInstance3D** for many similar words
2. **LOD** (Level of Detail) for distant words
3. **VisibleOnScreenNotifier3D** to pause distant words
4. Pool word objects instead of creating/destroying

## Next Steps
- Study **VisualShader** nodes for word effects
- Explore **NavigationAgent3D** for word pathfinding
- Use **Skeleton3D** for words with "bones"