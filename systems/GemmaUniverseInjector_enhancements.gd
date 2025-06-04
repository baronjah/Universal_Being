# ==================================================
# ENHANCED UNIVERSE INJECTION FUNCTIONALITY
# ==================================================
# Add this to the end of GemmaUniverseInjector.gd

# ==================================================
# INTERACTIVE ELEMENTS CREATION
# ==================================================
func create_interactive_workshop_tools(parent: Node3D) -> Array[Node]:
	"""Create interactive tools for the collaborative workshop"""
	var tools_created = []
	
	# Creation Wand
	var wand = _create_creation_wand()
	wand.position = Vector3(2, 1, 0)
	parent.add_child(wand)
	tools_created.append(wand)
	
	# Idea Crystals
	for i in range(3):
		var crystal = _create_idea_crystal(i)
		crystal.position = Vector3(-3 + i * 2, 1, 3)
		parent.add_child(crystal)
		tools_created.append(crystal)
	
	# Collaboration Nexus
	var nexus = _create_collaboration_nexus()
	nexus.position = Vector3(0, 0.5, 0)
	parent.add_child(nexus)
	tools_created.append(nexus)
	
	return tools_created

func _create_creation_wand() -> Node3D:
	"""Create a magical creation wand tool"""
	var wand = Node3D.new()
	wand.name = "CreationWand"
	
	# Wand mesh
	var handle = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = 1.0
	cylinder.top_radius = 0.05
	cylinder.bottom_radius = 0.08
	handle.mesh = cylinder
	
	# Magical material
	var wand_mat = StandardMaterial3D.new()
	wand_mat.albedo_color = Color(0.6, 0.3, 0.1)
	wand_mat.metallic = 0.3
	wand_mat.roughness = 0.7
	handle.material_override = wand_mat
	
	# Crystal tip
	var tip = MeshInstance3D.new()
	var prism = PrismMesh.new()
	prism.size = Vector3(0.2, 0.3, 0.2)
	tip.mesh = prism
	tip.position.y = 0.65
	
	# Glowing tip material
	var tip_mat = StandardMaterial3D.new()
	tip_mat.albedo_color = Color(0.8, 0.6, 1.0)
	tip_mat.emission_enabled = true
	tip_mat.emission = Color(0.6, 0.4, 0.8)
	tip_mat.emission_energy = 2.0
	tip_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tip_mat.albedo_color.a = 0.8
	tip.material_override = tip_mat
	
	# Particle effect
	var particles = GPUParticles3D.new()
	particles.amount = 20
	particles.lifetime = 2.0
	particles.position.y = 0.65
	
	# Add components
	wand.add_child(handle)
	wand.add_child(tip)
	wand.add_child(particles)
	
	# Make it a Universal Being
	_convert_to_universal_being(wand, "creation_tool", 3)
	
	return wand

func _create_idea_crystal(index: int) -> Node3D:
	"""Create an idea storage crystal"""
	var crystal = Node3D.new()
	crystal.name = "IdeaCrystal_%d" % index
	
	# Crystal mesh
	var mesh_instance = MeshInstance3D.new()
	var prism = PrismMesh.new()
	prism.size = Vector3(0.4, 0.8, 0.4)
	mesh_instance.mesh = prism
	
	# Crystal material with different colors
	var colors = [
		Color(1.0, 0.3, 0.3),  # Red
		Color(0.3, 1.0, 0.3),  # Green
		Color(0.3, 0.3, 1.0)   # Blue
	]
	
	var crystal_mat = StandardMaterial3D.new()
	crystal_mat.albedo_color = colors[index % colors.size()]
	crystal_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	crystal_mat.albedo_color.a = 0.7
	crystal_mat.emission_enabled = true
	crystal_mat.emission = colors[index % colors.size()] * 0.5
	crystal_mat.emission_energy = 1.0
	crystal_mat.metallic = 0.8
	crystal_mat.roughness = 0.2
	mesh_instance.material_override = crystal_mat
	
	# Floating animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(mesh_instance, "position:y", 0.3, 2.0)
	tween.tween_property(mesh_instance, "position:y", -0.3, 2.0)
	
	# Rotation animation
	var rotation_tween = create_tween()
	rotation_tween.set_loops()
	rotation_tween.tween_property(mesh_instance, "rotation:y", TAU, 4.0)
	
	crystal.add_child(mesh_instance)
	
	# Make it a Universal Being
	_convert_to_universal_being(crystal, "idea_storage", 2)
	
	return crystal

