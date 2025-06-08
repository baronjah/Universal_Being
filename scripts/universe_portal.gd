# ==================================================
# UNIVERSAL BEING: Universe Portal
# TYPE: UniverseCreation
# PURPOSE: Creates and manages portals between universes
# COMPONENTS: universe_creation.ub.zip
# SCENES: universe_portal.tscn
# ==================================================

extends UniversalBeing
class_name UniversePortalUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var portal_name: String = "Cosmic Gateway"
@export var target_universe: String = ""
@export var stability: float = 100.0
@export var max_travelers: int = 10
@export var current_travelers: int = 0
@export var portal_radius: float = 1.0
@export var portal_color: Color = Color(0.5, 0.8, 1.0, 0.8)

# Portal state
var is_active: bool = false
var is_stable: bool = true
var portal_energy: float = 100.0
var portal_pulse: float = 0.0
var portal_particles: GPUParticles3D
var portal_light: OmniLight3D
var portal_collision: CollisionShape3D

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	# Set Universal Being identity
	being_type = "universe_portal"
	being_name = portal_name
	consciousness_level = 2  # AI can monitor but not modify portals
	
	# Initialize portal state
	is_active = false
	is_stable = true
	portal_energy = 100.0
	portal_pulse = 0.0
	
	print("🌟 %s: Portal Init Complete" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Load the portal scene
	load_scene("res://components/universe_creation.ub.zip/universe_portal.tscn")
	
	# Get references to portal nodes
	portal_particles = get_scene_node("PortalVisuals/Particles")
	portal_light = get_scene_node("PortalVisuals/Light")
	portal_collision = get_scene_node("PortalCollision")
	
	# Initialize portal visuals
	update_portal_visuals()
	
	# Register with FloodGate if system is ready
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates:
			flood_gates.register_portal(self)
	
	print("🌟 %s: Portal Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update portal state
	update_portal_state(delta)
	
	# Update visuals
	update_portal_visuals()
	
	# Check for travelers
	check_travelers()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle portal interaction
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var camera = get_viewport().get_camera_3d()
			if camera:
				var from = camera.project_ray_origin(event.position)
				var to = from + camera.project_ray_normal(event.position) * 1000
				var space_state = get_tree().get_root().get_world_3d().direct_space_state
				var query = PhysicsRayQueryParameters3D.create(from, to)
				var result = space_state.intersect_ray(query)
				
				if result and result.collider == portal_collision:
					interact_with_portal()

func pentagon_sewers() -> void:
	# Cleanup portal state
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates:
			flood_gates.unregister_portal(self)
	
	# Cleanup scene
	if scene_is_loaded:
		unload_scene()
	
	super.pentagon_sewers()

# ===== PORTAL-SPECIFIC METHODS =====

func update_portal_state(delta: float) -> void:
	# Update portal pulse
	portal_pulse += delta * 2.0
	if portal_pulse > TAU:
		portal_pulse -= TAU
	
	# Update stability
	if current_travelers > max_travelers:
		stability = max(0.0, stability - delta * 10.0)
	else:
		stability = min(100.0, stability + delta * 5.0)
	
	# Update active state
	is_active = stability > 20.0 and portal_energy > 0.0
	is_stable = stability > 50.0
	
	# Update energy
	if is_active:
		portal_energy = max(0.0, portal_energy - delta * 2.0)
	else:
		portal_energy = min(100.0, portal_energy + delta * 5.0)

func update_portal_visuals() -> void:
	if not scene_is_loaded:
		return
	
	# Update particle properties
	if portal_particles:
		var material = portal_particles.process_material as ParticleProcessMaterial
		if material:
			material.color = portal_color
			material.scale_min = 0.1 + sin(portal_pulse) * 0.05
			material.scale_max = 0.2 + sin(portal_pulse) * 0.1
	
	# Update light
	if portal_light:
		portal_light.light_energy = 1.0 + sin(portal_pulse) * 0.5
		portal_light.light_color = portal_color
	
	# Update UI
	set_scene_property("PortalUI/StabilityLabel", "text", "Stability: %.1f%%" % stability)
	set_scene_property("PortalUI/TravelersLabel", "text", "Travelers: %d/%d" % [current_travelers, max_travelers])
	set_scene_property("PortalUI/EnergyBar", "value", portal_energy)
	set_scene_property("PortalUI/StabilityBar", "value", stability)
	
	# Update portal state
	set_scene_property("PortalUI/StatusLabel", "text", "Status: %s" % ("Active" if is_active else "Inactive"))
	set_scene_property("PortalUI/StatusLabel", "modulate", Color.GREEN if is_active else Color.RED)

func check_travelers() -> void:
	if not is_active:
		return
	
	# Check for travelers in portal area
	var space_state = get_tree().get_root().get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = portal_collision.shape
	query.transform = portal_collision.global_transform
	query.collision_mask = 1  # Adjust based on your collision layers
	
	var results = space_state.intersect_shape(query)
	current_travelers = results.size()
	
	# Handle travelers
	for result in results:
		var traveler = result.collider
		if traveler.has_method("enter_portal"):
			traveler.enter_portal(self)

func interact_with_portal() -> void:
	if not is_active:
		push_error("Portal %s is not active" % being_name)
		return
	
	if current_travelers >= max_travelers:
		push_error("Portal %s is at maximum capacity" % being_name)
		return
	
	# Log portal interaction
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic:
			akashic.log_portal_interaction(being_name, target_universe, stability)

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	pass
	var base_interface = super.ai_interface()
	base_interface.portal_commands = ["activate", "deactivate", "set_target"]
	base_interface.portal_properties = {
		"stability": stability,
		"energy": portal_energy,
		"travelers": current_travelers,
		"target": target_universe
	}
	return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"activate":
			is_active = true
			return true
		"deactivate":
			is_active = false
			return true
		"set_target":
			if args.size() > 0:
				target_universe = args[0]
				return true
			return false
		_:
			return super.ai_invoke_method(method_name, args) 
