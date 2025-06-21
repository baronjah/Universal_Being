# ==================================================
# MAIN NICE GAME LAUNCHER
# Simple launcher for the perfect nice game
# ==================================================

extends Node

func _ready():
	print("🌟 LAUNCHING NICE GAME...")
	
	# Load the nice game scene
	var nice_game = preload("res://scenes/NICE_GAME.tscn")
	var game_instance = nice_game.instantiate()
	get_tree().root.add_child(game_instance)
	
	# Switch to nice game
	get_tree().current_scene = game_instance
	
	print("✨ NICE GAME READY!")
	print("🎮 CONTROLS:")
	print("   WASD - Move around")
	print("   Mouse - Look around") 
	print("   Space - Create nice entity")
	print("   C - Ask Claude for help")
	print("   ~ - Open console")
	print("😊 Have fun creating beauty!")