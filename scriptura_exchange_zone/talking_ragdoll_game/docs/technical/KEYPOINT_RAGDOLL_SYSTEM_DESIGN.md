# Keypoint-Based Ragdoll System Design
*Date: 2025-05-26*

## Overview
Complete redesign of the ragdoll system focusing on keypoint-driven animation, environmental awareness, and realistic movement cycles.

## Core Problems with Current System
1. **Movement Disconnect**: Lower torso moves while legs drag behind
2. **No Environmental Awareness**: Ragdoll doesn't check surroundings or ground
3. **Poor Ground Contact**: Feet float or sink, no proper ground detection
4. **Lack of Animation Cycles**: No proper stepping sequence or timing
5. **Missing IK Goals**: Limbs don't have target positions to reach for

## New Architecture

### 1. Keypoint System
Each limb has multiple keypoints that define its movement goals:

```gdscript
class LimbKeypoint:
    var rest_position: Vector3      # Default position relative to parent
    var current_goal: Vector3       # Where this keypoint wants to be
    var goal_weight: float          # How strongly to pursue goal (0-1)
    var ground_contact: bool        # Is this point touching ground?
    var last_ground_pos: Vector3    # Last valid ground position
```

### 2. Animation States & Cycles
```gdscript
class AnimationCycle:
    var name: String               # "walk", "run", "turn", etc.
    var duration: float            # Total cycle time
    var keyframes: Array[Keyframe] # Time-based keypoint goals
    var loop: bool                 # Does it repeat?
    
class Keyframe:
    var time: float                # When in cycle (0-1)
    var limb_goals: Dictionary     # {limb_name: goal_position}
    var easing: String             # "linear", "ease_in_out", etc.
```

### 3. Environmental Awareness System
```gdscript
class EnvironmentScanner:
    var ground_rays: Array[RayCast3D]    # Multiple rays for terrain
    var obstacle_sensors: Array[Area3D]   # Detect walls/objects
    var edge_detectors: Array[RayCast3D] # Prevent falling off edges
    
    func scan_surroundings() -> EnvironmentData:
        # Returns ground height, slope, nearby obstacles, safe directions
```

### 4. Movement Planning
```gdscript
class MovementPlanner:
    var current_state: String          # "idle", "walking", "turning", etc.
    var target_velocity: Vector3       # Where we want to move
    var safe_directions: Array         # From environment scan
    var next_foot_placement: Vector3   # Where to place foot next
    var balance_point: Vector3         # Center of mass target
```

## Implementation Plan

### Phase 1: Ground Detection & Balance
```gdscript
# New ground detection system
class GroundDetector:
    var foot_rays: Dictionary = {
        "left_foot": [],   # Multiple rays per foot
        "right_foot": []   # For better ground conforming
    }
    
    func get_ground_info(foot_pos: Vector3) -> GroundInfo:
        # Returns height, normal, material type
        # Handles slopes, stairs, uneven terrain
```

### Phase 2: Keypoint Animation System
```gdscript
# Procedural animation with keypoints
class KeypointAnimator:
    var limbs: Dictionary = {}  # All limb keypoints
    var active_cycle: AnimationCycle
    var cycle_time: float = 0.0
    
    func update_keypoints(delta: float):
        # Update cycle time
        cycle_time = fmod(cycle_time + delta, active_cycle.duration)
        
        # Calculate current keyframe blend
        var frame_data = get_blended_frame(cycle_time)
        
        # Apply to each limb with IK
        for limb in limbs:
            apply_ik_goal(limb, frame_data[limb])
```

### Phase 3: State Machine with Transitions
```gdscript
# Proper state management
class RagdollStateMachine:
    var states = {
        "idle": IdleState.new(),
        "walk": WalkState.new(),
        "run": RunState.new(),
        "turn": TurnState.new(),
        "pickup": PickupState.new(),
        "fall": FallState.new(),
        "recover": RecoverState.new()
    }
    
    func transition_to(new_state: String, blend_time: float):
        # Smooth transition between animation cycles
```

### Phase 4: Tutorial Scenarios

#### Scenario 1: Basic Movement
- **Goal**: Walk to marked location
- **Teaches**: Ground detection, basic stepping
- **Environment**: Flat ground with visual markers

#### Scenario 2: Obstacle Navigation
- **Goal**: Navigate around objects
- **Teaches**: Environmental awareness, turning
- **Environment**: Room with furniture

#### Scenario 3: Item Interaction
- **Goal**: Pick up and place objects
- **Teaches**: Reaching, grabbing, balance while carrying
- **Environment**: Table with objects

#### Scenario 4: Terrain Adaptation
- **Goal**: Walk on uneven ground
- **Teaches**: Slope handling, stair climbing
- **Environment**: Ramps, stairs, hills

## Key Features

### 1. Foot Placement System
```gdscript
func calculate_next_foot_position(current_pos: Vector3, move_dir: Vector3) -> Vector3:
    # Consider:
    # - Current momentum
    # - Ground height ahead
    # - Optimal step length
    # - Obstacles
    # - Balance requirements
```

### 2. Balance Controller
```gdscript
func maintain_balance():
    # Keep center of mass over support polygon
    # Adjust upper body to compensate
    # Trigger recovery animations if falling
```

### 3. IK Chain Solver
```gdscript
func solve_limb_ik(limb: RigidBody3D, target: Vector3):
    # Two-bone IK for legs
    # Consider joint limits
    # Maintain natural poses
```

## Visual Debug System
- Show keypoint goals as colored spheres
- Draw IK target lines
- Display ground contact points
- Show balance center and support polygon
- Highlight active animation state

## Performance Considerations
- Use object pooling for rays/areas
- Limit IK iterations per frame
- LOD system for distant ragdolls
- Optimize ground checks with spatial hashing

## Integration with Existing Systems
- Keep physics-based for impacts/collisions
- Blend between animation and physics
- Support for multiple ragdolls
- Network-friendly state synchronization