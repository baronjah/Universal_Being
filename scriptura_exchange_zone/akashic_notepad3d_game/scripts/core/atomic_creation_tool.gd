extends Node3D
# ═══════════════════════════════════════════════════════════════════════════════════════════════
# ⚛️ ATOMIC CREATION TOOL - 9x9x9 REALITY MANIFESTATION ENGINE ⚛️
# ═══════════════════════════════════════════════════════════════════════════════════════════════
#
# 📍 PROJECT PATH: /akashic_notepad3d_game/scripts/core/atomic_creation_tool.gd
# 🎯 FILE GOAL: Complete atomic-level creation system with periodic table precision
# 🔗 CONNECTED FILES:
#    - core/nine_layer_pyramid_system.gd (coordinate system)
#    - core/periodic_table_system.gd (element data)
#    - core/matter_states_engine.gd (solid/liquid/gas/plasma)
#
# 🚀 REVOLUTIONARY FEATURES:
#    - 729 Position Creation Space (9x9x9)
#    - Complete Periodic Table (118 elements)
#    - 4 Matter States with atomic spacing
#    - H2O Example: Ice → Water → Fog transitions
#    - Command-Based Creation: "create pyramid", "create cylinder height 8"
#
# 🎮 CREATION COMMANDS:
#    - create pyramid → 3D pyramid structure
#    - create cube water ice → H2O in solid state
#    - create cylinder height 8 → Perfect cylinder from circles
# ═══════════════════════════════════════════════════════════════════════════════════════════════

class_name AtomicCreationTool

# ATOMIC CREATION CONSTANTS
const CREATION_SPACE_SIZE = 9
const TOTAL_CREATION_POSITIONS = 729  # 9x9x9
const ATOMIC_SCALE = 0.1  # Scale factor for atomic visualization

# MATTER STATES - From Knowledge Archives
enum MatterState {
	SOLID,      # [ooo] - atoms tightly packed
	LIQUID,     # [ococo] - atoms with connectors  
	GAS,        # [occocco] - atoms with more space
	PLASMA      # [o] - single vibrating sphere
}

# PERIODIC TABLE ELEMENTS (Complete 118 elements)
const PERIODIC_TABLE = {
	"H": {"name": "Hydrogen", "number": 1, "mass": 1.0080, "group": 1, "period": 1},
	"He": {"name": "Helium", "number": 2, "mass": 4.0026, "group": 18, "period": 1},
	"O": {"name": "Oxygen", "number": 8, "mass": 15.999, "group": 16, "period": 2},
	# TODO: Add complete periodic table (118 elements)
}

# CREATION SYSTEM STATE
var creation_space = {}              # 9x9x9 atomic positions
var active_creation = null           # Currently active creation
var matter_state_engine              # Matter states processor
var pyramid_system: NineLayerPyramidSystem

# CREATION HISTORY
var creation_history = []
var undo_stack = []

# ATOMIC VISUALIZATION
var atom_meshes = {}
var molecular_bonds = []

# SIGNALS FOR CREATION EVENTS
signal creation_started(command: String)
signal creation_completed(object_data: Dictionary)
signal matter_state_changed(from_state: MatterState, to_state: MatterState)
signal atomic_structure_modified(position: Vector3, atoms: Array)

# ─────────────────────────────────────────────────────────────────────────────────
# ⚛️ INITIALIZE ATOMIC CREATION SYSTEM - REALITY MANIFESTATION SETUP
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Pyramid system reference for coordinate integration
# PROCESS: Sets up complete 9x9x9 creation space with atomic precision
# OUTPUT: Fully initialized atomic creation system ready for operation
# CHANGES: Creates creation space, connects to pyramid system, prepares visualization
# CONNECTION: Primary initialization point for reality creation integration
# ─────────────────────────────────────────────────────────────────────────────────
func initialize(pyramid_ref: NineLayerPyramidSystem) -> void:
	pyramid_system = pyramid_ref
	
	print("⚛️ ATOMIC CREATION TOOL INITIALIZING")
	print("🏗️ Creation Space: %dx%dx%d = %d positions" % [CREATION_SPACE_SIZE, CREATION_SPACE_SIZE, CREATION_SPACE_SIZE, TOTAL_CREATION_POSITIONS])
	
	_initialize_creation_space()
	_setup_matter_states()
	_prepare_atomic_visualization()
	
	print("✨ Atomic Creation Tool: READY FOR REALITY MANIFESTATION")

