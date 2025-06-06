# ==================================================
# SCRIPT NAME: UniversalBeingDNA.gd
# DESCRIPTION: Universal Being DNA/Blueprint system for cloning, evolution, and creation
# PURPOSE: Encode all aspects of a Universal Being into analyzable, reusable blueprints
# CREATED: 2025-06-03 - Universal Being Evolution
# ==================================================

extends Resource
class_name UniversalBeingDNA

# ===== DNA STRUCTURE =====

## Core Identity
@export var being_uuid: String = ""
@export var being_name: String = ""
@export var being_type: String = ""
@export var consciousness_level: int = 0
@export var creation_timestamp: int = 0

## Genetic Markers
@export var species: String = "universal_being"
@export var generation: int = 1
@export var parent_lineage: Array[String] = []
@export var evolutionary_traits: Dictionary = {}
@export var adaptation_history: Array[Dictionary] = []

## Physical Structure
@export var scene_path: String = ""
@export var scene_structure: Dictionary = {}
@export var component_list: Array[String] = []
@export var socket_configuration: Dictionary = {}
@export var visual_layer: int = 0

## Behavioral Patterns
@export var state_preferences: Dictionary = {}
@export var interaction_patterns: Dictionary = {}
@export var learning_data: Dictionary = {}
@export var memory_patterns: Dictionary = {}

## Consciousness Profile
@export var consciousness_signature: Dictionary = {}
@export var resonance_frequencies: Array[float] = []
@export var evolution_potential: Dictionary = {}
@export var transcendence_markers: Array[String] = []

## Creation Capabilities
@export var can_create: Array[String] = []
@export var creation_templates: Dictionary = {}
@export var offspring_patterns: Dictionary = {}
@export var mutation_rates: Dictionary = {}

## Scene Analysis (for beings that control scenes)
@export var scene_analysis: Dictionary = {}
@export var node_catalog: Dictionary = {}
@export var interaction_points: Array[Dictionary] = []
@export var modifiable_elements: Dictionary = {}

## AI Integration
@export var ai_accessible: bool = true
@export var ai_modification_rights: Dictionary = {}
@export var collaboration_history: Array[Dictionary] = []

# ===== DNA ANALYSIS METHODS =====

func analyze_being(being: UniversalBeing) -> void:
	"""Extract complete DNA from a Universal Being"""
	print("🧬 Analyzing DNA of: %s" % being.being_name)
	
	# Core identity
	being_uuid = being.being_uuid
	being_name = being.being_name
	being_type = being.being_type
	consciousness_level = being.consciousness_level
	creation_timestamp = Time.get_ticks_msec()
	
	# Extract genetic markers
	_extract_genetic_markers(being)
	
	# Analyze scene structure if loaded
	if being.scene_is_loaded and being.controlled_scene:
		_analyze_scene_structure(being)
	
	# Extract behavioral patterns
	_analyze_behavioral_patterns(being)
	
	# Analyze consciousness profile
	_analyze_consciousness_profile(being)
	
	# Extract creation capabilities
	_analyze_creation_capabilities(being)
	
	# Extract component system
	_analyze_component_system(being)
	
	print("🧬 DNA analysis complete - %d traits catalogued" % get_total_trait_count())

func _extract_genetic_markers(being: UniversalBeing) -> void:
	"""Extract genetic and evolutionary information"""
	evolutionary_traits = {
		"base_form": being.being_type,
		"current_state": being._state_to_string(being.current_state),
		"state_history_length": being.state_history.size(),
		"evolution_count": being.evolution_state.get("evolution_count", 0),
		"last_evolution": being.evolution_state.get("last_evolution", 0),
		"can_become": being.evolution_state.get("can_become", []),
		"is_composite": being.is_composite,
		"has_physics": being.physics_enabled,
		"interaction_radius": being.interaction_radius
	}
	
	# Extract parent lineage if available
	if being.metadata.has("parent_uuid"):
		parent_lineage.append(being.metadata.parent_uuid)
	
	# Calculate generation
	generation = parent_lineage.size() + 1

