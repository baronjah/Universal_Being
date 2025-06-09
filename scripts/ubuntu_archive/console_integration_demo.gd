extends Node
class_name JSHConsoleIntegrationDemo

# This script demonstrates how to integrate the Phase 4 Console System
# with the existing Menu_Keyboard_Console components

# References to JSH Console System
var console_manager: JSHConsoleManager = null
var console_ui: Control = null

# References to Legacy Console System
var legacy_console = null  # JSH_console.gd
var text_screen = null    # text_screen.gd

# References to Bank Systems
var records_bank = null
var actions_bank = null
var scenes_bank = null
var instructions_bank = null
var banks_combiner = null

# References to Other Systems
var digital_earthlings = null
var mainframe_database = null
var database_system = null
var marching_shapes = null
var snake_game = null
var task_manager = null

# Adapter instances
var legacy_adapter: JSHLegacyConsoleAdapter = null

# Integration status
var integration_status = {
	"console": {
		"jsh_ready": false,
		"legacy_ready": false,
		"adapter_ready": false
	},
	"banks": {
		"records": false,
		"actions": false,
		"scenes": false,
		"instructions": false,
		"combiner": false
	},
	"systems": {
		"entity": false,
		"database": false,
		"spatial": false,
		"task": false
	},
	"game": {
		"snake": false,
		"marching": false
	}
}

func _ready():
	# Set up JSH Console System
	_setup_jsh_console()
	
	# Load legacy console components
	_load_legacy_components()
	
	# Create adapter
	_create_adapter()
	
	# Register additional commands
	_register_integration_commands()
	
	# Print integration status
	_print_integration_status()

func _setup_jsh_console():
	# Get or create console manager
	console_manager = JSHConsoleManager.get_instance()
	
	# Load console UI
	var ui_scene = load("res://jsh_console_ui.tscn")
	if ui_scene:
		console_ui = ui_scene.instantiate()
		add_child(console_ui)
		
		# Initially hide console
		console_ui.visible = false
	
	integration_status.console.jsh_ready = console_manager != null and console_ui != null
	
	print("JSH Console System: " + ("Ready" if integration_status.console.jsh_ready else "Not Ready"))

func _load_legacy_components():
	# Find JSH_console.gd
	legacy_console = get_node_or_null("/root/JSH_console")
	integration_status.console.legacy_ready = legacy_console != null
	
	# Find text_screen.gd
	text_screen = get_node_or_null("/root/text_screen")
	
	# Find bank systems
	records_bank = get_node_or_null("/root/records_bank")
	integration_status.banks.records = records_bank != null
	
	actions_bank = get_node_or_null("/root/actions_bank")
	integration_status.banks.actions = actions_bank != null
	
	scenes_bank = get_node_or_null("/root/scenes_bank")
	integration_status.banks.scenes = scenes_bank != null
	
	instructions_bank = get_node_or_null("/root/instructions_bank")
	integration_status.banks.instructions = instructions_bank != null
	
	banks_combiner = get_node_or_null("/root/banks_combiner")
	integration_status.banks.combiner = banks_combiner != null
	
	# Find other systems
	digital_earthlings = get_node_or_null("/root/jsh_digital_earthlings")
	integration_status.systems.entity = digital_earthlings != null
	
	mainframe_database = get_node_or_null("/root/JSH_mainframe_database")
	database_system = get_node_or_null("/root/jsh_database_system")
	integration_status.systems.database = mainframe_database != null or database_system != null
	
	marching_shapes = get_node_or_null("/root/jsh_marching_shapes_system")
	integration_status.game.marching = marching_shapes != null
	
	snake_game = get_node_or_null("/root/jsh_snake_game")
	integration_status.game.snake = snake_game != null
	
	task_manager = get_node_or_null("/root/jsh_task_manager")
	integration_status.systems.task = task_manager != null
	
	print("Legacy Components: " + ("Found" if integration_status.console.legacy_ready else "Not Found"))

