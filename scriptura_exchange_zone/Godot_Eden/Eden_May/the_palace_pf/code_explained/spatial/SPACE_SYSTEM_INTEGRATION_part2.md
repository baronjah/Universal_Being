---
Continuation of SPACE_SYSTEM_INTEGRATION (Part 2)
---

		return ""
		
	return space_system.create_galaxy(position, properties)

# Create a star system within a galaxy
func create_star_system(galaxy_id: String, position: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> String:
	if not is_instance_valid(space_system):
		return ""
		
	return space_system.create_star_system(galaxy_id, position, properties)

# Create a planet within a star system
func create_planet(system_id: String, position: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> String:
	if not is_instance_valid(space_system):
		return ""
		
	return space_system.create_planet(system_id, position, properties)

# Generate a random star system
func generate_random_star_system() -> String:
	if not is_instance_valid(space_system):
		return ""
		
	return space_system.generate_random_star_system()
```

### 4. Create Integration Tests

```gdscript
# /code/gdscript/scripts/integration/space_integration_test.gd
extends Node

# References
var universal_bridge = null
var space_system = null
var akashic_records_manager = null

func _ready():
	# Run tests after initialization
	await get_tree().process_frame
	run_tests()

func run_tests():
	print("Running Space System Integration Tests...")
	
	# Get required references
	_get_references()
	
	# Run tests
	_test_galaxy_creation()
	_test_star_system_creation()
	_test_planet_creation()
	_test_random_system_generation()
	
	print("Space System Integration Tests Complete")

func _get_references():
	# Get Universal Bridge
	universal_bridge = UniversalBridge.get_instance()
	
	# Get Akashic Records Manager
	akashic_records_manager = AkashicRecordsManager.get_instance()
	
	# Get Space System
	space_system = SpaceSystem.get_instance()
	if space_system:
		space_system.initialize(universal_bridge, akashic_records_manager)

func _test_galaxy_creation():
	if not universal_bridge or not space_system:
		push_error("Required systems not available")
		return
	
	print("Testing galaxy creation...")
	
	var position = Vector3(100, 0, 100)
	var properties = {
		"size": 500,
		"star_count": 5000,
		"spiral_factor": 0.5,
		"color": Color(0.8, 0.6, 0.9)
	}
	
	var galaxy_id = universal_bridge.create_galaxy(position, properties)
	
	if galaxy_id.is_empty():
		push_error("Failed to create galaxy")
	else:
		print("Created galaxy: " + galaxy_id)
		
		# Verify it exists in space system
		var galaxy_data = space_system.get_celestial_body(galaxy_id)
		print("Galaxy exists in space system: " + str(galaxy_data.size() > 0))
		
		# Verify it was registered with Akashic Records
		var word = akashic_records_manager.get_word(galaxy_id)
		print("Galaxy registered in Akashic Records: " + str(word.size() > 0))

func _test_star_system_creation():
	if not universal_bridge or not space_system:
		push_error("Required systems not available")
		return
	
	print("Testing star system creation...")
	
	# Find a galaxy
	var galaxy_id = ""
	if space_system.galaxies.size() > 0:
		galaxy_id = space_system.galaxies.keys()[0]
	
	if galaxy_id.is_empty():
		# Create a galaxy if none exists
		galaxy_id = universal_bridge.create_galaxy()
	
	# Create star system
	var position = Vector3(10, 0, 10)
	var properties = {
		"star_type": "yellow_dwarf",
		"temperature": 5800,
		"radius": 1.0,
		"age": 4.6
	}
	
	var system_id = universal_bridge.create_star_system(galaxy_id, position, properties)
	
	if system_id.is_empty():
		push_error("Failed to create star system")
	else:
		print("Created star system: " + system_id + " in galaxy: " + galaxy_id)
		
		# Verify it exists in space system
		var system_data = space_system.get_celestial_body(system_id)
		print("Star system exists in space system: " + str(system_data.size() > 0))
		
		# Verify it was registered with Akashic Records
		var word = akashic_records_manager.get_word(system_id)
		print("Star system registered in Akashic Records: " + str(word.size() > 0))

func _test_planet_creation():
	if not universal_bridge or not space_system:
		push_error("Required systems not available")
		return
	
	print("Testing planet creation...")
	
	# Find a star system
	var system_id = ""
	if space_system.active_star_systems.size() > 0:
		system_id = space_system.active_star_systems.keys()[0]
	
	if system_id.is_empty():
		# Find a galaxy
		var galaxy_id = ""
		if space_system.galaxies.size() > 0:
			galaxy_id = space_system.galaxies.keys()[0]
		
		if galaxy_id.is_empty():
			# Create a galaxy if none exists
			galaxy_id = universal_bridge.create_galaxy()
		
		# Create star system
		system_id = universal_bridge.create_star_system(galaxy_id)
	
	# Create planet
	var position = Vector3(1, 0, 0)
	var properties = {
		"type": "terrestrial",
		"radius": 1.0,
		"distance": 1.0,
		"rotation_period": 24.0,
		"orbital_period": 365.0,
		"has_atmosphere": true,
		"has_water": true
	}
	
	var planet_id = universal_bridge.create_planet(system_id, position, properties)
	
	if planet_id.is_empty():
		push_error("Failed to create planet")
	else:
		print("Created planet: " + planet_id + " in star system: " + system_id)
		
		# Verify it exists in space system
		var planet_data = space_system.get_celestial_body(planet_id)
		print("Planet exists in space system: " + str(planet_data.size() > 0))
		
		# Verify it was registered with Akashic Records
		var word = akashic_records_manager.get_word(planet_id)
		print("Planet registered in Akashic Records: " + str(word.size() > 0))

func _test_random_system_generation():
	if not universal_bridge:
		push_error("Universal Bridge not available")
		return
	
	print("Testing random star system generation...")
	
	var system_id = universal_bridge.generate_random_star_system()
	
	if system_id.is_empty():
		push_error("Failed to generate random star system")
	else:
		print("Generated random star system: " + system_id)
		
		# Verify planets were created
		var planet_count = 0
		if space_system and space_system.active_star_systems.has(system_id):
			planet_count = space_system.active_star_systems[system_id].planets.size()
		
		print("System has " + str(planet_count) + " planets")
```

### 5. Create Space Demo Scene

```gdscript
# /code/gdscript/scenes/space_demo.tscn
[gd_scene load_steps=6 format=3 uid="uid://chq3n8g5awe4r"]

[ext_resource type="Script" path="res://code/gdscript/scripts/core/universal_bridge.gd" id="1_cxqvw"]
[ext_resource type="Script" path="res://code/gdscript/scripts/core/akashic_records_manager.gd" id="2_t5qr0"]
[ext_resource type="Script" path="res://code/gdscript/scripts/core/space_system.gd" id="3_kbgew"]
[ext_resource type="Script" path="res://code/gdscript/scripts/integration/space_system_adapter.gd" id="4_3hj1l"]
[ext_resource type="Script" path="res://code/gdscript/scripts/integration/space_integration_test.gd" id="5_m564i"]

[node name="SpaceDemo" type="Node"]

[node name="Systems" type="Node" parent="."]

[node name="UniversalBridge" type="Node" parent="Systems"]
script = ExtResource("1_cxqvw")

[node name="AkashicRecordsManager" type="Node" parent="Systems"]
script = ExtResource("2_t5qr0")

[node name="SpaceSystem" type="Node" parent="Systems"]
script = ExtResource("3_kbgew")

[node name="SpaceSystemAdapter" type="Node" parent="Systems"]
script = ExtResource("4_3hj1l")

[node name="SpaceWorld" type="Node3D" parent="."]

[node name="Camera3D" type="Camera3D" parent="SpaceWorld"]
transform = Transform3D(1, 0, 0, 0, 0.866025, 0.5, 0, -0.5, 0.866025, 0, 100, 1000)

[node name="DirectionalLight3D" type="DirectionalLight3D" parent="SpaceWorld"]
transform = Transform3D(0.866025, 0.433013, -0.25, 0, 0.5, 0.866025, 0.5, -0.75, 0.433013, 0, 100, 0)
shadow_enabled = true

[node name="SpaceIntegrationTest" type="Node" parent="."]
script = ExtResource("5_m564i")

[node name="UI" type="CanvasLayer" parent="."]

[node name="SpaceControlPanel" type="PanelContainer" parent="UI"]
offset_right = 250.0
offset_bottom = 200.0

[node name="VBoxContainer" type="VBoxContainer" parent="UI/SpaceControlPanel"]
layout_mode = 2

[node name="Label" type="Label" parent="UI/SpaceControlPanel/VBoxContainer"]
layout_mode = 2
text = "Space System Demo"
horizontal_alignment = 1

[node name="HSeparator" type="HSeparator" parent="UI/SpaceControlPanel/VBoxContainer"]
layout_mode = 2

[node name="CreateGalaxyButton" type="Button" parent="UI/SpaceControlPanel/VBoxContainer"]
layout_mode = 2
text = "Create Galaxy"

[node name="CreateStarSystemButton" type="Button" parent="UI/SpaceControlPanel/VBoxContainer"]
layout_mode = 2
text = "Create Star System"

[node name="CreateSolarSystemButton" type="Button" parent="UI/SpaceControlPanel/VBoxContainer"]
layout_mode = 2
text = "Create Solar System"

[node name="RandomSystemButton" type="Button" parent="UI/SpaceControlPanel/VBoxContainer"]
layout_mode = 2
text = "Generate Random System"

[node name="HSeparator2" type="HSeparator" parent="UI/SpaceControlPanel/VBoxContainer"]
layout_mode = 2

[node name="StatusLabel" type="Label" parent="UI/SpaceControlPanel/VBoxContainer"]
layout_mode = 2
text = "Status: Ready"
```

## Backward Compatibility

To ensure backward compatibility:

1. **Space System Adapter**: Provides a bridge between old and new APIs
2. **Legacy Paths**: Keep original scripts in place during transition
3. **Signal Forwarding**: Forward signals from new system to match old signal names
4. **Instance Mapping**: Map between node instances and IDs for both systems

## Implementation Timeline

1. **Day 1**: Create Space System core class and basic functionality
2. **Day 2**: Implement Space System Adapter and update Universal Bridge
3. **Day 3**: Create standard celestial body classes in new structure
4. **Day 4**: Create integration tests and space demo scene
5. **Day 5**: Test and fix integration issues

## Testing Plan

1. **Functionality Testing**: Verify all space system functionality works
2. **Integration Testing**: Test connections with other systems
3. **Performance Testing**: Check for any performance impacts
4. **Visual Testing**: Ensure celestial bodies appear correctly

## Documentation

Update documentation to include:

1. **Space System API**: Document all methods and properties
2. **Integration Guide**: How to connect new components with Space System
3. **Usage Examples**: Example code for common space operations
4. **Migration Guide**: How to transition from old to new API