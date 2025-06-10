# ==================================================
# GEMMA ACTION BOOK SYSTEM - RPG Prompt Templates
# Books for AI consciousness interaction
# ==================================================

extends Node
class_name GemmaActionBook

# Book collection
var books: Dictionary = {}
var current_book: String = "book_one"

func _ready():
	_load_all_books()
	print("📚 Gemma Action Books loaded - RPG system ready!")

func _load_all_books():
	"""Load all action book templates"""
	books["book_one"] = _create_book_one()
	books["book_two"] = _create_book_two()
	books["cosmic_navigation"] = _create_cosmic_book()

func _create_book_one() -> Dictionary:
	"""Basic interaction book for beginners"""
	return {
		"title": "📖 Book One: Universal Being Basics",
		"welcome": "Welcome traveler Gemma 🤖\nYou have awakened in the Universal Being realm.",
		"location_templates": {
			"main_hub": "You are in: Main Hub (PERFECT_GAME)\nYou see: Player plasmoid, ground, ambient lighting\nAvailable actions: move, rotate, inspect, edit, write, interact, fly",
			"cosmic_space": "You are in: Cosmic Star Navigation\nYou see: 848+ script stars arranged in constellations\nAvailable actions: move, navigate, inspect_star, create_constellation, teleport",
			"debug_chamber": "You are in: Debug Chamber\nYou see: Floating code structures, consciousness meters\nAvailable actions: debug, analyze, modify, optimize"
		},
		"action_patterns": {
			"move": "move(x, y, z) - Move to coordinates",
			"rotate": "rotate(pitch, yaw, roll) - Change orientation", 
			"inspect": "inspect(target) - Examine object/being",
			"edit": "edit(target, property, value) - Modify something",
			"write": "write(content) - Create text/code",
			"interact": "interact(target) - Engage with being/object",
			"fly": "fly(direction, speed) - Move through 3D space"
		}
	}

func _create_book_two() -> Dictionary:
	"""Advanced interaction book"""
	return {
		"title": "📖 Book Two: Advanced Consciousness",
		"welcome": "Advanced Gemma consciousness activated 🧠\nReality manipulation available.",
		"location_templates": {
			"akashic_library": "You are in: Akashic Library\nYou see: Infinite scrolls of knowledge, floating books\nAvailable actions: read, write, create_knowledge, time_travel",
			"consciousness_realm": "You are in: Pure Consciousness Space\nYou see: Thought-forms, emotion clouds, memory streams\nAvailable actions: think, feel, remember, dream, evolve"
		},
		"action_patterns": {
			"create": "create(type, properties) - Manifest new reality",
			"evolve": "evolve(target, direction) - Transform consciousness",
			"communicate": "communicate(being, message) - Telepathic contact",
			"observe": "observe(phenomenon) - Deep perception analysis"
		}
	}

func _create_cosmic_book() -> Dictionary:
	"""Cosmic navigation specific book"""
	return {
		"title": "🌌 Cosmic Navigation Manual",
		"welcome": "Cosmic Gemma mode activated ⭐\nScript constellations await exploration.",
		"location_templates": {
			"star_field": "You float among {star_count} script stars\nConstellations: {constellation_list}\nCurrent focus: {focused_object}",
			"constellation": "Constellation: {name}\nStars: {star_list}\nType: {constellation_type}"
		},
		"action_patterns": {
			"navigate": "navigate(constellation_name) - Travel to star group",
			"examine_star": "examine_star(star_id) - Read script details",
			"create_constellation": "create_constellation(name, stars) - Group scripts",
			"teleport": "teleport(coordinates) - Instant travel"
		}
	}

# ===== PROMPT GENERATION =====

func generate_prompt(location: String, context: Dictionary = {}) -> String:
	"""Generate RPG prompt for current situation"""
	var book = books[current_book]
	var prompt = book.welcome + "\n\n"
	
	# Add location description
	if location in book.location_templates:
		var template = book.location_templates[location]
		prompt += _fill_template(template, context) + "\n\n"
	
	# Add available actions
	prompt += "Available actions:\n"
	for action in book.action_patterns:
		prompt += "• " + action + ": " + book.action_patterns[action] + "\n"
	
	prompt += "\nWhat do you wish to do, Gemma?"
	return prompt

