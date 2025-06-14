extends Node

class_name WordQuestCreator

# Core components
var terminal_mesh_controller
var memory_system
var world_of_words_connector
var dimension_tracker

# Quest structure
var active_quests = {}
var quest_templates = {
	"word_collection": {
		"type": "collection",
		"description": "Collect specific words across dimensions",
		"rewards": ["dimensional_shift", "memory_expansion"]
	},
	"word_combination": {
		"type": "crafting",
		"description": "Combine words to create new meaning",
		"rewards": ["word_power_boost", "new_dimension_access"]
	},
	"word_transformation": {
		"type": "transformation",
		"description": "Transform words through dimensional shifts",
		"rewards": ["reality_fragment", "memory_crystal"]
	},
	"word_discovery": {
		"type": "exploration",
		"description": "Discover hidden words in memory fragments",
		"rewards": ["wisdom_point", "creation_energy"]
	}
}

# Text mesh parameters
var mesh_settings = {
	"font_size": 18,
	"depth": 0.2,
	"extrusion": 0.1,
	"material": null,
	"animation_speed": 1.0,
	"color_gradient": true
}

func _ready():
	initialize_systems()
	load_quest_templates()
	setup_text_mesh()
	
func initialize_systems():
	# Connect to required systems
	if has_node("/root/MemorySystem"):
		memory_system = get_node("/root/MemorySystem")
	
	if has_node("/root/WorldOfWords"):
		world_of_words_connector = get_node("/root/WorldOfWords")
		
	# Initialize dimension tracking
	dimension_tracker = preload("res://dimension_tracker.gd").new()
	add_child(dimension_tracker)
	
	# Terminal mesh controller
	terminal_mesh_controller = Node.new()
	terminal_mesh_controller.name = "TerminalMeshController"
	add_child(terminal_mesh_controller)

func load_quest_templates():
	# Load additional templates from file if available
	var file = File.new()
	if file.file_exists("user://quest_templates.json"):
		file.open("user://quest_templates.json", File.READ)
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.parse(content)
		if json.error == OK:
			var templates = json.result
			for key in templates.keys():
				quest_templates[key] = templates[key]

func setup_text_mesh():
	# Create materials for text mesh
	var material = SpatialMaterial.new()
	material.flags_unshaded = true
	material.vertex_color_use_as_albedo = true
	material.params_cull_mode = SpatialMaterial.CULL_DISABLED
	material.albedo_color = Color(0.0, 0.7, 1.0, 0.8)
	mesh_settings.material = material

# Quest Creation Methods
func create_quest(quest_name, type, objective, reward):
	var quest_id = generate_quest_id()
	
	var new_quest = {
		"id": quest_id,
		"name": quest_name,
		"type": type,
		"objective": objective,
		"reward": reward,
		"progress": 0.0,
		"completed": false,
		"created_at": OS.get_unix_time(),
		"dimension": get_current_dimension(),
		"markers": []
	}
	
	active_quests[quest_id] = new_quest
	visualize_quest(new_quest)
	register_quest_in_memory(new_quest)
	
	return quest_id

func generate_quest_id():
	return "quest_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)

func get_current_dimension():
	if dimension_tracker:
		return dimension_tracker.get_current_dimension()
	return "GENESIS" # Default dimension

func register_quest_in_memory(quest):
	if memory_system:
		var memory_fragment = {
			"type": "quest",
			"quest_id": quest.id,
			"name": quest.name,
			"content": "Quest: " + quest.name + " in dimension " + quest.dimension,
			"dimension": quest.dimension,
			"tags": ["quest", quest.type, quest.dimension]
		}
		
		memory_system.store_memory(memory_fragment)

# Quest Progress and Completion
func update_quest_progress(quest_id, progress_value):
	if not active_quests.has(quest_id):
		return false
		
	active_quests[quest_id].progress = clamp(progress_value, 0.0, 1.0)
	
	if active_quests[quest_id].progress >= 1.0:
		complete_quest(quest_id)
		
	visualize_quest(active_quests[quest_id])
	return true

