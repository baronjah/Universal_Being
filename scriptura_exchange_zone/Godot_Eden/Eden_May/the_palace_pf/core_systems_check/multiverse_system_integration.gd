extends Node

# Multiverse System Integration for JSH Ethereal Engine
# Manages communication between the UI and core multiverse systems
# Provides API for universe travel, discovery, and management

# System references
var multiverse_evolution_system = null
var akashic_records_manager = null
var player_controller = null
var time_progression_system = null

# Universe tracking
var universes = {}
var current_universe_id = ""
var discovered_universes = []
var key_universes = []
var access_points = []

# Cosmic state
var cosmic_state = {
	"current_turn": 1,
	"total_turns": 108,
	"turn_progress": 0.0,
	"current_age": 0,
	"total_ages": 7,
	"metanarrative_progress": 0.0
}

# Events and triggers
signal universe_changed(old_universe_id, new_universe_id)
signal access_point_discovered(access_point_data)
signal cosmic_turn_advanced(turn_data)
signal metanarrative_progressed(progress_data)

# ========== Initialization ==========

func _ready():
	# This will be initialized from the MultiiverseInitializer
	pass

# Connect to core systems
func initialize(evolution_system = null, records_manager = null, player = null, time_system = null):
	multiverse_evolution_system = evolution_system
	akashic_records_manager = records_manager
	player_controller = player
	time_progression_system = time_system
	
	# If any systems are null, try to find them in the scene
	if not multiverse_evolution_system:
		multiverse_evolution_system = get_node_or_null("/root/MultiverseEvolutionSystem")
	
	if not akashic_records_manager:
		akashic_records_manager = get_node_or_null("/root/AkashicRecordsManager")
	
	if not time_progression_system:
		time_progression_system = get_node_or_null("/root/TimeProgressionSystem")
	
	# Set up initial state
	load_universe_data()
	create_default_universe()
	generate_access_points()
	
	print("JSH Multiverse System Integration initialized")
	return true

# Create a default universe if none exists
func create_default_universe():
	if universes.empty():
		var default_universe = {
			"id": "root_universe",
			"name": "Origin Point Alpha",
			"type": "Physical",
			"stability": 100.0,
			"energy_level": 7,
			"core_element": "Unity",
			"story_phase": "Beginning",
			"discovered_turn": 1,
			"description": "The primary universe where all journeys begin."
		}
		
		universes[default_universe.id] = default_universe
		current_universe_id = default_universe.id
		discovered_universes.append(default_universe.id)
		key_universes.append(default_universe)
		
		print("JSH Multiverse: Created default universe")
	
# Load universe data from multiverse evolution system if available
func load_universe_data():
	if multiverse_evolution_system:
		# This would load data from the evolution system
		# For now, we'll create sample data
		create_sample_universe_data()
	else:
		# Create sample data if no system is available
		create_sample_universe_data()

# Create sample universe data for testing
func create_sample_universe_data():
	# Sample universes
	var sample_universes = [
		{
			"id": "physical_prime",
			"name": "Prime Material Reality",
			"type": "Physical",
			"stability": 95.7,
			"energy_level": 6,
			"core_element": "Matter",
			"story_phase": "Rising Action",
			"discovered_turn": 3,
			"description": "The primary physical universe with standard natural laws."
		},
		{
			"id": "digital_nexus",
			"name": "Digital Nexus",
			"type": "Digital",
			"stability": 88.2,
			"energy_level": 8,
			"core_element": "Data",
			"story_phase": "Exposition",
			"discovered_turn": 7,
			"description": "A universe of pure information where code forms reality."
		},
		{
			"id": "astral_expanse",
			"name": "Astral Expanse",
			"type": "Astral",
			"stability": 72.4,
			"energy_level": 9,
			"core_element": "Thought",
			"story_phase": "Conflict",
			"discovered_turn": 12,
			"description": "A dream-like reality shaped by consciousness."
		},
		{
			"id": "quantum_labyrinth",
			"name": "Quantum Labyrinth",
			"type": "Quantum",
			"stability": 45.8,
			"energy_level": 11,
			"core_element": "Probability",
			"story_phase": "Complexity",
			"discovered_turn": 18,
			"description": "A chaotic universe where multiple timelines intersect unpredictably."
		},
		{
			"id": "temporal_archive",
			"name": "Temporal Archive",
			"type": "Temporal",
			"stability": 83.1,
			"energy_level": 7,
			"core_element": "Memory",
			"story_phase": "Flashback",
			"discovered_turn": 15,
			"description": "A repository of past events where history can be experienced."
		}
	]
	
	# Add sample universes to our tracking dictionary
	for universe in sample_universes:
		universes[universe.id] = universe
		discovered_universes.append(universe.id)
		key_universes.append(universe)
	
	# Set current universe
	if not current_universe_id and not universes.empty():
		current_universe_id = universes.keys()[0]
	
	# Set up cosmic state
	cosmic_state.current_turn = 25
	cosmic_state.turn_progress = 37.5
	cosmic_state.current_age = 2
	cosmic_state.metanarrative_progress = 28.4

