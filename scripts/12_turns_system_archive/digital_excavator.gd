extends Node

class_name DigitalExcavator

# Digital excavation configuration
const EXCAVATION_CONFIG = {
	"modes": {
		"surface": {
			"depth": 1,
			"energy_usage": 0.2,
			"stability_impact": 0.05,
			"discovery_rate": 0.4,
			"max_duration_minutes": 60
		},
		"intermediate": {
			"depth": 3,
			"energy_usage": 0.5,
			"stability_impact": 0.15,
			"discovery_rate": 0.6,
			"max_duration_minutes": 180
		},
		"deep": {
			"depth": 5,
			"energy_usage": 0.8,
			"stability_impact": 0.3,
			"discovery_rate": 0.8,
			"max_duration_minutes": 360
		},
		"quantum": {
			"depth": 7,
			"energy_usage": 1.0,
			"stability_impact": 0.5,
			"discovery_rate": 0.9,
			"max_duration_minutes": 720
		}
	},
	"algorithms": {
		"standard_hash": {
			"complexity": "low",
			"power_efficiency": 0.7,
			"reward_factor": 0.5,
			"stability_coefficient": 0.8
		},
		"advanced_hash": {
			"complexity": "medium",
			"power_efficiency": 0.5,
			"reward_factor": 0.8,
			"stability_coefficient": 0.6
		},
		"neural_hash": {
			"complexity": "high",
			"power_efficiency": 0.3,
			"reward_factor": 1.2,
			"stability_coefficient": 0.4
		},
		"quantum_hash": {
			"complexity": "extreme",
			"power_efficiency": 0.2,
			"reward_factor": 1.8,
			"stability_coefficient": 0.2
		}
	},
	"targets": {
		"numerical": {
			"type": "standard",
			"value_multiplier": 1.0,
			"difficulty": 0.5,
			"description": "Standard numerical sequences with verification"
		},
		"cryptographic": {
			"type": "advanced",
			"value_multiplier": 1.5,
			"difficulty": 0.7,
			"description": "Cryptographic puzzles with higher complexity"
		},
		"multidimensional": {
			"type": "complex",
			"value_multiplier": 2.0,
			"difficulty": 0.8,
			"description": "Multi-layered puzzles spanning dimensional barriers"
		},
		"reality": {
			"type": "quantum",
			"value_multiplier": 3.0,
			"difficulty": 0.95,
			"description": "Reality fragments with quantum uncertainty properties"
		}
	}
}

# Digital resources configuration
const RESOURCE_CONFIG = {
	"data_fragments": {
		"rarity": "common",
		"value": 1,
		"stability": 0.9,
		"description": "Basic data units found in digital excavation"
	},
	"code_crystals": {
		"rarity": "uncommon",
		"value": 5,
		"stability": 0.8,
		"description": "Crystallized code structures with algorithmic properties"
	},
	"pattern_matrices": {
		"rarity": "rare",
		"value": 20,
		"stability": 0.7,
		"description": "Matrix structures containing complex pattern information"
	},
	"reality_shards": {
		"rarity": "very_rare",
		"value": 100,
		"stability": 0.5,
		"description": "Fragments of digital reality with transformative properties"
	},
	"quantum_keys": {
		"rarity": "legendary",
		"value": 500,
		"stability": 0.3,
		"description": "Keys to fundamental quantum states of digital existence"
	}
}

# Excavation status
var excavation_status = {
	"active": false,
	"current_mode": "surface",
	"current_algorithm": "standard_hash",
	"current_target": "numerical",
	"current_depth": 0,
	"energy_consumption": 0.0,
	"stability_level": 1.0,
	"duration_minutes": 0,
	"last_start_time": 0,
	"progress": 0.0
}

# Resource inventory
var resource_inventory = {
	"data_fragments": 0,
	"code_crystals": 0,
	"pattern_matrices": 0,
	"reality_shards": 0,
	"quantum_keys": 0,
	"total_value": 0
}

