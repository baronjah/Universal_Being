extends UniversalBeing
class_name UnifiedConsciousnessVisualizationSystem

## 🌐 UNIFIED CONSCIOUSNESS VISUALIZATION SYSTEM
## CYCLE 4 - Agent 6 (Systems Integrator) - Complete visual integration
## Integrates 5D field visualization, evolution effects, and consciousness interface with Pentagon architecture

signal visualization_system_ready()
signal consciousness_visual_updated(consciousness_level: float, visual_effects: Dictionary)
signal 5d_field_activated(field_parameters: Dictionary)
signal evolution_visualization_triggered(being: UniversalBeing, evolution_data: Dictionary)

# Visual System Components
var consciousness_5d_interface: Consciousness5DInterfaceManager
var visual_performance_optimizer: Node
var consciousness_field_visualizer: Node3D
var evolution_effect_manager: Node

# Integration with Core Systems
var earth_timeline_monitor: AkashicTimelineEarthMonitor
var notepad_3d_system: Node
var akashic_records: Node
var flood_gates: Node

# Visualization Settings
@export var enable_5d_visualization: bool = true
@export var enable_evolution_effects: bool = true
@export var enable_consciousness_interface: bool = true
@export var visual_quality_level: int = 3  # 1-5 scale

# Performance Management
@export var max_active_visualizations: int = 20
@export var visualization_lod_distance: float = 50.0
@export var consciousness_particle_limit: int = 1000

