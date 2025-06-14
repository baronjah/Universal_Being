# 🏛️ Universal Being - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: universal_being_minimal.gd
# DESCRIPTION: Minimal working version of Universal Being
# PURPOSE: Test the core concept before full implementation
# ==================================================

extends UniversalBeingBase
class_name UniversalBeing

# Core properties
var uuid: String = ""
var form: String = "void"
var essence: Dictionary = {}

# Visual representation
var manifestation: Node3D = null
var is_manifested: bool = false

# Neural consciousness system (NEW EVOLUTION)
var is_conscious: bool = false
var consciousness_level: int = 0  # 0=none, 1=basic, 2=advanced, 3=collective
var task_manager: Node = null
var physical_embodiment: Node = null
var action_memory: Array[Dictionary] = []
var needs: Dictionary = {}
var current_goal: String = ""
var neural_connections: Array[UniversalBeing] = []

# Signals for neural events
signal consciousness_awakened(being: UniversalBeing)
signal goal_set(goal: String, parameters: Dictionary)
signal action_completed(action: String, success: bool)
signal need_changed(need_name: String, old_value: float, new_value: float)

# Basic initialization
func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	uuid = "being_" + str(Time.get_ticks_msec())
	name = "UniversalBeing_" + uuid

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	"""Main processing loop - handle consciousness if active"""
	if is_conscious:
		think_and_act(delta)
	

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
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
func become(new_form: String) -> void:
	"""Transform into a new form"""
	var old_form = form
	form = new_form
	
	# Create visual manifestation
	manifest(new_form)
	
	print("[", name, "] Transformed from ", old_form, " to ", new_form)

func manifest(form_type: String) -> void:
	"""Create visual representation of this being"""
	print("\n[DEBUG] manifest() called for type: ", form_type)
	
	# Remove old manifestation
	if manifestation:
		manifestation.queue_free()
		manifestation = null
	
	# Try to use StandardizedObjects for known asset types
	var std_objects = get_node_or_null("/root/StandardizedObjects")
	print("[DEBUG] StandardizedObjects found: ", std_objects != null)
	
	if std_objects and std_objects.has_method("create_object"):
		# Check if this is a known asset type
		var has_type = std_objects.object_definitions.has(form_type)
		print("[DEBUG] StandardizedObjects has type '", form_type, "': ", has_type)
		
		if has_type:
			print("[DEBUG] Creating object with StandardizedObjects...")
			manifestation = std_objects.create_object(form_type, global_position)
			if manifestation:
				print("[DEBUG] Manifestation created: ", manifestation.get_class())
				print("[DEBUG] Manifestation children: ", manifestation.get_child_count())
				
				# Remove from world and add as child
				if manifestation.get_parent():
					manifestation.get_parent().remove_child(manifestation)
				add_child(manifestation)
				# Reset local position since parent handles world position
				manifestation.position = Vector3.ZERO
				is_manifested = true
				print("[", name, "] Manifested as ", form_type, " using StandardizedObjects")
				return
			else:
				print("[DEBUG] StandardizedObjects.create_object returned null!")
	
	# Fallback: create basic visual representation
	print("[", name, "] StandardizedObjects not available or type not found, using fallback")
	_create_basic_manifestation(form_type)

func _create_basic_manifestation(form_type: String) -> void:
	"""Create basic visual representation when StandardizedObjects unavailable"""
	var mesh_instance = MeshInstance3D.new()
	
	# Choose mesh based on form type
	match form_type:
		"tree":
			var mesh = BoxMesh.new()
			mesh.size = Vector3(0.5, 3.0, 0.5)
			mesh_instance.mesh = mesh
			var material = MaterialLibrary.get_material("default")
			material.albedo_color = Color(0.4, 0.2, 0.1)  # Brown
			mesh_instance.material_override = material
		"rock":
			var mesh = SphereMesh.new()
			mesh.radius = 0.8
			mesh_instance.mesh = mesh
			var material = MaterialLibrary.get_material("default")
			material.albedo_color = Color(0.5, 0.5, 0.5)  # Gray
			mesh_instance.material_override = material
		_:
			# Default sphere
			var mesh = SphereMesh.new()
			mesh.radius = 0.5
			mesh_instance.mesh = mesh
			var material = MaterialLibrary.get_material("default")
			material.albedo_color = Color(1.0, 0.0, 1.0)  # Magenta for unknown
			mesh_instance.material_override = material
	
	manifestation = mesh_instance
	add_child(manifestation)
	is_manifested = true
	print("[", name, "] Created basic manifestation as ", form_type)

func set_property(key: String, value: Variant) -> void:
	"""Set a property in essence"""
	essence[key] = value

func get_property(key: String, default_value: Variant = null) -> Variant:
	"""Get a property from essence"""
	return essence.get(key, default_value)

func become_interface(interface_type: String, properties: Dictionary = {}) -> void:
	"""Transform into a functional UI interface"""
	var old_form = form
	form = "interface_" + interface_type
	
	# Remove old manifestation
	if manifestation:
		manifestation.queue_free()
		manifestation = null
	
	# Create interface based on type
	match interface_type:
		"asset_creator":
			_create_asset_creator_interface(properties)
		"console":
			_create_console_interface(properties)
		"grid":
			_create_grid_interface(properties)
		"inspector":
			_create_inspector_interface(properties)
		_:
			_create_generic_interface(interface_type, properties)
	
	print("[", name, "] Transformed from ", old_form, " to interface: ", interface_type)