# Discovery log
var discovery_log = []

# Excavation metrics
var metrics = {
	"total_excavation_time_minutes": 0,
	"total_energy_consumed": 0.0,
	"total_discoveries": 0,
	"total_value_discovered": 0,
	"stability_incidents": 0,
	"longest_excavation_minutes": 0
}

# Reality processor integration
var reality_processor = null
var current_turn = 1

# System timer and processor
var excavation_timer = null
var update_interval_seconds = 1.0

# Signals
signal excavation_started(config)
signal excavation_stopped(results)
signal resource_discovered(resource_type, amount, value)
signal stability_changed(old_level, new_level)
signal depth_reached(depth)
signal excavation_completed(summary)
signal error_occurred(error_info)

func _ready():
	# Initialize the excavator
	initialize_excavator()
	
	# Setup timer
	setup_timer()

func initialize_excavator():
	print("Initializing Digital Excavator...")
	
	# Connect to reality processor if available
	connect_to_reality_processor()
	
	# Load current turn
	load_current_turn()
	
	# Create storage directory
	create_storage_directory()
	
	print("Digital Excavator initialized")

func setup_timer():
	excavation_timer = Timer.new()
	add_child(excavation_timer)
	excavation_timer.wait_time = update_interval_seconds
	excavation_timer.connect("timeout", self, "_on_excavation_update")
	excavation_timer.set_paused(true)

func connect_to_reality_processor():
	# Try to find Reality Processor
	if ClassDB.class_exists("RealityDataProcessor"):
		reality_processor = RealityDataProcessor.new()
		add_child(reality_processor)
		print("Connected to Reality Data Processor")

func load_current_turn():
	var file = File.new()
	var turn_file = "/mnt/c/Users/Percision 15/12_turns_system/current_turn.txt"
	
	if file.file_exists(turn_file) and file.open(turn_file, File.READ) == OK:
		var content = file.get_as_text()
		file.close()
		
		var turn = int(content)
		if turn >= 1 and turn <= 12:
			current_turn = turn
	else:
		current_turn = 1

func create_storage_directory():
	var dir = Directory.new()
	var path = "/mnt/c/Users/Percision 15/12_turns_system/excavation_data"
	
	if not dir.dir_exists(path):
		var result = dir.make_dir_recursive(path)
		if result == OK:
			print("Created excavation data directory: " + path)
		else:
			push_error("Failed to create excavation data directory")

# Public API methods

# Start digital excavation
func start_excavation(mode = "surface", algorithm = "standard_hash", target = "numerical"):
	# Validate parameters
	if not EXCAVATION_CONFIG.modes.has(mode):
		push_error("Invalid excavation mode: " + mode)
		return false
	
	if not EXCAVATION_CONFIG.algorithms.has(algorithm):
		push_error("Invalid excavation algorithm: " + algorithm)
		return false
	
	if not EXCAVATION_CONFIG.targets.has(target):
		push_error("Invalid excavation target: " + target)
		return false
	
	# Check turn requirement
	var depth = EXCAVATION_CONFIG.modes[mode].depth
	if depth > current_turn:
		push_error("Excavation depth " + str(depth) + " exceeds current turn " + str(current_turn))
		emit_signal("error_occurred", {
			"type": "depth_restriction",
			"message": "Excavation depth exceeds current turn",
			"required_turn": depth,
			"current_turn": current_turn
		})
		return false
	
	# Check if excavation is already active
	if excavation_status.active:
		push_error("Excavation already active")
		return false
	
	# Configure excavation
	excavation_status.active = true
	excavation_status.current_mode = mode
	excavation_status.current_algorithm = algorithm
	excavation_status.current_target = target
	excavation_status.current_depth = EXCAVATION_CONFIG.modes[mode].depth
	excavation_status.energy_consumption = 0.0
	excavation_status.stability_level = 1.0
	excavation_status.duration_minutes = 0
	excavation_status.last_start_time = OS.get_unix_time()
	excavation_status.progress = 0.0
	
	# Start the timer
	excavation_timer.set_paused(false)
	
	# Emit signal
	emit_signal("excavation_started", {
		"mode": mode,
		"algorithm": algorithm,
		"target": target,
		"depth": EXCAVATION_CONFIG.modes[mode].depth,
		"start_time": excavation_status.last_start_time
	})
	
	print("Digital excavation started - Mode: " + mode + ", Algorithm: " + algorithm + ", Target: " + target)
	return true

