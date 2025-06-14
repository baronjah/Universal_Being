# ==================================================
# SCRIPT NAME: universal_being_base_enhanced.gd
# DESCRIPTION: Enhanced Pentagon Base with dependency queue integration
# PURPOSE: Add queue system support to UniversalBeingBase
# CREATED: 2025-06-01 - Pentagon dependency resolution enhancement
# ==================================================

extends UniversalBeingBase
class_name UniversalBeingBaseEnhanced

# Pentagon dependency queue integration
var pentagon_queue: PentagonInitializationQueue = null
var dependencies_registered: bool = false
var initialization_complete: bool = false

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Get Pentagon queue system
	pentagon_queue = get_node_or_null("/root/PentagonInitializationQueue")
	if pentagon_queue:
		print("🏛️ [%s] Connected to Pentagon Initialization Queue" % name)
	
	# Call Pentagon ready with dependency support
	pentagon_ready_with_dependencies()

func pentagon_ready_with_dependencies() -> void:
	"""Enhanced pentagon_ready that handles dependencies"""
	# Check if we need to register dependencies
	var required_nodes = get_pentagon_dependencies()
	
	if required_nodes.is_empty():
		# No dependencies - proceed with normal initialization
		pentagon_ready()
		initialization_complete = true
	else:
		# Has dependencies - register with queue system
		if pentagon_queue and not dependencies_registered:
			var system_name = name + "_" + get_script().resource_path.get_file().get_basename()
			pentagon_queue.register_pentagon_dependency(
				system_name,
				required_nodes,
				_delayed_pentagon_ready,
				self
			)
			dependencies_registered = true
			print("📋 [%s] Registered dependencies: %s" % [name, str(required_nodes)])
		else:
			# No queue system - try direct initialization
			pentagon_ready()

func _delayed_pentagon_ready() -> bool:
	"""Called by queue system when dependencies are met"""
	if not is_inside_tree() or not is_instance_valid(self):
		return false
	
	# Check dependencies one more time
	var required_nodes = get_pentagon_dependencies()
	for node_path in required_nodes:
		if not has_node(node_path) and get_node_or_null(node_path) == null:
			print("⚠️ [%s] Dependency still missing: %s" % [name, node_path])
			return false
	
	# All dependencies available - proceed
	pentagon_ready()
	initialization_complete = true
	print("✅ [%s] Pentagon initialization complete with dependencies" % name)
	return true

# ===== OVERRIDE THESE IN CHILD CLASSES =====

func get_pentagon_dependencies() -> Array[String]:
	"""Override this to specify required node paths"""
	# Example return: ["/root/ConsoleManager", "/root/FloodgateController", "SomeChildNode"]
	return []

func pentagon_ready() -> void:
	"""Override this for your Pentagon ready logic"""
	# Your initialization code here
	pass

# ===== DEPENDENCY HELPERS =====

func require_node(node_path: String) -> Node:
	"""Safe node getter that waits for dependencies"""
	var node = get_node_or_null(node_path)
	if not node:
		# Try again through queue system if available
		if pentagon_queue and initialization_complete:
			push_warning("[%s] Required node missing after initialization: %s" % [name, node_path])
	return node

func require_autoload(autoload_name: String) -> Node:
	"""Safe autoload getter"""
	return require_node("/root/" + autoload_name)

func wait_for_node(node_path: String, callback: Callable) -> void:
	"""Wait for a specific node to exist, then call callback"""
	if pentagon_queue:
		pentagon_queue.register_pentagon_dependency(
			name + "_wait_" + node_path.replace("/", "_"),
			[node_path],
			callback,
			self
		)

# ===== PENTAGON PATTERN WITH QUEUE SUPPORT =====

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	"""Pentagon initialization - always safe to override"""
	pass

func _process(delta: float) -> void:
	if initialization_complete:
		pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	"""Pentagon processing - only runs after dependencies met"""
	pass

func _input(event: InputEvent) -> void:
	if initialization_complete:
		pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	"""Pentagon input - only runs after dependencies met"""
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	"""Pentagon cleanup - always safe to run"""
	pass

# ===== CONVENIENCE METHODS =====

func is_pentagon_ready() -> bool:
	"""Check if Pentagon initialization is complete"""
	return initialization_complete

func get_pentagon_status() -> String:
	"""Get current Pentagon status"""
	if initialization_complete:
		return "complete"
	elif dependencies_registered:
		return "pending_dependencies"
	else:
		return "not_initialized"

func force_pentagon_retry() -> void:
	"""Force retry Pentagon initialization"""
	if pentagon_queue and dependencies_registered:
		var system_name = name + "_" + get_script().resource_path.get_file().get_basename()
		pentagon_queue.force_retry_system(system_name)