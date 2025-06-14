# ==================================================
# SCRIPT NAME: universal_being_visualizer.gd
# DESCRIPTION: Visual Universal Being with star sprite and interaction area
# PURPOSE: The Universal Being that can become anything - now with perfect visualization!
# CREATED: 2025-05-28 - Your dream visualization realized
# ==================================================

extends UniversalBeingBase
class_name UniversalBeingVisualizer

# Visual Universal Being with star sprite and clickable area
signal clicked()
signal area_entered(body)
signal area_exited(body)
signal transformation_started(new_form)
signal transformation_completed(old_form, new_form)

# Core Universal Being properties
var uuid: String = ""
var form: String = "universal_star"
var essence: Dictionary = {}
var satisfaction: float = 100.0

# Visual components
var sprite_3d: Sprite3D = null
var area_3d: Area3D = null
var collision_shape: CollisionShape3D = null
var interaction_area: SphereShape3D = null

# Transformation system
var current_manifestation: Node3D = null
var is_transforming: bool = false
var transformation_timer: Timer = null

# Interaction tracking
var nearby_objects: Array = []
var nearby_beings: Array = []

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "UniversalBeing_" + str(Time.get_ticks_msec())
	uuid = _generate_uuid()
	
	# Create visual components
	_create_star_visualization()
	_create_interaction_area()
	_setup_transformation_system()
	
	# Register with systems
	_register_with_systems()
	
	_print("⭐ Universal Being manifested! I can become anything!")

func _generate_uuid() -> String:
	return "ubeing_" + str(Time.get_ticks_msec()) + "_" + str(randi())

func _create_star_visualization() -> void:
	"""Create the beautiful star sprite representation"""
	sprite_3d = Sprite3D.new()
	sprite_3d.name = "StarSprite"
	
	# Create a simple star texture procedurally
	var star_texture = _create_star_texture()
	sprite_3d.texture = star_texture
	
	# Make it glow and look magical
	sprite_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_3d.shaded = false
	sprite_3d.modulate = Color(1.0, 0.8, 0.3, 0.9)  # Golden glow
	sprite_3d.scale = Vector3(2.0, 2.0, 1.0)  # Make it visible
	
	# Add gentle pulsing animation
	var tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(sprite_3d, "modulate:a", 0.6, 1.5)
	tween.tween_property(sprite_3d, "modulate:a", 1.0, 1.5)
	
	add_child(sprite_3d)
	_print("⭐ Star visualization created")

func _create_star_texture() -> ImageTexture:
	"""Create a simple star texture"""
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))  # Transparent background
	
	# Draw a simple star shape (center white circle)
	var _center = Vector2i(32, 32)
	var radius = 20
	
	# Create star points
	for y in range(64):
		for x in range(64):
			var dist = Vector2(x - 32, y - 32).length()
			if dist < radius:
				var alpha = 1.0 - (dist / radius)
				image.set_pixel(x, y, Color(1, 1, 1, alpha))
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func _create_interaction_area() -> void:
	"""Create clickable and interaction area"""
	# Main area for detection
	area_3d = Area3D.new()
	area_3d.name = "InteractionArea"
	
	# Collision shape for the area
	collision_shape = CollisionShape3D.new()
	collision_shape.name = "InteractionShape"
	
	# Sphere shape for 360-degree interaction
	interaction_area = SphereShape3D.new()
	interaction_area.radius = 3.0  # 3 unit radius for interaction
	
	collision_shape.shape = interaction_area
	FloodgateController.universal_add_child(collision_shape, area_3d)
	add_child(area_3d)
	
	# Set up collision layers for mouse interaction
	area_3d.collision_layer = 1  # Default layer
	area_3d.collision_mask = 1   # Detect default layer
	area_3d.monitoring = true
	area_3d.monitorable = true
	
	# Connect signals
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	area_3d.area_entered.connect(_on_area_entered)
	area_3d.area_exited.connect(_on_area_exited)
	area_3d.input_event.connect(_on_input_event)
	
	_print("🔮 Interaction area created (radius: 3.0)")

