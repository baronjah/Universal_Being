# ==================================================
# SCRIPT NAME: FloodGates.gd
# DESCRIPTION: The Guardian of Scene Tree - Controls ALL Universal Being operations
# PURPOSE: No Universal Being can enter or leave the scene without going through FloodGates
# CREATED: 2025-06-01 - Universal Being Revolution
# AUTHOR: JSH + Claude Code + Luminus + Alpha
# ==================================================
extends Node
class_name FloodGates

# ===== FLOODGATE AUTHORITY =====

## System Limits
const MAX_BEINGS: int = 144  # Sacred number of maximum entities
const OPERATION_QUEUE_SIZE: int = 256

## Scene Tree Control
var registered_beings: Dictionary = {}  # UUID -> Node
var being_registry: Array[Node] = []
var parent_map: Dictionary = {}  # UUID -> parent_node
var operation_queue: Array[Dictionary] = []

## Authority State
var current_being_count: int = 0
var floodgate_active: bool = true
var operation_processing: bool = false
var authority_level: int = 10  # Highest authority in scene tree

## Processing Control
var process_frame_counter: int = 0
var max_operations_per_frame: int = 8

# ===== CORE SIGNALS =====

signal being_registered(being: Node)
signal being_unregistered(being: Node)
signal being_added_to_scene(being: Node, parent: Node)
signal being_removed_from_scene(being: Node)
signal being_evolved(old_being: Node, new_being: Node)
signal floodgate_limit_reached(count: int)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	print("🌊 FloodGates: Awakening scene tree guardian...")

func pentagon_ready() -> void:
	print("🌊 FloodGates: Authority established over scene tree")
	set_process(true)

func pentagon_process(delta: float) -> void:
	if operation_queue.size() > 0 and not operation_processing:
		process_operation_queue()

func pentagon_input(event: InputEvent) -> void:
	pass  # FloodGates doesn't handle direct input

func pentagon_sewers() -> void:
	# Clean up any orphaned beings
	cleanup_orphaned_beings()

# ===== UNIVERSAL BEING MANAGEMENT =====

func register_being(being: Node) -> bool:
	"""Register a Universal Being with FloodGates"""
	if not being or not is_instance_valid(being):
		push_error("🌊 FloodGates: Invalid being provided for registration")
		return false

	var being_uuid = being.get("being_uuid") if being.has_method("get") else ""
	
	# Handle missing or empty UUID
	if not being_uuid or being_uuid == "":
		push_warning("🌊 FloodGates: Being has no UUID - generating one")
		if being.has_method("generate_uuid"):
			being_uuid = being.generate_uuid()
			being.set("being_uuid", being_uuid)
		else:
			# Fallback UUID generation
			var time = Time.get_ticks_msec()
			var random = randi()
			being_uuid = "ub_%s_%s" % [time, random]
			if being.has_method("set"):
				being.set("being_uuid", being_uuid)
	
	if being_uuid in registered_beings:
		push_warning("🌊 FloodGates: Being already registered: " + str(being_uuid))
		return true

	if current_being_count >= MAX_BEINGS:
		floodgate_limit_reached.emit(current_being_count)
		push_error("🌊 FloodGates: Maximum beings reached (%d)" % MAX_BEINGS)
		return false

	# Register the being
	registered_beings[being_uuid] = being
	being_registry.append(being)
	current_being_count += 1

	being_registered.emit(being)
	var being_name = being.get("being_name") if being.has_method("get") else being.name
	print("🌊 FloodGates: Being registered - %s (%s)" % [being_name, being_uuid])
	return true

func unregister_being(being: Node) -> bool:
	"""Unregister a Universal Being from FloodGates"""
	if not being or not is_instance_valid(being):
		return false

	var being_uuid = being.get("being_uuid") if being.has_method("get") else ""
	if not being_uuid in registered_beings:
		push_warning("🌊 FloodGates: Being not registered for removal")
		return false

	# Remove from registry
	registered_beings.erase(being_uuid)
	being_registry.erase(being)
	current_being_count -= 1

	being_unregistered.emit(being)
	var being_name = being.get("being_name") if being.has_method("get") else being.name
	print("🌊 FloodGates: Being unregistered - %s" % being_name)
	return true

