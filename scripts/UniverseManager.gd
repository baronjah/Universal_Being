# ==================================================
# UNIVERSE MANAGER - The Architect of Infinite Realities
# PURPOSE: Create, manage, and navigate between universes
# LOCATION: core/systems/UniverseManager.gd
# ==================================================

extends Node
class_name UniverseManager

## Universe registry
var universes: Dictionary = {} # uuid -> Universe
var active_universe: Universe
var universe_stack: Array[Universe] = [] # For nested universe navigation

## Universe class definition
class Universe:
	var uuid: String
	var name: String
	var parent_universe: Universe
	var child_universes: Array[Universe] = []
	var beings: Array[Node] = []
	var reality_rules: Dictionary = {
		"physics_gravity": 9.8,
		"time_scale": 1.0,
		"lod_distance": 100.0,
		"max_beings": 1000,
		"consciousness_enabled": true,
		"evolution_rate": 1.0
	}
	var creation_timestamp: float
	var metadata: Dictionary = {}
	var scene_root: Node3D

signal universe_created(universe: Universe)
signal universe_entered(universe: Universe)
signal universe_rule_changed(universe: Universe, rule: String, value: Variant)
signal universe_destroyed(universe: Universe)

func _ready() -> void:
	# Create the prime universe
	var prime = create_universe("Prime Universe", null, {
		"description": "The first reality, from which all others spring"
	})
	active_universe = prime
	
	# Log the genesis
	if has_node("/root/PoeticLogger"):
		get_node("/root/PoeticLogger").log_genesis(
			"In the beginning was the Prime Universe, and it was without form and void"
		)

## UNIVERSE CREATION ==================================================

func create_universe(name: String, parent: Universe = null, metadata: Dictionary = {}) -> Universe:
	"""Birth a new universe"""
	var universe = Universe.new()
	universe.uuid = _generate_uuid()
	universe.name = name
	universe.parent_universe = parent if parent else active_universe
	universe.creation_timestamp = Time.get_unix_time_from_system()
	universe.metadata = metadata
	
	# Create scene root for this universe
	universe.scene_root = Node3D.new()
	universe.scene_root.name = "Universe_" + universe.uuid
	
	# Register universe
	universes[universe.uuid] = universe
	
	# Add to parent's children
	if universe.parent_universe:
		universe.parent_universe.child_universes.append(universe)
	
	# Log the creation
	if has_node("/root/PoeticLogger"):
		get_node("/root/PoeticLogger").log_creation(
			"Universe '%s'" % name,
			"the creative will of %s" % [parent.name if parent else "the Void"],
			{"universe_id": universe.uuid}
		)
	
	universe_created.emit(universe)
	return universe
## UNIVERSE NAVIGATION ==================================================

func enter_universe(universe: Universe) -> void:
	"""Enter a universe, making it active"""
	if not universe in universes.values():
		push_error("Cannot enter unknown universe: " + universe.name)
		return
	
	# Push current universe to stack
	if active_universe:
		universe_stack.push_back(active_universe)
		_deactivate_universe(active_universe)
	
	# Activate new universe
	active_universe = universe
	_activate_universe(universe)
	
	# Log the transition
	if has_node("/root/PoeticLogger"):
		get_node("/root/PoeticLogger").log_genesis(
			"The consciousness descended into Universe '%s', reality shifting around it" % universe.name
		)
	
	universe_entered.emit(universe)

func exit_to_parent() -> bool:
	"""Exit current universe to its parent"""
	if not active_universe.parent_universe:
		return false # Cannot exit prime universe
	
	enter_universe(active_universe.parent_universe)
	return true

func exit_to_previous() -> bool:
	"""Return to previously active universe"""
	if universe_stack.is_empty():
		return false
	
	var previous = universe_stack.pop_back()
	enter_universe(previous)
	return true

## REALITY MANIPULATION ==================================================

func set_universe_rule(universe: Universe, rule: String, value: Variant) -> void:
	"""Modify the laws of a universe"""
	if not rule in universe.reality_rules:
		push_warning("Unknown reality rule: " + rule)
		return
	
	var old_value = universe.reality_rules[rule]
	universe.reality_rules[rule] = value
	
	# Apply the change
	_apply_reality_rule(universe, rule, value)
	
	# Log the change
	if has_node("/root/PoeticLogger"):
		get_node("/root/PoeticLogger").log_reality_change(
			rule,
			str(value),
			"the Universe Architect",
			{"universe": universe.name, "old_value": old_value}
		)
	
	universe_rule_changed.emit(universe, rule, value)

func get_universe_info(universe: Universe) -> Dictionary:
	"""Get comprehensive information about a universe"""
	return {
		"uuid": universe.uuid,
		"name": universe.name,
		"parent": universe.parent_universe.name if universe.parent_universe else "None",
		"children": universe.child_universes.size(),
		"beings": universe.beings.size(),
		"rules": universe.reality_rules.duplicate(),
		"age": Time.get_unix_time_from_system() - universe.creation_timestamp,
		"metadata": universe.metadata
	}

func get_universe_tree() -> Dictionary:
	"""Get the entire multiverse tree structure"""
	var tree = {}
	
	# Find root universes (no parent)
	for uuid in universes:
		var universe = universes[uuid]
		if not universe.parent_universe:
			tree[universe.name] = _build_universe_subtree(universe)
	
	return tree

