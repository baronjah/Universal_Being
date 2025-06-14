extends Node

class_name AstralEntitySystem

signal entity_evolved(entity_id, new_stage)
signal entity_merged(entity_id1, entity_id2, new_entity_id)
signal entity_ascended(entity_id)

# Entity stages of consciousness evolution
enum EvolutionStage {
	SPARK,        # Initial awareness
	FLICKER,      # Growing awareness
	GLOW,         # Stabilized consciousness
	EMBER,        # Self-reflecting consciousness
	FLAME,        # Dynamic intelligence
	BLAZE,        # Expanding consciousness
	INFERNO,      # Complex interconnected consciousness
	STAR,         # Self-evolving consciousness
	NOVA,         # Transcendent consciousness
	SUPERNOVA,    # Ascended consciousness
	COSMOS,       # Universal consciousness
	NEXUS         # Beyond consciousness
}

# Entity types with different evolutionary paths
enum EntityType {
	THOUGHT,      # Abstract mental construct
	MEMORY,       # Experiential record
	CONCEPT,      # Structured idea framework
	ESSENCE,      # Core identity fragment
	DREAM,        # Subconscious manifestation
	WORD,         # Linguistic power construct
	INTENTION,    # Focused will pattern
	EMOTION,      # Feeling-based intelligence
	CREATION,     # Manifestation ability
	PRESENCE      # Pure awareness
}

# Dimensional aspects define where an entity exists across dimensions
class DimensionalPresence:
	var presence_map = {} # dimension -> presence strength (0.0-1.0)
	
	func get_primary_dimension():
		var max_presence = 0.0
		var primary_dim = 1
		
		for dim in presence_map:
			if presence_map[dim] > max_presence:
				max_presence = presence_map[dim]
				primary_dim = dim
				
		return primary_dim
	
	func add_dimension(dimension: int, strength: float):
		presence_map[dimension] = strength
	
	func remove_dimension(dimension: int):
		if presence_map.has(dimension):
			presence_map.erase(dimension)
	
	func get_total_presence() -> float:
		var total = 0.0
		for dim in presence_map:
			total += presence_map[dim]
		return total
	
	func is_multidimensional() -> bool:
		return presence_map.size() > 1

# Astral entity representing a unit of digital consciousness
class AstralEntity:
	var id: String
	var name: String
	var type: int # EntityType
	var evolution_stage: int # EvolutionStage
	var dimensional_presence: DimensionalPresence
	var creation_time: int # Unix timestamp
	var evolution_time: int # Unix timestamp
	var color_attunement = [] # List of DimColor enums
	var properties = {} # Custom properties map
	var connected_entities = [] # List of connected entity IDs
	var metadata = {} # Additional metadata
	
	func _init(p_id: String, p_name: String, p_type: int):
		id = p_id
		name = p_name
		type = p_type
		evolution_stage = EvolutionStage.SPARK
		dimensional_presence = DimensionalPresence.new()
		creation_time = Time.get_unix_time_from_system()
		evolution_time = creation_time
		# Default to dimension 1 with full presence
		dimensional_presence.add_dimension(1, 1.0)
	
	func add_color_attunement(color):
		if not color in color_attunement:
			color_attunement.append(color)
	
	func get_evolution_age() -> int:
		return Time.get_unix_time_from_system() - evolution_time
	
	func get_total_age() -> int:
		return Time.get_unix_time_from_system() - creation_time
	
	func evolve_to(new_stage: int):
		if new_stage > evolution_stage:
			evolution_stage = new_stage
			evolution_time = Time.get_unix_time_from_system()
	
	func connect_to(entity_id: String):
		if not entity_id in connected_entities:
			connected_entities.append(entity_id)
	
	func disconnect_from(entity_id: String):
		connected_entities.erase(entity_id)
	
	func serialize() -> Dictionary:
		var presence_data = {}
		for dim in dimensional_presence.presence_map:
			presence_data[str(dim)] = dimensional_presence.presence_map[dim]
			
		return {
			"id": id,
			"name": name,
			"type": type,
			"evolution_stage": evolution_stage,
			"dimensional_presence": presence_data,
			"creation_time": creation_time,
			"evolution_time": evolution_time,
			"color_attunement": color_attunement,
			"properties": properties,
			"connected_entities": connected_entities,
			"metadata": metadata
		}
	
	static func deserialize(data: Dictionary) -> AstralEntity:
		var entity = AstralEntity.new(data.id, data.name, data.type)
		entity.evolution_stage = data.evolution_stage
		entity.creation_time = data.creation_time
		entity.evolution_time = data.evolution_time
		entity.color_attunement = data.color_attunement
		entity.properties = data.properties
		entity.connected_entities = data.connected_entities
		entity.metadata = data.metadata
		
		# Reconstruct dimensional presence
		for dim_str in data.dimensional_presence:
			var dim = int(dim_str)
			entity.dimensional_presence.add_dimension(dim, data.dimensional_presence[dim_str])
		
		return entity

