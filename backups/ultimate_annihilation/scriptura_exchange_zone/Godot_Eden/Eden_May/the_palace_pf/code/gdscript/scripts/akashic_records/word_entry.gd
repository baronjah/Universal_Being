extends Resource
class_name WordEntry

# Basic identification
@export var id: String = ""
@export var category: String = ""
@export var parent_id: String = ""
@export var children: Array[String] = []
@export var usage_count: int = 0
@export var last_used: int = 0  # Unix timestamp

# Content
@export var properties: Dictionary = {}
@export var states: Dictionary = {}
@export var current_state: String = ""
@export var interactions: Dictionary = {}
@export var file_reference: String = ""
@export var variants: Array[Resource] = []  # Array of WordEntry variants

# Initialization
func _init(p_id: String = "", p_category: String = ""):
	id = p_id
	category = p_category

# Serialization
func from_dict(data: Dictionary) -> void:
	id = data.get("id", "")
	category = data.get("category", "")
	parent_id = data.get("parent_id", "")
	
	# Handle children array
	children = []
	for child in data.get("children", []):
		children.append(child)
	
	# Usage statistics
	usage_count = data.get("usage_count", 0)
	last_used = data.get("last_used", 0)
	
	# Handle properties
	properties = data.get("properties", {}).duplicate()
	
	# Handle states
	states = data.get("states", {}).duplicate()
	
	# Set default state
	current_state = ""
	for state in states:
		if states[state].get("default", false):
			current_state = state
			break
	
	# Handle interactions
	interactions = data.get("interactions", {}).duplicate()
	file_reference = data.get("file_reference", "")
	
	# Variants will be handled separately since they're references to other WordEntry objects

func to_dict() -> Dictionary:
	var variant_ids = []
	for variant in variants:
		if variant is WordEntry:
			variant_ids.append(variant.id)
	
	return {
		"id": id,
		"category": category,
		"parent_id": parent_id,
		"children": children,
		"usage_count": usage_count,
		"last_used": last_used,
		"properties": properties,
		"states": states,
		"current_state": current_state,
		"interactions": interactions,
		"file_reference": file_reference,
		"variant_ids": variant_ids
	}

# Child management
func add_child(child_id: String) -> void:
	if not children.has(child_id):
		children.append(child_id)

func remove_child(child_id: String) -> void:
	if children.has(child_id):
		children.erase(child_id)

# State management
func get_current_state() -> String:
	return current_state

func change_state(new_state: String) -> bool:
	if not states.has(new_state):
		return false
	
	current_state = new_state
	
	# Apply state properties
	var state_props = states[new_state].get("properties", {})
	for prop in state_props:
		properties[prop] = state_props[prop]
	
	return true

# Interaction management
func add_interaction_rule(target_id: String, result_id: String, conditions: Dictionary = {}) -> void:
	interactions[target_id] = {
		"result": result_id,
		"conditions": conditions
	}

func get_interaction_result(target_id: String) -> Dictionary:
	if interactions.has(target_id):
		return interactions[target_id]
	return {}

func evaluate_conditions(conditions: Dictionary, context: Dictionary) -> bool:
	# Handle empty conditions - always succeed
	if conditions.is_empty():
		return true
	
	for condition_key in conditions:
		var condition_value = conditions[condition_key]
		var context_value = context.get(condition_key, null)
		
		# Skip if context doesn't have this value
		if context_value == null:
			continue
		
		# Handle comparison operators in string form
		if condition_value is String:
			if condition_value.begins_with(">"):
				var compare_value = float(condition_value.substr(1).strip_edges())
				if not (context_value is float or context_value is int) or context_value <= compare_value:
					return false
			elif condition_value.begins_with("<"):
				var compare_value = float(condition_value.substr(1).strip_edges())
				if not (context_value is float or context_value is int) or context_value >= compare_value:
					return false
			elif condition_value.begins_with("!="):
				var compare_value = condition_value.substr(2).strip_edges()
				if str(context_value) == compare_value:
					return false
			elif condition_value.begins_with("=="):
				var compare_value = condition_value.substr(2).strip_edges()
				if str(context_value) != compare_value:
					return false
			elif context_value != condition_value:
				return false
		# Direct comparison for non-string condition values
		elif context_value != condition_value:
			return false
	
	return true

# Usage tracking
func record_usage() -> void:
	usage_count += 1
	last_used = Time.get_unix_time_from_system()

# Evolution methods
func evolve_properties(influence_factor: float = 0.1) -> void:
	# Gradually change properties based on usage and randomness
	for prop in properties:
		if properties[prop] is float:
			# Add some random drift
			var drift = (randf() - 0.5) * influence_factor
			properties[prop] = clamp(properties[prop] + drift, 0.0, 1.0)

# Variant handling
func add_variant(variant: WordEntry) -> void:
	if not variants.has(variant):
		variants.append(variant)
		variant.parent_id = id

func get_variants() -> Array[Resource]:
	return variants

func has_variants() -> bool:
	return not variants.is_empty()

# Utility functions
func is_related_to(other_word: WordEntry) -> bool:
	return parent_id == other_word.id or other_word.parent_id == id or children.has(other_word.id) or other_word.children.has(id)

func calculate_similarity(other_word: WordEntry) -> float:
	if properties.is_empty() or other_word.properties.is_empty():
		return 0.0
	
	var similarity = 0.0
	var common_props = 0
	
	for prop in properties:
		if other_word.properties.has(prop):
			var my_value = properties[prop]
			var other_value = other_word.properties[prop]
			
			if my_value is float and other_value is float:
				similarity += 1.0 - abs(my_value - other_value)
				common_props += 1
	
	if common_props == 0:
		return 0.0
	
	return similarity / common_props