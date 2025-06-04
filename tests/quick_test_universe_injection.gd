# ==================================================
# SCRIPT NAME: quick_test_universe_injection.gd
# DESCRIPTION: Quick test script to validate Universe Injection
# PURPOSE: Simple validation that can be attached to any Node3D
# CREATED: 2025-06-04
# AUTHOR: Claude Desktop MCP
# ==================================================
extends Node3D

func _ready() -> void:
	print("🌌 Quick Universe Injection Test Starting...")
	
	# Create the injector
	var injector = GemmaUniverseInjector.new()
	injector.name = "TestInjector"
	add_child(injector)
	
	# Wait a moment for initialization
	await get_tree().create_timer(0.5).timeout
	
	# Test 1: Inject Collaborative Workshop
	print("\n📍 Test 1: Injecting Collaborative Workshop...")
	var result = injector.inject_universe(
		GemmaUniverseInjector.UniverseType.COLLABORATIVE_WORKSHOP,
		{"test_mode": true}
	)
	
	if result.success:
		print("✅ Workshop injected successfully!")
		print("   Message: %s" % result.message)
		
		# Count beings created
		await get_tree().create_timer(1.0).timeout
		var beings = get_tree().get_nodes_in_group("universal_beings")
		print("   Beings created: %d" % beings.size())
		
		# List the beings
		for being in beings:
			var b_name = being.get("being_name") if being.has_method("get") else being.name
			var b_type = being.get("being_type") if being.has_method("get") else "unknown"
			var b_cons = being.get("consciousness_level") if being.has_method("get") else 0
			print("   - %s (%s) [Consciousness: %d]" % [b_name, b_type, b_cons])
	else:
		print("❌ Failed to inject workshop: %s" % result.message)
	
	# Test 2: Generate a story
	print("\n📍 Test 2: Generating Collaboration Story...")
	var story_result = injector.generate_story(
		GemmaUniverseInjector.StoryType.COLLABORATION_EPIC,
		{"quick_test": true}
	)
	
	if story_result.success:
		print("✅ Story generated successfully!")
		print("   Story type: %s" % story_result.story.pattern_name)
		print("   Narrative phases: %d" % story_result.story.generated_narrative.size())
	else:
		print("❌ Failed to generate story")
	
	# Test 3: Create interactive tools
	print("\n📍 Test 3: Creating Interactive Workshop Tools...")
	var tools = injector.create_interactive_workshop_tools(self)
	print("✅ Created %d interactive tools" % tools.size())
	
	print("\n🌌 Quick Universe Injection Test Complete!")
	print("   You should see:")
	print("   - A workshop with workbench, tools, and idea generator")
	print("   - Interactive crystals and collaboration nexus")
	print("   - All elements are Universal Beings")
	print("\n   Try using the console (~) to interact with them!")
