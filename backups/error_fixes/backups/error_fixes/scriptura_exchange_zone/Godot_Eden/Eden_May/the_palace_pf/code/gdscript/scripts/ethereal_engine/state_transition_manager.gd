# state_transition_manager.gd
extends Node

# State transition rules
var state_transitions = {
	"water": {
		"solid": {
			"conditions": {"temperature": {"below": 0}},
			"target_state": "solid",
			"visual_effect": "freezing",
			"sound_effect": "ice_forming"
		},
		"liquid": {
			"conditions": {"temperature": {"above": 0, "below": 100}},
			"target_state": "liquid",
			"visual_effect": "flowing",
			"sound_effect": "water_flowing"
		},
		"gas": {
			"conditions": {"temperature": {"above": 100}},
			"target_state": "gas",
			"visual_effect": "steaming",
			"sound_effect": "water_boiling"
		}
	},
	# Other elements...
}

func can_transition(element, from_state, to_state):
	if element in state_transitions:
		if to_state in state_transitions[element]:
			return true
	return false
	
func get_transition_conditions(element, to_state):
	return state_transitions[element][to_state].conditions
	
func transition_element(element, new_state):
	if can_transition(element.type, element.current_state, new_state):
		# Play effects
		play_visual_effect(
			state_transitions[element.type][new_state].visual_effect,
			element.global_position
		)
		play_sound_effect(
			state_transitions[element.type][new_state].sound_effect,
			element.global_position
		)
		
		# Change state
		element.change_state(new_state)
		return true
	return false
	
func play_visual_effect(effect_name, position):
	var effect = load("res://effects/visual/" + effect_name + ".tscn").instance()
	effect.global_position = position
	get_tree().get_root().add_child(effect)
	
func play_sound_effect(effect_name, position):
	var effect = load("res://effects/sound/" + effect_name + ".tscn").instance()
	effect.global_position = position
	get_tree().get_root().add_child(effect)