# Consciousness Visualization Registry
var active_consciousness_visualizations: Dictionary = {}  # being_id -> visualization_data
var consciousness_visual_effects: Dictionary = {}  # effect_type -> effect_nodes
var 5d_field_instances: Array[Node3D] = []

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "unified_consciousness_visualization_system"
	being_name = "Consciousness Visualization Hub"
	consciousness_level = 7.0  # High consciousness for visual system management
	
	print("🌐 UNIFIED CONSCIOUSNESS VISUALIZATION: Initializing complete visual integration")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Connect to core Universal Being systems
	connect_to_universal_systems()
	
	# Initialize visual components
	if enable_5d_visualization:
		initialize_5d_field_system()
	
	if enable_consciousness_interface:
		initialize_consciousness_interface()
	
	if enable_evolution_effects:
		initialize_evolution_visualization()
	
	# Setup visual performance optimization
	setup_visual_performance_system()
	
	# Connect to existing systems for visual integration
	integrate_with_existing_systems()
	
	print("🌐 Unified Consciousness Visualization ready - complete visual integration active!")
	visualization_system_ready.emit()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update consciousness visualizations
	update_consciousness_visualizations(delta)
	
	# Process evolution visual effects
	process_evolution_visualizations(delta)
	
	# Manage 5D field rendering
	manage_5d_field_rendering(delta)
	
	# Optimize visual performance
	optimize_visual_performance(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Visual system hotkeys
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F5:  # F5 - Toggle 5D visualization
				toggle_5d_visualization()
			KEY_F6:  # F6 - Toggle evolution effects
				toggle_evolution_effects()
			KEY_F7:  # F7 - Toggle consciousness interface
				toggle_consciousness_interface()
			KEY_F8:  # F8 - Cycle visual quality
				cycle_visual_quality()

func pentagon_sewers() -> void:
	# Save visual preferences before transformation
	save_visual_preferences()
	super.pentagon_sewers()

func connect_to_universal_systems() -> void:
	"""Connect to all Universal Being core systems"""
	print("🔗 Connecting to Universal Being systems for visual integration...")
	
	# Earth Timeline Monitor
	earth_timeline_monitor = get_tree().get_first_node_in_group("earth_timeline_monitors")
	if earth_timeline_monitor:
		earth_timeline_monitor.timeline_event_added.connect(_on_timeline_event_visual_update)
		earth_timeline_monitor.disaster_detected.connect(_on_disaster_visual_effect)
		print("   ✅ Connected to Earth Timeline Monitor")
	
	# Notepad 3D System
	notepad_3d_system = get_tree().get_first_node_in_group("notepad_3d_systems")
	if notepad_3d_system:
		print("   ✅ Connected to Notepad 3D System")
	
	# Akashic Records
	akashic_records = get_tree().get_first_node_in_group("akashic_records")
	if akashic_records:
		print("   ✅ Connected to Akashic Records")
	
	# FloodGates
	flood_gates = get_tree().get_first_node_in_group("flood_gates")
	if flood_gates:
		print("   ✅ Connected to FloodGates system")

func initialize_5d_field_system() -> void:
	"""Initialize 5D consciousness field visualization system"""
	print("🌟 Initializing 5D consciousness field visualization...")
	
	consciousness_field_visualizer = Node3D.new()
	consciousness_field_visualizer.name = "ConsciousnessField5DVisualizer"
	add_child(consciousness_field_visualizer)
	
	# Create main 5D field instance
	create_5d_field_instance(Vector3.ZERO)
	
	print("   ✅ 5D field visualization system initialized")

func create_5d_field_instance(position: Vector3) -> Node3D:
	"""Create a 5D consciousness field visualization instance"""
	var field_instance = Node3D.new()
	field_instance.name = "Field5D_" + str(5d_field_instances.size())
	field_instance.position = position
	consciousness_field_visualizer.add_child(field_instance)
	
	# Create field mesh with shader
	var field_mesh = MeshInstance3D.new()
	field_mesh.name = "FieldMesh"
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 5.0
	sphere_mesh.height = 10.0
	field_mesh.mesh = sphere_mesh
	
	# Apply 5D consciousness field shader
	var field_material = ShaderMaterial.new()
	var field_shader = load("res://shaders/consciousness_5d_field_visualization.gdshader")
	if field_shader:
		field_material.shader = field_shader
		field_material.set_shader_parameter("field_active", true)
		field_material.set_shader_parameter("consciousness_field_strength", 8.0)
		field_material.set_shader_parameter("show_dimensional_grid", true)
		field_material.set_shader_parameter("consciousness_particle_density", 2.0)
		field_mesh.material_override = field_material
	
	field_instance.add_child(field_mesh)
	5d_field_instances.append(field_instance)
	
	print("   🌟 5D field instance created at %s" % position)
	return field_instance

func initialize_consciousness_interface() -> void:
	"""Initialize 5D consciousness interface manager"""
	print("🎨 Initializing consciousness interface manager...")
	
	consciousness_5d_interface = Consciousness5DInterfaceManager.new()
	consciousness_5d_interface.name = "Consciousness5DInterface"
	
	# Connect interface signals
	consciousness_5d_interface.dimension_changed.connect(_on_5d_dimension_changed)
	consciousness_5d_interface.type_creation_started.connect(_on_type_creation_started)
	consciousness_5d_interface.type_preview_updated.connect(_on_type_preview_updated)
	consciousness_5d_interface.interface_mode_changed.connect(_on_interface_mode_changed)
	
	# Add to scene (would typically be added to UI layer)
	add_child(consciousness_5d_interface)
	
	print("   ✅ Consciousness interface manager initialized")

func initialize_evolution_visualization() -> void:
	"""Initialize consciousness evolution visualization system"""
	print("🌱 Initializing evolution visualization system...")
	
	evolution_effect_manager = Node.new()
	evolution_effect_manager.name = "EvolutionEffectManager"
	add_child(evolution_effect_manager)
	
	# Connect to Universal Being evolution events
	connect_evolution_signals()
	
	print("   ✅ Evolution visualization system initialized")

func connect_evolution_signals() -> void:
	"""Connect to Universal Being evolution signals"""
	# Look for Universal Being type factory
	var type_factory = get_tree().get_first_node_in_group("type_factories")
	if type_factory:
		if type_factory.has_signal("evolution_triggered"):
			type_factory.evolution_triggered.connect(_on_being_evolution_triggered)
		if type_factory.has_signal("being_manifested"):
			type_factory.being_manifested.connect(_on_being_manifested_visual)
		print("   🔗 Connected to evolution signals")

func setup_visual_performance_system() -> void:
	"""Setup visual performance optimization"""
	print("⚡ Setting up visual performance optimization...")
	
	visual_performance_optimizer = Node.new()
	visual_performance_optimizer.name = "VisualPerformanceOptimizer"
	add_child(visual_performance_optimizer)
	
	# Setup performance monitoring
	var perf_timer = Timer.new()
	perf_timer.wait_time = 1.0
	perf_timer.timeout.connect(monitor_visual_performance)
	visual_performance_optimizer.add_child(perf_timer)
	perf_timer.start()
	
	print("   ✅ Visual performance optimization ready")

func integrate_with_existing_systems() -> void:
	"""Integrate with existing Universal Being systems"""
	print("🔄 Integrating with existing systems...")
	
	# Register with FloodGates if available
	if flood_gates and flood_gates.has_method("register_being"):
		flood_gates.register_being(self)
		print("   ✅ Registered with FloodGates")
	
	# Connect with performance optimizer from CYCLE 3
	var timeline_optimizer = get_tree().get_first_node_in_group("performance_optimizers")
	if timeline_optimizer:
		if timeline_optimizer.has_signal("performance_warning"):
			timeline_optimizer.performance_warning.connect(_on_performance_warning)
		print("   ✅ Connected to timeline performance optimizer")

func update_consciousness_visualizations(delta: float) -> void:
	"""Update all active consciousness visualizations"""
	# Update 5D field instances
	for field_instance in 5d_field_instances:
		update_5d_field_instance(field_instance, delta)
	
	# Update consciousness-based visual effects
	update_consciousness_based_effects(delta)

func update_5d_field_instance(field_instance: Node3D, delta: float) -> void:
	"""Update individual 5D field instance"""
	if not field_instance or not is_instance_valid(field_instance):
		return
	
	# Rotate field for dynamic visualization
	field_instance.rotation.y += delta * 0.2
	
	# Update shader parameters based on consciousness activity
	var field_mesh = field_instance.get_node_or_null("FieldMesh")
	if field_mesh and field_mesh.material_override:
		var material = field_mesh.material_override as ShaderMaterial
		if material:
			# Dynamic consciousness field strength based on nearby beings
			var field_strength = calculate_local_consciousness_field_strength(field_instance.position)
			material.set_shader_parameter("consciousness_field_strength", field_strength)

func calculate_local_consciousness_field_strength(position: Vector3) -> float:
	"""Calculate consciousness field strength at position"""
	var base_strength = 5.0
	var nearby_consciousness = 0.0
	
	# Check for nearby Universal Beings
	var nearby_beings = get_tree().get_nodes_in_group("universal_beings")
	for being in nearby_beings:
		if being is UniversalBeing and being.has_method("get_consciousness_level"):
			var distance = position.distance_to(being.global_position)
			if distance < 20.0:  # Within consciousness influence range
				var influence = being.get_consciousness_level() / (1.0 + distance * 0.1)
				nearby_consciousness += influence
	
	return base_strength + nearby_consciousness * 0.5

func update_consciousness_based_effects(delta: float) -> void:
	"""Update visual effects based on consciousness levels"""
	# Update existing consciousness visualizations
	for being_id in active_consciousness_visualizations.keys():
		var viz_data = active_consciousness_visualizations[being_id]
		update_being_visualization(viz_data, delta)

func update_being_visualization(viz_data: Dictionary, delta: float) -> void:
	"""Update visualization for specific Universal Being"""
	var being = viz_data.get("being") as UniversalBeing
	if not being or not is_instance_valid(being):
		return
	
	var visual_node = viz_data.get("visual_node") as Node3D
	if not visual_node:
		return
	
	# Update consciousness evolution shader parameters
	var mesh_instance = visual_node.get_node_or_null("EvolutionMesh") as MeshInstance3D
	if mesh_instance and mesh_instance.material_override:
		var material = mesh_instance.material_override as ShaderMaterial
		if material:
			material.set_shader_parameter("consciousness_level", being.consciousness_level)
			material.set_shader_parameter("evolution_energy", being.consciousness_level * 0.8)

func process_evolution_visualizations(delta: float) -> void:
	"""Process active evolution visualizations"""
	if not evolution_effect_manager:
		return
	
	# Update active evolution effects
	for child in evolution_effect_manager.get_children():
		if child.has_method("update_evolution_effect"):
			child.update_evolution_effect(delta)

func manage_5d_field_rendering(delta: float) -> void:
	"""Manage 5D field rendering based on performance"""
	var target_fps = 60.0
	var current_fps = Engine.get_frames_per_second()
	
	if current_fps < target_fps * 0.8:  # Below 80% of target
		# Reduce field quality
		reduce_5d_field_quality()
	elif current_fps > target_fps * 1.1:  # Above 110% of target
		# Can increase field quality
		increase_5d_field_quality()

func reduce_5d_field_quality() -> void:
	"""Reduce 5D field quality for performance"""
	for field_instance in 5d_field_instances:
		var field_mesh = field_instance.get_node_or_null("FieldMesh")
		if field_mesh and field_mesh.material_override:
			var material = field_mesh.material_override as ShaderMaterial
			if material:
				# Reduce particle density
				var current_density = material.get_shader_parameter("consciousness_particle_density")
				if current_density > 0.5:
					material.set_shader_parameter("consciousness_particle_density", current_density * 0.8)

func increase_5d_field_quality() -> void:
	"""Increase 5D field quality when performance allows"""
	for field_instance in 5d_field_instances:
		var field_mesh = field_instance.get_node_or_null("FieldMesh")
		if field_mesh and field_mesh.material_override:
			var material = field_mesh.material_override as ShaderMaterial
			if material:
				# Increase particle density up to limit
				var current_density = material.get_shader_parameter("consciousness_particle_density")
				if current_density < 3.0:
					material.set_shader_parameter("consciousness_particle_density", current_density * 1.1)

func optimize_visual_performance(delta: float) -> void:
	"""Optimize visual performance based on system load"""
	# Count active visualizations
	var active_viz_count = active_consciousness_visualizations.size() + 5d_field_instances.size()
	
	if active_viz_count > max_active_visualizations:
		# Cull distant visualizations
		cull_distant_visualizations()
	
	# Apply LOD to distant visualizations
	apply_visualization_lod()

func cull_distant_visualizations() -> void:
	"""Cull visualizations beyond LOD distance"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var camera_position = camera.global_position
	
	# Cull distant 5D field instances
	for i in range(5d_field_instances.size() - 1, -1, -1):
		var field_instance = 5d_field_instances[i]
		if field_instance.global_position.distance_to(camera_position) > visualization_lod_distance:
			field_instance.visible = false
		else:
			field_instance.visible = true

func apply_visualization_lod() -> void:
	"""Apply Level of Detail to visualizations"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var camera_position = camera.global_position
	
	for field_instance in 5d_field_instances:
		var distance = field_instance.global_position.distance_to(camera_position)
		var lod_level = get_lod_level(distance)
		apply_lod_to_field_instance(field_instance, lod_level)

func get_lod_level(distance: float) -> int:
	"""Get LOD level based on distance"""
	if distance < 10.0:
		return 0  # High detail
	elif distance < 25.0:
		return 1  # Medium detail
	elif distance < 50.0:
		return 2  # Low detail
	else:
		return 3  # Culled

func apply_lod_to_field_instance(field_instance: Node3D, lod_level: int) -> void:
	"""Apply LOD to field instance"""
	var field_mesh = field_instance.get_node_or_null("FieldMesh")
	if not field_mesh or not field_mesh.material_override:
		return
	
	var material = field_mesh.material_override as ShaderMaterial
	if not material:
		return
	
	match lod_level:
		0:  # High detail
			material.set_shader_parameter("consciousness_particle_density", 3.0)
			material.set_shader_parameter("show_dimensional_grid", true)
		1:  # Medium detail
			material.set_shader_parameter("consciousness_particle_density", 2.0)
			material.set_shader_parameter("show_dimensional_grid", true)
		2:  # Low detail
			material.set_shader_parameter("consciousness_particle_density", 1.0)
			material.set_shader_parameter("show_dimensional_grid", false)
		3:  # Culled
			field_instance.visible = false

func monitor_visual_performance() -> void:
	"""Monitor visual system performance"""
	var current_fps = Engine.get_frames_per_second()
	var viz_count = active_consciousness_visualizations.size() + 5d_field_instances.size()
	
	if current_fps < 45.0 and viz_count > 5:
		print("⚡ Visual performance warning: %.1f FPS with %d visualizations" % [current_fps, viz_count])
		# Trigger aggressive optimization
		apply_aggressive_visual_optimization()

func apply_aggressive_visual_optimization() -> void:
	"""Apply aggressive visual optimization for performance recovery"""
	print("🚨 Applying aggressive visual optimization...")
	
	# Reduce all field qualities
	for field_instance in 5d_field_instances:
		apply_lod_to_field_instance(field_instance, 2)  # Force low detail
	
	# Reduce visual effects
	for viz_data in active_consciousness_visualizations.values():
		var visual_node = viz_data.get("visual_node")
		if visual_node and visual_node.has_method("reduce_effect_quality"):
			visual_node.reduce_effect_quality()

# Signal Handlers

func _on_timeline_event_visual_update(event_data: Dictionary) -> void:
	"""Handle timeline event visual updates"""
	var event_type = event_data.get("type", "unknown")
	var location = event_data.get("location", Vector3.ZERO)
	
	# Create visual effect for timeline event
	match event_type:
		"consciousness":
			create_consciousness_event_visualization(event_data)
		"disaster":
			create_disaster_event_visualization(event_data)
		"video":
			create_video_event_visualization(event_data)

func create_consciousness_event_visualization(event_data: Dictionary) -> void:
	"""Create visualization for consciousness events"""
	var location = event_data.get("location", Vector3.ZERO)
	var consciousness_level = event_data.get("consciousness_level", 5.0)
	
	# Create consciousness event visual effect
	var effect_node = Node3D.new()
	effect_node.name = "ConsciousnessEvent"
	effect_node.position = location
	consciousness_field_visualizer.add_child(effect_node)
	
	# Add evolution visualization mesh
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "EvolutionMesh"
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = consciousness_level * 0.3
	mesh_instance.mesh = sphere_mesh
	
	# Apply consciousness evolution shader
	var material = ShaderMaterial.new()
	var evolution_shader = load("res://shaders/consciousness_evolution_visualization.gdshader")
	if evolution_shader:
		material.shader = evolution_shader
		material.set_shader_parameter("consciousness_level", consciousness_level)
		material.set_shader_parameter("show_consciousness_aura", true)
		material.set_shader_parameter("consciousness_glow_intensity", 3.0)
		mesh_instance.material_override = material
	
	effect_node.add_child(mesh_instance)
	
	# Auto-remove after time
	var timer = Timer.new()
	timer.wait_time = 10.0
	timer.timeout.connect(func(): effect_node.queue_free())
	effect_node.add_child(timer)
	timer.start()

func create_disaster_event_visualization(event_data: Dictionary) -> void:
	"""Create visualization for disaster events"""
	var disaster_type = event_data.get("disaster_type", "unknown")
	var location = event_data.get("location", Vector3.ZERO)
	var intensity = event_data.get("intensity", 5.0)
	
	# Special handling for flood disasters (Texas flood integration)
	if disaster_type == "flood":
		create_flood_disaster_visual_effect(location, intensity)

func create_flood_disaster_visual_effect(location: Vector3, intensity: float) -> void:
	"""Create flood disaster visual effect"""
	var flood_effect = Node3D.new()
	flood_effect.name = "FloodDisasterEffect"
	flood_effect.position = location
	consciousness_field_visualizer.add_child(flood_effect)
	
	# Create flood visualization plane
	var mesh_instance = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(intensity * 2.0, intensity * 2.0)
	mesh_instance.mesh = plane_mesh
	
	# Apply flood disaster shader
	var material = ShaderMaterial.new()
	var flood_shader = load("res://shaders/flood_disaster_visualization.gdshader")
	if flood_shader:
		material.shader = flood_shader
		material.set_shader_parameter("flood_intensity", intensity)
		material.set_shader_parameter("show_flood_spread", true)
		material.set_shader_parameter("consciousness_impact", intensity * 0.8)
		mesh_instance.material_override = material
	
	flood_effect.add_child(mesh_instance)

func create_video_event_visualization(event_data: Dictionary) -> void:
	"""Create visualization for video events"""
	var location = event_data.get("location", Vector3.ZERO)
	var consciousness_level = event_data.get("consciousness_level", 3.0)
	
	# Create simple video marker with consciousness coloring
	var video_effect = Node3D.new()
	video_effect.position = location
	consciousness_field_visualizer.add_child(video_effect)
	
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.5, 0.5, 0.1)
	mesh_instance.mesh = box_mesh
	
	# Simple consciousness-colored material
	var material = StandardMaterial3D.new()
	material.albedo_color = map_consciousness_to_color(consciousness_level)
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.5
	mesh_instance.material_override = material
	
	video_effect.add_child(mesh_instance)

