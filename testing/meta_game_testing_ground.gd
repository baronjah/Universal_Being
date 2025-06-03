# ==================================================
# UNIVERSAL BEING: MetaGameTestingGround
# TYPE: Testing Environment
# PURPOSE: Testing ground for meta-game command system and AI collaboration
# COMPONENTS: Test scenarios, command validation, AI interaction tests
# SCENES: meta_game_testing_ground.tscn
# ==================================================

extends UniversalBeing
class_name MetaGameTestingGround

# ===== TEST SCENARIOS =====
var test_scenarios: Dictionary = {
    "potato_door": {
        "description": "Test 'say potato to open doors' natural language command",
        "setup_commands": [
            "/scene load res://scenes/test/door_test.tscn",
            "/create being door at 100,100"
        ],
        "test_commands": [
            "say potato to open doors",
            "potato"  # Trigger the logic connector
        ],
        "expected_results": ["Logic connector created", "Door opened"]
    },
    
    "ai_collaboration": {
        "description": "Test AI collaboration channel with Gemma",
        "setup_commands": [
            "/toggle ai_channel"
        ],
        "test_commands": [
            "/gemma create new logic for movement",
            "/create being from ai description smart_button"
        ],
        "expected_results": ["AI collaboration active", "New being created"]
    },
    
    "script_inspection": {
        "description": "Test data inspection commands",
        "setup_commands": [],
        "test_commands": [
            "count lines in res://core/UniversalBeing.gd",
            "show functions in res://core/UniversalBeing.gd",
            "/inspect components in button_basic"
        ],
        "expected_results": ["Line count returned", "Functions listed", "Components analyzed"]
    },
    
    "reality_modification": {
        "description": "Test in-game reality modification",
        "setup_commands": [
            "/scene load res://scenes/test/empty_world.tscn"
        ],
        "test_commands": [
            "/create being conscious_cube with consciousness 3",
            "/modify consciousness_cube consciousness 5",
            "/when cube near player then evolve"
        ],
        "expected_results": ["Being created", "Consciousness changed", "Logic connector set"]
    },
    
    "macro_recording": {
        "description": "Test macro recording and playback",
        "setup_commands": [],
        "test_commands": [
            "/start recording door_sequence",
            "say potato to open doors",
            "/scene load door.tscn",
            "/stop recording",
            "/replay door_sequence"
        ],
        "expected_results": ["Recording started", "Commands recorded", "Macro played back"]
    }
}

# ===== TEST STATE =====
var current_test: String = ""
var test_results: Dictionary = {}
var ai_responses_received: Array[String] = []

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    being_type = "testing_ground"
    being_name = "Meta-Game Testing Ground"
    consciousness_level = 6  # High level for testing complex systems
    
    print("🧪 MetaGameTestingGround: Testing environment initialized")

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Set up testing UI
    _create_testing_interface()
    
    # Connect to command systems
    _connect_to_test_systems()
    
    print("🧪 MetaGameTestingGround: Ready for meta-game testing")

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Monitor test progress
    _monitor_test_execution()

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    # Handle testing hotkeys
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F5: run_all_tests()
            KEY_F6: await run_test("potato_door")
            KEY_F7: await run_test("ai_collaboration")
            KEY_F8: _create_gemma_test_scenario()

func pentagon_sewers() -> void:
    print("🧪 MetaGameTestingGround: Saving test results...")
    _save_test_results()
    super.pentagon_sewers()

# ===== TESTING EXECUTION =====

func run_all_tests() -> Dictionary:
    """Run all test scenarios"""
    print("🧪 Running all meta-game tests...")
    
    var all_results = {}
    
    for test_name in test_scenarios:
        print("🧪 Running test: %s" % test_name)
        var result = await run_test(test_name)
        all_results[test_name] = result
        
        # Wait between tests
        await get_tree().create_timer(2.0).timeout
    
    _generate_test_report(all_results)
    return all_results