# ===== SCENE TREE OPERATIONS =====

func add_being_to_scene(being: Node, parent: Node, force_registration: bool = false) -> bool:
	"""Add a Universal Being to the scene tree through FloodGate authority"""
	if not being or not parent:
		push_error("🌊 FloodGates: Invalid being or parent for scene addition")
		return false

	# Register if not already registered
	if force_registration or not is_being_registered(being):
		if not register_being(being):
			return false

	# Queue the operation
	var operation = {
		"type": "add_to_scene",
		"being": being,
		"parent": parent,
		"timestamp": Time.get_ticks_msec()
	}
	
	operation_queue.append(operation)
	return true

func remove_being_from_scene(being: Node) -> bool:
	"""Remove a Universal Being from scene tree through FloodGate authority"""
	if not being or not is_instance_valid(being):
		return false

	var operation = {
		"type": "remove_from_scene",
		"being": being,
		"timestamp": Time.get_ticks_msec()
	}
	
	operation_queue.append(operation)
	return true

func move_being(being: Node, new_parent: Node) -> bool:
	"""Move a Universal Being to new parent through FloodGate authority"""
	if not being or not new_parent:
		push_error("🌊 FloodGates: Invalid being or new parent for move operation")
		return false

	var operation = {
		"type": "move_being",
		"being": being,
		"new_parent": new_parent,
		"timestamp": Time.get_ticks_msec()
	}
	
	operation_queue.append(operation)
	return true

# ===== OPERATION PROCESSING =====

func process_operation_queue() -> void:
	"""Process queued operations in controlled manner"""
	if operation_queue.size() == 0:
		return

	operation_processing = true
	var operations_this_frame = 0

	while operation_queue.size() > 0 and operations_this_frame < max_operations_per_frame:
		var operation = operation_queue.pop_front()
		execute_operation(operation)
		operations_this_frame += 1

	operation_processing = false

func execute_operation(operation: Dictionary) -> void:
	"""Execute a single FloodGate operation"""
	match operation.type:
		"add_to_scene":
			execute_add_to_scene(operation.being, operation.parent)
		"remove_from_scene":
			execute_remove_from_scene(operation.being)
		"move_being":
			execute_move_being(operation.being, operation.new_parent)

func execute_add_to_scene(being: Node, parent: Node) -> void:
	"""Execute scene addition operation"""
	if not being.get_parent():
		parent.add_child(being)
		var being_uuid = being.get("being_uuid") if being.has_method("get") else ""
		parent_map[being_uuid] = parent
		being_added_to_scene.emit(being, parent)

func execute_remove_from_scene(being: Node) -> void:
	"""Execute scene removal operation"""
	if being.get_parent():
		being.get_parent().remove_child(being)
		var being_uuid = being.get("being_uuid") if being.has_method("get") else ""
		parent_map.erase(being_uuid)
		being_removed_from_scene.emit(being)

func execute_move_being(being: Node, new_parent: Node) -> void:
	"""Execute being move operation"""
	if being.get_parent():
		being.get_parent().remove_child(being)
	new_parent.add_child(being)
	var being_uuid = being.get("being_uuid") if being.has_method("get") else ""
	parent_map[being_uuid] = new_parent

# ===== EVOLUTION SYSTEM =====

func evolve_being(old_being: Node, new_type: String) -> Node:
	"""Evolve a Universal Being into new form"""
	print("🌊 FloodGates: Evolution requested - %s to %s" % [old_being.name, new_type])
	
	# This would integrate with AkashicRecords for actual evolution
	# For now, placeholder
	var new_being = create_being_placeholder(new_type)
	if new_being:
		transfer_being_properties(old_being, new_being)
		being_evolved.emit(old_being, new_being)
	
	return new_being

