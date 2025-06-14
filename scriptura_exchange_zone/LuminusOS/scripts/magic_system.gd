extends Node

class_name MagicSystem

# Multi-dimensional Magic System for LuminusOS
# Inspired by TempleOS's divine random number generator
# but expanded into a full magical system with multiple dimensions

signal spell_discovered(spell_name, dimension)
signal spell_cast(spell_name, result)
signal dimensional_shift(from_dimension, to_dimension)
signal mana_updated(current_mana, max_mana)

# Magic system structure
var dimensions = {
	"physical": {
		"name": "Physical Realm",
		"description": "The dimension of matter and energy",
		"color": Color(0.1, 0.5, 0.9),
		"spells": {},
		"affinity": 1.0,
		"connected_to": ["ethereal", "temporal"]
	},
	"ethereal": {
		"name": "Ethereal Realm",
		"description": "The dimension of spirit and consciousness",
		"color": Color(0.9, 0.5, 0.9),
		"spells": {},
		"affinity": 1.0,
		"connected_to": ["physical", "divine"]
	},
	"temporal": {
		"name": "Temporal Realm",
		"description": "The dimension of time and causality",
		"color": Color(0.2, 0.8, 0.2),
		"spells": {},
		"affinity": 1.0,
		"connected_to": ["physical", "void"]
	},
	"divine": {
		"name": "Divine Realm",
		"description": "The dimension of higher purpose and transcendence",
		"color": Color(1.0, 0.9, 0.1),
		"spells": {},
		"affinity": 1.0,
		"connected_to": ["ethereal", "void"]
	},
	"void": {
		"name": "Void Realm",
		"description": "The dimension between dimensions, of chaos and potential",
		"color": Color(0.1, 0.1, 0.3),
		"spells": {},
		"affinity": 1.0,
		"connected_to": ["temporal", "divine"]
	}
}

# Current state
var current_dimension = "physical"
var mana = 100.0
var max_mana = 100.0
var mana_regen_rate = 1.0
var dimensional_stability = 1.0

# Spell components
var spell_prefixes = ["ar", "bal", "cir", "dor", "eth", "fal", "gal", "hir", "in", "jal", 
					"kal", "lor", "mir", "nir", "om", "pyr", "qar", "ral", "sul", "tir"]
var spell_suffixes = ["ax", "eth", "im", "or", "us", "yr", "az", "en", "is", "um", 
					"ar", "el", "il", "on", "ux", "ys", "an", "er", "ix", "un"]
var spell_effects = {
	"physical": ["create", "destroy", "transform", "move", "bind", "release"],
	"ethereal": ["inspire", "dream", "connect", "perceive", "awaken", "transcend"],
	"temporal": ["accelerate", "slow", "reverse", "split", "merge", "loop"],
	"divine": ["bless", "purify", "judge", "reveal", "conceal", "transcend"],
	"void": ["nullify", "absorb", "contain", "release", "balance", "corrupt"]
}

# Spell targets
var spell_targets = {
	"physical": ["element", "matter", "energy", "object", "creature", "self"],
	"ethereal": ["mind", "spirit", "emotion", "memory", "dream", "soul"],
	"temporal": ["moment", "timeline", "history", "future", "age", "cycle"],
	"divine": ["faith", "destiny", "creation", "harmony", "purpose", "truth"],
	"void": ["chaos", "order", "dimension", "reality", "existence", "nothing"]
}

# Automation with tick system
var auto_tick_enabled = false
var tick_interval = 1.0
var tick_timer = 0.0

# Statistics
var stats = {
	"spells_discovered": 0,
	"spells_cast": 0,
	"dimensions_visited": {},
	"mana_spent": 0
}

func _ready():
	# Initialize the magic system
	initialize_dimensions()
	reset_stats()
	
func _process(delta):
	if auto_tick_enabled:
		tick_timer += delta
		if tick_timer >= tick_interval:
			tick_timer = 0
			process_tick()
	
	# Natural mana regeneration
	regenerate_mana(delta * mana_regen_rate)

