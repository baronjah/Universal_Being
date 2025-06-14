# Material Library - Pentagon Architecture Resource Pooling
# Author: JSH (Pentagon Migration Engine)
# Created: May 31, 2025, 23:45 CEST
# Purpose: Centralized material resource management for Pentagon architecture
# Connection: Prevents MaterialLibrary.get_material("default") violations

extends UniversalBeingBase
# class_name MaterialLibrary  # Commented to avoid autoload conflict

## Centralized material resource management
## Prevents memory waste from creating new materials repeatedly

# Material pool
var material_pool: Dictionary = {}
var default_materials: Dictionary = {}

func _ready() -> void:
	_create_default_materials()
	print("MaterialLibrary: Initialized with Pentagon resource pooling")

func _create_default_materials() -> void:
	# Create commonly used materials
	default_materials["default"] = _create_standard_material(Color.WHITE)
	default_materials["red"] = _create_standard_material(Color.RED)
	default_materials["green"] = _create_standard_material(Color.GREEN)
	default_materials["blue"] = _create_standard_material(Color.BLUE)
	default_materials["brown"] = _create_standard_material(Color(0.6, 0.4, 0.2))
	default_materials["gray"] = _create_standard_material(Color.GRAY)

func _create_standard_material(color: Color) -> StandardMaterial3D:
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = color
	return material

## Get material from pool (Pentagon compliant way)
static func get_material(material_type: String = "default") -> StandardMaterial3D:
	# Try to find MaterialLibrary singleton
	var material_lib = null
	if Engine.has_singleton("MaterialLibrary"):
		material_lib = Engine.get_singleton("MaterialLibrary")
	else:
		# Fallback - create new material (should not happen in Pentagon architecture)
		push_warning("MaterialLibrary not found - creating new material (Pentagon violation)")
		var fallback_material = StandardMaterial3D.new()
		fallback_material.albedo_color = Color.WHITE
		return fallback_material
	
	return material_lib._get_material_instance(material_type)

func _get_material_instance(material_type: String) -> StandardMaterial3D:
	if material_type in default_materials:
		return default_materials[material_type]
	else:
		push_warning("Unknown material type: %s, using default" % material_type)
		return default_materials["default"]

## Return material to pool (for future recycling)
static func return_material(material: StandardMaterial3D) -> void:
	# Materials are reference counted, so we don't need to do much here
	# In the future, we could implement actual pooling
	pass

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