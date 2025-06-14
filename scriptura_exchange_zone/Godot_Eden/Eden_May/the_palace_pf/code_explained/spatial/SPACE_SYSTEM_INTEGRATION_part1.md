# Space System Integration Plan

## Overview

The Space System is a major component of the Eden project that generates and manages celestial bodies and space environments. This document outlines the plan to integrate the existing Galaxy_Star_Planet system with our newly standardized components.

## Current State

- **Location**: `/code/gdscript/scripts/Galaxy_Star_Planet/`
- **Key Components**:
  - `Galaxies.gd`: Galaxy generation and management
  - `Star.gd`: Star simulation
  - `CelestialPlanet.gd`: Planet generation and properties
  - `GalaxyCloseUp.gd`: Detailed visualization
- **Issues**:
  - Direct references to other systems
  - Non-standardized naming conventions
  - Lacks integration with Universal Bridge
  - Potential duplication with Thing Creator functionality

## Integration Goals

1. Connect Space System with Universal Bridge
2. Standardize API for celestial body creation and management
3. Link with Akashic Records for celestial body properties
4. Integrate with Thing Creator for entity instantiation
5. Create adapter for backward compatibility

## Directory Structure

### Target Structure

```
/code/gdscript/scripts/
├── core/
│   ├── space_system.gd              (New central manager)
│   ├── universal_bridge.gd          (Existing)
│   └── akashic_records_manager.gd   (Existing)
├── space/
│   ├── celestial_body.gd            (Base class)
│   ├── galaxy.gd                    (From Galaxies.gd)
│   ├── star.gd                      (From Star.gd)
│   ├── planet.gd                    (From CelestialPlanet.gd)
│   ├── galaxy_visualizer.gd         (From GalaxyCloseUp.gd)
│   └── space_navigation.gd          (From space_navigation_ui.gd)
└── integration/
    └── space_system_adapter.gd      (New adapter)
```

## Integration Steps

### 1. Create Space System Core

