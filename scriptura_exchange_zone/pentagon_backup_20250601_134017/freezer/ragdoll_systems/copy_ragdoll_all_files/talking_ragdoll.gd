# ==================================================
# SCRIPT NAME: talking_ragdoll.gd
# DESCRIPTION: A ragdoll character that talks constantly while being dragged
# CREATED: 2025-05-23 - The talking, draggable character
# ==================================================

extends RigidBody3D

# Dialogue lines for different situations
const IDLE_DIALOGUE = [
	"Oh hey there! Nice day for being a ragdoll, isn't it?",
	"You know, I used to have bones... I miss bones.",
	"Is anyone else floating? No? Just me? Cool, cool.",
	"I can see my house from here! Wait, I don't have a house.",
	"Sometimes I wonder if physics is just a suggestion.",
	"My therapist says I need to be more grounded. Ironic, right?",
	"I'm not drunk, I'm just... dimensionally flexible.",
	"Have you ever noticed how the ground is always down? Wild."
]

const BEING_DRAGGED_DIALOGUE = [
	"WHEEEEE! This is better than coffee!",
	"Oh we're going places now! Literally!",
	"Is this what birds feel like? Minus the feathers?",
	"I'm flying! I'm flying! Oh wait, I'm being dragged.",
	"This reminds me of my childhood. Very traumatic. Very fun.",
	"Faster! Faster! Oh wait, I might throw up. Do ragdolls throw up?",
	"You have very strong mouse muscles!",
	"I feel like a yo-yo! A sentient, talkative yo-yo!"
]

const COLLISION_DIALOGUE = [
	"OOF! That's gonna leave a mark. If I had skin.",
	"Hello wall! We meet again!",
	"I meant to do that. Very intentional collision.",
	"Physics! It's everywhere! Even in my face!",
	"That tree came out of nowhere!",
	"I'm okay! Everything's fine! Just a little dizzy!",
	"Did anyone get the number of that object?",
	"Note to self: Objects are solid. Very solid."
]

const FALLING_DIALOGUE = [
	"I believe I can fly! I believe I can touch the-- OW!",
	"Gravity is just a theory! A very painful theory!",
	"This is fine. Everything is fine. AHHHHHHH!",
	"I wonder if cats really land on their feet. What about ragdolls?",
	"Going down! Department store jokes, existential crisis, ground floor!",
	"Is it the fall that gets you or the sudden stop? Let's find out!"
]

# State management
var is_being_dragged: bool = false
var drag_offset: Vector3
var mouse_force_multiplier: float = 50.0
var talk_timer: float = 0.0
var talk_interval: float = 3.0
var last_dialogue_category: String = ""

# Components
@onready var dialogue_audio: AudioStreamPlayer3D = $DialogueAudio
@onready var collision_audio: AudioStreamPlayer3D = $CollisionAudio
@onready var drag_area: Area3D = $DragArea
@onready var speech_bubble: Label3D = $SpeechBubble
@onready var blink_controller: Node = null  # Will be created dynamically
@onready var left_eye: MeshInstance3D = null  # Eye meshes if available
@onready var right_eye: MeshInstance3D = null
@onready var visual_indicator: Node3D = null  # Health/name/status display
@onready var health_bar: ProgressBar = null
@onready var name_label: Label3D = null
@onready var status_label: Label3D = null

# Physics properties
var original_gravity_scale: float

# Entity stats for visual indicators
var entity_name: String = "Happy Ragdoll"
var max_health: float = 100.0
var current_health: float = 100.0
var current_action: String = "Idle"

func _ready() -> void:
	# Set up physics (Professional values)
	set_gravity_scale(0.7)
	set_linear_damp(5.0)
	set_angular_damp(15.0)
	mass = 10.0  # Heavy pelvis for stability
	original_gravity_scale = gravity_scale
	
	# Set up collision detection
	set_contact_monitor(true)
	set_max_contacts_reported(10)
	body_entered.connect(_on_body_entered)
	
	# Initialize blink animation system
	_setup_blink_animation()
	
	# Initialize visual indicators
	_setup_visual_indicators()
	
	# Start talking
	_say_something("IDLE")
	set_action_state("Idle")
	
	# Make sure we can be dragged
	set_freeze_enabled(false)
	
	# Random initial force for fun
	apply_central_impulse(Vector3(randf_range(-2, 2), 5, randf_range(-2, 2)))