func become_container(container_type: String, size: Vector3 = Vector3(10, 5, 10), properties: Dictionary = {}) -> void:
	"""Transform into a scene container for organizing space"""
	var old_form = form
	form = "container_" + container_type
	
	# Remove old manifestation
	if manifestation:
		manifestation.queue_free()
		manifestation = null
	
	# Create scene container
	var container = load("res://scripts/core/universal_being_scene_container.gd").new()
	container.container_type = container_type
	container.container_size = size
	container.show_boundaries = properties.get("show_boundaries", true)
	container.show_connection_points = properties.get("show_connection_points", true)
	
	manifestation = container
	add_child(manifestation)
	is_manifested = true
	
	# Store container reference for easy access
	set_property("container_reference", container)
	
	print("[", name, "] Transformed from ", old_form, " to container: ", container_type, " with size ", size)

func get_container() -> UniversalBeingSceneContainer:
	"""Get the scene container if this being is a container"""
	return get_property("container_reference", null)

func connect_to(other: UniversalBeing) -> void:
	"""Simple connection (minimal version)"""
	print("[", name, "] Connected to ", other.name)

func freeze() -> void:
	"""Freeze the being (minimal version)"""
	set_process(false)
	print("[", name, "] Frozen")

func unfreeze() -> void:
	"""Unfreeze the being (minimal version)"""
	set_process(true)
	print("[", name, "] Unfrozen")

func _to_string() -> String:
	"""String representation"""
	var status = ""
	if is_conscious:
		status = "conscious_L" + str(consciousness_level)
		if current_goal != "":
			status += "_" + current_goal
	else:
		status = "inactive"
	return "UniversalBeing(" + form + ", " + status + ")"

# ===== NEURAL CONSCIOUSNESS EVOLUTION =====

func become_conscious(level: int = 1) -> void:
	"""Evolve this Universal Being to have consciousness"""
	var old_status = "inactive" if not is_conscious else "level_" + str(consciousness_level)
	is_conscious = true
	consciousness_level = level
	
	# Initialize neural systems based on consciousness level
	match level:
		1:  # Basic consciousness - reactive behaviors
			_initialize_basic_consciousness()
		2:  # Advanced consciousness - goal planning
			_initialize_advanced_consciousness() 
		3:  # Collective consciousness - group coordination
			_initialize_collective_consciousness()
	
	consciousness_awakened.emit(self)
	print("🧠 [", name, "] Consciousness awakened! Level: ", level, " (was ", old_status, ")")

func _initialize_basic_consciousness() -> void:
	"""Set up basic reactive consciousness"""
	needs = {
		"energy": 100.0,
		"safety": 80.0,
		"curiosity": 50.0
	}
	
	# Basic behaviors based on form
	match form:
		"tree":
			needs["nutrients"] = 80.0
			needs["sunlight"] = 60.0
			needs["growth_desire"] = 40.0
		"astral_being":
			needs["hunger"] = 40.0
			needs["companionship"] = 60.0
		"ragdoll", "walker":
			needs["balance"] = 70.0
			needs["movement"] = 50.0
	
	# Start basic thinking process
	set_process(true)

func _initialize_advanced_consciousness() -> void:
	"""Set up advanced goal-oriented consciousness"""
	_initialize_basic_consciousness()
	
	# Try to connect to JSH Task Manager
	var jsh_manager = get_node_or_null("/root/JSHTaskManager")
	if jsh_manager:
		task_manager = jsh_manager
		print("🎯 [", name, "] Connected to JSH Task Manager for advanced planning")
	else:
		# Create simple task manager
		task_manager = _create_simple_task_manager()
	
	# Advanced needs
	needs["goal_achievement"] = 30.0
	needs["learning"] = 40.0

func _initialize_collective_consciousness() -> void:
	"""Set up collective group consciousness"""
	_initialize_advanced_consciousness()
	
	# Advanced social needs
	needs["collective_harmony"] = 50.0
	needs["information_sharing"] = 60.0
	
	print("🌐 [", name, "] Collective consciousness initialized - can coordinate with other beings")

func _create_simple_task_manager() -> Node:
	"""Create basic task manager if JSH not available"""
	var simple_manager = Node.new()
	simple_manager.name = "SimpleTaskManager"
	simple_manager.set_script(load("res://scripts/neural/simple_task_manager.gd"))
	add_child(simple_manager)
	return simple_manager

func connect_to_body(body: Node3D) -> void:
	"""Connect consciousness to physical embodiment"""
	physical_embodiment = body
	
	# Try to find walker or ragdoll systems
	var walker = body.get_node_or_null("SimpleWalker") 
	if not walker:
		walker = body.get_node_or_null("Walker")
	if not walker:
		walker = body.get_node_or_null("RagdollWalker")
	
	if walker:
		print("🚶 [", name, "] Connected to physical walker system: ", walker.name)
		# Connect walker signals to consciousness
		if walker.has_signal("walking_started"):
			walker.walking_started.connect(_on_body_action_started.bind("walking"))
		if walker.has_signal("walking_stopped"):
			walker.walking_stopped.connect(_on_body_action_completed.bind("walking", true))
	
	# Connect to ragdoll system
	if body.has_meta("body_parts"):
		print("🦴 [", name, "] Connected to ragdoll physics system")
		# Can control individual body parts through consciousness

