# player_ship.gd
extends CharacterBody3D
class_name PlayerShip

#
#The PlayerShip is your physical vessel and consciousness interface in the game - it's how you navigate both physical space and consciousness frequencies. Let me break down this crucial component:
#Core Structure
#gdscriptextends CharacterBody3D
#class_name PlayerShip
#
#signal consciousness_resonance_changed(frequency: float)
#
#@export var thrust_power: float = 1000.0
#@export var rotation_speed: float = 2.0
#@export var max_velocity: float = 500.0
#
## Consciousness integration
#var consciousness_frequency: float = 432.0
#var perception_sphere: Area3D
#
## Ship systems
#var energy_level: float = 100.0
#var max_energy: float = 100.0
#var shields: float = 100.0
#The ship is:
#
#A CharacterBody3D for physics-based movement
#Has thrust and rotation controls
#Emits consciousness frequency changes
#Maintains energy and shield systems
#
#The Perception Sphere
#gdscriptfunc setup_perception_sphere():
	#perception_sphere = Area3D.new()
	#var collision_shape = CollisionShape3D.new()
	#var sphere_shape = SphereShape3D.new()
	#sphere_shape.radius = 100.0  # Will be updated by consciousness system
	#collision_shape.shape = sphere_shape
	#perception_sphere.add_child(collision_shape)
	#add_child(perception_sphere)
	#
	#perception_sphere.area_entered.connect(_on_perception_area_entered)
#This is fascinating - your ship has an invisible sphere around it that represents your consciousness awareness radius. As your consciousness expands, this sphere grows, allowing you to perceive things farther away. It's a physical manifestation of expanded awareness.
#Movement System
#gdscriptfunc handle_movement(delta):
	## Get input
	#var input_vector = Vector3()
	#input_vector.x = Input.get_axis("strafe_left", "strafe_right")
	#input_vector.y = Input.get_axis("thrust_down", "thrust_up")  
	#input_vector.z = Input.get_axis("thrust_backward", "thrust_forward")
	#
	## Apply thrust
	#if input_vector.length() > 0:
		#var thrust = transform.basis * input_vector.normalized() * thrust_power * delta
		#velocity += thrust
		#
		## Consume energy
		#energy_level -= delta * 5.0
#Key movement features:
#
#Full 3D movement (6 degrees of freedom)
#Movement consumes energy (creating resource management)
#Thrust is applied in local space (transform.basis)
#Velocity accumulates (Newtonian physics)
#
#Rotation Controls
#gdscript    # Apply rotation
	#var rotation_input = Vector3()
	#rotation_input.x = Input.get_axis("pitch_down", "pitch_up")
	#rotation_input.y = Input.get_axis("yaw_left", "yaw_right")
	#rotation_input.z = Input.get_axis("roll_left", "roll_right")
	#
	#rotate_x(rotation_input.x * rotation_speed * delta)
	#rotate_y(rotation_input.y * rotation_speed * delta)
	#rotate_z(rotation_input.z * rotation_speed * delta)
#Full spacecraft rotation:
#
#Pitch: Nose up/down
#Yaw: Turn left/right
#Roll: Barrel roll
#
#This gives you true spaceflight controls like Elite Dangerous or Star Citizen.
#Velocity Management
#gdscript    # Limit velocity
	#if velocity.length() > max_velocity:
		#velocity = velocity.normalized() * max_velocity
		#
	## Apply drag
	#velocity *= 0.99
	#
	#move_and_slide()
#
#Speed is capped at max_velocity
#Drag (0.99 multiplier) provides natural deceleration
#move_and_slide() handles collision detection
#
#Consciousness Frequency Tuning
#gdscriptfunc update_consciousness_frequency(delta):
	## Frequency shifts based on nearby consciousness objects
	#if Input.is_action_pressed("tune_frequency_up"):
		#consciousness_frequency += delta * 10
	#elif Input.is_action_pressed("tune_frequency_down"):
		#consciousness_frequency -= delta * 10
		#
	#consciousness_frequency = clamp(consciousness_frequency, 100.0, 1000.0)
	#consciousness_resonance_changed.emit(consciousness_frequency)