func create_being_placeholder(being_type: String) -> Node:
	"""Create placeholder being of specified type"""
	var UniversalBeingClass = load("res://core/UniversalBeing.gd")
	if UniversalBeingClass:
		var new_being = UniversalBeingClass.new()
		new_being.name = "Evolved_" + being_type
		if new_being.has_method("set"):
			new_being.set("being_type", being_type)
			new_being.set("consciousness_level", 1)
		return new_being
	return null

func transfer_being_properties(old_being: Node, new_being: Node) -> void:
	"""Transfer properties during evolution"""
	if new_being.has_method("set") and old_being.has_method("get"):
		var consciousness = old_being.get("consciousness_level") if old_being.has_method("get") else 0
		var metadata = old_being.get("metadata") if old_being.has_method("get") else {}

		new_being.set("consciousness_level", consciousness)
		if metadata:
			var new_metadata = metadata.duplicate(true)
			new_metadata["modified_at"] = Time.get_ticks_msec()
			new_being.set("metadata", new_metadata)

# ===== QUERY FUNCTIONS =====

func get_being_count() -> int:
	"""Get current number of registered beings"""
	return current_being_count

func get_all_beings() -> Array[Node]:
	"""Get array of all registered beings"""
	return being_registry.duplicate()

func get_beings_by_type(type: String) -> Array[Node]:
	"""Get beings of specific type"""
	var result: Array[Node] = []
	for being in being_registry:
		var being_type = being.get("being_type") if being.has_method("get") else ""
		if being_type == type:
			result.append(being)
	return result

func is_being_registered(being: Node) -> bool:
	"""Check if being is registered with FloodGates"""
	var being_uuid = being.get("being_uuid") if being.has_method("get") else ""
	return being_uuid in registered_beings

func get_being_parent(being: Node) -> Node:
	"""Get parent of a registered being"""
	var being_uuid = being.get("being_uuid") if being.has_method("get") else ""
	return parent_map.get(being_uuid, null)

# ===== UTILITY FUNCTIONS =====

func cleanup_orphaned_beings() -> void:
	"""Clean up any beings that no longer exist"""
	var to_remove: Array[String] = []
	
	for uuid in registered_beings.keys():
		var being = registered_beings[uuid]
		if not is_instance_valid(being):
			to_remove.append(uuid)
	
	for uuid in to_remove:
		registered_beings.erase(uuid)
		current_being_count -= 1

func generate_uuid() -> String:
	"""Generate simple UUID for beings without one"""
	return "being_" + str(Time.get_ticks_msec()) + "_" + str(randi())

func get_floodgate_status() -> Dictionary:
	"""Get current FloodGate system status"""
	return {
		"active": floodgate_active,
		"being_count": current_being_count,
		"max_beings": MAX_BEINGS,
		"queue_size": operation_queue.size(),
		"authority_level": authority_level
	}


## underneath is virst version, over version from desktop









## ==================================================
## SCRIPT NAME: FloodGates.gd  
## DESCRIPTION: The Guardian of Scene Tree - Controls ALL Universal Being operations
## PURPOSE: No Universal Being can enter or leave the scene without going through FloodGates
## CREATED: 2025-06-01 - Universal Being Revolution
## AUTHOR: JSH + Claude Code + Luminus + Alpha
## ==================================================
#
#extends Node
#class_name FloodGates
#
## ===== FLOODGATE AUTHORITY =====
#
### Scene Tree Control
#var registered_beings: Dictionary = {}  # UUID -> UniversalBeing
#var being_registry: Array[Node] = []
#var parent_map: Dictionary = {}  # UUID -> parent_node
#var operation_queue: Array[Dictionary] = []
#
### Safety Limits
#const MAX_BEINGS: int = 144  # Sacred number
#const MAX_OPERATIONS_PER_FRAME: int = 10
#var current_being_count: int = 0
#
### Operation Types
#enum OperationType {
	#ADD_BEING,
	#REMOVE_BEING,
	#MOVE_BEING,
	#EVOLVE_BEING,
	#BATCH_OPERATION
