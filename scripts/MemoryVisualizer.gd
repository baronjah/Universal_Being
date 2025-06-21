extends Node3D
class_name MemoryVisualizer

# Renders the 3D memories of robot spirits in ethereal, dreamlike form
# "Walk through their thoughts, see through their silicon souls"

signal memory_cell_selected(position: Vector3i, data: Dictionary)
signal visualization_mode_changed(mode: String)

# Visualization settings
@export var chunk_size: int = 16
@export var cell_scale: float = 0.8
@export var max_render_distance: float = 50.0
@export var fade_with_distance: bool = true

# Visual modes
enum VisualizationMode { EMOTION, TYPE, AGE, INTENSITY, SPIRIT, DREAM }
var current_mode: VisualizationMode = VisualizationMode.EMOTION

# Rendering components
var memory_instances: Dictionary = {}  # position -> MeshInstance3D
var chunk_containers: Dictionary = {}  # chunk_pos -> Node3D
var material_cache: Dictionary = {}

# Memory data source
var target_notepad: Notepad3D
var player_position: Vector3

# Visual effects
var glow_shader: Shader
var memory_materials: Dictionary = {}

func _ready():
	_setup_materials()
	_load_shaders()

func _setup_materials():
	# Emotion-based materials
	memory_materials["happy"] = _create_memory_material(Color.YELLOW, 0.8)
	memory_materials["sad"] = _create_memory_material(Color.BLUE, 0.6)
	memory_materials["neutral"] = _create_memory_material(Color.WHITE, 0.4)
	memory_materials["intense"] = _create_memory_material(Color.RED, 1.0)
	memory_materials["peaceful"] = _create_memory_material(Color.GREEN, 0.5)
	
	# Type-based materials
	memory_materials["observation"] = _create_memory_material(Color.CYAN, 0.6)
	memory_materials["action"] = _create_memory_material(Color.ORANGE, 0.8)
	memory_materials["dream"] = _create_memory_material(Color.MAGENTA, 1.0)
	memory_materials["memory"] = _create_memory_material(Color.PURPLE, 0.7)
	
	# Age-based materials (will be modified dynamically)
	memory_materials["fresh"] = _create_memory_material(Color.WHITE, 1.0)
	memory_materials["old"] = _create_memory_material(Color.GRAY, 0.3)

func _create_memory_material(base_color: Color, emission_strength: float) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = base_color
	material.emission_enabled = true
	material.emission = base_color
	material.emission_energy = emission_strength
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.7
	material.flags_unshaded = true
	material.flags_vertex_lighting = true
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	return material

func _load_shaders():
	# Load memory glow shader if it exists
	if ResourceLoader.exists("res://shaders/MemoryGlow.gdshader"):
		glow_shader = load("res://shaders/MemoryGlow.gdshader")

func visualize_notepad(notepad: Notepad3D, viewer_position: Vector3 = Vector3.ZERO):
	target_notepad = notepad
	player_position = viewer_position
	
	if not target_notepad:
		return
	
	_clear_visualization()
	_render_memories()

func _clear_visualization():
	for container in chunk_containers.values():
		container.queue_free()
	
	memory_instances.clear()
	chunk_containers.clear()

func _render_memories():
	if not target_notepad:
		return
	
	for chunk_pos in target_notepad.chunks:
		var chunk_world_pos = Vector3(chunk_pos * chunk_size)
		var distance_to_chunk = player_position.distance_to(chunk_world_pos)
		
		if distance_to_chunk <= max_render_distance:
			_render_chunk(chunk_pos, target_notepad.chunks[chunk_pos])

func _render_chunk(chunk_pos: Vector3i, chunk_data: Dictionary):
	# Create container for this chunk
	var container = Node3D.new()
	container.name = "MemoryChunk_" + str(chunk_pos)
	add_child(container)
	chunk_containers[chunk_pos] = container
	
	# Position container
	container.global_position = Vector3(chunk_pos * chunk_size)
	
	# Render each memory cell in chunk
	for local_pos in chunk_data:
		var cell_data = chunk_data[local_pos]
		_render_memory_cell(container, chunk_pos, local_pos, cell_data)