```gdscript
# /code/gdscript/scripts/core/space_system.gd
extends Node
class_name SpaceSystem

# Singleton instance
static var _instance = null

# Static function to get the singleton instance
static func get_instance() -> SpaceSystem:
	if not _instance:
		_instance = SpaceSystem.new()
	return _instance

# References
var universal_bridge = null
var akashic_records_manager = null
var galaxy_generator = null

# Data storage
var galaxies = {}
var active_star_systems = {}
var active_planets = {}

# Signals
signal galaxy_created(galaxy_id, position)
signal star_system_created(system_id, galaxy_id, position)
signal planet_created(planet_id, system_id, position)
signal celestial_body_selected(body_id, body_type)

func _ready():
	print("Initializing Space System...")

# Initialize the system
func initialize(p_universal_bridge = null, p_akashic_records_manager = null) -> void:
	universal_bridge = p_universal_bridge
	akashic_records_manager = p_akashic_records_manager
	
	# Load galaxy generator
	galaxy_generator = load("res://code/gdscript/scripts/space/galaxy.gd").new()
	if galaxy_generator:
		add_child(galaxy_generator)
	
	# Connect to Universal Bridge if available
	if universal_bridge:
		if universal_bridge.has_signal("entity_registered"):
			universal_bridge.connect("entity_registered", Callable(self, "_on_entity_registered"))
	
	print("Space System initialized")

# Create a new galaxy
func create_galaxy(position: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> String:
	if not galaxy_generator:
		push_error("Galaxy generator not available")
		return ""
	
	# Generate a unique ID
	var galaxy_id = "galaxy_" + str(randi())
	
	# Create galaxy properties if needed
	if properties.is_empty():
		properties = {
			"size": randf_range(100, 1000),
			"star_count": randi_range(1000, 10000),
			"spiral_factor": randf_range(0.1, 0.9),
			"color": Color(randf(), randf(), randf())
		}
	
	# Register with Akashic Records if available
	if akashic_records_manager:
		if not akashic_records_manager.get_word(galaxy_id).size() > 0:
			akashic_records_manager.create_word(galaxy_id, "celestial_body", properties)
	
	# Create galaxy instance
	var galaxy = galaxy_generator.create_galaxy(position, properties)
	
	# Store galaxy
	galaxies[galaxy_id] = {
		"instance": galaxy,
		"position": position,
		"properties": properties,
		"star_systems": {}
	}
	
	# Emit signal
	emit_signal("galaxy_created", galaxy_id, position)
	
	return galaxy_id

# Create a star system within a galaxy
func create_star_system(galaxy_id: String, position: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> String:
	if not galaxies.has(galaxy_id):
		push_error("Galaxy not found: " + galaxy_id)
		return ""
	
	# Generate a unique ID
	var system_id = "star_system_" + str(randi())
	
	# Create star system properties if needed
	if properties.is_empty():
		properties = {
			"star_type": ["red_dwarf", "yellow_dwarf", "blue_giant", "white_dwarf"].pick_random(),
			"temperature": randf_range(3000, 30000),
			"radius": randf_range(0.1, 10),
			"age": randf_range(1, 10)
		}
	
	# Register with Akashic Records if available
	if akashic_records_manager:
		if not akashic_records_manager.get_word(system_id).size() > 0:
			akashic_records_manager.create_word(system_id, "star_system", properties)
	
	# Create star system instance
	var star_system
	var StarClass = load("res://code/gdscript/scripts/space/star.gd")
	if StarClass:
		star_system = StarClass.new()
		star_system.initialize(properties)
		
		# Add to galaxy
		var galaxy_instance = galaxies[galaxy_id].instance
		if galaxy_instance:
			galaxy_instance.add_child(star_system)
			star_system.global_position = position
	
	# Store star system
	active_star_systems[system_id] = {
		"instance": star_system,
		"galaxy_id": galaxy_id,
		"position": position,
		"properties": properties,
		"planets": {}
	}
	
	# Add to galaxy data
	galaxies[galaxy_id].star_systems[system_id] = active_star_systems[system_id]
	
	# Emit signal
	emit_signal("star_system_created", system_id, galaxy_id, position)
	
	return system_id

# Create a planet within a star system
func create_planet(system_id: String, position: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> String:
	if not active_star_systems.has(system_id):
		push_error("Star system not found: " + system_id)
		return ""
	
	# Generate a unique ID
	var planet_id = "planet_" + str(randi())
	
	# Create planet properties if needed
	if properties.is_empty():
		properties = {
			"type": ["rocky", "gas_giant", "ice_giant", "terrestrial"].pick_random(),
			"radius": randf_range(0.1, 5),
			"distance": randf_range(0.5, 30),
			"rotation_period": randf_range(0.1, 1000),
			"orbital_period": randf_range(0.1, 1000),
			"has_atmosphere": randf() > 0.5,
			"has_water": randf() > 0.7
		}
	
	# Register with Akashic Records if available
	if akashic_records_manager:
		if not akashic_records_manager.get_word(planet_id).size() > 0:
			akashic_records_manager.create_word(planet_id, "planet", properties)
	
	# Create planet instance
	var planet
	var PlanetClass = load("res://code/gdscript/scripts/space/planet.gd")
	if PlanetClass:
		planet = PlanetClass.new()
		planet.initialize(properties)
		
		# Add to star system
		var system_instance = active_star_systems[system_id].instance
		if system_instance:
			system_instance.add_child(planet)
			planet.global_position = position
	
	# Store planet
	active_planets[planet_id] = {
		"instance": planet,
		"system_id": system_id,
		"position": position,
		"properties": properties
	}
	
	# Add to star system data
	active_star_systems[system_id].planets[planet_id] = active_planets[planet_id]
	
	# Emit signal
	emit_signal("planet_created", planet_id, system_id, position)
	
	return planet_id

# Get a celestial body by ID
func get_celestial_body(body_id: String) -> Dictionary:
	if galaxies.has(body_id):
		return galaxies[body_id]
	elif active_star_systems.has(body_id):
		return active_star_systems[body_id]
	elif active_planets.has(body_id):
		return active_planets[body_id]
	
	return {}

# Select a celestial body for observation or interaction
func select_celestial_body(body_id: String) -> bool:
	var body_data = get_celestial_body(body_id)
	if body_data.is_empty():
		return false
	
	var body_type = "unknown"
	if galaxies.has(body_id):
		body_type = "galaxy"
	elif active_star_systems.has(body_id):
		body_type = "star_system"
	elif active_planets.has(body_id):
		body_type = "planet"
	
	emit_signal("celestial_body_selected", body_id, body_type)
	return true

# Generate a random star system
func generate_random_star_system() -> String:
	var galaxy_id = "galaxy_milky_way"
	
	# Create galaxy if it doesn't exist
	if not galaxies.has(galaxy_id):
		galaxy_id = create_galaxy()
	
	# Create random position within galaxy
	var position = Vector3(
		randf_range(-100, 100),
		randf_range(-20, 20),
		randf_range(-100, 100)
	)
	
	# Create star system
	var system_id = create_star_system(galaxy_id, position)
	
	# Create random planets
	var planet_count = randi_range(1, 10)
	for i in range(planet_count):
		var planet_position = position + Vector3(
			randf_range(-10, 10),
			randf_range(-2, 2),
			randf_range(-10, 10)
		)
		
		create_planet(system_id, planet_position)
	
	return system_id

# Signal handlers
func _on_entity_registered(entity_id: String, word_id: String, _element_id) -> void:
	# Check if this is a celestial body
	if akashic_records_manager:
		var word = akashic_records_manager.get_word(word_id)
		if word.has("category") and word.category == "celestial_body":
			print("Celestial body registered: " + entity_id + " (" + word_id + ")")
```

### 2. Create Space System Adapter

