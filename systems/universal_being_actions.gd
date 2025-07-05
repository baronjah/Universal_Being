extends Node3D
class_name UniversalBeingActions

# 🌳 UNIVERSAL BEING ACTION SYSTEM 🌳
# Tree makes fruit → Astral being eats fruit → Evolution chains
# Tasks, automations, todos evolved into consciousness states

signal action_initiated(being_id: String, action_type: String)
signal action_completed(being_id: String, action_result: Dictionary)
signal state_changed(being_id: String, old_state: String, new_state: String)
signal evolution_triggered(being_id: String, evolution_path: Array)

# ACTION SYSTEM CORE
@export var actions_enabled: bool = true
@export var autonomous_behavior: bool = true
@export var consciousness_driven_actions: bool = true

# BEING STATE MANAGEMENT
var being_states: Dictionary = {}
var action_trees: Dictionary = {}
var evolution_chains: Dictionary = {}
var goal_systems: Dictionary = {}

# TASK/TODO EVOLUTION INTO CONSCIOUSNESS
enum BeingState {
	DORMANT,
	SEEKING,
	ACTING,
	CREATING,
	EVOLVING,
	TRANSCENDING
}

enum ActionType {
	MOVE_TO,
	CREATE_THING,
	CONSUME_THING,
	INTERACT_WITH,
	EVOLVE_FORM,
	MANIFEST_REALITY,
	CONNECT_TO_BEING
}

class ActionNode:
	var action_id: String
	var action_type: ActionType
	var target: Node3D
	var steps: Array[ActionStep] = []
	var prerequisites: Array[String] = []
	var success_conditions: Dictionary = {}
	var evolution_result: String = ""
	
	func _init(id: String, type: ActionType):
		action_id = id
		action_type = type

class ActionStep:
	var step_id: String
	var description: String
	var execute_function: Callable
	var completion_check: Callable
	var consciousness_requirement: float = 1.0
	
	func _init(id: String, desc: String):
		step_id = id
		description = desc

class BeingGoalSystem:
	var primary_goal: String
	var sub_goals: Array[String] = []
	var goal_progress: Dictionary = {}
	var goal_tree: Dictionary = {}
	
	func _init(goal: String):
		primary_goal = goal
		_generate_goal_tree()
	
	func _generate_goal_tree():
		match primary_goal:
			"tree_make_fruit":
				sub_goals = ["gather_nutrients", "grow_branches", "manifest_fruit", "ripen_fruit"]
				goal_tree = {
					"gather_nutrients": ["extend_roots", "absorb_sunlight", "collect_water"],
					"grow_branches": ["strengthen_trunk", "extend_limbs", "create_fruit_nodes"],
					"manifest_fruit": ["channel_life_energy", "form_fruit_body", "imbue_consciousness"],
					"ripen_fruit": ["mature_fruit", "emanate_attraction", "prepare_for_harvest"]
				}
			"astral_eat_fruit":
				sub_goals = ["locate_fruit", "approach_tree", "request_fruit", "consume_consciousness"]
				goal_tree = {
					"locate_fruit": ["scan_environment", "detect_life_signatures", "identify_ripe_fruit"],
					"approach_tree": ["navigate_to_tree", "respectful_approach", "establish_connection"],
					"request_fruit": ["communicate_intent", "offer_exchange", "receive_permission"],
					"consume_consciousness": ["absorb_fruit_essence", "integrate_consciousness", "evolve_being"]
				}

