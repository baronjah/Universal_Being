extends Node

class_name CommandSelfCheck

# Self-checking system for console commands
# Monitors command usage, checks validity, and provides suggestions

signal anomaly_detected(command, reason)
signal suggestion_created(command, suggestion)

var valid_commands = []
var command_history = []
var command_frequency = {}
var command_success_rate = {}
var suggestion_threshold = 3 # Number of failed attempts before suggesting
var enabled = true

# Command patterns to check against
var command_patterns = {
	"cores": "^cores( count [0-9]+| status| reset)?$",
	"task": "^task( add [a-z]+ [a-z]+ [a-z0-9 ]+| list| clear)?$",
	"memory": "^memory( list| get [a-z0-9_]+| set [a-z0-9_]+ [a-z0-9_]+| lock [a-z0-9_]+| unlock [a-z0-9_]+| clear)?$",
	"sudo": "^sudo [a-z0-9]+ [a-z0-9 ]+$",
	"magic": "^magic( cast [a-z]+| combine [a-z ]+| dimension [a-z0-9_]+| create [a-z]+ .+| list| clear)?$",
	"create_game": "^create_game [a-z0-9_]+ [a-z]+$",
	"spell": "^spell [a-z]+$"
}

func _ready():
	# Initialize with basic commands
	valid_commands = [
		"help", "clear", "cores", "task", "memory", "magic", 
		"word", "story", "sudo", "self_check", "create_game",
		"api", "reading_speed", "device", "spell", "godot",
		"game", "sh", "ascii", "exit"
	]
	
	# Add spell words as valid commands
	valid_commands.append_array([
		"exti", "vaeli", "lemi", "pelo", "zenime", 
		"perfefic", "shune", "cade"
	])
	
	print("Command self-check system initialized")

# Record a command and check its validity
func record_command(command_text):
	if not enabled:
		return true
		
	var parts = command_text.strip_edges().split(" ", false)
	var cmd = parts[0].to_lower()
	
	# Record in history
	command_history.append(command_text)
	
	# Update frequency
	if command_frequency.has(cmd):
		command_frequency[cmd] += 1
	else:
		command_frequency[cmd] = 1
	
	# Check if valid command
	var valid = is_valid_command(command_text)
	
	# Update success rate
	if not command_success_rate.has(cmd):
		command_success_rate[cmd] = {"success": 0, "fail": 0}
		
	if valid:
		command_success_rate[cmd]["success"] += 1
	else:
		command_success_rate[cmd]["fail"] += 1
		check_for_suggestions(command_text)
		emit_signal("anomaly_detected", command_text, "Invalid command pattern")
	
	return valid

# Check if a command is valid
func is_valid_command(command_text):
	var parts = command_text.strip_edges().split(" ", false)
	var cmd = parts[0].to_lower()
	
	# First check if base command is valid
	if not valid_commands.has(cmd):
		return false
	
	# If it's a direct spell word or simple command, it's valid
	if parts.size() == 1:
		return true
	
	# Check against pattern if available
	if command_patterns.has(cmd):
		var regex = RegEx.new()
		regex.compile(command_patterns[cmd])
		return regex.search(command_text) != null
	
	# If no pattern defined, assume valid
	return true

# Generate suggestions for failed commands
func check_for_suggestions(command_text):
	var parts = command_text.strip_edges().split(" ", false)
	var cmd = parts[0].to_lower()
	
	# If command is valid but usage is wrong
	if valid_commands.has(cmd) and command_success_rate.has(cmd):
		var fail_count = command_success_rate[cmd]["fail"]
		
		if fail_count >= suggestion_threshold:
			var suggestion = generate_suggestion(command_text)
			if suggestion != "":
				emit_signal("suggestion_created", command_text, suggestion)
	
	# If command is not recognized, suggest closest match
	if not valid_commands.has(cmd):
		var closest = find_closest_command(cmd)
		if closest != "":
			emit_signal("suggestion_created", command_text, 
				"Unknown command. Did you mean '%s'?" % closest)

# Generate a helpful suggestion for a command
func generate_suggestion(command_text):
	var parts = command_text.strip_edges().split(" ", false)
	var cmd = parts[0].to_lower()
	
	match cmd:
		"cores":
			return "Usage: cores [count <number>|status|reset]"
		"task":
			return "Usage: task [add <type> <operation> <params>|list|clear]"
		"memory":
			return "Usage: memory [list|get <address>|set <address> <value>|lock <address>|unlock <address>|clear]"
		"magic":
			return "Usage: magic [cast <spell>|combine <spells>|dimension <name>|create <name> <desc> <effect> <power>|list|clear]"
		"sudo":
			return "Usage: sudo <password> <command>"
		"create_game":
			return "Usage: create_game <game_name> [template_type]"
		"spell":
			return "Usage: spell <spell_name>"
		_:
			return ""

# Find the closest matching command
func find_closest_command(cmd):
	var min_distance = 100
	var closest = ""
	
	for valid_cmd in valid_commands:
		var distance = levenshtein_distance(cmd, valid_cmd)
		if distance < min_distance and distance <= 3:
			min_distance = distance
			closest = valid_cmd
	
	return closest

# Calculate Levenshtein distance between two strings
func levenshtein_distance(a, b):
	var m = a.length()
	var n = b.length()
	
	# Create distance matrix
	var d = []
	for i in range(m + 1):
		d.append([])
		for j in range(n + 1):
			d[i].append(0)
	
	# Initialize
	for i in range(m + 1):
		d[i][0] = i
	for j in range(n + 1):
		d[0][j] = j
	
	# Fill the matrix
	for j in range(1, n + 1):
		for i in range(1, m + 1):
			if a[i-1] == b[j-1]:
				d[i][j] = d[i-1][j-1]
			else:
				d[i][j] = min(
					d[i-1][j] + 1,   # deletion
					d[i][j-1] + 1,   # insertion
					d[i-1][j-1] + 1  # substitution
				)
	
	return d[m][n]

# Get statistics about command usage
func get_statistics():
	var stats = "Command Statistics:\n\n"
	
	stats += "Most used commands:\n"
	var sorted_cmds = command_frequency.keys()
	sorted_cmds.sort_custom(func(a, b): return command_frequency[a] > command_frequency[b])
	
	for i in range(min(5, sorted_cmds.size())):
		var cmd = sorted_cmds[i]
		stats += "- %s: %d times\n" % [cmd, command_frequency[cmd]]
	
	stats += "\nCommand success rates:\n"
	for cmd in command_success_rate:
		var total = command_success_rate[cmd]["success"] + command_success_rate[cmd]["fail"]
		var rate = 0.0
		if total > 0:
			rate = float(command_success_rate[cmd]["success"]) / float(total) * 100.0
			
		stats += "- %s: %.1f%% (%d/%d)\n" % [cmd, rate, command_success_rate[cmd]["success"], total]
	
	return stats

# Register a new valid command
func register_command(cmd, pattern=""):
	if not valid_commands.has(cmd):
		valid_commands.append(cmd)
		
	if pattern != "":
		command_patterns[cmd] = pattern
		
	return "Command registered: " + cmd

# Toggle enabled state
func toggle(enabled_state=null):
	if enabled_state != null:
		enabled = enabled_state
	else:
		enabled = !enabled
		
	return "Command self-check " + ("enabled" if enabled else "disabled")