func _setup_transformation_system() -> void:
	"""Setup transformation timing and effects"""
	transformation_timer = TimerManager.get_timer()
	transformation_timer.name = "TransformationTimer"
	transformation_timer.wait_time = 2.0
	transformation_timer.one_shot = true
	transformation_timer.timeout.connect(_complete_transformation)
	add_child(transformation_timer)
	
	# Set default essence
	essence = {
		"energy": 100.0,
		"consciousness": 100.0,
		"potential": "infinite",
		"color": Color(1.0, 0.8, 0.3),
		"size": 1.0
	}

func _register_with_systems() -> void:
	"""Register with all game systems"""
	# Register with Universal Object Manager
	var uom = get_node_or_null("/root/UniversalObjectManager")
	if uom:
		set_meta("uuid", uuid)
		set_meta("is_universal_being", true)
		set_meta("object_type", "universal_being")
	
	# Register with Floodgate
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate:
		floodgate.second_dimensional_magic(0, name, self)
	
	# Register with Inspection Bridge
	var bridge = get_node_or_null("/root/UniversalInspectionBridge")
	if not bridge:
		bridge = get_tree().get_first_node_in_group("inspection_bridge")
	if bridge and bridge.has_method("make_object_inspectable"):
		bridge.make_object_inspectable(self, "universal_being")
		_print("⭐ Made clickable through inspection bridge")
	
	# Add to groups
	add_to_group("universal_beings")
	add_to_group("conscious_entities")
	add_to_group("clickable_objects")

# ========== INTERACTION SYSTEM ==========