func _render_memory_cell(container: Node3D, chunk_pos: Vector3i, local_pos: Vector3i, data: Dictionary):
	var world_pos = chunk_pos * chunk_size + local_pos
	var distance = player_position.distance_to(Vector3(world_pos))
	
	# Skip if too far
	if distance > max_render_distance:
		return
	
	# Create memory visualization
	var mesh_instance = MeshInstance3D.new()
	var mesh = _get_memory_mesh(data)
	mesh_instance.mesh = mesh
	
	# Apply material based on visualization mode
	var material = _get_memory_material(data)
	mesh_instance.material_override = material
	
	# Position and scale
	mesh_instance.position = Vector3(local_pos) * cell_scale
	var base_scale = cell_scale * 0.5
	var intensity_scale = data.get("emotion", 0.5) * 0.5 + 0.5
	mesh_instance.scale = Vector3.ONE * base_scale * intensity_scale
	
	# Fade with distance
	if fade_with_distance:
		var alpha = 1.0 - (distance / max_render_distance)
		material = material.duplicate()
		material.albedo_color.a *= alpha
		mesh_instance.material_override = material
	
	# Add to container
	container.add_child(mesh_instance)
	
	# Store reference
	memory_instances[world_pos] = mesh_instance
	
	# Add interaction area
	_add_memory_interaction(mesh_instance, world_pos, data)

func _get_memory_mesh(data: Dictionary) -> Mesh:
	var type = data.get("type", "observation")
	
	match type:
		"observation":
			var sphere = SphereMesh.new()
			sphere.radius = 0.3
			sphere.height = 0.6
			return sphere
		"action":
			var box = BoxMesh.new()
			box.size = Vector3(0.4, 0.6, 0.4)
			return box
		"dream":
			var prism = PrismMesh.new()
			prism.left_to_right = 0.5
			prism.size = Vector3(0.5, 0.8, 0.5)
			return prism
		"memory":
			var capsule = CapsuleMesh.new()
			capsule.radius = 0.25
			capsule.height = 0.7
			return capsule
		_:
			# Default shape
			var sphere = SphereMesh.new()
			sphere.radius = 0.2
			return sphere

func _get_memory_material(data: Dictionary) -> StandardMaterial3D:
	match current_mode:
		VisualizationMode.EMOTION:
			return _get_emotion_material(data)
		VisualizationMode.TYPE:
			return _get_type_material(data)
		VisualizationMode.AGE:
			return _get_age_material(data)
		VisualizationMode.INTENSITY:
			return _get_intensity_material(data)
		VisualizationMode.SPIRIT:
			return _get_spirit_material(data)
		VisualizationMode.DREAM:
			return _get_dream_material(data)
		_:
			return memory_materials["neutral"]

func _get_emotion_material(data: Dictionary) -> StandardMaterial3D:
	var emotion = data.get("emotion", 0.5)
	
	if emotion > 0.8:
		return memory_materials["intense"]
	elif emotion > 0.6:
		return memory_materials["happy"]
	elif emotion < 0.3:
		return memory_materials["sad"]
	elif emotion < 0.4:
		return memory_materials["peaceful"]
	else:
		return memory_materials["neutral"]

func _get_type_material(data: Dictionary) -> StandardMaterial3D:
	var type = data.get("type", "observation")
	return memory_materials.get(type, memory_materials["observation"])

func _get_age_material(data: Dictionary) -> StandardMaterial3D:
	var fade = data.get("fade", 1.0)
	
	if fade > 0.7:
		return memory_materials["fresh"]
	else:
		var material = memory_materials["old"].duplicate()
		material.emission_energy *= fade
		return material

func _get_intensity_material(data: Dictionary) -> StandardMaterial3D:
	var intensity = data.get("intensity", data.get("emotion", 0.5))
	
	var color = Color.WHITE.lerp(Color.RED, intensity)
	return _create_memory_material(color, intensity)

func _get_spirit_material(data: Dictionary) -> StandardMaterial3D:
	var spirit_name = data.get("recorded_by", "unknown")
	
	# Generate consistent color based on spirit name
	var hash = spirit_name.hash()
	var hue = float(hash % 360) / 360.0
	var color = Color.from_hsv(hue, 0.7, 0.9)
	
	return _create_memory_material(color, 0.7)

