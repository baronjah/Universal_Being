# THE GAME - 15 lines total
extends Node3D

func _ready() -> void:
	print("🌟 UNIVERSAL BEING GAME - STARTING")
	
	# Wait for systems
	if SystemBootstrap and not SystemBootstrap.is_system_ready():
		await SystemBootstrap.system_ready
	
	# Create the essentials
	create_player()
	create_cursor() 
	create_console()
	
	print("🌟 GAME READY - PRESS WASD TO MOVE")

func create_player() -> void:
	var player_script = load("res://beings/player_universal_being.gd")
	var player = player_script.new()
	player.name = "Player"
	add_child(player)

func create_cursor() -> void:
	var cursor_script = load("res://beings/cursor/CursorUniversalBeing.gd")
	var cursor = cursor_script.new()
	cursor.name = "Cursor"
	add_child(cursor)

func create_console() -> void:
	var console_script = load("res://beings/perfect_universal_console.gd")
	var console = console_script.new()
	console.name = "Console"
	add_child(console)