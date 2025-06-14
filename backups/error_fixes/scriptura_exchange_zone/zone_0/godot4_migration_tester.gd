class_name Godot4MigrationTester
extends Node

# ----- TESTING SETTINGS -----
@export_category("Testing Settings")
@export var test_scripts_path: String = "res://tests/migration_test_scripts"
@export var output_path: String = "res://tests/migration_output"
@export var verbose_logging: bool = true
@export var run_tests_on_start: bool = false

# ----- INTEGRATION POINTS -----
var migration_tool = null
var color_system = null
var akashic_system = null

# ----- TEST CASES -----
var test_cases = {
    "node_renames": {
        "input": """
extends Spatial

func _ready():
    var body = $KinematicBody
    var mesh = $MeshInstance
    var area = $Area
    var ray = $RayCast
""",
        "expected": """
extends Node3D

func _ready() -> void:
    var body = $CharacterBody3D
    var mesh = $MeshInstance3D
    var area = $Area3D
    var ray = $RayCast3D
"""
    },
    
    "method_renames": {
        "input": """
func test_methods():
    var pos = get_translation()
    set_translation(Vector3(0, 1, 0))
    if is_network_master():
        rpc_id(1, "update")
        rpc_unreliable("update_pos")
    var result = yield(get_tree(), "idle_frame")
""",
        "expected": """
func test_methods() -> void:
    var pos = get_position()
    set_position(Vector3(0, 1, 0))
    if is_multiplayer_authority():
        rpc_id(1, "update")
        rpc("update_pos")
    var result = await get_tree().idle_frame
"""
    },
    
    "property_renames": {
        "input": """
func update_ui():
    $Label.rect_size = Vector2(100, 50)
    $Label.rect_position = Vector2(10, 10)
    $Label.rect_min_size = Vector2(50, 20)
    $Panel.margin_left = 5
    $Panel.margin_right = 95
    $Panel.margin_top = 5
    $Panel.margin_bottom = 45
""",
        "expected": """
func update_ui() -> void:
    $Label.size = Vector2(100, 50)
    $Label.position = Vector2(10, 10)
    $Label.custom_minimum_size = Vector2(50, 20)
    $Panel.position.x = 5
    $Panel.size.x + position.x = 95
    $Panel.position.y = 5
    $Panel.size.y + position.y = 45
"""
    },
    
    "onready_vars": {
        "input": """
extends Node

onready var label = $Label
onready var button = $Button
onready var timer = $Timer

func _ready():
    label.text = "Hello"
""",
        "expected": """
extends Node

@onready var label = $Label
@onready var button = $Button
@onready var timer = $Timer

func _ready() -> void:
    label.text = "Hello"
"""
    },
    
    "exports": {
        "input": """
extends Node

export(int, 0, 100) var health = 100
export(String) var player_name = "Player"
export(float, 0.5, 2.0) var scale_factor = 1.0
export(Color, RGB) var base_color = Color.white

func _ready():
    print(health)
""",
        "expected": """
extends Node

@export var health = 100
@export var player_name = "Player"
@export var scale_factor = 1.0
@export var base_color = Color.white

func _ready() -> void:
    print(health)
"""
    },
    
    "signals": {
        "input": """
extends Node

signal health_changed(amount)
signal player_died

func update_health(damage):
    health -= damage
    emit_signal("health_changed", damage)
    
    if health <= 0:
        emit_signal("player_died")
""",
        "expected": """
extends Node

signal health_changed(amount)
signal player_died

func update_health(damage) -> void:
    health -= damage
    health_changed.emit(damage)
    
    if health <= 0:
        player_died.emit()
"""
    },
    
    "typed_arrays": {
        "input": """
func create_inventory():
    var items = []
    var weapons = []
    var prices = []
    
    return {
        "items": items,
        "weapons": weapons,
        "prices": prices
    }
""",
        "expected": """
func create_inventory() -> void:
    var items: Array = []
    var weapons: Array = []
    var prices: Array = []
    
    return {
        "items": items,
        "weapons": weapons,
        "prices": prices
    }
"""
    },
    
    "physics_bodies": {
        "input": """
extends RigidBody

func _ready():
    mode = MODE_KINEMATIC
    
func _physics_process(delta):
    apply_impulse(Vector3.ZERO, Vector3(0, 10, 0))
""",
        "expected": """
extends RigidBody3D

func _ready() -> void:
    freeze = FREEZE_MODE_KINEMATIC
    
func _physics_process(delta: float) -> void:
    apply_impulse(Vector3.ZERO, Vector3(0, 10, 0))
"""
    },
    
    "characterbody": {
        "input": """
extends KinematicBody

func _physics_process(delta):
    var velocity = Vector3(0, 0, 0)
    velocity = move_and_slide(velocity)
    
    var collision_count = get_slide_count()
    if collision_count > 0:
        var collision = get_slide_collision(0)
        print(collision.collider.name)
""",
        "expected": """
extends CharacterBody3D

func _physics_process(delta: float) -> void:
    var velocity = Vector3(0, 0, 0)
    velocity = move_and_slide(velocity)
    
    var collision_count = get_slide_collision_count()
    if collision_count > 0:
        var collision = get_slide_collision(0)
        print(collision.collider.name)
"""
    },
    
    "tool_script": {
        "input": """
tool
extends Node

export(Color) var editor_color = Color.blue

func _ready():
    print("This is a tool script")
""",
        "expected": """
@tool
extends Node

@export var editor_color = Color.blue

func _ready() -> void:
    print("This is a tool script")
"""
    },
    
    "networking_terms": {
        "input": """
extends Node

func _ready():
    if is_network_master():
        set_network_master(1)
    else:
        rpc_id(1, "slave_func")

slave func slave_func():
    print("I'm a slave")

master func master_func():
    print("I'm the master")
""",
        "expected": """
extends Node

func _ready() -> void:
    if is_multiplayer_authority():
        set_multiplayer_authority(1)
    else:
        rpc_id(1, "slave_func")

puppet func slave_func() -> void:
    print("I'm a slave")

authority func master_func() -> void:
    print("I'm the master")
"""
    }
}