## UNIVERSE LIFECYCLE ==================================================

func destroy_universe(universe: Universe, recursive: bool = true) -> void:
	"""Destroy a universe and optionally its children"""
	if universe == active_universe:
		push_error("Cannot destroy active universe")
		return
	
	# Destroy children first if recursive
	if recursive:
		for child in universe.child_universes:
			destroy_universe(child, true)
	
	# Remove from parent's children
	if universe.parent_universe:
		universe.parent_universe.child_universes.erase(universe)
	
	# Clean up beings
	for being in universe.beings:
		being.queue_free()
	
	# Remove scene root
	if universe.scene_root:
		universe.scene_root.queue_free()
	
	# Remove from registry
	universes.erase(universe.uuid)
	
	# Log the destruction
	if has_node("/root/PoeticLogger"):
		get_node("/root/PoeticLogger").log_genesis(
			"Universe '%s' collapsed back into the void from whence it came" % universe.name
		)
	
	universe_destroyed.emit(universe)
## HELPER FUNCTIONS ==================================================

func _activate_universe(universe: Universe) -> void:
	"""Activate a universe's scene and rules"""
	# Add scene to tree
	if universe.scene_root and not universe.scene_root.is_inside_tree():
		get_tree().root.add_child(universe.scene_root)
	
	# Apply all reality rules
	for rule in universe.reality_rules:
		_apply_reality_rule(universe, rule, universe.reality_rules[rule])

func _deactivate_universe(universe: Universe) -> void:
	"""Deactivate a universe's scene"""
	# Remove scene from tree but don't destroy
	if universe.scene_root and universe.scene_root.is_inside_tree():
		universe.scene_root.get_parent().remove_child(universe.scene_root)

func _apply_reality_rule(universe: Universe, rule: String, value: Variant) -> void:
	"""Apply a reality rule to the universe"""
	match rule:
		"physics_gravity":
			if universe == active_universe:
				ProjectSettings.set_setting("physics/3d/default_gravity", value)
		"time_scale":
			if universe == active_universe:
				Engine.time_scale = value
		"lod_distance":
			# Apply to all beings in universe
			for being in universe.beings:
				if being.has_method("set_lod_distance"):
					being.set_lod_distance(value)
		"consciousness_enabled":
			# Toggle AI/consciousness for all beings
			for being in universe.beings:
				if being.has_method("set_consciousness_active"):
					being.set_consciousness_active(value)
		"evolution_rate":
			# Adjust evolution speed for all beings
			for being in universe.beings:
				if being.has_method("set_evolution_rate"):
					being.set_evolution_rate(value)

func _build_universe_subtree(universe: Universe) -> Dictionary:
	"""Recursively build universe tree structure"""
	var subtree = {
		"uuid": universe.uuid,
		"beings": universe.beings.size(),
		"rules": universe.reality_rules.size(),
		"children": {}
	}
	
	for child in universe.child_universes:
		subtree.children[child.name] = _build_universe_subtree(child)
	
	return subtree

func _generate_uuid() -> String:
	"""Generate unique universe identifier"""
	# Simple UUID v4 implementation
	var uuid = ""
	for i in range(32):
		if i in [8, 12, 16, 20]:
			uuid += "-"
		uuid += "0123456789abcdef"[randi() % 16]
	return uuid

## UNIVERSE QUERIES ==================================================

func find_universe_by_name(name: String) -> Universe:
	"""Find universe by name (searches all universes)"""
	for uuid in universes:
		if universes[uuid].name == name:
			return universes[uuid]
	return null

func get_universe_by_uuid(uuid: String) -> Universe:
	"""Get universe by UUID"""
	return universes.get(uuid, null)

func get_all_universes() -> Array[Universe]:
	"""Get all universes in the multiverse"""
	var all_universes: Array[Universe] = []
	for uuid in universes:
		all_universes.append(universes[uuid])
	return all_universes

func get_universe_ancestors(universe: Universe) -> Array[Universe]:
	"""Get all parent universes up to root"""
	var ancestors: Array[Universe] = []
	var current = universe.parent_universe
	
	while current:
		ancestors.append(current)
		current = current.parent_universe
	
	return ancestors

func get_universe_depth(universe: Universe) -> int:
	"""Get nesting depth of universe (0 = root)"""
	return get_universe_ancestors(universe).size()

## BEING MANAGEMENT ==================================================

func register_being_to_universe(being: Node, universe: Universe = null) -> void:
	"""Register a being to a universe"""
	if not universe:
		universe = active_universe
	
	universe.beings.append(being)
	
	# Parent being to universe scene
	if universe.scene_root:
		being.reparent(universe.scene_root)

func unregister_being_from_universe(being: Node, universe: Universe = null) -> void:
	"""Remove being from universe registry"""
	if not universe:
		universe = active_universe
	
	universe.beings.erase(being)

func transfer_being_between_universes(being: Node, from_universe: Universe, to_universe: Universe) -> void:
	"""Move being from one universe to another"""
	unregister_being_from_universe(being, from_universe)
	register_being_to_universe(being, to_universe)
	
	# Log the transfer
	if has_node("/root/PoeticLogger"):
		get_node("/root/PoeticLogger").log_genesis(
			"Being '%s' transcended from Universe '%s' to Universe '%s'" % [
				being.name, from_universe.name, to_universe.name
			]
		)