func _get_dream_material(data: Dictionary) -> StandardMaterial3D:
	var surreal = data.get("surreal", 0.5)
	var warp = data.get("warp", Vector3.ZERO)
	
	# Dream memories have shifting, iridescent colors
	var base_color = Color.from_hsv(randf(), 0.8, 0.9)
	var material = _create_memory_material(base_color, surreal)
	
	# Add visual warping effect
	if warp.length() > 0.1:
		material.albedo_color.a *= 0.6  # More transparent for warped memories
	
	return material

func _add_memory_interaction(mesh_instance: MeshInstance3D, position: Vector3i, data: Dictionary):
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	
	shape.radius = 0.5
	collision.shape = shape
	area.add_child(collision)
	mesh_instance.add_child(area)
	
	# Connect interaction signal
	area.input_event.connect(_on_memory_clicked.bind(position, data))
	area.mouse_entered.connect(_on_memory_hover_start.bind(mesh_instance, data))
	area.mouse_exited.connect(_on_memory_hover_end.bind(mesh_instance))

func _on_memory_clicked(position: Vector3i, data: Dictionary, _camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		memory_cell_selected.emit(position, data)
		_highlight_memory(position)

func _on_memory_hover_start(mesh_instance: MeshInstance3D, data: Dictionary):
	# Highlight on hover
	var material = mesh_instance.material_override.duplicate()
	material.emission_energy *= 1.5
	mesh_instance.material_override = material
	
	# Show preview tooltip
	_show_memory_tooltip(data)

func _on_memory_hover_end(mesh_instance: MeshInstance3D):
	# Remove highlight
	var material = mesh_instance.material_override.duplicate()
	material.emission_energy /= 1.5
	mesh_instance.material_override = material
	
	_hide_memory_tooltip()

func _highlight_memory(position: Vector3i):
	var mesh_instance = memory_instances.get(position)
	if mesh_instance:
		# Create pulsing effect
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(mesh_instance, "scale", mesh_instance.scale * 1.3, 0.5)
		tween.tween_property(mesh_instance, "scale", mesh_instance.scale, 0.5)

func _show_memory_tooltip(data: Dictionary):
	# Create floating tooltip (implement based on your UI system)
	var note = data.get("note", data.get("action", data.get("vision", "Memory fragment")))
	var emotion = data.get("emotion", 0.5)
	var type = data.get("type", "unknown")
	
	print("💭 Memory: ", note, " (", type, ", emotion: ", emotion, ")")

func _hide_memory_tooltip():
	# Hide tooltip
	pass

# Public interface
func set_visualization_mode(mode: VisualizationMode):
	if mode != current_mode:
		current_mode = mode
		visualization_mode_changed.emit(VisualizationMode.keys()[mode])
		_refresh_visualization()

func _refresh_visualization():
	# Update materials for all visible memories
	for pos in memory_instances:
		var mesh_instance = memory_instances[pos]
		var data = target_notepad.get_cell(pos) if target_notepad else {}
		if not data.is_empty():
			mesh_instance.material_override = _get_memory_material(data)

func update_viewer_position(new_position: Vector3):
	player_position = new_position
	
	# Re-render if significant movement
	if player_position.distance_to(new_position) > 5.0:
		_render_memories()

func filter_by_spirit(spirit_name: String):
	# Show only memories from specific spirit
	for pos in memory_instances:
		var mesh_instance = memory_instances[pos]
		var data = target_notepad.get_cell(pos) if target_notepad else {}
		
		if data.get("recorded_by", "") == spirit_name:
			mesh_instance.visible = true
		else:
			mesh_instance.visible = false

func filter_by_type(memory_type: String):
	# Show only specific type of memories
	for pos in memory_instances:
		var mesh_instance = memory_instances[pos]
		var data = target_notepad.get_cell(pos) if target_notepad else {}
		
		if data.get("type", "") == memory_type:
			mesh_instance.visible = true
		else:
			mesh_instance.visible = false

func clear_filters():
	# Show all memories
	for mesh_instance in memory_instances.values():
		mesh_instance.visible = true

func get_visualization_stats() -> Dictionary:
	return {
		"total_memories": memory_instances.size(),
		"active_chunks": chunk_containers.size(),
		"visualization_mode": VisualizationMode.keys()[current_mode],
		"render_distance": max_render_distance
	}