func _create_adapter():
	# Create adapter if legacy console exists
	if integration_status.console.legacy_ready and integration_status.console.jsh_ready:
		legacy_adapter = JSHLegacyConsoleAdapter.new(console_manager, legacy_console)
		add_child(legacy_adapter)
		
		integration_status.console.adapter_ready = true
		print("Legacy Console Adapter: Created")
	else:
		print("Legacy Console Adapter: Not Created (missing components)")

func _register_integration_commands():
	# Register specialized integration commands
	
	# System status command
	console_manager.register_command("status", {
		"description": "Show integration status",
		"usage": "status [detail_level]",
		"callback": Callable(self, "_cmd_status"),
		"min_args": 0,
		"max_args": 1,
		"arg_types": [TYPE_INT],
		"arg_descriptions": ["Detail level (1-3)"]
	})
	
	# Snake game command
	if integration_status.game.snake:
		console_manager.register_command("snake", {
			"description": "Play the snake game",
			"usage": "snake [start|stop|score]",
			"callback": Callable(self, "_cmd_snake"),
			"min_args": 0,
			"max_args": 1,
			"arg_types": [TYPE_STRING],
			"arg_descriptions": ["Operation: start, stop, score"]
		})
	
	# Marching shapes command
	if integration_status.game.marching:
		console_manager.register_command("shapes", {
			"description": "Generate marching shapes",
			"usage": "shapes <type> [size]",
			"callback": Callable(self, "_cmd_shapes"),
			"min_args": 1,
			"max_args": 2,
			"arg_types": [TYPE_STRING, TYPE_INT],
			"arg_descriptions": ["Shape type", "Size"]
		})
	
	# Task manager command
	if integration_status.systems.task:
		console_manager.register_command("task", {
			"description": "Task manager operations",
			"usage": "task <operation> [args...]",
			"callback": Callable(self, "_cmd_task"),
			"min_args": 1,
			"max_args": -1,
			"arg_types": [TYPE_STRING],
			"arg_descriptions": ["Operation: list, add, remove, start, stop"]
		})
	
	# Register visualization command
	console_manager.register_command("visualize", {
		"description": "Visualize system connections",
		"usage": "visualize [system]",
		"callback": Callable(self, "_cmd_visualize"),
		"min_args": 0,
		"max_args": 1,
		"arg_types": [TYPE_STRING],
		"arg_descriptions": ["System to visualize (console, banks, entity, all)"]
	})
	
	print("Integration Commands: Registered")

func _print_integration_status():
	console_manager.print_line("JSH Console Integration Demo", Color(0.2, 0.7, 1.0))
	console_manager.print_line("=========================", Color(0.2, 0.7, 1.0))
	
	console_manager.print_line("\nConsole Systems:")
	console_manager.print_line("  JSH Console: " + _status_text(integration_status.console.jsh_ready))
	console_manager.print_line("  Legacy Console: " + _status_text(integration_status.console.legacy_ready))
	console_manager.print_line("  Adapter: " + _status_text(integration_status.console.adapter_ready))
	
	console_manager.print_line("\nBank Systems:")
	console_manager.print_line("  Records Bank: " + _status_text(integration_status.banks.records))
	console_manager.print_line("  Actions Bank: " + _status_text(integration_status.banks.actions))
	console_manager.print_line("  Scenes Bank: " + _status_text(integration_status.banks.scenes))
	console_manager.print_line("  Instructions Bank: " + _status_text(integration_status.banks.instructions))
	console_manager.print_line("  Banks Combiner: " + _status_text(integration_status.banks.combiner))
	
	console_manager.print_line("\nOther Systems:")
	console_manager.print_line("  Entity System: " + _status_text(integration_status.systems.entity))
	console_manager.print_line("  Database System: " + _status_text(integration_status.systems.database))
	console_manager.print_line("  Task Manager: " + _status_text(integration_status.systems.task))
	console_manager.print_line("  Snake Game: " + _status_text(integration_status.game.snake))
	console_manager.print_line("  Marching Shapes: " + _status_text(integration_status.game.marching))
	
	console_manager.print_line("\nType 'status' for more detailed information")
	console_manager.print_line("Type 'visualize' to see system connections")
	console_manager.print_line("Press ~ or F1 to toggle console")