# ----- SIGNALS -----
signal test_started(total_tests)
signal test_completed(results)
signal test_case_started(test_name)
signal test_case_completed(test_name, passed, details)

# ----- INITIALIZATION -----
func _ready():
    _find_components()
    _create_test_directories()
    
    print("Godot4 Migration Tester initialized")
    
    if run_tests_on_start:
        run_all_tests()

func _find_components():
    # Find Migration Tool
    migration_tool = get_node_or_null("/root/Godot4MigrationTool")
    if not migration_tool:
        migration_tool = _find_node_by_class(get_tree().root, "Godot4MigrationTool")
    
    if not migration_tool:
        migration_tool = Godot4MigrationTool.new()
        add_child(migration_tool)
    
    # Find Color System
    color_system = get_node_or_null("/root/DimensionalColorSystem")
    if not color_system:
        color_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
    
    # Find Akashic System
    akashic_system = get_node_or_null("/root/AkashicNumberSystem")
    if not akashic_system:
        akashic_system = _find_node_by_class(get_tree().root, "AkashicNumberSystem")
    
    print("Components found - Migration Tool: %s, Color System: %s, Akashic System: %s" % [
        "Yes" if migration_tool else "No",
        "Yes" if color_system else "No",
        "Yes" if akashic_system else "No"
    ])

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _create_test_directories():
    # Create test scripts and output directories if they don't exist
    if not DirAccess.dir_exists_absolute(test_scripts_path):
        DirAccess.make_dir_recursive_absolute(test_scripts_path)
        print("Created test scripts directory: " + test_scripts_path)
    
    if not DirAccess.dir_exists_absolute(output_path):
        DirAccess.make_dir_recursive_absolute(output_path)
        print("Created output directory: " + output_path)

# ----- TEST EXECUTION -----
func run_all_tests():
    # First, generate test script files
    _generate_test_scripts()
    
    # Run tests
    var results = {
        "total": test_cases.size(),
        "passed": 0,
        "failed": 0,
        "details": {}
    }
    
    emit_signal("test_started", test_cases.size())
    
    for test_name in test_cases.keys():
        emit_signal("test_case_started", test_name)
        
        var test_result = _run_test(test_name)
        results.details[test_name] = test_result
        
        if test_result.passed:
            results.passed += 1
        else:
            results.failed += 1
        
        emit_signal("test_case_completed", test_name, test_result.passed, test_result)
    
    emit_signal("test_completed", results)
    
    # Print results
    _print_test_results(results)
    
    return results

func _generate_test_scripts():
    # Generate test script files from test cases
    for test_name in test_cases.keys():
        var script_content = test_cases[test_name].input
        var script_path = test_scripts_path.path_join(test_name + ".gd")
        
        var file = FileAccess.open(script_path, FileAccess.WRITE)
        if file:
            file.store_string(script_content)
            file.close()
            
            if verbose_logging:
                print("Generated test script: " + script_path)
        else:
            push_error("Failed to create test script: " + script_path)