func _analyze_scene_structure(being: UniversalBeing) -> void:
	"""Analyze the structure of a loaded scene"""
	print("🧬 Analyzing scene structure: %s" % being.scene_path)
	
	scene_path = being.scene_path
	scene_analysis = {
		"scene_name": being.controlled_scene.name,
		"scene_class": being.controlled_scene.get_class(),
		"node_count": being.scene_nodes.size(),
		"property_changes": being.scene_properties.size(),
		"analyzable_components": [],
		"extractable_features": [],
		"reusable_patterns": []
	}
	
	# Catalog all nodes
	_catalog_scene_nodes(being.controlled_scene, "")
	
	# Identify interaction points
	_identify_interaction_points(being)
	
	# Analyze modifiable elements
	_analyze_modifiable_elements(being)
	
	# Extract reusable patterns
	_extract_scene_patterns(being)

func _catalog_scene_nodes(node: Node, path_prefix: String = "") -> void:
	"""Catalog all nodes in the scene for DNA"""
	var node_info = {
		"name": node.name,
		"class": node.get_class(),
		"path": path_prefix + node.name,
		"properties": {},
		"signals": [],
		"methods": [],
		"children_count": node.get_children().size(),
		"is_reusable": true
	}
	
	# Extract key properties
	var property_list = node.get_property_list()
	for prop in property_list:
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			node_info.properties[prop.name] = {
				"type": prop.type,
				"value": node.get(prop.name) if node.has_method("get") else null
			}
	
	# Extract available signals
	var signal_list = node.get_signal_list()
	for signal_info in signal_list:
		node_info.signals.append(signal_info.name)
	
	# Extract methods
	var method_list = node.get_method_list()
	for method_info in method_list:
		if not method_info.name.begins_with("_"):  # Skip private methods
			node_info.methods.append(method_info.name)
	
	# Determine if node is reusable for evolution
	node_info.is_reusable = _is_node_reusable(node)
	
	node_catalog[node_info.path] = node_info
	
	# Recursively catalog children
	for child in node.get_children():
		_catalog_scene_nodes(child, path_prefix + node.name + "/")

func _is_node_reusable(node: Node) -> bool:
	"""Determine if a node can be reused in evolution"""
	var reusable_classes = [
		"Control", "Button", "Label", "LineEdit", "TextEdit",
		"MeshInstance3D", "CollisionShape3D", "Area3D", "RigidBody3D",
		"Camera3D", "Light3D", "DirectionalLight3D", "PointLight3D",
		"AudioStreamPlayer", "AnimationPlayer", "Timer"
	]
	
	for reusable_class in reusable_classes:
		if node.is_class(reusable_class):
			return true
	
	return false

func _identify_interaction_points(being: UniversalBeing) -> void:
	"""Identify points where other beings can interact with this scene"""
	for node_path in being.scene_nodes:
		var node = being.scene_nodes[node_path]
		if not node:
			continue
		
		var interaction_point = {
			"node_path": node_path,
			"node_name": node.name,
			"interaction_type": "unknown",
			"accessibility": "public",
			"parameters": {}
		}
		
		# Determine interaction type based on node class
		if node.is_class("Button"):
			interaction_point.interaction_type = "clickable"
			interaction_point.parameters = {"text": node.text if node.has_method("get") else ""}
		elif node.is_class("LineEdit") or node.is_class("TextEdit"):
			interaction_point.interaction_type = "text_input"
			interaction_point.parameters = {"placeholder": node.placeholder_text if node.has_method("get") else ""}
		elif node.is_class("Area3D"):
			interaction_point.interaction_type = "spatial_trigger"
			interaction_point.parameters = {"collision_enabled": true}
		elif node.is_class("Camera3D"):
			interaction_point.interaction_type = "viewpoint"
			interaction_point.parameters = {"fov": node.fov if node.has_method("get") else 60}
		
		if interaction_point.interaction_type != "unknown":
			interaction_points.append(interaction_point)

