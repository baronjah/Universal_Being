# Ragdoll Tutorial System Plan

## 🎯 Core Issues to Fix

### 1. Movement Stacking Problem
Based on Luno's keyframes document, we need proper **state management**:
- Commands should **replace** not stack
- Each movement state should have clear **entry and exit**
- Use **easing functions** for smooth transitions

### 2. Animation Principles for Ragdoll

From the document, key principles for fluid movement:
- **Timing & Spacing**: Control speed through frame distribution
- **Arcs**: Natural curved paths, not straight lines
- **Follow-Through**: Body parts move at different rates
- **Weight & Balance**: Center of gravity shifts realistically
- **Ease-In/Ease-Out**: Natural acceleration/deceleration

## 🎓 Tutorial System Design

### Phase 1: Basic Movement Tutorial
```gdscript
# Tutorial steps with scene changes
var tutorial_steps = [
    {
        "name": "Standing Practice",
        "scene": "tutorial_stand_area",
        "objectives": ["Press ragdoll_stand", "Maintain balance for 3 seconds"],
        "hints": ["Notice how weight shifts", "See the slight sway for balance"]
    },
    {
        "name": "Walking Forward",
        "scene": "tutorial_straight_path", 
        "objectives": ["Walk forward 10 units", "Stop at marker"],
        "hints": ["Watch the arc of each step", "Notice overlapping leg motion"]
    },
    {
        "name": "Direction Control",
        "scene": "tutorial_open_area",
        "objectives": ["Walk in each direction", "Complete a square path"],
        "hints": ["Smooth transitions between directions", "No instant stops"]
    }
]
```

### Phase 2: Advanced Movement
- **Speed Changes**: Transition between slow/normal/fast
- **Jumping**: Anticipation → Action → Landing (squash/stretch)
- **Rotation**: Smooth turning with weight shift
- **Crouching**: Center of gravity lowering

### Phase 3: Physics Interaction
- **Pushing Objects**: Weight transfer visualization
- **Climbing**: Using momentum and balance
- **Recovery**: Getting up after falling

## 📊 Logging System

### User Action Logger
```gdscript
class_name TutorialLogger
extends Node

var log_file_path = "user://tutorial_log_%s.txt" % Time.get_datetime_string_from_system()
var log_data = []

func log_action(action: String, context: Dictionary) -> void:
    var entry = {
        "timestamp": Time.get_ticks_msec(),
        "action": action,
        "context": context,
        "ragdoll_state": get_ragdoll_state(),
        "fps": Engine.get_frames_per_second()
    }
    log_data.append(entry)
    _write_to_file(entry)

func get_ragdoll_state() -> Dictionary:
    # Capture current ragdoll position, velocity, state
    var ragdoll = get_tree().get_first_node_in_group("ragdolls")
    if ragdoll:
        return {
            "position": ragdoll.global_position,
            "state": ragdoll.walker.get_state_name() if ragdoll.walker else "unknown",
            "velocity": ragdoll.get_node("pelvis").linear_velocity if ragdoll.has_node("pelvis") else Vector3.ZERO
        }
    return {}
```

## 🎮 Implementation Steps

### 1. Fix Movement Commands
```gdscript
# In enhanced_ragdoll_walker.gd
var current_movement_command = null

func set_movement_input(input: Vector2) -> void:
    # Cancel previous movement
    if current_movement_command:
        _cancel_movement()
    
    # Apply new movement with easing
    current_movement_command = input
    _apply_movement_with_easing(input)

func _apply_movement_with_easing(input: Vector2) -> void:
    # Use Bezier curves for smooth transitions
    var ease_curve = preload("res://resources/movement_ease_curve.tres")
    # Apply over time, not instantly
```

### 2. Scene Transition System
```gdscript
class_name TutorialSceneManager
extends Node

func transition_to_scene(scene_name: String, transition_type: String = "fade") -> void:
    match transition_type:
        "fade":
            _fade_transition(scene_name)
        "slide":
            _slide_transition(scene_name)
        "instant":
            get_tree().change_scene_to_file(scene_name)

func _fade_transition(scene_name: String) -> void:
    # Smooth fade using animation principles
    var tween = create_tween()
    tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.5)
    tween.tween_callback(get_tree().change_scene_to_file.bind(scene_name))
    tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.5)
```

### 3. Visual Feedback System
Based on animation principles:
- **Motion Trails**: Show path of movement
- **Weight Indicators**: Visualize center of gravity
- **Force Vectors**: Display applied forces
- **Timing Markers**: Show keyframe positions

## 🔄 Tutorial Flow

### Interactive Learning Path
1. **Observe** - Watch AI demonstrate movement
2. **Practice** - User tries with guidance
3. **Challenge** - Complete tasks without hints
4. **Create** - Design own movement sequences

### Adaptive Difficulty
- Monitor user performance via logs
- Adjust physics parameters gradually
- Provide contextual hints based on errors

## 📈 Progress Tracking

### Metrics to Log
- Command accuracy
- Movement smoothness (velocity changes)
- Task completion time
- Error recovery attempts
- Creative exploration (trying non-tutorial moves)

### Feedback Loop
```gdscript
func analyze_user_performance() -> Dictionary:
    # Read log data
    # Identify patterns
    # Suggest improvements
    # Adjust tutorial difficulty
```

## 🎨 Animation Curve Presets

Based on Luno's document, create preset curves:
- **Linear**: Robotic movement (for contrast)
- **Ease-In-Out**: Natural start/stop
- **Bounce**: For playful movements
- **Overshoot**: For emphatic actions

## 🚀 Next Steps

1. **Immediate**: Fix movement stacking issue
2. **Short-term**: Implement basic tutorial scenes
3. **Medium-term**: Add logging and analytics
4. **Long-term**: AI-driven adaptive tutorials

This system combines Luno's animation principles with interactive learning!