#}
#
## ===== CORE SIGNALS =====
#
#signal being_registered(being: Node)
#signal being_unregistered(being: Node)
#signal being_added_to_scene(being: Node, parent: Node)
#signal being_removed_from_scene(being: Node)
#signal being_evolved(old_being: Node, new_being: Node)
#signal floodgate_limit_reached(count: int)
#
## ===== PENTAGON ARCHITECTURE =====
#
#func pentagon_init() -> void:
	#name = "FloodGates"
	#set_process(true)
#
#func pentagon_ready() -> void:
	#print("🌊 FloodGates initialized - Guardian of Universal Beings active")
#
#func pentagon_process(delta: float) -> void:
	#process_operation_queue()
#
#func pentagon_input(event: InputEvent) -> void:
	#pass
#
#func pentagon_sewers() -> void:
	## Emergency cleanup all beings
	#for being in being_registry:
		#if is_instance_valid(being):
			#emergency_remove_being(being)
#
## ===== UNIVERSAL BEING MANAGEMENT =====
#
#func register_being(being: Node) -> bool:
	#"""Register a Universal Being with FloodGates"""
	#if not being or not is_instance_valid(being):
		#push_error("🌊 FloodGates: Invalid being provided for registration")
		#return false
		#
	#var being_uuid = being.get("being_uuid") if being.has_method("get") else ""
	#if being_uuid in registered_beings:
		#push_warning("🌊 FloodGates: Being already registered: " + being_uuid)
		#return true
		#
	#if current_being_count >= MAX_BEINGS:
		#push_error("🌊 FloodGates: Maximum beings limit reached (%d)" % MAX_BEINGS)
		#floodgate_limit_reached.emit(current_being_count)
		#return false
	#
	## Register the being
	#registered_beings[being_uuid] = being
	#being_registry.append(being)
	#current_being_count += 1
	#
	#being_registered.emit(being)
	#var being_name = being.get("being_name") if being.has_method("get") else being.name
	#print("🌊 FloodGates: Being registered - %s (%s)" % [being_name, being_uuid])
	#return true
#
#func unregister_being(being: UniversalBeing) -> bool:
	#"""Unregister a Universal Being from FloodGates"""
	#if not being or being.being_uuid not in registered_beings:
		#return false
		#
	#registered_beings.erase(being.being_uuid)
	#being_registry.erase(being)
	#parent_map.erase(being.being_uuid)
	#current_being_count -= 1
	#
	#being_unregistered.emit(being)
	#print("🌊 FloodGates: Being unregistered - %s" % being.being_uuid)
	#return true
#
## ===== SCENE TREE OPERATIONS =====
#
#func add_being(being: UniversalBeing, parent: Node, immediate: bool = false) -> bool:
	#"""The ONLY way to add Universal Beings to scene tree"""
	#if not being or not parent:
		#push_error("🌊 FloodGates: Invalid being or parent for add operation")
		#return false
	#
	#if immediate:
		#return execute_add_being(being, parent)
	#else:
		#queue_operation({
			#"type": OperationType.ADD_BEING,
			#"being": being,
			#"parent": parent
		#})
		#return true
#
#func remove_being(being: UniversalBeing, immediate: bool = false) -> bool:
	#"""The ONLY way to remove Universal Beings from scene tree"""
	#if not being:
		#return false
		#
	#if immediate:
		#return execute_remove_being(being)
	#else:
		#queue_operation({
			#"type": OperationType.REMOVE_BEING,
			#"being": being
		#})
		#return true
#
#func move_being(being: UniversalBeing, new_parent: Node, immediate: bool = false) -> bool:
	#"""The ONLY way to reparent Universal Beings"""
	#if not being or not new_parent:
		#return false
		#
	#if immediate:
		#return execute_move_being(being, new_parent)
	#else:
		#queue_operation({
			#"type": OperationType.MOVE_BEING,
			#"being": being,
			#"new_parent": new_parent
		#})
		#return true