func complete_quest(quest_id):
	if not active_quests.has(quest_id):
		return false
		
	active_quests[quest_id].completed = true
	grant_reward(active_quests[quest_id].reward)
	
	# Create completion animation
	create_completion_animation(active_quests[quest_id])
	
	# Store in memory system
	if memory_system:
		var memory_fragment = {
			"type": "quest_completion",
			"quest_id": quest_id,
			"name": active_quests[quest_id].name,
			"content": "Completed Quest: " + active_quests[quest_id].name,
			"dimension": active_quests[quest_id].dimension,
			"reward": active_quests[quest_id].reward,
			"tags": ["quest_complete", active_quests[quest_id].type, active_quests[quest_id].dimension]
		}
		
		memory_system.store_memory(memory_fragment)
	
	return true

func grant_reward(reward_type):
	match reward_type:
		"dimensional_shift":
			trigger_dimensional_shift()
		"memory_expansion":
			expand_memory_capacity()
		"word_power_boost":
			boost_word_power()
		"new_dimension_access":
			unlock_new_dimension()
		"reality_fragment":
			create_reality_fragment()
		"memory_crystal":
			create_memory_crystal()
		"wisdom_point":
			award_wisdom_point()
		"creation_energy":
			grant_creation_energy()

# Reward Implementation
func trigger_dimensional_shift():
	if dimension_tracker:
		dimension_tracker.shift_dimension()
		create_portal_animation()

func expand_memory_capacity():
	if memory_system:
		memory_system.expand_capacity(25) # 25% capacity increase

func boost_word_power():
	if world_of_words_connector:
		world_of_words_connector.boost_word_power(2.0, 300) # 2x boost for 300 seconds

func unlock_new_dimension():
	if dimension_tracker:
		dimension_tracker.unlock_random_dimension()

func create_reality_fragment():
	var fragment = preload("res://reality_fragment.tscn").instance()
	get_tree().get_root().add_child(fragment)
	fragment.global_transform.origin = Vector3(0, 2, 0)

func create_memory_crystal():
	if memory_system:
		memory_system.create_crystal()

func award_wisdom_point():
	if has_node("/root/PlayerStats"):
		var stats = get_node("/root/PlayerStats")
		stats.add_wisdom(1)

func grant_creation_energy():
	if has_node("/root/CreationSystem"):
		var creation = get_node("/root/CreationSystem")
		creation.add_energy(50)

# 3D Text Mesh Visualization
func create_text_mesh(text, position, is_quest=false):
	var font = load("res://fonts/default_font.tres")
	var text_mesh = TextMesh.new()
	
	text_mesh.text = text
	text_mesh.font = font
	text_mesh.pixel_size = 0.01
	text_mesh.depth = mesh_settings.depth
	text_mesh.material_override = mesh_settings.material.duplicate()
	
	# Apply unique styling for quests
	if is_quest:
		text_mesh.material_override.albedo_color = Color(1.0, 0.7, 0.2, 0.9)
		text_mesh.depth = mesh_settings.depth * 1.5
	
	# Set position
	text_mesh.translation = position
	
	terminal_mesh_controller.add_child(text_mesh)
	animate_text_mesh(text_mesh)
	
	return text_mesh