func run_test(test_name: String) -> Dictionary:
    """Run a specific test scenario"""
    if not test_scenarios.has(test_name):
        print("🧪 Test not found: %s" % test_name)
        return {"success": false, "error": "Test not found"}
    
    current_test = test_name
    var scenario = test_scenarios[test_name]
    var cmd_processor = _get_command_processor()
    
    if not cmd_processor:
        return {"success": false, "error": "Command processor not available"}
    
    print("🧪 Starting test: %s" % scenario.description)
    
    var result = {
        "test_name": test_name,
        "success": true,
        "setup_results": [],
        "test_results": [],
        "errors": [],
        "start_time": Time.get_unix_time_from_system()
    }
    
    # Run setup commands
    for setup_cmd in scenario.setup_commands:
        var setup_result = cmd_processor.process_universal_command(setup_cmd, "test_setup")
        result.setup_results.append(setup_result)
        
        if not setup_result.success:
            result.errors.append("Setup failed: %s" % setup_cmd)
    
    # Wait for setup to complete
    await get_tree().create_timer(1.0).timeout
    
    # Run test commands
    for test_cmd in scenario.test_commands:
        var test_result = cmd_processor.process_universal_command(test_cmd, "test")
        result.test_results.append(test_result)
        
        if not test_result.success:
            result.errors.append("Test failed: %s" % test_cmd)
            result.success = false
        
        # Wait between commands
        await get_tree().create_timer(0.5).timeout
    
    result.end_time = Time.get_unix_time_from_system()
    result.duration = result.end_time - result.start_time
    
    # Validate expected results
    _validate_test_results(result, scenario.expected_results)
    
    test_results[test_name] = result
    current_test = ""
    
    print("🧪 Test completed: %s (Success: %s)" % [test_name, str(result.success)])
    return result

# ===== GEMMA AI TESTING =====

func _create_gemma_test_scenario() -> void:
    """Create interactive test scenario for Gemma AI"""
    print("🤖 Creating Gemma AI test scenario...")
    
    # Create test environment
    var test_commands = [
        "/scene load res://scenes/test/ai_playground.tscn",
        "/toggle ai_channel",
        "/create being test_subject with consciousness 2"
    ]
    
    var cmd_processor = _get_command_processor()
    for cmd in test_commands:
        if cmd_processor:
            cmd_processor.process_universal_command(cmd, "gemma_test_setup")
    
    # Instructions for Gemma
    print("🤖 GEMMA AI TEST ENVIRONMENT READY!")
    print("🤖 Available commands for testing:")
    print("   - 'say hello to create greeting' (natural language)")
    print("   - '/create being smart_helper' (direct command)")
    print("   - 'count lines in UniversalBeing.gd' (inspection)")
    print("   - '/when player near helper then assist' (logic connector)")
    print("   - '/start recording gemma_sequence' (macro recording)")
    print("🤖 Try any combination! The system will learn and adapt!")

func test_gemma_command(command: String) -> Dictionary:
    """Test a command specifically from Gemma AI"""
    print("🤖 Gemma command: %s" % command)
    
    var cmd_processor = _get_command_processor()
    if not cmd_processor:
        return {"success": false, "error": "Command processor unavailable"}
    
    var result = cmd_processor.process_universal_command(command, "gemma")
    
    # Log for AI learning
    ai_responses_received.append(command)
    
    # Provide feedback to Gemma
    if result.success:
        print("🤖 ✅ SUCCESS: %s" % result.message)
        if result.new_beings_created.size() > 0:
            print("🤖 🌟 New beings created: %s" % str(result.new_beings_created))
    else:
        print("🤖 ❌ ERROR: %s" % result.message)
        print("🤖 💡 Suggestion: Try a different approach or check syntax")
    
    return result

# ===== INPUT FOCUS TESTING =====