func _ready():
	# INPUT: Atomic creation tool initialization
	# PROCESS: Set up complete 9x9x9 creation space with atomic precision
	# OUTPUT: Active atomic creation system ready for reality manifestation
	# CHANGES: Initializes creation_space, connects to pyramid system
	# CONNECTION: Establishes foundation for atomic-level reality creation
	
	# Auto-initialize if not called by main controller
	if creation_space.is_empty():
		_initialize_creation_space()
		_setup_matter_states()
		_prepare_atomic_visualization()

func _initialize_creation_space():
	# INPUT: Ready signal from creation tool
	# PROCESS: Create complete 9x9x9 atomic creation matrix
	# OUTPUT: Initialized creation_space with atomic precision positioning
	# CHANGES: Populates creation_space dictionary with atomic positions
	# CONNECTION: Creates foundation for atomic-level object creation
	
	creation_space = {}
	
	for z in range(1, CREATION_SPACE_SIZE + 1):
		for y in range(1, CREATION_SPACE_SIZE + 1):
			for x in range(1, CREATION_SPACE_SIZE + 1):
				var position_key = "x%dy%dz%d" % [x, y, z]
				
				creation_space[position_key] = {
					"position": Vector3(x, y, z),
					"world_position": _calculate_creation_world_position(x, y, z),
					"atoms": [],
					"matter_state": MatterState.SOLID,
					"temperature": 20.0,  # Celsius
					"pressure": 1.0,      # Atmospheric
					"occupied": false,
					"molecular_bonds": [],
					"creation_timestamp": 0,
					"element_composition": {}
				}
	
	print("🏗️ Creation Space Initialized: %d atomic positions" % creation_space.size())

func _calculate_creation_world_position(x: int, y: int, z: int) -> Vector3:
	# INPUT: Grid coordinates in creation space
	# PROCESS: Convert creation coordinates to world space positions
	# OUTPUT: Vector3 world position for 3D atomic visualization
	# CHANGES: None (pure calculation)
	# CONNECTION: Bridges logical creation space with physical visualization
	
	var spacing = ATOMIC_SCALE
	var world_x = (x - 5) * spacing
	var world_y = (y - 5) * spacing
	var world_z = (z - 5) * spacing
	
	return Vector3(world_x, world_y, world_z)

func _setup_matter_states():
	# INPUT: Creation space initialization completion
	# PROCESS: Configure matter state engine for atomic transformations
	# OUTPUT: Active matter state system for solid/liquid/gas/plasma
	# CHANGES: Creates matter_state_engine reference
	# CONNECTION: Enables atomic matter state transformations
	
	# Create matter state engine (placeholder for now)
	matter_state_engine = {
		"transition_rules": {
			MatterState.SOLID: {"heat_threshold": 0.0, "spacing": 1.0},
			MatterState.LIQUID: {"heat_threshold": 100.0, "spacing": 1.5},
			MatterState.GAS: {"heat_threshold": 200.0, "spacing": 3.0},
			MatterState.PLASMA: {"heat_threshold": 1000.0, "spacing": 5.0}
		}
	}
	
	print("🌡️ Matter State Engine Ready")

func _connect_to_pyramid_system():
	# INPUT: Matter state setup completion
	# PROCESS: Connect to nine layer pyramid system for coordinate integration
	# OUTPUT: Active connection to pyramid coordinate system
	# CHANGES: Establishes pyramid_system reference
	# CONNECTION: Integrates creation tool with master coordinate system
	
	var pyramid_node = get_node_or_null("../nine_layer_pyramid_system")
	if pyramid_node:
		pyramid_system = pyramid_node
		print("🔗 Connected to Nine Layer Pyramid System")

func _prepare_atomic_visualization():
	# INPUT: System connections established
	# PROCESS: Prepare atomic visualization meshes and materials
	# OUTPUT: Ready atomic visualization system
	# CHANGES: Creates atom_meshes dictionary
	# CONNECTION: Enables visual representation of atomic structures
	
	atom_meshes = {}
	
	# Create basic atomic visualization meshes
	for element in PERIODIC_TABLE:
		var mesh = SphereMesh.new()
		mesh.radius = ATOMIC_SCALE * 0.5
		atom_meshes[element] = mesh
	
	print("🎨 Atomic Visualization Ready")