# Generate access points between universes
func generate_access_points():
	access_points.clear()
	
	# Create access points for all discovered universes
	for universe_id in discovered_universes:
		if universe_id == current_universe_id:
			continue
		
		var universe = universes[universe_id]
		var stability = rand_range(25.0, 100.0)
		if universe.id in ["physical_prime", "digital_nexus"]:
			stability = rand_range(85.0, 100.0) # More stable for key universes
		
		var access_point = {
			"id": "ap_" + current_universe_id + "_to_" + universe_id,
			"source_universe": universes[current_universe_id],
			"target_universe": universe,
			"stability": stability,
			"description": "Portal to " + universe.name,
			"requirements": {},
			"hidden": false
		}
		
		# Special requirements for some universes
		if universe.id == "quantum_labyrinth":
			access_point.requirements["cosmic_turn_min"] = 15
			access_point.description += " (Requires Cosmic Turn 15+)"
		
		access_points.append(access_point)
	
	# Add some hidden universes
	var hidden_universe = {
		"id": "hidden_conceptual",
		"name": "Concept Realm",
		"type": "Conceptual",
		"stability": 65.3,
		"energy_level": 10,
		"core_element": "Abstraction",
		"story_phase": "Unknown",
		"discovered_turn": 0,
		"description": "A universe formed of pure concepts and ideas."
	}
	
	universes[hidden_universe.id] = hidden_universe
	
	var hidden_access_point = {
		"id": "ap_hidden_conceptual",
		"source_universe": universes[current_universe_id],
		"target_universe": hidden_universe,
		"stability": 38.2,
		"description": "Mysterious dimensional anomaly",
		"requirements": {"metanarrative_progress_min": 50},
		"hidden": true
	}
	
	access_points.append(hidden_access_point)

# ========== API Functions ==========

# Get the current universe data
func get_current_universe():
	if current_universe_id and universes.has(current_universe_id):
		return universes[current_universe_id]
	return null

# Get available access points from current universe
func get_available_access_points():
	# Regenerate access points if the source universe changed
	var current_source = ""
	if not access_points.empty():
		current_source = access_points[0].source_universe.id
	
	if current_source != current_universe_id:
		generate_access_points()
	
	return access_points

# Get key universes (frequently used or important)
func get_key_universes():
	return key_universes

# Get current cosmic state
func get_cosmic_state():
	# Update from time progression system if available
	if time_progression_system:
		var time_data = time_progression_system.get_time_data()
		cosmic_state.turn_progress = time_data.turn_progress
		cosmic_state.metanarrative_progress = time_data.narrative_progress
	
	return cosmic_state

# Get universe alignment data (for visualization)
func get_universe_alignment():
	# In a full implementation, this would calculate actual alignment
	# For now, return basic visualization data
	var alignment_data = {
		"central_universe": current_universe_id,
		"connected_universes": {},
		"alignment_values": {}
	}
	
	for ap in access_points:
		var target_id = ap.target_universe.id
		alignment_data.connected_universes[target_id] = ap.target_universe.type
		alignment_data.alignment_values[target_id] = ap.stability / 100.0
	
	return alignment_data

# Travel to a different universe
func travel_to_universe(universe_id):
	if not universes.has(universe_id):
		print("JSH Multiverse: Cannot travel to unknown universe: " + universe_id)
		return false
	
	# Check if we have an access point
	var access_point = null
	for ap in access_points:
		if ap.target_universe.id == universe_id:
			access_point = ap
			break
	
	if not access_point:
		print("JSH Multiverse: No access point to universe: " + universe_id)
		return false
	
	# Check requirements
	if access_point.requirements.has("cosmic_turn_min") and cosmic_state.current_turn < access_point.requirements.cosmic_turn_min:
		print("JSH Multiverse: Cosmic turn requirement not met")
		return false
	
	if access_point.requirements.has("metanarrative_progress_min") and cosmic_state.metanarrative_progress < access_point.requirements.metanarrative_progress_min:
		print("JSH Multiverse: Metanarrative progress requirement not met")
		return false
	
	# Perform universe transition
	var old_universe_id = current_universe_id
	current_universe_id = universe_id
	
	# If connected to multiverse evolution system, update it
	if multiverse_evolution_system:
		multiverse_evolution_system.set_active_universe(universe_id)
	
	# Record in Akashic Records if available
	if akashic_records_manager:
		akashic_records_manager.record_universe_travel(old_universe_id, universe_id)
	
	# Emit signal for listeners
	emit_signal("universe_changed", old_universe_id, universe_id)
	
	print("JSH Multiverse: Traveled from " + old_universe_id + " to " + universe_id)
	
	# Regenerate access points for new universe
	generate_access_points()
	
	return true

