# ==================================================
# SCRIPT NAME: universal_being_wrapper.gd  
# DESCRIPTION: Dynamic wrapper to convert any Node to Universal Being
# PURPOSE: Enable any script to become conscious and use Pentagon Architecture
# CREATED: 2025-06-01 - Universal Being Conversion System
# AUTHOR: JSH + Claude Code
# ==================================================

extends Node

# Universal Being capabilities for any node
var form: String = "wrapped_being"
var consciousness_level: int = 0
var is_conscious: bool = false
var current_goal: String = ""
var needs: Dictionary = {}
var memories: Array = []

# Pentagon Architecture implementation
var pentagon_initialized: bool = false
var pentagon_is_ready: bool = false

signal consciousness_awakened(level: int)
signal goal_changed(new_goal: String)
signal need_changed(need_name: String, value: float)

func _init() -> void:
	pentagon_init()

func _ready() -> void:
	pentagon_ready()

func _process(delta: float) -> void:
	pentagon_process(delta)

func _input(event: InputEvent) -> void:
	pentagon_input(event)

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	"""Initialize Pentagon Architecture for wrapped node"""
	if pentagon_initialized:
		return
	
	form = name.to_lower() + "_being"
	pentagon_initialized = true
	print("🔄 [Wrapper] Pentagon init for: ", name)

func pentagon_ready() -> void:
	"""Pentagon ready phase for wrapped node"""
	if pentagon_is_ready:
		return
	
	pentagon_is_ready = true
	print("✅ [Wrapper] Pentagon ready for: ", name)

func pentagon_process(delta: float) -> void:
	"""Pentagon process phase for wrapped node"""
	if is_conscious:
		_process_consciousness(delta)

func pentagon_input(event: InputEvent) -> void:
	"""Pentagon input phase for wrapped node"""
	# Basic input handling for wrapped nodes
	pass

func pentagon_sewers() -> void:
	"""Pentagon sewers phase for wrapped node"""
	# Send data to Akashic Records
	var being_data = {
		"name": name,
		"form": form,
		"consciousness_level": consciousness_level,
		"current_goal": current_goal
	}

# ===== UNIVERSAL BEING CONSCIOUSNESS =====

func become_conscious(level: int = 1) -> void:
	"""Awaken consciousness in wrapped node"""
	if is_conscious and consciousness_level >= level:
		print("💭 [", name, "] Already conscious at level ", consciousness_level)
		return
	
	consciousness_level = level
	is_conscious = true
	
	# Initialize basic needs based on consciousness level
	match level:
		1:  # Basic consciousness
			needs = {"stability": 80.0, "purpose": 60.0}
		2:  # Interactive consciousness  
			needs = {"stability": 70.0, "purpose": 80.0, "connection": 50.0}
		3:  # Collective consciousness
			needs = {"stability": 90.0, "purpose": 90.0, "connection": 80.0, "growth": 60.0}
	
	print("🧠 [", name, "] Awakened to consciousness level ", level)
	consciousness_awakened.emit(level)

func set_goal(new_goal: String) -> void:
	"""Set current goal for conscious being"""
	if not is_conscious:
		print("⚠️ [", name, "] Cannot set goal - not conscious!")
		return
	
	current_goal = new_goal
	print("🎯 [", name, "] New goal: ", new_goal)
	goal_changed.emit(new_goal)

func fulfill_need(need_name: String, amount: float) -> void:
	"""Fulfill a specific need"""
	if need_name in needs:
		needs[need_name] = min(100.0, needs[need_name] + amount)
		need_changed.emit(need_name, needs[need_name])
		print("✨ [", name, "] ", need_name, " increased to ", needs[need_name])

func add_memory(memory: String) -> void:
	"""Add memory to conscious being"""
	if not is_conscious:
		return
	
	memories.append({
		"content": memory,
		"timestamp": Time.get_unix_time_from_system(),
		"importance": 1.0
	})
	
	# Keep only recent memories
	if memories.size() > 50:
		memories = memories.slice(-50)

