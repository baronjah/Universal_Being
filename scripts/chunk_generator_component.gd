# Basic Chunk Generator Component
# Allows Universal Beings to generate content in chunks as they move

extends Node
class_name ChunkGeneratorComponent

# ===== GENERATOR PROPERTIES =====
@export var generation_rate: float = 1.0
@export var content_types: Array[String] = ["terrain", "vegetation", "structures"]
@export var consciousness_influence: float = 0.5
@export var auto_generate: bool = true
@export var generation_radius: int = 1

# Generation State
var host_being: Node = null
var current_chunk: Node = null
var last_chunk_position: Vector3i = Vector3i(-999, -999, -999)
var generation_history: Array[Dictionary] = []
var generation_energy: float = 100.0

# Generation Rules
var generation_rules: Dictionary = {
	"terrain_probability": 0.7,
	"vegetation_probability": 0.5,
	"structure_probability": 0.2,
	"being_probability": 0.1,
	"artifact_probability": 0.05
}

# Signals
signal content_generated(chunk: Node, content_type: String, content: Node)
signal generation_failed(chunk: Node, reason: String)
signal generation_energy_depleted()
signal entered_new_chunk(chunk: Node)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	"""Initialize the chunk generator component"""
	if get_parent():
		host_being = get_parent()
		print("🎨 Chunk Generator attached to: %s" % host_being.name)
	
	# Setup generation based on host consciousness level
	setup_generation_capabilities()

func pentagon_ready() -> void:
	"""Setup connections and monitoring"""
	if host_being:
		# Connect to host movement if available
		if host_being.has_signal("position_changed"):
			host_being.position_changed.connect(_on_host_position_changed)
		
		# Start monitoring chunk changes
		start_chunk_monitoring()

func pentagon_process(delta: float) -> void:
	"""Process chunk generation"""
	if not auto_generate or not host_being:
		return
	
	# Regenerate energy over time
	generation_energy = min(100.0, generation_energy + delta * 10.0)
	
	# Check for chunk changes
	check_chunk_position()
	
	# Generate content if needed
	if current_chunk and generation_energy > 20.0:
		process_chunk_generation(delta)

# ===== SETUP AND CONFIGURATION =====

func setup_generation_capabilities() -> void:
	"""Setup generation capabilities based on host being"""
	if not host_being:
		return
	
	var consciousness = 1
	if host_being.has_method("get_consciousness_level"):
		consciousness = host_being.get_consciousness_level()
	
	# Adjust generation based on consciousness level
	match consciousness:
		1:  # Basic generation
			content_types = ["terrain"]
			generation_rate = 0.5
		2:  # More varied generation
			content_types = ["terrain", "vegetation"]
			generation_rate = 0.7
		3:  # Complex generation
			content_types = ["terrain", "vegetation", "structures"]
			generation_rate = 1.0
		4:  # Advanced generation
			content_types = ["terrain", "vegetation", "structures", "beings"]
			generation_rate = 1.5
		5:  # Transcendent generation
			content_types = ["terrain", "vegetation", "structures", "beings", "artifacts"]
			generation_rate = 2.0
	
	print("🎨 Generator configured for consciousness level %d: %s" % [consciousness, content_types])

func set_generation_rules(new_rules: Dictionary) -> void:
	"""Set custom generation rules"""
	generation_rules.merge(new_rules, true)
	print("🎨 Generation rules updated: %s" % new_rules.keys())

# ===== CHUNK MONITORING =====

func start_chunk_monitoring() -> void:
	"""Start monitoring for chunk changes"""
	if host_being and host_being.has_method("get_global_position"):
		check_chunk_position()

func check_chunk_position() -> void:
	"""Check if host has moved to a different chunk"""
	if not host_being:
		return
	
	var grid_manager = get_tree().get_first_node_in_group("chunk_grid_managers")
	if not grid_manager:
		return
	
	var current_pos = host_being.global_position
	var chunk_coord = grid_manager.world_pos_to_chunk_coord(current_pos)
	
	if chunk_coord != last_chunk_position:
		# Host moved to a new chunk
		last_chunk_position = chunk_coord
		var new_chunk = grid_manager.get_chunk_at_coordinate(chunk_coord)
		
		if new_chunk != current_chunk:
			var old_chunk = current_chunk
			current_chunk = new_chunk
			_on_chunk_changed(old_chunk, new_chunk)

