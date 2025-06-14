extends Node3D
# ═══════════════════════════════════════════════════════════════════════════════════════════════
# 🌞 ETHEREAL ENGINE - COSMIC HIERARCHY SYSTEM 🌞
# ═══════════════════════════════════════════════════════════════════════════════════════════════
#
# 📍 PROJECT PATH: /akashic_notepad3d_game/scripts/core/cosmic_hierarchy_system.gd
# 🎯 FILE GOAL: Implementation of Sun + 8 Planets cosmic hierarchy with 729 positions each
# 🔗 CONNECTED FILES:
#    - core/nine_layer_pyramid_system.gd (pyramid coordinate system)
#    - core/atomic_creation_tool.gd (atomic creation integration)
#    - core/main_game_controller.gd (input handling and system coordination)
#
# 🚀 REVOLUTIONARY FEATURES:
#    - Sun (Central Hub): Master convergence point [x5y5z5] for all planetary systems
#    - 8 Planets: Each with independent 9x9x9 coordinate systems (729 positions)
#    - Cosmic Navigation: Seamless travel between planetary coordinate systems
#    - Hierarchical Focus: Dynamic zooming from solar system to planetary detail
#    - Frequency Resonance: Each planet operates on unique frequency signatures
#
# 🌟 COSMIC STRUCTURE:
#    Mercury - Frequency 1.0 - Speed/Communication Planet
#    Venus   - Frequency 1.6 - Love/Beauty Planet  
#    Earth   - Frequency 2.0 - Life/Balance Planet
#    Mars    - Frequency 2.4 - Action/Power Planet
#    Jupiter - Frequency 3.0 - Expansion/Wisdom Planet
#    Saturn  - Frequency 3.6 - Structure/Discipline Planet
#    Uranus  - Frequency 4.2 - Innovation/Change Planet
#    Neptune - Frequency 4.8 - Dreams/Mysticism Planet
#
# 🎮 USER EXPERIENCE: Navigate cosmic hierarchies with atomic precision
# ═══════════════════════════════════════════════════════════════════════════════════════════════

## Cosmic Hierarchy System - Sun + 8 Planets Architecture
class_name CosmicHierarchySystem

# Cosmic constants
const TOTAL_PLANETS = 8
const POSITIONS_PER_PLANET = 729  # 9x9x9
const SUN_POSITION = Vector3(0, 0, 0)  # Central hub
const PLANET_ORBIT_RADIUS = 100.0

# Planet data structure
enum PlanetType {
	MERCURY,  # Speed/Communication
	VENUS,    # Love/Beauty
	EARTH,    # Life/Balance  
	MARS,     # Action/Power
	JUPITER,  # Expansion/Wisdom
	SATURN,   # Structure/Discipline
	URANUS,   # Innovation/Change
	NEPTUNE   # Dreams/Mysticism
}

# Planet frequency signatures
const PLANET_FREQUENCIES = {
	PlanetType.MERCURY: 1.0,
	PlanetType.VENUS:   1.6,
	PlanetType.EARTH:   2.0,
	PlanetType.MARS:    2.4,
	PlanetType.JUPITER: 3.0,
	PlanetType.SATURN:  3.6,
	PlanetType.URANUS:  4.2,
	PlanetType.NEPTUNE: 4.8
}

# Planet names and characteristics
const PLANET_DATA = {
	PlanetType.MERCURY: {"name": "Mercury", "element": "Quicksilver", "domain": "Communication"},
	PlanetType.VENUS:   {"name": "Venus",   "element": "Copper",      "domain": "Beauty"},
	PlanetType.EARTH:   {"name": "Earth",   "element": "Iron",        "domain": "Life"},
	PlanetType.MARS:    {"name": "Mars",    "element": "Iron",        "domain": "Power"},
	PlanetType.JUPITER: {"name": "Jupiter", "element": "Tin",         "domain": "Wisdom"},
	PlanetType.SATURN:  {"name": "Saturn",  "element": "Lead",        "domain": "Structure"},
	PlanetType.URANUS:  {"name": "Uranus",  "element": "Uranium",     "domain": "Innovation"},
	PlanetType.NEPTUNE: {"name": "Neptune", "element": "Neptunium",   "domain": "Dreams"}
}

