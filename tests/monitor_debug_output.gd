extends Node

var output_buffer: Array[String] = []
var monitoring_active: bool = true

func _ready():
	print("\n=== UNIVERSAL BEING DEBUG MONITOR ACTIVE ===")
	print("Monitoring all debug output from consciousness revolution system...")
	print("============================================\n")
	
	# Connect to various debug signals
	get_tree().node_added.connect(_on_node_added)
	
	# Monitor SystemBootstrap
	if has_node("/root/SystemBootstrap"):

		var bootstrap = get_node("/root/SystemBootstrap")
		print("✅ SystemBootstrap found and monitoring")
	
	# Monitor GemmaAI
	if has_node("/root/GemmaAI"):

		var gemma = get_node("/root/GemmaAI")
		if gemma.has_signal("ai_message"):
			gemma.ai_message.connect(_on_gemma_message)
		if gemma.has_signal("ai_error"):
			gemma.ai_error.connect(_on_gemma_error)
		print("✅ GemmaAI found and monitoring")
	
	# Set up periodic status reports
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.timeout.connect(_print_status_report)
	add_child(timer)
	timer.start()

func _on_node_added(node: Node):
	"""Monitor when new nodes are added"""
	if node.name.contains("Consciousness") or node.name.contains("Revolution"):
		print("🌟 New consciousness node added: %s" % node.name)

	
	if node.has_method("get") and node.has_property("being_type"):

		var being_type = node.get("being_type")
		if being_type != "":
			print("🎭 New Universal Being spawned: %s (type: %s)" % [node.name, being_type])


func _on_gemma_message(message: String):
	print("🤖 Gemma AI: %s" % message)


func _on_gemma_error(error: String):
	print("❌ Gemma AI Error: %s" % error)


func _print_status_report():
	"""Print periodic status report"""
	print("\n--- STATUS REPORT ---")
	
	# Count Universal Beings
	var beings = get_tree().get_nodes_in_group("universal_beings")
	print("Universal Beings active: %d" % beings.size())

	
	# Check for consciousness systems
	var ripple_system = get_tree().get_first_node_in_group("consciousness_ripple_system")
	if ripple_system:
		print("✅ Consciousness Ripple System: ACTIVE")
	else:
		print("❌ Consciousness Ripple System: NOT FOUND")

	
	# Check for Gemma companion
	var gemma_companion = get_tree().get_first_node_in_group("gemma_companion")
	if gemma_companion:
		print("✅ Gemma AI Companion: PRESENT")
	else:
		print("❌ Gemma AI Companion: NOT FOUND")

	
	# Check console
	var console = get_tree().get_first_node_in_group("universal_console")
	if console:
		print("✅ Universal Console: AVAILABLE")
		if console.has_property("console_visible"):
			print("   Console visible: %s" % console.get("console_visible"))
	else:
		print("❌ Universal Console: NOT FOUND")

	
	print("--- END REPORT ---\n")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F9:
				print("\n=== MANUAL DEBUG DUMP ===")
				_dump_scene_tree()
			KEY_F10:
				print("\n=== STOPPING DEBUG MONITOR ===")
				monitoring_active = false
				queue_free()

func _dump_scene_tree():
	"""Dump the entire scene tree for debugging"""
	print("Scene Tree Dump:")
	_dump_node(get_tree().root, 0)

func _dump_node(node: Node, depth: int):
	pass
	var indent = "  ".repeat(depth)
	var info = "%s%s" % [indent, node.name]
	
	if node.has_method("get") and node.has_property("being_type"):

		var being_type = node.get("being_type")
		if being_type != "":
			info += " [UB: %s]" % being_type

	
	print(info)
	
	for child in node.get_children():
		_dump_node(child, depth + 1)