func _analyze_modifiable_elements(being: UniversalBeing) -> void:
	"""Analyze which elements can be modified for evolution"""
	for node_path in being.scene_nodes:
		var node = being.scene_nodes[node_path]
		if not node:
			continue
		
		var modifications = []
		
		# Check for modifiable properties
		if node.is_class("Control"):
			modifications.append_array(["position", "size", "modulate", "visible"])
		if node.is_class("MeshInstance3D"):
			modifications.append_array(["mesh", "material_override", "transform"])
		if node.is_class("Label") or node.is_class("Button"):
			modifications.append_array(["text", "font_size", "font_color"])
		if node.is_class("Light3D"):
			modifications.append_array(["light_energy", "light_color"])
		
		if not modifications.is_empty():
			modifiable_elements[node_path] = {
				"node_class": node.get_class(),
				"modifiable_properties": modifications,
				"current_values": {},
				"evolution_potential": _calculate_evolution_potential(node, modifications)
			}

func _extract_scene_patterns(being: UniversalBeing) -> void:
	"""Extract reusable patterns from the scene"""
	var patterns = []
	
	# Pattern: UI Layout
	var ui_nodes = []
	for node_path in being.scene_nodes:
		var node = being.scene_nodes[node_path]
		if node and node.is_class("Control"):
			ui_nodes.append(node_path)
	
	if ui_nodes.size() > 1:
		patterns.append({
			"pattern_type": "ui_layout",
			"pattern_name": "Control Layout Pattern",
			"nodes_involved": ui_nodes,
			"replication_difficulty": "easy",
			"evolution_value": "high"
		})
	
	# Pattern: 3D Mesh System
	var mesh_nodes = []
	for node_path in being.scene_nodes:
		var node = being.scene_nodes[node_path]
		if node and node.is_class("MeshInstance3D"):
			mesh_nodes.append(node_path)
	
	if mesh_nodes.size() > 0:
		patterns.append({
			"pattern_type": "3d_visual",
			"pattern_name": "3D Mesh Visualization",
			"nodes_involved": mesh_nodes,
			"replication_difficulty": "medium",
			"evolution_value": "high"
		})
	
	scene_analysis.reusable_patterns = patterns

func _analyze_behavioral_patterns(being: UniversalBeing) -> void:
	"""Analyze behavioral patterns and preferences"""
	state_preferences = {
		"current_state": being._state_to_string(being.current_state),
		"time_in_current_state": being.state_timer,
		"state_transitions": being.state_history.size(),
		"preferred_states": _calculate_preferred_states(being),
		"state_durations": {}
	}
	
	interaction_patterns = {
		"nearby_beings_count": being.nearby_beings.size(),
		"interaction_partners_count": being.interaction_partners.size(),
		"collision_responsiveness": being.physics_enabled,
		"proximity_sensitivity": being.interaction_radius,
		"social_tendency": _calculate_social_tendency(being)
	}

func _analyze_consciousness_profile(being: UniversalBeing) -> void:
	"""Analyze consciousness-related characteristics"""
	consciousness_signature = {
		"level": being.consciousness_level,
		"color_signature": being._get_consciousness_color(),
		"aura_radius": 32 + 8 * being.consciousness_level,
		"visual_layer": being.visual_layer,
		"awakening_timestamp": being.metadata.get("created_at", 0)
	}
	
	# Calculate resonance frequencies
	resonance_frequencies = []
	for level in range(8):  # 0-7 consciousness levels
		var frequency = _calculate_resonance_frequency(being.consciousness_level, level)
		resonance_frequencies.append(frequency)
	
	evolution_potential = {
		"can_evolve": being.consciousness_level < 7,
		"evolution_readiness": _calculate_evolution_readiness(being),
		"transcendence_markers": _identify_transcendence_markers(being),
		"growth_rate": _calculate_growth_rate(being)
	}

