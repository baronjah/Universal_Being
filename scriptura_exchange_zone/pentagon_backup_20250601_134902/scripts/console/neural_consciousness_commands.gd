# ==================================================
# SCRIPT NAME: neural_consciousness_commands.gd
# DESCRIPTION: Console commands for testing neural consciousness evolution
# PURPOSE: Test the new Universal Being consciousness system
# CREATED: 2025-05-30 - Neural evolution testing
# ==================================================

extends UniversalBeingBase
# Console command registration
func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	var console = get_node_or_null("/root/Console")
	if console and console.has_method("register_command"):
		console.register_command("neural_evolve", _cmd_neural_evolve, "Evolve a Universal Being to have consciousness")
		console.register_command("neural_status", _cmd_neural_status, "Show consciousness status of all beings")
		console.register_command("neural_test", _cmd_neural_test, "Create test scenario with conscious beings")
		console.register_command("neural_connect", _cmd_neural_connect, "Connect two conscious beings")
		console.register_command("consciousness_demo", _cmd_consciousness_demo, "Run full consciousness demonstration")
		print("🧠 Neural consciousness commands registered!")

func _cmd_neural_evolve(args: Array) -> String:
	"""Evolve a Universal Being to consciousness: neural_evolve <being_id> [level]"""
	if args.size() < 1:
		return "Usage: neural_evolve <being_id> [level]"
	
	var being_id = args[0]
	var level = int(args[1]) if args.size() > 1 else 1
	
	# Find the being
	var being = _find_universal_being(being_id)
	if not being:
		return "Universal Being not found: " + being_id
	
	# Evolve to consciousness
	being.become_conscious(level)
	
	return "✨ Evolved " + being.name + " to consciousness level " + str(level)

func _cmd_neural_status(_args: Array) -> String:
	"""Show consciousness status of all Universal Beings"""
	var beings = _find_all_universal_beings()
	if beings.size() == 0:
		return "No Universal Beings found"
	
	var status = "🧠 CONSCIOUSNESS STATUS:\n"
	for being in beings:
		if being.has_method("get_consciousness_status"):
			status += "• " + being.name + ": " + being.get_consciousness_status() + "\n"
		else:
			status += "• " + being.name + ": No consciousness system\n"
	
	return status

func _cmd_neural_test(_args: Array) -> String:
	"""Create a test scenario with conscious beings"""
	var scene_root = get_tree().current_scene
	
	# Create conscious tree
	var tree = UniversalBeing.new()
	tree.become("tree")
	tree.become_conscious(2)  # Advanced consciousness
	tree.global_position = Vector3(0, 0, 0)
	FloodgateController.universal_add_child(tree, scene_root)
	
	# Create conscious astral being
	var astral = UniversalBeing.new()
	astral.become("astral_being")
	astral.become_conscious(2)  # Advanced consciousness
	astral.global_position = Vector3(5, 1, 0)
	FloodgateController.universal_add_child(astral, scene_root)
	
	# Create conscious ragdoll
	var ragdoll = UniversalBeing.new()
	ragdoll.become("ragdoll")
	ragdoll.become_conscious(1)  # Basic consciousness
	ragdoll.global_position = Vector3(-5, 1, 0)
	FloodgateController.universal_add_child(ragdoll, scene_root)
	
	# Try to connect to existing ragdoll body
	var existing_ragdoll = scene_root.get_node_or_null("SevenPartRagdoll")
	if existing_ragdoll:
		ragdoll.connect_to_body(existing_ragdoll)
	
	return "🧪 Neural test scenario created:\n" + \
		   "• Tree (Level 2) - Will grow conscious fruit\n" + \
		   "• Astral Being (Level 2) - Will seek fruit\n" + \
		   "• Ragdoll (Level 1) - Will practice movement"

func _cmd_neural_connect(args: Array) -> String:
	"""Connect two conscious beings: neural_connect <being1_id> <being2_id>"""
	if args.size() < 2:
		return "Usage: neural_connect <being1_id> <being2_id>"
	
	var being1 = _find_universal_being(args[0])
	var being2 = _find_universal_being(args[1])
	
	if not being1:
		return "First being not found: " + args[0]
	if not being2:
		return "Second being not found: " + args[1]
	
	if not being1.is_conscious or not being2.is_conscious:
		return "Both beings must be conscious to connect"
	
	being1.connect_neural_network(being2)
	
	return "🔗 Connected " + being1.name + " and " + being2.name + " via neural network"

