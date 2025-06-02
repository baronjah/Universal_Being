# ==================================================
# UNIVERSAL BEING: ConsoleTextLayer
# TYPE: UI Component
# PURPOSE: Console interface for Universal Being system
# COMPONENTS: None (base component)
# SCENES: console_text_layer.tscn
# ==================================================

extends UniversalBeing
class_name ConsoleTextLayerUniversalBeing

const PackageSystemTest = preload("res://tests/complete_package_system_test.gd")

# ===== BEING-SPECIFIC PROPERTIES =====
@export var max_lines: int = 100
@export var command_prefix: String = ">"
@export var history_size: int = 50

# ===== INTERNAL STATE =====
var _console_node: RichTextLabel = null
var _input_node: LineEdit = null
var _command_history: Array[String] = []
var _history_index: int = -1
var _current_input: String = ""
var _active_scenes: Dictionary = {}  # Track loaded scenes

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    # Set Universal Being identity
    being_type = "ui_component"
    being_name = "ConsoleTextLayer"
    consciousness_level = 3  # High consciousness for AI accessibility
    
    print("💻 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Load console scene
    load_scene("res://beings/console_text_layer.tscn")
    
    # Get console nodes
    _console_node = get_scene_node("ConsoleOutput")
    _input_node = get_scene_node("CommandInput")
    
    if _console_node and _input_node:
        _setup_console()
    else:
        push_error("Console nodes not found in scene")
    
    print("💻 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    # No continuous processing needed

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    if not _input_node:
        return
    
    if event is InputEventKey:
        if event.pressed:
            match event.keycode:
                KEY_UP:
                    _navigate_history(-1)
                KEY_DOWN:
                    _navigate_history(1)
                KEY_ENTER:
                    _execute_command(_input_node.text)
                KEY_ESCAPE:
                    _clear_input()

func pentagon_sewers() -> void:
    # Cleanup console resources
    if _console_node:
        _console_node.queue_free()
        _console_node = null
    
    if _input_node:
        _input_node.queue_free()
        _input_node = null
    
    _command_history.clear()
    
    super.pentagon_sewers()
    print("💻 %s: Pentagon Sewers Complete" % being_name)

# ===== CONSOLE SETUP =====

func _setup_console() -> void:
    """Initialize console properties and connections"""
    _console_node.clear()
    _console_node.max_lines = max_lines
    
    _input_node.text = ""
    _input_node.placeholder_text = "Enter command..."
    _input_node.text_submitted.connect(_on_command_submitted)
    
    # Print welcome message
    print_console("Universal Being Console")
    print_console("Type 'help' for available commands")
    print_console("")

# ===== COMMAND HANDLING =====

func _execute_command(command: String) -> void:
    """Execute a console command"""
    if command.is_empty():
        return
    
    # Add to history
    _add_to_history(command)
    
    # Print command
    print_console("%s %s" % [command_prefix, command])
    
    # Parse and execute
    var parts = command.split(" ", false)
    var cmd = parts[0].to_lower()
    var args = parts.slice(1)
    
    match cmd:
        "help":
            _cmd_help(args)
        "clear":
            _cmd_clear(args)
        "package":
            _cmd_package(args)
        "scene":
            _cmd_scene(args)
        "validate":
            _cmd_validate(args)
        "memory":
            _cmd_memory(args)
        "test":
            _cmd_test(args)
        _:
            print_console("Unknown command: %s" % cmd)
            print_console("Type 'help' for available commands")

func _cmd_help(args: Array) -> void:
    """Show help information"""
    print_console("\nAvailable commands:")
    print_console("  help                    - Show this help")
    print_console("  clear                   - Clear console")
    print_console("  package <subcommand>    - Package management")
    print_console("    list                  - List available packages")
    print_console("    load <path>          - Load a package")
    print_console("    unload <id>          - Unload a package")
    print_console("    info <id>            - Show package info")
    print_console("  scene <subcommand>      - Scene management")
    print_console("    load <path> [level]  - Load scene with consciousness level")
    print_console("    unload <id>          - Unload a scene")
    print_console("    list                 - List active scenes")
    print_console("    info <id>            - Show scene info")
    print_console("  validate <path>         - Validate a package")
    print_console("  memory                  - Show memory usage")
    print_console("  test <package>          - Run package tests")
    print_console("")

func _cmd_clear(args: Array) -> void:
    """Clear console output"""
    _console_node.clear()
    print_console("Console cleared")

func _cmd_package(args: Array) -> void:
    """Handle package management commands"""
    if args.is_empty():
        print_console("Usage: package <subcommand>")
        return
    
    var subcmd = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcmd:
        "list":
            _cmd_package_list(subargs)
        "load":
            _cmd_package_load(subargs)
        "unload":
            _cmd_package_unload(subargs)
        "info":
            _cmd_package_info(subargs)
        _:
            print_console("Unknown package command: %s" % subcmd)

func _cmd_package_list(args: Array) -> void:
    """List available packages"""
    var zip_manager = SystemBootstrap.get_zip_manager() if SystemBootstrap else null
    if not zip_manager:
        print_console("Error: ZipPackageManager not available")
        return
    
    var packages = zip_manager.get_active_packages()
    if packages.is_empty():
        print_console("No packages loaded")
        return
    
    print_console("\nLoaded packages:")
    for package_id in packages:
        var package = packages[package_id]
        print_console("  %s:" % package_id)
        print_console("    Path: %s" % package.path)
        print_console("    Memory: %.1f MB" % (package.memory_usage / (1024.0 * 1024.0)))
        print_console("    Last access: %s" % Time.get_datetime_string_from_unix_time(package.last_access))

func _cmd_package_load(args: Array) -> void:
    """Load a package"""
    if args.is_empty():
        print_console("Usage: package load <path>")
        return
    
    var package_path = args[0]
    var zip_manager = SystemBootstrap.get_zip_manager() if SystemBootstrap else null
    if not zip_manager:
        print_console("Error: ZipPackageManager not available")
        return
    
    print_console("Loading package: %s" % package_path)
    var success = await zip_manager.load_full_package(package_path)
    
    if success:
        print_console("Package loaded successfully")
    else:
        print_console("Error: Failed to load package")

func _cmd_package_unload(args: Array) -> void:
    """Unload a package"""
    if args.is_empty():
        print_console("Usage: package unload <id>")
        return
    
    var package_id = args[0]
    var zip_manager = SystemBootstrap.get_zip_manager() if SystemBootstrap else null
    if not zip_manager:
        print_console("Error: ZipPackageManager not available")
        return
    
    print_console("Unloading package: %s" % package_id)
    var success = zip_manager.unload_package(package_id)
    
    if success:
        print_console("Package unloaded successfully")
    else:
        print_console("Error: Failed to unload package")

func _cmd_package_info(args: Array) -> void:
    """Show package information"""
    if args.is_empty():
        print_console("Usage: package info <id>")
        return
    
    var package_id = args[0]
    var zip_manager = SystemBootstrap.get_zip_manager() if SystemBootstrap else null
    if not zip_manager:
        print_console("Error: ZipPackageManager not available")
        return
    
    var package = zip_manager.get_package_info(package_id)
    if not package:
        print_console("Error: Package not found")
        return
    
    print_console("\nPackage info for %s:" % package_id)
    print_console("  Path: %s" % package.path)
    print_console("  Memory usage: %.1f MB" % (package.memory_usage / (1024.0 * 1024.0)))
    print_console("  Last access: %s" % Time.get_datetime_string_from_unix_time(package.last_access))
    print_console("  Files: %d" % package.files.size())
    print_console("  Cache items: %d" % package.cache_items.size())

func _cmd_validate(args: Array) -> void:
    """Validate a package"""
    if args.is_empty():
        print_console("Usage: validate <path>")
        return
    
    var package_path = args[0]
    var akashic_loader = SystemBootstrap.get_akashic_loader() if SystemBootstrap else null
    if not akashic_loader:
        print_console("Error: AkashicLoader not available")
        return
    
    print_console("Validating package: %s" % package_path)
    
    # Connect to validation signals
    var validation_complete = false
    var validation_results = {}
    
    var progress_handler = func(pkg_id: String, stage: String, progress: float) -> void:
        if pkg_id == package_path:
            print_console("  %s: %.0f%%" % [stage, progress * 100])
    
    var result_handler = func(pkg_id: String, results: Dictionary) -> void:
        if pkg_id == package_path:
            validation_complete = true
            validation_results = results
    
    akashic_loader.validation_progress.connect(progress_handler)
    akashic_loader.package_validated.connect(result_handler)
    
    # Start validation
    akashic_loader.validate_package(package_path)
    
    # Wait for validation (with timeout)
    var timeout = 10.0  # 10 seconds
    var start_time = Time.get_ticks_msec()
    while not validation_complete and (Time.get_ticks_msec() - start_time) < timeout * 1000:
        await get_tree().process_frame
    
    # Disconnect handlers
    akashic_loader.validation_progress.disconnect(progress_handler)
    akashic_loader.package_validated.disconnect(result_handler)
    
    if not validation_complete:
        print_console("Error: Validation timed out")
        return
    
    # Print results
    print_console("\nValidation results:")
    print_console("  Valid: %s" % ("Yes" if validation_results.get("valid", false) else "No"))
    
    if not validation_results.get("valid", false):
        print_console("\nErrors:")
        for stage in ["manifest", "compatibility", "performance", "memory"]:
            var stage_results = validation_results.get(stage, {})
            if not stage_results.get("valid", true):
                for error in stage_results.get("errors", []):
                    print_console("  %s: %s" % [stage, error])
    
    # Print metrics
    var metrics = {}
    for stage in ["manifest", "compatibility", "performance", "memory"]:
        var stage_results = validation_results.get(stage, {})
        if stage_results.has("metrics"):
            metrics[stage] = stage_results.metrics
    
    if not metrics.is_empty():
        print_console("\nMetrics:")
        for stage in metrics:
            print_console("  %s:" % stage)
            for key in metrics[stage]:
                print_console("    %s: %s" % [key, metrics[stage][key]])

func _cmd_memory(args: Array) -> void:
    """Show memory usage"""
    var akashic_loader = SystemBootstrap.get_akashic_loader() if SystemBootstrap else null
    if not akashic_loader:
        print_console("Error: AkashicLoader not available")
        return
    
    var metrics = akashic_loader.get_memory_metrics()
    
    print_console("\nMemory usage:")
    print_console("  Active memory: %.1f MB" % metrics.active_memory_mb)
    print_console("  Cache memory: %.1f MB" % metrics.cache_memory_mb)
    print_console("  Total memory: %.1f MB" % metrics.total_memory_mb)
    print_console("  Active packages: %d" % metrics.active_packages)
    print_console("  Cached assets: %d" % metrics.cached_assets)

func _cmd_test(args: Array) -> void:
    """Run package tests"""
    if args.is_empty():
        print_console("Usage: test <package>")
        return
    
    var package_path = args[0]
    
    # Create test being
    var test_being = PackageSystemTest.new()
    add_child(test_being)
    
    # Connect to test signals
    var test_complete = false
    var test_results = {}
    
    var test_handler = func(test_name: String, passed: bool, details: Dictionary) -> void:
        print_console("\nTest: %s" % test_name)
        print_console("  Status: %s" % ("PASSED" if passed else "FAILED"))
        print_console("  Duration: %.1f ms" % details.duration_ms)
        if not passed:
            print_console("  Error: %s" % details.error)
        print_console("  Metrics: %s" % details.metrics)
    
    var complete_handler = func(results: Dictionary) -> void:
        test_complete = true
        test_results = results
        
        print_console("\nTest summary:")
        var total = results.size()
        var passed = 0
        var total_duration = 0.0
        
        for test_name in results:
            if results[test_name].passed:
                passed += 1
            total_duration += results[test_name].details.duration_ms
        
        print_console("  Total tests: %d" % total)
        print_console("  Passed: %d" % passed)
        print_console("  Failed: %d" % (total - passed))
        print_console("  Total duration: %.1f ms" % total_duration)
    
    test_being.test_completed.connect(test_handler)
    test_being.all_tests_completed.connect(complete_handler)
    
    # Run tests
    print_console("Running tests for package: %s" % package_path)
    test_being.run_all_tests()
    
    # Wait for completion
    while not test_complete:
        await get_tree().process_frame
    
    # Cleanup
    test_being.test_completed.disconnect(test_handler)
    test_being.all_tests_completed.disconnect(complete_handler)
    test_being.queue_free()

# ===== SCENE COMMANDS =====

func _cmd_scene(args: Array) -> void:
    """Handle scene commands"""
    if args.is_empty():
        print_console("Usage: scene <subcommand>")
        print_console("Subcommands: load, unload, list, info")
        return
    
    var subcmd = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcmd:
        "load":
            _cmd_scene_load(subargs)
        "unload":
            _cmd_scene_unload(subargs)
        "list":
            _cmd_scene_list(subargs)
        "info":
            _cmd_scene_info(subargs)
        _:
            print_console("Unknown scene command: %s" % subcmd)

func _cmd_scene_load(args: Array) -> void:
    """Load a scene with optional consciousness level"""
    if args.is_empty():
        print_console("Usage: scene load <path> [consciousness_level]")
        return
    
    var scene_path = args[0]
    var consciousness_level = 1
    
    if args.size() > 1:
        consciousness_level = int(args[1])
        if consciousness_level < 0 or consciousness_level > 7:
            print_console("Error: Consciousness level must be 0-7")
            return
    
    print_console("Loading scene: %s (consciousness level %d)" % [scene_path, consciousness_level])
    
    # Try to load the scene
    var scene_resource = load(scene_path)
    if not scene_resource:
        print_console("Error: Could not load scene: %s" % scene_path)
        return
    
    var scene_instance = scene_resource.instantiate()
    if not scene_instance:
        print_console("Error: Could not instantiate scene")
        return
    
    # Set consciousness level if it's a Universal Being
    if scene_instance.has_method("set_consciousness_level"):
        scene_instance.set_consciousness_level(consciousness_level)
    
    # Add to scene tree through FloodGates if available
    var bootstrap = SystemBootstrap if SystemBootstrap else null
    if bootstrap and bootstrap.has_method("add_being_to_scene"):
        var parent = get_tree().current_scene
        if bootstrap.add_being_to_scene(scene_instance, parent):
            print_console("✓ Scene loaded successfully via FloodGates")
        else:
            print_console("⚠ Scene loaded with fallback method")
    else:
        # Fallback: add directly to scene tree
        get_tree().current_scene.add_child(scene_instance)
        print_console("✓ Scene loaded successfully")
    
    # Store scene reference for management
    var scene_id = "scene_%d" % Time.get_ticks_msec()
    _active_scenes[scene_id] = {
        "instance": scene_instance,
        "path": scene_path,
        "consciousness_level": consciousness_level,
        "loaded_at": Time.get_unix_time_from_system()
    }
    
    print_console("Scene ID: %s" % scene_id)

func _cmd_scene_unload(args: Array) -> void:
    """Unload a scene by ID"""
    if args.is_empty():
        print_console("Usage: scene unload <scene_id>")
        print_console("Use 'scene list' to see active scene IDs")
        return
    
    var scene_id = args[0]
    
    if not _active_scenes.has(scene_id):
        print_console("Error: Scene ID not found: %s" % scene_id)
        return
    
    var scene_data = _active_scenes[scene_id]
    var scene_instance = scene_data.instance
    
    if scene_instance and is_instance_valid(scene_instance):
        scene_instance.queue_free()
        print_console("✓ Scene unloaded: %s" % scene_id)
    else:
        print_console("⚠ Scene instance was already removed")
    
    _active_scenes.erase(scene_id)

func _cmd_scene_list(args: Array) -> void:
    """List all active scenes"""
    if _active_scenes.is_empty():
        print_console("No active scenes")
        return
    
    print_console("\nActive scenes:")
    for scene_id in _active_scenes:
        var scene_data = _active_scenes[scene_id]
        var status = "valid" if is_instance_valid(scene_data.instance) else "invalid"
        print_console("  %s:" % scene_id)
        print_console("    Path: %s" % scene_data.path)
        print_console("    Consciousness: %d" % scene_data.consciousness_level)
        print_console("    Status: %s" % status)
        print_console("    Loaded: %s ago" % _format_time_ago(scene_data.loaded_at))

func _cmd_scene_info(args: Array) -> void:
    """Show detailed info about a scene"""
    if args.is_empty():
        print_console("Usage: scene info <scene_id>")
        return
    
    var scene_id = args[0]
    
    if not _active_scenes.has(scene_id):
        print_console("Error: Scene ID not found: %s" % scene_id)
        return
    
    var scene_data = _active_scenes[scene_id]
    var scene_instance = scene_data.instance
    
    print_console("\nScene Info: %s" % scene_id)
    print_console("  Path: %s" % scene_data.path)
    print_console("  Consciousness Level: %d" % scene_data.consciousness_level)
    print_console("  Loaded At: %s" % Time.get_datetime_string_from_unix_time(scene_data.loaded_at))
    
    if is_instance_valid(scene_instance):
        print_console("  Status: Active")
        print_console("  Node Name: %s" % scene_instance.name)
        print_console("  Children: %d" % scene_instance.get_child_count())
        
        # Check if it's a Universal Being
        if scene_instance.has_method("ai_interface"):
            print_console("  Type: Universal Being")
            var interface = scene_instance.ai_interface()
            if interface.has("consciousness_level"):
                print_console("  Current Consciousness: %d" % interface.consciousness_level)
        else:
            print_console("  Type: Standard Node")
    else:
        print_console("  Status: Invalid/Removed")

func _format_time_ago(unix_time: float) -> String:
    """Format time difference as human readable string"""
    var diff = Time.get_unix_time_from_system() - unix_time
    
    if diff < 60:
        return "%d seconds" % diff
    elif diff < 3600:
        return "%d minutes" % (diff / 60)
    else:
        return "%d hours" % (diff / 3600)

# ===== CONSOLE UTILITIES =====

func print_console(text: String) -> void:
    """Print text to console"""
    if _console_node:
        _console_node.append_text(text + "\n")

func _add_to_history(command: String) -> void:
    """Add command to history"""
    _command_history.push_front(command)
    if _command_history.size() > history_size:
        _command_history.pop_back()
    _history_index = -1

func _navigate_history(direction: int) -> void:
    """Navigate command history"""
    if _command_history.is_empty():
        return
    
    _history_index = clamp(_history_index + direction, -1, _command_history.size() - 1)
    
    if _history_index == -1:
        _input_node.text = _current_input
    else:
        _input_node.text = _command_history[_history_index]

func _clear_input() -> void:
    """Clear input field"""
    _current_input = _input_node.text
    _input_node.text = ""
    _history_index = -1

# ===== SIGNAL HANDLERS =====

func _on_command_submitted(command: String) -> void:
    """Handle command submission"""
    _execute_command(command)
    _input_node.text = ""

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    """Enhanced AI interface for console being"""
    var base_interface = super.ai_interface()
    base_interface.custom_commands = [
        "print",
        "clear",
        "execute"
    ]
    base_interface.custom_properties = {
        "max_lines": max_lines,
        "command_history": _command_history
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """Handle AI method calls"""
    match method_name:
        "print":
            if args.size() > 0:
                print_console(str(args[0]))
                return true
        "clear":
            _cmd_clear([])
            return true
        "execute":
            if args.size() > 0:
                _execute_command(str(args[0]))
                return true
        _:
            return await super.ai_invoke_method(method_name, args)
    
    return false 