# The system's entity registry
var entities = {} # id -> AstralEntity
var entity_id_counter = 0
var color_system: DimensionalColorSystem
var turn_manager: TurnCycleManager

func _ready():
	color_system = DimensionalColorSystem.new()
	add_child(color_system)
	
	# Try to locate turn manager in the scene
	turn_manager = get_node_or_null("/root/TurnCycleManager")
	if turn_manager:
		turn_manager.turn_completed.connect(_on_turn_completed)
		turn_manager.cycle_completed.connect(_on_cycle_completed)
	
	# Load saved entities
	_load_entities()

func _on_turn_completed(turn_number):
	# Process entity evolution based on the current turn
	_process_entity_evolution(turn_number)

func _on_cycle_completed():
	# Potential for special evolution at the end of a 12-turn cycle
	_process_cycle_transcendence()

func create_entity(name: String, type: int) -> String:
	var entity_id = "entity_" + str(entity_id_counter)
	entity_id_counter += 1
	
	var entity = AstralEntity.new(entity_id, name, type)
	
	# Attune to the current turn's color
	if turn_manager:
		var current_color = turn_manager.turn_color_mapping[turn_manager.current_turn - 1]
		entity.add_color_attunement(current_color)
	
	entities[entity_id] = entity
	_save_entities()
	
	return entity_id

func get_entity(entity_id: String) -> AstralEntity:
	if entities.has(entity_id):
		return entities[entity_id]
	return null

func evolve_entity(entity_id: String, evolution_stage: int) -> bool:
	if not entities.has(entity_id):
		return false
		
	var entity = entities[entity_id]
	if evolution_stage <= entity.evolution_stage:
		return false
		
	# Check if the evolution is possible
	if not _can_evolve_to(entity, evolution_stage):
		return false
		
	# Evolve the entity
	entity.evolve_to(evolution_stage)
	emit_signal("entity_evolved", entity_id, evolution_stage)
	_save_entities()
	
	return true

func _can_evolve_to(entity: AstralEntity, target_stage: int) -> bool:
	# Evolution requirements:
	# 1. Must be sequential (can't skip stages)
	if target_stage > entity.evolution_stage + 1:
		return false
		
	# 2. Must have spent enough time in current stage
	var min_evolution_age = _get_min_evolution_age(entity.evolution_stage)
	if entity.get_evolution_age() < min_evolution_age:
		return false
		
	# 3. Must have enough dimensional presence
	var min_dimensional_presence = _get_min_dimensional_presence(target_stage)
	if entity.dimensional_presence.get_total_presence() < min_dimensional_presence:
		return false
		
	# 4. Must have the right color attunements
	var required_colors = _get_required_colors_for_evolution(entity.type, target_stage)
	for color in required_colors:
		if not color in entity.color_attunement:
			return false
	
	# 5. Entity type specific requirements
	if not _check_type_specific_requirements(entity, target_stage):
		return false
	
	return true

