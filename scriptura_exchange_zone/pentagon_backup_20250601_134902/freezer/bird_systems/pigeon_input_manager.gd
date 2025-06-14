# ==================================================
# SCRIPT NAME: pigeon_input_manager.gd
# DESCRIPTION: Sets up input actions for pigeon controller
# PURPOSE: Ensure pigeon controls work without project settings
# CREATED: 2025-05-24 - Input mapping for pigeon
# ==================================================

extends UniversalBeingBase
func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_setup_input_actions()

func _setup_input_actions() -> void:
	# Movement actions
	_add_action_if_missing("move_left", [KEY_LEFT, KEY_A])
	_add_action_if_missing("move_right", [KEY_RIGHT, KEY_D])
	_add_action_if_missing("move_forward", [KEY_UP, KEY_W])
	_add_action_if_missing("move_back", [KEY_DOWN, KEY_S])
	
	# Jump/Fly actions
	_add_action_if_missing("jump", [KEY_SPACE])
	_add_action_if_missing("fly_toggle", [KEY_F])
	_add_action_if_missing("fly_up", [KEY_Q, KEY_W])
	_add_action_if_missing("fly_down", [KEY_E, KEY_S])
	_add_action_if_missing("walk", [KEY_SHIFT])

func _add_action_if_missing(action_name: String, keys: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		
		for key in keys:
			var event = InputEventKey.new()
			event.keycode = key
			InputMap.action_add_event(action_name, event)

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