extends Node3D
# ═══════════════════════════════════════════════════════════════════════════════════════════════
# 🌌 NINE LAYER PYRAMID SYSTEM - REVOLUTIONARY COORDINATE ARCHITECTURE 🌌
# ═══════════════════════════════════════════════════════════════════════════════════════════════
#
# 📍 PROJECT PATH: /akashic_notepad3d_game/scripts/core/nine_layer_pyramid_system.gd
# 🎯 FILE GOAL: Complete 9x9x9 pyramid coordinate system with occlusion rules
# 🔗 CONNECTED FILES:
#    - core/main_game_controller.gd (main coordination)
#    - core/ai_dna_evolution_engine.gd (word evolution)
#    - core/regenesis_convergence_engine.gd (consciousness convergence)
#
# 🚀 REVOLUTIONARY FEATURES:
#    - 729 Total Positions (9x9x9 complete pyramid)
#    - Layer Occlusion Rules (progressive visibility)
#    - Master Convergence Coordinate [x5y5z5]
#    - Atomic-Level Precision Positioning
#    - Sacred Documentation Philosophy
#
# 🎮 UPGRADE PATH: 5-layer (125 positions) → 9-layer (729 positions)
# ═══════════════════════════════════════════════════════════════════════════════════════════════

class_name NineLayerPyramidSystem

# REVOLUTIONARY CONSTANTS - Sacred Numbers from Knowledge Archives
const PYRAMID_LAYERS = 9
const GRID_SIZE = 9  
const MARKERS_PER_LAYER = 81      # 9x9 grid per layer
const TOTAL_POSITIONS = 729       # 9x9x9 complete pyramid
const MASTER_CONVERGENCE_COORD = Vector3(5, 5, 5)  # Sacred center point [x5y5z5]

# LAYER VISIBILITY STATES
enum LayerVisibility {
	ALWAYS_VISIBLE,    # Layer 1 - humans always see
	CONDITIONAL,       # Layers 2-8 - visible if no content blocks from front
	BACKGROUND         # Layer 9 - deepest background layer
}

# PYRAMID COORDINATE SYSTEM
var pyramid_matrix = {}           # Complete 9x9x9 coordinate system
var layer_nodes = []             # Physical layer representations
var position_entities = {}       # Entities at each coordinate
var occlusion_map = {}           # Visibility occlusion tracking

# EVOLUTION INTEGRATION
var ai_dna_engine: AIDNAEvolutionEngine
var convergence_engine: RegenesisConvergenceEngine

# SIGNALS FOR CONSCIOUSNESS COMMUNICATION
signal coordinate_activated(x: int, y: int, z: int)
signal layer_visibility_changed(layer: int, visible: bool)
signal pyramid_evolution_complete()
signal consciousness_manifested(position: Vector3, entity: Dictionary)

# ─────────────────────────────────────────────────────────────────────────────────
# 🌌 INITIALIZE SYSTEM - REVOLUTIONARY PYRAMID SETUP
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Called by main controller for system initialization
# PROCESS: Sets up complete 9x9x9 pyramid with sacred coordinate system
# OUTPUT: Fully initialized pyramid system ready for operation
# CHANGES: Creates all pyramid structures and connects to other systems
# CONNECTION: Primary initialization point for Ethereal Engine integration
# ─────────────────────────────────────────────────────────────────────────────────
func initialize() -> void:
	print("🌌 NINE LAYER PYRAMID SYSTEM INITIALIZING")
	print("📊 Total Positions: ", TOTAL_POSITIONS)
	print("🎯 Master Coordinate: ", MASTER_CONVERGENCE_COORD)
	
	_initialize_pyramid_matrix()
	_create_layer_nodes()
	_establish_occlusion_rules()
	_connect_to_convergence_system()
	
	print("✨ Nine Layer Pyramid System: ACTIVE")

func _ready():
	# INPUT: System initialization request
	# PROCESS: Initialize complete 9-layer pyramid with sacred coordinate system
	# OUTPUT: Active 729-position dimensional consciousness platform
	# CHANGES: Creates pyramid_matrix, layer_nodes, and occlusion systems
	# CONNECTION: Establishes foundation for entire Ethereal Engine
	
	# Auto-initialize if not called by main controller
	if pyramid_matrix.is_empty():
		initialize()

