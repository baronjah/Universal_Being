extends Node

# Magic command system for LuminusOS
# Handles special word commands and incantations

class_name MagicCommands

signal spell_activated(spell_name, power_level)
signal dimension_changed(dimension_name)

var active_spells = {}
var spell_power_levels = {}
var current_dimension = "primary"
var sudo_enabled = false
var sudo_password = "diablica"

# Word-spell dictionary
var word_spells = {
	"exti": {
		"description": "A powerful healing force",
		"effect": "healing",
		"power": 7
	},
	"vaeli": {
		"description": "Going before zero point to improve a situation",
		"effect": "time_manipulation",
		"power": 9
	},
	"lemi": {
		"description": "The feeling of everyone else having it worse",
		"effect": "perception_shift",
		"power": 6
	},
	"pelo": {
		"description": "Balance between opposing forces",
		"effect": "balance",
		"power": 8
	},
	"zenime": {
		"description": "Pause time and create mental space",
		"effect": "time_pause",
		"power": 8
	},
	"perfefic": {
		"description": "Perfect energy for every fantasy created",
		"effect": "creation_boost",
		"power": 9
	},
	"shune": {
		"description": "Silence and restraint of responses",
		"effect": "silence",
		"power": 5
	},
	"cade": {
		"description": "Combination of energy, ego, and personality",
		"effect": "unification",
		"power": 8
	}
}

# Initialize the magic command system
func _ready():
	print("Magic command system initialized")

# Process word spells
func process_spell(word):
	word = word.to_lower().strip_edges()
	
	if word_spells.has(word):
		var spell = word_spells[word]
		active_spells[word] = true
		spell_power_levels[word] = spell["power"]
		
		emit_signal("spell_activated", word, spell["power"])
		
		return "Spell '%s' activated: %s (Power: %d)" % [word, spell["description"], spell["power"]]
	else:
		return "Unknown spell word: " + word

# Check if a specific spell is active
func is_spell_active(spell_name):
	return active_spells.has(spell_name) and active_spells[spell_name]

# Process a combination of spells
func process_spell_combination(spells):
	var spell_list = spells.split(" ", false)
	var total_power = 0
	var active_count = 0
	
	for spell in spell_list:
		if word_spells.has(spell):
			total_power += word_spells[spell]["power"]
			active_count += 1
			active_spells[spell] = true
			spell_power_levels[spell] = word_spells[spell]["power"]
	
	if active_count == 0:
		return "No valid spells in combination"
	
	var combined_power = total_power * (1 + (active_count * 0.2))
	
	return "Spell combination activated (%d spells). Combined power: %.1f" % [active_count, combined_power]

# Change dimension
func change_dimension(dimension):
	var old_dimension = current_dimension
	current_dimension = dimension
	emit_signal("dimension_changed", dimension)
	
	return "Dimension shifted: %s → %s" % [old_dimension, current_dimension]

# Process sudo commands
func process_sudo_command(password, command):
	if password == sudo_password:
		sudo_enabled = true
		return "Sudo access granted. Processing: " + command
	else:
		return "Incorrect sudo password. Access denied."

# Get all available spells
func get_available_spells():
	var spell_list = "Available spells:\n"
	
	for spell_name in word_spells:
		var spell = word_spells[spell_name]
		var status = "inactive"
		
		if active_spells.has(spell_name) and active_spells[spell_name]:
			status = "ACTIVE"
			
		spell_list += "- %s: %s (Power: %d) [%s]\n" % [spell_name, spell["description"], spell["power"], status]
		
	return spell_list

# Create a new spell
func create_spell(name, description, effect, power):
	if word_spells.has(name):
		return "Spell already exists: " + name
		
	word_spells[name] = {
		"description": description,
		"effect": effect,
		"power": power
	}
	
	return "New spell created: " + name

# Terminal command handler
func cmd_magic(args):
	if args.size() == 0:
		return get_available_spells()
	
	match args[0]:
		"cast":
			if args.size() < 2:
				return "Usage: magic cast <spell_name>"
			return process_spell(args[1])
			
		"combine":
			if args.size() < 2:
				return "Usage: magic combine <spell1> [spell2] [spell3]..."
			return process_spell_combination(" ".join(args.slice(1)))
			
		"dimension":
			if args.size() < 2:
				return "Current dimension: " + current_dimension
			return change_dimension(args[1])
			
		"create":
			if args.size() < 5:
				return "Usage: magic create <name> <description> <effect> <power:1-10>"
			
			var power = 5
			if args[4].is_valid_int():
				power = int(args[4])
				power = clamp(power, 1, 10)
				
			return create_spell(args[1], args[2], args[3], power)
			
		"list":
			return get_available_spells()
			
		"clear":
			active_spells.clear()
			spell_power_levels.clear()
			return "All active spells cleared"
			
		_:
			return "Unknown magic command. Try 'cast', 'combine', 'dimension', 'create', 'list', or 'clear'"

# Handle sudo access
func cmd_sudo(args):
	if args.size() < 2:
		return "Usage: sudo <password> <command>"
		
	return process_sudo_command(args[0], " ".join(args.slice(1)))