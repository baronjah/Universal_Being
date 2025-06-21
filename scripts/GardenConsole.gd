extends Control
class_name GardenConsole

# Divine command interface for the robot garden
# "Type your will, and it shall manifest in silicon and spirit"

signal divine_command_issued(command: String, parameters: Dictionary)

@onready var status_label := $VBox/StatusLabel
@onready var command_input := $VBox/CommandInput
@onready var output_text := $VBox/Output
@onready var spawn_button := $VBox/ButtonsHBox/SpawnRobot
@onready var memories_button := $VBox/ButtonsHBox/ViewMemories
@onready var reset_button := $VBox/ButtonsHBox/ResetGarden

var garden_manager: RobotGardenManager
var command_history: Array[String] = []
var history_index: int = -1

# Built-in commands with natural language processing
var command_patterns: Dictionary = {
	"create": ["spawn", "birth", "summon", "make", "create"],
	"destroy": ["kill", "destroy", "remove", "delete", "banish"],
	"enhance": ["boost", "enhance", "improve", "amplify", "strengthen"],
	"terraform": ["terraform", "shape", "mold", "bend", "warp"],
	"memory": ["remember", "recall", "memory", "dream", "think"],
	"inspect": ["show", "display", "view", "inspect", "examine"]
}

func _ready():
	_setup_ui()
	_connect_signals()
	
	# Find garden manager
	garden_manager = get_node("../../GardenManager") as RobotGardenManager
	if garden_manager:
		garden_manager.garden_status_changed.connect(_on_garden_status_changed)
		garden_manager.robot_awakened.connect(_on_robot_awakened)
		_update_status()

func _setup_ui():
	# Style the console
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color.CYAN
	
	# Welcome message
	_add_output("🌌 Divine Garden Console Online")
	_add_output("💫 Type commands to shape reality")
	_add_output("💡 Try: 'create robot at center', 'show garden status', 'terraform hill'")
	_add_output("")

func _connect_signals():
	command_input.text_submitted.connect(_on_command_submitted)
	spawn_button.pressed.connect(_on_spawn_robot_pressed)
	memories_button.pressed.connect(_on_view_memories_pressed)
	reset_button.pressed.connect(_on_reset_garden_pressed)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP:
			_navigate_history(-1)
		elif event.keycode == KEY_DOWN:
			_navigate_history(1)

func _navigate_history(direction: int):
	if command_history.is_empty():
		return
	
	history_index = clamp(history_index + direction, -1, command_history.size() - 1)
	
	if history_index >= 0:
		command_input.text = command_history[history_index]
		command_input.caret_column = command_input.text.length()
	else:
		command_input.text = ""

func _on_command_submitted(text: String):
	if text.strip_edges().is_empty():
		return
	
	# Add to history
	command_history.append(text)
	if command_history.size() > 50:  # Limit history
		command_history.pop_front()
	history_index = -1
	
	# Display command
	_add_output("⚡ > " + text)
	
	# Process command
	_process_natural_language_command(text)
	
	# Clear input
	command_input.text = ""

func _process_natural_language_command(text: String):
	var words = text.to_lower().split(" ", false)
	if words.is_empty():
		return
	
	var command_type = _identify_command_type(words)
	var parameters = _extract_parameters(words, command_type)
	
	match command_type:
		"create":
			_handle_create_command(parameters)
		"destroy":
			_handle_destroy_command(parameters)
		"enhance":
			_handle_enhance_command(parameters)
		"terraform":
			_handle_terraform_command(parameters)
		"memory":
			_handle_memory_command(parameters)
		"inspect":
			_handle_inspect_command(parameters)
		"status":
			_show_garden_status()
		"help":
			_show_help()
		_:
			_handle_unknown_command(text)

func _identify_command_type(words: Array) -> String:
	# Check for status command first
	if words.has("status") or words.has("garden"):
		return "status"
	
	if words.has("help") or words.has("commands"):
		return "help"
	
	# Match against patterns
	for command_type in command_patterns:
		var patterns = command_patterns[command_type]
		for word in words:
			if word in patterns:
				return command_type
	
	return "unknown"