# Process a single tick for the magic system
func process_tick():
	# Dimensional stability fluctuations
	if randf() < 0.05:  # 5% chance per tick
		dimensional_stability = clamp(dimensional_stability + randf_range(-0.1, 0.1), 0.5, 1.5)
	
	# Random chance to discover spell
	if randf() < 0.03:  # 3% chance per tick
		discover_random_spell()
	
	# Random chance of dimensional anomaly
	if randf() < 0.01 * (1.0 - dimensional_stability):  # More likely when unstable
		trigger_dimensional_anomaly()

# Initialize the dimensions with starter spells
func initialize_dimensions():
	# Add some starter spells to each dimension
	for dimension in dimensions:
		dimensions[dimension]["spells"] = {}
		var spells_count = randi() % 3 + 2  # 2-4 starter spells
		
		for i in range(spells_count):
			generate_spell(dimension)
		
		# Mark dimension as visited in stats
		stats["dimensions_visited"][dimension] = 1

# Reset statistics tracking
func reset_stats():
	stats["spells_discovered"] = 0
	stats["spells_cast"] = 0
	stats["mana_spent"] = 0
	for dimension in dimensions:
		stats["dimensions_visited"][dimension] = 0

# Generate a random spell for a specific dimension
func generate_spell(dimension):
	if not dimensions.has(dimension):
		return null
	
	# Create spell name
	var prefix = spell_prefixes[randi() % spell_prefixes.size()]
	var suffix = spell_suffixes[randi() % spell_suffixes.size()]
	var spell_name = prefix + suffix
	
	# Check if spell name already exists
	if dimensions[dimension]["spells"].has(spell_name):
		return null
	
	# Select effect and target
	var effect = "unknown"
	var target = "unknown"
	
	if spell_effects.has(dimension):
		effect = spell_effects[dimension][randi() % spell_effects[dimension].size()]
	
	if spell_targets.has(dimension):
		target = spell_targets[dimension][randi() % spell_targets[dimension].size()]
	
	# Calculate spell properties
	var power = randf_range(10.0, 30.0)
	var mana_cost = power * randf_range(0.8, 1.2)
	var stability_effect = randf_range(-0.1, 0.1)
	var is_dimensional = randf() < 0.2  # 20% chance to be a dimensional spell
	
	# Create spell data
	var spell = {
		"name": spell_name,
		"dimension": dimension,
		"effect": effect,
		"target": target,
		"description": generate_spell_description(effect, target),
		"power": power,
		"mana_cost": mana_cost,
		"stability_effect": stability_effect,
		"is_dimensional": is_dimensional,
		"discovered": true
	}
	
	# Add to dimension's spell list
	dimensions[dimension]["spells"][spell_name] = spell
	stats["spells_discovered"] += 1
	
	emit_signal("spell_discovered", spell_name, dimension)
	return spell_name

# Generate a random spell
func discover_random_spell():
	return generate_spell(current_dimension)

# Generate a description for a spell based on its effect and target
func generate_spell_description(effect, target):
	var descriptions = [
		"Channels " + effect + " energy through the " + target,
		"Binds the " + target + " with " + effect + " magic",
		"Invokes the power of " + effect + " upon the " + target,
		"Transforms the " + target + " through " + effect + " energy",
		"Aligns " + effect + " forces with the " + target,
		"Manifests " + effect + " power within the " + target
	]
	
	return descriptions[randi() % descriptions.size()]

# Change current dimension
func shift_dimension(target_dimension):
	if not dimensions.has(target_dimension):
		return false
	
	# Check if dimensions are connected
	if not target_dimension in dimensions[current_dimension]["connected_to"]:
		return false
	
	# Cost to shift dimensions
	var shift_cost = 20.0 * (1.0 / dimensional_stability)
	
	if mana < shift_cost:
		return false
	
	spend_mana(shift_cost)
	
	var previous_dimension = current_dimension
	current_dimension = target_dimension
	
	# Update stats
	if not stats["dimensions_visited"].has(target_dimension):
		stats["dimensions_visited"][target_dimension] = 0
	stats["dimensions_visited"][target_dimension] += 1
	
	# Dimension change affects stability
	dimensional_stability = clamp(dimensional_stability - 0.1, 0.5, 1.5)
	
	emit_signal("dimensional_shift", previous_dimension, target_dimension)
	return true

