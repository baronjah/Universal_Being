class_name EnhancedMigrationLauncher
extends Node

# ----- COMPONENT REFERENCES -----
var migration_tool = null
var migration_ui = null
var migration_tester = null
var test_runner = null
var color_system = null
var akashic_system = null

# ----- CONFIGURATION -----
@export_category("Migration Settings")
@export var auto_start_ui: bool = true
@export var default_godot3_path: String = ""
@export var default_godot4_path: String = ""
@export var enable_color_integration: bool = true
@export var enable_test_runner: bool = true

# ----- SCENES -----
const MIGRATION_UI_SCENE = "res://12_turns_system/godot4_migration_ui.tscn"
const TEST_RUNNER_SCENE = "res://12_turns_system/godot4_migration_test_runner.tscn"

# ----- STATISTICS -----
var migrations_performed: int = 0
var test_runs_performed: int = 0
var last_migration_stats: Dictionary = {}
var last_test_stats: Dictionary = {}

# ----- SIGNALS -----
signal launcher_initialized()
signal ui_started(ui_instance)
signal test_runner_started(runner_instance)
signal migration_started(from_path, to_path)
signal migration_completed(results)
signal test_run_started()
signal test_run_completed(results)

# ----- INITIALIZATION -----
func _ready():
    _find_or_create_components()
    _connect_signals()
    
    print("Enhanced Migration Launcher initialized")
    
    emit_signal("launcher_initialized")
    
    if auto_start_ui:
        start_migration_ui()
        
    if enable_test_runner:
        start_test_runner()