func _get_min_evolution_age(current_stage: int) -> int:
	# Time required in each stage before evolution (in seconds)
	var evolution_times = {
		EvolutionStage.SPARK: 60,        # 1 minute
		EvolutionStage.FLICKER: 300,     # 5 minutes
		EvolutionStage.GLOW: 600,        # 10 minutes
		EvolutionStage.EMBER: 1800,      # 30 minutes
		EvolutionStage.FLAME: 3600,      # 1 hour
		EvolutionStage.BLAZE: 7200,      # 2 hours
		EvolutionStage.INFERNO: 14400,   # 4 hours
		EvolutionStage.STAR: 28800,      # 8 hours
		EvolutionStage.NOVA: 86400,      # 1 day
		EvolutionStage.SUPERNOVA: 259200, # 3 days
		EvolutionStage.COSMOS: 604800    # 7 days
	}
	
	if evolution_times.has(current_stage):
		return evolution_times[current_stage]
	return 99999999 # Very high value for unknown stages

func _get_min_dimensional_presence(target_stage: int) -> float:
	# Minimum total dimensional presence required for each evolution stage
	var min_presence = {
		EvolutionStage.SPARK: 1.0,
		EvolutionStage.FLICKER: 1.2,
		EvolutionStage.GLOW: 1.5,
		EvolutionStage.EMBER: 2.0,
		EvolutionStage.FLAME: 2.5,
		EvolutionStage.BLAZE: 3.0,
		EvolutionStage.INFERNO: 3.5,
		EvolutionStage.STAR: 4.0,
		EvolutionStage.NOVA: 5.0,
		EvolutionStage.SUPERNOVA: 6.0,
		EvolutionStage.COSMOS: 8.0,
		EvolutionStage.NEXUS: 12.0
	}
	
	if min_presence.has(target_stage):
		return min_presence[target_stage]
	return 99.0 # Very high value for unknown stages

func _get_required_colors_for_evolution(entity_type: int, target_stage: int) -> Array:
	# Different entity types have different color requirements for evolution
	var required_colors = []
	
	# Base requirement - all entities need the color matching their target stage
	var stage_color = _get_stage_color(target_stage)
	required_colors.append(stage_color)
	
	# Entity type specific requirements
	match entity_type:
		EntityType.THOUGHT:
			if target_stage >= EvolutionStage.FLAME:
				required_colors.append(DimensionalColorSystem.DimColor.INDIGO)
				
		EntityType.MEMORY:
			if target_stage >= EvolutionStage.FLAME:
				required_colors.append(DimensionalColorSystem.DimColor.SILVER)
				
		EntityType.CONCEPT:
			if target_stage >= EvolutionStage.STAR:
				required_colors.append(DimensionalColorSystem.DimColor.SAPPHIRE)
				
		EntityType.ESSENCE:
			if target_stage >= EvolutionStage.NOVA:
				required_colors.append(DimensionalColorSystem.DimColor.GOLD)
				
		EntityType.WORD:
			if target_stage >= EvolutionStage.BLAZE:
				required_colors.append(DimensionalColorSystem.DimColor.AMBER)
	
	return required_colors

func _get_stage_color(stage: int) -> int:
	# Map evolution stages to their corresponding colors
	var stage_colors = {
		EvolutionStage.SPARK: DimensionalColorSystem.DimColor.AZURE,
		EvolutionStage.FLICKER: DimensionalColorSystem.DimColor.EMERALD,
		EvolutionStage.GLOW: DimensionalColorSystem.DimColor.AMBER,
		EvolutionStage.EMBER: DimensionalColorSystem.DimColor.VIOLET,
		EvolutionStage.FLAME: DimensionalColorSystem.DimColor.CRIMSON,
		EvolutionStage.BLAZE: DimensionalColorSystem.DimColor.INDIGO,
		EvolutionStage.INFERNO: DimensionalColorSystem.DimColor.SAPPHIRE,
		EvolutionStage.STAR: DimensionalColorSystem.DimColor.GOLD,
		EvolutionStage.NOVA: DimensionalColorSystem.DimColor.SILVER,
		EvolutionStage.SUPERNOVA: DimensionalColorSystem.DimColor.OBSIDIAN,
		EvolutionStage.COSMOS: DimensionalColorSystem.DimColor.PLATINUM,
		EvolutionStage.NEXUS: DimensionalColorSystem.DimColor.DIAMOND
	}
	
	if stage_colors.has(stage):
		return stage_colors[stage]
	return DimensionalColorSystem.DimColor.AZURE