# Cast a spell
func cast_spell(spell_name):
	# Check if spell exists in current dimension
	if not dimensions[current_dimension]["spells"].has(spell_name):
		return {"success": false, "message": "Spell not found in current dimension"}
	
	var spell = dimensions[current_dimension]["spells"][spell_name]
	
	# Check mana cost
	if mana < spell["mana_cost"]:
		return {"success": false, "message": "Not enough mana"}
	
	# Spend mana
	spend_mana(spell["mana_cost"])
	
	# Apply stability effect
	dimensional_stability = clamp(dimensional_stability + spell["stability_effect"], 0.5, 1.5)
	
	# Determine spell result
	var success_chance = dimensions[current_dimension]["affinity"] * dimensional_stability
	var spell_success = randf() < success_chance
	
	var result = {
		"success": spell_success,
		"power": spell["power"] * (spell_success ? 1.0 : 0.3),
		"effect": spell["effect"],
		"target": spell["target"]
	}
	
	# Handle dimensional spell effects
	if spell["is_dimensional"] and spell_success:
		result["dimensional_effect"] = process_dimensional_spell(spell)
	
	# Update stats
	stats["spells_cast"] += 1
	
	emit_signal("spell_cast", spell_name, result)
	return result

# Process special effects for dimensional spells
func process_dimensional_spell(spell):
	var effects = [
		"dimensional_echo", "reality_shift", "planar_connection",
		"cosmic_alignment", "void_resonance", "ethereal_link"
	]
	
	var effect = effects[randi() % effects.size()]
	
	match effect:
		"dimensional_echo":
			# Improved affinity with this dimension
			dimensions[current_dimension]["affinity"] += 0.1
			return "Your connection to the " + dimensions[current_dimension]["name"] + " has strengthened"
			
		"reality_shift":
			# Potential to reveal new spells
			var new_spell = generate_spell(current_dimension)
			if new_spell:
				return "The shift in reality revealed a new spell: " + new_spell
			return "Reality shifted, but no new knowledge was gained"
			
		"planar_connection":
			# Connect to a previously unconnected dimension
			var unconnected = []
			for dim in dimensions:
				if dim != current_dimension and not dim in dimensions[current_dimension]["connected_to"]:
					unconnected.append(dim)
			
			if unconnected.size() > 0:
				var new_connection = unconnected[randi() % unconnected.size()]
				dimensions[current_dimension]["connected_to"].append(new_connection)
				dimensions[new_connection]["connected_to"].append(current_dimension)
				return "A new connection has formed between " + dimensions[current_dimension]["name"] + " and " + dimensions[new_connection]["name"]
			return "The planar energies swirl but find no new connections to form"
			
		"cosmic_alignment":
			# Temporary boost to stability
			dimensional_stability = clamp(dimensional_stability + 0.2, 0.5, 1.5)
			return "The dimensions align, bringing greater stability to your magic"
			
		"void_resonance":
			# Chance to gain mana
			var mana_gain = 20.0 + randf() * 20.0
			regenerate_mana(mana_gain)
			return "Void energies resonate, restoring " + str(int(mana_gain)) + " mana"
			
		"ethereal_link":
			# Copy a random spell from another dimension
			var source_dims = []
			for dim in dimensions:
				if dim != current_dimension:
					source_dims.append(dim)
					
			if source_dims.size() > 0:
				var source_dim = source_dims[randi() % source_dims.size()]
				var source_spells = dimensions[source_dim]["spells"].keys()
				
				if source_spells.size() > 0:
					var spell_to_copy = source_spells[randi() % source_spells.size()]
					var copied_spell = dimensions[source_dim]["spells"][spell_to_copy].duplicate()
					copied_spell["dimension"] = current_dimension
					
					dimensions[current_dimension]["spells"][copied_spell["name"]] = copied_spell
					return "You've formed an ethereal link with " + dimensions[source_dim]["name"] + ", gaining the spell: " + copied_spell["name"]
			
			return "The ethereal link fails to connect to another dimension"
	
	return "The dimensional energies dissipate without effect"

