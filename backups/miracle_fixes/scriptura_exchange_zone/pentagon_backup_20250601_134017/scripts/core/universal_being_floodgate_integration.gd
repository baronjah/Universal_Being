# ==================================================
# SCRIPT NAME: universal_being_floodgate_integration.gd
# DESCRIPTION: Makes Universal Being creation go through Floodgate
# PURPOSE: Ensure all Universal Beings benefit from Floodgate management
# CREATED: 2025-05-29 - Proper integration with existing systems
# ==================================================

extends UniversalBeingBase
class_name UniversalBeingFloodgateIntegration

# References
var floodgate_controller: Node = null
var asset_library: Node = null
var standardized_objects: Node = null
var unified_being_system: Node = null

func _ready() -> void:
	_setup_references()

func _setup_references() -> void:
	"""Get references to required systems"""
	floodgate_controller = get_node_or_null("/root/FloodgateController")
	asset_library = get_node_or_null("/root/AssetLibrary")
	standardized_objects = get_node_or_null("/root/StandardizedObjects")
	unified_being_system = get_node_or_null("/root/UnifiedBeingSystem")
	
	if not floodgate_controller:
		print("[UniversalBeingFloodgate] Warning: FloodgateController not found!")
	if not asset_library:
		print("[UniversalBeingFloodgate] Warning: AssetLibrary not found!")


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func create_universal_being_through_floodgate(type: String, position: Vector3, properties: Dictionary = {}) -> void:
	"""Create a Universal Being using Floodgate system"""
	
	if not floodgate_controller:
		print("[UniversalBeingFloodgate] Error: FloodgateController not available")
		return
	
	# Check if type exists in asset library
	var asset_exists = false
	if asset_library and asset_library.has_method("has_asset"):
		asset_exists = asset_library.has_asset(type)
	
	# Queue the creation through Floodgate
	var operation = {
		"type": "create_universal_being",
		"params": {
			"being_type": type,
			"position": position,
			"properties": properties,
			"use_asset_library": asset_exists
		},
		"callback": _on_being_created
	}
	
	if floodgate_controller.has_method("queue_operation"):
		floodgate_controller.queue_operation(operation)
		print("[UniversalBeingFloodgate] Queued Universal Being creation: ", type)
	else:
		# Fallback to direct creation
		_create_being_directly(type, position, properties)

func _on_being_created(result: Dictionary) -> void:
	"""Called when Floodgate completes being creation"""
	if result.has("success") and result.success:
		print("[UniversalBeingFloodgate] Successfully created being: ", result.get("being_name", "unknown"))
	else:
		print("[UniversalBeingFloodgate] Failed to create being: ", result.get("error", "unknown error"))

func _create_being_directly(type: String, position: Vector3, properties: Dictionary) -> void:
	"""Direct creation as fallback"""
	
	# First try to use StandardizedObjects if type matches asset
	if standardized_objects and standardized_objects.has_method("create_object"):
		var visual = standardized_objects.create_object(type, position)
		if visual:
			# Wrap the StandardizedObject in a Universal Being
			var universal_being_script = load("res://scripts/core/universal_being.gd")
			if universal_being_script:
				var being = Node3D.new()
				being.set_script(universal_being_script)
				being.name = "being_" + type + "_" + str(Time.get_ticks_msec())
				
				# Get the scene root
				var main_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
				FloodgateController.universal_add_child(being, main_scene)
				being.global_position = position
				
				# Set the visual as the manifestation
				if visual.get_parent():
					visual.get_parent().remove_child(visual)
				FloodgateController.universal_add_child(visual, being)
				being.manifestation = visual
				being.is_manifested = true
				being.form = type
				
				print("[UniversalBeingFloodgate] Created being with StandardizedObject: ", type)
				return
	
	# Fallback to UnifiedBeingSystem
	if unified_being_system and unified_being_system.has_method("create_being"):
		unified_being_system.create_being(type, position, properties)

# Enhanced Universal Being with proper asset integration
static func enhance_universal_being(being: UniversalBeing, asset_type: String) -> void:
	"""Enhance a Universal Being with proper asset from library"""
	
	var std_objects = being.get_node_or_null("/root/StandardizedObjects")
	if not std_objects:
		return
	
	# Remove old manifestation
	if being.manifestation:
		being.manifestation.queue_free()
		being.manifestation = null
	
	# Create proper asset visual
	if std_objects.has_method("create_object"):
		var visual = std_objects.create_object(asset_type, Vector3.ZERO)
		if visual:
			FloodgateController.universal_add_child(visual, being)
			being.manifestation = visual
			being.is_manifested = true
			being.form = asset_type
			print("[UniversalBeingFloodgate] Enhanced being with asset: ", asset_type)