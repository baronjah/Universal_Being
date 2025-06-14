# 🏛️ Eden Action System - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
class_name EdenActionSystem
## Eden-style Action System for complex multi-step interactions
## Based on the Eden project's interaction array patterns

signal action_started(action_name: String, target: Node)
signal action_completed(action_name: String, result: Dictionary)
signal action_failed(action_name: String, reason: String)
signal combo_triggered(combo_name: String, targets: Array)

## Action definition structure
var action_definitions: Dictionary = {
	"examine": {
		"steps": ["look", "analyze", "report"],
		"required_components": [],
		"duration": 1.0,
		"can_chain": true
	},
	"pickup": {
		"steps": ["approach", "grasp", "lift"],
		"required_components": ["RigidBody3D"],
		"duration": 0.5,
		"can_chain": true
	},
	"activate": {
		"steps": ["target", "charge", "trigger"],
		"required_components": [],
		"duration": 2.0,
		"can_chain": false
	},
	"combine": {
		"steps": ["select_first", "select_second", "merge"],
		"required_components": [],
		"min_targets": 2,
		"duration": 3.0,
		"can_chain": false
	}
}

## Combo patterns (from Eden project)
var combo_patterns: Dictionary = {
	"quick_double": {
		"pattern": ["click", "click"],
		"max_time": 0.5,
		"action": "activate"
	},
	"hold_drag": {
		"pattern": ["press", "hold", "release"],
		"min_hold_time": 0.5,
		"action": "pickup"
	},
	"triple_tap": {
		"pattern": ["click", "click", "click"],
		"max_time": 1.0,
		"action": "examine"
	}
}

## Active actions being processed
var active_actions: Array[Dictionary] = []
var action_queue: Array[Dictionary] = []
var combo_buffer: Array[Dictionary] = []
var last_combo_time: float = 0.0

## Multi-target selection
var selected_targets: Array[Node] = []
var selection_mode: String = ""

## Action state machine
enum ActionState {
	IDLE,
	PREPARING,
	EXECUTING,
	COMPLETING,
	FAILED
}

var current_state: ActionState = ActionState.IDLE

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	set_process(true)

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	_process_action_queue(delta)
	_update_active_actions(delta)
	_cleanup_old_combos()

## Queue an action for execution

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
func queue_action(action_name: String, target: Node, params: Dictionary = {}) -> bool:
	if not action_definitions.has(action_name):
		push_error("Unknown action: " + action_name)
		return false
	
	var action_def = action_definitions[action_name]
	
	# Check requirements
	if not _check_action_requirements(action_def, target):
		emit_signal("action_failed", action_name, "Requirements not met")
		return false
	
	var action = {
		"name": action_name,
		"target": target,
		"params": params,
		"definition": action_def,
		"state": ActionState.IDLE,
		"current_step": 0,
		"start_time": Time.get_ticks_msec() / 1000.0,
		"progress": 0.0
	}
	
	action_queue.append(action)
	return true

## Process combo input
func process_combo_input(input_type: String, target: Node = null) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	
	combo_buffer.append({
		"type": input_type,
		"time": current_time,
		"target": target
	})
	
	# Clean old inputs
	combo_buffer = combo_buffer.filter(func(input): return current_time - input.time < 2.0)
	
	# Check for patterns
	for pattern_name in combo_patterns:
		var pattern = combo_patterns[pattern_name]
		if _check_combo_pattern(pattern):
			_trigger_combo(pattern_name, pattern)
			combo_buffer.clear()
			break

## Check if action requirements are met
func _check_action_requirements(action_def: Dictionary, target: Node) -> bool:
	if action_def.has("required_components"):
		for component in action_def.required_components:
			if not target.is_class(component):
				return false
	
	if action_def.has("min_targets") and selected_targets.size() < action_def.min_targets:
		return false
	
	return true

## Cleanup old combo inputs
func _cleanup_old_combos() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	combo_buffer = combo_buffer.filter(func(input): return current_time - input.time < 2.0)

## Process the action queue
func _process_action_queue(_delta: float) -> void:
	if action_queue.is_empty() or current_state != ActionState.IDLE:
		return
	
	var action = action_queue.pop_front()
	_start_action(action)