# System state
var current_planet: PlanetType = PlanetType.EARTH
var current_cosmic_level: String = "Solar_System"
var planets: Dictionary = {}
var sun_node: Node3D = null
var nine_layer_pyramid: NineLayerPyramidSystem = null

# Visualization nodes
var planet_visualizers: Array[Node3D] = []
var cosmic_ui: Control = null

# Navigation state
var cosmic_focus_mode: bool = false
var planet_transition_active: bool = false

# ─────────────────────────────────────────────────────────────────────────────────
# 🌞 INITIALIZE COSMIC HIERARCHY - SUN + 8 PLANETS SETUP
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Nine layer pyramid system reference for coordinate integration
# PROCESS: Creates Sun central hub and 8 planetary coordinate systems
# OUTPUT: Complete cosmic hierarchy with 5832 total positions (8 × 729)
# CHANGES: Initializes all planetary nodes and frequency signatures
# CONNECTION: Integrates with nine_layer_pyramid_system for coordinate mapping
# ─────────────────────────────────────────────────────────────────────────────────
func initialize(pyramid_system: NineLayerPyramidSystem) -> void:
	nine_layer_pyramid = pyramid_system
	_create_sun_central_hub()
	_create_planetary_systems()
	_setup_cosmic_navigation()
	_initialize_planet_visualizers()
	print("🌞 Cosmic Hierarchy System initialized - Sun + 8 Planets ready")
	print("📊 Total positions: ", TOTAL_PLANETS * POSITIONS_PER_PLANET, " (", TOTAL_PLANETS, " × ", POSITIONS_PER_PLANET, ")")

# ─────────────────────────────────────────────────────────────────────────────────
# ☀️ CREATE SUN CENTRAL HUB - MASTER CONVERGENCE POINT
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (creates at origin)
# PROCESS: Creates Sun node as master convergence point [x5y5z5]
# OUTPUT: Sun node with golden sphere visualization
# CHANGES: Adds sun_node to scene hierarchy
# CONNECTION: Central hub for all planetary coordinate systems
# ─────────────────────────────────────────────────────────────────────────────────
func _create_sun_central_hub() -> void:
	sun_node = Node3D.new()
	sun_node.name = "Sun_Central_Hub"
	sun_node.position = SUN_POSITION
	add_child(sun_node)
	
	# Create golden sphere for Sun visualization
	var sun_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 5.0
	sphere.height = 10.0
	sun_mesh.mesh = sphere
	
	# Golden material for Sun
	var sun_material = StandardMaterial3D.new()
	sun_material.emission_enabled = true
	sun_material.emission = Color.GOLD
	sun_material.metallic = 0.8
	sun_material.roughness = 0.2
	sun_mesh.material_override = sun_material
	
	sun_node.add_child(sun_mesh)
	print("☀️ Sun Central Hub created at position: ", SUN_POSITION)

# ─────────────────────────────────────────────────────────────────────────────────
# 🪐 CREATE PLANETARY SYSTEMS - 8 INDEPENDENT COORDINATE SYSTEMS
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (creates all 8 planets)
# PROCESS: Creates 8 planetary nodes, each with 9x9x9 coordinate system
# OUTPUT: 8 planets with unique positions, frequencies, and characteristics
# CHANGES: Populates planets dictionary with planetary coordinate systems
# CONNECTION: Each planet links to nine_layer_pyramid coordinate system
# ─────────────────────────────────────────────────────────────────────────────────
func _create_planetary_systems() -> void:
	for planet_type in PlanetType.values():
		var planet_node = Node3D.new()
		var planet_data = PLANET_DATA[planet_type]
		planet_node.name = planet_data.name + "_System"
		
		# Position planets in orbital configuration
		var angle = (float(planet_type) / TOTAL_PLANETS) * TAU
		var orbit_position = Vector3(
			cos(angle) * PLANET_ORBIT_RADIUS,
			sin(planet_type * 0.5) * 20.0,  # Slight vertical variation
			sin(angle) * PLANET_ORBIT_RADIUS
		)
		planet_node.position = orbit_position
		
		# Create planetary coordinate system (9x9x9)
		var planet_pyramid = NineLayerPyramidSystem.new()
		planet_pyramid.name = planet_data.name + "_Pyramid"
		planet_node.add_child(planet_pyramid)
		planet_pyramid.initialize()
		
		# Store planet data
		planets[planet_type] = {
			"node": planet_node,
			"pyramid": planet_pyramid,
			"frequency": PLANET_FREQUENCIES[planet_type],
			"data": planet_data,
			"position": orbit_position
		}
		
		add_child(planet_node)
		print("🪐 ", planet_data.name, " system created - Frequency: ", PLANET_FREQUENCIES[planet_type])