func _analyze_creation_capabilities(being: UniversalBeing) -> void:
	"""Analyze what this being can create"""
	can_create = []
	creation_templates = {}
	
	# Determine creation capabilities based on consciousness level
	match being.consciousness_level:
		0, 1:
			can_create = ["simple_offspring"]
		2, 3:
			can_create = ["simple_offspring", "basic_tools"]
		4, 5:
			can_create = ["simple_offspring", "basic_tools", "complex_structures"]
		6, 7:
			can_create = ["simple_offspring", "basic_tools", "complex_structures", "new_universes"]
	
	# Extract creation templates from components
	for component_path in being.components:
		var template_info = {
			"component_path": component_path,
			"template_type": _determine_component_type(component_path),
			"replication_cost": _calculate_replication_cost(component_path),
			"mutation_potential": _calculate_mutation_potential(component_path)
		}
		creation_templates[component_path] = template_info

func _analyze_component_system(being: UniversalBeing) -> void:
	"""Analyze the component system"""
	component_list = being.components.duplicate()
	
	if being.socket_manager:
		socket_configuration = being.socket_manager.get_socket_configuration()

# ===== DNA UTILITY METHODS =====

func _calculate_preferred_states(being: UniversalBeing) -> Array[String]:
	# Calculate which states this being prefers
	# Simple heuristic based on consciousness level
	var preferred: Array[String] = []
	
	if being.consciousness_level >= 3:
		preferred.append("THINKING")
	if being.consciousness_level >= 4:
		preferred.append("CREATING")
	if being.consciousness_level >= 5:
		preferred.append("TRANSCENDING")
	
	return preferred

func _calculate_social_tendency(being: UniversalBeing) -> String:
	"""Calculate social interaction tendency"""
	var nearby_count = being.nearby_beings.size()
	var interaction_count = being.interaction_partners.size()
	
	if interaction_count > 2:
		return "highly_social"
	elif interaction_count > 0:
		return "social"
	elif nearby_count > 0:
		return "somewhat_social"
	else:
		return "solitary"

func _calculate_resonance_frequency(own_level: int, other_level: int) -> float:
	"""Calculate resonance frequency with another consciousness level"""
	var level_difference = abs(own_level - other_level)
	return 1.0 - (level_difference / 7.0)

func _calculate_evolution_readiness(being: UniversalBeing) -> float:
	"""Calculate how ready this being is for evolution"""
	var readiness = 0.0
	
	# Base readiness from consciousness level
	readiness += being.consciousness_level * 0.1
	
	# Bonus for interaction experience
	readiness += being.interaction_partners.size() * 0.05
	
	# Bonus for state variety
	readiness += being.state_history.size() * 0.01
	
	return clamp(readiness, 0.0, 1.0)

func _identify_transcendence_markers(being: UniversalBeing) -> Array[String]:
	# Identify markers indicating potential for transcendence
	var markers: Array[String] = []
	
	if being.consciousness_level >= 6:
		markers.append("high_consciousness")
	if being.interaction_partners.size() > 3:
		markers.append("high_social_activity")
	if being.components.size() > 5:
		markers.append("complex_component_system")
	if being.evolution_state.evolution_count > 3:
		markers.append("evolution_veteran")
	
	return markers

func _calculate_growth_rate(being: UniversalBeing) -> float:
	"""Calculate the growth rate of this being"""
	var creation_time = being.metadata.get("created_at", Time.get_ticks_msec())
	var age = Time.get_ticks_msec() - creation_time
	var age_seconds = age / 1000.0
	
	if age_seconds > 0:
		return being.consciousness_level / age_seconds
	return 0.0