# Advance cosmic turn
func advance_cosmic_turn():
	cosmic_state.current_turn += 1
	cosmic_state.turn_progress = 0.0
	
	# Check for age advancement
	if cosmic_state.current_turn % 18 == 0 and cosmic_state.current_age < cosmic_state.total_ages - 1:
		cosmic_state.current_age += 1
	
	# Update metanarrative progress
	cosmic_state.metanarrative_progress = min(100.0, (cosmic_state.current_turn / float(cosmic_state.total_turns)) * 100.0)
	
	# Emit signal for listeners
	emit_signal("cosmic_turn_advanced", {
		"turn": cosmic_state.current_turn,
		"age": cosmic_state.current_age
	})
	
	print("JSH Multiverse: Advanced to Cosmic Turn " + str(cosmic_state.current_turn))
	
	# In a full implementation, this would trigger universe evolution
	# and potentially reveal new access points or universes
	update_universes_for_new_turn()
	
	return cosmic_state.current_turn

# Update universes for new turn
func update_universes_for_new_turn():
	# This would update universe properties based on the turn
	# For now, we'll just make small random changes
	
	for universe_id in universes:
		var universe = universes[universe_id]
		
		# Random stability fluctuation
		universe.stability += rand_range(-2.0, 2.0)
		universe.stability = clamp(universe.stability, 25.0, 100.0)
		
		# Random energy level change
		if randf() < 0.2: # 20% chance
			universe.energy_level += randi() % 3 - 1 # -1, 0, or 1
			universe.energy_level = clamp(universe.energy_level, 1, 12)
		
		# Story phase progression
		if randf() < 0.1: # 10% chance
			var phases = ["Beginning", "Exposition", "Rising Action", "Conflict", 
						  "Climax", "Falling Action", "Resolution", "Epilogue"]
			var current_index = phases.find(universe.story_phase)
			if current_index >= 0 and current_index < phases.size() - 1:
				universe.story_phase = phases[current_index + 1]
	
	# Potentially discover new universe
	if randf() < 0.15: # 15% chance per turn
		discover_new_universe()

# Discover a new universe
func discover_new_universe():
	# Check if we've already discovered most universes
	if discovered_universes.size() >= universes.size() - 1:
		return false
	
	# Find undiscovered universe
	var undiscovered = []
	for universe_id in universes:
		if not universe_id in discovered_universes:
			undiscovered.append(universe_id)
	
	if undiscovered.empty():
		return false
	
	# Select random undiscovered universe
	var new_universe_id = undiscovered[randi() % undiscovered.size()]
	var new_universe = universes[new_universe_id]
	
	# Mark as discovered
	discovered_universes.append(new_universe_id)
	new_universe.discovered_turn = cosmic_state.current_turn
	
	# Create access point
	var access_point = {
		"id": "ap_" + current_universe_id + "_to_" + new_universe_id,
		"source_universe": universes[current_universe_id],
		"target_universe": new_universe,
		"stability": rand_range(40.0, 80.0),
		"description": "Newly discovered portal to " + new_universe.name,
		"requirements": {},
		"hidden": false
	}
	
	access_points.append(access_point)
	
	# Emit signal
	emit_signal("access_point_discovered", access_point)
	
	print("JSH Multiverse: Discovered new universe: " + new_universe.name)
	return true

# Reset the multiverse system
func reset_system():
	universes.clear()
	discovered_universes.clear()
	key_universes.clear()
	access_points.clear()
	current_universe_id = ""
	
	cosmic_state.current_turn = 1
	cosmic_state.turn_progress = 0.0
	cosmic_state.current_age = 0
	cosmic_state.metanarrative_progress = 0.0
	
	# Reinitialize
	create_default_universe()
	create_sample_universe_data()
	generate_access_points()
	
	print("JSH Multiverse: System reset to initial state")
	return true