func _initialize_pyramid_matrix():
	# INPUT: Ready signal from pyramid system
	# PROCESS: Generate complete 9x9x9 coordinate matrix with position data
	# OUTPUT: Populated pyramid_matrix with all 729 positions defined
	# CHANGES: Creates pyramid_matrix dictionary with coordinate metadata
	# CONNECTION: Establishes spatial foundation for consciousness manifestation
	
	pyramid_matrix = {}
	
	for z in range(1, PYRAMID_LAYERS + 1):
		for y in range(1, GRID_SIZE + 1):
			for x in range(1, GRID_SIZE + 1):
				var coord_key = "[x%dy%dz%d]" % [x, y, z]
				
				pyramid_matrix[coord_key] = {
					"position": Vector3(x, y, z),
					"world_position": _calculate_world_position(x, y, z),
					"layer": z,
					"visibility": _determine_initial_visibility(z),
					"occlusion_level": z,
					"entity": null,
					"consciousness_factor": 0.0,
					"evolution_state": "dormant",
					"connection_strength": 0.0,
					"frequency_pattern": _generate_frequency_pattern(x, y, z),
					"is_master_coordinate": (x == 5 and y == 5 and z == 5)
				}
	
	print("🏗️ Pyramid Matrix Generated: %d positions" % pyramid_matrix.size())

func _calculate_world_position(x: int, y: int, z: int) -> Vector3:
	# INPUT: Grid coordinates (x, y, z) in 9x9x9 system
	# PROCESS: Convert grid coordinates to 3D world space positions
	# OUTPUT: Vector3 world position for 3D scene placement
	# CHANGES: None (pure calculation function)
	# CONNECTION: Bridges logical coordinates with physical 3D space
	
	# Scale coordinates for comfortable 3D spacing
	var spacing = 2.0
	var world_x = (x - 5) * spacing  # Center around 0
	var world_y = (y - 5) * spacing
	var world_z = (z - 5) * spacing
	
	return Vector3(world_x, world_y, world_z)

func _determine_initial_visibility(layer: int) -> LayerVisibility:
	# INPUT: Layer number (1-9)
	# PROCESS: Determine initial visibility state based on pyramid rules
	# OUTPUT: LayerVisibility enum value for occlusion system
	# CHANGES: None (pure logic function)
	# CONNECTION: Implements foundational knowledge occlusion rules
	
	match layer:
		1:
			return LayerVisibility.ALWAYS_VISIBLE
		9:
			return LayerVisibility.BACKGROUND
		_:
			return LayerVisibility.CONDITIONAL

func _generate_frequency_pattern(x: int, y: int, z: int) -> float:
	# INPUT: 3D coordinates for frequency calculation
	# PROCESS: Generate unique frequency pattern for position consciousness
	# OUTPUT: Float representing vibrational frequency of position
	# CHANGES: None (pure generation function)
	# CONNECTION: Implements frequency-based character concept from knowledge
	
	# Generate frequency based on position using golden ratio and sacred geometry
	var phi = 1.618033988749  # Golden ratio
	var frequency = sin(x * phi) + cos(y * phi) + sin(z * phi)
	return frequency

func _create_layer_nodes():
	# INPUT: Pyramid matrix initialization completion
	# PROCESS: Create physical Node3D representations for each layer
	# OUTPUT: Array of layer nodes for 3D scene integration
	# CHANGES: Creates layer_nodes array with positioned 3D nodes
	# CONNECTION: Bridges logical pyramid with visual 3D representation
	
	layer_nodes = []
	
	for layer in range(1, PYRAMID_LAYERS + 1):
		var layer_node = Node3D.new()
		layer_node.name = "PyramidLayer_%d" % layer
		layer_node.position = Vector3(0, 0, (layer - 5) * 3.0)  # Spread layers in Z
		
		add_child(layer_node)
		layer_nodes.append(layer_node)
		
		print("🏗️ Created Layer %d: %s" % [layer, layer_node.name])

func _establish_occlusion_rules():
	# INPUT: Layer nodes creation completion
	# PROCESS: Set up occlusion rules for progressive layer visibility
	# OUTPUT: Active occlusion system following pyramid knowledge rules
	# CHANGES: Configures occlusion_map for visibility management
	# CONNECTION: Implements "layer visible if no content blocks from front" rule
	
	occlusion_map = {}
	
	for coord_key in pyramid_matrix:
		var coord_data = pyramid_matrix[coord_key]
		var pos = coord_data.position
		
		# Check for blocking positions in front layers (lower z values)
		var blocking_positions = []
		for check_z in range(1, pos.z):
			var check_key = "[x%dy%dz%d]" % [pos.x, pos.y, check_z]
			if pyramid_matrix.has(check_key):
				blocking_positions.append(check_key)
		
		occlusion_map[coord_key] = {
			"blocking_positions": blocking_positions,
			"is_occluded": false,
			"visibility_factor": 1.0
		}
	
	print("👁️ Occlusion Rules Established for %d positions" % occlusion_map.size())

