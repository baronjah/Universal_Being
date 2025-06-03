# ChunkUniversalBeing - 3D Grid Spatial Data Storage
# Each chunk represents a 10x10x10 unit of space that can contain and generate content

extends UniversalBeing
class_name ChunkUniversalBeing

# ===== DEBUG META CONFIGURATION =====
const DEBUG_META := {
	"show_vars": ["chunk_coordinates", "chunk_active", "generation_level", "current_lod", "consciousness_level", "render_distance", "detail_distance"],
	"edit_vars": ["chunk_active", "generation_level", "consciousness_level", "render_distance", "detail_distance"],
	"actions": {
		"Generate Content": "generate_full_content",
		"Clear Chunk": "clear_chunk_content", 
		"Save to Akashic": "save_chunk_to_akashic",
		"Test LOD": "test_lod_cycle",
		"Inspect": "inspect_chunk"
	}
}

# ===== CHUNK PROPERTIES =====
@export var chunk_coordinates: Vector3i = Vector3i.ZERO :
	set(value):
		chunk_coordinates = value
		if pentagon_initialized:
			being_name = "Chunk_%d_%d_%d" % [chunk_coordinates.x, chunk_coordinates.y, chunk_coordinates.z]
@export var chunk_size: Vector3 = Vector3(10.0, 10.0, 10.0)
@export var chunk_active: bool = false
@export var generation_level: int = 0  # How much content has been generated

# Chunk Content Management
var stored_beings: Array[Node] = []
var stored_data: Dictionary = {}
var generation_rules: Dictionary = {}
var debug_label: Label3D = null
var chunk_boundary: Node3D = null

# LOD System
enum LODLevel { HIDDEN, MINIMAL, BASIC, DETAILED, FULL_DETAIL }
var current_lod: LODLevel = LODLevel.HIDDEN
var render_distance: float = 50.0
var detail_distance: float = 20.0

# Generation Systems
var terrain_generator: TerrainGenerator = null
var star_generator: StarGenerator = null
var content_generator: ContentGenerator = null

# Signals for chunk management
signal chunk_activated(chunk: ChunkUniversalBeing)
signal chunk_deactivated(chunk: ChunkUniversalBeing)
signal content_generated(chunk: ChunkUniversalBeing, content_type: String)
signal chunk_loaded(chunk: ChunkUniversalBeing)
signal chunk_unloaded(chunk: ChunkUniversalBeing)

# ===== STATIC FACTORY METHOD =====