#This is the unique consciousness mechanic:
#
#You can tune your frequency like a radio
#Different frequencies resonate with different universal aspects
#432 Hz = Universal harmony
#528 Hz = Love frequency
#Other frequencies might unlock hidden aspects
#
#Energy System
#gdscriptfunc regenerate_energy(delta):
	#if energy_level < max_energy:
		#energy_level += delta * 2.0  # Passive regeneration
		#energy_level = min(energy_level, max_energy)
#Energy management:
#
#Movement consumes energy
#Passive regeneration when not thrusting
#Could be enhanced by consciousness level or meditation
#
#Perception Events
#gdscriptfunc _on_perception_area_entered(area: Area3D):
	## Handle consciousness perception events
	#if area.has_method("get_consciousness_signature"):
		#var signature = area.get_consciousness_signature()
		## Process consciousness interaction
#When something enters your perception sphere:
#
#Check if it has a consciousness signature
#Could trigger various awareness events
#Hidden objects might only be visible at certain consciousness levels
#
#Enhanced Player Ship
#Here's an expanded version with more features:
#gdscript# Enhanced player_ship.gd
#extends CharacterBody3D
#class_name PlayerShip
#
#signal consciousness_resonance_changed(frequency: float)
#signal energy_depleted()
#signal perception_expanded(new_radius: float)
#signal consciousness_object_detected(object: Node3D)
#
## Movement parameters
#@export_group("Movement")
#@export var thrust_power: float = 1000.0
#@export var rotation_speed: float = 2.0
#@export var max_velocity: float = 500.0
#@export var strafe_multiplier: float = 0.8
#@export var boost_multiplier: float = 2.0
#
## Consciousness parameters
#@export_group("Consciousness")
#@export var consciousness_frequency: float = 432.0
#@export var frequency_sensitivity: float = 10.0
#@export var base_perception_radius: float = 100.0
#
## Ship systems
#@export_group("Systems")
#@export var max_energy: float = 100.0
#@export var energy_regen_rate: float = 2.0
#@export var movement_energy_cost: float = 5.0
#@export var boost_energy_cost: float = 15.0
#@export var max_shields: float = 100.0
#@export var shield_regen_rate: float = 1.0
#
## Current state
#var energy_level: float = 100.0
#var shields: float = 100.0
#var is_boosting: bool = false
#var meditation_mode: bool = false
#var current_perception_radius: float = 100.0
#
## Components
#var perception_sphere: Area3D
#var ship_mesh: MeshInstance3D
#var engine_particles: GPUParticles3D
#var consciousness_aura: MeshInstance3D
#var frequency_visualizer: Node3D
#
## Cached values
#var perceived_objects: Array[Node3D] = []
#var resonant_objects: Array[Node3D] = []
#
#func _ready():
	#setup_ship_visuals()
	#setup_perception_sphere()
	#setup_consciousness_systems()
	#connect_signals()