func _status_text(status: bool) -> String:
	return "✓ Available" if status else "✗ Not Found"

# Command handlers
func _cmd_status(args : Array) -> Dictionary:
	var detail_level = 1
	if args.size() > 0:
		detail_level = args[0]
	
	console_manager.print_line("Integration Status", Color(0.2, 0.7, 1.0))
	console_manager.print_line("=================", Color(0.2, 0.7, 1.0))
	
	# Basic status display
	_print_integration_status()
	
	if detail_level >= 2:
		# Show component details
		console_manager.print_line("\nComponent Details:", Color(1, 0.9, 0.2))
		
		if legacy_console:
			console_manager.print_line("  Legacy Console:")
			console_manager.print_line("    Commands: " + str(legacy_adapter.get_legacy_commands().size() if legacy_adapter else "Unknown"))
			console_manager.print_line("    Type: " + str(legacy_console.get_class()))
		
		if records_bank:
			console_manager.print_line("  Records Bank:")
			var record_count = "Unknown"
			if records_bank.has_method("get_record_count"):
				record_count = str(records_bank.get_record_count())
			console_manager.print_line("    Records: " + record_count)
		
		if actions_bank:
			console_manager.print_line("  Actions Bank:")
			var action_count = "Unknown"
			if actions_bank.has_method("get_action_count"):
				action_count = str(actions_bank.get_action_count())
			console_manager.print_line("    Actions: " + action_count)
	
	if detail_level >= 3:
		# Show integration metrics
		console_manager.print_line("\nIntegration Metrics:", Color(1, 0.9, 0.2))
		
		var metrics = {
			"commands_registered": console_manager.commands.size(),
			"legacy_commands": legacy_adapter.get_legacy_commands().size() if legacy_adapter else 0,
			"bank_commands": 0,
			"integration_commands": 5,
			"entities_synced": 0,
			"records_synced": 0
		}
		
		console_manager.print_line("  Commands: " + str(metrics.commands_registered) + " total")
		console_manager.print_line("    Legacy Commands: " + str(metrics.legacy_commands))
		console_manager.print_line("    Bank Commands: " + str(metrics.bank_commands))
		console_manager.print_line("    Integration Commands: " + str(metrics.integration_commands))
		console_manager.print_line("  Entities Synced: " + str(metrics.entities_synced))
		console_manager.print_line("  Records Synced: " + str(metrics.records_synced))
	
	return {
		"success": true,
		"message": "Status displayed",
		"detail_level": detail_level
	}

func _cmd_snake(args : Array) -> Dictionary:
	if not integration_status.game.snake:
		console_manager.print_error("Snake game not available")
		return {"success": false, "message": "Snake game not available"}
	
	var operation = "start"
	if args.size() > 0:
		operation = args[0].to_lower()
	
	match operation:
		"start":
			if snake_game.has_method("start_game"):
				snake_game.start_game()
				console_manager.print_success("Snake game started")
			else:
				console_manager.print_error("Unable to start snake game")
		
		"stop":
			if snake_game.has_method("stop_game"):
				snake_game.stop_game()
				console_manager.print_success("Snake game stopped")
			else:
				console_manager.print_error("Unable to stop snake game")
		
		"score":
			var score = "Unknown"
			if snake_game.has_method("get_score"):
				score = str(snake_game.get_score())
			console_manager.print_line("Snake game score: " + score)
		
		_:
			console_manager.print_error("Unknown snake operation: " + operation)
			return {"success": false, "message": "Unknown operation"}
	
	return {
		"success": true,
		"message": "Snake game operation: " + operation,
		"operation": operation
	}

