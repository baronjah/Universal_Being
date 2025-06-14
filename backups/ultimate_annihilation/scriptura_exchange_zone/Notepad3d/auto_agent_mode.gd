extends Node

class_name AutoAgentMode

# Auto Agent Mode
# Enables automatic processing of commands, wishes, and trajectories
# Manages word transformations through various operations
# Connects projects in dimensional space

signal agent_mode_activated(mode, parameters)
signal transform_applied(operation, word, result)
signal project_centered(project_name, coordinates)
signal word_power_changed(word, old_power, new_power)

# === CONSTANTS ===
const OPERATIONS = [
	"update",     # Update word state
	"upgrade",    # Increase word power
	"downgrade",  # Decrease word power
	"merge",      # Combine words
	"split",      # Split word into components
	"evolve",     # Evolve word to next form
	"devolve",    # Devolve word to previous form
	"connect",    # Connect word to another
	"disconnect", # Disconnect word from another
	"activate",   # Activate word effect
	"deactivate", # Deactivate word effect
	"transform",  # Transform word shape
	"relocate",   # Move word to new location
	"synchronize" # Synchronize word with project
]

# === VARIABLES ===
var is_mode_active = false       # Whether auto agent mode is active
var active_operations = []       # Currently available operations
var project_centers = {}         # Center coordinates for each project
var word_trajectories = {}       # Word movement trajectories
var word_power_levels = {}       # Power levels for each word
var operation_cooldowns = {}     # Cooldown for each operation
var transform_history = []       # History of transformations

# === INITIALIZATION ===
func _ready():
	# Initialize with default settings
	is_mode_active = true
	
	# Initialize operations
	initialize_operations()
	
	print("Auto Agent Mode initialized")

# Initialize available operations
func initialize_operations():
	active_operations = OPERATIONS.duplicate()
	
	# Initialize cooldowns
	for op in active_operations:
		operation_cooldowns[op] = 0
	
	print("Initialized " + str(active_operations.size()) + " operations")

# === STATE MANAGEMENT ===

# Check if agent mode is active
func is_active():
	return is_mode_active

# Activate agent mode
func activate():
	is_mode_active = true
	emit_signal("agent_mode_activated", "activate", {})
	print("Auto Agent Mode activated")
	return true

# Deactivate agent mode
func deactivate():
	is_mode_active = false
	emit_signal("agent_mode_activated", "deactivate", {})
	print("Auto Agent Mode deactivated")
	return true

# Set project centers
func set_project_centers(centers):
	project_centers = centers
	
	# Emit signals for each center
	for project in project_centers:
		emit_signal("project_centered", project, project_centers[project])
	
	print("Set " + str(project_centers.size()) + " project centers")
	return project_centers

# Get number of available operations
func get_operation_count():
	return active_operations.size()

# Get available operations
func get_available_operations():
	var available = []
	
	for op in active_operations:
		if operation_cooldowns[op] <= 0:
			available.append(op)
	
	return available

# === TRANSFORM OPERATIONS ===