func map_consciousness_to_color(level: float) -> Color:
	"""Map consciousness level to color"""
	if level <= 2.0:
		return Color.GRAY
	elif level <= 4.0:
		return Color.BLUE
	elif level <= 6.0:
		return Color.GREEN
	elif level <= 8.0:
		return Color.YELLOW
	else:
		return Color.WHITE

func _on_disaster_visual_effect(disaster_type: String, location: Vector3, intensity: float) -> void:
	"""Handle disaster visual effects"""
	print("🌋 Creating visual effect for %s disaster at %s" % [disaster_type, location])
	create_disaster_event_visualization({
		"disaster_type": disaster_type,
		"location": location,
		"intensity": intensity
	})

func _on_5d_dimension_changed(dimension: String, value: float) -> void:
	"""Handle 5D dimension changes"""
	print("🌟 5D dimension %s changed to %.1f" % [dimension, value])
	
	# Update all field instances
	for field_instance in 5d_field_instances:
		var field_mesh = field_instance.get_node_or_null("FieldMesh")
		if field_mesh and field_mesh.material_override:
			var material = field_mesh.material_override as ShaderMaterial
			material.set_shader_parameter(dimension + "_activity", value)

func _on_type_creation_started(type_name: String) -> void:
	"""Handle type creation start"""
	print("🎨 Starting visual effects for type creation: %s" % type_name)
	
	# Enable creation mode on all field instances
	for field_instance in 5d_field_instances:
		var field_mesh = field_instance.get_node_or_null("FieldMesh")
		if field_mesh and field_mesh.material_override:
			var material = field_mesh.material_override as ShaderMaterial
			material.set_shader_parameter("type_creation_mode", true)