func _calculate_evolution_potential(node: Node, modifications: Array) -> float:
	"""Calculate evolution potential for a specific node"""
	var potential = modifications.size() * 0.1
	
	# Bonus for interactive nodes
	if node.is_class("Button") or node.is_class("Area3D"):
		potential += 0.3
	
	# Bonus for visual nodes
	if node.is_class("MeshInstance3D") or node.is_class("Control"):
		potential += 0.2
	
	return clamp(potential, 0.0, 1.0)

func _determine_component_type(component_path: String) -> String:
	"""Determine the type of a component from its path"""
	var filename = component_path.get_file().to_lower()
	
	if "visual" in filename or "mesh" in filename or "sprite" in filename:
		return "visual"
	elif "behavior" in filename or "ai" in filename:
		return "behavioral"
	elif "interaction" in filename:
		return "interactive"
	elif "sound" in filename or "audio" in filename:
		return "audio"
	else:
		return "utility"

func _calculate_replication_cost(component_path: String) -> float:
	"""Calculate the cost to replicate a component"""
	# Simple heuristic based on component type
	var component_type = _determine_component_type(component_path)
	
	match component_type:
		"visual": return 0.3
		"behavioral": return 0.7
		"interactive": return 0.5
		"audio": return 0.4
		"utility": return 0.2
		_: return 0.5

func _calculate_mutation_potential(component_path: String) -> float:
	"""Calculate mutation potential for a component"""
	var component_type = _determine_component_type(component_path)
	
	match component_type:
		"visual": return 0.8  # High mutation potential
		"behavioral": return 0.6
		"interactive": return 0.7
		"audio": return 0.5
		"utility": return 0.3
		_: return 0.5

# ===== DNA OPERATIONS =====

func get_total_trait_count() -> int:
	"""Get total number of catalogued traits"""
	var count = 0
	count += evolutionary_traits.size()
	count += scene_analysis.size()
	count += node_catalog.size()
	count += interaction_points.size()
	count += modifiable_elements.size()
	count += state_preferences.size()
	count += interaction_patterns.size()
	count += consciousness_signature.size()
	count += creation_templates.size()
	return count

func get_evolution_blueprint() -> Dictionary:
	"""Get blueprint for evolving this being"""
	return {
		"base_dna": self,
		"mutation_points": _identify_mutation_points(),
		"evolution_paths": _calculate_evolution_paths(),
		"required_resources": _calculate_evolution_requirements(),
		"success_probability": _calculate_evolution_success_rate()
	}

func _identify_mutation_points() -> Array[Dictionary]:
	"""Identify points where mutations can occur"""
	var mutation_points = []
	
	# Consciousness level mutations
	mutation_points.append({
		"type": "consciousness",
		"current_value": consciousness_level,
		"mutation_range": [max(0, consciousness_level - 1), min(7, consciousness_level + 2)],
		"mutation_probability": 0.7
	})
	
	# Component mutations
	for component_path in component_list:
		mutation_points.append({
			"type": "component",
			"component": component_path,
			"mutation_type": "variation",
			"mutation_probability": _calculate_mutation_potential(component_path)
		})
	
	# Scene structure mutations (if applicable)
	if not scene_path.is_empty():
		mutation_points.append({
			"type": "scene_structure",
			"current_scene": scene_path,
			"mutation_type": "node_modification",
			"mutation_probability": 0.5
		})
	
	return mutation_points

func _calculate_evolution_paths() -> Array[Dictionary]:
	"""Calculate possible evolution paths"""
	var paths = []
	
	# Consciousness evolution path
	if consciousness_level < 7:
		paths.append({
			"path_type": "consciousness_ascension",
			"target_level": consciousness_level + 1,
			"requirements": ["high_interaction", "stable_state"],
			"probability": evolution_potential.get("evolution_readiness", 0.0)
		})
	
	# Specialization paths based on current traits
	if "high_social_activity" in transcendence_markers:
		paths.append({
			"path_type": "social_specialist",
			"target_traits": ["enhanced_interaction", "group_coordination"],
			"requirements": ["multiple_partners", "communication_components"],
			"probability": 0.6
		})
	
	# Scene-based evolution (if scene is loaded)
	if not scene_path.is_empty():
		paths.append({
			"path_type": "scene_master",
			"target_traits": ["enhanced_scene_control", "multi_scene_management"],
			"requirements": ["scene_experience", "modification_history"],
			"probability": 0.4
		})
	
	return paths

