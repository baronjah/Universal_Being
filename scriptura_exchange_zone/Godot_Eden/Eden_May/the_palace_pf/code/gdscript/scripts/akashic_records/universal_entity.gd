extends Node
class_name UniversalEntity

# Core identity properties
var entity_id: String = ""
var entity_type: String = "primordial" # Base type from which all things evolve
var previous_types: Array = [] # History of transformations
var creation_timestamp: int = 0

# Transformation and evolution properties
var evolution_stage: int = 0
var transformation_energy: float = 0.0
var transformation_threshold: float = 100.0
var can_transform: bool = true

# Core properties that all entities share
var properties: Dictionary = {
	"essence": 1.0,      # Fundamental essence/energy
	"stability": 1.0,    # How stable this form is
	"resonance": 0.5,    # How it resonates with other entities
	"complexity": 0.0    # Level of complexity (increases with evolution)
}

# State system
var state: Dictionary = {
	"current": "stable",
	"previous": "",
	"locked": false
}

# Interaction rules
var interaction_rules: Dictionary = {}

# Spatial properties
var position: Vector3 = Vector3.ZERO
var scale: Vector3 = Vector3.ONE

# Relationship tracking
var connected_entities: Array = []
var parent_entity: String = ""
var child_entities: Array = []

# Database references
var dictionary_entry: String = ""
var zone_id: String = ""

# Signals
signal entity_transformed(old_type, new_type)
signal entity_property_changed(property_name, old_value, new_value)
signal entity_state_changed(old_state, new_state)
signal entity_connected(other_entity_id)
signal entity_disconnected(other_entity_id)

# Initialize the entity
func initialize(id: String, type: String = "primordial", pos: Vector3 = Vector3.ZERO, init_properties: Dictionary = {}) -> void:
	entity_id = id
	entity_type = type
	position = pos
	creation_timestamp = Time.get_ticks_msec()
	
	# Apply any provided properties
	for key in init_properties:
		set_property(key, init_properties[key])
	
	# Set complexity based on type
	if type == "primordial":
		properties["complexity"] = 0.0
	else:
		properties["complexity"] = 0.1 * (1 + randf())
	
	print("Entity initialized: " + entity_id + " of type " + entity_type)

# Transform entity to a new type while preserving core identity
func transform(new_type: String, transformation_properties: Dictionary = {}) -> bool:
	if not can_transform or state.locked:
		print("Entity cannot transform: locked or transformation disabled")
		return false
	
	if transformation_energy < transformation_threshold:
		print("Entity lacks transformation energy: " + str(transformation_energy) + "/" + str(transformation_threshold))
		return false
	
	# Store previous type
	previous_types.append(entity_type)
	
	# Record old type for signal
	var old_type = entity_type
	
	# Change to new type
	entity_type = new_type
	
	# Apply transformation properties
	for key in transformation_properties:
		set_property(key, transformation_properties[key])
	
	# Update complexity
	properties["complexity"] += 0.1 + randf() * 0.2
	properties["complexity"] = min(properties["complexity"], 1.0)
	
	# Reset transformation energy
	transformation_energy = 0.0
	
	# Increase evolution stage
	evolution_stage += 1
	
	# Emit signal
	emit_signal("entity_transformed", old_type, new_type)
	
	print("Entity transformed: " + entity_id + " from " + old_type + " to " + new_type)
	return true

# Revert to previous form
func revert_to_previous() -> bool:
	if previous_types.size() == 0:
		print("Entity has no previous type to revert to")
		return false
	
	if not can_transform or state.locked:
		print("Entity cannot transform: locked or transformation disabled")
		return false
	
	# Get previous type
	var previous_type = previous_types.pop_back()
	
	# Record current type
	var old_type = entity_type
	
	# Change to previous type
	entity_type = previous_type
	
	# Decrease complexity
	properties["complexity"] = max(0.0, properties["complexity"] - 0.15)
	
	# Decrease evolution stage
	evolution_stage = max(0, evolution_stage - 1)
	
	# Emit signal
	emit_signal("entity_transformed", old_type, previous_type)
	
	print("Entity reverted: " + entity_id + " from " + old_type + " to " + previous_type)
	return true

# Revert all the way to primordial state
func revert_to_primordial() -> bool:
	if entity_type == "primordial":
		print("Entity is already in primordial state")
		return false
	
	if not can_transform or state.locked:
		print("Entity cannot transform: locked or transformation disabled")
		return false
	
	# Record current type
	var old_type = entity_type
	
	# Store all previous types
	previous_types.append(entity_type)
	
	# Change to primordial type
	entity_type = "primordial"
	
	# Reset complexity
	properties["complexity"] = 0.0
	
	# Reset evolution stage
	evolution_stage = 0
	
	# Reset transformation energy
	transformation_energy = 0.0
	
	# Emit signal
	emit_signal("entity_transformed", old_type, "primordial")
	
	print("Entity reverted to primordial: " + entity_id)
	return true

# Get a property value
func get_property(property_name: String, default_value = null):
	if properties.has(property_name):
		return properties[property_name]
	return default_value

# Set a property value
func set_property(property_name: String, value) -> void:
	var old_value = properties.get(property_name, null)
	properties[property_name] = value
	emit_signal("entity_property_changed", property_name, old_value, value)

# Change entity state
func change_state(new_state: String) -> bool:
	if state.locked:
		print("Entity state is locked and cannot be changed")
		return false
	
	var old_state = state.current
	state.previous = old_state
	state.current = new_state
	
	emit_signal("entity_state_changed", old_state, new_state)
	print("Entity state changed: " + entity_id + " from " + old_state + " to " + new_state)
	return true