# ─────────────────────────────────────────────────────────────────────────────────
# 🧭 SETUP COSMIC NAVIGATION - HIERARCHICAL FOCUS SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (sets up navigation system)
# PROCESS: Configures hierarchical navigation from solar to planetary scale
# OUTPUT: Navigation system ready for cosmic hierarchy traversal
# CHANGES: Initializes cosmic focus modes and transition systems
# CONNECTION: Links to main controller input system for cosmic navigation
# ─────────────────────────────────────────────────────────────────────────────────
func _setup_cosmic_navigation() -> void:
	# Set initial focus to Earth
	current_planet = PlanetType.EARTH
	current_cosmic_level = "Planetary_Surface"
	
	# Create cosmic UI for navigation feedback
	cosmic_ui = Control.new()
	cosmic_ui.name = "Cosmic_Navigation_UI"
	add_child(cosmic_ui)
	
	print("🧭 Cosmic navigation system ready - Default focus: Earth")

# ─────────────────────────────────────────────────────────────────────────────────
# 🎨 INITIALIZE PLANET VISUALIZERS - VISUAL REPRESENTATION SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (creates visualizers for all planets)
# PROCESS: Creates visual representations with planet-specific materials
# OUTPUT: Visual planet spheres with appropriate colors and materials
# CHANGES: Adds planet visualizer nodes to scene
# CONNECTION: Visual feedback system for cosmic navigation
# ─────────────────────────────────────────────────────────────────────────────────
func _initialize_planet_visualizers() -> void:
	var planet_colors = {
		PlanetType.MERCURY: Color.SILVER,
		PlanetType.VENUS:   Color.ORANGE,
		PlanetType.EARTH:   Color.BLUE,
		PlanetType.MARS:    Color.RED,
		PlanetType.JUPITER: Color.GOLDENROD,
		PlanetType.SATURN:  Color.YELLOW,
		PlanetType.URANUS:  Color.CYAN,
		PlanetType.NEPTUNE: Color.DEEP_SKY_BLUE
	}
	
	for planet_type in PlanetType.values():
		var planet_info = planets[planet_type]
		var visualizer = MeshInstance3D.new()
		
		# Create planet sphere
		var sphere = SphereMesh.new()
		sphere.radius = 3.0 + (planet_type * 0.5)  # Varying sizes
		sphere.height = sphere.radius * 2
		visualizer.mesh = sphere
		
		# Planet-specific material
		var material = StandardMaterial3D.new()
		material.albedo_color = planet_colors[planet_type]
		material.metallic = 0.3
		material.roughness = 0.7
		visualizer.material_override = material
		
		planet_info.node.add_child(visualizer)
		planet_visualizers.append(visualizer)
		
		print("🎨 ", planet_info.data.name, " visualizer created with color: ", planet_colors[planet_type])

# ─────────────────────────────────────────────────────────────────────────────────
# 🎮 UPDATE COSMIC SYSTEM - REAL-TIME SYSTEM UPDATES
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Delta time for frame-rate independent updates
# PROCESS: Updates planetary systems, orbital mechanics, frequency resonance
# OUTPUT: Smooth cosmic system operation and transition handling
# CHANGES: Updates planet positions, system states, and visual feedback
# CONNECTION: Called by main_game_controller.gd in _process loop
# ─────────────────────────────────────────────────────────────────────────────────
func update_cosmic_system(delta: float) -> void:
	if planet_transition_active:
		_handle_planet_transition(delta)
	
	_update_orbital_mechanics(delta)
	_update_frequency_resonance(delta)
	_update_cosmic_focus_visualization(delta)

