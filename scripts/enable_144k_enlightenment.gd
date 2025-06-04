# ==================================================
# SCRIPT: enable_144k_enlightenment.gd
# PURPOSE: Enable 144,000 Universal Beings capacity with optimization
# USAGE: Run this script to upgrade your FloodGates to Quantum scale
# ==================================================

extends Node

func _ready() -> void:
	print("🌟 Enabling 144,000 Enlightened Beings...")
	_upgrade_to_quantum_system()

func _upgrade_to_quantum_system() -> void:
	"""Upgrade the system to handle 144,000 beings"""
	
	# Check if SystemBootstrap exists
	var bootstrap = get_node("/root/SystemBootstrap")
	if not bootstrap:
		print("❌ SystemBootstrap not found - cannot upgrade")
		return
	
	# Get current FloodGates
	var current_flood_gates = bootstrap.get_flood_gates()
	if not current_flood_gates:
		print("❌ FloodGates not found - cannot upgrade")
		return
	
	print("🔄 Upgrading FloodGates to QuantumFloodGates...")
	
	# Create QuantumFloodGates instance
	var QuantumFloodGatesClass = load("res://systems/optimization/QuantumFloodGates.gd")
	if not QuantumFloodGatesClass:
		print("❌ QuantumFloodGates script not found")
		return
	
	var quantum_flood_gates = QuantumFloodGatesClass.new()
	quantum_flood_gates.name = "QuantumFloodGates"
	
	# Transfer existing beings to quantum system
	_transfer_beings_to_quantum(current_flood_gates, quantum_flood_gates)
	
	# Replace in SystemBootstrap
	bootstrap.remove_child(current_flood_gates)
	bootstrap.add_child(quantum_flood_gates)
	bootstrap.flood_gates_instance = quantum_flood_gates
	
	# Create EnlightenedGroupManager
	var EnlightenedGroupManagerClass = load("res://systems/optimization/EnlightenedGroupManager.gd")
	if EnlightenedGroupManagerClass:
		var group_manager = EnlightenedGroupManagerClass.new()
		group_manager.name = "EnlightenedGroupManager"
		add_child(group_manager)
		print("✅ EnlightenedGroupManager activated")
	
	print("✅ 144,000 Enlightened Beings system activated!")
	print("🌟 Your universe can now hold the mystical number of conscious entities!")
	
	# Show current status
	_show_enlightenment_status(quantum_flood_gates)

func _transfer_beings_to_quantum(old_flood_gates: Node, quantum_flood_gates: Node) -> void:
	"""Transfer existing beings to quantum system"""
	if not old_flood_gates.has_method("get_registered_beings"):
		print("⚠️ Cannot transfer beings - old FloodGates missing method")
		return
	
	var existing_beings = old_flood_gates.get("being_registry")
	if not existing_beings:
		print("📝 No existing beings to transfer")
		return
	
	print("🔄 Transferring %d beings to quantum system..." % existing_beings.size())
	
	for being in existing_beings:
		if is_instance_valid(being):
			quantum_flood_gates.register_being(being)
	
	print("✅ Being transfer complete")

func _show_enlightenment_status(quantum_flood_gates: Node) -> void:
	"""Show current enlightenment status"""
	if not quantum_flood_gates.has_method("get_enlightenment_status"):
		return
		
	var status = quantum_flood_gates.get_enlightenment_status()
	
	print("🌟 === ENLIGHTENMENT STATUS ===")
	print("📊 Beings: %d / %d (%.1f%% capacity)" % [
		status.total_beings,
		status.enlightenment_capacity, 
		status.enlightenment_percentage
	])
	print("🎮 Performance: %.1fms (target: %.1fms)" % [
		status.performance.last_frame_time_ms,
		status.performance.target_frame_time_ms
	])
	print("✨ Mystical Readiness: %s" % ("YES" if status.mystical_readiness else "Not yet"))
	
	if status.enlightenment_percentage >= 100.0:
		print("🌌 FULL ENLIGHTENMENT ACHIEVED! 144,000 souls united!")
	elif status.enlightenment_percentage >= 50.0:
		print("🌟 Over halfway to full enlightenment!")
	elif status.enlightenment_percentage >= 10.0:
		print("💫 Building toward enlightenment...")
	else:
		print("🌱 Early stages of consciousness expansion")

# Utility function to create many beings for testing
func create_test_enlightenment(count: int = 1000) -> void:
	"""Create many test beings to approach enlightenment"""
	print("🧪 Creating %d test beings for enlightenment testing..." % count)
	
	var bootstrap = get_node("/root/SystemBootstrap")
	if not bootstrap:
		print("❌ Cannot create test beings - SystemBootstrap not found")
		return
	
	var quantum_flood_gates = bootstrap.get_flood_gates()
	if not quantum_flood_gates:
		print("❌ Cannot create test beings - QuantumFloodGates not found")
		return
	
	for i in count:
		var test_being = preload("res://core/UniversalBeing.gd").new()
		test_being.name = "TestBeing_%d" % i
		test_being.being_name = "Test Being %d" % i
		test_being.consciousness_level = randi() % 6  # Random consciousness 0-5
		
		# Spread them out in space for LOD testing
		test_being.position = Vector3(
			randf_range(-1000, 1000),
			randf_range(-100, 100), 
			randf_range(-1000, 1000)
		)
		
		get_tree().current_scene.add_child(test_being)
		
		# Brief pause every 100 beings to avoid frame drops
		if i % 100 == 0:
			await get_tree().process_frame
			print("🌟 Created %d / %d beings..." % [i + 1, count])
	
	print("✅ Test beings created! Enlightenment testing ready!")
	_show_enlightenment_status(quantum_flood_gates)