# Lock/unlock state changes
func lock_state(locked: bool) -> void:
	state.locked = locked

# Connect to another entity
func connect_to(other_entity_id: String) -> bool:
	if connected_entities.has(other_entity_id):
		return false
	
	connected_entities.append(other_entity_id)
	emit_signal("entity_connected", other_entity_id)
	return true

# Disconnect from an entity
func disconnect_from(other_entity_id: String) -> bool:
	if not connected_entities.has(other_entity_id):
		return false
	
	connected_entities.erase(other_entity_id)
	emit_signal("entity_disconnected", other_entity_id)
	return true

# Add transformation energy
func add_transformation_energy(amount: float) -> void:
	transformation_energy += amount
	transformation_energy = min(transformation_energy, transformation_threshold * 2)

# Process interaction with another entity
func interact_with(other_entity, context: Dictionary = {}) -> Dictionary:
	var result = {
		"success": false,
		"type": "none",
		"effects": [],
		"transformation": null
	}
	
	# Basic interaction logic - more complex rules would be in the interaction_rules dictionary
	var resonance_combined = properties["resonance"] + other_entity.get_property("resonance", 0.5)
	var stability_combined = properties["stability"] + other_entity.get_property("stability", 1.0)
	var complexity_diff = abs(properties["complexity"] - other_entity.get_property("complexity", 0.0))
	
	# Determine basic interaction type
	if resonance_combined > 1.5:
		result["type"] = "harmony"
		result["success"] = true
		
		# Add transformation energy to both entities
		add_transformation_energy(10.0)
		other_entity.add_transformation_energy(10.0)
		
		result["effects"].append("energy_transfer")
		
		# Possible connection
		if randf() > 0.5:
			if connect_to(other_entity.entity_id):
				result["effects"].append("connection_formed")
	
	elif stability_combined < 1.0:
		result["type"] = "instability"
		result["success"] = true
		
		# Possible state change
		if randf() > 0.7:
			if change_state("unstable"):
				result["effects"].append("state_changed")

	elif complexity_diff > 0.5:
		result["type"] = "complexity_exchange"
		result["success"] = true

		# Transfer some complexity
		var transfer = min(0.1, complexity_diff * 0.2)

		if properties["complexity"] > other_entity.get_property("complexity", 0.0):
			set_property("complexity", properties["complexity"] - transfer)
			other_entity.set_property("complexity", other_entity.get_property("complexity", 0.0) + transfer)
		else:
			set_property("complexity", properties["complexity"] + transfer)
			other_entity.set_property("complexity", other_entity.get_property("complexity", 0.0) - transfer)
		
		result["effects"].append("complexity_transfer")
	
	else:
		result["type"] = "neutral"
		result["success"] = true
	
	# Check for transformation threshold
	if transformation_energy >= transformation_threshold:
		result["transformation"] = {
			"possible": true,
			"entity_id": entity_id,
			"current_type": entity_type,
			"potential_types": _get_potential_transformations()
		}
	
	return result

# Get potential transformation types
func _get_potential_transformations() -> Array:
	# This would normally be determined by the dictionary/word system
	# For now, return a placeholder
	return ["element", "particle", "wave", "form"]

# Serialize entity to dictionary
func to_dictionary() -> Dictionary:
	return {
		"id": entity_id,
		"type": entity_type,
		"previous_types": previous_types.duplicate(),
		"creation_timestamp": creation_timestamp,
		"evolution_stage": evolution_stage,
		"transformation_energy": transformation_energy,
		"transformation_threshold": transformation_threshold,
		"can_transform": can_transform,
		"properties": properties.duplicate(),
		"state": state.duplicate(),
		"position": {
			"x": position.x,
			"y": position.y,
			"z": position.z
		},
		"scale": {
			"x": scale.x,
			"y": scale.y,
			"z": scale.z
		},
		"connected_entities": connected_entities.duplicate(),
		"parent_entity": parent_entity,
		"child_entities": child_entities.duplicate(),
		"dictionary_entry": dictionary_entry,
		"zone_id": zone_id
	}

# Create entity from dictionary
static func from_dictionary(data: Dictionary) -> UniversalEntity:
	var entity = UniversalEntity.new()
	
	entity.entity_id = data.get("id", "")
	entity.entity_type = data.get("type", "primordial")
	entity.previous_types = data.get("previous_types", []).duplicate()
	entity.creation_timestamp = data.get("creation_timestamp", 0)
	entity.evolution_stage = data.get("evolution_stage", 0)
	entity.transformation_energy = data.get("transformation_energy", 0.0)
	entity.transformation_threshold = data.get("transformation_threshold", 100.0)
	entity.can_transform = data.get("can_transform", true)
	
	# Load properties
	if data.has("properties"):
		entity.properties = data.properties.duplicate()
	
	# Load state
	if data.has("state"):
		entity.state = data.state.duplicate()
	
	# Load position and scale
	if data.has("position"):
		entity.position = Vector3(
			data.position.get("x", 0.0),
			data.position.get("y", 0.0),
			data.position.get("z", 0.0)
		)
	
	if data.has("scale"):
		entity.scale = Vector3(
			data.scale.get("x", 1.0),
			data.scale.get("y", 1.0),
			data.scale.get("z", 1.0)
		)
	
	# Load relationships
	entity.connected_entities = data.get("connected_entities", []).duplicate()
	entity.parent_entity = data.get("parent_entity", "")
	entity.child_entities = data.get("child_entities", []).duplicate()
	
	# Load references
	entity.dictionary_entry = data.get("dictionary_entry", "")
	entity.zone_id = data.get("zone_id", "")
	
	return entity