func _physics_process(delta: float) -> void:
	# Update talking
	talk_timer += delta
	if talk_timer >= talk_interval:
		talk_timer = 0.0
		talk_interval = randf_range(2.0, 5.0)  # Random interval
		
		if is_being_dragged:
			_say_something("DRAGGED")
			set_action_state("Being Dragged")
		elif linear_velocity.y < -5.0:
			_say_something("FALLING")
			set_action_state("Falling")
		else:
			_say_something("IDLE")
			set_action_state("Idle")
	
	# Handle dragging
	if is_being_dragged:
		var mouse_pos = _get_mouse_world_position()
		if mouse_pos != Vector3.ZERO:
			var target_pos = mouse_pos + drag_offset
			var force = (target_pos - global_position) * mouse_force_multiplier
			apply_central_force(force)
			
			# Reduce gravity while dragging for easier control
			set_gravity_scale(0.3)
	else:
		set_gravity_scale(original_gravity_scale)
	
	# Update speech bubble to face camera
	if speech_bubble and speech_bubble.visible:
		var camera = get_viewport().get_camera_3d()
		if camera:
			speech_bubble.look_at(camera.global_position, Vector3.UP)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drag_ragdoll"):
		var mouse_pos = _get_mouse_world_position()
		if mouse_pos != Vector3.ZERO:
			var distance = global_position.distance_to(mouse_pos)
			if distance < 3.0:  # Within drag range
				is_being_dragged = true
				drag_offset = global_position - mouse_pos
				_say_something("DRAGGED")
	
	elif event.is_action_released("release_ragdoll"):
		if is_being_dragged:
			is_being_dragged = false
			# Add some random force on release for fun
			apply_central_impulse(Vector3(
				randf_range(-5, 5),
				randf_range(5, 10),
				randf_range(-5, 5)
			))

func _get_mouse_world_position() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return Vector3.ZERO
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100
	
	var space_state = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.exclude = [self]
	ray_query.collision_mask = 1  # Floor/ground layer
	
	var result = space_state.intersect_ray(ray_query)
	if result:
		return result.position
	
	# If no ground hit, project to a plane at y=0
	var plane = Plane(Vector3.UP, 0)
	return plane.intersects_ray(from, camera.project_ray_normal(mouse_pos))

func _say_something(category: String) -> void:
	var dialogue_pool: Array
	
	match category:
		"IDLE":
			dialogue_pool = IDLE_DIALOGUE
		"DRAGGED":
			dialogue_pool = BEING_DRAGGED_DIALOGUE
		"FALLING":
			dialogue_pool = FALLING_DIALOGUE
		"COLLISION":
			dialogue_pool = COLLISION_DIALOGUE
		_:
			dialogue_pool = IDLE_DIALOGUE
	
	# Avoid repeating the same category too much
	if category == last_dialogue_category and randf() > 0.7:
		return
	
	last_dialogue_category = category
	var line = dialogue_pool[randi() % dialogue_pool.size()]
	
	# Update speech bubble
	if speech_bubble:
		speech_bubble.text = line
		speech_bubble.visible = true
		
		# Hide after a delay
		get_tree().create_timer(3.0).timeout.connect(func(): speech_bubble.visible = false)
	
	# Play audio (if we had voice lines)
	if dialogue_audio:
		# dialogue_audio.play()
		pass
	
	# Also print to console for fun
	print("[Ragdoll]: " + line)

func _on_body_entered(body: Node) -> void:
	if body != self and not body.is_in_group("ignore_ragdoll"):
		_say_something("COLLISION")
		set_action_state("Colliding")
		
		# Take some damage on hard collisions
		if linear_velocity.length() > 10:
			take_damage(5.0)
		
		# Play collision sound
		if collision_audio:
			collision_audio.pitch_scale = randf_range(0.8, 1.2)
			# collision_audio.play()

## Make the ragdoll extra floppy
# INPUT: Floppiness factor (0.0 to 1.0)
# PROCESS: Adjusts physics properties for floppiness
# OUTPUT: None
# CHANGES: Physics damping and constraints
# CONNECTION: Can be called by console commands
func set_floppiness(factor: float) -> void:
	factor = clamp(factor, 0.0, 1.0)
	set_linear_damp(5.0 - (factor * 2.0))  # Scale from professional base value
	set_angular_damp(15.0 - (factor * 5.0))  # Scale from professional base value
	
	# More floppy = less stable
	if factor > 0.7:
		_say_something("IDLE")  # Will say something about being floppy

