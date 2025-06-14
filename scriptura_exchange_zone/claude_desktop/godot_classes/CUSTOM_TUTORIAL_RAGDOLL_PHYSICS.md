# 🎮 Tutorial: Advanced Ragdoll Console Creator
*Combining physics, consciousness, and console integration*

## Essential Classes for Ragdoll
- **CharacterBody3D** - Main controller
- **RigidBody3D** - Individual body parts
- **Joint3D** family - Connect parts
- **BoneAttachment3D** - Attach to skeleton
- **PhysicalBone3D** - Physics-enabled bones

## Building a 7-Part Ragdoll

### Core Structure
```gdscript
# advanced_ragdoll.gd
extends Node3D

# Body parts as RigidBody3D
@onready var head: RigidBody3D = $Head
@onready var torso: RigidBody3D = $Torso
@onready var left_arm: RigidBody3D = $LeftArm
@onready var right_arm: RigidBody3D = $RightArm
@onready var left_leg: RigidBody3D = $LeftLeg
@onready var right_leg: RigidBody3D = $RightLeg
@onready var pelvis: RigidBody3D = $Pelvis

# Joints
@onready var neck_joint: ConeTwistJoint3D = $NeckJoint
@onready var shoulder_left: Generic6DOFJoint3D = $ShoulderLeft
@onready var shoulder_right: Generic6DOFJoint3D = $ShoulderRight
```

### Joint Types & Usage

#### ConeTwistJoint3D - Perfect for neck/spine
```gdscript
func setup_neck_joint():
    neck_joint.node_a = torso.get_path()
    neck_joint.node_b = head.get_path()
    neck_joint.swing_span = 30.0  # degrees
    neck_joint.twist_span = 45.0
```

#### Generic6DOFJoint3D - Ultimate flexibility
```gdscript
func setup_shoulder():
    shoulder_left.node_a = torso.get_path()
    shoulder_left.node_b = left_arm.get_path()
    
    # Limit rotations
    shoulder_left.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -PI/2)
    shoulder_left.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, PI/2)
```

#### HingeJoint3D - Elbows/knees
```gdscript
func setup_elbow():
    elbow_joint.node_a = upper_arm.get_path()
    elbow_joint.node_b = lower_arm.get_path()
    elbow_joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, 0)
    elbow_joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, 140)
```

## Console Creation Integration

### Making Ragdoll "Speak" Commands
```gdscript
# ragdoll_console_creator.gd
extends CharacterBody3D

signal console_command_created(command: String)

@export var creation_power: float = 0.0
var accumulated_motion: Vector3 = Vector3.ZERO

func _physics_process(delta):
    # Track ragdoll movement
    accumulated_motion += velocity * delta
    
    # Movement creates console energy
    creation_power = accumulated_motion.length()
    
    if creation_power > 10.0:
        create_console_command()
        accumulated_motion = Vector3.ZERO

func create_console_command():
    var commands = ["spawn", "evolve", "connect", "layer", "dimension"]
    var command = commands[randi() % commands.size()]
    emit_signal("console_command_created", command)
```

## Layer Reality for Ragdolls

### Different Physics per Layer
```gdscript
func set_reality_layer(layer: int):
    match layer:
        0:  # Text mode - disable physics
            for body in get_rigid_bodies():
                body.freeze = true
        1:  # 2D mode - constrain to plane
            for body in get_rigid_bodies():
                body.axis_lock_position_y = true
                body.axis_lock_angular_x = true
                body.axis_lock_angular_z = true
        3:  # Full 3D
            for body in get_rigid_bodies():
                body.freeze = false
                body.axis_lock_position_y = false
```

## Consciousness System for Ragdoll

### Using Area3D for Awareness
```gdscript
# ragdoll_consciousness.gd
extends Node3D

@export var consciousness_level: float = 0.0
@onready var awareness_area: Area3D = $AwarenessArea

var nearby_entities: Array = []

func _ready():
    awareness_area.body_entered.connect(_on_awareness_entered)
    awareness_area.body_exited.connect(_on_awareness_exited)

func _on_awareness_entered(body):
    nearby_entities.append(body)
    consciousness_level += 0.1
    
    if body.has_method("is_word"):
        # Ragdoll learns from words
        learn_word(body.word_text)
```

## Advanced Techniques

### Motorized Ragdoll Movement
```gdscript
# ragdoll_motor.gd
@export var motor_strength: float = 100.0

func apply_motor_impulse(joint: Generic6DOFJoint3D, target_angle: Vector3):
    joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, 
                      target_angle.x * motor_strength)
    joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_MOTOR, true)
```

### Balance System
```gdscript
# ragdoll_balance.gd
@export var balance_force: float = 50.0

func maintain_balance():
    var com = calculate_center_of_mass()
    var support_point = get_support_point()
    
    if com.x > support_point.x + 0.1:
        # Apply corrective force
        torso.apply_central_impulse(Vector3(-balance_force, 0, 0))
```

## Performance Optimization

### LOD for Ragdolls
```gdscript
func update_lod(camera_distance: float):
    if camera_distance > 50:
        # Simplify physics
        set_physics_process(false)
        $AnimationPlayer.stop()
    elif camera_distance > 20:
        # Reduce joint complexity
        Engine.physics_ticks_per_second = 30
    else:
        # Full quality
        Engine.physics_ticks_per_second = 60
```

## Connection to Eden OS
```gdscript
# ragdoll_dimensional_consciousness.gd
var current_dimension: int = 3
var dimension_colors = [
    Color.RED,    # Physical
    Color.BLUE,   # Mental
    Color.GREEN,  # Emotional
    Color.PURPLE  # Spiritual
]

func shift_dimension(new_dim: int):
    current_dimension = new_dim
    modulate = dimension_colors[new_dim % dimension_colors.size()]
    
    # Adjust physics based on dimension
    for body in get_rigid_bodies():
        body.gravity_scale = 1.0 / (new_dim + 1)
```

## Next Evolution
1. Study **SkeletonIK3D** for procedural animation
2. Explore **SpringArm3D** for camera following
3. Use **SoftBody3D** for cloth/hair
4. Implement **PhysicalBoneSimulator3D** for advanced skeletons