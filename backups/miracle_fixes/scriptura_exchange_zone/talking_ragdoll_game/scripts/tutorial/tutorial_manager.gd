# ==================================================
# SCRIPT NAME: tutorial_manager.gd
# DESCRIPTION: Manages tutorial flow and logging system
# PURPOSE: Guide users through ragdoll controls with scene transitions
# CREATED: 2025-05-26 - Tutorial system implementation
# ==================================================

extends UniversalBeingBase
# Tutorial phases
enum TutorialPhase {
	INTRO,
	BASIC_MOVEMENT,
	ADVANCED_MOVEMENT,
	OBJECT_INTERACTION,
	PHYSICS_PLAYGROUND,
	COMPLETE
}

# Current tutorial state
var current_phase: TutorialPhase = TutorialPhase.INTRO
var phase_start_time: float = 0.0
var tutorial_active: bool = false

# Logging system
var action_log: Array = []
var log_file_path: String = "user://tutorial_log_%s.json" % Time.get_datetime_string_from_system().replace(":", "-")

# Scene references
var tutorial_scenes = {
	TutorialPhase.INTRO: "res://scenes/tutorial/intro_scene.tscn",
	TutorialPhase.BASIC_MOVEMENT: "res://scenes/tutorial/basic_movement_scene.tscn",
	TutorialPhase.ADVANCED_MOVEMENT: "res://scenes/tutorial/advanced_movement_scene.tscn",
	TutorialPhase.OBJECT_INTERACTION: "res://scenes/tutorial/object_interaction_scene.tscn",
	TutorialPhase.PHYSICS_PLAYGROUND: "res://scenes/tutorial/physics_playground_scene.tscn",
	TutorialPhase.COMPLETE: "res://scenes/tutorial/complete_scene.tscn"
}

# Tutorial UI elements
var tutorial_ui: Control
var instruction_label: RichTextLabel
var progress_bar: ProgressBar
var hint_panel: Panel

# Phase completion requirements
var phase_requirements = {
	TutorialPhase.INTRO: {"time": 5.0},
	TutorialPhase.BASIC_MOVEMENT: {"commands": ["forward", "backward", "left", "right", "stop"]},
	TutorialPhase.ADVANCED_MOVEMENT: {"commands": ["run", "jump", "crouch", "rotate_left", "rotate_right"]},
	TutorialPhase.OBJECT_INTERACTION: {"actions": ["pickup", "drop", "throw"]},
	TutorialPhase.PHYSICS_PLAYGROUND: {"time": 60.0}
}

# Completed actions per phase
var phase_progress: Dictionary = {}

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[TutorialManager] Initializing tutorial system...")
	
	# Initialize phase progress tracking
	for phase in TutorialPhase.values():
		phase_progress[phase] = {}
	
	# Create tutorial UI
	_create_tutorial_ui()
	
	# Connect to console for command logging
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.command_executed.connect(_on_command_executed)
	
	print("[TutorialManager] Tutorial system ready!")

func _create_tutorial_ui() -> void:
	# Create canvas layer for tutorial UI (on top of everything)
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "TutorialCanvasLayer"
	canvas_layer.layer = 200  # Higher than console (120)
	add_child(canvas_layer)
	
	# Create main UI container
	tutorial_ui = Control.new()
	tutorial_ui.name = "TutorialUI"
	tutorial_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tutorial_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	FloodgateController.universal_add_child(tutorial_ui, canvas_layer)
	
	# Create instruction panel
	var instruction_panel = Panel.new()
	instruction_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	instruction_panel.set_offsets_preset(Control.PRESET_TOP_WIDE)
	instruction_panel.size = Vector2(0, 100)
	instruction_panel.modulate.a = 0.8
	FloodgateController.universal_add_child(instruction_panel, tutorial_ui)
	
	# Create instruction label
	instruction_label = RichTextLabel.new()
	instruction_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	instruction_label.set_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, 10)
	instruction_label.bbcode_enabled = true
	instruction_label.fit_content = true
	FloodgateController.universal_add_child(instruction_label, instruction_panel)
	
	# Create progress bar
	progress_bar = ProgressBar.new()
	progress_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	progress_bar.position.y = -30
	progress_bar.size = Vector2(0, 20)
	progress_bar.modulate.a = 0.7
	FloodgateController.universal_add_child(progress_bar, tutorial_ui)
	
	# Create hint panel (initially hidden)
	hint_panel = Panel.new()
	hint_panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	hint_panel.position.x = -220
	hint_panel.size = Vector2(200, 150)
	hint_panel.modulate.a = 0.0
	FloodgateController.universal_add_child(hint_panel, tutorial_ui)
	
	# Initially hide UI
	tutorial_ui.visible = false


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
func start_tutorial() -> void:
	"""Start the tutorial from the beginning"""
	print("[TutorialManager] Starting tutorial...")
	tutorial_active = true
	current_phase = TutorialPhase.INTRO
	phase_start_time = Time.get_ticks_msec() / 1000.0
	
	# Show UI
	tutorial_ui.visible = true
	
	# Log tutorial start
	_log_action("tutorial_started", {
		"timestamp": Time.get_datetime_string_from_system(),
		"version": "1.0"
	})
	
	# Load first scene
	_load_tutorial_scene(current_phase)
	_update_instructions()