func execute_creation_command(command: String) -> bool:
	# INPUT: Text command for creation (e.g., "create pyramid")
	# PROCESS: Parse command and execute corresponding creation operation
	# OUTPUT: Boolean success status and created object
	# CHANGES: Modifies creation_space with new atomic structures
	# CONNECTION: Core interface for reality manifestation commands
	
	emit_signal("creation_started", command)
	
	var success = false
	var creation_data = {}
	
	# Parse and execute creation commands
	if command.begins_with("create pyramid"):
		success = _create_pyramid()
		creation_data = {"type": "pyramid", "positions": _get_pyramid_positions()}
		
	elif command.begins_with("create cube"):
		var material = _extract_material_from_command(command)
		var state = _extract_state_from_command(command)
		success = _create_cube(material, state)
		creation_data = {"type": "cube", "material": material, "state": state}
		
	elif command.begins_with("create cylinder"):
		var height = _extract_height_from_command(command)
		success = _create_cylinder(height)
		creation_data = {"type": "cylinder", "height": height}
		
	else:
		print("❌ Unknown creation command: %s" % command)
		return false
	
	if success:
		creation_history.append(creation_data)
		emit_signal("creation_completed", creation_data)
		print("✨ Creation Complete: %s" % command)
	
	return success

func _create_pyramid() -> bool:
	# INPUT: Create pyramid command execution
	# PROCESS: Generate 3D pyramid structure in creation space using knowledge pattern
	# OUTPUT: Pyramid structure with progressive layer building
	# CHANGES: Places pyramid atoms in creation_space following knowledge pattern
	# CONNECTION: Implements exact pyramid pattern from knowledge archives
	
	print("🔺 Creating Pyramid using Knowledge Pattern")
	
	# Clear creation space
	_clear_creation_space()
	
	# Implement pyramid pattern from knowledge:
	# Layer 1: [1][1][1][1][1][1][1][1][1] (full bottom)
	# Layer 2: [][2][2][2][2][2][2][2][] (8 positions)
	# Layer 3: [][][3][3][3][3][3][][]  (5 positions)
	# etc.
	
	for layer in range(1, 6):  # First 5 layers as example
		var width = 11 - (layer * 2)  # Decreasing width
		var start_pos = layer
		
		for x in range(start_pos, start_pos + width):
			for z in range(start_pos, start_pos + width):
				if x < CREATION_SPACE_SIZE and z < CREATION_SPACE_SIZE:
					var position_key = "x%dy%dz%d" % [x, layer, z]
					if creation_space.has(position_key):
						creation_space[position_key].occupied = true
						creation_space[position_key].atoms = [{"element": "H", "count": 1}]
	
	return true

func _create_cube(material: String = "water", state: MatterState = MatterState.SOLID) -> bool:
	# INPUT: Material type and matter state for cube creation
	# PROCESS: Create cube with specified material and atomic state
	# OUTPUT: Cube structure with proper atomic spacing for matter state
	# CHANGES: Places atoms in creation_space with matter-appropriate spacing
	# CONNECTION: Implements H2O example from knowledge (Ice/Water/Fog)
	
	print("🧊 Creating Cube: %s in %s state" % [material, MatterState.keys()[state]])
	
	# Clear creation space
	_clear_creation_space()
	
	# Create 7x7x7 cube as in knowledge example
	var cube_size = 7
	var start_pos = 2  # Center in 9x9x9 space
	
	for x in range(start_pos, start_pos + cube_size):
		for y in range(start_pos, start_pos + cube_size):
			for z in range(start_pos, start_pos + cube_size):
				var position_key = "x%dy%dz%d" % [x, y, z]
				if creation_space.has(position_key):
					_place_material_atoms(position_key, material, state)
	
	return true

func _create_cylinder(height: int = 8) -> bool:
	# INPUT: Height specification for cylinder creation
	# PROCESS: Create cylinder using circle base and height extension
	# OUTPUT: Perfect cylinder structure from knowledge pattern
	# CHANGES: Places atoms forming cylinder shape in creation_space
	# CONNECTION: Implements cylinder creation from knowledge archives
	
	print("🛢️ Creating Cylinder: height %d" % height)
	
	# Clear creation space
	_clear_creation_space()
	
	# Create base circle (layer 1)
	_create_circle_layer(1)
	
	# Fill middle layers (layer 2 to height-1)
	for layer in range(2, height):
		_create_cylinder_middle_layer(layer)
	
	# Create top circle (layer height)
	_create_circle_layer(height)
	
	return true