# Apply a transform operation to a word
func apply_transform(operation, word, parameters = {}):
	if not is_active():
		print("Cannot apply transform: Agent mode is not active")
		return null
	
	if not active_operations.has(operation):
		print("Cannot apply transform: Operation '" + operation + "' not available")
		return null
	
	if operation_cooldowns[operation] > 0:
		print("Cannot apply transform: Operation '" + operation + "' is on cooldown")
		return null
	
	# Apply cooldown
	operation_cooldowns[operation] = 3  # 3 seconds cooldown
	
	# Initialize word power if needed
	if not word_power_levels.has(word):
		word_power_levels[word] = 1.0
	
	# Store old power for signal
	var old_power = word_power_levels[word]
	
	# Apply the operation
	var result = null
	
	match operation:
		"update":
			result = _transform_update(word, parameters)
		"upgrade":
			result = _transform_upgrade(word, parameters)
		"downgrade":
			result = _transform_downgrade(word, parameters)
		"merge":
			result = _transform_merge(word, parameters)
		"split":
			result = _transform_split(word, parameters)
		"evolve":
			result = _transform_evolve(word, parameters)
		"devolve":
			result = _transform_devolve(word, parameters)
		"connect":
			result = _transform_connect(word, parameters)
		"disconnect":
			result = _transform_disconnect(word, parameters)
		"activate":
			result = _transform_activate(word, parameters)
		"deactivate":
			result = _transform_deactivate(word, parameters)
		"transform":
			result = _transform_transform(word, parameters)
		"relocate":
			result = _transform_relocate(word, parameters)
		"synchronize":
			result = _transform_synchronize(word, parameters)
	
	# Record in history
	transform_history.append({
		"operation": operation,
		"word": word,
		"parameters": parameters,
		"result": result,
		"timestamp": OS.get_ticks_msec()
	})
	
	# Emit signal
	emit_signal("transform_applied", operation, word, result)
	
	# Emit power change signal if power changed
	if word_power_levels[word] != old_power:
		emit_signal("word_power_changed", word, old_power, word_power_levels[word])
	
	print("Applied transform '" + operation + "' to word '" + word + "'")
	return result

# === TRANSFORM IMPLEMENTATIONS ===

# Update transform - Update word state
func _transform_update(word, parameters):
	# Simply update the timestamp
	return {
		"word": word,
		"updated_at": OS.get_ticks_msec()
	}

# Upgrade transform - Increase word power
func _transform_upgrade(word, parameters):
	var amount = 0.25
	if parameters.has("amount"):
		amount = parameters.amount
	
	word_power_levels[word] += amount
	
	return {
		"word": word,
		"power": word_power_levels[word]
	}

# Downgrade transform - Decrease word power
func _transform_downgrade(word, parameters):
	var amount = 0.25
	if parameters.has("amount"):
		amount = parameters.amount
	
	word_power_levels[word] -= amount
	
	# Ensure power doesn't go below 0.1
	word_power_levels[word] = max(word_power_levels[word], 0.1)
	
	return {
		"word": word,
		"power": word_power_levels[word]
	}

# Merge transform - Combine words
func _transform_merge(word, parameters):
	var target_word = ""
	if parameters.has("target_word"):
		target_word = parameters.target_word
	else:
		# Generate a simple target
		target_word = "merged_" + word
	
	# Combine powers
	var target_power = word_power_levels[word]
	if word_power_levels.has(target_word):
		target_power += word_power_levels[target_word]
	
	word_power_levels[target_word] = target_power
	
	return {
		"word": target_word,
		"power": target_power,
		"source_words": [word, target_word]
	}

# Split transform - Split word into components
func _transform_split(word, parameters):
	var num_parts = 2
	if parameters.has("parts"):
		num_parts = parameters.parts
	
	var parts = []
	var part_power = word_power_levels[word] / num_parts
	
	for i in range(num_parts):
		var part_word = word + "_part" + str(i + 1)
		word_power_levels[part_word] = part_power
		parts.append(part_word)
	
	return {
		"word": word,
		"parts": parts,
		"part_power": part_power
	}

# Evolve transform - Evolve word to next form
func _transform_evolve(word, parameters):
	var evolved_word = word + "_evolved"
	if parameters.has("evolved_word"):
		evolved_word = parameters.evolved_word
	
	# Evolved form has higher power
	word_power_levels[evolved_word] = word_power_levels[word] * 1.5
	
	return {
		"word": evolved_word,
		"power": word_power_levels[evolved_word],
		"source_word": word
	}

# Devolve transform - Devolve word to previous form
func _transform_devolve(word, parameters):
	var devolved_word = word.replace("_evolved", "")
	if parameters.has("devolved_word"):
		devolved_word = parameters.devolved_word
	
	# Devolved form has lower power
	word_power_levels[devolved_word] = word_power_levels[word] * 0.7
	
	return {
		"word": devolved_word,
		"power": word_power_levels[devolved_word],
		"source_word": word
	}

