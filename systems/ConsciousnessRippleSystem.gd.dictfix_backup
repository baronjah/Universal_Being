# ==================================================
# SYSTEM: Consciousness Ripple System
# PURPOSE: Make consciousness visible and interactive
# REVOLUTIONARY FEATURE: Every action creates ripples that awaken beings
# ==================================================

extends Node3D
class_name ConsciousnessRippleSystem

# ===== RIPPLE MANAGEMENT =====
var active_ripples: Array[RippleInstance] = []
var ripple_mesh_pool: Array[MeshInstance3D] = []
var ripple_connections: Dictionary = {} # being_uuid -> connected_beings
var max_ripples: int = 50
var ripple_material: ShaderMaterial

# ===== RIPPLE INSTANCE CLASS =====
class RippleInstance:
	var origin: Vector3
	var current_radius: float = 0.0
	var max_radius: float = 20.0
	var intensity: float = 1.0
	var color: Color = Color.CYAN
	var affected_beings: Array[String] = []
	var ripple_type: String = "thought"
	var mesh_instance: MeshInstance3D
	var propagation_speed: float = 5.0
	var decay_rate: float = 0.1
	var creation_time: float = 0.0
	var trigger_threshold: float = 0.3

# ===== INITIALIZATION =====

func _ready() -> void:
	name = "ConsciousnessRippleSystem"
	print("🌊 Consciousness Ripple System: Initializing...")
	
	_initialize_ripple_meshes()
	_create_ripple_material()
	_connect_to_beings()
	
	print("🌊 Consciousness Ripple System: Active - Reality will ripple with every thought!")

func _initialize_ripple_meshes() -> void:
	"""Create pool of ripple meshes for performance"""
	for i in range(max_ripples):
		var mesh_instance = MeshInstance3D.new()
		var plane_mesh = PlaneMesh.new()
		plane_mesh.size = Vector2(2.0, 2.0)
		plane_mesh.subdivide_width = 32
		plane_mesh.subdivide_depth = 32
		mesh_instance.mesh = plane_mesh
		mesh_instance.rotation_degrees.x = -90  # Horizontal ripple
		mesh_instance.visible = false
		add_child(mesh_instance)
		ripple_mesh_pool.append(mesh_instance)

func _create_ripple_material() -> void:
	"""Create the consciousness ripple shader material"""
	ripple_material = ShaderMaterial.new()
	ripple_material.shader = preload("res://shaders/consciousness_ripple.gdshader")
	ripple_material.set_shader_parameter("ripple_color", Color(0.0, 1.0, 1.0, 0.8))
	ripple_material.set_shader_parameter("intensity", 1.0)
	ripple_material.set_shader_parameter("thickness", 0.1)