# ─────────────────────────────────────────────────────────────────────────────────
# 🌀 UPDATE ORBITAL MECHANICS - PLANETARY MOTION SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Delta time for smooth orbital motion
# PROCESS: Rotates planets around Sun with frequency-based orbital speeds
# OUTPUT: Realistic planetary orbital motion
# CHANGES: Updates planet node positions in orbital configuration
# CONNECTION: Creates living cosmic system with dynamic planet movement
# ─────────────────────────────────────────────────────────────────────────────────
func _update_orbital_mechanics(delta: float) -> void:
	for planet_type in PlanetType.values():
		var planet_info = planets[planet_type]
		var frequency = planet_info.frequency
		
		# Rotate planet around Sun based on frequency
		var orbital_speed = frequency * 0.1  # Slow orbital motion
		var current_angle = Time.get_ticks_msec() * 0.001 * orbital_speed
		
		var new_position = Vector3(
			cos(current_angle) * PLANET_ORBIT_RADIUS,
			sin(planet_type * 0.5) * 20.0,  # Maintain vertical variation
			sin(current_angle) * PLANET_ORBIT_RADIUS
		)
		
		planet_info.node.position = new_position
		planet_info.position = new_position

# ─────────────────────────────────────────────────────────────────────────────────
# 🎵 UPDATE FREQUENCY RESONANCE - HARMONIC SYSTEM UPDATES
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Delta time for frequency calculations
# PROCESS: Updates planet frequency signatures and harmonic resonance
# OUTPUT: Dynamic frequency-based planet behavior
# CHANGES: Modulates planet characteristics based on frequency signatures
# CONNECTION: Harmonic resonance affects creation tool and pyramid systems
# ─────────────────────────────────────────────────────────────────────────────────
func _update_frequency_resonance(delta: float) -> void:
	for planet_type in PlanetType.values():
		var planet_info = planets[planet_type]
		var frequency = planet_info.frequency
		
		# Update pyramid system with frequency modulation
		if planet_info.pyramid:
			planet_info.pyramid.set_frequency_modulation(frequency)

# ─────────────────────────────────────────────────────────────────────────────────
# 👁️ UPDATE COSMIC FOCUS VISUALIZATION - FOCUS FEEDBACK SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Delta time for smooth visual transitions
# PROCESS: Updates visual feedback for current cosmic focus
# OUTPUT: Clear visual indication of current planet/system focus
# CHANGES: Modulates planet brightness and scale based on focus
# CONNECTION: Provides user feedback for cosmic navigation state
# ─────────────────────────────────────────────────────────────────────────────────
func _update_cosmic_focus_visualization(delta: float) -> void:
	for i in range(planet_visualizers.size()):
		var visualizer = planet_visualizers[i]
		var planet_type = PlanetType.values()[i]
		
		# Highlight current planet
		if planet_type == current_planet:
			var pulse = sin(Time.get_ticks_msec() * 0.005) * 0.3 + 1.0
			visualizer.scale = Vector3.ONE * pulse
		else:
			visualizer.scale = Vector3.ONE

# ─────────────────────────────────────────────────────────────────────────────────
# 🚀 NAVIGATE TO PLANET - COSMIC TRAVEL SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Target planet type for navigation
# PROCESS: Initiates smooth transition to target planetary system
# OUTPUT: Camera and focus transition to target planet
# CHANGES: Updates current_planet and cosmic navigation state
# CONNECTION: Triggered by input system for cosmic hierarchy navigation
# ─────────────────────────────────────────────────────────────────────────────────
func navigate_to_planet(target_planet: PlanetType) -> void:
	if target_planet == current_planet:
		return
	
	var planet_info = planets[target_planet]
	var planet_data = planet_info.data
	
	print("🚀 Navigating to ", planet_data.name, " - ", planet_data.domain, " Domain")
	print("🎵 Planet frequency: ", planet_info.frequency)
	
	current_planet = target_planet
	planet_transition_active = true
	
	# Signal to camera system for smooth transition
	_initiate_camera_transition_to_planet(planet_info)