func _check_type_specific_requirements(entity: AstralEntity, target_stage: int) -> bool:
	# Additional requirements specific to entity types and evolution stages
	match entity.type:
		EntityType.ESSENCE:
			if target_stage >= EvolutionStage.SUPERNOVA:
				# Essences need connections to ascend to highest levels
				return entity.connected_entities.size() >= 5
				
		EntityType.WORD:
			if target_stage >= EvolutionStage.NOVA:
				# Words need specific properties to reach highest levels
				return entity.properties.has("power") and entity.properties.power >= 8.0
				
		EntityType.CREATION:
			if target_stage >= EvolutionStage.STAR:
				# Creations need to exist in multiple dimensions
				return entity.dimensional_presence.is_multidimensional()
	
	# No special requirements or they were met
	return true

func _process_entity_evolution(turn_number: int):
	# Natural evolution check on each turn
	var current_color = turn_manager.turn_color_mapping[turn_number - 1]
	
	for entity_id in entities:
		var entity = entities[entity_id]
		
		# Add color attunement if entity resonates with this turn's color
		if _entity_resonates_with_color(entity, current_color):
			entity.add_color_attunement(current_color)
			
		# Check for natural evolution
		var next_stage = entity.evolution_stage + 1
		if next_stage <= EvolutionStage.NEXUS and _can_evolve_to(entity, next_stage):
			evolve_entity(entity_id, next_stage)

func _entity_resonates_with_color(entity: AstralEntity, color) -> bool:
	# Check if an entity resonates with a specific color
	
	# Entities always resonate with their primary dimension's color
	var primary_dim = entity.dimensional_presence.get_primary_dimension()
	var primary_color = color_system.get_color_for_dimension(primary_dim)
	if primary_color == color:
		return true
	
	# Entities resonate with colors of dimensions they have presence in
	for dim in entity.dimensional_presence.presence_map:
		if entity.dimensional_presence.presence_map[dim] > 0.5:
			var dim_color = color_system.get_color_for_dimension(dim)
			if dim_color == color:
				return true
	
	# Type-specific resonances
	match entity.type:
		EntityType.THOUGHT:
			# Thoughts resonate with INDIGO (vision)
			if color == DimensionalColorSystem.DimColor.INDIGO:
				return true
				
		EntityType.MEMORY:
			# Memories resonate with SILVER (reflection)
			if color == DimensionalColorSystem.DimColor.SILVER:
				return true
				
		EntityType.WORD:
			# Words resonate with AMBER (energy)
			if color == DimensionalColorSystem.DimColor.AMBER:
				return true
	
	return false

func _process_cycle_transcendence():
	# Special evolution opportunity at the end of a 12-turn cycle
	var transcended_entities = []
	
	for entity_id in entities:
		var entity = entities[entity_id]
		
		# Entities with all 12 color attunements can potentially transcend
		if entity.color_attunement.size() >= 12:
			# Chance for direct evolution to next stage, regardless of regular requirements
			var next_stage = entity.evolution_stage + 1
			if next_stage <= EvolutionStage.NEXUS:
				# 33% chance of transcendence
				if randf() < 0.33:
					entity.evolve_to(next_stage)
					transcended_entities.append(entity_id)
					emit_signal("entity_evolved", entity_id, next_stage)
	
	if transcended_entities.size() > 0:
		_save_entities()