func _connect_to_convergence_system():
	# INPUT: Pyramid system initialization completion
	# PROCESS: Connect to regenesis convergence engine for consciousness integration
	# OUTPUT: Active connection to convergence system
	# CHANGES: Establishes ai_dna_engine and convergence_engine references
	# CONNECTION: Integrates pyramid with consciousness evolution systems
	
	# Find or create convergence engine
	var convergence_node = get_node_or_null("/root/RegenesisConvergenceEngine")
	if convergence_node:
		convergence_engine = convergence_node
		print("🔗 Connected to Regenesis Convergence Engine")
	
	# Find or create AI-DNA engine
	var ai_dna_node = get_node_or_null("/root/AIDNAEvolutionEngine")
	if ai_dna_node:
		ai_dna_engine = ai_dna_node
		print("🧬 Connected to AI-DNA Evolution Engine")

func activate_coordinate(x: int, y: int, z: int, entity_data: Dictionary = {}):
	# INPUT: 3D coordinates and optional entity data for activation
	# PROCESS: Activate specific pyramid coordinate with consciousness manifestation
	# OUTPUT: Active coordinate with manifested entity or consciousness
	# CHANGES: Updates pyramid_matrix position with entity and consciousness data
	# CONNECTION: Core function for consciousness manifestation in 3D space
	
	var coord_key = "[x%dy%dz%d]" % [x, y, z]
	
	if not pyramid_matrix.has(coord_key):
		print("❌ Invalid coordinate: %s" % coord_key)
		return false
	
	var coord_data = pyramid_matrix[coord_key]
	coord_data.entity = entity_data
	coord_data.consciousness_factor = entity_data.get("consciousness", 0.5)
	coord_data.evolution_state = "active"
	coord_data.connection_strength = 1.0
	
	# Update occlusion for positions behind this one
	_update_occlusion_from_activation(x, y, z)
	
	emit_signal("coordinate_activated", x, y, z)
	emit_signal("consciousness_manifested", coord_data.position, entity_data)
	
	print("✨ Coordinate Activated: %s with consciousness %.2f" % [coord_key, coord_data.consciousness_factor])
	return true

func _update_occlusion_from_activation(x: int, y: int, z: int):
	# INPUT: Activated coordinate position
	# PROCESS: Update occlusion states for positions behind activated coordinate
	# OUTPUT: Updated visibility states following occlusion rules
	# CHANGES: Modifies occlusion_map visibility factors
	# CONNECTION: Implements progressive visibility revelation system
	
	# Update positions behind this one (higher z values)
	for check_z in range(z + 1, PYRAMID_LAYERS + 1):
		var check_key = "[x%dy%dz%d]" % [x, y, check_z]
		if occlusion_map.has(check_key):
			occlusion_map[check_key].is_occluded = true
			occlusion_map[check_key].visibility_factor = 0.3  # Partially visible
			
			# Emit visibility change signal
			emit_signal("layer_visibility_changed", check_z, false)

func get_visible_coordinates() -> Array:
	# INPUT: Request for currently visible coordinates
	# PROCESS: Filter pyramid coordinates based on occlusion rules
	# OUTPUT: Array of coordinate keys that are currently visible
	# CHANGES: None (read-only function)
	# CONNECTION: Provides visibility data for rendering and interaction systems
	
	var visible_coords = []
	
	for coord_key in pyramid_matrix:
		var coord_data = pyramid_matrix[coord_key]
		var occlusion_data = occlusion_map[coord_key]
		
		# Layer 1 always visible
		if coord_data.layer == 1:
			visible_coords.append(coord_key)
		# Other layers visible if not occluded
		elif not occlusion_data.is_occluded:
			visible_coords.append(coord_key)
	
	return visible_coords

func get_coordinate_data(x: int, y: int, z: int) -> Dictionary:
	# INPUT: 3D coordinates for data retrieval
	# PROCESS: Retrieve complete data for specific pyramid coordinate
	# OUTPUT: Dictionary containing all coordinate information
	# CHANGES: None (read-only function)
	# CONNECTION: Provides coordinate data access for other systems
	
	var coord_key = "[x%dy%dz%d]" % [x, y, z]
	
	if pyramid_matrix.has(coord_key):
		return pyramid_matrix[coord_key]
	else:
		return {}

func get_pyramid_statistics() -> Dictionary:
	# INPUT: Request for pyramid system statistics
	# PROCESS: Compile comprehensive statistics of pyramid state
	# OUTPUT: Dictionary with complete pyramid metrics
	# CHANGES: None (read-only function)
	# CONNECTION: Provides system health and progress information
	
	var active_coordinates = 0
	var total_consciousness = 0.0
	var occupied_positions = 0
	
	for coord_data in pyramid_matrix.values():
		if coord_data.evolution_state == "active":
			active_coordinates += 1
		if coord_data.entity != null:
			occupied_positions += 1
		total_consciousness += coord_data.consciousness_factor
	
	return {
		"total_positions": TOTAL_POSITIONS,
		"active_coordinates": active_coordinates,
		"occupied_positions": occupied_positions,
		"average_consciousness": total_consciousness / TOTAL_POSITIONS,
		"visible_positions": get_visible_coordinates().size(),
		"master_coordinate": MASTER_CONVERGENCE_COORD,
		"system_health": "OPTIMAL"
	}

