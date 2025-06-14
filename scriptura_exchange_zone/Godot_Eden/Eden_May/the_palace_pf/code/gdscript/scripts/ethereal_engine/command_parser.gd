# command_parser.gd
class_name CommandParser
extends Node

static func parse_command(command_text):
	# Basic structure: ACTION TARGET [PARAMETERS]
	var tokens = command_text.split(" ")
	if tokens.size() < 2:
		return {"success": false, "error": "Command too short"}
		
	var action = tokens[0].to_lower()
	var target = tokens[1].to_lower()
	var params = {}
	
	# Parse remaining tokens as parameters
	for i in range(2, tokens.size()):
		var param_parts = tokens[i].split("=")
		if param_parts.size() == 2:
			params[param_parts[0]] = parse_parameter_value(param_parts[1])
	
	# Validate action and target
	if !is_valid_action(action):
		return {"success": false, "error": "Invalid action: " + action}
	if !is_valid_target(target):
		return {"success": false, "error": "Invalid target: " + target}
		
	# Process the command based on action type
	match action:
		"create":
			return process_create_command(target, params)
		"modify":
			return process_modify_command(target, params)
		# Other actions...
	
	return {"success": true, "action": action, "target": target, "parameters": params}
	
static func process_create_command(target, params):
	# Example: "create water position=10,5,3 size=3,3,3 state=liquid"
	var position = Vector3.ZERO
	var size = Vector3.ONE
	var state = "solid"
	
	if "position" in params:
		position = params.position
	if "size" in params:
		size = params.size
	if "state" in params:
		state = params.state
		
	return {
		"success": true,
		"action": "create",
		"parameters": {
			"type": target,
			"position": position,
			"size": size,
			"state": state,
			"properties": params
		}
	}
	
# Additional parsing methods...