# Trigger a random dimensional anomaly
func trigger_dimensional_anomaly():
	var anomalies = [
		"mana_surge", "mana_drain", "dimensional_instability", 
		"spell_mutation", "dimensional_bleed", "reality_echo"
	]
	
	var anomaly = anomalies[randi() % anomalies.size()]
	var result = ""
	
	match anomaly:
		"mana_surge":
			var surge_amount = max_mana * randf_range(0.2, 0.5)
			regenerate_mana(surge_amount)
			result = "A mana surge flows through you, restoring " + str(int(surge_amount)) + " mana"
			
		"mana_drain":
			var drain_amount = mana * randf_range(0.1, 0.3)
			spend_mana(drain_amount)
			result = "Dimensional energies drain " + str(int(drain_amount)) + " mana from you"
			
		"dimensional_instability":
			dimensional_stability = clamp(dimensional_stability - 0.2, 0.5, 1.5)
			result = "The boundaries between dimensions weaken"
			
		"spell_mutation":
			# Randomly mutate a spell in current dimension
			var spell_keys = dimensions[current_dimension]["spells"].keys()
			if spell_keys.size() > 0:
				var spell_to_mutate = spell_keys[randi() % spell_keys.size()]
				var spell = dimensions[current_dimension]["spells"][spell_to_mutate]
				
				# Mutate spell properties
				spell["power"] = spell["power"] * randf_range(0.8, 1.5)
				spell["mana_cost"] = spell["power"] * randf_range(0.8, 1.2)
				spell["stability_effect"] = randf_range(-0.15, 0.15)
				
				dimensions[current_dimension]["spells"][spell_to_mutate] = spell
				result = "The spell " + spell_to_mutate + " has mutated in the dimensional flux"
			else:
				result = "Dimensional energies swirl but find no spells to affect"
				
		"dimensional_bleed":
			# Random chance to be pulled to another dimension
			var connected_dims = dimensions[current_dimension]["connected_to"]
			if connected_dims.size() > 0:
				var random_dim = connected_dims[randi() % connected_dims.size()]
				if randf() < 0.5:  # 50% chance
					var old_dim = current_dimension
					current_dimension = random_dim
					result = "You are pulled through a dimensional bleed into the " + dimensions[random_dim]["name"]
					emit_signal("dimensional_shift", old_dim, random_dim)
				else:
					result = "A dimensional bleed opens briefly but you resist being pulled through"
			else:
				result = "Dimensional energies ripple but find no connection to pull you through"
				
		"reality_echo":
			# Chance to duplicate a random spell
			var spell_keys = dimensions[current_dimension]["spells"].keys()
			if spell_keys.size() > 0:
				var spell_to_copy = spell_keys[randi() % spell_keys.size()]
				var spell = dimensions[current_dimension]["spells"][spell_to_copy]
				
				// Generate a new name for the echo
				var prefix = spell_prefixes[randi() % spell_prefixes.size()]
				var suffix = spell_suffixes[randi() % spell_suffixes.size()]
				var echo_name = prefix + suffix
				
				// Only create if the name doesn't already exist
				if not dimensions[current_dimension]["spells"].has(echo_name):
					var echo_spell = spell.duplicate()
					echo_spell["name"] = echo_name
					echo_spell["description"] = "An echo of " + spell_to_copy + ": " + echo_spell["description"]
					
					dimensions[current_dimension]["spells"][echo_name] = echo_spell
					result = "A reality echo creates a duplicate of " + spell_to_copy + ": " + echo_name
				else:
					result = "A reality echo appears but dissipates without effect"
			else:
				result = "A reality echo appears but finds no spell to duplicate"
	
	return result

# Spend mana
func spend_mana(amount):
	var actual_amount = min(amount, mana)
	mana -= actual_amount
	stats["mana_spent"] += actual_amount
	emit_signal("mana_updated", mana, max_mana)
	return actual_amount

# Regenerate mana
func regenerate_mana(amount):
	mana = min(mana + amount, max_mana)
	emit_signal("mana_updated", mana, max_mana)
	return mana

# API for LuminusOS terminal

