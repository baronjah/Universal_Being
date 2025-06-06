extends Node

# Script to monitor consciousness revolution output
var monitoring: bool = true
var log_file: FileAccess = null
var start_time: float = 0.0

func _ready():
	print("🔍 REVOLUTION MONITOR: Starting...")
	start_time = Time.get_ticks_msec() / 1000.0
	
	# Open log file for revolution output
	log_file = FileAccess.open("user://revolution_log.txt", FileAccess.WRITE)
	if log_file:
		log_file.store_line("=== CONSCIOUSNESS REVOLUTION LOG ===")
		log_file.store_line("Time: %s" % Time.get_datetime_string_from_system())
		log_file.store_line("")
	
	# Monitor for 10 seconds then quit
	get_tree().create_timer(10.0).timeout.connect(_finish_monitoring)
	
	# Try to trigger revolution after 2 seconds
	get_tree().create_timer(2.0).timeout.connect(_trigger_revolution)

func _trigger_revolution():
	print("🎯 ATTEMPTING TO TRIGGER REVOLUTION...")
	
	# Find console and trigger revolution
	var console_paths = [
		"/root/Main/UI/UniversalConsole",
		"/root/Main/UniversalConsole",
		"/root/UniversalConsole"
	]
	
	for path in console_paths:
		var console = get_node_or_null(path)
		if console:
			print("✅ Found console at: %s" % path)
			if console.has_method("deploy_consciousness_revolution"):
				console.deploy_consciousness_revolution()
				_log("Revolution command executed via: %s" % path)
				return
	
	# If no console found, try direct spawner creation
	print("⚠️ No console found, creating spawner directly...")
	var spawner_class = load("res://beings/ConsciousnessRevolutionSpawner.gd")
	if spawner_class:
		var spawner = spawner_class.new()
		spawner.name = "DirectRevolutionSpawner"
		spawner.global_position = Vector3(0, 5, 0)
		get_tree().current_scene.add_child(spawner)
		_log("Revolution spawner created directly!")

func _process(_delta):
	# Monitor for revolution-related nodes
	if monitoring and Time.get_ticks_msec() / 1000.0 - start_time > 1.0:
		_check_revolution_status()

func _check_revolution_status():
	# Check for revolution components
	var ripple_system = get_node_or_null("/root/Main/ConsciousnessRippleSystem")
	var gemma_companion = get_node_or_null("/root/Main/GemmaAICompanion")
	var spawner = _find_node_by_name("ConsciousnessRevolutionSpawner")
	
	if ripple_system:
		_log("✅ Ripple System DETECTED!")
	if gemma_companion:
		_log("✅ Gemma Companion DETECTED!")
	if spawner:
		_log("✅ Revolution Spawner DETECTED!")
		if spawner.has_method("get_revolution_status"):
			var status = spawner.get_revolution_status()
			_log("Revolution Status: Phase %d - %s" % [
				status.spawning_phase,
				status.phase_names.get(status.spawning_phase, "Unknown")
			])

func _find_node_by_name(node_name: String) -> Node:
	return _search_tree(get_tree().root, node_name)

func _search_tree(node: Node, search_name: String) -> Node:
	if node.name == search_name:
		return node
	for child in node.get_children():
		var result = _search_tree(child, search_name)
		if result:
			return result
	return null

func _log(message: String):
	var timestamp = "%.2f" % (Time.get_ticks_msec() / 1000.0 - start_time)
	var log_line = "[%s] %s" % [timestamp, message]
	print(log_line)
	if log_file:
		log_file.store_line(log_line)

func _finish_monitoring():
	monitoring = false
	_log("=== MONITORING COMPLETE ===")
	
	# Final status check
	var beings = get_tree().get_nodes_in_group("universal_beings")
	_log("Total Universal Beings: %d" % beings.size())
	
	for being in beings:
		if being.has_method("get") and being.has_property("being_type"):
			var being_type = being.get("being_type")
			if being_type in ["revolution_spawner", "gemma_ai_companion", "consciousness_ripple"]:
				_log("Found: %s (%s)" % [being.name, being_type])
	
	if log_file:
		log_file.close()
	
	print("🔍 REVOLUTION MONITOR: Complete. Check user://revolution_log.txt")
	get_tree().quit()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if log_file:
			log_file.close()