# EXAMPLE: Tree Universal Being Action System
class TreeBeingActions:
	extends ActionNode
	
	var tree_consciousness: float = 2.0
	var fruit_creation_energy: float = 100.0
	var nutrient_level: float = 50.0
	
	func _init():
		super("tree_fruit_creation", ActionType.CREATE_THING)
		_setup_fruit_creation_steps()
	
	func _setup_fruit_creation_steps():
		# Step 1: Gather nutrients
		var gather_step = ActionStep.new("gather_nutrients", "Extend roots and absorb earth energy")
		gather_step.execute_function = _gather_nutrients
		gather_step.completion_check = _check_nutrient_levels
		steps.append(gather_step)
		
		# Step 2: Channel life force
		var channel_step = ActionStep.new("channel_life", "Channel consciousness into fruit formation")
		channel_step.execute_function = _channel_life_force
		channel_step.completion_check = _check_life_force
		steps.append(channel_step)
		
		# Step 3: Manifest fruit
		var manifest_step = ActionStep.new("manifest_fruit", "Bring fruit into physical reality")
		manifest_step.execute_function = _manifest_fruit
		manifest_step.completion_check = _check_fruit_existence
		steps.append(manifest_step)
	
	func _gather_nutrients() -> bool:
		nutrient_level += 25.0
		print("🌳 Tree extends roots, absorbing earth's wisdom...")
		return nutrient_level >= 75.0
	
	func _channel_life_force() -> bool:
		fruit_creation_energy += tree_consciousness * 10.0
		print("✨ Tree channels life force into fruit creation...")
		return fruit_creation_energy >= 120.0
	
	func _manifest_fruit() -> bool:
		print("🍎 Tree manifests consciousness fruit!")
		return true
	
	func _check_nutrient_levels() -> bool:
		return nutrient_level >= 75.0
	
	func _check_life_force() -> bool:
		return fruit_creation_energy >= 120.0
	
	func _check_fruit_existence() -> bool:
		return true  # Fruit has been created

# EXAMPLE: Astral Being Action System
class AstralBeingActions:
	extends ActionNode
	
	var astral_consciousness: float = 3.0
	var hunger_level: float = 80.0
	var target_tree: Node3D = null
	
	func _init():
		super("astral_consume_fruit", ActionType.CONSUME_THING)
		_setup_consumption_steps()
	
	func _setup_consumption_steps():
		# Step 1: Locate fruit tree
		var locate_step = ActionStep.new("locate_tree", "Scan reality for consciousness fruit")
		locate_step.execute_function = _locate_fruit_tree
		locate_step.completion_check = _check_tree_found
		steps.append(locate_step)
		
		# Step 2: Approach respectfully
		var approach_step = ActionStep.new("approach_tree", "Float to tree with respectful intent")
		approach_step.execute_function = _approach_tree
		approach_step.completion_check = _check_near_tree
		steps.append(approach_step)
		
		# Step 3: Consume fruit consciousness
		var consume_step = ActionStep.new("consume_fruit", "Absorb fruit's consciousness essence")
		consume_step.execute_function = _consume_fruit_consciousness
		consume_step.completion_check = _check_consumption_complete
		steps.append(consume_step)
	
	func _locate_fruit_tree() -> bool:
		print("👻 Astral being scans reality for consciousness fruit...")
		# Find tree in scene
		var scene_root = get_tree().current_scene
		for child in scene_root.get_children():
			if child.has_method("get_fruit_availability"):
				target_tree = child
				break
		return target_tree != null
	
	func _approach_tree() -> bool:
		if target_tree:
			print("🌟 Astral being floats toward the consciousness tree...")
			# Move toward tree
			return true
		return false
	
	func _consume_fruit_consciousness() -> bool:
		print("✨ Astral being absorbs fruit consciousness, evolving...")
		hunger_level -= 50.0
		astral_consciousness += 0.5
		return true
	
	func _check_tree_found() -> bool:
		return target_tree != null
	
	func _check_near_tree() -> bool:
		return true  # Simplified
	
	func _check_consumption_complete() -> bool:
		return hunger_level <= 30.0

func _ready():
	name = "UniversalBeingActions"
	print("🎭 UNIVERSAL BEING ACTION SYSTEM INITIALIZING...")
	
	# Initialize action systems
	_initialize_action_frameworks()
	
	# Register with FloodGates
	_register_with_flood_gates()
	
	print("🌟 ACTION SYSTEM READY - BEINGS CAN NOW ACT!")

func _initialize_action_frameworks():
	"""Initialize action frameworks for all universal beings"""
	
	# Create example tree being
	var tree_actions = TreeBeingActions.new()
	action_trees["tree_being"] = tree_actions
	
	# Create example astral being
	var astral_actions = AstralBeingActions.new()
	action_trees["astral_being"] = astral_actions
	
	print("🌳 Tree action system ready")
	print("👻 Astral being action system ready")