func _run_test(test_name):
    var input_path = test_scripts_path.path_join(test_name + ".gd")
    var output_path_file = output_path.path_join(test_name + "_migrated.gd")
    
    if verbose_logging:
        print("Running test: " + test_name)
    
    # Run migration on the test script
    var migration_result = migration_tool.migrate_single_file(input_path, output_path_file)
    
    if not migration_result.success:
        return {
            "passed": false,
            "migration_error": migration_result.error,
            "expected": test_cases[test_name].expected,
            "actual": null
        }
    
    # Read the migrated output
    var file = FileAccess.open(output_path_file, FileAccess.READ)
    if not file:
        return {
            "passed": false,
            "error": "Failed to read migrated output file",
            "expected": test_cases[test_name].expected,
            "actual": null
        }
    
    var actual_output = file.get_as_text()
    file.close()
    
    # Compare with expected output
    var expected_output = test_cases[test_name].expected
    var normalized_expected = _normalize_script(expected_output)
    var normalized_actual = _normalize_script(actual_output)
    
    var passed = normalized_expected == normalized_actual
    
    return {
        "passed": passed,
        "expected": normalized_expected,
        "actual": normalized_actual,
        "warnings": migration_result.warnings,
        "errors": migration_result.errors
    }

func _normalize_script(script_text):
    # Normalize script text for comparison (removes extra whitespace, etc.)
    var lines = script_text.split("\n")
    var normalized_lines = []
    
    for line in lines:
        var trimmed = line.strip_edges()
        if trimmed.length() > 0:
            normalized_lines.append(trimmed)
    
    return "\n".join(normalized_lines)

func _print_test_results(results):
    print("\n----- MIGRATION TEST RESULTS -----")
    print("Total tests: " + str(results.total))
    print("Passed: " + str(results.passed))
    print("Failed: " + str(results.failed))
    print("\nDetailed Results:")
    
    for test_name in results.details.keys():
        var test_result = results.details[test_name]
        var status = "✓ PASSED" if test_result.passed else "✗ FAILED"
        print("\n" + test_name + ": " + status)
        
        if not test_result.passed:
            print("\nExpected:")
            print(test_result.expected)
            print("\nActual:")
            print(test_result.actual)
            
            if test_result.has("migration_error"):
                print("\nMigration Error: " + test_result.migration_error)
        
        if test_result.has("warnings") and test_result.warnings.size() > 0:
            print("\nWarnings:")
            for warning in test_result.warnings:
                print("  - " + warning)
        
        if test_result.has("errors") and test_result.errors.size() > 0:
            print("\nErrors:")
            for error in test_result.errors:
                print("  - " + error)

# ----- ADDITIONAL TEST UTILITIES -----
func create_custom_test_case(name: String, input_script: String, expected_output: String) -> bool:
    # Add a custom test case
    if test_cases.has(name):
        push_error("Test case with name '" + name + "' already exists")
        return false
    
    test_cases[name] = {
        "input": input_script,
        "expected": expected_output
    }
    
    if verbose_logging:
        print("Added custom test case: " + name)
    
    return true

func run_single_test(test_name: String):
    # Run a single named test
    if not test_cases.has(test_name):
        push_error("Test case '" + test_name + "' does not exist")
        return null
    
    _generate_test_scripts()
    
    var test_result = _run_test(test_name)
    
    # Print result
    print("\n----- TEST RESULT: " + test_name + " -----")
    var status = "✓ PASSED" if test_result.passed else "✗ FAILED"
    print("Status: " + status)
    
    if not test_result.passed:
        print("\nExpected:")
        print(test_result.expected)
        print("\nActual:")
        print(test_result.actual)
        
        if test_result.has("migration_error"):
            print("\nMigration Error: " + test_result.migration_error)
    
    return test_result

func test_custom_script(script_content: String) -> Dictionary:
    # Test migration on custom script content without saving to a test case
    
    # Create a temporary file
    var temp_path = test_scripts_path.path_join("temp_test.gd")
    var output_path_file = output_path.path_join("temp_test_migrated.gd")
    
    var file = FileAccess.open(temp_path, FileAccess.WRITE)
    if not file:
        return {
            "success": false,
            "error": "Failed to create temporary test file"
        }
    
    file.store_string(script_content)
    file.close()
    
    # Run migration
    var migration_result = migration_tool.migrate_single_file(temp_path, output_path_file)
    
    if not migration_result.success:
        return {
            "success": false,
            "error": migration_result.error
        }
    
    # Read the migrated output
    file = FileAccess.open(output_path_file, FileAccess.READ)
    if not file:
        return {
            "success": false,
            "error": "Failed to read migrated output file"
        }
    
    var migrated_content = file.get_as_text()
    file.close()
    
    # Clean up temporary file
    var dir = DirAccess.open(test_scripts_path)
    if dir:
        dir.remove("temp_test.gd")
    
    return {
        "success": true,
        "original": script_content,
        "migrated": migrated_content,
        "warnings": migration_result.warnings,
        "errors": migration_result.errors
    }