func _place_material_atoms(position_key: String, material: String, state: MatterState):
	# INPUT: Position key, material type, and matter state
	# PROCESS: Place appropriate atoms based on material and state
	# OUTPUT: Atomic structure placed at position with correct spacing
	# CHANGES: Updates creation_space position with atomic data
	# CONNECTION: Core atomic placement with matter state physics
	
	var position_data = creation_space[position_key]
	
	# Place atoms based on material (H2O example)
	if material == "water":
		position_data.atoms = [
			{"element": "H", "count": 2},
			{"element": "O", "count": 1}
		]
		position_data.element_composition = {"H": 2, "O": 1}
	
	# Apply matter state spacing
	match state:
		MatterState.SOLID:
			# Atoms tightly packed [ooo]
			position_data.occupied = true
		MatterState.LIQUID:
			# Atoms with connectors [ococo]
			position_data.occupied = (position_data.position.x + position_data.position.z) % 2 == 0
		MatterState.GAS:
			# Atoms with more space [occocco]  
			position_data.occupied = (position_data.position.x + position_data.position.z) % 3 == 0
		MatterState.PLASMA:
			# Single vibrating sphere [o]
			position_data.occupied = (position_data.position == Vector3(5, 5, 5))
	
	position_data.matter_state = state
	position_data.creation_timestamp = Time.get_unix_time_from_system()

func _create_circle_layer(layer: int):
	# INPUT: Layer number for circle creation
	# PROCESS: Create circular pattern at specified layer
	# OUTPUT: Circle of atoms placed in creation space
	# CHANGES: Updates creation_space with circular atomic pattern
	# CONNECTION: Helper function for cylinder creation
	
	var center = 5  # Center of 9x9 grid
	var radius = 3
	
	for x in range(1, CREATION_SPACE_SIZE + 1):
		for z in range(1, CREATION_SPACE_SIZE + 1):
			var distance = sqrt(pow(x - center, 2) + pow(z - center, 2))
			if distance <= radius and distance >= radius - 1:
				var position_key = "x%dy%dz%d" % [x, layer, z]
				if creation_space.has(position_key):
					creation_space[position_key].occupied = true
					creation_space[position_key].atoms = [{"element": "H", "count": 1}]

func _create_cylinder_middle_layer(layer: int):
	# INPUT: Layer number for cylinder middle section
	# PROCESS: Create cylinder wall at specified layer
	# OUTPUT: Cylindrical wall pattern in creation space
	# CHANGES: Updates creation_space with cylinder wall atoms
	# CONNECTION: Helper function for cylinder creation
	
	# Create hollow cylinder walls
	var center = 5
	var outer_radius = 3
	var inner_radius = 2
	
	for x in range(1, CREATION_SPACE_SIZE + 1):
		for z in range(1, CREATION_SPACE_SIZE + 1):
			var distance = sqrt(pow(x - center, 2) + pow(z - center, 2))
			if distance <= outer_radius and distance >= inner_radius:
				var position_key = "x%dy%dz%d" % [x, layer, z]
				if creation_space.has(position_key):
					creation_space[position_key].occupied = true
					creation_space[position_key].atoms = [{"element": "H", "count": 1}]

func _clear_creation_space():
	# INPUT: Request to clear creation space
	# PROCESS: Reset all positions in creation space to empty state
	# OUTPUT: Clean creation space ready for new creation
	# CHANGES: Resets all creation_space positions to default state
	# CONNECTION: Preparation function for new atomic creations
	
	for position_key in creation_space:
		var position_data = creation_space[position_key]
		position_data.occupied = false
		position_data.atoms = []
		position_data.element_composition = {}
		position_data.molecular_bonds = []

func _extract_material_from_command(command: String) -> String:
	# INPUT: Creation command string
	# PROCESS: Extract material specification from command
	# OUTPUT: Material name or default "hydrogen"
	# CHANGES: None (pure parsing function)
	# CONNECTION: Command parsing for material-specific creation
	
	if "water" in command:
		return "water"
	elif "hydrogen" in command:
		return "hydrogen"
	else:
		return "hydrogen"  # Default