# Stop digital excavation
func stop_excavation(reason = "user"):
	# Check if excavation is active
	if not excavation_status.active:
		return false
	
	# Stop the timer
	excavation_timer.set_paused(true)
	
	# Calculate duration
	var end_time = OS.get_unix_time()
	var duration_seconds = end_time - excavation_status.last_start_time
	excavation_status.duration_minutes = duration_seconds / 60.0
	
	# Update metrics
	metrics.total_excavation_time_minutes += excavation_status.duration_minutes
	metrics.total_energy_consumed += excavation_status.energy_consumption
	metrics.longest_excavation_minutes = max(metrics.longest_excavation_minutes, excavation_status.duration_minutes)
	
	# Prepare results
	var results = {
		"mode": excavation_status.current_mode,
		"algorithm": excavation_status.current_algorithm,
		"target": excavation_status.current_target,
		"depth": excavation_status.current_depth,
		"duration_minutes": excavation_status.duration_minutes,
		"energy_consumed": excavation_status.energy_consumption,
		"final_stability": excavation_status.stability_level,
		"resources_discovered": metrics.total_discoveries,
		"total_value": metrics.total_value_discovered,
		"stop_reason": reason
	}
	
	# Mark as inactive
	excavation_status.active = false
	
	# Emit signal
	emit_signal("excavation_stopped", results)
	
	# If completed (not stopped by user/error), emit completion signal
	if reason == "completed":
		emit_signal("excavation_completed", results)
	
	print("Digital excavation stopped - Reason: " + reason + ", Duration: " + 
		str(excavation_status.duration_minutes) + " minutes")
	
	return true

# Get excavation status
func get_excavation_status():
	var current_time = OS.get_unix_time()
	var current_duration = excavation_status.active ? 
		(current_time - excavation_status.last_start_time) / 60.0 : 
		excavation_status.duration_minutes
	
	return {
		"active": excavation_status.active,
		"mode": excavation_status.current_mode,
		"algorithm": excavation_status.current_algorithm,
		"target": excavation_status.current_target,
		"depth": excavation_status.current_depth,
		"duration_minutes": current_duration,
		"energy_consumption": excavation_status.energy_consumption,
		"stability_level": excavation_status.stability_level,
		"progress": excavation_status.progress,
		"estimated_completion": excavation_status.active ? 
			_estimate_completion_time() : 0
	}

# Get resource inventory
func get_resource_inventory():
	return {
		"data_fragments": resource_inventory.data_fragments,
		"code_crystals": resource_inventory.code_crystals,
		"pattern_matrices": resource_inventory.pattern_matrices,
		"reality_shards": resource_inventory.reality_shards,
		"quantum_keys": resource_inventory.quantum_keys,
		"total_value": resource_inventory.total_value
	}

# Get excavation metrics
func get_excavation_metrics():
	return {
		"total_excavation_time_minutes": metrics.total_excavation_time_minutes,
		"total_energy_consumed": metrics.total_energy_consumed,
		"total_discoveries": metrics.total_discoveries,
		"total_value_discovered": metrics.total_value_discovered,
		"stability_incidents": metrics.stability_incidents,
		"longest_excavation_minutes": metrics.longest_excavation_minutes,
		"current_turn": current_turn,
		"max_accessible_depth": current_turn
	}