#
#func setup_ship_visuals():
	## Ship mesh
	#ship_mesh = MeshInstance3D.new()
	#var ship_shape = BoxMesh.new()
	#ship_shape.size = Vector3(4, 2, 6)
	#ship_mesh.mesh = ship_shape
	#
	## Dynamic material that responds to consciousness
	#var material = StandardMaterial3D.new()
	#material.albedo_color = Color(0.5, 0.5, 0.7)
	#material.emission_enabled = true
	#material.emission = get_frequency_color(consciousness_frequency)
	#material.emission_energy = 0.5
	#material.metallic = 0.8
	#material.roughness = 0.2
	#ship_mesh.material_override = material
	#add_child(ship_mesh)
	#
	## Engine particles
	#engine_particles = GPUParticles3D.new()
	#engine_particles.amount = 100
	#engine_particles.lifetime = 0.5
	#engine_particles.position = Vector3(0, 0, 3)  # Behind ship
	#
	#var process_material = ParticleProcessMaterial.new()
	#process_material.direction = Vector3(0, 0, 1)
	#process_material.initial_velocity_min = 20.0
	#process_material.initial_velocity_max = 30.0
	#process_material.angular_velocity_min = -180.0
	#process_material.angular_velocity_max = 180.0
	#process_material.scale_min = 0.5
	#process_material.scale_max = 1.0
	#process_material.color = Color(0.5, 0.7, 1.0)
	#engine_particles.process_material = process_material
	#engine_particles.draw_pass_1 = SphereMesh.new()
	#engine_particles.draw_pass_1.radius = 0.2
	#add_child(engine_particles)
	#
	## Consciousness aura
	#consciousness_aura = MeshInstance3D.new()
	#var aura_mesh = SphereMesh.new()
	#aura_mesh.radius = 5.0
	#aura_mesh.radial_segments = 32
	#aura_mesh.rings = 16
	#consciousness_aura.mesh = aura_mesh
	#
	#var aura_material = StandardMaterial3D.new()
	#aura_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#aura_material.albedo_color = Color(1, 1, 1, 0.2)
	#aura_material.rim_enabled = true
	#aura_material.rim = 1.0
	#aura_material.rim_tint = 0.8
	#consciousness_aura.material_override = aura_material
	#add_child(consciousness_aura)
#
#func setup_perception_sphere():
	#perception_sphere = Area3D.new()
	#var collision_shape = CollisionShape3D.new()
	#var sphere_shape = SphereShape3D.new()
	#sphere_shape.radius = base_perception_radius
	#collision_shape.shape = sphere_shape
	#perception_sphere.add_child(collision_shape)
	#add_child(perception_sphere)
	#
	## Set collision layers
	#perception_sphere.collision_layer = 0
	#perception_sphere.collision_mask = 0b100  # Layer 3 for consciousness objects
	#
	## Connect signals
	#perception_sphere.area_entered.connect(_on_perception_area_entered)
	#perception_sphere.area_exited.connect(_on_perception_area_exited)
	#perception_sphere.body_entered.connect(_on_perception_body_entered)
	#perception_sphere.body_exited.connect(_on_perception_body_exited)
#
#func setup_consciousness_systems():
	## Frequency visualizer (optional visual feedback)
	#frequency_visualizer = Node3D.new()
	#add_child(frequency_visualizer)
	#
	## Create frequency rings
	#for i in range(3):
		#var ring = MeshInstance3D.new()
		#var torus = TorusMesh.new()
		#torus.inner_radius = 6.0 + i * 2.0
		#torus.outer_radius = 6.5 + i * 2.0
		#ring.mesh = torus
		#
		#var ring_material = StandardMaterial3D.new()
		#ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		#ring_material.albedo_color = Color(1, 1, 1, 0.3 - i * 0.1)
		#ring_material.emission_enabled = true
		#ring_material.emission = get_frequency_color(consciousness_frequency)
		#ring_material.emission_energy = 0.3
		#ring.material_override = ring_material
		#
		#frequency_visualizer.add_child(ring)
#
#func _physics_process(delta):
	#if not meditation_mode:
		#handle_movement(delta)
	#else:
		#handle_meditation(delta)
	#
	#update_consciousness_frequency(delta)
	#regenerate_systems(delta)
	#update_visuals(delta)