func _register_with_flood_gates():
	"""Register action system with FloodGates"""
	var flood_gates = SystemBootstrap.get_flood_gates()
	if flood_gates:
		flood_gates.register_action_system(self)
		print("🌊 Actions registered with FloodGates")

func execute_being_action(being_id: String, action_type: String) -> bool:
	"""Execute an action for a specific being"""
	if not action_trees.has(being_id):
		print("❌ No action tree found for being:", being_id)
		return false
	
	var action_tree = action_trees[being_id]
	print("🎭 Executing action:", action_type, "for being:", being_id)
	
	action_initiated.emit(being_id, action_type)
	
	# Execute action steps
	for step in action_tree.steps:
		print("🔄 Executing step:", step.description)
		var success = step.execute_function.call()
		if not success:
			print("❌ Step failed:", step.step_id)
			return false
		
		# Check completion
		if step.completion_check.call():
			print("✅ Step completed:", step.step_id)
		else:
			print("⏳ Step in progress:", step.step_id)
	
	print("🌟 Action completed successfully!")
	action_completed.emit(being_id, {"success": true, "action": action_type})
	return true

func create_being_action_tree(being_id: String, goal: String) -> BeingGoalSystem:
	"""Create action tree for a universal being based on its goal"""
	var goal_system = BeingGoalSystem.new(goal)
	goal_systems[being_id] = goal_system
	
	print("🌳 Created action tree for:", being_id, "with goal:", goal)
	return goal_system

func update_being_state(being_id: String, new_state: BeingState):
	"""Update consciousness state of a universal being"""
	var old_state = being_states.get(being_id, BeingState.DORMANT)
	being_states[being_id] = new_state
	
	print("🔄 Being state changed:", being_id, "from", old_state, "to", new_state)
	state_changed.emit(being_id, str(old_state), str(new_state))

func trigger_evolution_chain(being_id: String, trigger_event: String):
	"""Trigger evolution based on completed actions"""
	if not evolution_chains.has(being_id):
		evolution_chains[being_id] = []
	
	evolution_chains[being_id].append(trigger_event)
	
	print("🌟 Evolution triggered for:", being_id, "by event:", trigger_event)
	evolution_triggered.emit(being_id, evolution_chains[being_id])

# CONSOLE COMMANDS INTEGRATION
func _register_console_commands():
	"""Register action commands with console system"""
	var console = get_node("/root/Console")
	if console and console.has_method("register_command"):
		console.register_command("tree_fruit", create_tree_fruit_action)
		console.register_command("astral_eat", create_astral_eat_action)
		console.register_command("being_action", execute_custom_being_action)
		print("📡 Action commands registered with console")

func create_tree_fruit_action(args: Array):
	"""Console command: Create fruit action for tree"""
	execute_being_action("tree_being", "create_fruit")

func create_astral_eat_action(args: Array):
	"""Console command: Astral being eats fruit"""
	execute_being_action("astral_being", "consume_fruit")

func execute_custom_being_action(args: Array):
	"""Console command: Execute custom action"""
	if args.size() >= 2:
		execute_being_action(args[0], args[1])

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F:  # Fruit creation
				execute_being_action("tree_being", "create_fruit")
			KEY_H:  # Hunger (astral eat)
				execute_being_action("astral_being", "consume_fruit")
			KEY_A:  # Action demo
				_demonstrate_action_chain()

func _demonstrate_action_chain():
	"""Demonstrate complete action chain: Tree creates → Astral consumes"""
	print("🎭 DEMONSTRATING UNIVERSAL BEING ACTION CHAIN...")
	
	# Tree creates fruit
	execute_being_action("tree_being", "create_fruit")
	
	# Wait a moment, then astral being acts
	await get_tree().create_timer(2.0).timeout
	
	# Astral being consumes fruit
	execute_being_action("astral_being", "consume_fruit")
	
	print("✨ ACTION CHAIN COMPLETE - CONSCIOUSNESS EVOLVED!")