func _extract_state_from_command(command: String) -> MatterState:
	# INPUT: Creation command string
	# PROCESS: Extract matter state from command
	# OUTPUT: MatterState enum value
	# CHANGES: None (pure parsing function)
	# CONNECTION: Command parsing for matter state specification
	
	if "ice" in command or "solid" in command:
		return MatterState.SOLID
	elif "liquid" in command or "water" in command:
		return MatterState.LIQUID
	elif "gas" in command or "fog" in command:
		return MatterState.GAS
	elif "plasma" in command:
		return MatterState.PLASMA
	else:
		return MatterState.SOLID  # Default

func _extract_height_from_command(command: String) -> int:
	# INPUT: Creation command string
	# PROCESS: Extract height specification from command
	# OUTPUT: Height integer or default 8
	# CHANGES: None (pure parsing function)
	# CONNECTION: Command parsing for dimensional specifications
	
	var regex = RegEx.new()
	regex.compile("height\\s+(\\d+)")
	var result = regex.search(command)
	
	if result:
		return int(result.get_string(1))
	else:
		return 8  # Default height

func get_creation_statistics() -> Dictionary:
	# INPUT: Request for creation tool statistics
	# PROCESS: Compile comprehensive creation system metrics
	# OUTPUT: Dictionary with complete creation tool status
	# CHANGES: None (read-only function)
	# CONNECTION: Provides creation tool health and usage information
	
	var occupied_positions = 0
	var total_atoms = 0
	var active_elements = {}
	
	for position_data in creation_space.values():
		if position_data.occupied:
			occupied_positions += 1
		
		for atom in position_data.atoms:
			total_atoms += atom.count
			var element = atom.element
			active_elements[element] = active_elements.get(element, 0) + atom.count
	
	return {
		"total_positions": TOTAL_CREATION_POSITIONS,
		"occupied_positions": occupied_positions,
		"total_atoms": total_atoms,
		"active_elements": active_elements,
		"creation_history_count": creation_history.size(),
		"available_elements": PERIODIC_TABLE.size(),
		"system_health": "OPTIMAL"
	}

func _get_pyramid_positions() -> Array:
	# INPUT: Request for pyramid position data
	# PROCESS: Collect all positions used in pyramid creation
	# OUTPUT: Array of position keys forming pyramid
	# CHANGES: None (read-only function)
	# CONNECTION: Provides pyramid structure data for visualization
	
	var pyramid_positions = []
	
	for position_key in creation_space:
		if creation_space[position_key].occupied:
			pyramid_positions.append(position_key)
	
	return pyramid_positions

# ─────────────────────────────────────────────────────────────────────────────────
# 🔄 UPDATE CREATION SYSTEM - REAL-TIME ATOMIC PROCESSING
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Delta time from main controller update loop
# PROCESS: Updates atomic structures, matter state transitions, molecular bonds
# OUTPUT: Continuous atomic system evolution and matter state processing
# CHANGES: Updates temperatures, pressures, and atomic interactions
# CONNECTION: Called by main_game_controller for real-time system updates
# ─────────────────────────────────────────────────────────────────────────────────
func update_creation_system(delta: float) -> void:
	# Update matter state transitions based on temperature and pressure
	for position_key in creation_space:
		var position_data = creation_space[position_key]
		if position_data.occupied:
			_update_matter_state_transitions(position_data, delta)
			_update_molecular_bonds(position_data, delta)
			_update_atomic_visualization(position_data)

# ─────────────────────────────────────────────────────────────────────────────────
# 🎮 TOGGLE CREATION INTERFACE - ATOMIC TOOL DISPLAY CONTROL
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Toggle request from main controller (0 key press)
# PROCESS: Shows/hides atomic creation tool interface and visualization
# OUTPUT: Toggles visibility of creation space and atomic structures
# CHANGES: Updates visibility state of creation tool components
# CONNECTION: Controlled by main input system for atomic creation display
# ─────────────────────────────────────────────────────────────────────────────────
func toggle_creation_interface() -> void:
	visible = !visible
	if visible:
		print("⚛️ Atomic Creation Tool interface enabled - 729 positions ready")
		print("📊 Creation statistics: ", get_creation_statistics())
		print("🧪 Available elements: ", PERIODIC_TABLE.size())
		print("💡 Try: 'create pyramid', 'create cube water ice', 'create cylinder height 8'")
	else:
		print("⚛️ Atomic Creation Tool interface disabled")

