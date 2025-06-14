# 🏛️ Racing Menu Integrator - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
# This script handles integration of the racing game into the main menu system

const RACING_GAME_MENU_ID = "world_of_pallets_racing"

# Reference to the menu integration script
var menu_integration = null
var main_controller = null

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("\n🏎️ [RACING INTEGRATOR] Racing menu integrator ready\n")
	
	# Wait for the main controller to be fully initialized
	await get_tree().process_frame
	
	# Get reference to main controller (usually the parent)
	main_controller = get_parent()
	
	# Create the menu integration node
	menu_integration = load("res://racing_game/scripts/menu_integration.gd").new()
	menu_integration.name = "RacingMenuIntegration"
	add_child(menu_integration)
	
	# Register racing game actions
	register_racing_actions()
	
	# Add racing game to the menu
	add_racing_to_menu()


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
func register_racing_actions():
	# Register actions with the main controller's action system
	if main_controller and main_controller.has_method("register_action"):
		print("Registering racing game actions...")
		
		# Register start racing game action
		main_controller.register_action("start_racing_game", menu_integration, "start_racing_game")
		
		# Register exit racing game action
		main_controller.register_action("exit_racing_game", menu_integration, "exit_racing_game")
		
		# Register pause racing game action
		main_controller.register_action("pause_racing_game", menu_integration, "pause_racing_game")
		
		# Register resume racing game action
		main_controller.register_action("resume_racing_game", menu_integration, "resume_racing_game")
		
		print("Racing game actions registered")
	else:
		print("Warning: Could not register racing game actions - main controller not found or missing register_action method")

func add_racing_to_menu():
	# Check if your main menu system has a create_menu_item method
	if main_controller and main_controller.has_method("create_menu_button"):
		print("Adding racing game to main menu...")
		
		# Create a menu button for the racing game
		main_controller.create_menu_button("World of Pallets Racing", "start_racing_game")
		
		print("Racing game added to menu")
	elif main_controller and main_controller.has_method("add_menu_button"):
		# Alternative method name
		main_controller.add_menu_button("World of Pallets Racing", "start_racing_game")
	else:
		print("Warning: Could not add racing game to menu - main controller not found or missing create_menu_button method")
		
		# If the menu system uses a different approach, you may need to adapt this
		# For example, if it uses scene_bank entries:
		if main_controller and "BanksCombiner" in main_controller:
			print("Attempting to add racing game to menu via BanksCombiner...")
			# This is where you'd add code specific to your menu system