func _cmd_shapes(args : Array) -> Dictionary:
	if not integration_status.game.marching:
		console_manager.print_error("Marching shapes system not available")
		return {"success": false, "message": "Marching shapes not available"}
	
	var shape_type = args[0].to_lower()
	var size = 10
	
	if args.size() > 1:
		size = args[1]
	
	if marching_shapes.has_method("generate_shape"):
		var shape = marching_shapes.generate_shape(shape_type, size)
		
		if shape:
			console_manager.print_success("Shape generated: " + shape_type)
			return {
				"success": true,
				"message": "Shape generated",
				"shape_type": shape_type,
				"size": size
			}
		else:
			console_manager.print_error("Failed to generate shape")
			return {"success": false, "message": "Generation failed"}
	else:
		console_manager.print_error("Shape generation method not found")
		return {"success": false, "message": "Method not found"}

func _cmd_task(args : Array) -> Dictionary:
	if not integration_status.systems.task:
		console_manager.print_error("Task manager not available")
		return {"success": false, "message": "Task manager not available"}
	
	var operation = args[0].to_lower()
	var task_args = args.slice(1)
	
	match operation:
		"list":
			var tasks = []
			if task_manager.has_method("get_tasks"):
				tasks = task_manager.get_tasks()
			
			console_manager.print_line("Tasks:")
			for task in tasks:
				var task_id = task.get("id", "unknown")
				var task_status = task.get("status", "unknown")
				console_manager.print_line("  " + task_id + ": " + task_status)
			
			return {
				"success": true,
				"message": str(tasks.size()) + " tasks found",
				"tasks": tasks
			}
		
		"add":
			if task_args.size() < 1:
				console_manager.print_error("Task name required")
				return {"success": false, "message": "Task name required"}
			
			var task_name = task_args[0]
			var task_params = {}
			
			if task_manager.has_method("add_task"):
				var task = task_manager.add_task(task_name, task_params)
				
				if task:
					console_manager.print_success("Task added: " + task_name)
					return {
						"success": true,
						"message": "Task added",
						"task_name": task_name,
						"task": task
					}
				else:
					console_manager.print_error("Failed to add task")
					return {"success": false, "message": "Failed to add task"}
			else:
				console_manager.print_error("Add task method not found")
				return {"success": false, "message": "Method not found"}
		
		_:
			console_manager.print_error("Unknown task operation: " + operation)
			return {"success": false, "message": "Unknown operation"}

