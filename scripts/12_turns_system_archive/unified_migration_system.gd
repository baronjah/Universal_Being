class_name UnifiedMigrationSystem
extends Node

# ----- SYSTEM COMPONENTS -----
var migration_tool = null
var migration_ui = null
var migration_tester = null
var test_runner = null
var ethereal_bridge = null
var enhanced_launcher = null
var akashic_system = null
var color_system = null

# ----- CONFIGURATION -----
@export_category("Unified Migration Settings")
@export var auto_start: bool = false
@export var godot3_project_path: String = ""
@export var godot4_project_path: String = ""
@export var enable_ethereal_engine_support: bool = true
@export var enable_akashic_integration: bool = true
@export var enable_color_system: bool = true
@export var enable_statistics: bool = true

# ----- PATHS -----
const MIGRATION_TOOL_PATH = "res://12_turns_system/godot4_migration_tool.gd"
const MIGRATION_UI_PATH = "res://12_turns_system/godot4_migration_ui.gd"
const MIGRATION_TESTER_PATH = "res://12_turns_system/godot4_migration_tester.gd"
const TEST_RUNNER_PATH = "res://12_turns_system/godot4_migration_test_runner.gd"
const ETHEREAL_BRIDGE_PATH = "res://12_turns_system/ethereal_migration_bridge.gd"
const ENHANCED_LAUNCHER_PATH = "res://12_turns_system/enhanced_migration_launcher.gd"

# ----- STATISTICS -----
var migration_count: int = 0
var test_run_count: int = 0
var ethereal_migration_count: int = 0
var start_time: int = 0
var migrations_by_version: Dictionary = {}
var test_success_rate: float = 0.0

# ----- SIGNALS -----
signal unified_system_initialized
signal migration_started(type, from_path, to_path)
signal migration_completed(type, stats)
signal test_run_started(type)
signal test_run_completed(type, stats)
signal akashic_numbers_recorded(numbers)
signal color_patterns_detected(patterns)

# ----- INITIALIZATION -----
func _ready():
    start_time = Time.get_unix_time_from_system()
    
    _find_or_create_components()
    _connect_signals()
    
    # Initialize statistics
    migrations_by_version = {
        "3.x_to_4.0": 0,
        "3.x_to_4.5": 0,
        "3.x_to_4.x_ethereal": 0
    }
    
    emit_signal("unified_system_initialized")
    
    print("Unified Migration System initialized")
    
    if auto_start and godot3_project_path != "" and godot4_project_path != "":
        start_migration()