func generate_test_report(file_path: String = "") -> String:
    # Generate a detailed test report and optionally save to file
    var results = run_all_tests()
    
    var report = "# Godot 4 Migration Test Report\n\n"
    report += "Generated: " + Time.get_datetime_string_from_system() + "\n\n"
    report += "## Summary\n\n"
    report += "- Total Tests: " + str(results.total) + "\n"
    report += "- Passed: " + str(results.passed) + "\n"
    report += "- Failed: " + str(results.failed) + "\n"
    report += "- Success Rate: " + str(float(results.passed) / results.total * 100) + "%\n\n"
    
    report += "## Detailed Results\n\n"
    
    for test_name in results.details.keys():
        var test_result = results.details[test_name]
        var status = "✅ PASSED" if test_result.passed else "❌ FAILED"
        
        report += "### " + test_name + ": " + status + "\n\n"
        
        if not test_result.passed:
            report += "#### Expected Output\n\n```gdscript\n" + test_result.expected + "\n```\n\n"
            report += "#### Actual Output\n\n```gdscript\n" + test_result.actual + "\n```\n\n"
            
            if test_result.has("migration_error"):
                report += "#### Migration Error\n\n" + test_result.migration_error + "\n\n"
        
        if test_result.has("warnings") and test_result.warnings.size() > 0:
            report += "#### Warnings\n\n"
            for warning in test_result.warnings:
                report += "- " + warning + "\n"
            report += "\n"
        
        if test_result.has("errors") and test_result.errors.size() > 0:
            report += "#### Errors\n\n"
            for error in test_result.errors:
                report += "- " + error + "\n"
            report += "\n"
    
    # Save to file if path is provided
    if file_path != "":
        var file = FileAccess.open(file_path, FileAccess.WRITE)
        if file:
            file.store_string(report)
            file.close()
            print("Test report saved to: " + file_path)
        else:
            push_error("Failed to save test report to: " + file_path)
    
    return report

# ----- BATCH TESTING -----
func batch_test_directory(directory_path: String) -> Dictionary:
    # Test all GDScript files in a directory
    var files = _get_all_script_files(directory_path)
    var results = {
        "total_files": files.size(),
        "successful_migrations": 0,
        "failed_migrations": 0,
        "details": {}
    }
    
    for file_path in files:
        var file_name = file_path.get_file()
        var output_path_file = output_path.path_join(file_name.get_basename() + "_migrated.gd")
        
        var migration_result = migration_tool.migrate_single_file(file_path, output_path_file)
        
        if migration_result.success and migration_result.modified:
            results.successful_migrations += 1
        else:
            results.failed_migrations += 1
        
        results.details[file_path] = migration_result
    
    return results

func _get_all_script_files(path: String) -> Array:
    var files = []
    var dir = DirAccess.open(path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            var full_path = path.path_join(file_name)
            
            if dir.current_is_dir() and file_name != "." and file_name != "..":
                # Recursively process subdirectories
                files.append_array(_get_all_script_files(full_path))
            elif file_name.ends_with(".gd"):
                files.append(full_path)
            
            file_name = dir.get_next()
    else:
        push_error("Failed to open directory: " + path)
    
    return files

# ----- ADVANCED TESTING -----
func test_migration_with_color_system():
    # Test the integration between migration and color system
    if not color_system:
        push_error("Color system not found, integration test cannot run")
        return {
            "success": false,
            "error": "Color system not found"
        }
    
    # Run a test that would generate color-coded output when integrated with color system
    var test_results = run_all_tests()
    var nodes_migrated = 0
    var methods_migrated = 0
    var properties_migrated = 0
    
    # Count different types of migrations
    for test_name in test_results.details.keys():
        var test_result = test_results.details[test_name]
        
        if test_name == "node_renames" and test_result.passed:
            nodes_migrated += 1
        elif test_name == "method_renames" and test_result.passed:
            methods_migrated += 1
        elif test_name == "property_renames" and test_result.passed:
            properties_migrated += 1
    
    # In a real implementation, this would call the color system to visualize these statistics
    # For now, we just return the numbers
    return {
        "success": true,
        "nodes_migrated": nodes_migrated,
        "methods_migrated": methods_migrated,
        "properties_migrated": properties_migrated,
        "total_passed": test_results.passed,
        "total_failed": test_results.failed
    }