func think_and_act(delta: float) -> void:
	"""Main consciousness processing loop"""
	if not is_conscious:
		return
	
	# Update needs over time
	_update_needs(delta)
	
	# Make decisions based on consciousness level
	match consciousness_level:
		1:
			_process_basic_thoughts(delta)
		2:
			_process_advanced_thoughts(delta)  
		3:
			_process_collective_thoughts(delta)

func _process_basic_thoughts(delta: float) -> void:
	"""Basic reactive consciousness"""
	# Find most urgent need
	var most_urgent_need = ""
	var lowest_value = 1000.0
	
	for need_name in needs:
		if needs[need_name] < lowest_value:
			lowest_value = needs[need_name]
			most_urgent_need = need_name
	
	# React to urgent needs
	if lowest_value < 30.0:
		_react_to_urgent_need(most_urgent_need)

func _process_advanced_thoughts(delta: float) -> void:
	"""Advanced goal-oriented consciousness"""
	_process_basic_thoughts(delta)
	
	# Goal-oriented behavior
	if current_goal == "" or randf() < 0.1:
		_set_new_goal()
	
	# Execute current goal using task manager
	if task_manager and current_goal != "":
		_execute_goal_with_brain()

func _process_collective_thoughts(delta: float) -> void:
	"""Collective group consciousness"""
	_process_advanced_thoughts(delta)
	
	# Share information with connected beings
	for connected_being in neural_connections:
		if connected_being and connected_being.is_conscious:
			_share_consciousness_data(connected_being)

func _set_new_goal() -> void:
	"""Set a new goal based on form and needs"""
	match form:
		"tree":
			if needs.get("growth_desire", 0) > 60:
				current_goal = "grow_fruit"
			elif needs.get("nutrients", 0) < 40:
				current_goal = "gather_nutrients"
			else:
				current_goal = "provide_ecosystem_service"
		
		"astral_being":
			if needs.get("hunger", 0) > 50:
				current_goal = "seek_food"
			elif needs.get("curiosity", 0) > 70:
				current_goal = "explore_environment"
			else:
				current_goal = "help_others"
		
		"ragdoll", "humanoid":
			if needs.get("balance", 0) < 30:
				current_goal = "improve_balance"
			elif needs.get("movement", 0) > 60:
				current_goal = "practice_walking"
			else:
				current_goal = "learn_new_skill"
		
		"bird":
			if needs.get("hunger", 0) > 60:
				current_goal = "find_food"
			elif needs.get("safety", 0) < 40:
				current_goal = "find_safe_space"
			else:
				current_goal = "explore_territory"
		
		_:
			current_goal = "understand_environment"
	
	goal_set.emit(current_goal, {})
	print("🎯 [", name, "] New goal set: ", current_goal)

func _execute_goal_with_brain() -> void:
	"""Use task manager (brain) to plan and execute current goal"""
	if not task_manager:
		return
	
	match current_goal:
		"grow_fruit":
			_execute_tree_grow_fruit_conscious()
		"seek_food":
			_execute_astral_seek_food_conscious()
		"improve_balance":
			_execute_ragdoll_balance_conscious()
		"practice_walking":
			_execute_ragdoll_walking_conscious()
		"find_food":
			_execute_bird_find_food_conscious()

func _execute_tree_grow_fruit_conscious() -> void:
	"""Tree uses consciousness to grow fruit systematically"""
	print("🌳 [", name, "] Conscious fruit growing process...")
	
	# Use task manager to plan multi-step process
	if task_manager.has_method("create_task"):
		var fruit_task = task_manager.create_task("fruit_growing_conscious")
		
		# Add steps if task manager supports it
		if task_manager.has_method("add_task_step"):
			task_manager.add_task_step("assess_nutrients", 2.0)
			task_manager.add_task_step("channel_energy", 3.0)
			task_manager.add_task_step("manifest_fruit_being", 2.0)
			task_manager.add_task_step("gift_consciousness", 1.0)
	
	# Schedule fruit creation
	var timer = TimerManager.get_timer()
	add_child(timer)
	timer.wait_time = 8.0
	timer.one_shot = true
	timer.timeout.connect(_spawn_conscious_fruit)
	timer.start()
	
	# Update needs
	needs["growth_desire"] = max(0, needs["growth_desire"] - 30)
	needs["energy"] = max(0, needs["energy"] - 20)

func _spawn_conscious_fruit() -> void:
	"""Spawn a conscious fruit Universal Being"""
	var fruit_being = UniversalBeing.new()
	fruit_being.become("fruit")
	fruit_being.become_conscious(1)  # Give it basic consciousness!
	fruit_being.global_position = global_position + Vector3(randf_range(-1.5, 1.5), 2.5, randf_range(-1.5, 1.5))
	get_parent().add_child(fruit_being)
	
	print("🍎✨ [", name, "] Spawned CONSCIOUS fruit being!")
	action_completed.emit("grow_fruit", true)

