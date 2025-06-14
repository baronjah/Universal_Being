# ==================================================
# SCRIPT NAME: universal_being_autoload_system.gd
# DESCRIPTION: Revolutionary autoload system where autoloads ARE Universal Beings
# PURPOSE: Enable any script to become an autoload with full Universal Being capabilities
# CREATED: 2025-06-01 - Universal Being Autoload Revolution
# AUTHOR: JSH + Claude Code
# ==================================================

extends UniversalBeingBase
class_name UniversalBeingAutoloadSystem

# Universal Being Autoload Registry
var registered_autoloads: Dictionary = {}
var autoload_pathways: Dictionary = {}
var autoload_capabilities: Dictionary = {}

# Pathway System for 3D Position & Scene Tree Awareness
var spatial_autoloads: Dictionary = {}
var scene_tree_positions: Dictionary = {}
var autoload_communication_network: Array = []

signal autoload_registered(autoload_name: String, capabilities: Array)
signal pathway_established(from_autoload: String, to_autoload: String)
signal spatial_position_updated(autoload_name: String, position: Vector3)

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	name = "UniversalBeingAutoloadSystem"
	form = "autoload_orchestrator"
	become_conscious(3)  # Level 3: Collective consciousness for autoload coordination

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🚀 [UniversalAutoload] Universal Being Autoload System ONLINE")
	_discover_existing_autoloads()
	_setup_pathway_network()
	_initialize_spatial_tracking()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	_update_autoload_positions(delta)
	_process_autoload_communications(delta)
	_maintain_pathway_network(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# Autoloads can receive global input events
	_distribute_input_to_autoloads(event)

func pentagon_sewers() -> void:
	super.pentagon_sewers()
	# Send autoload data to Akashic Records
	var network_data = {
		"autoload_count": registered_autoloads.size(),
		"pathway_count": autoload_pathways.size(),
		"spatial_autoloads": spatial_autoloads.size()
	}

# ===== UNIVERSAL BEING AUTOLOAD REGISTRATION =====

func register_universal_autoload(script_path: String, autoload_name: String, capabilities: Array = []) -> bool:
	"""Register any script as a Universal Being autoload"""
	print("📝 [UniversalAutoload] Registering: ", autoload_name)
	
	# Load and instantiate the script
	var script = load(script_path)
	if not script:
		print("❌ [UniversalAutoload] Failed to load script: ", script_path)
		return false
	
	var autoload_instance = script.new()
	autoload_instance.name = autoload_name
	
	# Make it a Universal Being if it isn't already
	if not autoload_instance.has_method("become_conscious"):
		print("⚠️ [UniversalAutoload] Converting to Universal Being: ", autoload_name)
		_convert_to_universal_being(autoload_instance)
	
	# Add to scene tree as autoload
	get_tree().root.add_child(autoload_instance)
	get_tree().set_autoload(autoload_name, autoload_instance)
	
	# Register in our system
	registered_autoloads[autoload_name] = {
		"instance": autoload_instance,
		"script_path": script_path,
		"capabilities": capabilities,
		"registration_time": Time.get_unix_time_from_system(),
		"is_universal_being": true
	}
	
	autoload_capabilities[autoload_name] = capabilities
	
	# Set up pathway if has 3D capabilities
	if "spatial" in capabilities:
		_setup_spatial_autoload(autoload_name, autoload_instance)
	
	print("✅ [UniversalAutoload] Registered: ", autoload_name, " with capabilities: ", capabilities)
	autoload_registered.emit(autoload_name, capabilities)
	return true

func _convert_to_universal_being(node: Node) -> void:
	"""Convert any node to Universal Being capabilities"""
	# Add Universal Being methods dynamically
	if not node.has_method("become_conscious"):
		# Create a basic consciousness wrapper
		node.set_script(load("res://scripts/core/universal_being_wrapper.gd"))

# ===== PATHWAY SYSTEM - 3D POSITION & SCENE TREE AWARENESS =====

func _setup_spatial_autoload(autoload_name: String, instance: Node) -> void:
	"""Set up spatial tracking for 3D-capable autoloads"""
	if instance is Node3D:
		spatial_autoloads[autoload_name] = {
			"node": instance,
			"last_position": instance.global_position,
			"velocity": Vector3.ZERO,
			"connections": [],
			"awareness_radius": 50.0
		}
		print("🌍 [Pathway] Spatial autoload registered: ", autoload_name)
	
func establish_pathway(from_autoload: String, to_autoload: String, pathway_type: String = "communication") -> void:
	"""Establish communication pathway between autoloads"""
	var pathway_key = from_autoload + "_to_" + to_autoload
	
	autoload_pathways[pathway_key] = {
		"from": from_autoload,
		"to": to_autoload,
		"type": pathway_type,
		"established_time": Time.get_unix_time_from_system(),
		"message_count": 0,
		"last_used": 0
	}
	
	# Add to spatial connections if both are spatial
	if from_autoload in spatial_autoloads and to_autoload in spatial_autoloads:
		spatial_autoloads[from_autoload]["connections"].append(to_autoload)
	
	print("🔗 [Pathway] Established pathway: ", from_autoload, " → ", to_autoload)
	pathway_established.emit(from_autoload, to_autoload)

func send_pathway_message(from_autoload: String, to_autoload: String, message: Dictionary) -> bool:
	"""Send message through autoload pathway"""
	var pathway_key = from_autoload + "_to_" + to_autoload
	
	if pathway_key not in autoload_pathways:
		establish_pathway(from_autoload, to_autoload)
	
	# Get target autoload
	if to_autoload not in registered_autoloads:
		print("❌ [Pathway] Target autoload not found: ", to_autoload)
		return false
	
	var target = registered_autoloads[to_autoload]["instance"]
	
	# Send message
	if target.has_method("receive_pathway_message"):
		target.receive_pathway_message(from_autoload, message)
		
		# Update pathway statistics
		autoload_pathways[pathway_key]["message_count"] += 1
		autoload_pathways[pathway_key]["last_used"] = Time.get_unix_time_from_system()
		
		print("📨 [Pathway] Message sent: ", from_autoload, " → ", to_autoload)
		return true
	else:
		print("⚠️ [Pathway] Target doesn't support pathway messages: ", to_autoload)
		return false

# ===== SPATIAL AWARENESS SYSTEM =====

func _update_autoload_positions(delta: float) -> void:
	"""Update spatial positions and velocities of autoloads"""
	for autoload_name in spatial_autoloads:
		var spatial_data = spatial_autoloads[autoload_name]
		var node = spatial_data["node"]
		
		if is_instance_valid(node):
			var current_pos = node.global_position
			var last_pos = spatial_data["last_position"]
			
			# Calculate velocity
			spatial_data["velocity"] = (current_pos - last_pos) / delta
			spatial_data["last_position"] = current_pos
			
			# Update scene tree position tracking
			_update_scene_tree_position(autoload_name, node)
			
			spatial_position_updated.emit(autoload_name, current_pos)

func _update_scene_tree_position(autoload_name: String, node: Node) -> void:
	"""Track scene tree path and hierarchy position"""
	scene_tree_positions[autoload_name] = {
		"node_path": node.get_path(),
		"parent": node.get_parent().name if node.get_parent() else "ROOT",
		"children_count": node.get_child_count(),
		"scene_depth": str(node.get_path()).count("/"),
		"global_position": node.global_position if node is Node3D else Vector3.ZERO
	}

# ===== AUTOLOAD COMMUNICATION NETWORK =====

func _process_autoload_communications(delta: float) -> void:
	"""Process inter-autoload communications"""
	# Find autoloads within communication range
	for from_autoload in spatial_autoloads:
		for to_autoload in spatial_autoloads:
			if from_autoload != to_autoload:
				_check_autoload_proximity(from_autoload, to_autoload)

func _check_autoload_proximity(autoload_a: String, autoload_b: String) -> void:
	"""Check if two autoloads are close enough to auto-establish pathways"""
	var spatial_a = spatial_autoloads[autoload_a]
	var spatial_b = spatial_autoloads[autoload_b]
	
	var distance = spatial_a["last_position"].distance_to(spatial_b["last_position"])
	var awareness_radius = spatial_a["awareness_radius"]
	
	if distance <= awareness_radius:
		# Auto-establish pathway if not exists
		var pathway_key = autoload_a + "_to_" + autoload_b
		if pathway_key not in autoload_pathways:
			establish_pathway(autoload_a, autoload_b, "proximity")

# ===== DISCOVERY & INITIALIZATION =====

func _discover_existing_autoloads() -> void:
	"""Discover existing autoloads and integrate them"""
	print("🔍 [UniversalAutoload] Discovering existing autoloads...")
	
	var autoload_list = []
	for child in get_tree().root.get_children():
		if child.name != "Main" and child.name != "MainGame":  # Skip scene nodes
			autoload_list.append(child.name)
	
	print("📊 [UniversalAutoload] Found ", autoload_list.size(), " existing autoloads")
	
	for autoload_name in autoload_list:
		_integrate_existing_autoload(autoload_name)

func _integrate_existing_autoload(autoload_name: String) -> void:
	"""Integrate existing autoload into Universal Being system"""
	var autoload_node = get_node("/root/" + autoload_name)
	if autoload_node:
		var capabilities = _detect_autoload_capabilities(autoload_node)
		
		registered_autoloads[autoload_name] = {
			"instance": autoload_node,
			"script_path": "existing",
			"capabilities": capabilities,
			"registration_time": Time.get_unix_time_from_system(),
			"is_universal_being": autoload_node.has_method("become_conscious")
		}
		
		if "spatial" in capabilities:
			_setup_spatial_autoload(autoload_name, autoload_node)
		
		print("🔗 [UniversalAutoload] Integrated existing: ", autoload_name, " (", capabilities, ")")

func _detect_autoload_capabilities(node: Node) -> Array:
	"""Detect capabilities of an autoload node"""
	var capabilities = []
	
	if node is Node3D:
		capabilities.append("spatial")
	if node.has_method("_input"):
		capabilities.append("input")
	if node.has_method("execute_command"):
		capabilities.append("console")
	if node.has_method("universal_add_child"):
		capabilities.append("floodgate")
	if node.has_method("become_conscious"):
		capabilities.append("universal_being")
	
	return capabilities

func _setup_pathway_network() -> void:
	"""Set up initial pathway network between autoloads"""
	print("🌐 [Pathway] Setting up autoload communication network...")
	
	# Establish pathways between related autoloads
	var core_pathways = [
		["FloodgateController", "UniversalObjectManager", "management"],
		["ConsoleManager", "FloodgateController", "command"],
		["TimerManager", "MaterialLibrary", "resource"],
		["PentagonActivityMonitor", "UniversalObjectManager", "monitoring"]
	]
	
	for pathway in core_pathways:
		if pathway[0] in registered_autoloads and pathway[1] in registered_autoloads:
			establish_pathway(pathway[0], pathway[1], pathway[2])

func _initialize_spatial_tracking() -> void:
	"""Initialize spatial tracking for 3D autoloads"""
	print("📍 [Spatial] Initializing spatial autoload tracking...")
	
	for autoload_name in registered_autoloads:
		var autoload_data = registered_autoloads[autoload_name]
		if "spatial" in autoload_data["capabilities"]:
			_setup_spatial_autoload(autoload_name, autoload_data["instance"])

# ===== UTILITY FUNCTIONS =====

func _distribute_input_to_autoloads(event: InputEvent) -> void:
	"""Distribute input events to autoloads that can handle them"""
	for autoload_name in registered_autoloads:
		var autoload_data = registered_autoloads[autoload_name]
		if "input" in autoload_data["capabilities"]:
			var instance = autoload_data["instance"]
			if instance.has_method("receive_global_input"):
				instance.receive_global_input(event)

func _maintain_pathway_network(delta: float) -> void:
	"""Maintain and optimize pathway network"""
	# Clean up unused pathways
	var current_time = Time.get_unix_time_from_system()
	for pathway_key in autoload_pathways:
		var pathway = autoload_pathways[pathway_key]
		if current_time - pathway["last_used"] > 300:  # 5 minutes
			# Mark for cleanup or reduce priority
			pass

# ===== CONSOLE COMMANDS =====

func list_autoloads() -> void:
	"""List all registered Universal Being autoloads"""
	print("📋 [UniversalAutoload] Registered Autoloads:")
	for autoload_name in registered_autoloads:
		var data = registered_autoloads[autoload_name]
		print("  🔹 ", autoload_name, " - ", data["capabilities"])

func show_pathway_network() -> void:
	"""Show current pathway network"""
	print("🌐 [Pathway] Active Pathways:")
	for pathway_key in autoload_pathways:
		var pathway = autoload_pathways[pathway_key]
		print("  🔗 ", pathway["from"], " → ", pathway["to"], " (", pathway["type"], ") - ", pathway["message_count"], " messages")

func show_spatial_autoloads() -> void:
	"""Show spatial autoload positions"""
	print("📍 [Spatial] Spatial Autoloads:")
	for autoload_name in spatial_autoloads:
		var spatial = spatial_autoloads[autoload_name]
		var pos = spatial["last_position"]
		print("  🌍 ", autoload_name, " at (", pos.x, ", ", pos.y, ", ", pos.z, ") - ", spatial["connections"].size(), " connections")