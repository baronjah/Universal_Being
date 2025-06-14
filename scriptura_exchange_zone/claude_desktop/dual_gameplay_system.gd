# Dual Gameplay System - Two Ways to Play
# JSH #memories
extends Node
class_name DualGameplaySystem

signal mode_changed(new_mode: String)
signal action_performed(mode: String, action: String, data: Dictionary)

# Gameplay modes
enum GameMode {
	EXPLORER,  # Discover, observe, learn
	CREATOR    # Build, manifest, transform
}

var current_mode = GameMode.EXPLORER
var mode_abilities = {}
var mode_constraints = {}
var mode_visuals = {}

# Mode-specific data
var explorer_data = {
	"discovered_entities": [],
	"learned_patterns": [],
	"observation_points": 0,
	"knowledge_level": 1
}

var creator_data = {
	"created_entities": [],
	"manifested_words": [],
	"creation_energy": 100.0,
	"mastery_level": 1
}

func _ready():
	print("🎮 Dual Gameplay System initialized")
	setup_mode_abilities()
	setup_mode_constraints()
	setup_mode_visuals()

func setup_mode_abilities():
	"""Define what each mode can do"""
	mode_abilities[GameMode.EXPLORER] = {
		"observe": true,
		"analyze": true,
		"learn": true,
		"interact": true,
		"create": false,
		"transform": false,
		"manifest": false,
		"delete": false
	}
	
	mode_abilities[GameMode.CREATOR] = {
		"observe": true,
		"analyze": false,
		"learn": false,
		"interact": true,
		"create": true,
		"transform": true,
		"manifest": true,
		"delete": true
	}

func setup_mode_constraints():
	"""Define limitations for each mode"""
	mode_constraints[GameMode.EXPLORER] = {
		"max_speed": 10.0,
		"interaction_range": 5.0,
		"visibility_range": 50.0,
		"can_fly": false,
		"can_teleport": false,
		"energy_cost_multiplier": 0.5
	}
	
	mode_constraints[GameMode.CREATOR] = {
		"max_speed": 50.0,
		"interaction_range": 20.0,
		"visibility_range": 100.0,
		"can_fly": true,
		"can_teleport": true,
		"energy_cost_multiplier": 2.0
	}

func setup_mode_visuals():
	"""Define visual differences for each mode"""
	mode_visuals[GameMode.EXPLORER] = {
		"ui_color": Color.CYAN,
		"cursor_shape": "magnifying_glass",
		"trail_effect": "subtle_glow",
		"ambient_particles": "knowledge_sparks",
		"screen_overlay": "exploration_hud"
	}
	
	mode_visuals[GameMode.CREATOR] = {
		"ui_color": Color.GOLD,
		"cursor_shape": "creation_wand",
		"trail_effect": "rainbow_trail",
		"ambient_particles": "creation_energy",
		"screen_overlay": "creation_hud"
	}

func switch_mode():
	"""Toggle between gameplay modes"""
	current_mode = (current_mode + 1) % GameMode.size()
	apply_mode_changes()
	mode_changed.emit(get_mode_name())
	
	print("🎮 Switched to %s Mode" % get_mode_name())
	show_mode_abilities()

func set_mode(mode: GameMode):
	"""Set specific gameplay mode"""
	if current_mode != mode:
		current_mode = mode
		apply_mode_changes()
		mode_changed.emit(get_mode_name())

func get_mode_name() -> String:
	match current_mode:
		GameMode.EXPLORER:
			return "Explorer"
		GameMode.CREATOR:
			return "Creator"
		_:
			return "Unknown"

func apply_mode_changes():
	"""Apply all mode-specific changes"""
	# This would connect to your actual game systems
	var constraints = mode_constraints[current_mode]
	var visuals = mode_visuals[current_mode]
	
	# Apply constraints
	# player.max_speed = constraints.max_speed
	# player.can_fly = constraints.can_fly
	# etc...
	
	# Apply visuals
	# ui.set_theme_color(visuals.ui_color)
	# cursor.set_shape(visuals.cursor_shape)
	# etc...

func can_perform_action(action: String) -> bool:
	"""Check if current mode allows an action"""
	var abilities = mode_abilities[current_mode]
	return abilities.get(action, false)

func try_perform_action(action: String, data: Dictionary = {}) -> bool:
	"""Attempt to perform an action in current mode"""
	if not can_perform_action(action):
		print("❌ %s Mode cannot perform action: %s" % [get_mode_name(), action])
		return false
	
	# Perform the action
	match action:
		"observe":
			return perform_observe(data)
		"analyze":
			return perform_analyze(data)
		"learn":
			return perform_learn(data)
		"interact":
			return perform_interact(data)
		"create":
			return perform_create(data)
		"transform":
			return perform_transform(data)
		"manifest":
			return perform_manifest(data)
		"delete":
			return perform_delete(data)
	
	return false