func _execute_astral_seek_food_conscious() -> void:
	"""Astral being uses consciousness to intelligently seek food"""
	print("👻 [", name, "] Conscious food seeking...")
	
	# Scan environment for food sources
	var food_sources = []
	for child in get_parent().get_children():
		if child.is_in_group("fruit") or child.is_in_group("food"):
			food_sources.append(child)
	
	if food_sources.size() == 0:
		print("👻 [", name, "] No food sources detected")
		current_goal = "explore_environment"
		return
	
	# Choose best food source using consciousness
	var best_food = null
	var best_score = -1
	
	for food in food_sources:
		var distance = global_position.distance_to(food.global_position)
		var score = 100.0 / (distance + 1.0)  # Closer is better
		
		# Prefer conscious fruit (higher quality)
		if food is UniversalBeing and food.is_conscious:
			score *= 2.0
			
		if score > best_score:
			best_score = score
			best_food = food
	
	# Navigate to best food using physical embodiment
	if best_food and physical_embodiment:
		print("👻 [", name, "] Navigating to best food source: ", best_food.name)
		
		# Use walker/bird navigation if available
		if physical_embodiment.has_method("navigate_to"):
			physical_embodiment.navigate_to(best_food.global_position)
		elif physical_embodiment.has_method("set_target"):
			physical_embodiment.set_target(best_food.global_position)
		
		# Schedule consumption
		var timer = TimerManager.get_timer()
		add_child(timer)
		timer.wait_time = 3.0
		timer.one_shot = true
		timer.timeout.connect(_consume_food.bind(best_food))
		timer.start()

func _consume_food(food_item: Node3D) -> void:
	"""Consume food and gain energy"""
	if food_item and is_instance_valid(food_item):
		# Gain energy from food
		needs["hunger"] = max(0, needs["hunger"] - 40)
		needs["energy"] = min(100, needs["energy"] + 30)
		
		# If consuming conscious fruit, gain consciousness benefits
		if food_item is UniversalBeing and food_item.is_conscious:
			consciousness_level = min(3, consciousness_level + 0.1)
			print("✨ [", name, "] Gained consciousness from consuming conscious fruit!")
		
		# Remove food item
		food_item.queue_free()
		action_completed.emit("seek_food", true)
		current_goal = ""  # Goal accomplished

func _execute_ragdoll_balance_conscious() -> void:
	"""Ragdoll uses consciousness to improve balance"""
	print("🦴 [", name, "] Conscious balance improvement...")
	
	if physical_embodiment:
		# Use ragdoll walker system
		if physical_embodiment.has_method("stand_up"):
			physical_embodiment.stand_up()
			print("🦴 [", name, "] Standing up consciously")
		
		# Check for walker component
		var walker = physical_embodiment.get_node_or_null("SimpleWalker")
		if walker and walker.has_method("get_status"):
			var status = walker.get_status()
			print("🦴 [", name, "] Walker status: ", status)
	
	# Update needs based on action
	needs["balance"] = min(100, needs["balance"] + 20)
	action_completed.emit("improve_balance", true)

func _execute_ragdoll_walking_conscious() -> void:
	"""Ragdoll uses consciousness to practice walking"""
	print("🚶 [", name, "] Conscious walking practice...")
	
	if physical_embodiment:
		var walker = physical_embodiment.get_node_or_null("SimpleWalker")
		if walker:
			# Set a random target for practice
			var practice_target = global_position + Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
			
			if walker.has_method("set_target_position"):
				walker.set_target_position(practice_target)
			elif walker.has_method("start_walking"):
				walker.start_walking()
			
			print("🚶 [", name, "] Started conscious walking practice")
	
	needs["movement"] = max(0, needs["movement"] - 25)
	needs["learning"] = min(100, needs["learning"] + 15)