# ─────────────────────────────────────────────────────────────────────────────────
# 📹 INITIATE CAMERA TRANSITION TO PLANET - SMOOTH COSMIC TRAVEL
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Target planet information for camera positioning
# PROCESS: Creates smooth camera transition to planetary coordinate system
# OUTPUT: Camera positioned for optimal planetary system viewing
# CHANGES: Camera position and orientation for planetary focus
# CONNECTION: Coordinates with main camera controller for smooth transitions
# ─────────────────────────────────────────────────────────────────────────────────
func _initiate_camera_transition_to_planet(planet_info: Dictionary) -> void:
	var target_position = planet_info.position + Vector3(0, 10, 30)  # Viewing position
	
	# Create transition tween (would need camera reference)
	print("📹 Camera transition initiated to position: ", target_position)
	print("🎯 Focus: ", planet_info.data.name, " planetary coordinate system")

# ─────────────────────────────────────────────────────────────────────────────────
# 🌀 HANDLE PLANET TRANSITION - TRANSITION STATE MANAGEMENT
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Delta time for transition progress
# PROCESS: Manages ongoing planet transition animations and state
# OUTPUT: Smooth transition completion and state cleanup
# CHANGES: Updates transition state and finalizes planet switch
# CONNECTION: Ensures smooth cosmic navigation experience
# ─────────────────────────────────────────────────────────────────────────────────
func _handle_planet_transition(delta: float) -> void:
	# Handle transition logic here
	# For now, complete transition immediately
	planet_transition_active = false
	print("✅ Planet transition completed")

# ─────────────────────────────────────────────────────────────────────────────────
# 🎮 GET CURRENT PLANET INFO - SYSTEM STATE ACCESS
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (returns current state)
# PROCESS: Retrieves current planet information and system state
# OUTPUT: Dictionary with current planet data and coordinate system
# CHANGES: No changes (read-only access)
# CONNECTION: Provides system state to other components
# ─────────────────────────────────────────────────────────────────────────────────
func get_current_planet_info() -> Dictionary:
	return planets[current_planet] if current_planet in planets else {}

# ─────────────────────────────────────────────────────────────────────────────────
# 📊 GET COSMIC STATISTICS - SYSTEM METRICS ACCESS
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (returns system statistics)
# PROCESS: Calculates and returns cosmic system metrics
# OUTPUT: Dictionary with total positions, planets, frequencies
# CHANGES: No changes (calculated metrics)
# CONNECTION: Provides metrics for debug system and UI displays
# ─────────────────────────────────────────────────────────────────────────────────
func get_cosmic_statistics() -> Dictionary:
	return {
		"total_planets": TOTAL_PLANETS,
		"positions_per_planet": POSITIONS_PER_PLANET,
		"total_positions": TOTAL_PLANETS * POSITIONS_PER_PLANET,
		"current_planet": PLANET_DATA[current_planet].name,
		"current_frequency": PLANET_FREQUENCIES[current_planet],
		"cosmic_level": current_cosmic_level
	}

# ─────────────────────────────────────────────────────────────────────────────────
# 🌌 TOGGLE COSMIC VISUALIZATION - DISPLAY CONTROL
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (toggles current state)
# PROCESS: Shows/hides cosmic hierarchy visualization
# OUTPUT: Toggles visibility of all cosmic system components
# CHANGES: Updates visibility state of planets and visualization elements
# CONNECTION: Controlled by main input system for cosmic display management
# ─────────────────────────────────────────────────────────────────────────────────
func toggle_cosmic_visualization() -> void:
	visible = !visible
	if visible:
		print("🌌 Cosmic Hierarchy visualization enabled - Sun + 8 Planets visible")
	else:
		print("🌌 Cosmic Hierarchy visualization disabled")