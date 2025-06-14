extends UniversalBeingBase
# Unified Being System - Consolidates all being types
# Replaces: astral_being (5+ versions), universal_being (3 versions), bird (2-3 versions)

signal being_created(being: Node3D, type: String)
# signal being_removed(being: Node3D)  # TODO: Emit this signal in remove_being() when implemented
signal being_transformed(being: Node3D, old_type: String, new_type: String)

# Being registry
var beings: Dictionary = {}  # instance_id -> being data
var being_types: Dictionary = {}  # type -> array of beings

# Being capabilities (what all beings can do)
var capabilities = {
	"move": true,
	"transform": true,
	"interact": true,
	"emit_particles": true,
	"change_color": true,
	"scale": true,
	"rotate": true,
	"talk": true
}

# Simple being template
const BEING_TEMPLATE = {
	"type": "basic",
	"name": "Being",
	"position": Vector3.ZERO,
	"rotation": Vector3.ZERO,
	"scale": Vector3.ONE,
	"color": Color.WHITE,
	"properties": {},
	"capabilities": [],
	"state": "idle"
}

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[UnifiedBeingSystem] Consolidating all being systems into one")
	_register_commands()
	_migrate_existing_beings()

func _register_commands():
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		# Basic being commands
		console.register_command("being", _cmd_being, "Create or manage beings")
		console.register_command("beings", _cmd_list_beings, "List all beings")
		console.register_command("transform", _cmd_transform_being, "Transform a being")
		
		# Container commands
		console.register_command("container", _cmd_container, "Create or manage scene containers")
		console.register_command("containers", _cmd_list_containers, "List all containers")
		console.register_command("connect", _cmd_connect_containers, "Connect two containers")


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
func create_being(type: String = "basic", position: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> Node3D:
	"""Create a unified being that can become anything"""
	
	# Always create Universal Being directly - it will use StandardizedObjects for visuals
	# This ensures everything is a Universal Being as per the user's vision
	var being = Node3D.new()
	being.name = "%s_%d" % [type, beings.size()]
	
	# Set Universal Being script
	var universal_being_script = load("res://scripts/core/universal_being.gd")
	if universal_being_script:
		being.set_script(universal_being_script)
		
		# Add to world first
		var main_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
		FloodgateController.universal_add_child(being, main_scene)
		being.global_position = position
		
		# Add to spawned_objects group for proper tracking
		being.add_to_group("spawned_objects")
		being.add_to_group("universal_beings")
		
		# Let Universal Being handle its own manifestation
		being.become(type)
	else:
		# Old fallback system
		var visual = _create_visual_for_type(type)
		if visual:
			FloodgateController.universal_add_child(visual, being)
		
		# Add to world
		var main_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
		FloodgateController.universal_add_child(being, main_scene)
		being.global_position = position
	
	# Setup being data
	var being_data = BEING_TEMPLATE.duplicate(true)
	being_data.type = type
	being_data.name = being.name
	being_data.position = position
	being_data.properties = properties
	
	# Register being
	beings[being.get_instance_id()] = being_data
	if not being_types.has(type):
		being_types[type] = []
	being_types[type].append(being)
	
	# Add capabilities
	_add_capabilities(being, type)
	
	being_created.emit(being, type)
	print("[UnifiedBeingSystem] Created %s being at %s" % [type, position])
	
	return being

func _create_visual_for_type(type: String) -> Node3D:
	"""Create appropriate visual for being type"""
	var visual = Node3D.new()
	
	# Use StandardizedObjects if available
	var std_objects = get_node_or_null("/root/StandardizedObjects")
	if std_objects and std_objects.has_method("create_object"):
		match type:
			"tree":
				return std_objects.create_object("tree", Vector3.ZERO)
			"rock":
				return std_objects.create_object("rock", Vector3.ZERO)
			"astral":
				# Create glowing sphere for astral beings
				var astral_mesh = MeshInstance3D.new()
				astral_mesh.mesh = SphereMesh.new()
				astral_mesh.mesh.radial_segments = 16
				astral_mesh.mesh.height = 1.0
				astral_mesh.mesh.radius = 0.5
				
				# Glowing material
				var material = MaterialLibrary.get_material("default")
				material.albedo_color = Color(0.5, 0.8, 1.0)
				material.emission_enabled = true
				material.emission = Color(0.3, 0.6, 0.9)
				material.emission_energy = 2.0
				astral_mesh.material_override = material
				
				FloodgateController.universal_add_child(astral_mesh, visual)
				return visual
			"bird":
				# Simple bird shape
				var bird_mesh = MeshInstance3D.new()
				bird_mesh.mesh = CapsuleMesh.new()
				bird_mesh.mesh.height = 0.5
				bird_mesh.mesh.radius = 0.2
				FloodgateController.universal_add_child(bird_mesh, visual)
				return visual
			_:
				# Default cube
				var default_mesh = MeshInstance3D.new()
				default_mesh.mesh = BoxMesh.new()
				FloodgateController.universal_add_child(default_mesh, visual)
				return visual
	
	# Fallback to simple mesh
	var fallback_mesh = MeshInstance3D.new()
	fallback_mesh.mesh = BoxMesh.new()
	FloodgateController.universal_add_child(fallback_mesh, visual)
	return visual

func _add_capabilities(being: Node3D, type: String):
	"""Add capabilities based on type"""
	# All beings can move
	being.set_meta("can_move", true)
	being.set_meta("can_transform", true)
	
	# Type-specific capabilities
	match type:
		"astral":
			being.set_meta("can_fly", true)
			being.set_meta("can_glow", true)
			being.set_meta("can_phase", true)
		"bird":
			being.set_meta("can_fly", true)
			being.set_meta("can_perch", true)
		"tree":
			being.set_meta("can_grow", true)
			being.set_meta("can_drop_fruit", true)

func transform_being(being: Node3D, new_type: String) -> bool:
	"""Transform a being from one type to another"""
	var instance_id = being.get_instance_id()
	if not instance_id in beings:
		push_error("Being not found in registry")
		return false
	
	var old_data = beings[instance_id]
	var old_type = old_data.type
	
	# Remove old visual
	for child in being.get_children():
		child.queue_free()
	
	# Create new visual
	var new_visual = _create_visual_for_type(new_type)
	if new_visual:
		FloodgateController.universal_add_child(new_visual, being)
	
	# Update data
	old_data.type = new_type
	
	# Update type registry
	if old_type in being_types:
		being_types[old_type].erase(being)
	if not new_type in being_types:
		being_types[new_type] = []
	being_types[new_type].append(being)
	
	# Update capabilities
	_add_capabilities(being, new_type)
	
	being_transformed.emit(being, old_type, new_type)
	print("[UnifiedBeingSystem] Transformed %s from %s to %s" % [being.name, old_type, new_type])
	
	return true

func _migrate_existing_beings():
	"""Find and migrate existing beings to unified system"""
	# Find astral beings
	var astral_count = 0
	for node in get_tree().get_nodes_in_group("astral_beings"):
		beings[node.get_instance_id()] = {
			"type": "astral",
			"name": node.name,
			"position": node.global_position,
			"properties": {}
		}
		if not "astral" in being_types:
			being_types["astral"] = []
		being_types["astral"].append(node)
		astral_count += 1
	
	if astral_count > 0:
		print("[UnifiedBeingSystem] Migrated %d astral beings" % astral_count)

# Console commands
func _cmd_being(args: Array) -> String:
	if args.is_empty():
		return "Usage: being <type> [x] [y] [z] OR being interface <interface_type> OR being create <asset_type>"
	
	var command = args[0]
	
	# Handle different being commands
	match command:
		"interface":
			# being interface console
			if args.size() >= 2:
				var interface_type = args[1]
				return _create_interface_being(interface_type, args.slice(2))
			return "Usage: being interface <type> [x] [y] [z]"
		
		"container":
			# being container room
			if args.size() >= 2:
				var container_type = args[1]
				var size = Vector3(10, 5, 10)
				var pos = Vector3.ZERO
				if args.size() >= 5:
					size = Vector3(args[2].to_float(), args[3].to_float(), args[4].to_float())
				if args.size() >= 8:
					pos = Vector3(args[5].to_float(), args[6].to_float(), args[7].to_float())
				return _create_container_being(container_type, size, pos)
			return "Usage: being container <type> [size_x size_y size_z] [pos_x pos_y pos_z]"
		
		"create":
			# being create tree - explicit asset creation
			if args.size() >= 2:
				var asset_type = args[1]
				var pos = Vector3(0, 0, -5)  # Default position in front
				if args.size() >= 5:
					pos = Vector3(args[2].to_float(), args[3].to_float(), args[4].to_float())
				
				print("\n[CMD] Creating Universal Being with asset type: ", asset_type)
				var being = create_being(asset_type, pos)
				if being:
					return "✅ Created %s being at %s" % [asset_type, pos]
				else:
					return "❌ Failed to create %s being" % asset_type
			return "Usage: being create <asset_type> [x] [y] [z]"
		
		_:
			# Default: being tree (direct type creation)
			var type = command
			var pos = Vector3.ZERO
			
			# Handle special cases
			if type == "target":
				print("[INFO] 'target' isn't an asset type. Use 'gizmo target <object_name>' to attach gizmo.")
				print("       Creating a box instead for demonstration...")
				type = "box"  # Use box as a visible target
			
			if args.size() >= 4:
				pos = Vector3(args[1].to_float(), args[2].to_float(), args[3].to_float())
			elif args.size() == 2:
				pos = Vector3(0, args[1].to_float(), 0)
			
			var being = create_being(type, pos)
			if being:
				# Debug check
				print("\n[DEBUG] Universal Being created:")
				print("  Type requested: ", type)
				print("  Being name: ", being.name)
				print("  Position: ", being.global_position)
				print("  Visible: ", being.visible)
				print("  Children: ", being.get_child_count())
				return "Created %s being at %s" % [type, pos]
			else:
				return "Failed to create %s being" % type

func _create_interface_being(interface_type: String, pos_args: Array) -> String:
	"""Create a Universal Being interface using the interface manifestation system"""
	
	# Parse position if provided
	var pos = Vector3(0, 5, 5)  # Default position for interfaces
	if pos_args.size() >= 3:
		pos = Vector3(pos_args[0].to_float(), pos_args[1].to_float(), pos_args[2].to_float())
	
	# Create a Universal Being that manifests as an interface
	var universal_being_script = load("res://scripts/core/universal_being.gd")
	if not universal_being_script:
		return "Error: Universal Being script not found"
	
	var interface_being = Node3D.new()
	interface_being.set_script(universal_being_script)
	interface_being.name = "interface_%d" % beings.size()
	
	# Add to scene
	var main_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	FloodgateController.universal_add_child(interface_being, main_scene)
	interface_being.global_position = pos
	
	# Transform the being into an interface
	interface_being.become_interface(interface_type, {})
	
	# Register in unified system
	var being_data = BEING_TEMPLATE.duplicate(true)
	being_data.type = "interface_" + interface_type
	being_data.name = interface_being.name
	being_data.position = pos
	being_data.properties = {"interface_type": interface_type}
	
	beings[interface_being.get_instance_id()] = being_data
	if not being_types.has("interface"):
		being_types["interface"] = []
	being_types["interface"].append(interface_being)
	
	being_created.emit(interface_being, "interface_" + interface_type)
	print("[UnifiedBeingSystem] Created interface being at %s" % pos)
	
	return "✅ Created %s interface at %s" % [interface_type, pos]

func _cmd_list_beings(_args: Array) -> String:
	if beings.is_empty():
		return "No beings exist"
	
	var output = "[Unified Beings]\n"
	for type in being_types:
		var count = being_types[type].size()
		if count > 0:
			output += "%s: %d\n" % [type, count]
	
	output += "\nTotal: %d beings" % beings.size()
	return output

func _cmd_transform_being(args: Array) -> String:
	if args.size() < 2:
		return "Usage: transform <being_name> <new_type>"
	
	var being_name = args[0]
	var new_type = args[1]
	
	# Find being by name
	for being in get_tree().get_nodes_in_group("beings"):
		if being.name == being_name:
			if transform_being(being, new_type):
				return "Transformed %s to %s" % [being_name, new_type]
			else:
				return "Failed to transform %s" % being_name
	
	return "Being '%s' not found" % being_name

# ===== CONTAINER COMMANDS =====

func _cmd_container(args: Array) -> String:
	"""Handle container creation and management commands"""
	if args.is_empty():
		return "Usage: container <type> [size_x] [size_y] [size_z] [pos_x] [pos_y] [pos_z]"
	
	var container_type = args[0]
	
	# Parse container size
	var size = Vector3(10, 5, 10)  # Default room size
	if args.size() >= 4:
		size = Vector3(args[1].to_float(), args[2].to_float(), args[3].to_float())
	
	# Parse position
	var pos = Vector3(0, 0, 0)
	if args.size() >= 7:
		pos = Vector3(args[4].to_float(), args[5].to_float(), args[6].to_float())
	
	return _create_container_being(container_type, size, pos)

func _create_container_being(container_type: String, size: Vector3, pos: Vector3) -> String:
	"""Create a Universal Being that acts as a scene container"""
	
	# Create a Universal Being that manifests as a container
	var universal_being_script = load("res://scripts/core/universal_being.gd")
	if not universal_being_script:
		return "Error: Universal Being script not found"
	
	var container_being = Node3D.new()
	container_being.set_script(universal_being_script)
	container_being.name = "container_%s_%d" % [container_type, beings.size()]
	
	# Add to scene
	var main_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	FloodgateController.universal_add_child(container_being, main_scene)
	container_being.global_position = pos
	
	# Transform the being into a container
	var properties = {
		"show_boundaries": true,
		"show_connection_points": true
	}
	container_being.become_container(container_type, size, properties)
	
	# Register in unified system
	var being_data = BEING_TEMPLATE.duplicate(true)
	being_data.type = "container_" + container_type
	being_data.name = container_being.name
	being_data.position = pos
	being_data.properties = {
		"container_type": container_type,
		"size": size,
		"properties": properties
	}
	
	beings[container_being.get_instance_id()] = being_data
	if not being_types.has("container"):
		being_types["container"] = []
	being_types["container"].append(container_being)
	
	being_created.emit(container_being, "container_" + container_type)
	print("[UnifiedBeingSystem] Created container being: ", container_type, " at ", pos)
	
	return "✅ Created %s container (%s) at %s" % [container_type, size, pos]

func _cmd_list_containers(_args: Array) -> String:
	"""List all container beings"""
	
	var containers = being_types.get("container", [])
	if containers.is_empty():
		return "No containers exist"
	
	var output = "[Scene Containers]\n"
	for container_being in containers:
		var container = container_being.get_container()
		if container:
			var info = container.get_container_info()
			output += "%s: %s (%s) - %d beings, %d connections\n" % [
				info.name, 
				info.type, 
				info.size,
				info.beings_count,
				info.connections_count
			]
	
	output += "\nTotal: %d containers" % containers.size()
	return output

func _cmd_connect_containers(args: Array) -> String:
	"""Connect two containers via connection points"""
	if args.size() < 2:
		return "Usage: connect <container1_name> <container2_name> [connection_type]"
	
	var container1_name = args[0]
	var container2_name = args[1]
	var connection_type = args[2] if args.size() > 2 else "door"
	
	# Find containers
	var container1 = _find_container_by_name(container1_name)
	var container2 = _find_container_by_name(container2_name)
	
	if not container1:
		return "Container '%s' not found" % container1_name
	if not container2:
		return "Container '%s' not found" % container2_name
	
	# Get available connection points
	var connections1 = container1.get_available_connection_points()
	var connections2 = container2.get_available_connection_points()
	
	if connections1.is_empty():
		return "Container '%s' has no available connection points" % container1_name
	if connections2.is_empty():
		return "Container '%s' has no available connection points" % container2_name
	
	# Use first available connection points
	var conn1_id = connections1[0].id
	var conn2_id = connections2[0].id
	
	# Attempt connection
	if container1.connect_to_container(container2, conn1_id, conn2_id):
		return "✅ Connected %s to %s via %s" % [container1_name, container2_name, connection_type]
	else:
		return "❌ Failed to connect containers"

func _find_container_by_name(container_name: String) -> UniversalBeingSceneContainer:
	"""Find a container by name"""
	var containers = being_types.get("container", [])
	for container_being in containers:
		if container_being.name.contains(container_name):
			return container_being.get_container()
	return null