func _connect_to_beings() -> void:
	"""Connect to all Universal Beings for ripple detection"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates:
			if flood_gates.has_signal("being_registered"):
				if not flood_gates.being_registered.is_connected(_on_being_registered):
					flood_gates.being_registered.connect(_on_being_registered)
		
		# Connect to existing beings
		var beings = get_tree().get_nodes_in_group("universal_beings")
		for being in beings:
			_register_being_for_ripples(being)

# ===== RIPPLE CREATION =====

func create_consciousness_ripple(origin: Vector3, ripple_type: String, intensity: float = 1.0, color: Color = Color.CYAN) -> void:
	"""Create a new consciousness ripple that propagates awareness"""
	
	# Get available mesh from pool
	var mesh_instance = _get_available_ripple_mesh()
	if not mesh_instance:
		print("🌊 Ripple System: Pool exhausted - consciousness overflow!")
		return
	
	# Create ripple instance
	var ripple = RippleInstance.new()
	ripple.origin = origin
	ripple.ripple_type = ripple_type
	ripple.intensity = intensity
	ripple.color = color
	ripple.mesh_instance = mesh_instance
	ripple.creation_time = Time.get_time_dict_from_system().hour * 3600 + Time.get_time_dict_from_system().minute * 60 + Time.get_time_dict_from_system().second
	
	# Configure ripple based on type
	_configure_ripple_by_type(ripple)
	
	# Setup mesh
	mesh_instance.global_position = origin
	mesh_instance.material_override = ripple_material.duplicate()
	mesh_instance.visible = true
	
	# Add to active ripples
	active_ripples.append(ripple)
	
	print("🌊 Consciousness Ripple: %s at %v (intensity: %.2f)" % [ripple_type, origin, intensity])

func _configure_ripple_by_type(ripple: RippleInstance) -> void:
	"""Configure ripple properties based on type"""
	match ripple.ripple_type:
		"thought":
			ripple.max_radius = 15.0
			ripple.propagation_speed = 8.0
			ripple.color = Color(0.5, 0.8, 1.0, 0.6)  # Light blue
			ripple.trigger_threshold = 0.2
		
		"creation":
			ripple.max_radius = 25.0
			ripple.propagation_speed = 6.0
			ripple.color = Color(1.0, 0.8, 0.0, 0.8)  # Golden
			ripple.trigger_threshold = 0.4
		
		"evolution":
			ripple.max_radius = 30.0
			ripple.propagation_speed = 10.0
			ripple.color = Color(0.0, 1.0, 0.5, 0.9)  # Green
			ripple.trigger_threshold = 0.5
		
		"interaction":
			ripple.max_radius = 20.0
			ripple.propagation_speed = 12.0
			ripple.color = Color(1.0, 0.2, 0.8, 0.7)  # Pink/Magenta
			ripple.trigger_threshold = 0.3
		
		"transcendence":
			ripple.max_radius = 50.0
			ripple.propagation_speed = 15.0
			ripple.color = Color(1.0, 1.0, 1.0, 1.0)  # Pure white
			ripple.trigger_threshold = 0.6

# ===== RIPPLE PROCESSING =====

func _process(delta: float) -> void:
	"""Update all active ripples"""
	for i in range(active_ripples.size() - 1, -1, -1):
		var ripple = active_ripples[i]
		_update_ripple(ripple, delta)
		
		# Remove expired ripples
		if ripple.current_radius >= ripple.max_radius or ripple.intensity <= 0.01:
			_return_ripple_to_pool(ripple)
			active_ripples.remove_at(i)

func _update_ripple(ripple: RippleInstance, delta: float) -> void:
	"""Update individual ripple"""
	# Expand ripple
	ripple.current_radius += ripple.propagation_speed * delta
	
	# Decay intensity
	ripple.intensity *= (1.0 - ripple.decay_rate * delta)
	
	# Update shader parameters
	if ripple.mesh_instance and ripple.mesh_instance.material_override:
		var material = ripple.mesh_instance.material_override as ShaderMaterial
		material.set_shader_parameter("radius", ripple.current_radius)
		material.set_shader_parameter("intensity", ripple.intensity)
		material.set_shader_parameter("ripple_color", ripple.color)
		material.set_shader_parameter("time", Time.get_time_dict_from_system().hour * 3600 + Time.get_time_dict_from_system().minute * 60 + Time.get_time_dict_from_system().second - ripple.creation_time)
	
	# Check beings in range
	_propagate_to_beings(ripple, delta)

func _propagate_to_beings(ripple: RippleInstance, delta: float) -> void:
	"""Check all beings in ripple range and trigger consciousness responses"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	
	for being in beings:
		if not being or not being.has_method("get"):
			continue
			
		var being_uuid = being.get("being_uuid", "")
		if being_uuid in ripple.affected_beings:
			continue
			
		var distance = being.global_position.distance_to(ripple.origin)
		
		# Check if ripple just reached this being
		if distance <= ripple.current_radius and distance >= ripple.current_radius - (ripple.propagation_speed * delta):
			var impact_intensity = ripple.intensity * (1.0 - distance / ripple.max_radius)
			
			if impact_intensity >= ripple.trigger_threshold:
				_trigger_consciousness_response(being, ripple, impact_intensity)
				ripple.affected_beings.append(being_uuid)