#
#func evolve_being(being: UniversalBeing, new_form_path: String) -> UniversalBeing:
	#"""The ONLY way to evolve Universal Beings"""
	#if not being or not new_form_path.ends_with(".ub.zip"):
		#return null
		#
	## Load new being from ZIP
	#var new_being = create_being_from_zip(new_form_path)
	#if not new_being:
		#return null
	#
	## Transfer properties
	#transfer_being_properties(being, new_being)
	#
	## Replace in scene
	#var parent = being.get_parent()
	#if parent:
		#remove_being(being, true)
		#add_being(new_being, parent, true)
	#
	#being_evolved.emit(being, new_being)
	#return new_being
#
## ===== OPERATION QUEUE SYSTEM =====
#
#func queue_operation(operation: Dictionary) -> void:
	#"""Queue an operation to be processed next frame"""
	#operation_queue.append(operation)
#
#func process_operation_queue() -> void:
	#"""Process queued operations with frame limit"""
	#var operations_this_frame = 0
	#
	#while operation_queue.size() > 0 and operations_this_frame < MAX_OPERATIONS_PER_FRAME:
		#var operation = operation_queue.pop_front()
		#execute_operation(operation)
		#operations_this_frame += 1
#
#func execute_operation(operation: Dictionary) -> bool:
	#"""Execute a single operation"""
	#match operation.type:
		#OperationType.ADD_BEING:
			#return execute_add_being(operation.being, operation.parent)
		#OperationType.REMOVE_BEING:
			#return execute_remove_being(operation.being)
		#OperationType.MOVE_BEING:
			#return execute_move_being(operation.being, operation.new_parent)
		#OperationType.EVOLVE_BEING:
			#evolve_being(operation.being, operation.new_form_path)
			#return true
		#_:
			#push_error("🌊 FloodGates: Unknown operation type")
			#return false
#
## ===== OPERATION IMPLEMENTATIONS =====
#
#func execute_add_being(being: UniversalBeing, parent: Node) -> bool:
	#"""Actually add being to scene tree"""
	#if not being.get_parent():
		#parent.add_child(being)
		#parent_map[being.being_uuid] = parent
		#being_added_to_scene.emit(being, parent)
		#print("🌊 FloodGates: Being added to scene - %s" % being.being_name)
		#return true
	#return false
#
#func execute_remove_being(being: UniversalBeing) -> bool:
	#"""Actually remove being from scene tree"""
	#if being.get_parent():
		#being.get_parent().remove_child(being)
		#parent_map.erase(being.being_uuid)
		#being_removed_from_scene.emit(being)
		#being.queue_free()
		#print("🌊 FloodGates: Being removed from scene - %s" % being.being_name)
		#return true
	#return false
#
#func execute_move_being(being: UniversalBeing, new_parent: Node) -> bool:
	#"""Actually move being to new parent"""
	#var old_parent = being.get_parent()
	#if old_parent:
		#old_parent.remove_child(being)
	#
	#new_parent.add_child(being)
	#parent_map[being.being_uuid] = new_parent
	#print("🌊 FloodGates: Being moved - %s" % being.being_name)
	#return true
#
#func emergency_remove_being(being: UniversalBeing) -> void:
	#"""Emergency removal without queue"""
	#if being and is_instance_valid(being):
		#if being.get_parent():
			#being.get_parent().remove_child(being)
		#being.queue_free()
#
## ===== BEING CREATION =====
#
#func create_being_from_zip(zip_path: String) -> Node:
	#"""Create a Universal Being from ZIP file"""
	#print("🌊 FloodGates: Creating being from ZIP (placeholder): " + zip_path)
	#
	## For now, create a basic Universal Being
	## TODO: Implement full ZIP loading through SystemBootstrap
	#var UniversalBeingClass = load("res://core/UniversalBeing.gd")
	#if UniversalBeingClass:
		#var being = UniversalBeingClass.new()
		#being.name = "ZIP Being"
		#if being.has_method("set"):
			#being.set("being_name", "ZIP Being")
			#being.set("being_type", "zip_loaded")
			#being.set("consciousness_level", 1)
		#return being
	#
	#return null