#
#func handle_movement(delta):
	## Get input with deadzone
	#var input_vector = Vector3()
	#input_vector.x = Input.get_axis("strafe_left", "strafe_right")
	#input_vector.y = Input.get_axis("thrust_down", "thrust_up")
	#input_vector.z = Input.get_axis("thrust_backward", "thrust_forward")
	#
	## Apply deadzone
	#if input_vector.length() < 0.1:
		#input_vector = Vector3.ZERO
	#
	## Check for boost
	#is_boosting = Input.is_action_pressed("boost") and energy_level > boost_energy_cost * delta
	#
	## Calculate thrust
	#if input_vector.length() > 0:
		#var thrust_multiplier = thrust_power
		#var energy_cost = movement_energy_cost
		#
		#if is_boosting:
			#thrust_multiplier *= boost_multiplier
			#energy_cost = boost_energy_cost
		#
		## Apply strafe reduction for lateral movement
		#if abs(input_vector.x) > 0 or abs(input_vector.y) > 0:
			#thrust_multiplier *= strafe_multiplier
		#
		#var thrust = transform.basis * input_vector.normalized() * thrust_multiplier * delta
		#velocity += thrust
		#
		## Consume energy
		#energy_level -= energy_cost * delta
		#energy_level = max(0, energy_level)
		#
		#if energy_level <= 0:
			#energy_depleted.emit()
			#is_boosting = false
	#
	## Rotation with mouse support
	#var rotation_input = Vector3()
	#
	#if Input.is_action_pressed("free_look"):
		## Mouse control when holding free look
		#rotation_input = get_mouse_rotation_input()
	#else:
		## Keyboard/gamepad control
		#rotation_input.x = Input.get_axis("pitch_down", "pitch_up")
		#rotation_input.y = Input.get_axis("yaw_left", "yaw_right")
		#rotation_input.z = Input.get_axis("roll_left", "roll_right")
	#
	## Apply rotation with smoothing
	#rotate_x(rotation_input.x * rotation_speed * delta)
	#rotate_y(rotation_input.y * rotation_speed * delta)
	#rotate_z(rotation_input.z * rotation_speed * delta)
	#
	## Velocity management
	#if velocity.length() > max_velocity:
		#if is_boosting:
			#velocity = velocity.normalized() * max_velocity * boost_multiplier
		#else:
			#velocity = velocity.normalized() * max_velocity
	#
	## Dynamic drag based on speed
	#var drag = 0.99 - (velocity.length() / max_velocity) * 0.05
	#velocity *= drag
	#
	## Move with collision
	#move_and_slide()
#
#func handle_meditation(delta):
	## In meditation mode, ship hovers and consciousness expands
	#velocity *= 0.95  # Gentle stop
	#
	## Expand consciousness faster
	#var expansion_rate = 50.0 * delta
	#update_perception_radius(current_perception_radius + expansion_rate)
	#
	## Regenerate energy faster
	#energy_level += energy_regen_rate * 3.0 * delta
	#energy_level = min(energy_level, max_energy)
	#
	## Exit meditation
	#if Input.is_action_just_pressed("meditate"):
		#meditation_mode = false
#
#func update_consciousness_frequency(delta):
	#var frequency_change = 0.0
	#
	## Manual tuning
	#if Input.is_action_pressed("tune_frequency_up"):
		#frequency_change += frequency_sensitivity
	#elif Input.is_action_pressed("tune_frequency_down"):
		#frequency_change -= frequency_sensitivity
	#
	## Environmental influences
	#for obj in resonant_objects:
		#if obj.has_method("get_frequency_influence"):
			#frequency_change += obj.get_frequency_influence(global_position)
	#
	## Apply change with smoothing
	#if abs(frequency_change) > 0:
		#consciousness_frequency += frequency_change * delta
		#consciousness_frequency = clamp(consciousness_frequency, 100.0, 1000.0)
		#consciousness_resonance_changed.emit(consciousness_frequency)
		#
		## Check for special frequencies
		#check_frequency_resonance()