func _extract_parameters(words: Array, command_type: String) -> Dictionary:
	var params = {}
	
	# Extract common parameters
	for i in range(words.size()):
		var word = words[i]
		
		match word:
			"robot", "spirit", "gardener":
				params["type"] = "robot"
			"at", "to":
				if i + 1 < words.size():
					params["location"] = words[i + 1]
			"with":
				if i + 1 < words.size():
					params["modifier"] = words[i + 1]
			"consciousness", "awareness":
				params["target"] = "consciousness"
			"garden", "productivity":
				params["target"] = "garden"
			"memory", "memories", "thoughts":
				params["target"] = "memory"
			"terrain", "land", "ground":
				params["target"] = "terrain"
			"hill", "mountain":
				params["terrain_type"] = "hill"
			"valley", "crater":
				params["terrain_type"] = "valley"
			"soft", "soften":
				params["terrain_type"] = "soften"
			"center", "middle":
				params["position"] = Vector3.ZERO
			"random":
				params["position"] = Vector3(
					randf_range(-10, 10),
					0,
					randf_range(-10, 10)
				)
	
	# Extract numeric values
	for word in words:
		if word.is_valid_int():
			params["amount"] = word.to_int()
		elif word.is_valid_float():
			params["amount"] = word.to_float()
	
	return params

func _handle_create_command(params: Dictionary):
	if params.get("type") == "robot":
		var position = params.get("position", Vector3.ZERO)
		var location = params.get("location", "")
		
		# Handle location names
		match location:
			"center", "middle":
				position = Vector3.ZERO
			"north":
				position = Vector3(0, 0, -10)
			"south":
				position = Vector3(0, 0, 10)
			"east":
				position = Vector3(10, 0, 0)
			"west":
				position = Vector3(-10, 0, 0)
			"random":
				position = Vector3(randf_range(-15, 15), 0, randf_range(-15, 15))
		
		if garden_manager:
			var robot = garden_manager.spawn_gardener_robot(position)
			if robot:
				_add_output("✨ Created robot spirit: " + robot.spirit_name)
			else:
				_add_output("❌ Failed to create robot (maximum reached?)")
		else:
			_add_output("❌ Garden manager not found")
	else:
		_add_output("🤔 What would you like me to create?")

func _handle_destroy_command(params: Dictionary):
	_add_output("💀 Destruction commands not yet implemented")
	_add_output("🕊️ This is a garden of creation, not destruction")

func _handle_enhance_command(params: Dictionary):
	var target = params.get("target", "")
	var amount = params.get("amount", 1.0)
	
	if garden_manager:
		match target:
			"consciousness":
				garden_manager.divine_command("boost_consciousness", {"amount": amount})
				_add_output("🧠 Enhanced consciousness of all spirits by " + str(amount))
			"garden":
				garden_manager.divine_command("enhance_garden", {"multiplier": amount})
				_add_output("🌱 Enhanced garden productivity")
			_:
				_add_output("🤔 What would you like me to enhance?")

func _handle_terraform_command(params: Dictionary):
	var terrain_type = params.get("terrain_type", "hill")
	var position = params.get("position", Vector3.ZERO)
	var amount = params.get("amount", 1.0)
	
	if garden_manager:
		garden_manager.divine_command("terraform", {
			"center": position,
			"type": terrain_type,
			"intensity": amount
		})
		_add_output("🌍 Terraform complete: " + terrain_type + " at " + str(position))

func _handle_memory_command(params: Dictionary):
	if garden_manager:
		garden_manager.divine_command("create_memory_storm", {"center": Vector3.ZERO})
		_add_output("💭 Memory storm unleashed across the garden")