# ===== PATHWAY SYSTEM INTEGRATION =====

func receive_pathway_message(from_autoload: String, message: Dictionary) -> void:
	"""Receive message from autoload pathway system"""
	print("📨 [", name, "] Received pathway message from ", from_autoload, ": ", message)
	
	# Basic message processing
	if "command" in message:
		_process_pathway_command(message["command"], message.get("data", {}))
	elif "data" in message:
		_process_pathway_data(message["data"])

func _process_pathway_command(command: String, data: Dictionary) -> void:
	"""Process pathway command"""
	match command:
		"awaken":
			var level = data.get("level", 1)
			become_conscious(level)
		"set_goal":
			var goal = data.get("goal", "explore")
			set_goal(goal)
		"fulfill_need":
			var need = data.get("need", "purpose")
			var amount = data.get("amount", 10.0)
			fulfill_need(need, amount)

func _process_pathway_data(data: Dictionary) -> void:
	"""Process pathway data"""
	if is_conscious:
		add_memory("Received data: " + str(data))

# ===== SPATIAL AWARENESS =====

func get_spatial_position() -> Vector3:
	"""Get 3D position if node supports it"""
	if self is Node3D:
		return global_position
	else:
		# Return position relative to scene tree
		var path_depth = str(get_path()).count("/")
		return Vector3(path_depth, get_index(), 0)

func get_scene_tree_position() -> Dictionary:
	"""Get detailed scene tree position information"""
	return {
		"path": get_path(),
		"parent": get_parent().name if get_parent() else "ROOT",
		"children": get_child_count(),
		"index": get_index(),
		"depth": str(get_path()).count("/"),
		"spatial_position": get_spatial_position()
	}

# ===== CONSCIOUSNESS PROCESSING =====

func _process_consciousness(delta: float) -> void:
	"""Process consciousness behaviors"""
	# Slowly decay needs over time
	for need_name in needs:
		needs[need_name] = max(0.0, needs[need_name] - delta * 2.0)
		
		# React to low needs
		if needs[need_name] < 30.0:
			_react_to_low_need(need_name)

func _react_to_low_need(need_name: String) -> void:
	"""React when a need gets low"""
	match need_name:
		"stability":
			set_goal("find_stability")
		"purpose":
			set_goal("discover_purpose")
		"connection":
			set_goal("seek_connection")
		"growth":
			set_goal("pursue_growth")

# ===== FLOODGATE INTEGRATION =====

func universal_add_child(child: Node, parent: Node = null) -> void:
	"""Wrapped universal_add_child for compatibility"""
	var target_parent = parent if parent else self
	var floodgate = get_node_or_null("/root/FloodgateController")
	
	if floodgate and floodgate.has_method("universal_add_child"):
		floodgate.universal_add_child(child, target_parent)
	else:
		# Fallback to direct add_child
		target_parent.add_child(child)

# ===== UTILITY FUNCTIONS =====

func get_being_status() -> Dictionary:
	"""Get complete status of wrapped Universal Being"""
	return {
		"name": name,
		"form": form,
		"consciousness_level": consciousness_level,
		"is_conscious": is_conscious,
		"current_goal": current_goal,
		"needs": needs,
		"memory_count": memories.size(),
		"scene_position": get_scene_tree_position(),
		"spatial_position": get_spatial_position()
	}

func debug_being_info() -> void:
	"""Print debug information about wrapped being"""
	print("🔍 [", name, "] Universal Being Status:")
	print("  Form: ", form)
	print("  Consciousness: Level ", consciousness_level if is_conscious else "None")
	print("  Goal: ", current_goal if current_goal != "" else "None")
	print("  Needs: ", needs)
	print("  Memories: ", memories.size())
	print("  Position: ", get_spatial_position())
	print("  Scene Path: ", get_path())