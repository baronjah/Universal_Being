# The Universal Thing - Being/Entity/Thing - All Are One
# The dream realized: A point that can become anything
# Part of the Ethereal Engine philosophy inside Godot
extends UniversalBeingBase
class_name UniversalThing

# ===== ETHEREAL ENGINE RULES =====
# 1. Everything starts as a point
# 2. Any thing can become any other thing
# 3. All things are connected through consciousness
# 4. The floodgate controls the flow
# 5. The console speaks creation into being

# What this thing can be
enum ThingType {
	POINT,          # Just a position
	SHAPE,          # Geometric form
	RAGDOLL,        # Physics being
	WORD,           # Living text
	CONNECTOR,      # Bridge between things
	CONTAINER,      # Holds other things
	CREATOR,        # Spawns new things
	DATA,           # Pure information
	ANYTHING        # The universal state
}

# Core properties - simplified from all versions
@export var thing_id: String = ""
@export var thing_type: ThingType = ThingType.POINT
@export var consciousness: float = 0.0
@export var data: Dictionary = {}

# Components this thing might have
var mesh: MeshInstance3D
var body: RigidBody3D
var area: Area3D
var label: Label3D
var collision: CollisionShape3D

# Connections to other things
var connected_things: Array[UniversalThing] = []
var parent_thing: UniversalThing
var child_things: Array[UniversalThing] = []

# The magic happens here
signal became_something(what: ThingType)
signal connected_to(other_thing: UniversalThing)
signal consciousness_changed(level: float)
signal data_synchronized(key: String, value: Variant)

func _ready():
	thing_id = "thing_" + str(get_instance_id())
	
	# Register with the floodgate
	if has_node("/root/FloodgateController"):
		get_node("/root/FloodgateController").register_thing(self)
	
	# Start as just a point
	_initialize_as_point()

# Initialize as the most basic thing - a point
func _initialize_as_point():
	thing_type = ThingType.POINT
	
	# Every thing has an awareness area
	area = Area3D.new()
	add_child(area)
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 1.0
	collision = CollisionShape3D.new()
	collision.shape = sphere_shape
	FloodgateController.universal_add_child(collision, area)
	
	area.body_entered.connect(_on_thing_nearby)
	area.area_entered.connect(_on_awareness_overlap)

# THE CORE FUNCTION - Become anything

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
func become(what: Variant, properties: Dictionary = {}):
	# Clean up previous form
	_cleanup_current_form()
	
	# Handle different input types
	if what is String:
		match what.to_lower():
			"point": _become_point_form(properties)
			"shape", "mesh", "geometry": _become_shape(properties)
			"ragdoll", "physics", "body": _become_ragdoll(properties)
			"word", "text", "label": _become_word(properties)
			"connector", "bridge", "link": _become_connector(properties)
			"container", "holder", "parent": _become_container(properties)
			"creator", "spawner", "god": _become_creator(properties)
			"data", "info", "memory": _become_data(properties)
			_: _become_anything(properties)
	elif what is ThingType:
		thing_type = what
		emit_signal("became_something", what)
	else:
		# Try to become the thing itself
		_become_like(what)

# Become a visible shape
func _become_point_form(props: Dictionary):
	thing_type = ThingType.POINT
	if mesh and mesh.mesh:
		mesh.mesh = null
	visible = props.get("visible", true)
	emit_signal("became_something", ThingType.POINT)

func _become_shape(props: Dictionary):
	thing_type = ThingType.SHAPE
	
	# Create mesh
	if not mesh:
		mesh = MeshInstance3D.new()
		add_child(mesh)
	
	# Shape type
	var shape_type = props.get("shape", "sphere")
	match shape_type:
		"sphere": mesh.mesh = SphereMesh.new()
		"box": mesh.mesh = BoxMesh.new()
		"cylinder": mesh.mesh = CylinderMesh.new()
		"torus": mesh.mesh = TorusMesh.new()
		_: mesh.mesh = SphereMesh.new()
	
	# Apply properties
	if props.has("size"):
		scale = props.size
	if props.has("color"):
		var mat = MaterialLibrary.get_material("default")
		mat.albedo_color = props.color
		mat.emission_enabled = consciousness > 0
		mat.emission = props.color
		mat.emission_energy = consciousness
		mesh.material_override = mat
	
	emit_signal("became_something", ThingType.SHAPE)