func _on_type_preview_updated(preview_data: Dictionary) -> void:
	"""Handle type preview updates"""
	print("👁️ Updating type preview visualization")
	# Preview visualization handled by interface manager

func _on_interface_mode_changed(mode: String) -> void:
	"""Handle interface mode changes"""
	print("🎮 Interface mode changed to: %s" % mode)

func _on_being_evolution_triggered(being: UniversalBeing, evolved_type: String) -> void:
	"""Handle Universal Being evolution visualization"""
	print("🌱 Creating evolution visualization for %s -> %s" % [being.being_type, evolved_type])
	
	create_evolution_visual_effect(being, evolved_type)
	evolution_visualization_triggered.emit(being, {"evolved_type": evolved_type})

func create_evolution_visual_effect(being: UniversalBeing, evolved_type: String) -> void:
	"""Create visual effect for Universal Being evolution"""
	var evolution_effect = Node3D.new()
	evolution_effect.name = "EvolutionEffect"
	evolution_effect.position = being.global_position
	evolution_effect_manager.add_child(evolution_effect)
	
	# Create evolution particle effect
	var particles = GPUParticles3D.new()
	particles.emitting = true
	particles.amount = 200
	evolution_effect.add_child(particles)
	
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 1, 0)
	particle_material.initial_velocity_min = 2.0
	particle_material.initial_velocity_max = 5.0
	particle_material.scale_min = 0.1
	particle_material.scale_max = 0.3
	particles.process_material = particle_material
	
	# Auto-remove after evolution effect
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.timeout.connect(func(): evolution_effect.queue_free())
	evolution_effect.add_child(timer)
	timer.start()