func stop_tutorial() -> void:
	"""Stop the tutorial and return to main game"""
	print("[TutorialManager] Stopping tutorial...")
	tutorial_active = false
	tutorial_ui.visible = false
	
	# Log tutorial stop
	_log_action("tutorial_stopped", {
		"phase": TutorialPhase.keys()[current_phase],
		"completion_percentage": _calculate_completion_percentage()
	})
	
	# Save log to file
	_save_log()
	
	# Return to main scene
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _load_tutorial_scene(phase: TutorialPhase) -> void:
	"""Load the scene for the current tutorial phase"""
	if phase in tutorial_scenes:
		var scene_path = tutorial_scenes[phase]
		print("[TutorialManager] Loading tutorial scene: ", scene_path)
		
		# For now, just log the intent - actual scene loading would go here
		_log_action("scene_loaded", {
			"phase": TutorialPhase.keys()[phase],
			"scene": scene_path
		})

func _update_instructions() -> void:
	"""Update instruction text based on current phase"""
	var instructions = {
		TutorialPhase.INTRO: "[center][b]Welcome to Ragdoll Tutorial![/b][/center]\n[center]Let's learn how to control your character[/center]",
		TutorialPhase.BASIC_MOVEMENT: "[center][b]Basic Movement[/b][/center]\nTry these commands:\n• ragdoll_move forward\n• ragdoll_move backward\n• ragdoll_move left/right\n• ragdoll_move stop",
		TutorialPhase.ADVANCED_MOVEMENT: "[center][b]Advanced Movement[/b][/center]\nNow try:\n• ragdoll_run\n• ragdoll_jump\n• ragdoll_crouch\n• ragdoll_rotate left/right",
		TutorialPhase.OBJECT_INTERACTION: "[center][b]Object Interaction[/b][/center]\nInteract with objects:\n• ragdoll_pickup\n• ragdoll_drop\n• Look at objects and use them",
		TutorialPhase.PHYSICS_PLAYGROUND: "[center][b]Physics Playground[/b][/center]\nExperiment freely!\nTry combining movements and interactions",
		TutorialPhase.COMPLETE: "[center][b]Tutorial Complete![/b][/center]\n[center]You've mastered ragdoll control![/center]"
	}
	
	if current_phase in instructions:
		instruction_label.text = instructions[current_phase]

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	if not tutorial_active:
		return
	
	# Update progress bar
	_update_progress()
	
	# Check for phase completion
	if _is_phase_complete():
		_advance_to_next_phase()

func _update_progress() -> void:
	"""Update the progress bar based on phase completion"""
	var progress = 0.0
	
	match current_phase:
		TutorialPhase.INTRO:
			var elapsed = (Time.get_ticks_msec() / 1000.0) - phase_start_time
			var required = phase_requirements[current_phase]["time"]
			progress = min(elapsed / required, 1.0)
		
		TutorialPhase.BASIC_MOVEMENT, TutorialPhase.ADVANCED_MOVEMENT:
			var required_commands = phase_requirements[current_phase]["commands"]
			var completed = 0
			for cmd in required_commands:
				if phase_progress[current_phase].has(cmd):
					completed += 1
			progress = float(completed) / float(required_commands.size())
		
		TutorialPhase.OBJECT_INTERACTION:
			var required_actions = phase_requirements[current_phase]["actions"]
			var completed = 0
			for action in required_actions:
				if phase_progress[current_phase].has(action):
					completed += 1
			progress = float(completed) / float(required_actions.size())
		
		TutorialPhase.PHYSICS_PLAYGROUND:
			var elapsed = (Time.get_ticks_msec() / 1000.0) - phase_start_time
			var required = phase_requirements[current_phase]["time"]
			progress = min(elapsed / required, 1.0)
	
	progress_bar.value = progress * 100

