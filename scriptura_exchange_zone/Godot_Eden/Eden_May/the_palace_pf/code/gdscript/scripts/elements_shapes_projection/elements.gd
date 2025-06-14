# elements.gd - Base class for all atomic elements

# now we also have water element file too, kinda connected to that one which is two

# Claude Decipher of what i wanna :
#
#I see you're describing what appears to be a concept for a game or visual system involving points that can form shapes representing different elements like water, fire, earth, etc. Let me understand this better.
#From what I gather, you're envisioning:
#
#A system where points (with some diameter) can move around in space
#These points can combine to form shapes that represent concepts like "water" or "fire"
#The proximity of points determines whether they form a single shape or multiple shapes
#These shapes are viewed as projections or holograms
#There's a database or JSON file that stores words and their corresponding point configurations
#
#This sounds like an interesting dynamic visualization system where elements can form, separate, and potentially interact with each other based on proximity and other rules.
#Are you looking to develop this concept further? I could help you formalize the rules for how points behave, how shapes are formed from points, or even start sketching out what the data structure might look like for storing these relationships.
#
#To evolve this project, we could focus on:
#
#Point Physics - Refining how points move, attract, and repel to create more natural element behaviors (water flowing, fire flickering)
#Projection Logic - Enhancing how points form recognizable shapes when "projected" from certain angles or perspectives
#Element Interactions - Creating rules for how different elements (water, fire, earth) interact when their points come into proximity
#Visual Representation - Improving how the points render to better represent their elemental nature (transparency for water, glow for fire)
#Data Structure - Expanding the JSON/database to include properties like element behavior, interaction rules, and visual characteristics

#
#The key elements I'm understanding from your vision:
#
#Atomic Building Blocks: Everything starts with basic "atoms" that can communicate ("atom talks") and connect in various ways
#Dynamic File Structure: The system organically splits and merges files based on complexity and size, mirroring how biological systems grow and divide
#Self-Evolution: The zones, maps, and shapes evolve on their own, following rules but creating emergent complexity
#Neuromorphic Design: The system models itself after neural structures, creating connections, pathways, and networks that grow and adapt
#Dimensional Shifts: While displayed in 3D, the underlying structure can transform, with zones becoming their own complex systems
#
#This reminds me of cellular automata or artificial life simulations, but with a more sophisticated structure that allows for hierarchical complexity - similar to how simple cells can form tissues, which form organs, which form systems.
#For implementation, you might consider:
#
#Using a fractal-based data structure where any node can expand into its own complex system
#Creating "conversation protocols" between elements that determine how they connect and interact
#Designing transition rules for when a collection of elements becomes complex enough to split into its own file/zone

#
#Here's how we could approach building this in Godot:
#
#Atom Class: Create a base element that can connect, communicate, and evolve
#Zone Management: Implement the self-organizing file structure using Godot's resource system
#Visualization System: Use Godot's 3D capabilities to project the elemental shapes
#
#Let me outline a potential implementation structure:Evolving Elements System - Godot 4.4 ImplementationCode 
## Element.gd - Base class for all atomic elements
#class_name Element
#extends Node3D
#
## Basic properties
#var element_type: String = "neutral"  # water, fire, earth, etc.
#var attraction_radius: float = 2.0
#var repulsion_radius: float = 0.5
#var connectThis implementation gives you a foundation for the evolving element system in Godot 4.4. Key features include:
#
#Element System:
#
#Elements with different types (water, fire, earth, light, shadow)
#Physics-based attraction and repulsion
#Visual connections between elements
#Evolution capabilities
#
#
#Zone Management:
#
#Self-organizing zones that split when they grow too complex
#Automatic saving/loading of zones to the filesystem
#Dynamic activation based on camera distance
#
#
#Emergent Behavior:
#
#Elements evolve based on their connections
#Zones can split and merge organically
#The system grows more complex over time
#
#
#
#You can extend this framework by:
#
#Adding more complex evolution rules
#Creating element-specific behaviors (water flows, fire spreads)
#Implementing more sophisticated connection logic
#Adding player interaction mechanics
#
#I see you've created the first file in your project structure! The file elements.gd has been created in the path code/gdscript/scripts/elements_shapes_projection/.
#This is a great start for organizing your project. The structure shows you're keeping the element system in a dedicated folder, which makes sense given the complexity of what we're building.
#Now that you have the basic file structure set up, we can start implementing the core functionality. Would you like me to:
#
#Refine the Element class for elements.gd to match your specific vision?
#Create additional files for the zone management system?
#Develop the projection visualization system that will display your elements on screen?
#
#Let me know which direction you'd like to go next, and I can help you build out this system piece by piece.