func _on_being_manifested_visual(being_instance: UniversalBeing, type_name: String) -> void:
	"""Handle visual effects for new being manifestation"""
	print("🌟 Creating manifestation visualization for %s" % type_name)
	
	# Register being for consciousness visualization
	register_being_for_visualization(being_instance)

func register_being_for_visualization(being: UniversalBeing) -> void:
	"""Register Universal Being for consciousness visualization"""
	var being_id = being.get_instance_id()
	
	# Create visualization node for being
	var visual_node = Node3D.new()
	visual_node.name = "ConsciousnessVisualization"
	being.add_child(visual_node)
	
	# Add consciousness evolution mesh
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "EvolutionMesh"
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 1.0
	mesh_instance.mesh = sphere_mesh
	
	# Apply consciousness evolution shader
	var material = ShaderMaterial.new()
	var evolution_shader = load("res://shaders/consciousness_evolution_visualization.gdshader")
	if evolution_shader:
		material.shader = evolution_shader
		material.set_shader_parameter("consciousness_level", being.consciousness_level)
		material.set_shader_parameter("show_consciousness_aura", true)
		material.set_shader_parameter("consciousness_glow_intensity", 2.0)
		mesh_instance.material_override = material
	
	visual_node.add_child(mesh_instance)
	
	# Register in visualization system
	active_consciousness_visualizations[being_id] = {
		"being": being,
		"visual_node": visual_node,
		"mesh_instance": mesh_instance
	}
	
	consciousness_visual_updated.emit(being.consciousness_level, {"being_id": being_id})