# Get discovery log
func get_discovery_log(max_entries = 10):
	var entries = []
	
	var start_index = max(0, discovery_log.size() - max_entries)
	for i in range(start_index, discovery_log.size()):
		entries.append(discovery_log[i])
	
	return entries

# Process a single discovery attempt
func process_discovery_attempt():
	# Only process if excavation is active
	if not excavation_status.active:
		return null
	
	# Get current configuration
	var mode_config = EXCAVATION_CONFIG.modes[excavation_status.current_mode]
	var algo_config = EXCAVATION_CONFIG.algorithms[excavation_status.current_algorithm]
	var target_config = EXCAVATION_CONFIG.targets[excavation_status.current_target]
	
	# Calculate discovery chance
	var base_chance = mode_config.discovery_rate * algo_config.power_efficiency
	var difficulty_factor = 1.0 - target_config.difficulty
	var stability_factor = excavation_status.stability_level
	
	var discovery_chance = base_chance * difficulty_factor * stability_factor
	
	# Determine if discovery is made
	if randf() <= discovery_chance:
		# Determine which resource is discovered
		var resource_type = _determine_resource_type(
			excavation_status.current_depth,
			target_config.type
		)
		
		# Calculate amount
		var base_amount = 1 + randi() % 3
		var amount = base_amount * target_config.value_multiplier
		
		# Calculate value
		var resource_value = RESOURCE_CONFIG[resource_type].value
		var total_value = resource_value * amount
		
		# Add to inventory
		resource_inventory[resource_type] += amount
		resource_inventory.total_value += total_value
		
		# Update metrics
		metrics.total_discoveries += 1
		metrics.total_value_discovered += total_value
		
		# Add to discovery log
		var discovery = {
			"timestamp": OS.get_unix_time(),
			"resource_type": resource_type,
			"amount": amount,
			"value": total_value,
			"depth": excavation_status.current_depth,
			"stability": excavation_status.stability_level
		}
		
		discovery_log.append(discovery)
		
		# Emit signal
		emit_signal("resource_discovered", resource_type, amount, total_value)
		
		print("Resource discovered: " + str(amount) + " " + resource_type + " (Value: " + str(total_value) + ")")
		
		return discovery
	
	return null

# Store a digital artifact
func store_digital_artifact(artifact_data):
	if not excavation_status.active:
		push_error("Excavation not active")
		return false
	
	# Use Reality Processor if available
	if reality_processor:
		var dimension = _get_dimension_for_depth(excavation_status.current_depth)
		return reality_processor.store_artifact(artifact_data, dimension)
	
	# Fallback storage
	var file_path = "/mnt/c/Users/Percision 15/12_turns_system/excavation_data/artifact_" + 
		str(OS.get_unix_time()) + ".json"
	
	var file = File.new()
	if file.open(file_path, File.WRITE) == OK:
		file.store_string(JSON.print(artifact_data, "  "))
		file.close()
		return true
	else:
		push_error("Failed to store artifact")
		return false

# Use a resource to boost excavation
func use_resource(resource_type, amount = 1):
	if not RESOURCE_CONFIG.has(resource_type):
		push_error("Invalid resource type: " + resource_type)
		return false
	
	if resource_inventory[resource_type] < amount:
		push_error("Not enough resources: " + resource_type)
		return false
	
	# Apply resource effects
	var effect = _apply_resource_effect(resource_type, amount)
	
	if effect.success:
		# Subtract from inventory
		resource_inventory[resource_type] -= amount
		
		print("Used " + str(amount) + " " + resource_type + ": " + effect.description)
		return true
	
	return false