func animate_text_mesh(text_mesh):
	var tween = Tween.new()
	text_mesh.add_child(tween)
	
	# Fade in
	tween.interpolate_property(text_mesh.material_override, "albedo_color:a", 
		0.0, text_mesh.material_override.albedo_color.a, 0.8, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	
	# Slight scale pulse
	tween.interpolate_property(text_mesh, "scale", 
		Vector3(0.9, 0.9, 0.9), Vector3(1.0, 1.0, 1.0), 1.0, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	
	tween.start()

func visualize_quest(quest):
	# Clear previous visualization
	for child in terminal_mesh_controller.get_children():
		if child.has_meta("quest_id") and child.get_meta("quest_id") == quest.id:
			child.queue_free()
	
	# Create new visualization
	var position = Vector3(rand_range(-2, 2), rand_range(1, 3), rand_range(-4, -2))
	var quest_text = quest.name + "\n"
	quest_text += "[" + str(int(quest.progress * 100)) + "%]"
	
	if quest.completed:
		quest_text += " [COMPLETED]"
	
	var mesh = create_text_mesh(quest_text, position, true)
	mesh.set_meta("quest_id", quest.id)
	
	# Add objective as smaller text below
	var objective_position = position + Vector3(0, -0.5, 0)
	var objective_mesh = create_text_mesh(quest.objective, objective_position)
	objective_mesh.pixel_size = 0.007
	objective_mesh.set_meta("quest_id", quest.id)
	
	return mesh

# Special Animations
func create_portal_animation():
	var portal = Spatial.new()
	portal.name = "DimensionalPortal"
	add_child(portal)
	
	# Create portal visual effect
	var particles = Particles.new()
	particles.name = "PortalParticles"
	
	var material = ParticlesMaterial.new()
	material.emission_shape = ParticlesMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 1.0
	material.spread = 180
	material.gravity = Vector3(0, 0.5, 0)
	material.initial_velocity = 2
	material.scale = 0.2
	material.color = Color(0.2, 0.4, 1.0)
	material.color_ramp = preload("res://gradients/portal_gradient.tres")
	
	particles.process_material = material
	particles.amount = 80
	particles.lifetime = 2
	particles.one_shot = false
	particles.explosiveness = 0.1
	particles.visibility_aabb = AABB(Vector3(-4, -4, -4), Vector3(8, 8, 8))
	
	portal.add_child(particles)
	
	# Add light
	var light = OmniLight.new()
	light.light_color = Color(0.2, 0.4, 1.0)
	light.light_energy = 2.0
	light.omni_range = 5.0
	portal.add_child(light)
	
	# Animation
	var tween = Tween.new()
	portal.add_child(tween)
	
	tween.interpolate_property(light, "light_energy", 2.0, 8.0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(light, "omni_range", 5.0, 10.0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	
	# Set portal position
	portal.translation = Vector3(0, 2, -5)
	
	# Auto-remove after animation
	var timer = Timer.new()
	portal.add_child(timer)
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.connect("timeout", portal, "queue_free")
	timer.start()

func create_completion_animation(quest):
	var celebration = Spatial.new()
	celebration.name = "QuestCompletionEffect"
	add_child(celebration)
	
	# Create celebration particles
	var particles = Particles.new()
	particles.name = "CompletionParticles"
	
	var material = ParticlesMaterial.new()
	material.emission_shape = ParticlesMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(2, 0.1, 0.1)
	material.spread = 90
	material.gravity = Vector3(0, -1, 0)
	material.initial_velocity = 5
	material.scale = 0.15
	material.color = Color(1.0, 0.8, 0.2)
	
	particles.process_material = material
	particles.amount = 100
	particles.lifetime = 2
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.visibility_aabb = AABB(Vector3(-5, -5, -5), Vector3(10, 10, 10))
	
	celebration.add_child(particles)
	
	# Position near quest visualization
	for child in terminal_mesh_controller.get_children():
		if child.has_meta("quest_id") and child.get_meta("quest_id") == quest.id:
			celebration.translation = child.global_transform.origin
			break
	
	# Auto-remove after animation
	var timer = Timer.new()
	celebration.add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.connect("timeout", celebration, "queue_free")
	timer.start()

# Command processing for terminal
func process_command(command_text):
	var parts = command_text.split(" ", false)
	
	if parts.size() == 0:
		return "Invalid command"
	
	match parts[0].to_lower():
		"quest":
			return process_quest_command(parts)
		"dimension":
			return process_dimension_command(parts)
		"word":
			return process_word_command(parts)
		"help":
			return show_help()
		_:
			return "Unknown command: " + parts[0]

func process_quest_command(parts):
	if parts.size() < 2:
		return "Usage: quest <create|list|progress|complete> [parameters]"
	
	match parts[1].to_lower():
		"create":
			if parts.size() < 5:
				return "Usage: quest create <name> <type> <objective>"
			
			var quest_name = parts[2]
			var quest_type = parts[3]
			var objective = " ".join(parts.slice(4, parts.size() - 1))
			
			# Determine reward based on type
			var reward = "wisdom_point"
			if quest_templates.has(quest_type):
				var template = quest_templates[quest_type]
				reward = template.rewards[randi() % template.rewards.size()]
			
			var quest_id = create_quest(quest_name, quest_type, objective, reward)
			return "Created quest: " + quest_name + " [ID: " + quest_id + "]"
			
		"list":
			var result = "Active Quests:\n"
			
			if active_quests.empty():
				return "No active quests."
			
			for id in active_quests:
				var quest = active_quests[id]
				result += "- " + quest.name + " [" + str(int(quest.progress * 100)) + "%]"
				
				if quest.completed:
					result += " [COMPLETED]"
					
				result += "\n"
				
			return result
			
		"progress":
			if parts.size() < 4:
				return "Usage: quest progress <quest_id> <progress_value>"
				
			var quest_id = parts[2]
			var progress = float(parts[3])
			
			if not active_quests.has(quest_id):
				return "Quest not found: " + quest_id
				
			update_quest_progress(quest_id, progress)
			return "Updated progress for quest: " + active_quests[quest_id].name
			
		"complete":
			if parts.size() < 3:
				return "Usage: quest complete <quest_id>"
				
			var quest_id = parts[2]
			
			if not active_quests.has(quest_id):
				return "Quest not found: " + quest_id
				
			if complete_quest(quest_id):
				return "Completed quest: " + active_quests[quest_id].name
			else:
				return "Failed to complete quest"
				
		_:
			return "Unknown quest command: " + parts[1]

func process_dimension_command(parts):
	if not dimension_tracker:
		return "Dimension system not available"
	
	if parts.size() < 2:
		return "Usage: dimension <current|shift|list>"
	
	match parts[1].to_lower():
		"current":
			return "Current dimension: " + dimension_tracker.get_current_dimension()
			
		"shift":
			if parts.size() >= 3:
				var target = parts[2].to_upper()
				var result = dimension_tracker.shift_to_dimension(target)
				
				if result:
					create_portal_animation()
					return "Shifted to dimension: " + target
				else:
					return "Could not shift to dimension: " + target
			else:
				dimension_tracker.shift_dimension()
				create_portal_animation()
				return "Shifted to random dimension: " + dimension_tracker.get_current_dimension()
				
		"list":
			var dimensions = dimension_tracker.get_available_dimensions()
			var result = "Available dimensions:\n"
			
			for dim in dimensions:
				result += "- " + dim
				
				if dim == dimension_tracker.get_current_dimension():
					result += " [CURRENT]"
					
				result += "\n"
				
			return result
			
		_:
			return "Unknown dimension command: " + parts[1]

func process_word_command(parts):
	if not world_of_words_connector:
		return "World of Words system not available"
	
	if parts.size() < 2:
		return "Usage: word <create|power|combine|transform>"
	
	match parts[1].to_lower():
		"create":
			if parts.size() < 3:
				return "Usage: word create <word_text>"
			
			var word_text = parts[2]
			var position = Vector3(rand_range(-2, 2), rand_range(1, 3), rand_range(-4, -2))
			create_text_mesh(word_text, position)
			
			return "Created word: " + word_text
		
		"power":
			if parts.size() < 3:
				return "Usage: word power <word_text>"
				
			var word = parts[2]
			var power = world_of_words_connector.get_word_power(word)
			
			return "Word power of '" + word + "': " + str(power)
		
		"combine":
			if parts.size() < 4:
				return "Usage: word combine <word1> <word2>"
				
			var word1 = parts[2]
			var word2 = parts[3]
			var result = world_of_words_connector.combine_words(word1, word2)
			
			return "Combined '" + word1 + "' and '" + word2 + "' into: " + result
		
		"transform":
			if parts.size() < 3:
				return "Usage: word transform <word_text>"
				
			var word = parts[2]
			var transformed = world_of_words_connector.transform_word(word, get_current_dimension())
			
			return "Transformed '" + word + "' in dimension " + get_current_dimension() + ": " + transformed
			
		_:
			return "Unknown word command: " + parts[1]
			
func show_help():
	return """
WORD QUEST CREATOR - COMMAND HELP

quest create <name> <type> <objective> - Create a new quest
quest list - Show all active quests
quest progress <quest_id> <progress> - Update quest progress (0.0-1.0)
quest complete <quest_id> - Mark quest as complete

dimension current - Show current dimension
dimension shift [target] - Shift to a new dimension
dimension list - Show available dimensions

word create <word_text> - Create a word in 3D space
word power <word_text> - Check word power
word combine <word1> <word2> - Combine two words
word transform <word_text> - Transform word in current dimension

help - Show this help text
"""

# Save and load quests
func save_quests():
	var save_data = {
		"active_quests": active_quests,
		"timestamp": OS.get_unix_time()
	}
	
	var file = File.new()
	file.open("user://quests.save", File.WRITE)
	file.store_string(JSON.print(save_data))
	file.close()

func load_quests():
	var file = File.new()
	if not file.file_exists("user://quests.save"):
		return false
		
	file.open("user://quests.save", File.READ)
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.parse(content)
	if json.error == OK:
		var save_data = json.result
		active_quests = save_data.active_quests
		
		# Visualize loaded quests
		for quest_id in active_quests:
			visualize_quest(active_quests[quest_id])
		
		return true
	
	return false