func _is_phase_complete() -> bool:
	"""Check if current phase requirements are met"""
	match current_phase:
		TutorialPhase.INTRO, TutorialPhase.PHYSICS_PLAYGROUND:
			var elapsed = (Time.get_ticks_msec() / 1000.0) - phase_start_time
			return elapsed >= phase_requirements[current_phase]["time"]
		
		TutorialPhase.BASIC_MOVEMENT, TutorialPhase.ADVANCED_MOVEMENT:
			var required_commands = phase_requirements[current_phase]["commands"]
			for cmd in required_commands:
				if not phase_progress[current_phase].has(cmd):
					return false
			return true
		
		TutorialPhase.OBJECT_INTERACTION:
			var required_actions = phase_requirements[current_phase]["actions"]
			for action in required_actions:
				if not phase_progress[current_phase].has(action):
					return false
			return true
		
		TutorialPhase.COMPLETE:
			return true
	
	return false

func _advance_to_next_phase() -> void:
	"""Move to the next tutorial phase"""
	_log_action("phase_completed", {
		"phase": TutorialPhase.keys()[current_phase],
		"duration": (Time.get_ticks_msec() / 1000.0) - phase_start_time
	})
	
	# Advance to next phase
	var next_phase = current_phase + 1
	if next_phase <= TutorialPhase.COMPLETE:
		current_phase = next_phase as TutorialPhase
		phase_start_time = Time.get_ticks_msec() / 1000.0
		
		# Reset progress for new phase
		phase_progress[current_phase].clear()
		
		# Load new scene
		_load_tutorial_scene(current_phase)
		_update_instructions()
		
		# Show phase transition effect
		_show_phase_transition()
	else:
		# Tutorial complete
		stop_tutorial()

func _show_phase_transition() -> void:
	"""Show a smooth transition between phases"""
	# Create transition overlay
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.modulate.a = 0.0
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(overlay, tutorial_ui)
	
	# Animate fade in/out
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.3)
	tween.tween_callback(_update_instructions)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.3)
	tween.tween_callback(overlay.queue_free)

func _on_command_executed(command: String, args: Array) -> void:
	"""Log when a command is executed during tutorial"""
	if not tutorial_active:
		return
	
	# Log the command
	_log_action("command_executed", {
		"command": command,
		"args": args,
		"phase": TutorialPhase.keys()[current_phase]
	})
	
	# Track progress for movement commands
	if command.begins_with("ragdoll_"):
		var action = command.trim_prefix("ragdoll_")
		
		# Map commands to progress tracking
		match action:
			"move":
				if args.size() > 0:
					phase_progress[current_phase][args[0]] = true
			"run", "jump", "crouch":
				phase_progress[current_phase][action] = true
			"rotate":
				if args.size() > 0:
					phase_progress[current_phase]["rotate_" + args[0]] = true
			"pickup", "drop":
				phase_progress[current_phase][action] = true

func _log_action(action_type: String, data: Dictionary) -> void:
	"""Log a user action with timestamp"""
	var log_entry = {
		"timestamp": Time.get_ticks_msec() / 1000.0,
		"action": action_type,
		"data": data
	}
	action_log.append(log_entry)
	
	# Also print to console for debugging
	print("[Tutorial Log] ", action_type, ": ", data)

func _save_log() -> void:
	"""Save the action log to a file"""
	var file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if file:
		var log_data = {
			"session_start": Time.get_datetime_string_from_system(),
			"total_duration": Time.get_ticks_msec() / 1000.0,
			"completion_percentage": _calculate_completion_percentage(),
			"actions": action_log
		}
		file.store_string(JSON.stringify(log_data, "\t"))
		file.close()
		print("[TutorialManager] Log saved to: ", log_file_path)

func _calculate_completion_percentage() -> float:
	"""Calculate overall tutorial completion percentage"""
	var total_phases = TutorialPhase.COMPLETE
	var completed_phases = int(current_phase)
	return (float(completed_phases) / float(total_phases)) * 100.0

func show_hint(hint_text: String, duration: float = 3.0) -> void:
	"""Show a hint to the user"""
	var hint_label = RichTextLabel.new()
	hint_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hint_label.set_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE, 10)
	hint_label.bbcode_enabled = true
	hint_label.text = "[center]" + hint_text + "[/center]"
	FloodgateController.universal_add_child(hint_label, hint_panel)
	
	# Animate hint panel
	var tween = create_tween()
	tween.tween_property(hint_panel, "modulate:a", 0.9, 0.3)
	tween.tween_interval(duration)
	tween.tween_property(hint_panel, "modulate:a", 0.0, 0.3)
	tween.tween_callback(hint_label.queue_free)

# Public API for other systems
func is_tutorial_active() -> bool:
	return tutorial_active

func get_current_phase() -> TutorialPhase:
	return current_phase

func log_custom_action(action: String, data: Dictionary) -> void:
	"""Allow other systems to log actions"""
	_log_action(action, data)