func test_input_focus() -> Dictionary:
    """Test input focus management system"""
    print("⌨️ Testing input focus management...")
    
    var focus_manager = _get_input_focus_manager()
    if not focus_manager:
        return {"success": false, "error": "Input focus manager not found"}
    
    var test_sequence = [
        "game_focused",     # Default state
        "console_focused",  # Press ~ key
        "ai_channel",       # Press F1 key
        "game_focused"      # Press ESC key
    ]
    
    var results = []
    
    for expected_state in test_sequence:
        # Simulate focus change
        var current_state = focus_manager.ai_invoke_method("get_focus_state")
        results.append({
            "expected": expected_state,
            "actual": current_state,
            "match": current_state == expected_state
        })
        
        await get_tree().create_timer(0.5).timeout
    
    return {"success": true, "focus_tests": results}

# ===== UTILITY FUNCTIONS =====

func _validate_test_results(result: Dictionary, expected: Array) -> void:
    """Validate test results against expected outcomes"""
    result.validation = {"passed": 0, "total": expected.size(), "details": []}
    
    for expectation in expected:
        var found = false
        
        # Check if expectation appears in any result message
        for test_result in result.test_results:
            if test_result.message.contains(expectation):
                found = true
                break
        
        if found:
            result.validation.passed += 1
        
        result.validation.details.append({
            "expectation": expectation,
            "met": found
        })
    
    result.validation_success = result.validation.passed == result.validation.total

func _generate_test_report(all_results: Dictionary) -> void:
    """Generate comprehensive test report"""
    print("\n🧪 ===== META-GAME TEST REPORT =====")
    
    var total_tests = all_results.size()
    var passed_tests = 0
    
    for test_name in all_results:
        var result = all_results[test_name]
        if result.success:
            passed_tests += 1
        
        print("🧪 %s: %s (%.1fs)" % [
            test_name,
            "PASS" if result.success else "FAIL",
            result.get("duration", 0.0)
        ])
        
        if result.has("errors") and result.errors.size() > 0:
            for error in result.errors:
                print("   ❌ %s" % error)
    
    print("🧪 Summary: %d/%d tests passed (%.1f%%)" % [
        passed_tests,
        total_tests,
        (passed_tests * 100.0) / total_tests if total_tests > 0 else 0
    ])
    print("🧪 ================================\n")

func _get_command_processor() -> Node:
    """Get the universal command processor"""
    return get_node_or_null("/root/UniversalCommandProcessor")

func _get_input_focus_manager() -> Node:
    """Get the input focus manager"""
    return get_node_or_null("/root/InputFocusManager")

func _create_testing_interface() -> void:
    """Create UI for testing"""
    # Could create visual testing interface
    pass

func _connect_to_test_systems() -> void:
    """Connect to systems for testing"""
    # Connect to various systems for monitoring
    pass

func _monitor_test_execution() -> void:
    """Monitor ongoing test execution"""
    # Monitor test progress and results
    pass

func _save_test_results() -> void:
    """Save test results for analysis"""
    var save_data = {
        "test_results": test_results,
        "ai_responses": ai_responses_received,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    var file = FileAccess.open("user://meta_game_test_results.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()

# ===== AI INTERFACE =====

func ai_interface() -> Dictionary:
    """AI interface for testing system"""
    var base = super.ai_interface()
    base.testing_commands = [
        "run_test",
        "run_all_tests",
        "test_gemma_command",
        "create_test_scenario",
        "get_test_results"
    ]
    base.available_tests = test_scenarios.keys()
    base.current_test = current_test
    return base

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """AI method invocation for testing"""
    match method_name:
        "run_test":
            if args.size() > 0:
                return await run_test(args[0])
        
        "run_all_tests":
            return await run_all_tests()
        
        "test_gemma_command":
            if args.size() > 0:
                return test_gemma_command(args[0])
        
        "create_test_scenario":
            _create_gemma_test_scenario()
            return "Gemma test scenario created"
        
        "get_test_results":
            return test_results
        
        _:
            return await super.ai_invoke_method(method_name, args)

func _to_string() -> String:
    return "MetaGameTestingGround<Tests:%d, Current:%s>" % [test_scenarios.size(), current_test]