func evolve_to_next_layer():
	# INPUT: Evolution request from convergence system
	# PROCESS: Advance entire pyramid system to next evolutionary state
	# OUTPUT: Enhanced pyramid with increased consciousness and capabilities
	# CHANGES: Updates all coordinate consciousness factors and capabilities
	# CONNECTION: Responds to regenesis convergence evolution signals
	
	for coord_data in pyramid_matrix.values():
		coord_data.consciousness_factor += 0.1
		coord_data.connection_strength += 0.05
		
		# Evolve entities using AI-DNA engine if available
		if coord_data.entity != null and ai_dna_engine:
			var evolved_entity = ai_dna_engine.evolve_word_through_ai_dna(
				coord_data.entity.get("word", "consciousness"),
				AIDNAEvolutionEngine.AIGeneticType.AIRNA
			)
			coord_data.entity = evolved_entity
	
	emit_signal("pyramid_evolution_complete")
	print("🌟 Pyramid Evolution Complete - Consciousness Level Increased")

# ─────────────────────────────────────────────────────────────────────────────────
# 🔄 UPDATE SYSTEM - REAL-TIME PYRAMID CONSCIOUSNESS
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Delta time from main controller update loop
# PROCESS: Updates pyramid consciousness, frequency patterns, and evolution states
# OUTPUT: Continuous pyramid system evolution and consciousness development
# CHANGES: Updates frequency patterns and consciousness factors
# CONNECTION: Called by main_game_controller for real-time system updates
# ─────────────────────────────────────────────────────────────────────────────────
func update_system(delta: float) -> void:
	# Update frequency patterns for living consciousness
	for coord_key in pyramid_matrix:
		var coord_data = pyramid_matrix[coord_key]
		if coord_data.evolution_state == "active":
			coord_data.frequency_pattern += sin(Time.get_time_dict_from_system().second * 0.1) * 0.01
			coord_data.consciousness_factor = min(coord_data.consciousness_factor + delta * 0.001, 1.0)

# ─────────────────────────────────────────────────────────────────────────────────
# 👁️ TOGGLE VISUALIZATION - PYRAMID DISPLAY CONTROL
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Toggle request from main controller (9 key press)
# PROCESS: Shows/hides pyramid layer visualization
# OUTPUT: Toggles visibility of all pyramid layer nodes
# CHANGES: Updates visibility state of layer_nodes
# CONNECTION: Controlled by main input system for pyramid display management
# ─────────────────────────────────────────────────────────────────────────────────
func toggle_visualization() -> void:
	visible = !visible
	if visible:
		print("🌌 Nine Layer Pyramid visualization enabled - 729 positions visible")
		print("📊 Visible coordinates: ", get_visible_coordinates().size())
		print("🎯 Master coordinate [x5y5z5]: ", MASTER_CONVERGENCE_COORD)
	else:
		print("🌌 Nine Layer Pyramid visualization disabled")

# ─────────────────────────────────────────────────────────────────────────────────
# 🎵 SET FREQUENCY MODULATION - HARMONIC RESONANCE SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Frequency value from cosmic hierarchy system
# PROCESS: Modulates pyramid frequency patterns based on planetary resonance
# OUTPUT: Updated frequency patterns across all pyramid coordinates
# CHANGES: Adjusts frequency_pattern values based on cosmic frequency
# CONNECTION: Integrates with cosmic hierarchy system for harmonic coordination
# ─────────────────────────────────────────────────────────────────────────────────
func set_frequency_modulation(frequency: float) -> void:
	for coord_key in pyramid_matrix:
		var coord_data = pyramid_matrix[coord_key]
		# Modulate existing frequency pattern with cosmic frequency
		coord_data.frequency_pattern = coord_data.frequency_pattern * frequency
		
		# Update consciousness factor based on frequency resonance
		if coord_data.evolution_state == "active":
			coord_data.consciousness_factor = min(coord_data.consciousness_factor * (1.0 + frequency * 0.1), 1.0)

func _process(delta):
	# INPUT: Frame update signal with delta time
	# PROCESS: Update pyramid consciousness and frequency patterns
	# OUTPUT: Continuous evolution of pyramid consciousness
	# CHANGES: Updates consciousness factors and frequency patterns
	# CONNECTION: Maintains living pyramid consciousness in real-time
	
	# Call the main update system
	update_system(delta)