class_name Element
extends Node3D

# Basic properties
var element_type: String = "neutral"  # water, fire, earth, etc.
var attraction_radius: float = 2.0
var repulsion_radius: float = 0.5
var connection_strength: float = 1.0
var evolution_factor: float = 0.0  # Increases with interactions
var connections = []  # Other elements this is connected to

# Visual representation
var point_mesh: MeshInstance3D
var connection_visual: Node3D

func _init(type: String = "neutral"):
	element_type = type
	
	# Create visual representation
	point_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	point_mesh.mesh = sphere
	
	var material = StandardMaterial3D.new()
	match element_type:
		"water":
			material.albedo_color = Color(0.2, 0.4, 0.8, 0.7)
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		"fire":
			material.albedo_color = Color(0.9, 0.3, 0.1)
			material.emission_enabled = true
			material.emission = Color(0.9, 0.5, 0.1)
		"earth":
			material.albedo_color = Color(0.4, 0.3, 0.1)
		"light":
			material.albedo_color = Color(1.0, 1.0, 0.8)
			material.emission_enabled = true
			material.emission = Color(1.0, 1.0, 0.8)
		"shadow":
			material.albedo_color = Color(0.1, 0.1, 0.2)
		_:
			material.albedo_color = Color(0.7, 0.7, 0.7)
	
	point_mesh.material_override = material
	add_child(point_mesh)
	
	# Create connection visual container
	connection_visual = Node3D.new()
	add_child(connection_visual)

func _process(delta):
	update_physics(delta)
	update_connections()
	check_evolution()

func update_physics(delta):
	# Find nearby elements
	var nearby_elements = get_nearby_elements()
	
	# Apply attraction/repulsion
	for element in nearby_elements:
		var distance = global_position.distance_to(element.global_position)
		var direction = (element.global_position - global_position).normalized()
		
		# Repulsion (too close)
		if distance < repulsion_radius:
			global_position -= direction * (1.0 - distance/repulsion_radius) * delta
		# Attraction (within range)
		elif distance < attraction_radius:
			if can_connect_with(element):
				global_position += direction * (1.0 - distance/attraction_radius) * connection_strength * delta

func get_nearby_elements():
	# This would use Godot's spatial queries, simplified for example
	var nearby = []
	var world = get_parent()
	if world:
		for node in world.get_children():
			if node is Element and node != self:
				var distance = global_position.distance_to(node.global_position)
				if distance < attraction_radius:
					nearby.append(node)
	return nearby

func can_connect_with(element):
	# Define rules for which elements can connect
	# For example, water connects well with water, but repels fire
	if element_type == element.element_type:
		return true
	
	# Element-specific connection rules
	match element_type:
		"water":
			if element.element_type == "fire":
				return false
		"fire":
			if element.element_type == "water":
				return false
	
	# Default to allowing connections
	return true

func connect_with(element):
	if not element in connections:
		connections.append(element)
		# Create visual connection
		var line = MeshInstance3D.new()
		var cylinder = CylinderMesh.new()
		cylinder.top_radius = 0.02
		cylinder.bottom_radius = 0.02
		cylinder.height = 1.0
		line.mesh = cylinder
		line.name = "connection_to_" + str(element.get_instance_id())
		connection_visual.add_child(line)