func _on_performance_warning(fps: float, cause: String) -> void:
	"""Handle performance warnings from timeline optimizer"""
	print("⚠️ Performance warning: %.1f FPS - %s" % [fps, cause])
	
	if fps < 30.0:
		apply_aggressive_visual_optimization()

# Toggle Functions

func toggle_5d_visualization() -> void:
	"""Toggle 5D visualization on/off"""
	enable_5d_visualization = !enable_5d_visualization
	
	for field_instance in 5d_field_instances:
		field_instance.visible = enable_5d_visualization
	
	print("🌟 5D visualization %s" % ("enabled" if enable_5d_visualization else "disabled"))

func toggle_evolution_effects() -> void:
	"""Toggle evolution effects on/off"""
	enable_evolution_effects = !enable_evolution_effects
	
	if evolution_effect_manager:
		evolution_effect_manager.visible = enable_evolution_effects
	
	print("🌱 Evolution effects %s" % ("enabled" if enable_evolution_effects else "disabled"))

func toggle_consciousness_interface() -> void:
	"""Toggle consciousness interface on/off"""
	enable_consciousness_interface = !enable_consciousness_interface
	
	if consciousness_5d_interface:
		consciousness_5d_interface.visible = enable_consciousness_interface
	
	print("🎨 Consciousness interface %s" % ("enabled" if enable_consciousness_interface else "disabled"))