# Connect transform - Connect word to another
func _transform_connect(word, parameters):
	var target_word = ""
	if parameters.has("target_word"):
		target_word = parameters.target_word
	else:
		# Generate a simple target
		target_word = "connected_" + word
	
	# Create a trajectory between the words
	word_trajectories[word + "_to_" + target_word] = {
		"source": word,
		"target": target_word,
		"created_at": OS.get_ticks_msec()
	}
	
	return {
		"source_word": word,
		"target_word": target_word,
		"trajectory_id": word + "_to_" + target_word
	}

# Disconnect transform - Disconnect word from another
func _transform_disconnect(word, parameters):
	var target_word = ""
	if parameters.has("target_word"):
		target_word = parameters.target_word
	else:
		# Find any trajectory with this word
		var trajectory_id = ""
		for id in word_trajectories:
			if word_trajectories[id].source == word or word_trajectories[id].target == word:
				trajectory_id = id
				target_word = word_trajectories[id].source if word_trajectories[id].source != word else word_trajectories[id].target
				break
	
	if target_word != "":
		var trajectory_id = word + "_to_" + target_word
		if word_trajectories.has(trajectory_id):
			word_trajectories.erase(trajectory_id)
		else:
			trajectory_id = target_word + "_to_" + word
			if word_trajectories.has(trajectory_id):
				word_trajectories.erase(trajectory_id)
		
		return {
			"source_word": word,
			"target_word": target_word,
			"disconnected": true
		}
	
	return {
		"source_word": word,
		"disconnected": false,
		"reason": "No connection found"
	}

# Activate transform - Activate word effect
func _transform_activate(word, parameters):
	# Boost power temporarily
	var old_power = word_power_levels[word]
	word_power_levels[word] *= 2.0
	
	return {
		"word": word,
		"activated": true,
		"old_power": old_power,
		"new_power": word_power_levels[word]
	}

# Deactivate transform - Deactivate word effect
func _transform_deactivate(word, parameters):
	# Reduce power temporarily
	var old_power = word_power_levels[word]
	word_power_levels[word] *= 0.5
	
	return {
		"word": word,
		"deactivated": true,
		"old_power": old_power,
		"new_power": word_power_levels[word]
	}

# Transform - Transform word shape
func _transform_transform(word, parameters):
	var shape_type = 0
	if parameters.has("shape_type"):
		shape_type = parameters.shape_type
	
	return {
		"word": word,
		"shape_type": shape_type,
		"transformed": true
	}

# Relocate transform - Move word to new location
func _transform_relocate(word, parameters):
	var project = ""
	if parameters.has("project"):
		project = parameters.project
	else:
		# Select random project
		var projects = project_centers.keys()
		if projects.size() > 0:
			project = projects[randi() % projects.size()]
	
	if project != "" and project_centers.has(project):
		return {
			"word": word,
			"project": project,
			"coordinates": project_centers[project]
		}
	
	return {
		"word": word,
		"relocated": false,
		"reason": "No valid project found"
	}

# Synchronize transform - Synchronize word with project
func _transform_synchronize(word, parameters):
	var project = ""
	if parameters.has("project"):
		project = parameters.project
	else:
		# Select random project
		var projects = project_centers.keys()
		if projects.size() > 0:
			project = projects[randi() % projects.size()]
	
	if project != "":
		return {
			"word": word,
			"project": project,
			"synchronized": true
		}
	
	return {
		"word": word,
		"synchronized": false,
		"reason": "No valid project found"
	}

# === PROCESSING ===

# Process cooldowns
func _process(delta):
	# Process operation cooldowns
	for op in operation_cooldowns.keys():
		if operation_cooldowns[op] > 0:
			operation_cooldowns[op] -= delta

# === UTILITY METHODS ===

# Get word power
func get_word_power(word):
	if word_power_levels.has(word):
		return word_power_levels[word]
	return 0.0

# Get project center
func get_project_center(project):
	if project_centers.has(project):
		return project_centers[project]
	return Vector3(0, 0, 0)

# Get transform history
func get_transform_history():
	return transform_history

# Get trajectories
func get_trajectories():
	return word_trajectories