func _on_chunk_changed(old_chunk: Node, new_chunk: Node) -> void:
	"""Handle chunk change"""
	if new_chunk:
		print("🎨 %s entered chunk: %s" % [host_being.name, new_chunk.being_name])
		entered_new_chunk.emit(new_chunk)
		
		# Trigger generation in new chunk if it needs content
		if auto_generate:
			consider_chunk_generation(new_chunk)

func _on_host_position_changed(new_position: Vector3) -> void:
	"""Handle host position changes"""
	check_chunk_position()

# ===== CONTENT GENERATION =====

func process_chunk_generation(delta: float) -> void:
	"""Process ongoing generation in current chunk"""
	if not current_chunk or generation_energy < 20.0:
		return
	
	# Check if chunk needs more content
	if chunk_needs_generation(current_chunk):
		generate_content_in_chunk(current_chunk)

func consider_chunk_generation(chunk: Node) -> void:
	"""Consider whether to generate content in a chunk"""
	if not chunk or not chunk.has_method("get"):
		return
	
	var generation_level = chunk.get("generation_level") if chunk.has_method("get") else 0
	
	# Generate if chunk is under-developed
	if generation_level < 2:
		generate_content_in_chunk(chunk)

func chunk_needs_generation(chunk: Node) -> bool:
	"""Check if a chunk needs more content generation"""
	if not chunk or not chunk.has_method("get"):
		return false
	
	var generation_level = chunk.get("generation_level") if chunk.has_method("get") else 0
	var stored_beings = chunk.get("stored_beings") if chunk.has_method("get") else []
	
	# Need generation if low generation level or few stored beings
	return generation_level < 2 or stored_beings.size() < 3

func generate_content_in_chunk(chunk: Node) -> void:
	"""Generate content in the specified chunk"""
	if not chunk or generation_energy < 20.0:
		return
	
	print("🎨 %s generating content in %s" % [host_being.name, chunk.name])
	
	# Choose content type based on rules and consciousness
	var content_type = choose_content_type()
	var success = false
	
	match content_type:
		"terrain":
			success = generate_terrain(chunk)
		"vegetation":
			success = generate_vegetation(chunk)
		"structures":
			success = generate_structures(chunk)
		"beings":
			success = generate_beings(chunk)
		"artifacts":
			success = generate_artifacts(chunk)
	
	if success:
		# Consume energy and log
		generation_energy -= 20.0
		log_generation(chunk, content_type)
		content_generated.emit(chunk, content_type, null)
		
		if generation_energy <= 0:
			generation_energy_depleted.emit()
	else:
		generation_failed.emit(chunk, "Failed to generate " + content_type)

func choose_content_type() -> String:
	"""Choose what type of content to generate"""
	var total_weight = 0.0
	var weights = {}
	
	for content_type in content_types:
		var probability_key = content_type + "_probability"
		var weight = generation_rules.get(probability_key, 0.1)
		weights[content_type] = weight
		total_weight += weight
	
	var random_value = randf() * total_weight
	var current_weight = 0.0
	
	for content_type in weights.keys():
		current_weight += weights[content_type]
		if random_value <= current_weight:
			return content_type
	
	return content_types[0] if content_types.size() > 0 else "terrain"

# ===== SPECIFIC GENERATION METHODS =====

func generate_terrain(chunk: Node) -> bool:
	"""Generate terrain features in the chunk"""
	print("🏔️ Generating terrain in %s" % chunk.name)
	
	# Create basic terrain based on chunk position
	if chunk.has_method("add_stored_data"):
		chunk.add_stored_data("terrain_generated", {
			"type": "basic_terrain",
			"generator": host_being.name,
			"timestamp": Time.get_ticks_msec()
		})
	
	return true