func cycle_visual_quality() -> void:
	"""Cycle through visual quality levels"""
	visual_quality_level = (visual_quality_level % 5) + 1
	apply_visual_quality_level(visual_quality_level)
	print("⚡ Visual quality set to level %d" % visual_quality_level)

func apply_visual_quality_level(level: int) -> void:
	"""Apply visual quality level to all systems"""
	match level:
		1:  # Low quality
			consciousness_particle_limit = 200
			max_active_visualizations = 5
		2:  # Medium-low quality
			consciousness_particle_limit = 400
			max_active_visualizations = 10
		3:  # Medium quality
			consciousness_particle_limit = 1000
			max_active_visualizations = 20
		4:  # High quality
			consciousness_particle_limit = 2000
			max_active_visualizations = 30
		5:  # Ultra quality
			consciousness_particle_limit = 5000
			max_active_visualizations = 50
	
	# Update all visualizations with new quality settings
	update_all_visualizations_quality()

func update_all_visualizations_quality() -> void:
	"""Update all visualizations with current quality settings"""
	for field_instance in 5d_field_instances:
		var field_mesh = field_instance.get_node_or_null("FieldMesh")
		if field_mesh and field_mesh.material_override:
			var material = field_mesh.material_override as ShaderMaterial
			var particle_density = min(3.0, visual_quality_level * 0.6)
			material.set_shader_parameter("consciousness_particle_density", particle_density)

func save_visual_preferences() -> void:
	"""Save visual preferences"""
	print("💾 Saving visual preferences...")
	# Would save to configuration file in full implementation

# Public API

func create_consciousness_visualization_for_being(being: UniversalBeing) -> void:
	"""Public API to create consciousness visualization for a being"""
	register_being_for_visualization(being)

func get_visualization_status() -> Dictionary:
	"""Get current visualization system status"""
	return {
		"5d_visualization_enabled": enable_5d_visualization,
		"evolution_effects_enabled": enable_evolution_effects,
		"consciousness_interface_enabled": enable_consciousness_interface,
		"visual_quality_level": visual_quality_level,
		"active_visualizations": active_consciousness_visualizations.size(),
		"5d_field_instances": 5d_field_instances.size(),
		"performance_optimized": Engine.get_frames_per_second() >= 50.0
	}