## Start executing an action
func _start_action(action: Dictionary) -> void:
	current_state = ActionState.PREPARING
	active_actions.append(action)
	emit_signal("action_started", action.name, action.target)
	
	# Execute first step
	_execute_action_step(action)

## Execute current step of an action
func _execute_action_step(action: Dictionary) -> void:
	var steps = action.definition.steps
	if action.current_step >= steps.size():
		_complete_action(action)
		return
	
	var step_name = steps[action.current_step]
	
	match step_name:
		"look":
			_step_look(action)
		"analyze":
			_step_analyze(action)
		"report":
			_step_report(action)
		"approach":
			_step_approach(action)
		"grasp":
			_step_grasp(action)
		"lift":
			_step_lift(action)
		"target":
			_step_target(action)
		"charge":
			_step_charge(action)
		"trigger":
			_step_trigger(action)
		_:
			push_warning("Unknown step: " + step_name)

## Update active actions
func _update_active_actions(delta: float) -> void:
	for i in range(active_actions.size() - 1, -1, -1):
		var action = active_actions[i]
		action.progress += delta / action.definition.duration
		
		if action.progress >= 1.0:
			action.current_step += 1
			action.progress = 0.0
			_execute_action_step(action)

## Complete an action
func _complete_action(action: Dictionary) -> void:
	active_actions.erase(action)
	current_state = ActionState.IDLE
	
	var result = {
		"success": true,
		"target": action.target,
		"data": {}
	}
	
	emit_signal("action_completed", action.name, result)

## Check combo pattern
func _check_combo_pattern(pattern: Dictionary) -> bool:
	var pattern_array = pattern.pattern
	if combo_buffer.size() < pattern_array.size():
		return false
	
	var start_index = combo_buffer.size() - pattern_array.size()
	
	for i in range(pattern_array.size()):
		if combo_buffer[start_index + i].type != pattern_array[i]:
			return false
		
		if i > 0 and pattern.has("max_time"):
			var time_diff = combo_buffer[start_index + i].time - combo_buffer[start_index + i - 1].time
			if time_diff > pattern.max_time:
				return false
	
	return true

## Trigger a combo
func _trigger_combo(combo_name: String, pattern: Dictionary) -> void:
	var targets = []
	for input in combo_buffer:
		if input.target and input.target not in targets:
			targets.append(input.target)
	
	emit_signal("combo_triggered", combo_name, targets)
	
	if pattern.has("action"):
		for target in targets:
			queue_action(pattern.action, target)

## Action step implementations
func _step_look(action: Dictionary) -> void:
	print("Looking at: ", action.target.name)

func _step_analyze(action: Dictionary) -> void:
	var data = {
		"type": action.target.get_class(),
		"position": action.target.global_position if action.target is Node3D else Vector3.ZERO,
		"groups": action.target.get_groups()
	}
	action.params["analysis"] = data

func _step_report(action: Dictionary) -> void:
	if action.params.has("analysis"):
		print("Analysis complete: ", action.params.analysis)

func _step_approach(action: Dictionary) -> void:
	print("Approaching: ", action.target.name)

func _step_grasp(action: Dictionary) -> void:
	if action.target is RigidBody3D:
		action.target.set_freeze_enabled(true)

func _step_lift(action: Dictionary) -> void:
	if action.target is Node3D:
		action.target.position.y += 1.0

func _step_target(action: Dictionary) -> void:
	print("Targeting: ", action.target.name)

func _step_charge(_action: Dictionary) -> void:
	print("Charging power...")

func _step_trigger(action: Dictionary) -> void:
	if action.target.has_method("activate"):
		action.target.activate()
	else:
		print("Triggered: ", action.target.name)

## Multi-target selection
func start_selection_mode(mode: String) -> void:
	selection_mode = mode
	selected_targets.clear()

func add_to_selection(target: Node) -> void:
	if target not in selected_targets:
		selected_targets.append(target)

func clear_selection() -> void:
	selected_targets.clear()
	selection_mode = ""

func execute_multi_target_action(action_name: String) -> void:
	if selected_targets.size() < 2:
		return
	
	var params = {
		"targets": selected_targets.duplicate()
	}
	
	queue_action(action_name, selected_targets[0], params)