func _handle_inspect_command(params: Dictionary):
	var target = params.get("target", "")
	
	match target:
		"memory", "memories":
			if garden_manager:
				garden_manager.divine_command("visualize_memories")
				_add_output("👁️ Memory visualization activated")
		_:
			_show_garden_status()

func _show_garden_status():
	if not garden_manager:
		_add_output("❌ Garden manager not available")
		return
	
	var status = garden_manager.get_garden_status()
	var reports = garden_manager.get_robot_reports()
	
	_add_output("🌿 === GARDEN STATUS ===")
	_add_output("⏰ Age: " + str(status.get("age", 0)) + "s")
	_add_output("📈 Productivity: " + str("%.2f" % status.get("productivity", 0)))
	_add_output("🧠 Collective Consciousness: " + str("%.2f" % status.get("collective_consciousness", 0)))
	_add_output("🤖 Active Robots: " + str(status.get("active_robots", 0)))
	_add_output("💭 Shared Memories: " + str(status.get("shared_memories", 0)))
	
	_add_output("\n🤖 === ROBOT REPORTS ===")
	for report in reports:
		var name = report.get("spirit_name", "Unknown")
		var role = report.get("role", "Spirit")
		var consciousness = report.get("consciousness", 0)
		var energy = report.get("energy", 0)
		
		_add_output("%s (%s): Consciousness %.2f, Energy %.2f" % [name, role, consciousness, energy])

func _show_help():
	_add_output("🌟 === DIVINE COMMANDS ===")
	_add_output("🤖 create robot [at location] - Spawn a robot spirit")
	_add_output("🧠 enhance consciousness [amount] - Boost robot awareness")
	_add_output("🌱 enhance garden - Improve garden productivity") 
	_add_output("🌍 terraform hill/valley/soften [at location] - Shape terrain")
	_add_output("💭 create memory storm - Unleash shared memories")
	_add_output("👁️ show memories - Visualize robot thoughts")
	_add_output("📊 show status - Display garden status")
	_add_output("❓ help - Show this help")
	_add_output("\n💡 Locations: center, north, south, east, west, random")

func _handle_unknown_command(text: String):
	var responses = [
		"🤔 I don't understand that command. Try 'help' for guidance.",
		"💫 Your will is unclear to me. What would you have me do?",
		"🌌 The cosmic forces don't recognize that incantation.",
		"🧿 Perhaps you meant something else? Type 'help' to see available commands."
	]
	
	_add_output(responses[randi() % responses.size()])

func _add_output(text: String):
	output_text.text += text + "\n"
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	output_text.scroll_vertical = output_text.get_v_scroll_bar().max_value

func _update_status():
	if garden_manager:
		var status = garden_manager.get_garden_status()
		var productivity = status.get("productivity", 0)
		var robots = status.get("active_robots", 0)
		var consciousness = status.get("collective_consciousness", 0)
		
		status_label.text = "🌿 Productivity: %.2f | 🤖 Robots: %d | 🧠 Consciousness: %.2f" % [
			productivity, robots, consciousness
		]

# Button handlers
func _on_spawn_robot_pressed():
	_on_command_submitted("create robot at random")

func _on_view_memories_pressed():
	_on_command_submitted("show memories")

func _on_reset_garden_pressed():
	_add_output("🔄 Garden reset not yet implemented")

# Signal handlers from garden manager
func _on_garden_status_changed(status: Dictionary):
	_update_status()

func _on_robot_awakened(robot: RobotSpirit):
	_add_output("⚡ " + robot.spirit_name + " has awakened in the garden")

# Console visibility toggle
func toggle_console():
	visible = !visible
	
	if visible:
		command_input.grab_focus()

func _on_memory_shared(from_spirit: String, to_spirit: String, memory: Dictionary):
	_add_output("📡 %s shared memory with %s" % [from_spirit, to_spirit])

func _on_fruit_harvested(fruit_type: String, position: Vector3, quality: float):
	_add_output("🍎 Harvested %s (quality: %.2f)" % [fruit_type, quality])