# Stabilize the excavation
func stabilize_excavation():
	if not excavation_status.active:
		push_error("Excavation not active")
		return false
	
	var old_stability = excavation_status.stability_level
	
	# Determine stabilization amount
	var base_stabilization = 0.15
	var mode_factor = 1.0 - (EXCAVATION_CONFIG.modes[excavation_status.current_mode].stability_impact * 0.5)
	var algo_factor = EXCAVATION_CONFIG.algorithms[excavation_status.current_algorithm].stability_coefficient
	
	var stabilization_amount = base_stabilization * mode_factor * algo_factor
	
	# Apply stabilization
	excavation_status.stability_level += stabilization_amount
	excavation_status.stability_level = min(excavation_status.stability_level, 1.0)
	
	emit_signal("stability_changed", old_stability, excavation_status.stability_level)
	
	print("Excavation stabilized: " + str(old_stability) + " -> " + str(excavation_status.stability_level))
	return true

# Timer update function
func _on_excavation_update():
	if not excavation_status.active:
		return
	
	# Get configs
	var mode_config = EXCAVATION_CONFIG.modes[excavation_status.current_mode]
	var algo_config = EXCAVATION_CONFIG.algorithms[excavation_status.current_algorithm]
	
	# Update duration
	var current_time = OS.get_unix_time()
	var elapsed_seconds = current_time - excavation_status.last_start_time
	excavation_status.duration_minutes = elapsed_seconds / 60.0
	
	# Check max duration
	if excavation_status.duration_minutes >= mode_config.max_duration_minutes:
		stop_excavation("completed")
		return
	
	# Update energy consumption
	var energy_rate = mode_config.energy_usage * (1.0 - algo_config.power_efficiency * 0.5)
	excavation_status.energy_consumption += energy_rate * update_interval_seconds / 60.0
	
	# Update progress
	excavation_status.progress = min(excavation_status.duration_minutes / mode_config.max_duration_minutes, 1.0) * 100.0
	
	# Affect stability
	_update_stability()
	
	# Check for discoveries
	process_discovery_attempt()

# Update stability
func _update_stability():
	# Get configs
	var mode_config = EXCAVATION_CONFIG.modes[excavation_status.current_mode]
	var algo_config = EXCAVATION_CONFIG.algorithms[excavation_status.current_algorithm]
	
	var old_stability = excavation_status.stability_level
	
	# Calculate stability impact
	var base_impact = mode_config.stability_impact * 0.01 # Small per-update impact
	var algo_factor = 1.0 - algo_config.stability_coefficient # Lower coefficient = higher impact
	
	var stability_impact = base_impact * (1.0 + algo_factor)
	
	# Apply stability impact
	excavation_status.stability_level -= stability_impact
	excavation_status.stability_level = max(excavation_status.stability_level, 0.1) # Prevent total collapse
	
	# Check for stability incident
	if old_stability >= 0.5 and excavation_status.stability_level < 0.5:
		metrics.stability_incidents += 1
		emit_signal("stability_changed", old_stability, excavation_status.stability_level)
		
		print("Stability incident: " + str(old_stability) + " -> " + str(excavation_status.stability_level))
	
	# Critical stability warning
	if excavation_status.stability_level < 0.2:
		emit_signal("error_occurred", {
			"type": "critical_stability",
			"message": "Excavation stability critically low",
			"stability": excavation_status.stability_level
		})