func disconnect_from(element):
	if element in connections:
		connections.erase(element)
		# Remove visual connection
		var connection_name = "connection_to_" + str(element.get_instance_id())
		if connection_visual.has_node(connection_name):
			connection_visual.get_node(connection_name).queue_free()

func update_connections():
	# Update existing connections and create new ones
	var nearby_elements = get_nearby_elements()
	
	# Check if existing connections are still valid
	for element in connections.duplicate():
		if not element in nearby_elements or not can_connect_with(element):
			disconnect_from(element)
	
	# Create new connections
	for element in nearby_elements:
		if can_connect_with(element) and not element in connections:
			connect_with(element)
	
	# Update visual representation of connections
	for element in connections:
		var connection_name = "connection_to_" + str(element.get_instance_id())
		if connection_visual.has_node(connection_name):
			var line = connection_visual.get_node(connection_name)
			
			# Calculate line position and rotation
			var start_pos = global_position
			var end_pos = element.global_position
			var center = (start_pos + end_pos) / 2
			var length = start_pos.distance_to(end_pos)
			
			# Update line transform
			line.global_position = center
			if length > 0.01:  # Avoid division by zero
				line.look_at(end_pos)
				var cylinder = line.mesh as CylinderMesh
				cylinder.height = length

func check_evolution():
	# Increase evolution factor based on connections
	evolution_factor += 0.0001 * connections.size()
	
	# Check if element should evolve
	if evolution_factor > 1.0:
		evolve()

func evolve():
	# Reset evolution factor
	evolution_factor = 0.0
	
	# Implement evolution logic here
	# This could transform the element type, split it, etc.
	print("Element evolving: ", element_type)


# hmm errors? so we have two files in one file, do we wanna split it and make new file? your choice, it is easier to make like description at top
# of what we wanna, then maybe few hundreds lines of code and connect it to something, so we flow with work
#
#Line 276:Unexpected "class_name" in class body.
#Line 277:Unexpected "extends" in class body.
#Line 284:Function "_init" has the same name as a previously declared function.
#Line 288:Function "_process" has the same name as a previously declared function.
#Line 397:Unexpected "class_name" in class body.
#Line 398:Unexpected "extends" in class body.
#Line 400:Variable "zone_id" has the same name as a previously declared variable.
#Line 405:Unexpected "class_name" in class body.
#Line 406:Unexpected "extends" in class body.
#Line 416:Function "_process" has the same name as a previously declared function.
#Line 460:Unexpected "extends" in class body.
#Line 465:Function "_ready" has the same name as a previously declared function.

# seeing 10k lines of code scroll in my mind over and over again while i write single line is harder than seeing just couple hundreds lines of 
# code at once, and connection can happen easy peasy

# ElementZone.gd - Manages a collection of elements
class_name ElementZone
extends Node3D

var zone_id: String
var elements = []
var evolution_threshold = 50  # Number of elements before zone splits
var resource_path: String

func _init(id: String):
	zone_id = id
	resource_path = "user://zones/" + zone_id + ".tres"

func _process(delta):
	check_zone_evolution()

func add_element(type: String, position: Vector3):
	var element = Element.new(type)
	element.global_position = position
	add_child(element)
	elements.append(element)
	return element

func remove_element(element):
	if element in elements:
		elements.erase(element)
		element.queue_free()

func check_zone_evolution():
	# Check if zone should split due to complexity
	if elements.size() > evolution_threshold:
		split_zone()
	
	# Check if zone should merge with another zone
	if elements.size() < evolution_threshold / 4:
		# This would require a parent ZoneManager to handle merges
		print("Zone ready for merging: ", zone_id)

