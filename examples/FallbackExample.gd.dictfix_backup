# ==================================================
# FALLBACK SYSTEM EXAMPLE
# ==================================================

extends Node

func _ready():
	# Register multiple Player implementations
	UniversalFallbackSystem.register_class_implementation("Player", "res://examples/BasePlayer.gd", 100)
	UniversalFallbackSystem.register_class_implementation("Player", "res://examples/AdvancedPlayer.gd", 200)
	
	# Create player with fallback capabilities
	var player = UniversalFallbackSystem.create_fallback_instance("Player")
	
	# Test method resolution
	print("=== FALLBACK SYSTEM TEST ===")
	
	# This will use AdvancedPlayer (higher priority)
	player.move_player(1.0)
	
	# AdvancedPlayer has this method
	player.fly()
	
	# AdvancedPlayer has this method  
	player.cast_spell("Fireball")
	
	# BasePlayer has this method (fallback)
	print("Health: " + str(player.get_health()))
	
	# AdvancedPlayer has this method
	print("Mana: " + str(player.get_mana()))
	
	# BasePlayer has this method (fallback)
	player.attack()
	
	print("=== TEST COMPLETE ===")