# Determine which resource is discovered
func _determine_resource_type(depth, target_type):
	# Weightings based on depth and target
	var weights = {
		"data_fragments": 0,
		"code_crystals": 0,
		"pattern_matrices": 0,
		"reality_shards": 0,
		"quantum_keys": 0
	}
	
	# Base weights by depth
	if depth <= 2:
		weights.data_fragments = 70
		weights.code_crystals = 25
		weights.pattern_matrices = 5
		weights.reality_shards = 0
		weights.quantum_keys = 0
	elif depth <= 4:
		weights.data_fragments = 40
		weights.code_crystals = 40
		weights.pattern_matrices = 15
		weights.reality_shards = 5
		weights.quantum_keys = 0
	elif depth <= 6:
		weights.data_fragments = 20
		weights.code_crystals = 30
		weights.pattern_matrices = 35
		weights.reality_shards = 15
		weights.quantum_keys = 0
	else: # depth > 6
		weights.data_fragments = 10
		weights.code_crystals = 20
		weights.pattern_matrices = 30
		weights.reality_shards = 30
		weights.quantum_keys = 10
	
	# Adjust based on target type
	match target_type:
		"standard":
			# No adjustment
			pass
		"advanced":
			weights.data_fragments = int(weights.data_fragments * 0.7)
			weights.code_crystals = int(weights.code_crystals * 1.2)
			weights.pattern_matrices = int(weights.pattern_matrices * 1.2)
		"complex":
			weights.data_fragments = int(weights.data_fragments * 0.5)
			weights.code_crystals = int(weights.code_crystals * 0.8)
			weights.pattern_matrices = int(weights.pattern_matrices * 1.5)
			weights.reality_shards = int(weights.reality_shards * 1.3)
			weights.quantum_keys = int(weights.quantum_keys * 1.5)
		"quantum":
			weights.data_fragments = int(weights.data_fragments * 0.3)
			weights.code_crystals = int(weights.code_crystals * 0.5)
			weights.pattern_matrices = int(weights.pattern_matrices * 0.8)
			weights.reality_shards = int(weights.reality_shards * 2.0)
			weights.quantum_keys = int(weights.quantum_keys * 4.0)
	
	# Calculate total weight
	var total_weight = 0
	for resource in weights:
		total_weight += weights[resource]
	
	# Generate random number
	var roll = randi() % total_weight
	
	# Determine result
	var cumulative = 0
	for resource in weights:
		cumulative += weights[resource]
		if roll < cumulative:
			return resource
	
	# Fallback
	return "data_fragments"

# Apply resource effect
func _apply_resource_effect(resource_type, amount):
	var effect = {
		"success": true,
		"description": ""
	}
	
	match resource_type:
		"data_fragments":
			# Slight stability boost
			var old_stability = excavation_status.stability_level
			excavation_status.stability_level += 0.05 * amount
			excavation_status.stability_level = min(excavation_status.stability_level, 1.0)
			effect.description = "Stability improved: " + str(old_stability) + " -> " + str(excavation_status.stability_level)
		
		"code_crystals":
			# Energy efficiency boost
			var energy_reduction = 0.1 * amount
			excavation_status.energy_consumption = max(excavation_status.energy_consumption * (1.0 - energy_reduction), 0)
			effect.description = "Energy consumption reduced by " + str(energy_reduction * 100) + "%"
		
		"pattern_matrices":
			# Discovery rate boost
			# This is handled implicitly in the next discovery attempt
			effect.description = "Discovery rate temporarily increased"
		
		"reality_shards":
			# Major stability restoration
			var old_stability = excavation_status.stability_level
			excavation_status.stability_level += 0.2 * amount
			excavation_status.stability_level = min(excavation_status.stability_level, 1.0)
			effect.description = "Stability significantly improved: " + str(old_stability) + " -> " + str(excavation_status.stability_level)
		
		"quantum_keys":
			# Dimensional shift - access higher depths temporarily
			excavation_status.current_depth += amount
			effect.description = "Excavation depth increased to " + str(excavation_status.current_depth)
			emit_signal("depth_reached", excavation_status.current_depth)
	
	return effect

# Estimate completion time
func _estimate_completion_time():
	if not excavation_status.active:
		return 0
	
	var mode_config = EXCAVATION_CONFIG.modes[excavation_status.current_mode]
	var remaining_minutes = mode_config.max_duration_minutes - excavation_status.duration_minutes
	
	return OS.get_unix_time() + (remaining_minutes * 60)

# Get dimension for depth
func _get_dimension_for_depth(depth):
	if depth <= 2:
		return "physical"
	elif depth <= 4:
		return "digital"
	elif depth <= 6:
		return "temporal"
	elif depth <= 8:
		return "conceptual"
	else:
		return "quantum"