func _find_or_create_components():
    # 1. Find or create the migration tool
    migration_tool = get_node_or_null("/root/Godot4MigrationTool")
    if not migration_tool:
        migration_tool = _find_node_by_class(get_tree().root, "Godot4MigrationTool")
    
    if not migration_tool:
        if ResourceLoader.exists(MIGRATION_TOOL_PATH):
            var script = load(MIGRATION_TOOL_PATH)
            migration_tool = Node.new()
            migration_tool.set_script(script)
            migration_tool.name = "Godot4MigrationTool"
            add_child(migration_tool)
        else:
            migration_tool = Godot4MigrationTool.new()
            add_child(migration_tool)
    
    # 2. Find or create the ethereal bridge
    ethereal_bridge = get_node_or_null("/root/EtherealMigrationBridge")
    if not ethereal_bridge:
        ethereal_bridge = _find_node_by_class(get_tree().root, "EtherealMigrationBridge")
    
    if not ethereal_bridge and enable_ethereal_engine_support:
        if ResourceLoader.exists(ETHEREAL_BRIDGE_PATH):
            var script = load(ETHEREAL_BRIDGE_PATH)
            ethereal_bridge = Node.new()
            ethereal_bridge.set_script(script)
            ethereal_bridge.name = "EtherealMigrationBridge"
            add_child(ethereal_bridge)
        else:
            ethereal_bridge = EtherealMigrationBridge.new()
            add_child(ethereal_bridge)
    
    # 3. Find or create the enhanced launcher
    enhanced_launcher = get_node_or_null("/root/EnhancedMigrationLauncher")
    if not enhanced_launcher:
        enhanced_launcher = _find_node_by_class(get_tree().root, "EnhancedMigrationLauncher")
    
    if not enhanced_launcher:
        if ResourceLoader.exists(ENHANCED_LAUNCHER_PATH):
            var script = load(ENHANCED_LAUNCHER_PATH)
            enhanced_launcher = Node.new()
            enhanced_launcher.set_script(script)
            enhanced_launcher.name = "EnhancedMigrationLauncher"
            add_child(enhanced_launcher)
        else:
            enhanced_launcher = EnhancedMigrationLauncher.new()
            enhanced_launcher.default_godot3_path = godot3_project_path
            enhanced_launcher.default_godot4_path = godot4_project_path
            add_child(enhanced_launcher)
    
    # 4. Find supporting systems
    akashic_system = get_node_or_null("/root/AkashicNumberSystem")
    if not akashic_system:
        akashic_system = _find_node_by_class(get_tree().root, "AkashicNumberSystem")
    
    color_system = get_node_or_null("/root/DimensionalColorSystem")
    if not color_system:
        color_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
    
    print("Components found: Migration Tool: %s, Ethereal Bridge: %s, Enhanced Launcher: %s" % [
        "Yes" if migration_tool else "No",
        "Yes" if ethereal_bridge else "No",
        "Yes" if enhanced_launcher else "No"
    ])
    
    print("Support systems found: Akashic System: %s, Color System: %s" % [
        "Yes" if akashic_system else "No",
        "Yes" if color_system else "No"
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
    
    # Connect ethereal bridge signals
    if ethereal_bridge:
        ethereal_bridge.ethereal_migration_started.connect(_on_ethereal_migration_started)
        ethereal_bridge.ethereal_migration_completed.connect(_on_ethereal_migration_completed)
        ethereal_bridge.reality_transition_migrated.connect(_on_reality_transition_migrated)
        ethereal_bridge.word_manifestation_migrated.connect(_on_word_manifestation_migrated)
    
    # Connect enhanced launcher signals
    if enhanced_launcher:
        enhanced_launcher.launcher_initialized.connect(_on_launcher_initialized)
        enhanced_launcher.migration_completed.connect(_on_launcher_migration_completed)
        enhanced_launcher.test_run_completed.connect(_on_launcher_test_completed)

# ----- SIGNAL HANDLERS -----
func _on_migration_started(total_files):
    print("Migration started with " + str(total_files) + " files")
    emit_signal("migration_started", "standard", godot3_project_path, godot4_project_path)

func _on_migration_completed(stats):
    print("Migration completed - Files processed: " + str(stats.files_processed) + 
          ", Modified: " + str(stats.files_modified))
    
    migration_count += 1
    migrations_by_version["3.x_to_4.5"] += 1
    
    _record_migration_stats(stats)
    
    emit_signal("migration_completed", "standard", stats)

func _on_ethereal_migration_started(records_count):
    print("Ethereal migration started with " + str(records_count) + " records")
    emit_signal("migration_started", "ethereal", godot3_project_path, godot4_project_path)

func _on_ethereal_migration_completed(stats):
    print("Ethereal migration completed - Ethereal nodes: " + str(stats.ethereal_nodes_migrated) + 
          ", Reality contexts: " + str(stats.reality_contexts_migrated) + 
          ", Word manifestations: " + str(stats.word_manifestations_migrated))
    
    ethereal_migration_count += 1
    migrations_by_version["3.x_to_4.x_ethereal"] += 1
    
    _record_ethereal_migration_stats(stats)
    
    emit_signal("migration_completed", "ethereal", stats)

func _on_reality_transition_migrated(reality_type):
    print("Reality transition migrated: " + reality_type)
    
    if enable_akashic_integration and akashic_system and akashic_system.has_method("register_number"):
        var reality_hash = reality_type.hash()
        akashic_system.register_number(reality_hash, "migrated_reality_" + reality_type)

func _on_word_manifestation_migrated(word, position):
    print("Word manifestation migrated: " + word + " at " + str(position))
    
    if enable_color_system and color_system and color_system.has_method("visualize_word"):
        color_system.visualize_word(word, position)

func _on_launcher_initialized():
    print("Enhanced launcher initialized")

func _on_launcher_migration_completed(stats):
    print("Launcher migration completed")
    
    _record_migration_stats(stats)

func _on_launcher_test_completed(results):
    print("Test run completed - Total tests: " + str(results.total) + 
          ", Passed: " + str(results.passed) + 
          ", Failed: " + str(results.failed))
    
    test_run_count += 1
    
    if results.total > 0:
        test_success_rate = float(results.passed) / results.total
    
    _record_test_stats(results)
    
    emit_signal("test_run_completed", "standard", results)

# ----- STATISTICS RECORDING -----
func _record_migration_stats(stats):
    if not enable_statistics:
        return
    
    # Record in akashic system
    if enable_akashic_integration and akashic_system and akashic_system.has_method("register_number"):
        var migration_numbers = {
            "timestamp": Time.get_unix_time_from_system(),
            "files_processed": stats.files_processed,
            "files_modified": stats.files_modified,
            "errors": stats.errors_encountered if stats.has("errors_encountered") else 0,
            "warnings": stats.warnings_generated if stats.has("warnings_generated") else 0
        }
        
        akashic_system.register_number(migration_numbers.timestamp, "migration_timestamp")
        akashic_system.register_number(migration_numbers.files_processed, "files_processed")
        akashic_system.register_number(migration_numbers.files_modified, "files_modified")
        
        emit_signal("akashic_numbers_recorded", migration_numbers)
    
    # Update color system
    if enable_color_system and color_system and color_system.has_method("visualize_data"):
        var success_rate = 0.0
        if stats.files_processed > 0:
            success_rate = float(stats.files_modified) / stats.files_processed
        
        color_system.visualize_data("migration_success", success_rate)
        
        if stats.has("errors_encountered") and stats.errors_encountered > 0:
            color_system.visualize_data("migration_errors", stats.errors_encountered)

func _record_ethereal_migration_stats(stats):
    if not enable_statistics:
        return
    
    # Record in akashic system
    if enable_akashic_integration and akashic_system and akashic_system.has_method("register_number"):
        var ethereal_numbers = {
            "timestamp": Time.get_unix_time_from_system(),
            "ethereal_nodes": stats.ethereal_nodes_migrated,
            "reality_contexts": stats.reality_contexts_migrated,
            "word_manifestations": stats.word_manifestations_migrated,
            "datapoints": stats.datapoints_migrated,
            "records": stats.records_migrated
        }
        
        akashic_system.register_number(ethereal_numbers.timestamp, "ethereal_migration_timestamp")
        akashic_system.register_number(ethereal_numbers.ethereal_nodes, "ethereal_nodes_migrated")
        akashic_system.register_number(ethereal_numbers.reality_contexts, "reality_contexts_migrated")
        akashic_system.register_number(ethereal_numbers.word_manifestations, "word_manifestations_migrated")
        
        emit_signal("akashic_numbers_recorded", ethereal_numbers)
    
    # Update color system
    if enable_color_system and color_system and color_system.has_method("visualize_data"):
        color_system.visualize_data("ethereal_nodes", stats.ethereal_nodes_migrated)
        color_system.visualize_data("reality_contexts", stats.reality_contexts_migrated)
        color_system.visualize_data("word_manifestations", stats.word_manifestations_migrated)

func _record_test_stats(stats):
    if not enable_statistics:
        return
    
    # Record in akashic system
    if enable_akashic_integration and akashic_system and akashic_system.has_method("register_number"):
        var test_numbers = {
            "timestamp": Time.get_unix_time_from_system(),
            "total_tests": stats.total,
            "passed_tests": stats.passed,
            "failed_tests": stats.failed
        }
        
        akashic_system.register_number(test_numbers.timestamp, "test_run_timestamp")
        akashic_system.register_number(test_numbers.total_tests, "total_tests_run")
        akashic_system.register_number(test_numbers.passed_tests, "passed_tests")
        
        emit_signal("akashic_numbers_recorded", test_numbers)
    
    # Update color system
    if enable_color_system and color_system and color_system.has_method("visualize_data"):
        var success_rate = 0.0
        if stats.total > 0:
            success_rate = float(stats.passed) / stats.total
        
        color_system.visualize_data("test_success_rate", success_rate)
        
        if stats.failed > 0:
            color_system.visualize_data("test_failures", stats.failed)

# ----- MAIN FUNCTIONS -----
func start_migration() -> Dictionary:
    if not migration_tool:
        return {
            "success": false,
            "error": "Migration tool not initialized"
        }
    
    if godot3_project_path == "" or godot4_project_path == "":
        return {
            "success": false,
            "error": "Project paths not specified"
        }
    
    var result = null
    
    # Check if it's an Ethereal Engine project
    if enable_ethereal_engine_support and ethereal_bridge and _is_ethereal_engine_project(godot3_project_path):
        print("Detected JSH Ethereal Engine project, using specialized migration")
        result = ethereal_bridge.migrate_jsh_ethereal_project(godot3_project_path, godot4_project_path)
    else:
        # Standard migration
        result = migration_tool.migrate_project(godot3_project_path, godot4_project_path)
    
    return result

func run_all_tests() -> Dictionary:
    if enhanced_launcher:
        return enhanced_launcher.run_all_tests()
    elif migration_tester:
        return migration_tester.run_all_tests()
    else:
        return {
            "success": false,
            "error": "Test components not initialized"
        }

func start_ui() -> Node:
    if enhanced_launcher:
        return enhanced_launcher.start_migration_ui()
    else:
        return null

func generate_compatibility_report(project_path: String = "") -> Dictionary:
    var target_path = project_path if project_path != "" else godot3_project_path
    
    if target_path == "":
        return {
            "success": false,
            "error": "Project path not specified"
        }
    
    if enable_ethereal_engine_support and ethereal_bridge and _is_ethereal_engine_project(target_path):
        return ethereal_bridge.generate_ethereal_migration_report(target_path)
    elif migration_tool:
        return migration_tool.generate_migration_report(target_path)
    else:
        return {
            "success": false,
            "error": "Migration components not initialized"
        }

func get_statistics() -> Dictionary:
    var runtime = Time.get_unix_time_from_system() - start_time
    
    return {
        "migration_count": migration_count,
        "ethereal_migration_count": ethereal_migration_count,
        "test_run_count": test_run_count,
        "migrations_by_version": migrations_by_version,
        "test_success_rate": test_success_rate,
        "runtime_seconds": runtime,
        "akashic_integration": enable_akashic_integration && akashic_system != null,
        "color_system_integration": enable_color_system && color_system != null
    }

func set_project_paths(godot3_path: String, godot4_path: String) -> void:
    godot3_project_path = godot3_path
    godot4_project_path = godot4_path
    
    if enhanced_launcher:
        enhanced_launcher.default_godot3_path = godot3_path
        enhanced_launcher.default_godot4_path = godot4_path

# ----- HELPER FUNCTIONS -----
func _is_ethereal_engine_project(project_path: String) -> bool:
    # Check for key files that indicate JSH Ethereal Engine
    var indicators = [
        "/CORE/eden_core.gd",
        "/JSH_records_system.gd",
        "/BanksCombiner.gd",
        "/scripts/reality_transition.gd",
        "/word_manifestation.gd"
    ]
    
    for indicator in indicators:
        if FileAccess.file_exists(project_path + indicator):
            return true
    
    # Scan key directories for JSH patterns
    var potential_dirs = [
        "/scripts",
        "/CORE",
        "/code",
        "/scenes"
    ]
    
    for dir_path in potential_dirs:
        var full_path = project_path + dir_path
        if not DirAccess.dir_exists_absolute(full_path):
            continue
        
        var script_files = _get_script_files_in_dir(full_path)
        for file_path in script_files:
            var compatibility = ethereal_bridge.check_ethereal_compatibility(file_path)
            if compatibility.is_ethereal and compatibility.ethereal_patterns >= 2:
                return true
    
    return false

func _get_script_files_in_dir(dir_path: String, max_count: int = 10) -> Array:
    var files = []
    var dir = DirAccess.open(dir_path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "" and files.size() < max_count:
            var full_path = dir_path.path_join(file_name)
            
            if file_name.ends_with(".gd"):
                files.append(full_path)
            
            file_name = dir.get_next()
    
    return files