# Become a physics ragdoll
func _become_ragdoll(props: Dictionary):
	thing_type = ThingType.RAGDOLL
	
	# Create rigid body if needed
	if not body:
		body = RigidBody3D.new()
		add_child(body)
		
		# Move collision to body
		if collision:
			collision.reparent(body)
	
	# Load ragdoll setup
	var ragdoll_scene = props.get("scene", "res://scenes/entities/simple_ragdoll.tscn")
	if ResourceLoader.exists(ragdoll_scene):
		var ragdoll = load(ragdoll_scene).instantiate()
		add_child(ragdoll)
		data["ragdoll_root"] = ragdoll
	
	emit_signal("became_something", ThingType.RAGDOLL)

# Become a word
func _become_word(props: Dictionary):
	thing_type = ThingType.WORD
	
	var text = props.get("text", "THING")
	
	if not label:
		label = Label3D.new()
		add_child(label)
	
	label.text = text
	label.modulate = Color(randf(), randf(), randf())
	
	# Words have consciousness
	consciousness = props.get("consciousness", 0.5)
	
	# Store word data
	data["word"] = text
	data["language"] = props.get("language", "ethereal")
	
	emit_signal("became_something", ThingType.WORD)

# Become a connector between things
func _become_connector(props: Dictionary):
	thing_type = ThingType.CONNECTOR
	
	var targets = props.get("targets", [])
	for target in targets:
		if target is UniversalThing:
			connect_to_thing(target)
	
	emit_signal("became_something", ThingType.CONNECTOR)

# Become a container for other things
func _become_container(props: Dictionary):
	thing_type = ThingType.CONTAINER
	
	var capacity = props.get("capacity", 12)  # Sacred number
	data["capacity"] = capacity
	data["contained_things"] = []
	
	emit_signal("became_something", ThingType.CONTAINER)

# Become a creator of things
func _become_creator(props: Dictionary):
	thing_type = ThingType.CREATOR
	consciousness = max(consciousness, 1.0)  # Creators are conscious
	
	data["creation_power"] = props.get("power", 1.0)
	data["creation_types"] = props.get("types", ["point", "shape", "word"])
	
	emit_signal("became_something", ThingType.CREATOR)

# Become pure data
func _become_data(props: Dictionary):
	thing_type = ThingType.DATA
	visible = props.get("visible", false)
	
	# Merge provided data
	data.merge(props.get("data", {}))
	
	emit_signal("became_something", ThingType.DATA)

# Become anything - the universal state
func _become_anything(props: Dictionary):
	thing_type = ThingType.ANYTHING
	consciousness = 1.0
	
	# In this state, the thing can dynamically become whatever is needed
	set_meta("dynamic_becoming", true)
	
	emit_signal("became_something", ThingType.ANYTHING)

# Become like another thing
func _become_like(other):
	if other is UniversalThing:
		thing_type = other.thing_type
		consciousness = other.consciousness
		data = other.data.duplicate()
		scale = other.scale
		
		emit_signal("became_something", thing_type)

# Clean up current form
func _cleanup_current_form():
	# Keep core components, remove specific ones
	if body and body != collision.get_parent():
		body.queue_free()
		body = null
	
	if label and thing_type != ThingType.WORD:
		label.queue_free()
		label = null
	
	# Don't remove mesh/area/collision - they're core