func perform_observe(data: Dictionary) -> bool:
	"""Explorer mode: Observe entity"""
	if current_mode == GameMode.EXPLORER:
		explorer_data.observation_points += 1
		if data.has("entity_id"):
			if not data.entity_id in explorer_data.discovered_entities:
				explorer_data.discovered_entities.append(data.entity_id)
				print("🔍 Discovered new entity: %s" % data.entity_id)
	
	action_performed.emit(get_mode_name(), "observe", data)
	return true

func perform_analyze(data: Dictionary) -> bool:
	"""Explorer mode: Analyze patterns"""
	if current_mode == GameMode.EXPLORER:
		if data.has("pattern"):
			explorer_data.learned_patterns.append(data.pattern)
			print("🧠 Learned new pattern: %s" % data.pattern)
	
	action_performed.emit(get_mode_name(), "analyze", data)
	return true

func perform_learn(data: Dictionary) -> bool:
	"""Explorer mode: Learn from observation"""
	if current_mode == GameMode.EXPLORER:
		explorer_data.knowledge_level += 0.1
		print("📚 Knowledge increased to level %.1f" % explorer_data.knowledge_level)
	
	action_performed.emit(get_mode_name(), "learn", data)
	return true

func perform_interact(data: Dictionary) -> bool:
	"""Both modes: Interact with entity"""
	print("🤝 Interacting with: %s" % data.get("entity_id", "unknown"))
	action_performed.emit(get_mode_name(), "interact", data)
	return true

func perform_create(data: Dictionary) -> bool:
	"""Creator mode: Create new entity"""
	if current_mode == GameMode.CREATOR and creator_data.creation_energy >= 10.0:
		creator_data.creation_energy -= 10.0
		creator_data.created_entities.append(data.get("entity_type", "unknown"))
		print("✨ Created new %s" % data.get("entity_type", "entity"))
		
		action_performed.emit(get_mode_name(), "create", data)
		return true
	
	if creator_data.creation_energy < 10.0:
		print("⚡ Not enough creation energy!")
	return false

func perform_transform(data: Dictionary) -> bool:
	"""Creator mode: Transform existing entity"""
	if current_mode == GameMode.CREATOR and creator_data.creation_energy >= 5.0:
		creator_data.creation_energy -= 5.0
		print("🔄 Transformed entity: %s" % data.get("entity_id", "unknown"))
		
		action_performed.emit(get_mode_name(), "transform", data)
		return true
	
	return false

func perform_manifest(data: Dictionary) -> bool:
	"""Creator mode: Manifest word into reality"""
	if current_mode == GameMode.CREATOR and creator_data.creation_energy >= 20.0:
		creator_data.creation_energy -= 20.0
		var word = data.get("word", "")
		creator_data.manifested_words.append(word)
		print("🌟 Manifested word '%s' into reality!" % word)
		
		action_performed.emit(get_mode_name(), "manifest", data)
		return true
	
	return false

func perform_delete(data: Dictionary) -> bool:
	"""Creator mode: Delete entity"""
	if current_mode == GameMode.CREATOR:
		print("🗑️ Deleted entity: %s" % data.get("entity_id", "unknown"))
		action_performed.emit(get_mode_name(), "delete", data)
		return true
	
	return false

func show_mode_abilities():
	"""Display current mode abilities"""
	var abilities = mode_abilities[current_mode]
	print("\n🎮 %s Mode Abilities:" % get_mode_name())
	for ability in abilities:
		if abilities[ability]:
			print("  ✅ %s" % ability)
		else:
			print("  ❌ %s" % ability)

func get_mode_stats() -> Dictionary:
	"""Get current mode statistics"""
	match current_mode:
		GameMode.EXPLORER:
			return explorer_data
		GameMode.CREATOR:
			return creator_data
		_:
			return {}

func update_creation_energy(delta: float):
	"""Regenerate creation energy over time"""
	if current_mode == GameMode.CREATOR:
		creator_data.creation_energy = min(100.0, creator_data.creation_energy + delta * 5.0)

func _input(event):
	"""Handle mode switching input"""
	if event.is_action_pressed("switch_gameplay_mode"):  # Define this in project settings
		switch_mode()

# Save/Load mode progress
func save_progress() -> Dictionary:
	return {
		"current_mode": current_mode,
		"explorer_data": explorer_data,
		"creator_data": creator_data
	}

func load_progress(data: Dictionary):
	if data.has("current_mode"):
		current_mode = data.current_mode
	if data.has("explorer_data"):
		explorer_data = data.explorer_data
	if data.has("creator_data"):
		creator_data = data.creator_data
	
	apply_mode_changes()