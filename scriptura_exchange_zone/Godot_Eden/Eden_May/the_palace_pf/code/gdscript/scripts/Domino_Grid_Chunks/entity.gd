# entity.gd
extends Node2D

class_name Entity

# Basic properties all entities have
var entity_id: String
var entity_type: String
var position_vec2i: Vector2i  # Grid position
var health: float = 100.0
var age: float = 0.0
var energy: float = 100.0
var genetics: Dictionary = {}  # Genetic traits
var state_machine = null

# Signals
signal entity_died(entity)
signal entity_acted(entity, action_type, target)
signal entity_moved(entity, old_position, new_position)

func _ready():
	entity_id = generate_unique_id()
	initialize_state_machine()

func _process(delta):
	# Basic life processes
	age += delta
	energy -= delta * get_base_energy_consumption()
	
	# Process AI and behavior via state machine
	if state_machine != null:
		state_machine.update(delta)
	
	# Check survival conditions
	if energy <= 0 or health <= 0:
		die()

func initialize_state_machine():
	# To be implemented in child classes
	pass

func get_base_energy_consumption() -> float:
	# Can be overridden by subclasses
	return 0.5

func act(action_type: String, target = null):
	# Base action processing
	match action_type:
		"move":
			move_to(target)
		"eat":
			consume(target)
		"reproduce":
			reproduce()
		# More actions...
	
	emit_signal("entity_acted", self, action_type, target)

func consume(target):
	# to implement
	pass
	
func reproduce():
	# to implement
	pass

func move_to(new_position: Vector2i):
	var old_position = position_vec2i
	position_vec2i = new_position
	
	# Get world node to update entity positions
	var world = get_node("/root/World")
	world.move_entity(self, old_position, new_position)
	
	emit_signal("entity_moved", self, old_position, new_position)

func die():
	emit_signal("entity_died", self)
	queue_free()

func generate_unique_id() -> String:
	return "%s_%s" % [entity_type, randi() % 1000000]

func to_dict() -> Dictionary:
	# Used for saving entity state
	return {
		"id": entity_id,
		"type": entity_type,
		"position": {"x": position_vec2i.x, "y": position_vec2i.y},
		"health": health,
		"age": age,
		"energy": energy,
		"genetics": genetics
	}

func from_dict(data: Dictionary) -> void:
	# Used for loading entity state
	entity_id = data.id
	position_vec2i = Vector2i(data.position.x, data.position.y)
	health = data.health
	age = data.age
	energy = data.energy
	genetics = data.genetics