static func create_at(coordinates: Vector3i) -> ChunkUniversalBeing:
	"""Create a chunk at specific coordinates"""
	var chunk = ChunkUniversalBeing.new()
	chunk.chunk_coordinates = coordinates
	chunk.being_name = "Chunk_%d_%d_%d" % [coordinates.x, coordinates.y, coordinates.z]
	return chunk

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Chunk_%d_%d_%d" % [chunk_coordinates.x, chunk_coordinates.y, chunk_coordinates.z]
	being_type = "spatial_chunk"
	consciousness_level = 1  # Chunks are conscious spatial containers
	
	# Initialize chunk components
	initialize_chunk_systems()
	setup_generation_rules()

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	print("🧊 Chunk %s pentagon_ready called!" % being_name)
	
	# Position chunk in world space
	position_chunk_in_world()
	create_debug_visualization()
	setup_lod_system()
	
	# Connect to spatial systems
	connect_to_akashic_records()
	
	# Register with LogicConnector for debugging (now that we're in the tree)
	# Try to find LogicConnector in parent nodes or as sibling
	var logic_connector = get_node_or_null("/root/LogicConnector")
	if not logic_connector:
		# Try to find in parent hierarchy
		var parent = get_parent()
		while parent and not logic_connector:
			logic_connector = parent.get_node_or_null("LogicConnector")
			if not logic_connector:
				parent = parent.get_parent()
	
	if logic_connector:
		logic_connector.register(self)
		print("🔌 Registered chunk %s with LogicConnector" % being_name)
	else:
		print("❌ LogicConnector not found for chunk %s!" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update LOD based on distance to active cameras/players
	update_lod_system(delta)
	
	# Process chunk content if active
	if chunk_active:
		process_chunk_content(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle chunk-specific interactions
	if chunk_active and event is InputEventMouseButton:
		handle_chunk_interaction(event)

func pentagon_sewers() -> void:
	# Save chunk data before transformation/destruction
	save_chunk_to_akashic()
	
	# Deregister from LogicConnector
	var logic_connector = get_node_or_null("/root/LogicConnector")
	if not logic_connector:
		# Try to find in parent hierarchy
		var parent = get_parent()
		while parent and not logic_connector:
			logic_connector = parent.get_node_or_null("LogicConnector")
			if not logic_connector:
				parent = parent.get_parent()
	
	if logic_connector:
		logic_connector.deregister(self)
	
	super.pentagon_sewers()

# ===== CHUNK INITIALIZATION =====

func initialize_chunk_systems() -> void:
	"""Initialize all chunk subsystems"""
	# Create generators based on Y level
	setup_generators_by_y_level()
	
	# Initialize data storage
	stored_data = {
		"chunk_coordinates": chunk_coordinates,
		"generation_timestamp": Time.get_ticks_msec(),
		"generation_seed": randi(),
		"content_manifest": {},
		"visitor_log": [],
		"evolution_history": []
	}

func setup_generators_by_y_level() -> void:
	"""Setup different generators based on Y coordinate"""
	var y_coord = chunk_coordinates.y
	
	if y_coord < -5:
		# Underground: caves, minerals, roots
		content_generator = UndergroundGenerator.new()
	elif y_coord >= -5 and y_coord <= 5:
		# Surface: terrain, vegetation, structures
		terrain_generator = TerrainGenerator.new()
		content_generator = SurfaceGenerator.new()
	elif y_coord > 5 and y_coord <= 20:
		# Sky: clouds, flying creatures, floating platforms
		content_generator = SkyGenerator.new()
	else:
		# Space: stars, cosmic entities, void structures
		star_generator = StarGenerator.new()
		content_generator = CosmicGenerator.new()

func setup_generation_rules() -> void:
	"""Setup rules for what can be generated in this chunk"""
	generation_rules = {
		"max_beings_per_chunk": 10,
		"terrain_complexity": 1.0,
		"vegetation_density": 0.5,
		"structure_probability": 0.1,
		"cosmic_density": 0.2,
		"evolution_rate": 1.0,
		"consciousness_attraction": 1.0
	}

# ===== WORLD POSITIONING =====

func position_chunk_in_world() -> void:
	"""Position this chunk in 3D world space"""
	global_position = Vector3(
		chunk_coordinates.x * chunk_size.x,
		chunk_coordinates.y * chunk_size.y,
		chunk_coordinates.z * chunk_size.z
	)
	
	# Create chunk boundary visualization (optional)
	if OS.is_debug_build():
		create_chunk_boundary()

func create_chunk_boundary() -> void:
	"""Create visual boundary for debugging"""
	if chunk_boundary:
		return
		
	chunk_boundary = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = chunk_size
	chunk_boundary.mesh = box_mesh
	
	# Create wireframe material
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.CYAN
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.2
	material.cull_mode = BaseMaterial3D.CULL_DISABLED  # Show both sides
	chunk_boundary.material_override = material
	
	add_child(chunk_boundary)

# ===== DEBUG VISUALIZATION =====

func create_debug_visualization() -> void:
	"""Create debug label showing chunk coordinates"""
	if debug_label:
		return
		
	debug_label = Label3D.new()
	debug_label.text = "[%d,%d,%d]" % [chunk_coordinates.x, chunk_coordinates.y, chunk_coordinates.z]
	debug_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	debug_label.modulate = get_consciousness_color()
	debug_label.pixel_size = 0.01
	debug_label.position.y = chunk_size.y / 2 + 2.0  # Float above chunk
	
	add_child(debug_label)
	
	# Add secondary info label
	var info_label = Label3D.new()
	info_label.text = "Gen:%d LOD:%s" % [generation_level, LODLevel.keys()[current_lod]]
	info_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	info_label.modulate = Color.WHITE
	info_label.pixel_size = 0.008
	info_label.position.y = chunk_size.y / 2 + 1.0
	
	add_child(info_label)
	
	# Add debug indicator (shows this chunk is debuggable)
	var debug_indicator = Label3D.new()
	debug_indicator.text = "🎛️"  # Debug icon
	debug_indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	debug_indicator.modulate = Color(0.5, 1.0, 1.0, 0.8)  # Cyan glow
	debug_indicator.pixel_size = 0.015
	debug_indicator.position.y = chunk_size.y / 2 + 3.0
	debug_indicator.position.x = -2.0
	debug_indicator.name = "DebugIndicator"
	
	add_child(debug_indicator)

func update_debug_labels() -> void:
	"""Update debug information"""
	if debug_label:
		var children = get_children()
		for child in children:
			if child is Label3D:
				if child.text.begins_with("["):
					child.text = "[%d,%d,%d]" % [chunk_coordinates.x, chunk_coordinates.y, chunk_coordinates.z]
					child.modulate = get_consciousness_color()
				elif child.text.begins_with("Gen:"):
					child.text = "Gen:%d LOD:%s" % [generation_level, LODLevel.keys()[current_lod]]

# ===== LOD SYSTEM =====

func setup_lod_system() -> void:
	"""Initialize Level of Detail system"""
	current_lod = LODLevel.HIDDEN
	set_lod_level(LODLevel.MINIMAL)

func update_lod_system(delta: float) -> void:
	"""Update LOD based on distance to observers"""
	var closest_distance = get_distance_to_closest_observer()
	var new_lod = calculate_lod_level(closest_distance)
	
	if new_lod != current_lod:
		set_lod_level(new_lod)

func get_distance_to_closest_observer() -> float:
	"""Get distance to closest camera or player"""
	var min_distance = INF
	
	# Check cameras
	var cameras = get_tree().get_nodes_in_group("cameras")
	for camera in cameras:
		if camera is Camera3D:
			var distance = global_position.distance_to(camera.global_position)
			min_distance = min(min_distance, distance)
	
	# Check players
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		var distance = global_position.distance_to(player.global_position)
		min_distance = min(min_distance, distance)
	
	return min_distance if min_distance != INF else 1000.0

func calculate_lod_level(distance: float) -> LODLevel:
	"""Calculate appropriate LOD level based on distance"""
	if distance > render_distance * 2:
		return LODLevel.HIDDEN
	elif distance > render_distance:
		return LODLevel.MINIMAL
	elif distance > detail_distance:
		return LODLevel.BASIC
	elif distance > detail_distance / 2:
		return LODLevel.DETAILED
	else:
		return LODLevel.FULL_DETAIL

func set_lod_level(new_lod: LODLevel) -> void:
	"""Set the LOD level and adjust chunk accordingly"""
	if new_lod == current_lod:
		return
		
	var old_lod = current_lod
	current_lod = new_lod
	
	match current_lod:
		LODLevel.HIDDEN:
			deactivate_chunk()
		LODLevel.MINIMAL:
			activate_chunk_minimal()
		LODLevel.BASIC:
			activate_chunk_basic()
		LODLevel.DETAILED:
			activate_chunk_detailed()
		LODLevel.FULL_DETAIL:
			activate_chunk_full()
	
	update_debug_labels()
	print("🧊 Chunk %s: LOD %s -> %s (dist: %.1f)" % [being_name, LODLevel.keys()[old_lod], LODLevel.keys()[current_lod], get_distance_to_closest_observer()])

# ===== LOD ACTIVATION LEVELS =====

func deactivate_chunk() -> void:
	"""Deactivate chunk completely"""
	chunk_active = false
	visible = false
	set_process_mode(Node.PROCESS_MODE_DISABLED)
	chunk_deactivated.emit(self)

func activate_chunk_minimal() -> void:
	"""Activate with minimal detail"""
	chunk_active = true
	visible = true
	set_process_mode(Node.PROCESS_MODE_PAUSABLE)
	
	# Show only debug labels
	if debug_label:
		debug_label.visible = true
		
	chunk_activated.emit(self)

func activate_chunk_basic() -> void:
	"""Activate with basic detail"""
	activate_chunk_minimal()
	
	# Generate basic terrain if not done
	if generation_level < 1:
		generate_basic_content()

func activate_chunk_detailed() -> void:
	"""Activate with detailed content"""
	activate_chunk_basic()
	
	# Generate detailed content
	if generation_level < 2:
		generate_detailed_content()

func activate_chunk_full() -> void:
	"""Activate with full detail"""
	activate_chunk_detailed()
	
	# Generate full content including beings
	if generation_level < 3:
		generate_full_content()

# ===== CONTENT GENERATION =====

func generate_basic_content() -> void:
	"""Generate basic chunk content (terrain, basic structures)"""
	if not terrain_generator and not star_generator:
		return
		
	print("🌱 Generating basic content for chunk %s" % being_name)
	
	if terrain_generator:
		terrain_generator.generate_terrain(self)
	elif star_generator:
		star_generator.generate_stars(self)
		
	generation_level = max(generation_level, 1)
	content_generated.emit(self, "basic")

func generate_detailed_content() -> void:
	"""Generate detailed content (vegetation, detailed structures)"""
	print("🌳 Generating detailed content for chunk %s" % being_name)
	
	if content_generator:
		content_generator.generate_detailed_content(self)
		
	generation_level = max(generation_level, 2)
	content_generated.emit(self, "detailed")

func generate_full_content() -> void:
	"""Generate full content including conscious beings"""
	print("✨ Generating full content for chunk %s" % being_name)
	
	if content_generator:
		content_generator.generate_beings(self)
		
	generation_level = max(generation_level, 3)
	content_generated.emit(self, "full")

func process_chunk_content(delta: float) -> void:
	"""Process content within the chunk"""
	# Update stored beings
	for being in stored_beings:
		if being and is_instance_valid(being):
			# Beings process themselves, but we can add chunk-level interactions
			process_being_in_chunk(being, delta)

func process_being_in_chunk(being: Node, delta: float) -> void:
	"""Process a being within this chunk's context"""
	# Check if being should evolve based on chunk properties
	if being.has_method("evolve_in_environment"):
		being.evolve_in_environment(self, delta)

# ===== CHUNK INTERACTIONS =====

func handle_chunk_interaction(event: InputEventMouseButton) -> void:
	"""Handle mouse interactions with the chunk"""
	if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		inspect_chunk()
	elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		show_chunk_context_menu()

func inspect_chunk() -> void:
	"""Inspect chunk contents and properties"""
	print("🔍 Inspecting Chunk %s:" % being_name)
	print("  Coordinates: %s" % chunk_coordinates)
	print("  Generation Level: %d" % generation_level)
	print("  LOD Level: %s" % LODLevel.keys()[current_lod])
	print("  Stored Beings: %d" % stored_beings.size())
	print("  Stored Data Keys: %s" % stored_data.keys())

func show_chunk_context_menu() -> void:
	"""Show context menu for chunk operations"""
	print("📋 Chunk Context Menu:")
	print("  1. Generate Content")
	print("  2. Clear Chunk")
	print("  3. Save to Akashic")
	print("  4. Load from Akashic")
	print("  5. Set Generation Rules")

# ===== AKASHIC INTEGRATION =====

func connect_to_akashic_records() -> void:
	"""Connect to Akashic Records for persistence"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic:
			# Try to load existing chunk data
			load_chunk_from_akashic()

func save_chunk_to_akashic() -> void:
	"""Save chunk state to Akashic Records"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		return
		
	var akashic = SystemBootstrap.get_akashic_records()
	if not akashic:
		return
		
	var chunk_data = {
		"coordinates": chunk_coordinates,
		"generation_level": generation_level,
		"stored_data": stored_data,
		"generation_rules": generation_rules,
		"being_manifest": []
	}
	
	# Add stored beings info
	for being in stored_beings:
		if being and being.has_method("get_akashic_data"):
			chunk_data.being_manifest.append(being.get_akashic_data())
	
	var chunk_id = "chunk_%d_%d_%d" % [chunk_coordinates.x, chunk_coordinates.y, chunk_coordinates.z]
	akashic.save_universal_being_data(chunk_id, chunk_data)
	
	print("💾 Saved chunk %s to Akashic Records" % being_name)

func load_chunk_from_akashic() -> void:
	"""Load chunk state from Akashic Records"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		return
		
	var akashic = SystemBootstrap.get_akashic_records()
	if not akashic:
		return
		
	var chunk_id = "chunk_%d_%d_%d" % [chunk_coordinates.x, chunk_coordinates.y, chunk_coordinates.z]
	var chunk_data = akashic.load_universal_being_data(chunk_id)
	
	if chunk_data:
		generation_level = chunk_data.get("generation_level", 0)
		stored_data.merge(chunk_data.get("stored_data", {}))
		generation_rules.merge(chunk_data.get("generation_rules", {}))
		
		# Restore beings from manifest
		var being_manifest = chunk_data.get("being_manifest", [])
		for being_data in being_manifest:
			restore_being_from_data(being_data)
		
		print("📖 Loaded chunk %s from Akashic Records" % being_name)

func restore_being_from_data(being_data: Dictionary) -> void:
	"""Restore a being from Akashic data"""
	# This would restore beings that were saved in the chunk
	# Implementation depends on the being restoration system
	pass

# ===== UTILITY FUNCTIONS =====

func add_being_to_chunk(being: Node) -> void:
	"""Add a being to this chunk"""
	if being not in stored_beings:
		stored_beings.append(being)
		being.reparent(self)
		
		# Log visitor
		if being.has_method("get_being_name"):
			stored_data.visitor_log.append({
				"being_name": being.get_being_name(),
				"timestamp": Time.get_ticks_msec(),
				"action": "entered_chunk"
			})

func remove_being_from_chunk(being: Node) -> void:
	"""Remove a being from this chunk"""
	stored_beings.erase(being)
	
	# Log departure
	if being.has_method("get_being_name"):
		stored_data.visitor_log.append({
			"being_name": being.get_being_name(),
			"timestamp": Time.get_ticks_msec(),
			"action": "left_chunk"
		})

func get_chunk_bounds() -> AABB:
	"""Get the bounding box of this chunk"""
	return AABB(global_position - chunk_size/2, chunk_size)

func is_position_in_chunk(pos: Vector3) -> bool:
	"""Check if a position is within this chunk"""
	return get_chunk_bounds().has_point(pos)

func get_chunk_center() -> Vector3:
	"""Get the center position of this chunk"""
	return global_position

# ===== CONSCIOUSNESS COLOR =====

func get_consciousness_color() -> Color:
	"""Get color based on consciousness level - delegates to base class"""
	return _get_consciousness_color()

# ===== DEBUGGABLE INTERFACE IMPLEMENTATION =====

func get_debug_payload() -> Dictionary:
	"""Return debug payload using DEBUG_META configuration"""
	var out := {}
	for key in DEBUG_META.get("show_vars", []):
		if has_method("get") and get(key) != null:
			out[key] = get(key)
		else:
			# Special handling for computed properties
			match key:
				"current_lod":
					out[key] = LODLevel.keys()[current_lod]
				_:
					out[key] = "N/A"
	return out

func set_debug_field(key: String, value) -> void:
	"""Handle live field editing from debug interface"""
	# Check if this field is editable
	if not key in DEBUG_META.get("edit_vars", []):
		print("⚠️ Field '%s' is not editable" % key)
		return
		
	match key:
		"chunk_active":
			chunk_active = value
			print("🧊 Chunk active state: %s" % value)
		"generation_level":
			generation_level = clampi(value, 0, 3)
			print("🎨 Generation level: %d" % generation_level)
		"consciousness_level":
			consciousness_level = value
			if debug_label:
				debug_label.modulate = get_consciousness_color()
			print("🧠 Consciousness level: %d" % consciousness_level)
		"render_distance":
			render_distance = maxf(value, 1.0)
			print("👁️ Render distance: %.1f" % render_distance)
		"detail_distance":
			detail_distance = maxf(value, 1.0)
			print("🔍 Detail distance: %.1f" % detail_distance)

func get_debug_actions() -> Dictionary:
	"""Return callable debug actions from DEBUG_META"""
	var out := {}
	var actions = DEBUG_META.get("actions", {})
	for label in actions.keys():
		var method_name = actions[label]
		if has_method(method_name):
			out[label] = Callable(self, method_name)
	return out

# Debug action helpers
func clear_chunk_content() -> void:
	"""Clear all generated content"""
	for being in stored_beings:
		if being and is_instance_valid(being):
			being.queue_free()
	stored_beings.clear()
	generation_level = 0
	print("🧹 Chunk content cleared")

func test_lod_cycle() -> void:
	"""Cycle through LOD levels for testing"""
	var next_lod = (current_lod + 1) % LODLevel.size()
	set_lod_level(next_lod)
	print("🔄 LOD cycled to: %s" % LODLevel.keys()[next_lod])

# ===== GENERATOR CLASSES (Stubs for now) =====

class TerrainGenerator:
	func generate_terrain(chunk: ChunkUniversalBeing) -> void:
		print("🏔️ Generating terrain for chunk %s" % chunk.being_name)

class StarGenerator:
	func generate_stars(chunk: ChunkUniversalBeing) -> void:
		print("⭐ Generating stars for chunk %s" % chunk.being_name)

class ContentGenerator:
	func generate_detailed_content(chunk: ChunkUniversalBeing) -> void:
		print("🎨 Generating detailed content for chunk %s" % chunk.being_name)
	
	func generate_beings(chunk: ChunkUniversalBeing) -> void:
		print("👥 Generating beings for chunk %s" % chunk.being_name)

class UndergroundGenerator extends ContentGenerator:
	pass

class SurfaceGenerator extends ContentGenerator:
	pass

class SkyGenerator extends ContentGenerator:
	pass

class CosmicGenerator extends ContentGenerator:
	pass