## Say custom text from console
# INPUT: Custom text to say
# PROCESS: Display the text in speech bubble
# OUTPUT: None
# CHANGES: Speech bubble visibility and text
# CONNECTION: Called by DialogueSystem from console
func _say_something_custom(text: String) -> void:
	if speech_bubble:
		speech_bubble.text = text
		speech_bubble.visible = true
		
		# Hide after a longer delay for custom text
		get_tree().create_timer(5.0).timeout.connect(func(): speech_bubble.visible = false)
	
	print("[Ragdoll Custom]: " + text)

## Setup blink animation system
# INPUT: None
# PROCESS: Creates and configures blink animation controller
# OUTPUT: None  
# CHANGES: Adds blink controller as child
# CONNECTION: Called from _ready()
func _setup_blink_animation() -> void:
	# Load the blink animation controller script
	var BlinkController = load("res://scripts/effects/blink_animation_controller.gd")
	if BlinkController:
		blink_controller = Node.new()
		blink_controller.set_script(BlinkController)
		blink_controller.name = "BlinkController"
		add_child(blink_controller)
		
		# Try to find eye nodes
		left_eye = find_child("*Eye*Left*", true, false) as MeshInstance3D
		right_eye = find_child("*Eye*Right*", true, false) as MeshInstance3D
		
		# If no specific eye nodes, look for any eye-like nodes
		if not left_eye:
			left_eye = find_child("*Eye*", true, false) as MeshInstance3D
		
		print("[Ragdoll] Blink animation system initialized!")
		
		# Connect blink events for special dialogue
		if blink_controller.has_signal("blink_started"):
			blink_controller.blink_started.connect(_on_blink_started)

func _on_blink_started() -> void:
	# Occasionally comment on blinking
	if randf() < 0.1:  # 10% chance
		var blink_comments = [
			"*blink*",
			"My eyes feel so realistic!",
			"Did you see that? I blinked!",
			"Blinking is my superpower!"
		]
		_say_something_custom(blink_comments[randi() % blink_comments.size()])
## Setup visual indicators (health, name, status)
# INPUT: None
# PROCESS: Creates visual indicator system above ragdoll
# OUTPUT: None
# CHANGES: Adds visual indicator nodes
# CONNECTION: Called from _ready()
func _setup_visual_indicators() -> void:
	# Load the visual indicator system
	var VisualIndicatorSystem = load("res://scripts/effects/visual_indicator_system.gd")
	if VisualIndicatorSystem:
		visual_indicator = Node3D.new()
		visual_indicator.set_script(VisualIndicatorSystem)
		visual_indicator.name = "VisualIndicator"
		add_child(visual_indicator)
		
		# Configure indicator
		if visual_indicator.has_method("setup_indicator"):
			visual_indicator.setup_indicator({
				"entity_name": entity_name,
				"max_health": max_health,
				"current_health": current_health,
				"show_health_bar": true,
				"show_name": true,
				"show_status": true,
				"offset_y": 2.5  # Above ragdoll head
			})
		
		print("[Ragdoll] Visual indicators initialized!")

## Update ragdoll status
# INPUT: New action/status string
# PROCESS: Updates the current action and visual indicator
# OUTPUT: None  
# CHANGES: current_action variable and status display
# CONNECTION: Called when ragdoll changes state
func set_action_state(action: String) -> void:
	current_action = action
	if visual_indicator and visual_indicator.has_method("update_status"):
		visual_indicator.update_status(action)
	
	# Update status label color based on action
	match action:
		"Idle": 
			if status_label: status_label.modulate = Color.WHITE
		"Walking":
			if status_label: status_label.modulate = Color.GREEN
		"Being Dragged":
			if status_label: status_label.modulate = Color.YELLOW
		"Falling":
			if status_label: status_label.modulate = Color.ORANGE
		"Colliding":
			if status_label: status_label.modulate = Color.RED

## Take damage (for testing health bar)
# INPUT: Damage amount
# PROCESS: Reduces health and updates visual indicator
# OUTPUT: None
# CHANGES: current_health and health bar display
# CONNECTION: Can be called by collision or console
func take_damage(amount: float) -> void:
	current_health = max(0, current_health - amount)
	if visual_indicator and visual_indicator.has_method("update_health"):
		visual_indicator.update_health(current_health / max_health)
	
	# Comment on damage
	if current_health <= 0:
		_say_something_custom("I'm... fading... tell my story...")
	elif current_health < 30:
		_say_something_custom("I don't feel so good...")
	elif amount > 20:
		_say_something_custom("OUCH! That really hurt!")