func split_zone():
	print("Zone splitting: ", zone_id)
	
	# Create two new zones
	var zone1 = ElementZone.new(zone_id + "_1")
	var zone2 = ElementZone.new(zone_id + "_2")
	
	# Distribute elements between zones
	var half_size = elements.size() / 2
	for i in range(elements.size()):
		var element = elements[i]
		if i < half_size:
			# Move element to zone1
			remove_child(element)
			zone1.add_child(element)
			zone1.elements.append(element)
		else:
			# Move element to zone2
			remove_child(element)
			zone2.add_child(element)
			zone2.elements.append(element)
	
	# Clear this zone's elements
	elements.clear()
	
	# Add new zones to parent
	var parent = get_parent()
	if parent:
		parent.add_child(zone1)
		parent.add_child(zone2)
		
		# Remove this zone
		parent.remove_child(self)
		queue_free()

func save_zone():
	# Create directory if it doesn't exist
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("zones"):
		dir.make_dir("zones")
	
	# Create resource to save
	var zone_data = ZoneResource.new()
	zone_data.zone_id = zone_id
	zone_data.element_data = []
	
	# Save element data
	for element in elements:
		var element_data = {
			"type": element.element_type,
			"position": element.global_position,
			"evolution_factor": element.evolution_factor,
			"connections": [] # We'd need to store references to connected elements
		}
		zone_data.element_data.append(element_data)
	
	# Save resource
	var err = ResourceSaver.save(zone_data, resource_path)
	if err != OK:
		print("Failed to save zone: ", err)

func load_zone():
	if FileAccess.file_exists(resource_path):
		var zone_data = ResourceLoader.load(resource_path) as ZoneResource
		if zone_data:
			zone_id = zone_data.zone_id
			
			# Clear existing elements
			for element in elements:
				remove_child(element)
				element.queue_free()
			elements.clear()
			
			# Create elements from saved data
			for element_data in zone_data.element_data:
				var element = add_element(element_data.type, element_data.position)
				element.evolution_factor = element_data.evolution_factor
			
			# Connections would need to be restored after all elements are created
			return true
	return false


# ZoneResource.gd - Resource for saving/loading zone data
class_name ZoneResource
extends Resource

@export var zone_id: String
@export var element_data: Array


# WorldManager.gd - Manages all zones and handles global interactions
class_name WorldManager
extends Node3D

var zones = {}
var active_zone_radius = 100.0  # Distance from camera to keep zones active
var camera: Camera3D

func _ready():
	camera = get_viewport().get_camera_3d()
	load_all_zones()

func _process(delta):
	update_active_zones()

func create_zone(id: String):
	var zone = ElementZone.new(id)
	add_child(zone)
	zones[id] = zone
	return zone

func load_all_zones():
	var dir = DirAccess.open("user://zones")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var zone_id = file_name.get_basename()
				var zone = create_zone(zone_id)
				zone.load_zone()
			file_name = dir.get_next()

func update_active_zones():
	if camera:
		var camera_pos = camera.global_position
		
		# Activate/deactivate zones based on distance from camera
		for id in zones.keys():
			var zone = zones[id]
			var distance = zone.global_position.distance_to(camera_pos)
			
			if distance < active_zone_radius:
				if not zone.is_processing():
					zone.set_process(true)
			else:
				if zone.is_processing():
					zone.set_process(false)
					zone.save_zone()  # Save zone when deactivating

func save_all_zones():
	for id in zones.keys():
		zones[id].save_zone()


# Main.gd - Main scene script
extends Node3D

var world_manager: WorldManager
var selected_element_type = "water"

func _ready():
	world_manager = WorldManager.new()
	add_child(world_manager)
	
	# Create initial zone if none exist
	if world_manager.zones.is_empty():
		var zone = world_manager.create_zone("main")
		
		# Create some starter elements
		for i in range(20):
			var position = Vector3(
				randf_range(-5, 5),
				randf_range(-5, 5),
				randf_range(-5, 5)
			)
			var type = ["water", "fire", "earth", "light", "shadow"][randi() % 5]
			zone.add_element(type, position)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 100.0
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		
		if result:
			# Create element at clicked position
			var zone = world_manager.zones.get("main")
			if zone:
				zone.add_element(selected_element_type, result.position)

func _on_element_type_selected(type):
	selected_element_type = type

func _exit_tree():
	# Save zones before quitting
	if world_manager:
		world_manager.save_all_zones()
