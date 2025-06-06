# Enhanced UniversalBeing Base - Automatically integrates with Luminus's LogicConnector
# Shows how to modify UniversalBeing to auto-register with debug system

extends UniversalBeing
class_name UniversalBeingEnhanced

# Note: This is an example of how to enhance the base UniversalBeing class
# You would apply these changes to your actual UniversalBeing.gd

# ===== ENHANCED PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	# Auto-register with LogicConnector if this object implements Debuggable
	if self is Debuggable:
		LogicConnector.register(self)
		print("🔌 Auto-registered %s with LogicConnector" % being_name)

func pentagon_sewers() -> void:
	# Auto-deregister from LogicConnector
	LogicConnector.deregister(self)
	print("🔌 Auto-deregistered %s from LogicConnector" % being_name)
	
	super.pentagon_sewers()

# ===== DEBUGGABLE INTERFACE IMPLEMENTATION =====
# Every UniversalBeing can optionally implement this for clean debug panels

func get_debug_payload() -> Dictionary:
	"""Standard Universal Being debug payload"""
	return {
		# Core Universal Being properties
		"being_name": being_name,
		"being_type": being_type,
		"consciousness_level": consciousness_level,
		
		# Node3D properties (if applicable)
		"global_position": global_position if self is Node3D else Vector3.ZERO,
		"rotation": rotation if self is Node3D else Vector3.ZERO,
		
		# Pentagon status
		"pentagon_active": pentagon_active if "pentagon_active" in self else true,
		
		# Evolution properties
		"can_evolve": evolution_state.can_become.size() > 0 if evolution_state else false,
		"evolution_paths": evolution_state.can_become if evolution_state else []
	}

func set_debug_field(key: String, value) -> void:
	"""Handle debug field changes"""
	match key:
		"being_name":
			if value is String:
				being_name = value
				name = value  # Also update node name
				print("📝 Being name changed to: %s" % value)
		
		"being_type":
			if value is String:
				being_type = value
				print("🏷️ Being type changed to: %s" % value)
		
		"consciousness_level":
			if value is int:
				consciousness_level = clampi(value, 0, 5)
				print("🧠 Consciousness level changed to: %d" % consciousness_level)
		
		"global_position":
			if value is Vector3 and self is Node3D:
				global_position = value
				print("📍 Position changed to: %s" % value)
		
		"rotation":
			if value is Vector3 and self is Node3D:
				rotation = value
				print("🔄 Rotation changed to: %s" % value)
		
		_:
			print("⚠️ Unknown debug field: %s" % key)

func get_debug_actions() -> Dictionary:
	"""Standard Universal Being debug actions"""
	var actions = {
		"Inspect": print_being_info,
		"Reset Position": reset_position,
		"Increase Consciousness": increase_consciousness,
		"Decrease Consciousness": decrease_consciousness
	}
	
	# Add evolution actions if applicable
	if evolution_state and evolution_state.can_become.size() > 0:
		actions["Show Evolution Paths"] = show_evolution_paths
		if evolution_state.can_become.size() > 0:
			actions["Evolve to First Path"] = evolve_to_first_path
	
	# Add component actions if applicable
	if has_method("add_component"):
		actions["List Components"] = list_components
	
	return actions

# ===== DEBUG ACTION IMPLEMENTATIONS =====

func print_being_info() -> void:
	"""Print detailed being information"""
	print("🔍 Universal Being Info: %s" % being_name)
	print("  Type: %s" % being_type)
	print("  Consciousness: %d" % consciousness_level)
	print("  Position: %s" % (global_position if self is Node3D else "N/A"))
	print("  Pentagon Active: %s" % (pentagon_active if "pentagon_active" in self else "Unknown"))
	print("  Evolution Paths: %s" % (evolution_state.can_become if evolution_state else []))

func reset_position() -> void:
	"""Reset position to origin"""
	if self is Node3D:
		global_position = Vector3.ZERO
		print("📍 Position reset to origin")

func increase_consciousness() -> void:
	"""Increase consciousness level"""
	if consciousness_level < 5:
		consciousness_level += 1
		print("🧠⬆️ Consciousness increased to: %d" % consciousness_level)
	else:
		print("🧠 Already at maximum consciousness level")

func decrease_consciousness() -> void:
	"""Decrease consciousness level"""
	if consciousness_level > 0:
		consciousness_level -= 1
		print("🧠⬇️ Consciousness decreased to: %d" % consciousness_level)
	else:
		print("🧠 Already at minimum consciousness level")

func show_evolution_paths() -> void:
	"""Show available evolution paths"""
	if evolution_state and evolution_state.can_become.size() > 0:
		print("🔀 Evolution paths for %s:" % being_name)
		for i in range(evolution_state.can_become.size()):
			print("  %d. %s" % [i + 1, evolution_state.can_become[i]])
	else:
		print("🔀 No evolution paths available")

func evolve_to_first_path() -> void:
	"""Evolve to the first available path"""
	if evolution_state and evolution_state.can_become.size() > 0:
		var first_path = evolution_state.can_become[0]
		if has_method("evolve_to"):
			evolve_to(first_path)
			print("🔀 Evolved to: %s" % first_path)
		else:
			print("❌ Evolution method not available")
	else:
		print("🔀 No evolution paths to evolve to")

func list_components() -> void:
	"""List attached components"""
	if has_method("get_components"):
		var components = get_components()
		print("🧩 Components attached to %s:" % being_name)
		for component in components:
			print("  - %s" % component.name)
	else:
		print("🧩 Component system not available")