func _on_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	"""Handle click events"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_clicked()

func _on_clicked() -> void:
	"""Handle being clicked"""
	_print("⭐ I have been clicked! I can transform into anything!")
	
	# Send click feedback to console
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_method("_print_to_console"):
		console._print_to_console("⭐ CLICKED: Universal Being (" + form + ")")
		console._print_to_console("  Position: " + str(position))
		console._print_to_console("  UUID: " + uuid)
		console._print_to_console("  Essence: " + str(essence.keys().size()) + " properties")
		console._print_to_console("  Nearby: " + str(nearby_objects.size()) + " objects")
		console._print_to_console("  Use 'being_transform [form]' to transform me!")
	
	# Pulse effect when clicked
	_create_click_effect()
	
	clicked.emit()

func _create_click_effect() -> void:
	"""Visual effect when clicked"""
	if sprite_3d:
		var tween = get_tree().create_tween()
		tween.tween_property(sprite_3d, "scale", Vector3(3.0, 3.0, 1.0), 0.2)
		tween.tween_property(sprite_3d, "scale", Vector3(2.0, 2.0, 1.0), 0.3)

func _on_body_entered(body: Node3D) -> void:
	"""Something entered our interaction area"""
	if body != self and not body in nearby_objects:
		nearby_objects.append(body)
		_print("👁️ Detected: " + body.name + " (Total: " + str(nearby_objects.size()) + ")")
		
		# Analyze what we can become based on nearby objects
		_analyze_transformation_possibilities()
		
		area_entered.emit(body)

func _on_body_exited(body: Node3D) -> void:
	"""Something left our interaction area"""
	if body in nearby_objects:
		nearby_objects.erase(body)
		_print("👋 Lost: " + body.name + " (Remaining: " + str(nearby_objects.size()) + ")")
		area_exited.emit(body)

func _on_area_entered(area: Area3D) -> void:
	"""Another area entered ours"""
	var owner_node = area.get_parent()
	if owner_node and owner_node != self:
		if owner_node.is_in_group("universal_beings"):
			if not owner_node in nearby_beings:
				nearby_beings.append(owner_node)
				_print("🤝 Universal Being nearby: " + owner_node.name)

func _on_area_exited(area: Area3D) -> void:
	"""Another area left ours"""
	var owner_node = area.get_parent()
	if owner_node and owner_node in nearby_beings:
		nearby_beings.erase(owner_node)
		_print("👋 Universal Being left: " + owner_node.name)

# ========== TRANSFORMATION SYSTEM ==========


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
func transform_into(new_form: String, properties: Dictionary = {}) -> void:
	"""Transform into any form based on nearby objects or user command"""
	if is_transforming:
		_print("🔄 Already transforming, please wait...")
		return
	
	var old_form = form
	_print("✨ Beginning transformation: " + old_form + " → " + new_form)
	
	is_transforming = true
	transformation_started.emit(new_form)
	
	# Update essence with new properties
	for key in properties:
		essence[key] = properties[key]
	
	# Start transformation visual
	_start_transformation_visual()
	
	# Set new form
	form = new_form
	
	# Start timer for completion
	transformation_timer.start()

func _start_transformation_visual() -> void:
	"""Visual effect during transformation"""
	if sprite_3d:
		var tween = get_tree().create_tween()
		tween.tween_property(sprite_3d, "modulate", Color(1, 1, 1, 0.3), 1.0)
		tween.tween_property(sprite_3d, "rotation", Vector3(0, TAU * 2, 0), 2.0)

func _complete_transformation() -> void:
	"""Complete the transformation process"""
	_create_new_manifestation()
	is_transforming = false
	
	# Reset star visual
	if sprite_3d:
		sprite_3d.modulate = essence.get("color", Color(1.0, 0.8, 0.3))
		sprite_3d.rotation = Vector3.ZERO
	
	_print("✅ Transformation complete! I am now: " + form)
	transformation_completed.emit("universal_star", form)

func _create_new_manifestation() -> void:
	"""Create physical manifestation of new form"""
	# Remove old manifestation
	if current_manifestation:
		current_manifestation.queue_free()
		current_manifestation = null
	
	# Create new form using StandardizedObjects
	if form != "universal_star":
		var obj = StandardizedObjects.create_object(form, Vector3.ZERO, essence)
		if obj:
			obj.position = Vector3(0, 1, 0)  # Slightly above the star
			add_child(obj)
			current_manifestation = obj
			_print("🎭 Manifested as: " + form)

func _analyze_transformation_possibilities() -> void:
	"""Analyze nearby objects to suggest transformations"""
	var suggestions = []
	
	for obj in nearby_objects:
		var obj_type = obj.get_meta("object_type", "unknown")
		if obj_type != "unknown" and not obj_type in suggestions:
			suggestions.append(obj_type)
	
	if suggestions.size() > 0:
		_print("💡 I could become: " + str(suggestions))

# ========== STATUS AND INSPECTION ==========

func get_full_state() -> Dictionary:
	"""Return complete state for inspection"""
	return {
		"uuid": uuid,
		"form": form,
		"essence": essence,
		"position": position,
		"satisfaction": satisfaction,
		"nearby_objects": nearby_objects.size(),
		"nearby_beings": nearby_beings.size(),
		"is_transforming": is_transforming,
		"current_manifestation": current_manifestation != null
	}

func _print(message: String) -> void:
	"""Print with Universal Being identifier"""
	print("⭐ [" + name + "] " + message)

# ========== CONSOLE COMMANDS ==========

func register_console_commands() -> void:
	"""Register commands for interacting with this being"""
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_method("add_command"):
		console.add_command("being_transform", _cmd_transform, "Transform Universal Being into [form]")
		console.add_command("being_status", _cmd_status, "Show Universal Being status")
		console.add_command("being_nearby", _cmd_nearby, "List nearby objects")

func _cmd_transform(args: Array) -> String:
	if args.size() < 1:
		return "Usage: being_transform [form] - Example: being_transform tree"
	
	var new_form = args[0]
	transform_into(new_form)
	return "⭐ Transforming into " + new_form + "..."

func _cmd_status(_args: Array) -> String:
	var status = "⭐ Universal Being Status:\n"
	status += "  Form: " + form + "\n"
	status += "  Position: " + str(position) + "\n"
	status += "  Nearby objects: " + str(nearby_objects.size()) + "\n"
	status += "  Satisfaction: " + str(satisfaction) + "%\n"
	status += "  Transforming: " + str(is_transforming)
	return status

func _cmd_nearby(_args: Array) -> String:
	if nearby_objects.size() == 0:
		return "⭐ No objects nearby"
	
	var result = "⭐ Nearby objects:\n"
	for obj in nearby_objects:
		var obj_type = obj.get_meta("object_type", "unknown")
		result += "  - " + obj.name + " (" + obj_type + ")\n"
	return result