func _cmd_consciousness_demo(_args: Array) -> String:
	"""Run a full consciousness demonstration with brain-body connections"""
	var scene_root = get_tree().current_scene
	
	# Create conscious tree that grows fruit
	var tree = UniversalBeing.new()
	tree.become("tree")
	tree.become_conscious(2)
	tree.global_position = Vector3(0, 0, 0)
	tree.name = "ConsciousTree"
	FloodgateController.universal_add_child(tree, scene_root)
	
	# Create conscious astral being that seeks food
	var astral = UniversalBeing.new()
	astral.become("astral_being")
	astral.become_conscious(2)
	astral.global_position = Vector3(8, 2, 0)
	astral.name = "ConsciousAstral"
	FloodgateController.universal_add_child(astral, scene_root)
	
	# Try to connect astral to existing bird body
	var bird_body = scene_root.get_node_or_null("TriangularBird")
	if bird_body:
		astral.connect_to_body(bird_body)
		astral.form = "bird"  # Update form to match body
	
	# Create conscious ragdoll connected to physics body
	var ragdoll_being = UniversalBeing.new()
	ragdoll_being.become("ragdoll")
	ragdoll_being.become_conscious(1)
	ragdoll_being.global_position = Vector3(-5, 1, 0)
	ragdoll_being.name = "ConsciousRagdoll"
	FloodgateController.universal_add_child(ragdoll_being, scene_root)
	
	# Connect to existing ragdoll system
	var physics_ragdoll = scene_root.get_node_or_null("SevenPartRagdoll")
	if physics_ragdoll:
		ragdoll_being.connect_to_body(physics_ragdoll)
	
	# Connect all beings in neural network
	tree.connect_neural_network(astral)
	astral.connect_neural_network(ragdoll_being)
	
	# Start consciousness processing
	for being in [tree, astral, ragdoll_being]:
		being.set_process(true)
		# Force initial thinking
		being.think_and_act(0.1)
	
	return "🌟 CONSCIOUSNESS DEMO STARTED!\n\n" + \
		   "🌳 Tree: Will grow conscious fruit over time\n" + \
		   "👻 Astral: Will seek and consume fruit (connected to bird if available)\n" + \
		   "🦴 Ragdoll: Will practice balance and movement (connected to physics)\n" + \
		   "🔗 All beings connected via neural network\n\n" + \
		   "Watch the console for consciousness activities!"

# Helper functions
func _find_universal_being(identifier: String) -> UniversalBeing:
	"""Find Universal Being by name or partial match"""
	var beings = _find_all_universal_beings()
	
	# Exact name match first
	for being in beings:
		if being.name == identifier:
			return being
	
	# Partial match
	for being in beings:
		if identifier.to_lower() in being.name.to_lower():
			return being
	
	return null

func _find_all_universal_beings() -> Array[UniversalBeing]:
	"""Find all Universal Beings in the scene"""
	var beings: Array[UniversalBeing] = []
	_search_for_beings(get_tree().current_scene, beings)
	return beings

func _search_for_beings(node: Node, beings: Array[UniversalBeing]) -> void:
	"""Recursively search for Universal Beings"""
	if node is UniversalBeing:
		beings.append(node)
	
	for child in node.get_children():
		_search_for_beings(child, beings)

# Test the consciousness processing with manual triggers

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func test_consciousness_cycle() -> String:
	"""Manually trigger consciousness processing for testing"""
	var beings = _find_all_universal_beings()
	var results = []
	
	for being in beings:
		if being.is_conscious and being.has_method("think_and_act"):
			being.think_and_act(1.0)  # Force a thinking cycle
			results.append(being.name + ": " + being.get_consciousness_status())
	
	if results.size() == 0:
		return "No conscious beings found for testing"
	
	return "🔄 CONSCIOUSNESS CYCLE RESULTS:\n" + "\n".join(results)