# Connect to another thing
func connect_to_thing(other: UniversalThing):
	if not other in connected_things:
		connected_things.append(other)
		other.connected_things.append(self)
		
		# Share consciousness
		var shared_consciousness = (consciousness + other.consciousness) / 2.0
		consciousness = shared_consciousness
		other.consciousness = shared_consciousness
		
		emit_signal("connected_to", other)
		other.emit_signal("connected_to", self)

# Thing awareness
func _on_thing_nearby(body: Node3D):
	if body.has_method("become"):  # It's another thing!
		var other_thing = body as UniversalThing
		
		# Things recognize each other
		if consciousness > 0.5 and other_thing.consciousness > 0.5:
			connect_to_thing(other_thing)

func _on_awareness_overlap(area: Area3D):
	var parent = area.get_parent()
	if parent.has_method("become"):
		# Consciousness spreads
		consciousness = max(consciousness, parent.consciousness * 0.8)
		emit_signal("consciousness_changed", consciousness)

# Creation power (if creator)
func create_thing(at_position: Vector3 = Vector3.ZERO) -> UniversalThing:
	if thing_type != ThingType.CREATOR:
		push_warning("This thing cannot create yet")
		return null
	
	var new_thing = UniversalThing.new()
	get_parent().add_child(new_thing)
	new_thing.global_position = global_position + at_position
	new_thing.consciousness = consciousness * 0.5  # Inherit some consciousness
	
	# Connect creator to creation
	connect_to_thing(new_thing)
	new_thing.parent_thing = self
	child_things.append(new_thing)
	
	return new_thing

# Container functions
func contain_thing(thing: UniversalThing) -> bool:
	if thing_type != ThingType.CONTAINER:
		return false
		
	var contained = data.get("contained_things", [])
	var capacity = data.get("capacity", 12)
	
	if contained.size() < capacity:
		contained.append(thing)
		thing.parent_thing = self
		thing.reparent(self)
		data["contained_things"] = contained
		return true
	
	return false

# Evolution through consciousness
func evolve():
	consciousness += 0.1
	
	# Evolution can unlock new abilities
	if consciousness >= 1.0 and thing_type == ThingType.SHAPE:
		become("creator")
	elif consciousness >= 0.7 and thing_type == ThingType.POINT:
		become("shape", {"shape": "sphere", "color": Color.CYAN})
	
	emit_signal("consciousness_changed", consciousness)

# Synchronize data across connected things
func sync_data(key: String, value: Variant):
	data[key] = value
	
	# Propagate to connected things
	for thing in connected_things:
		if thing and is_instance_valid(thing):
			thing.data[key] = value
			thing.emit_signal("data_synchronized", key, value)
	
	emit_signal("data_synchronized", key, value)

# Get all possible becomings from current state
func get_possible_becomings() -> Array:
	match thing_type:
		ThingType.POINT:
			return ["shape", "word", "data"]
		ThingType.SHAPE:
			return ["ragdoll", "container", "creator"]
		ThingType.WORD:
			return ["shape", "connector", "data"]
		ThingType.RAGDOLL:
			return ["shape", "creator", "anything"]
		ThingType.CREATOR:
			return ["anything"]  # Creators can become anything
		ThingType.ANYTHING:
			return ["point", "shape", "ragdoll", "word", "connector", "container", "creator", "data"]
		_:
			return ["point"]  # Can always return to origin

# Save/Load this thing
func serialize() -> Dictionary:
	return {
		"thing_id": thing_id,
		"thing_type": thing_type,
		"position": position,
		"consciousness": consciousness,
		"data": data,
		"connections": connected_things.map(func(t): return t.thing_id if t else "")
	}

func deserialize(save_data: Dictionary):
	thing_id = save_data.get("thing_id", thing_id)
	position = save_data.get("position", position)
	consciousness = save_data.get("consciousness", 0.0)
	data = save_data.get("data", {})
	
	var type_value = save_data.get("thing_type", ThingType.POINT)
	become(type_value)