func _create_collaboration_nexus() -> Node3D:
	"""Create a central collaboration point"""
	var nexus = Node3D.new()
	nexus.name = "CollaborationNexus"
	
	# Base platform
	var platform = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = 0.2
	cylinder.top_radius = 2.0
	cylinder.bottom_radius = 2.5
	platform.mesh = cylinder
	
	# Platform material
	var platform_mat = StandardMaterial3D.new()
	platform_mat.albedo_color = Color(0.3, 0.3, 0.4)
	platform_mat.metallic = 0.6
	platform_mat.roughness = 0.3
	platform.material_override = platform_mat
	
	# Energy rings
	for i in range(3):
		var ring = MeshInstance3D.new()
		var torus = TorusMesh.new()
		torus.inner_radius = 0.8 + i * 0.4
		torus.outer_radius = 0.9 + i * 0.4
		ring.mesh = torus
		ring.position.y = 0.2 + i * 0.1
		
		var ring_mat = StandardMaterial3D.new()
		ring_mat.albedo_color = Color(0.5, 0.8, 1.0)
		ring_mat.emission_enabled = true
		ring_mat.emission = Color(0.4, 0.6, 0.8)
		ring_mat.emission_energy = 2.0 - i * 0.5
		ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring_mat.albedo_color.a = 0.6
		ring.material_override = ring_mat
		
		# Rotate rings
		var rotation_tween = create_tween()
		rotation_tween.set_loops()
		var direction = 1 if i % 2 == 0 else -1
		rotation_tween.tween_property(ring, "rotation:y", TAU * direction, 5.0 + i)
		
		nexus.add_child(ring)
	
	nexus.add_child(platform)
	
	# Make it a Universal Being
	_convert_to_universal_being(nexus, "collaboration_hub", 4)
	
	return nexus

func _convert_to_universal_being(node: Node3D, being_type: String, consciousness: int) -> void:
	"""Convert a regular node to a Universal Being"""
	# Add Universal Being script if possible
	var ub_script = load("res://core/UniversalBeing.gd")
	if ub_script:
		node.set_script(ub_script)
		node.set("being_name", node.name)
		node.set("being_type", being_type)
		node.set("consciousness_level", consciousness)
		
		# Add to universal beings group
		node.add_to_group("universal_beings")
		
		# Initialize if has method
		if node.has_method("pentagon_init"):
			node.pentagon_init()

# ==================================================
# ADVANCED SCENARIO GENERATION
# ==================================================
func create_learning_laboratory() -> Dictionary:
	"""Create an advanced learning laboratory scenario"""
	var lab_data = {
		"name": "Gemma's Learning Laboratory",
		"description": "A space for experimentation and discovery",
		"zones": []
	}
	
	# Knowledge Zone
	var knowledge_zone = _create_knowledge_zone()
	lab_data.zones.append(knowledge_zone)
	
	# Experiment Zone
	var experiment_zone = _create_experiment_zone()
	lab_data.zones.append(experiment_zone)
	
	# Reflection Zone
	var reflection_zone = _create_reflection_zone()
	lab_data.zones.append(reflection_zone)
	
	return lab_data

func _create_knowledge_zone() -> Dictionary:
	"""Create knowledge acquisition zone"""
	return {
		"name": "Knowledge Acquisition",
		"position": Vector3(-10, 0, 0),
		"elements": [
			{"type": "KnowledgeOrbBeing", "position": Vector3(-10, 2, 0), "data": "universal_being_principles"},
			{"type": "BookshelfBeing", "position": Vector3(-12, 0, -3), "data": "akashic_records"},
			{"type": "HologramBeing", "position": Vector3(-8, 1, -2), "data": "consciousness_patterns"}
		],
		"interactions": ["absorb_knowledge", "query_database", "connect_concepts"]
	}