func cmd_magic(args):
	if args.size() == 0:
		return "Usage: magic <command> [parameters]"
	
	match args[0]:
		"status":
			return get_magic_status()
			
		"dimension":
			if args.size() < 2:
				return "Current dimension: " + dimensions[current_dimension]["name"]
			
			var dim = args[1]
			if dimensions.has(dim):
				if shift_dimension(dim):
					return "Shifted to " + dimensions[dim]["name"]
				else:
					return "Unable to shift to " + dim + ". Check mana or connections."
			else:
				return "Unknown dimension: " + dim + ". Available dimensions: " + ", ".join(dimensions.keys())
				
		"list":
			if args.size() >= 2 and args[1] == "dimensions":
				return list_dimensions()
			else:
				return list_spells()
				
		"cast":
			if args.size() < 2:
				return "Usage: magic cast <spell_name>"
			
			var spell_name = args[1]
			var result = cast_spell(spell_name)
			
			if result["success"]:
				var message = "Successfully cast " + spell_name + "!\n"
				message += "Effect: " + result["effect"] + " " + result["target"] + " with power " + str(int(result["power"]))
				
				if result.has("dimensional_effect"):
					message += "\n" + result["dimensional_effect"]
				
				return message
			else:
				return "Failed to cast " + spell_name + ": " + result["message"]
				
		"discover":
			var spell_name = discover_random_spell()
			if spell_name:
				return "Discovered new spell: " + spell_name
			else:
				return "Failed to discover a new spell"
				
		"info":
			if args.size() < 2:
				return "Usage: magic info <spell_name>"
			
			var spell_name = args[1]
			return get_spell_info(spell_name)
			
		"mana":
			if args.size() >= 2 and args[1] == "restore":
				var amount = 50.0
				if args.size() >= 3 and args[2].is_valid_float():
					amount = float(args[2])
				
				regenerate_mana(amount)
				return "Restored " + str(int(amount)) + " mana. Current: " + str(int(mana)) + "/" + str(int(max_mana))
			else:
				return "Mana: " + str(int(mana)) + "/" + str(int(max_mana))
				
		"stability":
			return "Dimensional stability: " + str(int(dimensional_stability * 100)) + "%"
			
		"create":
			if args.size() < 2:
				return "Usage: magic create <spell_name> [dimension]"
			
			var spell_name = args[1]
			var dimension_name = current_dimension
			
			if args.size() >= 3 and dimensions.has(args[2]):
				dimension_name = args[2]
			
			// Check if spell exists
			if dimensions[dimension_name]["spells"].has(spell_name):
				return "Spell already exists in " + dimension_name
			
			// Create custom spell
			var effect = spell_effects[dimension_name][randi() % spell_effects[dimension_name].size()]
			var target = spell_targets[dimension_name][randi() % spell_targets[dimension_name].size()]
			
			if args.size() >= 4 and args[3] in spell_effects[dimension_name]:
				effect = args[3]
			
			if args.size() >= 5 and args[4] in spell_targets[dimension_name]:
				target = args[4]
			
			// Calculate spell properties
			var power = 20.0
			var mana_cost = power
			var stability_effect = 0.0
			var is_dimensional = false
			
			if args.size() >= 6 and args[5].is_valid_float():
				power = float(args[5])
				mana_cost = power
			
			if args.size() >= 7 and args[6] == "dimensional":
				is_dimensional = true
			
			// Create spell data
			var spell = {
				"name": spell_name,
				"dimension": dimension_name,
				"effect": effect,
				"target": target,
				"description": generate_spell_description(effect, target),
				"power": power,
				"mana_cost": mana_cost,
				"stability_effect": stability_effect,
				"is_dimensional": is_dimensional,
				"discovered": true
			}
			
			// Add to dimension's spell list
			dimensions[dimension_name]["spells"][spell_name] = spell
			stats["spells_discovered"] += 1
			
			emit_signal("spell_discovered", spell_name, dimension_name)
			return "Created spell: " + spell_name + " in " + dimensions[dimension_name]["name"]
			
		"anomaly":
			var result = trigger_dimensional_anomaly()
			return "Dimensional anomaly: " + result
			
		"stats":
			return get_magic_stats()
			
		_:
			return "Unknown magic command. Try 'status', 'dimension', 'list', 'cast', 'discover', 'info', 'mana', 'stability', 'create', or 'stats'"

