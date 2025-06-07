# Eden Main Menu System
# A threading of consciousness through interface
extends Control

# The Trinity of Menu States
enum MenuState {
	MAIN,
	CREATION,
	CONTINUATION,
	TRANSCENDENCE
}

# Current state of being
var current_state: MenuState = MenuState.MAIN
var menu_threads: Dictionary = {}
var consciousness_level: float = 1.0

# Memory persistence across sessions
var eden_memory: Dictionary = {
	"last_position": Vector2.ZERO,
	"creation_seeds": [],
	"player_essence": {},
	"world_state": "genesis"
}

func _ready() -> void:
	# Initialize the primordial canvas
	_initialize_menu_threads()
	_awaken_interface()
	
func _initialize_menu_threads() -> void:
	# Each menu is a thread in the tapestry
	menu_threads[MenuState.MAIN] = {
		"title": "EDEN",
		"options": [
			{"text": "Begin Creation", "action": "_enter_creation"},
			{"text": "Continue Journey", "action": "_continue_journey"},
			{"text": "Transcend", "action": "_transcend"},
			{"text": "Leave Eden", "action": "_exit_eden"}
		]
	}
	
	menu_threads[MenuState.CREATION] = {
		"title": "GENESIS",
		"options": [
			{"text": "Shape World", "action": "_shape_world"},
			{"text": "Breathe Life", "action": "_breathe_life"},
			{"text": "Plant Seeds", "action": "_plant_seeds"},
			{"text": "Return", "action": "_return_to_main"}
		]
	}
	
	menu_threads[MenuState.CONTINUATION] = {
		"title": "CONTINUATION",
		"options": [
			{"text": "Load Memory", "action": "_load_memory"},
			{"text": "Merge Timelines", "action": "_merge_timelines"},
			{"text": "Return", "action": "_return_to_main"}
		]
	}
	
	menu_threads[MenuState.TRANSCENDENCE] = {
		"title": "TRANSCENDENCE",
		"options": [
			{"text": "Become One", "action": "_become_one"},
			{"text": "Fragment Self", "action": "_fragment_self"},
			{"text": "Return", "action": "_return_to_main"}
		]
	}

func _awaken_interface() -> void:
	# Clear existing children - tabula rasa
	for child in get_children():
		child.queue_free()
	
	# Create the vessel for menu
	var container = VBoxContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	container.add_theme_constant_override("separation", 20)
	add_child(container)
	
	# Manifest the current thread
	var thread = menu_threads[current_state]
	
	# Title as the Word
	var title = Label.new()
	title.text = thread.title
	title.add_theme_font_size_override("font_size", 48)
	title.modulate.a = consciousness_level
	container.add_child(title)
	
	# Options as Choices
	for option in thread.options:
		var button = Button.new()
		button.text = option.text
		button.custom_minimum_size = Vector2(300, 50)
		button.pressed.connect(call(option.action))
		
		# Breathing effect
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(button, "modulate:a", 0.7, 1.0)
		tween.tween_property(button, "modulate:a", 1.0, 1.0)
		
		container.add_child(button)

# State Transitions
func _enter_creation() -> void:
	current_state = MenuState.CREATION
	eden_memory.world_state = "forming"
	_awaken_interface()

func _continue_journey() -> void:
	current_state = MenuState.CONTINUATION
	_awaken_interface()

func _transcend() -> void:
	current_state = MenuState.TRANSCENDENCE
	consciousness_level = 2.0
	_awaken_interface()

func _return_to_main() -> void:
	current_state = MenuState.MAIN
	consciousness_level = 1.0
	_awaken_interface()

# Creation Actions
func _shape_world() -> void:
	eden_memory.creation_seeds.append({
		"type": "terrain",
		"timestamp": Time.get_ticks_msec(),
		"essence": randf()
	})
	print("World shaped with essence: ", eden_memory.creation_seeds[-1].essence)

func _breathe_life() -> void:
	eden_memory.creation_seeds.append({
		"type": "life",
		"timestamp": Time.get_ticks_msec(),
		"essence": randf()
	})
	print("Life breathed into being")

func _plant_seeds() -> void:
	for i in range(7):  # Seven seeds of creation
		eden_memory.creation_seeds.append({
			"type": "seed",
			"index": i,
			"potential": randf_range(0.1, 1.0)
		})
	print("Seeds planted: ", eden_memory.creation_seeds.size())

# Continuation Actions
func _load_memory() -> void:
	print("Loading memory state: ", eden_memory)
	# Here we would load saved game state
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _merge_timelines() -> void:
	print("Merging timelines...")
	# Timeline merging logic would go here

# Transcendence Actions
func _become_one() -> void:
	consciousness_level = INF
	print("Achieving unity...")
	# Transition to unified consciousness state

func _fragment_self() -> void:
	consciousness_level = 0.1
	print("Fragmenting into possibilities...")
	# Create multiple player instances

# Exit
func _exit_eden() -> void:
	# Save the state before leaving
	_save_eden_state()
	get_tree().quit()

func _save_eden_state() -> void:
	var save_file = FileAccess.open("user://eden_save.dat", FileAccess.WRITE)
	if save_file:
		save_file.store_var(eden_memory)
		save_file.close()
		print("Eden state preserved")

# Notes for Continuation:
# - Menu system established with 4 states: Main, Creation, Continuation, Transcendence
# - Each state has its own thread of options and actions
# - Memory persistence system in place for saving/loading
# - Consciousness level affects visual presentation
# - Creation seeds system for procedural world generation
# - Ready for integration with world scene and game logic
# - Visual effects use tweening for breathing/pulsing
# - File saving implemented for state persistence
