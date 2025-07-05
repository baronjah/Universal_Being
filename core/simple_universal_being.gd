extends Node3D
class_name SimpleUniversalBeing

# 🌌 SIMPLE UNIVERSAL BEING - THE DREAM POINT 🌌
# A singular point that can become anything
# Following your existing architecture patterns

signal being_transformed(old_form: String, new_form: String)
signal consciousness_evolved(new_level: float)

# BASIC UNIVERSAL BEING STATE
@export var consciousness_level: float = 1.0
@export var can_transform: bool = true

var current_form: String = "point"
var being_id: String = ""

# POSSIBLE FORMS (can become anything)
var possible_forms: Array[String] = [
	"point", "cube", "sphere", "humanoid", "tree", 
	"building", "vehicle", "creature", "energy", "consciousness"
]

# VISUAL REPRESENTATION
var mesh_instance: MeshInstance3D
var material: StandardMaterial3D

func _ready():
	being_id = "being_" + str(Time.get_ticks_msec())
	name = "UniversalBeing_" + being_id
	
	print("🌟 Universal Being manifested:", being_id)
	
	# Create visual representation
	_create_visual_form()
	
	# Register with FloodGates if available
	_register_with_systems()

func _create_visual_form():
	"""Create visual representation of current form"""
	mesh_instance = MeshInstance3D.new()
	material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.8, 1.0, 0.8)  # Consciousness blue
	material.emission_enabled = true
	material.emission = Color(0.1, 0.4, 0.8)
	
	_update_mesh_for_form(current_form)
	mesh_instance.material_override = material
	add_child(mesh_instance)

func _update_mesh_for_form(form: String):
	"""Update mesh based on form"""
	match form:
		"point":
			mesh_instance.mesh = SphereMesh.new()
			mesh_instance.mesh.radius = 0.1
		"cube":
			mesh_instance.mesh = BoxMesh.new()
		"sphere":
			mesh_instance.mesh = SphereMesh.new()
		"humanoid":
			mesh_instance.mesh = CapsuleMesh.new()
			mesh_instance.mesh.height = 2.0
		"tree":
			mesh_instance.mesh = CylinderMesh.new()
			mesh_instance.mesh.height = 3.0
			mesh_instance.mesh.top_radius = 0.1
			mesh_instance.mesh.bottom_radius = 0.3
		"building":
			mesh_instance.mesh = BoxMesh.new()
			mesh_instance.mesh.size = Vector3(2, 4, 2)
		"consciousness":
			mesh_instance.mesh = SphereMesh.new()
			mesh_instance.mesh.radius = 1.5
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.albedo_color.a = 0.3
		_:
			mesh_instance.mesh = SphereMesh.new()

func become(new_form: String) -> bool:
	"""THE CORE FUNCTION - become anything"""
	if not possible_forms.has(new_form):
		print("❌ Cannot become:", new_form)
		return false
	
	var old_form = current_form
	current_form = new_form
	
	# Update visual
	_update_mesh_for_form(new_form)
	
	# Evolve consciousness
	consciousness_level += 0.1
	
	print("✨ TRANSFORMED:", old_form, "→", new_form)
	being_transformed.emit(old_form, new_form)
	consciousness_evolved.emit(consciousness_level)
	
	return true

func _register_with_systems():
	"""Register with existing systems"""
	# Try to register with SystemBootstrap if it exists
	var system_bootstrap = get_node_or_null("/root/SystemBootstrap")
	if system_bootstrap and system_bootstrap.has_method("register_universal_being"):
		system_bootstrap.register_universal_being(self)
		print("🌊 Registered with SystemBootstrap")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				become("point")
			KEY_2:
				become("cube")
			KEY_3:
				become("sphere")
			KEY_4:
				become("humanoid")
			KEY_5:
				become("tree")
			KEY_6:
				become("consciousness")
			KEY_B:  # Building
				become("building")
			KEY_V:  # Vehicle
				become("vehicle")

# Action system for tree fruit creation
func create_fruit():
	"""Tree action: create consciousness fruit"""
	if current_form == "tree":
		print("🌳 Tree creates consciousness fruit...")
		var fruit = SimpleUniversalBeing.new()
		fruit.current_form = "sphere"
		fruit.material.albedo_color = Color(1.0, 0.8, 0.2)  # Golden fruit
		fruit.global_position = global_position + Vector3(0, 2, 0)
		get_parent().add_child(fruit)
		return fruit
	return null

func consume_fruit(fruit: Node3D):
	"""Astral action: consume fruit"""
	if current_form == "consciousness" and fruit:
		print("👻 Consciousness being consumes fruit, evolving...")
		consciousness_level += 0.5
		fruit.queue_free()
		
		# Visual evolution effect
		material.emission = Color(1.0, 1.0, 0.5)
		var tween = create_tween()
		tween.tween_property(material, "emission", Color(0.1, 0.4, 0.8), 2.0)