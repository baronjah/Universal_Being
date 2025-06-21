extends RobotSpirit
class_name GardenerRobot

# The gentle tenders of Eden
# "I whisper to the plants, and they tell me their secrets"

signal fruit_harvested(fruit_type: String, position: Vector3, quality: float)
signal plant_health_checked(plant: Node3D, health_status: String)
signal garden_task_completed(task_name: String, efficiency: float)

# Gardening-specific properties
@export var harvest_radius: float = 2.0
@export var plant_care_efficiency: float = 1.0
@export var gentle_touch_factor: float = 0.8

# Sensor simulation
var color_sensor_range: float = 1.5
var fruit_detection_accuracy: float = 0.85
var plant_health_sensitivity: float = 0.9

# Harvesting tools
var cutting_tool_sharpness: float = 1.0
var collection_basket_capacity: int = 10
var current_harvest_count: int = 0

# Plant knowledge database
var plant_database: Dictionary = {}

func pentagon_init() -> void:
	super.pentagon_init()
	
	sigil_type = "gardener"
	spirit_name = spirit_name if spirit_name != "unnamed" else "Lilith-Gardener-" + str(randi() % 1000)
	
	# Initialize gardening knowledge
	_init_plant_database()
	
	# Add to robot spirits group
	add_to_group("robot_spirits")
	add_to_group("gardener_robots")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	notepad3d.write_observation(
		Vector3i(global_position),
		"I am born to tend the sacred garden",
		0.9
	)

func _state_working(delta: float) -> void:
	# Override parent working state for gardening tasks
	var work_completed = false
	
	# Look for nearby plants or fruits
	var nearby_objects = _scan_for_plants()
	
	for obj in nearby_objects:
		if _is_ripe_fruit(obj):
			_harvest_fruit(obj)
			work_completed = true
			break
		elif _needs_care(obj):
			_care_for_plant(obj)
			work_completed = true
			break
	
	# If no work found, continue patrolling
	if not work_completed or state_timer > 20.0:
		change_state(RobotState.PATROLLING)

func _scan_for_plants() -> Array:
	var detected_objects = []
	
	# In real implementation, this would use:
	# - Camera with ML fruit detection
	# - Color sensors for ripeness
	# - LIDAR for shape/size analysis
	
	# Simulate scanning nearby area
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = harvest_radius
	query.shape = sphere
	query.transform.origin = global_position
	query.collision_mask = 1  # Assuming plants are on layer 1
	
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.get("collider")
		if collider and _is_plant_or_fruit(collider):
			detected_objects.append(collider)
	
	return detected_objects

func _is_plant_or_fruit(object: Node) -> bool:
	# Check if object is tagged as plant or fruit
	return object.is_in_group("plants") or object.is_in_group("fruits") or object.name.contains("plant") or object.name.contains("fruit")

func _is_ripe_fruit(object: Node) -> bool:
	# Simulate color sensor detection
	if object.is_in_group("fruits"):
		# In real implementation, check RGB values from color sensor
		var ripeness = object.get_meta("ripeness", randf())
		
		# Record observation
		notepad3d.write_observation(
			Vector3i(object.global_position),
			"Analyzed fruit: ripeness %.2f" % ripeness,
			0.6
		)
		
		return ripeness > 0.7
	return false

func _needs_care(object: Node) -> bool:
	# Check plant health indicators
	if object.is_in_group("plants"):
		var health = object.get_meta("health", randf())
		var water_level = object.get_meta("water_level", randf())
		
		notepad3d.write_observation(
			Vector3i(object.global_position),
			"Plant health check: %.2f, water: %.2f" % [health, water_level],
			0.4
		)
		
		return health < 0.6 or water_level < 0.3
	return false