#
#func check_frequency_resonance():
	## Universal harmony
	#if abs(consciousness_frequency - 432.0) < 1.0:
		#if not has_meta("resonance_432"):
			#set_meta("resonance_432", true)
			#achieve_resonance("universal_harmony")
	#else:
		#remove_meta("resonance_432")
	#
	## Love frequency
	#if abs(consciousness_frequency - 528.0) < 1.0:
		#if not has_meta("resonance_528"):
			#set_meta("resonance_528", true)
			#achieve_resonance("love_frequency")
	#else:
		#remove_meta("resonance_528")
	#
	## Cosmic consciousness
	#if abs(consciousness_frequency - 963.0) < 1.0:
		#if not has_meta("resonance_963"):
			#set_meta("resonance_963", true)
			#achieve_resonance("cosmic_consciousness")
	#else:
		#remove_meta("resonance_963")
#
#func achieve_resonance(resonance_type: String):
	## Visual feedback
	#create_resonance_pulse(resonance_type)
	#
	## Gameplay effects
	#match resonance_type:
		#"universal_harmony":
			#current_perception_radius *= 1.5
			#energy_regen_rate *= 2.0
		#"love_frequency":
			## Affects companion bonds
			#get_tree().call_group("companions", "increase_bond", 10)
		#"cosmic_consciousness":
			## Reveals hidden objects
			#get_tree().call_group("hidden_consciousness_objects", "reveal")
#
#func regenerate_systems(delta):
	## Energy regeneration
	#if energy_level < max_energy and not is_boosting:
		#energy_level += energy_regen_rate * delta
		#energy_level = min(energy_level, max_energy)
	#
	## Shield regeneration
	#if shields < max_shields:
		#shields += shield_regen_rate * delta
		#shields = min(shields, max_shields)
#
#func update_visuals(delta):
	## Update ship material based on frequency
	#if ship_mesh:
		#var material = ship_mesh.material_override
		#material.emission = get_frequency_color(consciousness_frequency)
		#material.emission_energy = 0.5 + (consciousness_frequency - 100) / 900 * 0.5
	#
	## Update engine particles
	#if engine_particles:
		#engine_particles.emitting = velocity.length() > 10.0
		#engine_particles.amount_ratio = clamp(velocity.length() / max_velocity, 0.1, 1.0)
		#
		#if is_boosting:
			#engine_particles.process_material.color = Color(1.0, 0.5, 0.0)
		#else:
			#engine_particles.process_material.color = Color(0.5, 0.7, 1.0)
	#
	## Update consciousness aura
	#if consciousness_aura:
		#var aura_scale = 1.0 + sin(Time.get_ticks_msec() / 1000.0) * 0.1
		#consciousness_aura.scale = Vector3.ONE * aura_scale
		#consciousness_aura.material_override.rim_tint = get_frequency_color(consciousness_frequency)
	#
	## Rotate frequency visualizer
	#if frequency_visualizer:
		#frequency_visualizer.rotate_y(delta * (consciousness_frequency / 432.0))
		#
		## Update ring colors
		#for i in range(frequency_visualizer.get_child_count()):
			#var ring = frequency_visualizer.get_child(i)
			#if ring.material_override:
				#ring.material_override.emission = get_frequency_color(consciousness_frequency)
#
#func update_perception_radius(new_radius: float):
	#current_perception_radius = new_radius
	#if perception_sphere:
		#var shape = perception_sphere.get_child(0).shape as SphereShape3D
		#shape.radius = new_radius
		#perception_expanded.emit(new_radius)
#
#func get_frequency_color(frequency: float) -> Color:
	## Map frequency to color spectrum
	#var normalized = (frequency - 100.0) / 900.0  # 0-1 range
	#
	## Special frequency colors
	#if abs(frequency - 432.0) < 10:
		#return Color(0.5, 1.0, 0.5)  # Green for universal harmony
	#elif abs(frequency - 528.0) < 10:
		#return Color(1.0, 0.5, 1.0)  # Magenta for love
	#elif abs(frequency - 963.0) < 10:
		#return Color(0.8, 0.8, 1.0)  # Light blue for cosmic
	#
	## Gradient from red (low) to violet (high)
	#if normalized < 0.5:
		#return Color(1.0, normalized * 2, 0)  # Red to yellow
	#else:
		#return Color(2 - normalized * 2, 0, (normalized - 0.5) * 2)  # Yellow to blue
