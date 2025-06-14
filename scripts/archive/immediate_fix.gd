extends Node

# IMMEDIATE FIX for SystemBootstrap.gd
# Copy these functions and replace them in your existing file

var UniversalBeingClass = null
var FloodGatesClass = null
var AkashicRecordsSystemSystemClass = null
var core_loaded: bool = false
var flood_gates_instance = null
var akashic_records_instance = null
var systems_ready: bool = false
var system_ready = Signal()
var system_error = Signal()
var startup_time: float = 0.0
var initialization_errors: Array = []

# Replace the existing load_core_classes() function with this:
func load_core_classes() -> void:
	"""Load core class resources with validation"""
	print("🚀 SystemBootstrap: Loading core classes...")

	
	# Check and load UniversalBeing
	var ub_path = "res://core/UniversalBeing.gd"
	if ResourceLoader.exists(ub_path):
		UniversalBeingClass = load(ub_path)
		if UniversalBeingClass:
			print("🚀 SystemBootstrap: ✅ UniversalBeing loaded")
		else:
			print("🚀 SystemBootstrap: ❌ UniversalBeing load failed")
	else:
		print("🚀 SystemBootstrap: ❌ UniversalBeing.gd not found at %s" % ub_path)

	
	# Check and load FloodGates
	var fg_path = "res://core/FloodGates.gd"
	if ResourceLoader.exists(fg_path):
		FloodGatesClass = load(fg_path)
		if FloodGatesClass:
			print("🚀 SystemBootstrap: ✅ FloodGates loaded")
		else:
			print("🚀 SystemBootstrap: ❌ FloodGates load failed")
	else:
		print("🚀 SystemBootstrap: ❌ FloodGates.gd not found at %s" % fg_path)

	
	# Check and load AkashicRecordsSystemSystem
	var ar_path = "res://systems/storage/AkashicRecordsSystem.gd"
	if ResourceLoader.exists(ar_path):
		AkashicRecordsSystemSystemClass = load(ar_path)
		if AkashicRecordsSystemSystemClass:
			print("🚀 SystemBootstrap: ✅ AkashicRecordsSystemSystem loaded")
		else:
			print("🚀 SystemBootstrap: ❌ AkashicRecordsSystemSystem load failed")
	else:
		print("🚀 SystemBootstrap: ❌ AkashicRecordsSystemSystem.gd not found at %s" % ar_path)

	
	# Update core_loaded status
	core_loaded = UniversalBeingClass != null and FloodGatesClass != null and AkashicRecordsSystemSystemClass != null
	
	if core_loaded:
		print("🚀 SystemBootstrap: ✅ All core classes loaded!")
	else:
		print("🚀 SystemBootstrap: ❌ Some core classes missing")
		if not UniversalBeingClass: print("   - Missing: UniversalBeing")
		if not FloodGatesClass: print("   - Missing: FloodGates")
		if not AkashicRecordsSystemSystemClass: print("   - Missing: AkashicRecordsSystemSystem")