#
#func transfer_being_properties(old_being: Node, new_being: Node) -> void:
	#"""Transfer properties during evolution"""
	#if new_being.has_method("set") and old_being.has_method("get"):
		#var consciousness = old_being.get("consciousness_level") if old_being.has_method("get") else 0
		#var metadata = old_being.get("metadata") if old_being.has_method("get") else {}
		#
		#new_being.set("consciousness_level", consciousness)
		#if metadata:
			#var new_metadata = metadata.duplicate(true)
			#new_metadata["modified_at"] = Time.get_ticks_msec()
			#new_being.set("metadata", new_metadata)
#
## ===== QUERY FUNCTIONS =====
#
#func get_being_by_uuid(uuid: String) -> UniversalBeing:
	#"""Find being by UUID"""
	#return registered_beings.get(uuid, null)
#
#func get_beings_by_type(type: String) -> Array[UniversalBeing]:
	#"""Find all beings of specific type"""
	#var result: Array[UniversalBeing] = []
	#for being in being_registry:
		#if being.being_type == type:
			#result.append(being)
	#return result
#
#func get_all_beings() -> Array[UniversalBeing]:
	#"""Get all registered beings"""
	#return being_registry.duplicate()
#
#func get_being_count() -> int:
	#"""Get current being count"""
	#return current_being_count
#
#func get_being_hierarchy() -> Dictionary:
	#"""Get parent-child relationships"""
	#var hierarchy = {}
	#for being in being_registry:
		#var parent = being.get_parent()
		#if parent:
			#hierarchy[being.being_uuid] = parent.name
	#return hierarchy
#
## ===== AI INTEGRATION =====
#
#func ai_interface() -> Dictionary:
	#"""Interface for Gemma AI"""
	#return {
		#"total_beings": current_being_count,
		#"max_beings": MAX_BEINGS,
		#"beings_available": MAX_BEINGS - current_being_count,
		#"operations_queued": operation_queue.size(),
		#"beings_by_type": get_beings_count_by_type(),
		#"can_create_beings": current_being_count < MAX_BEINGS
	#}
#
#func get_beings_count_by_type() -> Dictionary:
	#"""Get count of beings by type"""
	#var counts = {}
	#for being in being_registry:
		#var type = being.being_type
		#counts[type] = counts.get(type, 0) + 1
	#return counts
#
## ===== DEBUG FUNCTIONS =====
#
#func debug_info() -> String:
	#"""Get FloodGates debug information"""
	#var info = []
	#info.append("=== FloodGates Debug Info ===")
	#info.append("Total Beings: %d/%d" % [current_being_count, MAX_BEINGS])
	#info.append("Operations Queued: %d" % operation_queue.size())
	#info.append("Registered Beings:")
	#
	#for being in being_registry:
		#var parent_name = "No Parent"
		#if being.get_parent():
			#parent_name = being.get_parent().name
		#info.append("  - %s (%s) -> %s" % [being.being_name, being.being_type, parent_name])
	#
	#return "\n".join(info)
#
#func validate_scene_integrity() -> bool:
	#"""Validate that all registered beings are properly in scene"""
	#var issues_found = false
	#
	#for being in being_registry:
		#if not is_instance_valid(being):
			#print("🌊 FloodGates: WARNING - Invalid being in registry: " + str(being))
			#issues_found = true
		#elif not being.get_parent():
			#print("🌊 FloodGates: WARNING - Being without parent: " + being.being_name)
			#issues_found = true
	#
	#if not issues_found:
		#print("🌊 FloodGates: Scene integrity validated ✓")
	#
	#return not issues_found