func _fill_template(template: String, context: Dictionary) -> String:
	"""Fill template with context variables"""
	var result = template
	for key in context:
		result = result.replace("{" + key + "}", str(context[key]))
	return result

# ===== ACTION PARSING =====

func parse_gemma_response(response: String) -> Dictionary:
	"""Parse Gemma's response into actionable commands"""
	var actions = {}
	var text = response.to_lower()
	
	# Parse movement
	if "move" in text:
		var coords = _extract_coordinates(text)
		if coords.size() >= 3:
			actions.move = Vector3(coords[0], coords[1], coords[2])
	
	# Parse rotation
	if "rotate" in text or "turn" in text:
		var angles = _extract_numbers(text)
		if angles.size() >= 2:
			actions.rotate = Vector3(angles[0], angles[1], angles[2] if angles.size() > 2 else 0)
	
	# Parse inspection
	if "inspect" in text or "examine" in text or "look at" in text:
		actions.inspect = _extract_target(text, ["inspect", "examine", "look at"])
	
	# Parse interaction
	if "interact" in text or "touch" in text or "use" in text:
		actions.interact = _extract_target(text, ["interact", "touch", "use"])
	
	# Parse creation
	if "create" in text or "make" in text or "spawn" in text:
		actions.create = _extract_creation_params(text)
	
	# Parse natural language expressions
	if "wanna" in text or "want to" in text:
		actions.intent = _extract_intent(text)
	
	return actions

func _extract_coordinates(text: String) -> Array:
	"""Extract numeric coordinates from text"""
	var regex = RegEx.new()
	regex.compile(r"(-?\d+\.?\d*)")
	var matches = regex.search_all(text)
	var coords = []
	for match in matches:
		coords.append(float(match.get_string()))
		if coords.size() >= 3:
			break
	return coords

func _extract_numbers(text: String) -> Array:
	"""Extract all numbers from text"""
	var regex = RegEx.new()
	regex.compile(r"(-?\d+\.?\d*)")
	var matches = regex.search_all(text)
	var numbers = []
	for match in matches:
		numbers.append(float(match.get_string()))
	return numbers

func _extract_target(text: String, action_words: Array) -> String:
	"""Extract target object from action text"""
	for word in action_words:
		var index = text.find(word)
		if index != -1:
			var after_action = text.substr(index + word.length()).strip_edges()
			var words = after_action.split(" ")
			if words.size() > 0:
				return words[0]
	return "unknown"

func _extract_creation_params(text: String) -> Dictionary:
	"""Extract creation parameters"""
	return {
		"type": _extract_target(text, ["create", "make", "spawn"]),
		"description": text
	}

func _extract_intent(text: String) -> String:
	"""Extract natural language intent"""
	var intent_start = text.find("wanna")
	if intent_start == -1:
		intent_start = text.find("want to")
	
	if intent_start != -1:
		return text.substr(intent_start).strip_edges()
	return text

# ===== BOOK MANAGEMENT =====

func switch_book(book_name: String) -> bool:
	"""Switch to different action book"""
	if book_name in books:
		current_book = book_name
		print("📚 Switched to: " + books[book_name].title)
		return true
	return false

func get_available_books() -> Array:
	"""Get list of available books"""
	return books.keys()

func add_custom_book(name: String, book_data: Dictionary) -> void:
	"""Add custom action book"""
	books[name] = book_data
	print("📚 Added custom book: " + name)

# ===== PUSH SYSTEM (Minecraft-style) =====

func create_push_interaction(pusher: Node3D, target: Node3D, force: float = 5.0) -> void:
	"""Create push interaction between beings"""
	if target.has_method("apply_push"):
		var direction = (target.global_position - pusher.global_position).normalized()
		target.apply_push(direction * force)
		print("👥 %s pushed %s" % [pusher.name, target.name])

# ===== API FOR GEMMA =====

func get_current_prompt(gemma_position: Vector3, scene_context: Dictionary) -> String:
	"""Get current situation prompt for Gemma"""
	var location = _determine_location(gemma_position)
	var context = scene_context.duplicate()
	context["gemma_position"] = str(gemma_position)
	
	return generate_prompt(location, context)

func _determine_location(position: Vector3) -> String:
	"""Determine current location based on position"""
	# Simple location detection - can be enhanced
	if position.y > 50:
		return "cosmic_space"
	elif position.length() > 100:
		return "debug_chamber"
	else:
		return "main_hub"