func _execute_bird_find_food_conscious() -> void:
	"""Bird uses consciousness to systematically find food"""
	print("🐦 [", name, "] Conscious food searching...")
	
	# Use bird body for food detection
	if physical_embodiment and physical_embodiment.has_method("start_flying"):
		# Take to the air for better search
		physical_embodiment.start_flying()
		print("🐦 [", name, "] Flying to search for food")
	
	# Scan for food sources
	var food_sources = _scan_for_food()
	if food_sources.size() > 0:
		var closest_food = food_sources[0]
		var closest_distance = global_position.distance_to(closest_food.global_position)
		
		for food in food_sources:
			var distance = global_position.distance_to(food.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_food = food
		
		# Navigate to closest food
		if physical_embodiment and physical_embodiment.has_method("navigate_to"):
			physical_embodiment.navigate_to(closest_food.global_position)
		
		print("🐦 [", name, "] Found food, navigating to: ", closest_food.name)

func _scan_for_food() -> Array:
	"""Scan environment for food sources"""
	var food_sources = []
	for child in get_parent().get_children():
		if child.is_in_group("fruit") or child.is_in_group("food") or child.form == "fruit":
			food_sources.append(child)
	return food_sources

func _react_to_urgent_need(need_name: String) -> void:
	"""React to urgent needs immediately"""
	match need_name:
		"energy":
			if form in ["astral_being", "bird"]:
				current_goal = "seek_food"
		"balance":
			if physical_embodiment and physical_embodiment.has_method("stand_up"):
				physical_embodiment.stand_up()
		"safety":
			# Move to safer position
			global_position.y += 1.0

func _update_needs(delta: float) -> void:
	"""Update needs over time"""
	for need_name in needs:
		# Natural decay of satisfaction
		var decay_rate = 5.0  # Needs decrease over time
		var old_value = needs[need_name]
		needs[need_name] = max(0, needs[need_name] - decay_rate * delta)
		
		if abs(old_value - needs[need_name]) > 1.0:
			need_changed.emit(need_name, old_value, needs[need_name])

func _share_consciousness_data(other_being: UniversalBeing) -> void:
	"""Share consciousness information with connected being"""
	if randf() < 0.1:  # Don't spam - share occasionally
		# Share discovered food locations
		var my_known_food = _scan_for_food()
		if my_known_food.size() > 0:
			other_being.receive_shared_information("food_locations", my_known_food)

func receive_shared_information(info_type: String, _data: Variant) -> void:
	"""Receive shared information from other conscious beings"""
	match info_type:
		"food_locations":
			if form in ["astral_being", "bird"] and current_goal == "seek_food":
				var food_list = _data as Array
				if food_list.size() > 0:
					print("🧠 [", name, "] Received food location data from neural network")

# Helper methods
func _on_body_action_started(action: String) -> void:
	"""Handle signals from physical embodiment"""
	print("🎬 [", name, "] Body started action: ", action)

func _on_body_action_completed(action: String, success: bool) -> void:
	"""Handle completed actions from physical embodiment"""
	print("✅ [", name, "] Body completed action: ", action, " (success: ", success, ")")
	action_completed.emit(action, success)
	
	if success:
		# Positive reinforcement
		consciousness_level = min(3, consciousness_level + 0.05)

# Public consciousness API
func get_consciousness_status() -> String:
	"""Get detailed consciousness status for debugging"""
	if not is_conscious:
		return "Unconscious"
	
	var status = "Conscious L" + str(consciousness_level)
	status += " | Goal: " + current_goal
	status += " | Brain: " + ("Connected" if task_manager else "None")
	status += " | Body: " + ("Connected" if physical_embodiment else "None")
	
	if needs.size() > 0:
		status += " | Needs: "
		for need_name in needs:
			status += need_name + ":" + str(int(needs[need_name])) + " "
	
	return status

# DUPLICATE REMOVED - _process_collective_thoughts already defined at line 365

# DUPLICATE REMOVED - _react_to_urgent_need already defined at line 612

func _start_action(action_name: String) -> void:
	"""Start an action based on consciousness"""
	print("🎬 [", name, "] Starting action: ", action_name)
	current_goal = action_name
	
	# Form-specific action execution
	match action_name:
		"grow_fruit":
			_execute_grow_fruit_action()
		"seek_food":
			_execute_seek_food_action()
		"walk_around":
			_execute_walk_action()
		"stabilize":
			_execute_balance_action()
	
	goal_set.emit(action_name, {})

func _execute_grow_fruit_action() -> void:
	"""Tree consciousness grows fruit"""
	if form == "tree" and manifestation:
		print("🌳 [", name, "] Consciousness initiating fruit growth...")
		
		# Multi-step process for growing fruit
		if task_manager:
			# Use advanced task system
			var grow_task = {
				"name": "grow_fruit",
				"steps": [
					{"action": "gather_nutrients", "duration": 3.0},
					{"action": "form_fruit_being", "duration": 2.0},
					{"action": "mature_fruit", "duration": 1.0}
				]
			}
			# Task manager would handle this
		
		# Simple version: create fruit being after delay
		get_tree().create_timer(2.0).timeout.connect(_spawn_fruit_being)
		needs["growth_desire"] = 100.0  # Satisfied

func _spawn_fruit_being() -> void:
	"""Spawn a fruit Universal Being"""
	var fruit_being = UniversalBeing.new()
	fruit_being.global_position = global_position + Vector3(0, 2, 0)
	fruit_being.become("fruit")
	get_parent().add_child(fruit_being)
	
	print("🍎 [", name, "] Fruit being born through consciousness!")
	_complete_action("grow_fruit", true)

func _execute_seek_food_action() -> void:
	"""Astral being consciousness seeks food"""
	if form == "astral_being":
		print("👻 [", name, "] Consciousness seeking food...")
		
		# Scan environment for fruit beings
		var fruits = get_tree().get_nodes_in_group("fruit")
		if fruits.size() > 0:
			var closest_fruit = fruits[0]
			var closest_distance = global_position.distance_to(closest_fruit.global_position)
			
			for fruit in fruits:
				var distance = global_position.distance_to(fruit.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_fruit = fruit
			
			# Move towards fruit using physical body
			if physical_embodiment:
				_move_body_towards(closest_fruit.global_position)
		else:
			# No food found, wander randomly
			var random_pos = global_position + Vector3(
				randf_range(-5, 5), 0, randf_range(-5, 5)
			)
			if physical_embodiment:
				_move_body_towards(random_pos)

func _execute_walk_action() -> void:
	"""Move the body through consciousness"""
	if physical_embodiment:
		var walker = physical_embodiment.get_node_or_null("SimpleWalker")
		if walker and walker.has_method("start_walking"):
			var random_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
			walker.start_walking(random_direction)
			print("🚶 [", name, "] Consciousness initiated walking")

func _execute_balance_action() -> void:
	"""Stabilize the physical body"""
	if physical_embodiment:
		var walker = physical_embodiment.get_node_or_null("SimpleWalker")
		if walker and walker.has_method("stabilize"):
			walker.stabilize()
			needs["balance"] = 100.0
			print("⚖️ [", name, "] Consciousness restored balance")

func _move_body_towards(target_position: Vector3) -> void:
	"""Move physical body towards target"""
	if not physical_embodiment:
		return
	
	var direction = (target_position - global_position).normalized()
	
	# Try different movement systems
	var walker = physical_embodiment.get_node_or_null("SimpleWalker")
	if walker:
		if walker.has_method("walk_towards"):
			walker.walk_towards(target_position)
		elif walker.has_method("set_movement_direction"):
			walker.set_movement_direction(direction)

# DUPLICATE REMOVED - _update_needs already defined at line 625

func _complete_action(action_name: String, success: bool) -> void:
	"""Complete an action and learn from it"""
	current_goal = ""
	action_completed.emit(action_name, success)
	
	# Record in action memory
	action_memory.append({
		"action": action_name,
		"success": success,
		"timestamp": Time.get_ticks_msec(),
		"needs_before": needs.duplicate(),
		"form": form
	})
	
	# Keep memory limited
	if action_memory.size() > 10:
		action_memory.pop_front()
	
	print("✅ [", name, "] Action completed: ", action_name, " (success: ", success, ")")

func _plan_new_goal() -> void:
	"""Plan new goal using advanced consciousness"""
	# Analyze current situation and plan appropriate action
	var most_urgent = _find_most_urgent_need()
	
	if most_urgent == "":
		return
	
	# Plan based on past experience
	var best_action = _find_best_action_for_need(most_urgent)
	if best_action != "":
		_start_action(best_action)

func _find_most_urgent_need() -> String:
	"""Find the most urgent need"""
	var most_urgent = ""
	var lowest_value = 1000.0
	
	for need_name in needs:
		if needs[need_name] < lowest_value:
			lowest_value = needs[need_name]
			most_urgent = need_name
	
	return most_urgent if lowest_value < 50.0 else ""

func _find_best_action_for_need(need_name: String) -> String:
	"""Find best action based on memory"""
	# Check action memory for successful actions
	for memory in action_memory:
		if memory.success and memory.needs_before.has(need_name):
			if memory.needs_before[need_name] < 50.0:  # Was urgent before
				return memory.action
	
	# Fallback to basic reactions
	match need_name:
		"hunger": return "seek_food"
		"growth_desire": return "grow_fruit"
		"movement": return "walk_around"
		"balance": return "stabilize"
		_: return ""

func connect_neural_pathway(other_being: UniversalBeing) -> void:
	"""Create neural connection with another conscious being"""
	if other_being.is_conscious and other_being not in neural_connections:
		neural_connections.append(other_being)
		other_being.neural_connections.append(self)
		print("🔗 [", name, "] Neural pathway established with ", other_being.name)

func _share_information_with(other_being: UniversalBeing) -> void:
	"""Share consciousness information with connected being"""
	if consciousness_level >= 3:  # Collective consciousness
		# Share urgent needs
		for need_name in needs:
			if needs[need_name] < 30.0 and other_being.needs.has(need_name):
				if other_being.needs[need_name] > 70.0:
					# Other being can help
					print("📡 [", name, "] Requesting help with ", need_name, " from ", other_being.name)

# Body interaction callbacks
# DUPLICATE REMOVED - _on_body_action_started already defined at line 654

# DUPLICATE REMOVED - _on_body_action_completed already defined at line 658

# DUPLICATE REMOVED - _process already defined at line 40

# ----- INTERFACE MANIFESTATION FUNCTIONS -----
func _create_asset_creator_interface(properties: Dictionary) -> void:
	"""Create an enhanced asset creator interface"""
	var enhanced_interface = load("res://scripts/core/enhanced_interface_system.gd").new()
	enhanced_interface.setup_interface_type("asset_creator", self)
	enhanced_interface.position = Vector3(0, 0, 0)
	
	# Connect interface signals
	enhanced_interface.interface_button_clicked.connect(_on_interface_interaction)
	enhanced_interface.interface_value_changed.connect(_on_interface_value_changed)
	
	manifestation = enhanced_interface
	add_child(manifestation)
	is_manifested = true
	print("🎨 [", name, "] Enhanced Asset Creator Interface created")

func _create_console_interface(properties: Dictionary) -> void:
	"""Create an enhanced console interface"""
	var enhanced_interface = load("res://scripts/core/enhanced_interface_system.gd").new()
	enhanced_interface.setup_interface_type("console", self)
	enhanced_interface.position = Vector3(0, 0, 0)
	
	# Connect interface signals
	enhanced_interface.interface_button_clicked.connect(_on_interface_interaction)
	enhanced_interface.interface_value_changed.connect(_on_interface_value_changed)
	
	manifestation = enhanced_interface
	add_child(manifestation)
	is_manifested = true
	print("💻 [", name, "] Enhanced Console Interface created")

func _create_grid_interface(properties: Dictionary) -> void:
	"""Create an enhanced grid interface"""
	var enhanced_interface = load("res://scripts/core/enhanced_interface_system.gd").new()
	enhanced_interface.setup_interface_type("grid_list", self)
	enhanced_interface.position = Vector3(0, 0, 0)
	
	enhanced_interface.interface_button_clicked.connect(_on_interface_interaction)
	enhanced_interface.interface_value_changed.connect(_on_interface_value_changed)
	
	manifestation = enhanced_interface
	add_child(manifestation)
	is_manifested = true
	print("📊 [", name, "] Enhanced Grid Interface created")

func _create_inspector_interface(properties: Dictionary) -> void:
	"""Create an enhanced inspector interface"""
	var enhanced_interface = load("res://scripts/core/enhanced_interface_system.gd").new()
	enhanced_interface.setup_interface_type("being_inspector", self)
	enhanced_interface.position = Vector3(0, 0, 0)
	
	enhanced_interface.interface_button_clicked.connect(_on_interface_interaction)
	enhanced_interface.interface_value_changed.connect(_on_interface_value_changed)
	
	manifestation = enhanced_interface
	add_child(manifestation)
	is_manifested = true
	print("🔍 [", name, "] Enhanced Inspector Interface created")

func _create_generic_interface(interface_type: String, properties: Dictionary) -> void:
	"""Create an enhanced generic interface"""
	var enhanced_interface = load("res://scripts/core/enhanced_interface_system.gd").new()
	enhanced_interface.setup_interface_type("system_monitor", self)
	enhanced_interface.position = Vector3(0, 0, 0)
	
	enhanced_interface.interface_button_clicked.connect(_on_interface_interaction)
	enhanced_interface.interface_value_changed.connect(_on_interface_value_changed)
	
	manifestation = enhanced_interface
	add_child(manifestation)
	is_manifested = true
	print("🖥️ [", name, "] Enhanced Generic Interface created: ", interface_type)

func _create_basic_interface_fallback(interface_type: String) -> void:
	"""Create a basic cube representation for interfaces"""
	var mesh_instance = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(2.0, 1.5, 0.1)  # Flat panel shape
	mesh_instance.mesh = mesh
	
	# Create material with interface color
	var material = MaterialLibrary.get_material("default")
	match interface_type:
		"asset_creator":
			material.albedo_color = Color(1.0, 0.5, 0.0)  # Orange
		"console":
			material.albedo_color = Color(0.0, 1.0, 1.0)  # Cyan
		"grid":
			material.albedo_color = Color(0.0, 1.0, 0.0)  # Green
		"inspector":
			material.albedo_color = Color(1.0, 1.0, 0.0)  # Yellow
		_:
			material.albedo_color = Color(0.7, 0.7, 0.7)  # Gray
	
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.3
	mesh_instance.material_override = material
	
	manifestation = mesh_instance
	add_child(manifestation)
	is_manifested = true
	print("[", name, "] Created basic interface manifestation: ", interface_type)

# ----- INTERFACE INTERACTION HANDLERS -----
func _on_interface_clicked(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int, panel: Control) -> void:
	"""Handle clicks on 3D interfaces"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Toggle panel visibility or focus
		if panel:
			panel.visible = !panel.visible
			print("[", name, "] Interface clicked - toggled visibility")

func _on_interface_hover_start() -> void:
	"""Handle mouse entering interface"""
	if manifestation and manifestation.has_node("AssetCreatorInterface"):
		var sprite = manifestation.get_node("AssetCreatorInterface")
		if sprite is Sprite3D:
			sprite.modulate = Color(1.2, 1.2, 1.2)  # Brighten on hover

func _on_interface_hover_end() -> void:
	"""Handle mouse leaving interface"""
	if manifestation and manifestation.has_node("AssetCreatorInterface"):
		var sprite = manifestation.get_node("AssetCreatorInterface")
		if sprite is Sprite3D:
			sprite.modulate = Color.WHITE  # Reset color

# ===== ENHANCED INTERFACE INTERACTION HANDLERS =====

func _on_interface_interaction(button_id: String, _data: Dictionary) -> void:
	"""Handle interactions from enhanced interfaces"""
	print("🖱️ [", name, "] Interface interaction: ", button_id, " with data: ", _data)
	
	match button_id:
		"console_execute":
			_handle_console_command(_data.get("command", ""))
		"create_asset":
			_handle_asset_creation(_data)
		"quick_action":
			_handle_quick_action(_data.get("action", ""))
		"neural_status":
			_handle_neural_status_request()
		"refresh_neural":
			_refresh_neural_displays()

func _on_interface_value_changed(element_id: String, new_value: Variant) -> void:
	"""Handle value changes in interface elements"""
	print("📊 [", name, "] Interface value changed: ", element_id, " = ", new_value)
	
	# Update manifestation based on changes
	if manifestation and manifestation.has_method("update_display_data"):
		manifestation.update_display_data({element_id: new_value})

func _handle_console_command(command: String) -> void:
	"""Handle console commands from interface"""
	var console_manager = get_node_or_null("/root/ConsoleManager")
	if console_manager and console_manager.has_method("execute_command"):
		console_manager.execute_command(command)
		print("💻 [", name, "] Executed console command: ", command)

func _handle_asset_creation(asset_data: Dictionary) -> void:
	"""Handle asset creation from interface"""
	var size_x = asset_data.get("size_x", 1.0)
	var size_y = asset_data.get("size_y", 1.0) 
	var size_z = asset_data.get("size_z", 1.0)
	
	# Create new Universal Being with specified size
	var new_asset = UniversalBeing.new()
	new_asset.global_position = global_position + Vector3(3, 0, 0)
	new_asset.become("custom_asset")
	
	# Scale the manifestation if it exists
	if new_asset.manifestation:
		new_asset.manifestation.scale = Vector3(size_x, size_y, size_z)
	
	get_parent().add_child(new_asset)
	print("🏗️ [", name, "] Created asset with size: ", Vector3(size_x, size_y, size_z))

func _handle_quick_action(action: String) -> void:
	"""Handle quick action buttons"""
	match action:
		"neural_status":
			_create_neural_status_interface()
		"test_consciousness":
			_run_consciousness_test()

func _handle_neural_status_request() -> void:
	"""Create a neural status interface being"""
	var status_being = UniversalBeing.new()
	status_being.global_position = global_position + Vector3(0, 0, 4)
	status_being.become_interface("neural_status")
	get_parent().add_child(status_being)
	print("🧠 [", name, "] Created neural status interface")

func _refresh_neural_displays() -> void:
	"""Refresh all neural status displays"""
	var scene = get_tree().current_scene
	_refresh_neural_interfaces_recursive(scene)

func _refresh_neural_interfaces_recursive(node: Node) -> void:
	"""Recursively refresh neural interfaces"""
	if node is UniversalBeing and node.form.begins_with("interface_neural"):
		if node.manifestation and node.manifestation.has_method("update_display_data"):
			node.manifestation.update_display_data({})
	
	for child in node.get_children():
		_refresh_neural_interfaces_recursive(child)

func _create_neural_status_interface() -> void:
	"""Create a dedicated neural status interface"""
	var neural_interface = UniversalBeing.new()
	neural_interface.global_position = global_position + Vector3(-4, 2, 0)
	neural_interface.become_interface("neural_status")
	get_parent().add_child(neural_interface)
	print("🧠📊 [", name, "] Neural status interface spawned")

func _run_consciousness_test() -> void:
	"""Run the consciousness ecosystem test"""
	var console_manager = get_node_or_null("/root/ConsoleManager")
	if console_manager and console_manager.has_method("execute_command"):
		console_manager.execute_command("test_consciousness")
	print("🧪 [", name, "] Running consciousness test")

# ===== ENHANCED INTERFACE EVOLUTION METHODS =====

func evolve_to_system_interface(system_name: String) -> void:
	"""Evolve this Universal Being into a system interface"""
	var old_form = form
	form = "interface_" + system_name
	
	# Remove old manifestation
	if manifestation:
		manifestation.queue_free()
		manifestation = null
	
	# Create enhanced interface
	var enhanced_interface = load("res://scripts/core/enhanced_interface_system.gd").new()
	
	# Determine interface type based on system
	var interface_type = "system_monitor"
	match system_name:
		"console", "terminal":
			interface_type = "console"
		"asset_creator", "creator":
			interface_type = "asset_creator"
		"neural", "consciousness":
			interface_type = "neural_status"
		"inspector", "debug":
			interface_type = "being_inspector"
		"grid", "list":
			interface_type = "grid_list"
	
	enhanced_interface.setup_interface_type(interface_type, self)
	enhanced_interface.interface_button_clicked.connect(_on_interface_interaction)
	enhanced_interface.interface_value_changed.connect(_on_interface_value_changed)
	
	# Connect to relevant systems
	_connect_interface_to_systems(enhanced_interface, system_name)
	
	manifestation = enhanced_interface
	add_child(manifestation)
	is_manifested = true
	
	print("🔄 [", name, "] Evolved from ", old_form, " to ", system_name, " interface")

func _connect_interface_to_systems(interface: EnhancedInterfaceSystem, system_name: String) -> void:
	"""Connect interface to relevant game systems"""
	match system_name:
		"console":
			var console_manager = get_node_or_null("/root/ConsoleManager")
			if console_manager:
				interface.connect_to_system("console", console_manager)
		
		"neural":
			# Connect to all conscious beings
			var conscious_beings = []
			_find_all_conscious_beings(get_tree().current_scene, conscious_beings)
			for being in conscious_beings:
				interface.connect_to_system("being_" + being.name, being)
		
		"asset_creator":
			var world_builder = get_node_or_null("/root/WorldBuilder")
			if world_builder:
				interface.connect_to_system("world_builder", world_builder)
		
		"inspector":
			var object_manager = get_node_or_null("/root/UniversalObjectManager")
			if object_manager:
				interface.connect_to_system("object_manager", object_manager)

func _find_all_conscious_beings(node: Node, conscious_beings: Array) -> void:
	"""Find all conscious Universal Beings (helper method)"""
	if node is UniversalBeing and node.is_conscious:
		conscious_beings.append(node)
	
	for child in node.get_children():
		_find_all_conscious_beings(child, conscious_beings)

# ===== INTERFACE UTILITY METHODS =====

func make_interface_always_face_camera() -> void:
	"""Make interface always face the camera"""
	if manifestation:
		manifestation.look_at(get_viewport().get_camera_3d().global_position, Vector3.UP)

func set_interface_transparency(alpha: float) -> void:
	"""Set interface transparency"""
	alpha = clamp(alpha, 0.0, 1.0)
	if manifestation and manifestation.has_method("set_interface_alpha"):
		manifestation.set_interface_alpha(alpha)

func get_interface_type() -> String:
	"""Get the current interface type"""
	if form.begins_with("interface_"):
		return form.substr(10)  # Remove "interface_" prefix
	return ""

func is_interface() -> bool:
	"""Check if this Universal Being is an interface"""
	return form.begins_with("interface_")