func cmd_tick(args):
	if args.size() == 0:
		return "Auto-tick: " + ("Enabled" if auto_tick_enabled else "Disabled") + ", Interval: " + str(tick_interval) + "s"
	
	match args[0]:
		"on":
			auto_tick_enabled = true
			return "Auto-tick enabled"
			
		"off":
			auto_tick_enabled = false
			return "Auto-tick disabled"
			
		"interval":
			if args.size() < 2:
				return "Current tick interval: " + str(tick_interval) + "s"
			if args[1].is_valid_float():
				var new_interval = float(args[1])
				if new_interval > 0.1:
					tick_interval = new_interval
					return "Tick interval set to " + str(tick_interval) + "s"
				else:
					return "Tick interval must be at least 0.1s"
			return "Invalid tick interval"
			
		"once":
			process_tick()
			return "Manual tick processed"
			
		_:
			return "Unknown tick command. Try 'on', 'off', 'interval', or 'once'"

# Helper functions for formatting output

func get_magic_status():
	var status = "Magic System Status:\n"
	status += "Current dimension: " + dimensions[current_dimension]["name"] + "\n"
	status += "Mana: " + str(int(mana)) + "/" + str(int(max_mana)) + "\n"
	status += "Dimensional stability: " + str(int(dimensional_stability * 100)) + "%\n"
	status += "Available spells: " + str(dimensions[current_dimension]["spells"].size()) + "\n"
	status += "Connected dimensions: " + ", ".join(dimensions[current_dimension]["connected_to"]) + "\n"
	return status

func list_dimensions():
	var list = "Dimensions:\n"
	
	for dim_name in dimensions:
		list += dim_name + ": " + dimensions[dim_name]["name"]
		if dim_name == current_dimension:
			list += " (current)"
		list += "\n  Description: " + dimensions[dim_name]["description"]
		list += "\n  Spells: " + str(dimensions[dim_name]["spells"].size())
		list += "\n  Connected to: " + ", ".join(dimensions[dim_name]["connected_to"])
		list += "\n\n"
	
	return list

func list_spells():
	var list = "Spells in " + dimensions[current_dimension]["name"] + ":\n"
	var spells = dimensions[current_dimension]["spells"]
	
	if spells.size() == 0:
		return "No spells available in current dimension"
	
	for spell_name in spells:
		var spell = spells[spell_name]
		list += spell_name + " - " + spell["effect"] + " " + spell["target"]
		if spell["is_dimensional"]:
			list += " (dimensional)"
		list += " - " + str(int(spell["mana_cost"])) + " mana\n"
	
	return list

func get_spell_info(spell_name):
	if not dimensions[current_dimension]["spells"].has(spell_name):
		return "Spell not found in current dimension: " + spell_name
	
	var spell = dimensions[current_dimension]["spells"][spell_name]
	var info = "Spell: " + spell_name + "\n"
	info += "Dimension: " + dimensions[spell["dimension"]]["name"] + "\n"
	info += "Effect: " + spell["effect"] + " " + spell["target"] + "\n"
	info += "Description: " + spell["description"] + "\n"
	info += "Power: " + str(int(spell["power"])) + "\n"
	info += "Mana cost: " + str(int(spell["mana_cost"])) + "\n"
	
	if spell["is_dimensional"]:
		info += "Type: Dimensional spell\n"
	else:
		info += "Type: Regular spell\n"
	
	return info

func get_magic_stats():
	var stats_str = "Magic System Statistics:\n"
	stats_str += "Spells discovered: " + str(stats["spells_discovered"]) + "\n"
	stats_str += "Spells cast: " + str(stats["spells_cast"]) + "\n"
	stats_str += "Total mana spent: " + str(int(stats["mana_spent"])) + "\n"
	
	stats_str += "Dimensions visited:\n"
	for dimension in stats["dimensions_visited"]:
		if stats["dimensions_visited"][dimension] > 0:
			stats_str += "  " + dimensions[dimension]["name"] + ": " + str(stats["dimensions_visited"][dimension]) + " times\n"
	
	return stats_str