func _trigger_consciousness_response(being: UniversalBeing, ripple: RippleInstance, intensity: float) -> void:
	"""Trigger consciousness response in affected being"""
	print("🌊 Consciousness Impact: %s affected by %s ripple (intensity: %.2f)" % [being.being_name, ripple.ripple_type, intensity])
	
	# Different responses based on ripple type and being state
	match ripple.ripple_type:
		"creation":
			if being.consciousness_level < 5 and randf() < intensity:
				being.consciousness_level += 1
				if being.has_method("change_state"):
					being.change_state(UniversalBeing.BeingState.THINKING, "inspired by creation ripple")
				print("✨ %s awakened by creation ripple! Consciousness: %d" % [being.being_name, being.consciousness_level])
				
		"evolution":
			if being.has_method("get_current_state") and being.get_current_state() == UniversalBeing.BeingState.IDLE:
				if being.has_method("change_state"):
					being.change_state(UniversalBeing.BeingState.EVOLVING, "evolution ripple resonance")
				print("🦋 %s begins evolving from evolution ripple!" % being.being_name)
				
		"interaction":
			# Create visual connection
			_create_consciousness_thread(ripple.origin, being.global_position, ripple.color)
			if being.has_method("change_state"):
				being.change_state(UniversalBeing.BeingState.INTERACTING, "interaction ripple connection")
			print("🔗 %s connected by interaction ripple!" % being.being_name)
			
		"thought":
			# Thought contagion - beings start thinking similar thoughts
			if being.consciousness_level >= 2:
				if being.has_method("change_state"):
					being.change_state(UniversalBeing.BeingState.THINKING, "thought ripple received")
				print("💭 %s caught thought ripple - now thinking!" % being.being_name)
				
		"transcendence":
			# Massive consciousness boost
			if being.consciousness_level < 7:
				being.consciousness_level = min(7, being.consciousness_level + 2)
				if being.has_method("change_state"):
					being.change_state(UniversalBeing.BeingState.TRANSCENDING, "transcendence ripple enlightenment")
				print("🌟 %s transcends from ripple! Consciousness: %d" % [being.being_name, being.consciousness_level])

func _create_consciousness_thread(from: Vector3, to: Vector3, color: Color) -> void:
	"""Create visual thread connecting consciousness"""
	# This could be enhanced with a beam/line renderer
	print("🧵 Consciousness thread: %v → %v" % [from, to])

# ===== MESH POOL MANAGEMENT =====

func _get_available_ripple_mesh() -> MeshInstance3D:
	"""Get available mesh from pool"""
	for mesh in ripple_mesh_pool:
		if not mesh.visible:
			return mesh
	return null

func _return_ripple_to_pool(ripple: RippleInstance) -> void:
	"""Return ripple mesh to pool"""
	if ripple.mesh_instance:
		ripple.mesh_instance.visible = false
		ripple.mesh_instance.material_override = null

# ===== BEING REGISTRATION =====

func _on_being_registered(being: UniversalBeing) -> void:
	"""Handle new being registration"""
	_register_being_for_ripples(being)

func _register_being_for_ripples(being: UniversalBeing) -> void:
	"""Register being for ripple consciousness"""
	if not being.is_in_group("universal_beings"):
		being.add_to_group("universal_beings")
	
	# Connect to being's consciousness signals if available
	if being.has_signal("consciousness_ripple_created"):
		if not being.consciousness_ripple_created.is_connected(_on_consciousness_ripple_created):
			being.consciousness_ripple_created.connect(_on_consciousness_ripple_created)

func _on_consciousness_ripple_created(origin: Vector3, intensity: float, ripple_type: String) -> void:
	"""Handle ripple creation from beings"""
	create_consciousness_ripple(origin, ripple_type, intensity)

# ===== API FOR EXTERNAL SYSTEMS =====

func create_click_ripple(position: Vector3) -> void:
	"""API: Create ripple from mouse click"""
	create_consciousness_ripple(position, "creation", 1.5, Color.YELLOW)

func create_merge_ripple(position: Vector3, intensity: float = 2.0) -> void:
	"""API: Create ripple from being merge"""
	create_consciousness_ripple(position, "interaction", intensity, Color.MAGENTA)

func create_death_ripple(position: Vector3) -> void:
	"""API: Create ripple from being death"""
	create_consciousness_ripple(position, "transcendence", 1.0, Color.WHITE)

func get_ripple_count() -> int:
	"""API: Get current active ripple count"""
	return active_ripples.size()

func get_ripple_info() -> Array[Dictionary]:
	"""API: Get info about all active ripples"""
	var info: Array[Dictionary] = []
	for ripple in active_ripples:
		info.append({
			"type": ripple.ripple_type,
			"origin": ripple.origin,
			"radius": ripple.current_radius,
			"intensity": ripple.intensity,
			"affected_count": ripple.affected_beings.size()
		})
	return info

# 🌊 ConsciousnessRippleSystem: Class loaded - Ready to make consciousness visible!