func _cmd_visualize(args = []) -> Dictionary:
	var system = "all"
	if args.size() > 0:
		system = args[0].to_lower()
	
	console_manager.print_line("System Visualization", Color(0.2, 0.7, 1.0))
	console_manager.print_line("====================", Color(0.2, 0.7, 1.0))
	
	match system:
		"console", "all":
			# Console systems visualization
			console_manager.print_line("\nConsole Systems:", Color(1, 0.9, 0.2))
			console_manager.print_line("┌─────────────────┐      ┌─────────────────┐")
			console_manager.print_line("│  JSH Console    │      │  Legacy Console │")
			console_manager.print_line("│  System         │      │  System         │")
			console_manager.print_line("└────────┬────────┘      └────────┬────────┘")
			console_manager.print_line("         │                        │")
			console_manager.print_line("┌────────┴────────┐      ┌────────┴────────┐")
			console_manager.print_line("│ JSHConsoleUI    │      │ JSH_console.gd  │")
			console_manager.print_line("└────────┬────────┘      └────────┬────────┘")
			console_manager.print_line("         │                        │")
			console_manager.print_line("┌────────┴────────┐      ┌────────┴────────┐")
			console_manager.print_line("│ JSHConsole      │      │ text_screen.gd  │")
			console_manager.print_line("│ Manager         │      │                 │")
			console_manager.print_line("└────────┬────────┘      └────────┬────────┘")
			console_manager.print_line("         │                        │")
			console_manager.print_line("         └────────┬───────────────┘")
			console_manager.print_line("                  │")
			console_manager.print_line("         ┌────────┴────────┐")
			console_manager.print_line("         │ JSHLegacy       │")
			console_manager.print_line("         │ ConsoleAdapter  │")
			console_manager.print_line("         └────────┬────────┘")
			console_manager.print_line("                  │")
			console_manager.print_line("         ┌────────┴────────┐")
			console_manager.print_line("         │ Command         │")
			console_manager.print_line("         │ Execution       │")
			console_manager.print_line("         └─────────────────┘")
		
		"banks", "all":
			# Bank systems visualization
			console_manager.print_line("\nBank Systems:", Color(1, 0.9, 0.2))
			console_manager.print_line("┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐")
			console_manager.print_line("│  records_bank   │  │  actions_bank   │  │  scenes_bank    │")
			console_manager.print_line("└────────┬────────┘  └────────┬────────┘  └────────┬────────┘")
			console_manager.print_line("         │                    │                    │")
			console_manager.print_line("         └──────────┬─────────┴──────────┬────────┘")
			console_manager.print_line("                    │                    │")
			console_manager.print_line("         ┌──────────┴─────────┐ ┌────────┴────────┐")
			console_manager.print_line("         │ banks_combiner     │ │ instructions_   │")
			console_manager.print_line("         │                    │ │ bank            │")
			console_manager.print_line("         └──────────┬─────────┘ └────────┬────────┘")
			console_manager.print_line("                    │                    │")
			console_manager.print_line("                    └──────────┬─────────┘")
			console_manager.print_line("                               │")
			console_manager.print_line("                    ┌──────────┴─────────┐")
			console_manager.print_line("                    │  JSH Adapter       │")
			console_manager.print_line("                    └──────────┬─────────┘")
			console_manager.print_line("                               │")
			console_manager.print_line("┌─────────────────┐  ┌─────────┴───────┐  ┌─────────────────┐")
			console_manager.print_line("│ JSHEntityManager│  │ JSHConsole      │  │ JSHSpatial      │")
			console_manager.print_line("│                 │  │ Manager         │  │ Manager         │")
			console_manager.print_line("└─────────────────┘  └─────────────────┘  └─────────────────┘")
		
		"entity", "all":
			# Entity system visualization
			console_manager.print_line("\nEntity Systems:", Color(1, 0.9, 0.2))
			console_manager.print_line("┌─────────────────┐      ┌─────────────────┐")
			console_manager.print_line("│ JSHUniversal    │      │ data_point.gd   │")
			console_manager.print_line("│ Entity          │      │                 │")
			console_manager.print_line("└────────┬────────┘      └────────┬────────┘")
			console_manager.print_line("         │                        │")
			console_manager.print_line("┌────────┴────────┐      ┌────────┴────────┐")
			console_manager.print_line("│ JSHEntity       │      │ jsh_digital_    │")
			console_manager.print_line("│ Manager         │      │ earthlings.gd   │")
			console_manager.print_line("└────────┬────────┘      └────────┬────────┘")
			console_manager.print_line("         │                        │")
			console_manager.print_line("         └────────┬───────────────┘")
			console_manager.print_line("                  │")
			console_manager.print_line("         ┌────────┴────────┐")
			console_manager.print_line("         │ JSHLegacy       │")
			console_manager.print_line("         │ ConsoleAdapter  │")
			console_manager.print_line("         └────────┬────────┘")
			console_manager.print_line("                  │")
			console_manager.print_line("                  ▼")
			console_manager.print_line("         ┌─────────────────┐")
			console_manager.print_line("         │ JSHConsole      │")
			console_manager.print_line("         │ Manager         │")
			console_manager.print_line("         └─────────────────┘")
		
		_:
			console_manager.print_error("Unknown system to visualize: " + system)
			return {"success": false, "message": "Unknown system"}
	
	return {
		"success": true,
		"message": "Visualization displayed",
		"system": system
	}

# Utility function
func _get_time_string() -> String:
	var datetime = Time.get_datetime_dict_from_system()
	return "%02d:%02d:%02d" % [datetime.hour, datetime.minute, datetime.second]