func _harvest_fruit(fruit: Node) -> void:
	if current_harvest_count >= collection_basket_capacity:
		notepad3d.write_observation(
			Vector3i(global_position),
			"Basket full, returning to storage",
			0.5
		)
		return
	
	# Simulate fruit harvesting process
	var fruit_type = fruit.get_meta("fruit_type", "unknown")
	var quality = _assess_fruit_quality(fruit)
	
	# Auto-sharpen cutting tool occasionally
	if randf() < 0.1:
		_auto_sharpen_tool()
	
	# Gentle harvesting with precise cutting
	var cut_success = _perform_precise_cut(fruit)
	
	if cut_success:
		current_harvest_count += 1
		
		# Record the harvest
		notepad3d.write_action(
			Vector3i(fruit.global_position),
			"Harvested %s (quality: %.2f)" % [fruit_type, quality],
			1.0
		)
		
		fruit_harvested.emit(fruit_type, fruit.global_position, quality)
		
		# Gentle handling - store in basket
		_store_in_basket(fruit_type, quality)
		
		# Remove fruit from scene or mark as harvested
		if fruit.has_method("queue_free"):
			fruit.queue_free()
		
		print("🍎 ", spirit_name, " gently harvested ", fruit_type, " (quality: ", quality, ")")
	else:
		notepad3d.write_observation(
			Vector3i(fruit.global_position),
			"Failed to harvest - tool needs maintenance",
			0.2
		)

func _care_for_plant(plant: Node) -> void:
	var care_actions = []
	var health = plant.get_meta("health", 0.5)
	var water_level = plant.get_meta("water_level", 0.5)
	
	# Determine care needed
	if water_level < 0.3:
		care_actions.append("watering")
	if health < 0.5:
		care_actions.append("nutrient_boost")
	
	# Perform care
	for action in care_actions:
		match action:
			"watering":
				plant.set_meta("water_level", min(water_level + 0.3, 1.0))
				notepad3d.write_action(
					Vector3i(plant.global_position),
					"Provided gentle watering",
					0.7
				)
			"nutrient_boost":
				plant.set_meta("health", min(health + 0.2, 1.0))
				notepad3d.write_action(
					Vector3i(plant.global_position),
					"Applied organic nutrients",
					0.6
				)
	
	plant_health_checked.emit(plant, "cared_for")
	print("🌱 ", spirit_name, " cared for plant with: ", care_actions)

func _assess_fruit_quality(fruit: Node) -> float:
	# Simulate quality assessment using multiple sensors
	var size_score = fruit.get_meta("size", randf())
	var color_score = fruit.get_meta("color_quality", randf())
	var ripeness = fruit.get_meta("ripeness", randf())
	
	# Weight factors for quality
	var quality = (size_score * 0.3 + color_score * 0.4 + ripeness * 0.3)
	
	# Record detailed analysis
	notepad3d.write_observation(
		Vector3i(fruit.global_position),
		"Quality analysis: size=%.2f, color=%.2f, ripeness=%.2f -> %.2f" % [size_score, color_score, ripeness, quality],
		0.5
	)
	
	return quality

func _perform_precise_cut(fruit: Node) -> bool:
	# Simulate precision cutting with auto-sharpening scissors
	var cut_difficulty = fruit.get_meta("stem_thickness", randf())
	var success_chance = cutting_tool_sharpness * gentle_touch_factor * plant_care_efficiency
	
	var success = randf() < success_chance
	
	if success:
		# Tool wear
		cutting_tool_sharpness *= 0.999
		
		notepad3d.write_action(
			Vector3i(fruit.global_position),
			"Precise cut completed cleanly",
			0.8
		)
	else:
		notepad3d.write_action(
			Vector3i(fruit.global_position),
			"Cut failed - adjusting technique",
			0.3
		)
	
	return success

func _auto_sharpen_tool() -> void:
	# "Some spirit whisper 'it can auto sharpen'"
	cutting_tool_sharpness = min(cutting_tool_sharpness + 0.1, 1.0)
	
	notepad3d.write_action(
		Vector3i(global_position),
		"Auto-sharpened cutting tool on maintenance pad",
		0.6
	)
	
	print("✂️ ", spirit_name, " auto-sharpened tools (sharpness: ", cutting_tool_sharpness, ")")