```gdscript
# /code/gdscript/scripts/integration/space_system_adapter.gd
extends Node
class_name SpaceSystemAdapter

# References
var space_system = null
var universal_bridge = null
var old_galaxies = null  # Reference to old Galaxies node

# Initialize with references
func initialize(p_space_system, p_universal_bridge, p_old_galaxies = null) -> void:
	space_system = p_space_system
	universal_bridge = p_universal_bridge
	old_galaxies = p_old_galaxies
	
	# Connect signals
	_connect_signals()
	
	# Migrate existing data if needed
	if old_galaxies:
		_migrate_existing_data()
	
	print("Space System Adapter initialized")

# Connect signals between systems
func _connect_signals() -> void:
	if space_system:
		# Connect space system signals to adapter
		if space_system.has_signal("galaxy_created"):
			space_system.connect("galaxy_created", Callable(self, "_on_galaxy_created"))
		
		if space_system.has_signal("star_system_created"):
			space_system.connect("star_system_created", Callable(self, "_on_star_system_created"))
		
		if space_system.has_signal("planet_created"):
			space_system.connect("planet_created", Callable(self, "_on_planet_created"))

# Migrate existing data from old system
func _migrate_existing_data() -> void:
	if not old_galaxies or not space_system:
		return
	
	print("Migrating existing space data...")
	
	# Try to get existing galaxy data
	var existing_galaxies = []
	if old_galaxies.has_method("get_galaxies"):
		existing_galaxies = old_galaxies.get_galaxies()
	
	# Migrate each galaxy
	for galaxy in existing_galaxies:
		var galaxy_properties = {}
		
		# Extract properties from old galaxy
		if galaxy.has_method("get_properties"):
			galaxy_properties = galaxy.get_properties()
		else:
			# Try to extract common properties
			if galaxy.has("size"): galaxy_properties.size = galaxy.size
			if galaxy.has("star_count"): galaxy_properties.star_count = galaxy.star_count
			if galaxy.has("color"): galaxy_properties.color = galaxy.color
		
		# Create galaxy in new system
		var position = galaxy.global_position if galaxy.has("global_position") else Vector3.ZERO
		var galaxy_id = space_system.create_galaxy(position, galaxy_properties)
		
		print("Migrated galaxy: " + galaxy_id)
	
	print("Space data migration complete")

# Bridge API to legacy API

# Create a galaxy with the old API
func create_galaxy(position: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> Node:
	if not space_system:
		return null
	
	var galaxy_id = space_system.create_galaxy(position, properties)
	
	if galaxy_id.is_empty():
		return null
	
	return space_system.galaxies[galaxy_id].instance

# Create a star with the old API
func create_star(galaxy, position: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> Node:
	if not space_system:
		return null
	
	# Find galaxy ID from instance
	var galaxy_id = ""
	for gid in space_system.galaxies:
		if space_system.galaxies[gid].instance == galaxy:
			galaxy_id = gid
			break
	
	if galaxy_id.is_empty():
		return null
	
	var system_id = space_system.create_star_system(galaxy_id, position, properties)
	
	if system_id.is_empty():
		return null
	
	return space_system.active_star_systems[system_id].instance

# Create a planet with the old API
func create_planet(star_system, position: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> Node:
	if not space_system:
		return null
	
	# Find star system ID from instance
	var system_id = ""
	for sid in space_system.active_star_systems:
		if space_system.active_star_systems[sid].instance == star_system:
			system_id = sid
			break
	
	if system_id.is_empty():
		return null
	
	var planet_id = space_system.create_planet(system_id, position, properties)
	
	if planet_id.is_empty():
		return null
	
	return space_system.active_planets[planet_id].instance

# Signal handlers
func _on_galaxy_created(galaxy_id: String, position: Vector3) -> void:
	if universal_bridge and universal_bridge.has_method("create_thing_from_word"):
		universal_bridge.create_thing_from_word(galaxy_id, position)

func _on_star_system_created(system_id: String, galaxy_id: String, position: Vector3) -> void:
	if universal_bridge and universal_bridge.has_method("create_thing_from_word"):
		universal_bridge.create_thing_from_word(system_id, position)

func _on_planet_created(planet_id: String, system_id: String, position: Vector3) -> void:
	if universal_bridge and universal_bridge.has_method("create_thing_from_word"):
		universal_bridge.create_thing_from_word(planet_id, position)
```

### 3. Update Universal Bridge

Update the Universal Bridge to include the Space System:

```gdscript
# In universal_bridge.gd

# Add space system reference
var space_system = null

# In the _find_system_references method
func _find_system_references() -> void:
	# Existing code...
	
	# Find Space System (only if it already exists)
	space_system = SpaceSystem.get_instance()
	
	# Print found systems for debugging
	if debug_mode:
		print("Found Space System: ", space_system != null)

# In the _initialize_missing_systems method
func _initialize_missing_systems() -> void:
	# Existing code...
	
	# Create a SpaceSystem if it doesn't exist
	if not is_instance_valid(space_system):
		space_system = SpaceSystem.get_instance()
		if is_inside_tree():
			space_system.initialize(self, akashic_records_manager)
			print("Created and initialized SpaceSystem")

# Add space system methods to UniversalBridge

# Create a new galaxy
func create_galaxy(position: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> String:
	if not is_instance_valid(space_system):
