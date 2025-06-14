# 🏛️ Zone - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

@tool
extends UniversalBeingBase
class_name Zone
## Base class for all zones in the 3D block coding system
## Zones are spatial areas that process and transform data

signal data_updated(data: Dictionary)
signal zone_connected(other_zone: Zone)
signal processing_started()
signal processing_completed()

@export var zone_size: Vector3 = Vector3(10, 10, 10)
@export var zone_color: Color = Color(0.5, 0.5, 1.0, 0.3)
@export var zone_name: String = "Zone"

var zone_id: String = ""
var zone_data: Dictionary = {}
var connected_zones: Array[Zone] = []
var boundary_mesh: MeshInstance3D
var info_label: Label3D

# Universal Being properties
var essence: Dictionary = {}
var consciousness_level: int = 1

func _ready() -> void:
	"""Initialize the zone"""
	if zone_id == "":
		zone_id = "zone_%d" % Time.get_ticks_msec()
	
	_create_boundary_visualization()
	_create_info_label()
	
	if Engine.is_editor_hint():
		print("🌐 Zone initialized: %s" % zone_name)

func _create_boundary_visualization() -> void:
	"""Create visual boundary for the zone"""
	boundary_mesh = MeshInstance3D.new()
	add_child(boundary_mesh)
	
	# Create box mesh
	var box_mesh = BoxMesh.new()
	box_mesh.size = zone_size
	boundary_mesh.mesh = box_mesh
	
	# Semi-transparent material
	var material = MaterialLibrary.get_material("default")
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = zone_color
	material.emission_enabled = true
	material.emission = zone_color * 0.5
	material.emission_intensity = 1.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	boundary_mesh.material_override = material

func _create_info_label() -> void:
	"""Create 3D label showing zone info"""
	info_label = Label3D.new()
	add_child(info_label)
	info_label.position.y = zone_size.y / 2 + 1.0
	info_label.text = zone_name
	info_label.font_size = 32
	info_label.outline_size = 8
	info_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED


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
func serialize() -> Dictionary:
	"""Serialize zone data for saving"""
	return {
		"type": get_class(),
		"id": zone_id,
		"name": zone_name,
		"position": var_to_str(position),
		"size": var_to_str(zone_size),
		"color": var_to_str(zone_color),
		"data": zone_data
	}