func _calculate_evolution_requirements() -> Dictionary:
	"""Calculate what's needed for evolution"""
	return {
		"consciousness_energy": consciousness_level * 10,
		"interaction_experience": 5,
		"component_stability": component_list.size() * 2,
		"time_investment": 30.0,  # seconds
		"collaboration_support": consciousness_level >= 4
	}

func _calculate_evolution_success_rate() -> float:
	"""Calculate probability of successful evolution"""
	var base_rate = 0.3
	
	# Consciousness level bonus
	base_rate += consciousness_level * 0.05
	
	# Component system bonus
	base_rate += component_list.size() * 0.02
	
	# Social interaction bonus
	base_rate += len(transcendence_markers) * 0.1
	
	# Experience bonus
	base_rate += evolutionary_traits.get("evolution_count", 0) * 0.05
	
	return clamp(base_rate, 0.1, 0.9)

func create_clone_blueprint() -> Dictionary:
	"""Create a blueprint for cloning this being"""
	return {
		"dna_source": self,
		"clone_type": "exact_copy",
		"modifications": {},
		"inheritance_factors": {
			"consciousness_inheritance": 0.8,  # 80% of original consciousness
			"component_inheritance": 1.0,      # All components
			"scene_inheritance": 1.0,          # Full scene if applicable
			"memory_inheritance": 0.3          # Limited memory transfer
		},
		"clone_cost": _calculate_clone_cost(),
		"clone_time": _calculate_clone_time()
	}

func _calculate_clone_cost() -> float:
	"""Calculate resource cost for cloning"""
	var base_cost = consciousness_level * 5
	base_cost += component_list.size() * 2
	base_cost += node_catalog.size() * 0.5
	return base_cost

func _calculate_clone_time() -> float:
	"""Calculate time needed for cloning"""
	var base_time = 10.0  # seconds
	base_time += consciousness_level * 2.0
	base_time += component_list.size() * 1.0
	return base_time

func save_to_file(file_path: String) -> bool:
	"""Save DNA to file"""
	var result = ResourceSaver.save(self, file_path)
	if result == OK:
		print("🧬 DNA saved to: %s" % file_path)
		return true
	else:
		print("🧬 Failed to save DNA: %s" % file_path)
		return false

static func load_from_file(file_path: String) -> UniversalBeingDNA:
	"""Load DNA from file"""
	if FileAccess.file_exists(file_path):
		var dna = load(file_path) as UniversalBeingDNA
		if dna:
			print("🧬 DNA loaded from: %s" % file_path)
			return dna
	
	print("🧬 Failed to load DNA: %s" % file_path)
	return null

func get_summary() -> String:
	"""Get a human-readable summary of this DNA"""
	var summary = []
	summary.append("🧬 === UNIVERSAL BEING DNA SUMMARY ===")
	summary.append("Name: %s" % being_name)
	summary.append("Type: %s" % being_type)
	summary.append("Consciousness: Level %d" % consciousness_level)
	summary.append("Generation: %d" % generation)
	summary.append("Total Traits: %d" % get_total_trait_count())
	
	if not scene_path.is_empty():
		summary.append("Controlled Scene: %s" % scene_path.get_file())
		summary.append("Scene Nodes: %d" % node_catalog.size())
	
	summary.append("Components: %d" % component_list.size())
	summary.append("Evolution Readiness: %.1f%%" % (evolution_potential.get("evolution_readiness", 0.0) * 100))
	
	if not transcendence_markers.is_empty():
		summary.append("Transcendence Markers: %s" % ", ".join(transcendence_markers))
	
	return "\n".join(summary)