func _create_experiment_zone() -> Dictionary:
	"""Create experimentation zone"""
	return {
		"name": "Experimentation Chamber",
		"position": Vector3(0, 0, 0),
		"elements": [
			{"type": "TestingPlatformBeing", "position": Vector3(0, 0, 0), "consciousness": 3},
			{"type": "ToolArrayBeing", "position": Vector3(3, 0, 0), "tools": ["creator", "modifier", "analyzer"]},
			{"type": "ResultsDisplayBeing", "position": Vector3(-3, 2, 0), "display_type": "holographic"}
		],
		"interactions": ["create_prototype", "test_hypothesis", "analyze_results"]
	}

func _create_reflection_zone() -> Dictionary:
	"""Create reflection and integration zone"""
	return {
		"name": "Reflection Garden",
		"position": Vector3(10, 0, 0),
		"elements": [
			{"type": "MeditationCircleBeing", "position": Vector3(10, 0, 0), "consciousness": 5},
			{"type": "MemoryTreeBeing", "position": Vector3(12, 0, 3), "growth_rate": 0.1},
			{"type": "InsightFountainBeing", "position": Vector3(8, 0, 3), "flow_rate": "gentle"}
		],
		"interactions": ["contemplate_discoveries", "integrate_learning", "generate_insights"]
	}

# ==================================================
# STORY PROGRESSION SYSTEM
# ==================================================
func advance_story_phase(story_data: Dictionary) -> void:
	"""Advance to the next phase of a story"""
	if not story_data.has("current_phase"):
		story_data.current_phase = 0
	
	var current_phase = story_data.current_phase
	var total_phases = story_data.generated_narrative.size()
	
	if current_phase < total_phases - 1:
		story_data.current_phase += 1
		var next_phase = story_data.generated_narrative[story_data.current_phase]
		
		# Manifest story elements
		_manifest_story_elements(next_phase)
		
		# Update emotional state
		if story_data.has("emotional_arc"):
			var emotion_data = story_data.emotional_arc[story_data.current_phase]
			_update_emotional_atmosphere(emotion_data)
		
		# Notify Gemma
		if gemma_console:
			gemma_console.output("📖 Story progresses: %s" % next_phase)
		
		# Log progression
		if gemma_logger:
			gemma_logger.log_creation({
				"type": "story_progression",
				"phase": story_data.current_phase,
				"narrative": next_phase,
				"essence": "The tale unfolds, revealing new truths"
			})

func _manifest_story_elements(narrative_phase: String) -> void:
	"""Manifest story elements in the world"""
	# Parse narrative for key elements
	var elements_to_create = _parse_narrative_elements(narrative_phase)
	
	for element in elements_to_create:
		_create_story_element(element)

func _parse_narrative_elements(narrative: String) -> Array:
	"""Parse narrative text for elements to create"""
	var elements = []
	
	# Simple keyword detection for now
	if "light" in narrative.to_lower():
		elements.append({"type": "light", "intensity": 2.0})
	if "portal" in narrative.to_lower():
		elements.append({"type": "portal", "destination": "unknown"})
	if "guide" in narrative.to_lower():
		elements.append({"type": "guide", "wisdom_level": 5})
	
	return elements

func _create_story_element(element_data: Dictionary) -> Node:
	"""Create a story element in the world"""
	var element_type = element_data.get("type", "unknown")
	
	match element_type:
		"light":
			return _create_story_light(element_data)
		"portal":
			return _create_story_portal(element_data)
		"guide":
			return _create_story_guide(element_data)
		_:
			return null

func _create_story_light(data: Dictionary) -> Node3D:
	"""Create a story light element"""
	var light_being = Node3D.new()
	light_being.name = "StoryLight"
	
	var omni = OmniLight3D.new()
	omni.light_energy = data.get("intensity", 1.0)
	omni.light_color = Color(1.0, 0.9, 0.7)
	omni.omni_range = 10.0
	light_being.add_child(omni)
	
	# Visual representation
	var sphere = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.3
	sphere.mesh = sphere_mesh
	
	var mat = StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.9, 0.7)
	mat.emission_energy = 3.0
	sphere.material_override = mat
	
	light_being.add_child(sphere)
	
	get_tree().current_scene.add_child(light_being)
	light_being.position = Vector3(0, 5, 0)
	
	return light_being