#
#func _on_perception_area_entered(area: Area3D):
	#if area.has_method("get_consciousness_signature"):
		#var signature = area.get_consciousness_signature()
		#process_consciousness_detection(area, signature)
		#perceived_objects.append(area)
		#
		## Check for resonance
		#if area.has_method("get_resonant_frequency"):
			#var obj_frequency = area.get_resonant_frequency()
			#if abs(obj_frequency - consciousness_frequency) < 50:
				#resonant_objects.append(area)
#
#func _on_perception_area_exited(area: Area3D):
	#perceived_objects.erase(area)
	#resonant_objects.erase(area)
#
#func _on_perception_body_entered(body: Node3D):
	#if body.has_method("on_perceived_by_player"):
		#body.on_perceived_by_player(self)
	#consciousness_object_detected.emit(body)
#
#func _on_perception_body_exited(body: Node3D):
	#if body.has_method("on_perception_lost"):
		#body.on_perception_lost(self)
#
#func process_consciousness_detection(object: Node3D, signature: Dictionary):
	## Process based on signature type
	#var sig_type = signature.get("type", "unknown")
	#
	#match sig_type:
		#"akashic_node":
			## Player discovered an Akashic record location
			#print("Akashic knowledge detected at: ", object.global_position)
		#"consciousness_ore":
			## Consciousness-enhancing material nearby
			#print("Consciousness ore resonating at frequency: ", signature.get("frequency", 0))
		#"ancient_artifact":
			## Ancient consciousness technology
			#print("Ancient artifact detected - required consciousness level: ", signature.get("required_level", 0))
#
#func create_resonance_pulse(resonance_type: String):
	## Visual effect for achieving resonance
	#var pulse = preload("res://effects/resonance_pulse.tscn").instantiate()
	#pulse.resonance_type = resonance_type
	#pulse.position = global_position
	#get_parent().add_child(pulse)
#
#func get_mouse_rotation_input() -> Vector3:
	## Convert mouse movement to rotation input
	## This would need proper implementation with Input.get_last_mouse_velocity()
	#return Vector3.ZERO
#
#func take_damage(amount: float, damage_type: String = "normal"):
	## Shields absorb first
	#if shields > 0:
		#var shield_damage = min(amount, shields)
		#shields -= shield_damage
		#amount -= shield_damage
	#
	## Then hull/energy
	#if amount > 0:
		#energy_level -= amount * 0.5  # Damage disrupts energy
		#
		## Create damage effects
		#create_damage_effect(damage_type)
#
#func create_damage_effect(damage_type: String):
	## Visual feedback for damage
	#pass
#
## Input handling
#func _input(event):
	#if event.is_action_pressed("meditate"):
		#meditation_mode = !meditation_mode
		#
	## Quick frequency presets
	#if event.is_action_pressed("frequency_preset_1"):
		#consciousness_frequency = 432.0  # Universal harmony
	#elif event.is_action_pressed("frequency_preset_2"):
		#consciousness_frequency = 528.0  # Love
	#elif event.is_action_pressed("frequency_preset_3"):
		#consciousness_frequency = 963.0  # Cosmic consciousness
#
#func connect_signals():
	## Connect to game systems when added to tree
	#pass
#
## Save/Load support
#func get_save_data() -> Dictionary:
	#return {
		#"position": global_position,
		#"rotation": rotation,
		#"velocity": velocity,
		#"energy": energy_level,
		#"shields": shields,
		#"frequency": consciousness_frequency,
		#"perception_radius": current_perception_radius
	#}
#
#func load_save_data(data: Dictionary):
	#global_position = data.get("position", Vector3.ZERO)
	#rotation = data.get("rotation", Vector3.ZERO)
	#velocity = data.get("velocity", Vector3.ZERO)
	#energy_level = data.get("energy", max_energy)
	#shields = data.get("shields", max_shields)
	#consciousness_frequency = data.get("frequency", 432.0)
	#update_perception_radius(data.get("perception_radius", base_perception_radius))