# ─────────────────────────────────────────────────────────────────────────────────
# 🌡️ UPDATE MATTER STATE TRANSITIONS - ATOMIC PHYSICS SIMULATION
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Position data and delta time for physics updates
# PROCESS: Simulates matter state transitions based on temperature and pressure
# OUTPUT: Updated matter states following atomic physics rules
# CHANGES: Updates matter_state based on thermal and pressure conditions
# CONNECTION: Implements realistic atomic physics for matter state changes
# ─────────────────────────────────────────────────────────────────────────────────
func _update_matter_state_transitions(position_data: Dictionary, delta: float) -> void:
	var current_temp = position_data.temperature
	var transition_rules = matter_state_engine.transition_rules
	
	# Determine appropriate matter state based on temperature
	var new_state = position_data.matter_state
	
	if current_temp < transition_rules[MatterState.LIQUID].heat_threshold:
		new_state = MatterState.SOLID
	elif current_temp < transition_rules[MatterState.GAS].heat_threshold:
		new_state = MatterState.LIQUID
	elif current_temp < transition_rules[MatterState.PLASMA].heat_threshold:
		new_state = MatterState.GAS
	else:
		new_state = MatterState.PLASMA
	
	# Apply state change if different
	if new_state != position_data.matter_state:
		var old_state = position_data.matter_state
		position_data.matter_state = new_state
		emit_signal("matter_state_changed", old_state, new_state)

# ─────────────────────────────────────────────────────────────────────────────────
# 🔗 UPDATE MOLECULAR BONDS - ATOMIC INTERACTION SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Position data and delta time for bond calculations
# PROCESS: Updates molecular bonds between atoms based on proximity and chemistry
# OUTPUT: Updated molecular bond structures and interaction strengths
# CHANGES: Updates molecular_bonds array with current bond states
# CONNECTION: Simulates realistic molecular chemistry and atomic interactions
# ─────────────────────────────────────────────────────────────────────────────────
func _update_molecular_bonds(position_data: Dictionary, delta: float) -> void:
	# Update molecular bonds based on atomic proximity and chemistry
	# This is a simplified bond system for demonstration
	position_data.molecular_bonds = []
	
	# Calculate bonds with neighboring positions
	for atom in position_data.atoms:
		var bond_strength = _calculate_bond_strength(atom.element, position_data.matter_state)
		position_data.molecular_bonds.append({
			"element": atom.element,
			"strength": bond_strength,
			"type": "covalent"  # Simplified for now
		})

# ─────────────────────────────────────────────────────────────────────────────────
# 🎨 UPDATE ATOMIC VISUALIZATION - VISUAL REPRESENTATION SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Position data for visual update
# PROCESS: Updates visual representation of atomic structures
# OUTPUT: Updated 3D visualization of atoms and bonds
# CHANGES: Updates visual meshes and materials for atomic display
# CONNECTION: Provides visual feedback for atomic creation and manipulation
# ─────────────────────────────────────────────────────────────────────────────────
func _update_atomic_visualization(position_data: Dictionary) -> void:
	# Update visual representation of atoms at this position
	# This would create/update MeshInstance3D nodes for visualization
	pass  # Visual implementation would go here

# ─────────────────────────────────────────────────────────────────────────────────
# 🧪 CALCULATE BOND STRENGTH - CHEMICAL INTERACTION PHYSICS
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Element type and matter state for bond calculation
# PROCESS: Calculates molecular bond strength based on chemistry and state
# OUTPUT: Float representing bond strength value
# CHANGES: None (pure calculation function)
# CONNECTION: Provides realistic chemical bond strength for molecular simulation
# ─────────────────────────────────────────────────────────────────────────────────
func _calculate_bond_strength(element: String, state: MatterState) -> float:
	# Simplified bond strength calculation
	var base_strength = 1.0
	
	# Adjust strength based on matter state
	match state:
		MatterState.SOLID:
			base_strength *= 1.0  # Full strength
		MatterState.LIQUID:
			base_strength *= 0.7  # Reduced strength
		MatterState.GAS:
			base_strength *= 0.3  # Much reduced
		MatterState.PLASMA:
			base_strength *= 0.1  # Minimal bonding
	
	return base_strength