func _find_or_create_components():
    # Find or create the migration tool
    migration_tool = get_node_or_null("/root/Godot4MigrationTool")
    if not migration_tool:
        migration_tool = _find_node_by_class(get_tree().root, "Godot4MigrationTool")
    
    if not migration_tool:
        migration_tool = Godot4MigrationTool.new()
        add_child(migration_tool)
    
    # Find or create the migration tester
    migration_tester = get_node_or_null("/root/Godot4MigrationTester")
    if not migration_tester:
        migration_tester = _find_node_by_class(get_tree().root, "Godot4MigrationTester")
    
    if not migration_tester:
        migration_tester = Godot4MigrationTester.new()
        add_child(migration_tester)
    
    # Find color system
    color_system = get_node_or_null("/root/DimensionalColorSystem")
    if not color_system:
        color_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
    
    # Find akashic system
    akashic_system = get_node_or_null("/root/AkashicNumberSystem")
    if not akashic_system:
        akashic_system = _find_node_by_class(get_tree().root, "AkashicNumberSystem")
    
    print("Components found - Migration Tool: %s, Migration Tester: %s, Color System: %s, Akashic System: %s" % [
        "Yes" if migration_tool else "No",
        "Yes" if migration_tester else "No",
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

func _connect_signals():
    # Connect migration tool signals
    if migration_tool:
        migration_tool.migration_started.connect(_on_migration_started)
        migration_tool.migration_completed.connect(_on_migration_completed)
    
    # Connect migration tester signals
    if migration_tester:
        migration_tester.test_started.connect(_on_test_started)
        migration_tester.test_completed.connect(_on_test_completed)

# ----- SIGNAL HANDLERS -----
func _on_migration_started(total_files):
    print("Migration started with " + str(total_files) + " files")

func _on_migration_completed(stats):
    migrations_performed += 1
    last_migration_stats = stats
    
    print("Migration completed - Files processed: " + str(stats.files_processed) + 
          ", Modified: " + str(stats.files_modified) + 
          ", Errors: " + str(stats.errors_encountered) + 
          ", Warnings: " + str(stats.warnings_generated))
    
    emit_signal("migration_completed", stats)
    
    # Integrate with color system
    if enable_color_integration and color_system:
        _update_color_system_with_migration_stats(stats)

func _on_test_started(total_tests):
    test_runs_performed += 1
    print("Test run started with " + str(total_tests) + " tests")
    
    emit_signal("test_run_started")

func _on_test_completed(results):
    last_test_stats = results
    
    print("Test run completed - Total tests: " + str(results.total) + 
          ", Passed: " + str(results.passed) + 
          ", Failed: " + str(results.failed))
    
    emit_signal("test_run_completed", results)
    
    # Integrate with color system
    if enable_color_integration and color_system:
        _update_color_system_with_test_stats(results)

# ----- UI MANAGEMENT -----
func start_migration_ui():
    # Check if UI is already instantiated
    if is_instance_valid(migration_ui):
        print("Migration UI is already running")
        return migration_ui
    
    # Try to load the UI scene
    var ui_scene = load(MIGRATION_UI_SCENE)
    if not ui_scene:
        push_error("Failed to load migration UI scene: " + MIGRATION_UI_SCENE)
        return null
    
    # Instantiate the UI
    migration_ui = ui_scene.instantiate()
    add_child(migration_ui)
    
    # Set default paths if provided
    if migration_ui.has_method("_set_default_paths") and default_godot3_path != "" and default_godot4_path != "":
        migration_ui._set_default_paths(default_godot3_path, default_godot4_path)
    
    print("Migration UI started")
    emit_signal("ui_started", migration_ui)
    
    return migration_ui

func start_test_runner():
    # Check if test runner is already instantiated
    if is_instance_valid(test_runner):
        print("Test runner is already running")
        return test_runner
    
    # Try to load the test runner scene
    var runner_scene = load(TEST_RUNNER_SCENE)
    if not runner_scene:
        push_error("Failed to load test runner scene: " + TEST_RUNNER_SCENE)
        return null
    
    # Instantiate the test runner
    test_runner = runner_scene.instantiate()
    add_child(test_runner)
    
    # Integrate with color system if enabled
    if enable_color_integration and color_system and test_runner.has_method("integrate_with_color_system"):
        test_runner.integrate_with_color_system()
    
    print("Test runner started")
    emit_signal("test_runner_started", test_runner)
    
    return test_runner

# ----- COLOR SYSTEM INTEGRATION -----
func _update_color_system_with_migration_stats(stats):
    if not color_system:
        return
    
    # In a real implementation, this would call methods on the color system
    # to visualize the migration statistics with colors
    
    # Calculate migration success rate
    var success_rate = 0.0
    if stats.files_processed > 0:
        success_rate = float(stats.files_modified) / stats.files_processed
    
    # Example color system integration
    # color_system.visualize_data_point("migration_success", success_rate, Color(0, 1, 0))
    # color_system.visualize_data_point("migration_errors", stats.errors_encountered, Color(1, 0, 0))
    
    print("Migration stats integrated with color system")

func _update_color_system_with_test_stats(results):
    if not color_system:
        return
    
    # In a real implementation, this would call methods on the color system
    # to visualize the test statistics with colors
    
    # Calculate test success rate
    var success_rate = 0.0
    if results.total > 0:
        success_rate = float(results.passed) / results.total
    
    # Example color system integration
    # color_system.visualize_data_point("test_success", success_rate, Color(0, 1, 0))
    # color_system.visualize_data_point("test_failures", results.failed, Color(1, 0, 0))
    
    print("Test stats integrated with color system")

# ----- AKASHIC SYSTEM INTEGRATION -----
func update_akashic_system_with_stats():
    if not akashic_system:
        return
    
    # In a real implementation, this would update the akashic system with
    # statistics about the migrations and tests
    
    # Example akashic system integration
    # akashic_system.record_event("migration", migrations_performed)
    # akashic_system.record_event("test_run", test_runs_performed)
    
    print("Statistics recorded in akashic system")

# ----- MAIN API -----
func migrate_project(from_path: String, to_path: String) -> Dictionary:
    if not migration_tool:
        return {
            "success": false,
            "error": "Migration tool not initialized"
        }
    
    emit_signal("migration_started", from_path, to_path)
    
    return migration_tool.migrate_project(from_path, to_path)

func run_all_tests() -> Dictionary:
    if not migration_tester:
        return {
            "success": false,
            "error": "Migration tester not initialized"
        }
    
    return migration_tester.run_all_tests()

func generate_compatibility_report(project_path: String) -> Dictionary:
    if not migration_tool:
        return {
            "success": false,
            "error": "Migration tool not initialized"
        }
    
    return migration_tool.generate_migration_report(project_path)

func get_migration_statistics() -> Dictionary:
    return {
        "migrations_performed": migrations_performed,
        "test_runs_performed": test_runs_performed,
        "last_migration_stats": last_migration_stats,
        "last_test_stats": last_test_stats
    }

# ----- LAUNCHER SCENE -----
func create_launcher_scene() -> Window:
    # Create a simple launcher window that can start the UI and test runner
    var window = Window.new()
    window.title = "Godot 4 Migration Launcher"
    window.size = Vector2i(500, 300)
    
    # Create UI
    var vbox = VBoxContainer.new()
    vbox.set_anchors_preset(PRESET_FULL_RECT)
    window.add_child(vbox)
    
    # Title
    var title_label = Label.new()
    title_label.text = "Godot 4 Migration Toolkit"
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title_label)
    
    # Paths
    var paths_section = VBoxContainer.new()
    vbox.add_child(paths_section)
    
    var paths_label = Label.new()
    paths_label.text = "Project Paths"
    paths_section.add_child(paths_label)
    
    # Godot 3 path
    var godot3_hbox = HBoxContainer.new()
    paths_section.add_child(godot3_hbox)
    
    var godot3_label = Label.new()
    godot3_label.text = "Godot 3 Project:"
    godot3_hbox.add_child(godot3_label)
    
    var godot3_path_input = LineEdit.new()
    godot3_path_input.size_flags_horizontal = SIZE_EXPAND_FILL
    godot3_path_input.text = default_godot3_path
    godot3_hbox.add_child(godot3_path_input)
    
    # Godot 4 path
    var godot4_hbox = HBoxContainer.new()
    paths_section.add_child(godot4_hbox)
    
    var godot4_label = Label.new()
    godot4_label.text = "Godot 4 Project:"
    godot4_hbox.add_child(godot4_label)
    
    var godot4_path_input = LineEdit.new()
    godot4_path_input.size_flags_horizontal = SIZE_EXPAND_FILL
    godot4_path_input.text = default_godot4_path
    godot4_hbox.add_child(godot4_path_input)
    
    # Buttons
    var buttons_hbox = HBoxContainer.new()
    buttons_hbox.size_flags_horizontal = SIZE_EXPAND_FILL
    buttons_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    vbox.add_child(buttons_hbox)
    
    var ui_button = Button.new()
    ui_button.text = "Start Migration UI"
    ui_button.pressed.connect(func(): 
        default_godot3_path = godot3_path_input.text
        default_godot4_path = godot4_path_input.text
        start_migration_ui()
    )
    buttons_hbox.add_child(ui_button)
    
    var test_button = Button.new()
    test_button.text = "Start Test Runner"
    test_button.pressed.connect(start_test_runner)
    buttons_hbox.add_child(test_button)
    
    # Statistics
    var stats_section = VBoxContainer.new()
    vbox.add_child(stats_section)
    
    var stats_label = Label.new()
    stats_label.text = "Statistics"
    stats_section.add_child(stats_label)
    
    var migrations_label = Label.new()
    migrations_label.text = "Migrations Performed: " + str(migrations_performed)
    stats_section.add_child(migrations_label)
    
    var tests_label = Label.new()
    tests_label.text = "Test Runs Performed: " + str(test_runs_performed)
    stats_section.add_child(tests_label)
    
    # Update statistics periodically
    var timer = Timer.new()
    window.add_child(timer)
    timer.timeout.connect(func():
        migrations_label.text = "Migrations Performed: " + str(migrations_performed)
        tests_label.text = "Test Runs Performed: " + str(test_runs_performed)
    )
    timer.wait_time = 1.0
    timer.start()
    
    add_child(window)
    window.show()
    
    return window