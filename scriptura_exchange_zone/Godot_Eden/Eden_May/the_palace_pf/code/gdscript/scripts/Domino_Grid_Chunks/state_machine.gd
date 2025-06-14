# state_machine.gd
extends Node

class_name StateMachine

var parent
var current_state = null
var states = {}
var previous_state = null

func _init(parent_entity):
	parent = parent_entity

func add_state(state_name: String, state_object) -> void:
	states[state_name] = state_object

func change_state(new_state_name: String) -> void:
	if current_state:
		current_state.exit()
		previous_state = current_state
	
	if states.has(new_state_name):
		current_state = states[new_state_name]
		current_state.enter()
	else:
		push_error("State not found: " + new_state_name)

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)