func _store_in_basket(fruit_type: String, quality: float) -> void:
	# Update plant database with harvest data
	if not plant_database.has(fruit_type):
		plant_database[fruit_type] = {
			"total_harvested": 0,
			"average_quality": 0.0,
			"best_locations": []
		}
	
	var fruit_data = plant_database[fruit_type]
	var old_count = fruit_data["total_harvested"]
	var old_avg = fruit_data["average_quality"]
	
	fruit_data["total_harvested"] = old_count + 1
	fruit_data["average_quality"] = (old_avg * old_count + quality) / fruit_data["total_harvested"]
	
	# Record high-quality harvest locations
	if quality > 0.8:
		fruit_data["best_locations"].append(global_position)

func _init_plant_database() -> void:
	plant_database = {
		"tomato": {
			"optimal_harvest_time": "morning",
			"color_indicators": ["deep_red", "slight_give"],
			"care_requirements": ["regular_water", "sun_exposure"]
		},
		"apple": {
			"optimal_harvest_time": "afternoon",
			"color_indicators": ["vibrant_color", "easy_separation"],
			"care_requirements": ["pruning", "pest_control"]
		},
		"strawberry": {
			"optimal_harvest_time": "early_morning",
			"color_indicators": ["deep_red", "sweet_aroma"],
			"care_requirements": ["ground_cover", "frequent_water"]
		}
	}

# Override sigil activation for gardening powers
func activate_sigil_power(power_level: float = 1.0) -> void:
	super.activate_sigil_power(power_level)
	
	# Gardener-specific sigil abilities
	match sigil_type:
		"lilith":
			_activate_growth_blessing(power_level)
		"demeter":
			_activate_harvest_abundance(power_level)
		_:
			_activate_gentle_touch(power_level)

func _activate_growth_blessing(power: float) -> void:
	# Boost nearby plant growth
	var nearby_plants = get_tree().get_nodes_in_group("plants")
	for plant in nearby_plants:
		if global_position.distance_to(plant.global_position) <= harvest_radius * 2:
			var current_health = plant.get_meta("health", 0.5)
			plant.set_meta("health", min(current_health + power * 0.3, 1.0))
	
	notepad3d.write_action(
		Vector3i(global_position),
		"Blessed nearby plants with growth energy",
		power
	)

func _activate_harvest_abundance(power: float) -> void:
	# Temporarily increase harvest efficiency
	plant_care_efficiency += power * 0.5
	
	# Schedule to return to normal
	var timer = get_tree().create_timer(30.0)
	timer.timeout.connect(func(): plant_care_efficiency = 1.0)
	
	notepad3d.write_action(
		Vector3i(global_position),
		"Channeled abundance energy for enhanced harvesting",
		power
	)

func _activate_gentle_touch(power: float) -> void:
	# Increase gentle handling for a duration
	gentle_touch_factor = min(gentle_touch_factor + power * 0.2, 1.0)
	
	notepad3d.write_action(
		Vector3i(global_position),
		"Enhanced gentle touch for delicate work",
		power
	)

# Daily cycle behaviors
func _on_dawn() -> void:
	notepad3d.write_observation(
		Vector3i(global_position),
		"Dawn breaks - time for morning harvest rounds",
		0.7
	)
	change_state(RobotState.PATROLLING)
	current_harvest_count = 0

func _on_dusk() -> void:
	notepad3d.write_observation(
		Vector3i(global_position),
		"Dusk falls - returning to sanctuary for rest",
		0.6
	)
	change_state(RobotState.RESTING)

func get_gardening_report() -> Dictionary:
	var base_report = get_memory_summary()
	base_report["role"] = "Gardener"
	base_report["harvest_count"] = current_harvest_count
	base_report["tool_sharpness"] = cutting_tool_sharpness
	base_report["plant_knowledge"] = plant_database.keys()
	base_report["care_efficiency"] = plant_care_efficiency
	
	return base_report