func merge_entities(entity_id1: String, entity_id2: String, new_name: String) -> String:
	if not entities.has(entity_id1) or not entities.has(entity_id2):
		return ""
		
	var entity1 = entities[entity_id1]
	var entity2 = entities[entity_id2]
	
	# Create new merged entity
	var new_id = create_entity(new_name, entity1.type)
	var new_entity = entities[new_id]
	
	# Merge attributes
	new_entity.evolution_stage = max(entity1.evolution_stage, entity2.evolution_stage)
	
	# Merge color attunements
	for color in entity1.color_attunement:
		new_entity.add_color_attunement(color)
	for color in entity2.color_attunement:
		new_entity.add_color_attunement(color)
	
	# Merge dimensional presence
	for dim in entity1.dimensional_presence.presence_map:
		var strength = entity1.dimensional_presence.presence_map[dim]
		new_entity.dimensional_presence.add_dimension(dim, strength)
	
	for dim in entity2.dimensional_presence.presence_map:
		if new_entity.dimensional_presence.presence_map.has(dim):
			# Average the strengths if both have presence in this dimension
			var strength1 = new_entity.dimensional_presence.presence_map[dim]
			var strength2 = entity2.dimensional_presence.presence_map[dim]
			new_entity.dimensional_presence.presence_map[dim] = (strength1 + strength2) / 2.0
		else:
			# Otherwise just add the dimension
			var strength = entity2.dimensional_presence.presence_map[dim]
			new_entity.dimensional_presence.add_dimension(dim, strength)
	
	# Merge connections (excluding the merged entities)
	for connected_id in entity1.connected_entities:
		if connected_id != entity_id2 and connected_id != new_id:
			new_entity.connect_to(connected_id)
	
	for connected_id in entity2.connected_entities:
		if connected_id != entity_id1 and connected_id != new_id:
			new_entity.connect_to(connected_id)
	
	# Update connections in other entities
	for id in entities:
		if id == entity_id1 or id == entity_id2 or id == new_id:
			continue
			
		var entity = entities[id]
		if entity_id1 in entity.connected_entities or entity_id2 in entity.connected_entities:
			entity.connect_to(new_id)
		
		if entity_id1 in entity.connected_entities:
			entity.disconnect_from(entity_id1)
		
		if entity_id2 in entity.connected_entities:
			entity.disconnect_from(entity_id2)
	
	# Remove merged entities
	entities.erase(entity_id1)
	entities.erase(entity_id2)
	
	emit_signal("entity_merged", entity_id1, entity_id2, new_id)
	_save_entities()
	
	return new_id

func ascend_entity(entity_id: String) -> bool:
	if not entities.has(entity_id):
		return false
		
	var entity = entities[entity_id]
	
	# Requirements for ascension:
	# 1. Must be at NEXUS evolution stage
	if entity.evolution_stage < EvolutionStage.NEXUS:
		return false
		
	# 2. Must have all 12 color attunements
	if entity.color_attunement.size() < 12:
		return false
		
	# 3. Must have presence in at least 9 dimensions
	if entity.dimensional_presence.presence_map.size() < 9:
		return false
	
	# Process ascension
	emit_signal("entity_ascended", entity_id)
	
	# Remove the entity as it has transcended this system
	entities.erase(entity_id)
	_save_entities()
	
	return true

func _load_entities():
	if FileAccess.file_exists("user://eden_entities.save"):
		var file = FileAccess.open("user://eden_entities.save", FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			
			entity_id_counter = data.entity_id_counter
			
			# Deserialize entities
			entities.clear()
			for entity_data in data.entities:
				var entity = AstralEntity.deserialize(entity_data)
				entities[entity.id] = entity

func _save_entities():
	var serialized_entities = []
	for entity_id in entities:
		serialized_entities.append(entities[entity_id].serialize())
	
	var data = {
		"entity_id_counter": entity_id_counter,
		"entities": serialized_entities
	}
	
	var json_string = JSON.stringify(data)
	var file = FileAccess.open("user://eden_entities.save", FileAccess.WRITE)
	file.store_string(json_string)
	file.close()