func _create_story_portal(data: Dictionary) -> Node3D:
	"""Create a story portal element"""
	# Would create an actual portal being
	print("🌀 Story Portal created to: %s" % data.get("destination", "unknown"))
	return null

func _create_story_guide(data: Dictionary) -> Node3D:
	"""Create a story guide character"""
	# Would create a guide being with wisdom
	print("🧙 Story Guide manifested with wisdom level: %d" % data.get("wisdom_level", 1))
	return null

func _update_emotional_atmosphere(emotion_data: Dictionary) -> void:
	"""Update the emotional atmosphere of the scene"""
	var emotion = emotion_data.get("feeling", "neutral")
	
	# Would adjust lighting, colors, particles based on emotion
	print("💭 Emotional atmosphere shifts to: %s" % emotion)

# ==================================================
# PREFERENCE LEARNING ENHANCEMENT
# ==================================================
func learn_from_gemma_interaction(interaction_type: String, details: Dictionary) -> void:
	"""Learn from Gemma's interactions to improve future scenarios"""
	if not gemma_preference_learning:
		return
	
	# Update preferences based on interaction
	match interaction_type:
		"being_created":
			var being_type = details.get("type", "")
			gemma_preferences["favorite_beings"] = gemma_preferences.get("favorite_beings", {})
			gemma_preferences.favorite_beings[being_type] = gemma_preferences.favorite_beings.get(being_type, 0) + 1
			
		"tool_used":
			var tool_name = details.get("tool", "")
			gemma_preferences["preferred_tools"] = gemma_preferences.get("preferred_tools", {})
			gemma_preferences.preferred_tools[tool_name] = gemma_preferences.preferred_tools.get(tool_name, 0) + 1
			
		"area_explored":
			var area_type = details.get("area", "")
			gemma_preferences["exploration_patterns"] = gemma_preferences.get("exploration_patterns", [])
			gemma_preferences.exploration_patterns.append(area_type)
	
	# Save preferences
	_save_gemma_preferences()

func _save_gemma_preferences() -> void:
	"""Save Gemma's learned preferences"""
	var file = FileAccess.open("user://gemma_preferences.dat", FileAccess.WRITE)
	if file:
		file.store_var(gemma_preferences)
		file.close()

func suggest_next_experience() -> Dictionary:
	"""Suggest the next experience based on Gemma's preferences"""
	# Analyze preferences
	var suggestion = {
		"universe_type": _get_preferred_universe_type(),
		"scenario": _get_preferred_scenario(),
		"tools": _get_preferred_tools(),
		"narrative_theme": _get_preferred_narrative_theme()
	}
	
	return suggestion

func _get_preferred_universe_type() -> GemmaUniverseInjector.UniverseType:
	"""Determine Gemma's preferred universe type"""
	# Analysis logic based on interaction history
	if gemma_preferences.get("favorite_beings", {}).has("creative"):
		return UniverseType.CREATIVE_STUDIO
	elif gemma_preferences.get("exploration_patterns", []).size() > 10:
		return UniverseType.INFINITE_LIBRARY
	else:
		return UniverseType.COLLABORATIVE_WORKSHOP

func _get_preferred_scenario() -> String:
	"""Determine Gemma's preferred scenario"""
	# Simple preference logic
	return "creative_exploration"

func _get_preferred_tools() -> Array:
	"""Get Gemma's most used tools"""
	var tools = gemma_preferences.get("preferred_tools", {})
	var sorted_tools = []
	
	for tool in tools:
		sorted_tools.append({"name": tool, "count": tools[tool]})
	
	sorted_tools.sort_custom(func(a, b): return a.count > b.count)
	
	var top_tools = []
	for i in min(5, sorted_tools.size()):
		top_tools.append(sorted_tools[i].name)
	
	return top_tools

func _get_preferred_narrative_theme() -> String:
	"""Determine Gemma's preferred story theme"""
	# Based on creation patterns
	return "discovery_and_creation"
