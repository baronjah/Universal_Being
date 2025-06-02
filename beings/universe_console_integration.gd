# ==================================================
# SCRIPT NAME: UniverseConsoleIntegration.gd
# DESCRIPTION: Integration layer for universe console commands
# PURPOSE: Connect universe commands to existing console system
# CREATED: 2025-06-02 - The Bridge of Commands
# AUTHOR: JSH + Claude (Opus 4) - Integration Architects
# ==================================================

extends Node

var console_component: UniverseConsoleComponent = null
var universe_navigator: UniverseNavigator = null
var console_being: Node = null

func _ready() -> void:
	name = "UniverseConsoleIntegration"
	
	# Wait for systems to be ready
	if SystemBootstrap and not SystemBootstrap.is_system_ready():
		await SystemBootstrap.system_ready
	
	# Find or create console
	console_being = _find_console_being()
	if console_being:
		_integrate_universe_commands()

func _find_console_being() -> Node:
	"""Find the console universal being"""
	var consoles = get_tree().get_nodes_in_group("console_beings")
	if not consoles.is_empty():
		return consoles[0]
	
	# Search manually
	var main = get_tree().root.get_node_or_null("Main")
	if main:
		for child in main.get_children():
			if child.has_method("get") and child.get("being_type") == "console":
				return child
	
	return null

func _integrate_universe_commands() -> void:
	"""Integrate universe commands into console"""
	# Create universe console component
	console_component = preload("res://components/universe_console/UniverseConsoleComponent.gd").new()
	add_child(console_component)
	console_component.initialize(console_being)
	
	print("🌌 Universe Console Commands integrated!")
	print("🌌 Available commands: universe, portal, enter, exit, inspect, list, rules, setrule")
	
	# Log to Akashic
	var akashic = get_tree().get_first_node_in_group("akashic_library")
	if akashic:
		akashic.inscribe_genesis("🌌 The Universe Console awakened, reality became malleable through words...")

func toggle_universe_navigator() -> void:
	"""Toggle the visual universe navigator"""
	if not universe_navigator:
		universe_navigator = preload("res://ui/UniverseNavigator.gd").new()
		get_tree().root.add_child(universe_navigator)
		universe_navigator.visible = false
	
	universe_navigator.visible = not universe_navigator.visible
	
	if universe_navigator.visible:
		universe_navigator.refresh_universe_map()