func generate_vegetation(chunk: Node) -> bool:
	"""Generate vegetation in the chunk"""
	print("🌱 Generating vegetation in %s" % chunk.name)
	
	# Could create actual tree/plant Universal Beings
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var plant = SystemBootstrap.create_universal_being()
		if plant:
			plant.being_type = "plant"
			plant.being_name = "Generated Plant"
			plant.consciousness_level = 1
			
			# Add to chunk
			if chunk.has_method("add_being_to_chunk"):
				chunk.add_being_to_chunk(plant)
			else:
				chunk.add_child(plant)
			
			return true
	
	return false

func generate_structures(chunk: Node) -> bool:
	"""Generate structures in the chunk"""
	print("🏗️ Generating structures in %s" % chunk.name)
	
	# Could create building/structure Universal Beings
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var structure = SystemBootstrap.create_universal_being()
		if structure:
			structure.being_type = "structure"
			structure.being_name = "Generated Structure"
			structure.consciousness_level = 1
			
			# Add to chunk
			if chunk.has_method("add_being_to_chunk"):
				chunk.add_being_to_chunk(structure)
			else:
				chunk.add_child(structure)
			
			return true
	
	return false

func generate_beings(chunk: Node) -> bool:
	"""Generate conscious beings in the chunk"""
	print("👥 Generating beings in %s" % chunk.name)
	
	# Create a basic Universal Being
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var being = SystemBootstrap.create_universal_being()
		if being:
			being.being_type = "generated_being"
			being.being_name = "Chunk Inhabitant"
			being.consciousness_level = randi_range(1, 3)
			
			# Add to chunk
			if chunk.has_method("add_being_to_chunk"):
				chunk.add_being_to_chunk(being)
			else:
				chunk.add_child(being)
			
			return true
	
	return false

func generate_artifacts(chunk: Node) -> bool:
	"""Generate special artifacts in the chunk"""
	print("✨ Generating artifacts in %s" % chunk.name)
	
	# Create artifact Universal Being
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var artifact = SystemBootstrap.create_universal_being()
		if artifact:
			artifact.being_type = "artifact"
			artifact.being_name = "Mysterious Artifact"
			artifact.consciousness_level = randi_range(2, 4)
			
			# Add special properties
			if artifact.has_method("set"):
				artifact.set("is_artifact", true)
				artifact.set("artifact_power", randf_range(0.5, 2.0))
			
			# Add to chunk
			if chunk.has_method("add_being_to_chunk"):
				chunk.add_being_to_chunk(artifact)
			else:
				chunk.add_child(artifact)
			
			return true
	
	return false

# ===== UTILITY FUNCTIONS =====

func log_generation(chunk: Node, content_type: String) -> void:
	"""Log generation activity"""
	generation_history.append({
		"chunk": chunk.name if chunk else "unknown",
		"content_type": content_type,
		"timestamp": Time.get_ticks_msec(),
		"generator": host_being.name if host_being else "unknown",
		"energy_used": 20.0
	})
	
	# Keep history limited
	if generation_history.size() > 50:
		generation_history = generation_history.slice(-25)

func get_generation_capability() -> Dictionary:
	"""Get current generation capabilities"""
	return {
		"content_types": content_types,
		"generation_rate": generation_rate,
		"generation_energy": generation_energy,
		"consciousness_influence": consciousness_influence,
		"auto_generate": auto_generate,
		"generation_history_count": generation_history.size()
	}

# ===== AI INTERFACE =====

func generate_chunk_content(chunk: Node, content_type: String = "") -> bool:
	"""AI/Player command to generate content"""
	if not chunk:
		return false
	
	if content_type == "":
		content_type = choose_content_type()
	
	if content_type in content_types:
		current_chunk = chunk
		generate_content_in_chunk(chunk)
		return true
	
	return false

func set_auto_generation(enabled: bool) -> void:
	"""Enable/disable automatic generation"""
	auto_generate = enabled
	print("🎨 Auto generation: %s" % ("enabled" if enabled else "disabled"))

func recharge_generation_energy() -> void:
	"""Instantly recharge generation energy"""
	generation_energy = 100.0
	print("🔋 Generation energy recharged!")

# ===== PENTAGON CLEANUP =====

func pentagon_sewers() -> void:
	"""Clean up before removal"""
	# Save any important generation data
	if host_being and generation_history.size() > 0:
		print("🎨 Generator component detaching from %s with %d generations logged" % [host_being.name, generation_history.size()])