#Key Design Elements
#
#Consciousness as Gameplay: Your frequency affects everything - perception range, energy regeneration, companion bonds, hidden object visibility
#Energy Management: Movement costs energy, creating strategic decisions about when to boost or coast
#Perception Sphere: Physical representation of consciousness expansion - as you grow, you literally perceive more of the universe
#Meditation Mode: Alternative "gameplay" where you stop moving to expand consciousness faster
#Visual Feedback: Ship appearance changes with frequency, creating immediate visual connection between consciousness state and your vessel
#
#This player controller bridges the gap between traditional space game mechanics and consciousness-based gameplay, making abstract concepts tangible and interactive.


signal consciousness_resonance_changed(frequency: float)

@export var thrust_power: float = 1000.0
@export var rotation_speed: float = 2.0
@export var max_velocity: float = 500.0

# Consciousness integration
var consciousness_frequency: float = 432.0
var perception_sphere: Area3D

# Ship systems
var energy_level: float = 100.0
var max_energy: float = 100.0
var shields: float = 100.0

func _ready():
	setup_perception_sphere()
	
func setup_perception_sphere():
	perception_sphere = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 100.0  # Will be updated by consciousness system
	collision_shape.shape = sphere_shape
	perception_sphere.add_child(collision_shape)
	add_child(perception_sphere)
	
	perception_sphere.area_entered.connect(_on_perception_area_entered)
	
func _physics_process(delta):
	handle_movement(delta)
	update_consciousness_frequency(delta)
	regenerate_energy(delta)
	
func handle_movement(delta):
	# Get input
	var input_vector = Vector3()
	input_vector.x = Input.get_axis("strafe_left", "strafe_right")
	input_vector.y = Input.get_axis("thrust_down", "thrust_up")
	input_vector.z = Input.get_axis("thrust_backward", "thrust_forward")
	
	# Apply thrust
	if input_vector.length() > 0:
		var thrust = transform.basis * input_vector.normalized() * thrust_power * delta
		velocity += thrust
		
		# Consume energy
		energy_level -= delta * 5.0
		
	# Apply rotation
	var rotation_input = Vector3()
	rotation_input.x = Input.get_axis("pitch_down", "pitch_up")
	rotation_input.y = Input.get_axis("yaw_left", "yaw_right")
	rotation_input.z = Input.get_axis("roll_left", "roll_right")
	
	rotate_x(rotation_input.x * rotation_speed * delta)
	rotate_y(rotation_input.y * rotation_speed * delta)
	rotate_z(rotation_input.z * rotation_speed * delta)
	
	# Limit velocity
	if velocity.length() > max_velocity:
		velocity = velocity.normalized() * max_velocity
		
	# Apply drag
	velocity *= 0.99
	
	move_and_slide()
	
func update_consciousness_frequency(delta):
	# Frequency shifts based on nearby consciousness objects
	if Input.is_action_pressed("tune_frequency_up"):
		consciousness_frequency += delta * 10
	elif Input.is_action_pressed("tune_frequency_down"):
		consciousness_frequency -= delta * 10
		
	consciousness_frequency = clamp(consciousness_frequency, 100.0, 1000.0)
	consciousness_resonance_changed.emit(consciousness_frequency)
	
func regenerate_energy(delta):
	if energy_level < max_energy:
		energy_level += delta * 2.0  # Passive regeneration
		energy_level = min(energy_level, max_energy)
		
func _on_perception_area_entered(area: Area3D):
	# Handle consciousness perception events
	if area.has_method("get_consciousness_signature"):
		var signature = area.get_consciousness_signature()
		# Process consciousness interaction
		
func update_perception_radius(radius: float):
	if perception_sphere:
		var shape = perception_sphere.get_child(0).shape as SphereShape3D
		shape.radius = radius
