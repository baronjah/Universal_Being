extends Node3D

@onready var player = $Player
@onready var words_in_space = $WordsInSpace3D
@onready var player_gui = $GUI/PlayerGUI

# Configuration
var demo_words = [
	{ "id": "creation", "text": "Creation", "position": Vector3(0, 0, 0), "category": "concept" },
	{ "id": "energy", "text": "Energy", "position": Vector3(2, 0, 2), "category": "concept" },
	{ "id": "light", "text": "Light", "position": Vector3(-2, 0, 2), "category": "concept" },
	{ "id": "matter", "text": "Matter", "position": Vector3(0, 0, 4), "category": "concept" },
	{ "id": "time", "text": "Time", "position": Vector3(4, 0, 0), "category": "concept" },
	{ "id": "space", "text": "Space", "position": Vector3(-4, 0, 0), "category": "concept" },
	{ "id": "consciousness", "text": "Consciousness", "position": Vector3(0, 2, 0), "category": "concept" },
	{ "id": "life", "text": "Life", "position": Vector3(0, -2, 0), "category": "concept" },
	{ "id": "evolution", "text": "Evolution", "position": Vector3(2, -2, 2), "category": "process" },
	{ "id": "harmony", "text": "Harmony", "position": Vector3(-2, 2, 2), "category": "property" },
	{ "id": "transform", "text": "Transform", "position": Vector3(6, 0, 2), "category": "action" },
	{ "id": "connect", "text": "Connect", "position": Vector3(-6, 0, 2), "category": "action" },
	{ "id": "wisdom", "text": "Wisdom", "position": Vector3(0, 4, 0), "category": "concept" },
	{ "id": "joy", "text": "Joy", "position": Vector3(2, 2, 4), "category": "property" },
	{ "id": "peace", "text": "Peace", "position": Vector3(-2, 2, 4), "category": "property" },
	{ "id": "unity", "text": "Unity", "position": Vector3(0, 0, 8), "category": "concept" },
	{ "id": "water", "text": "Water", "position": Vector3(8, 0, 0), "category": "object" },
	{ "id": "fire", "text": "Fire", "position": Vector3(-8, 0, 0), "category": "object" },
	{ "id": "earth", "text": "Earth", "position": Vector3(0, -4, 0), "category": "object" },
	{ "id": "air", "text": "Air", "position": Vector3(0, 4, 4), "category": "object" },
]

var demo_connections = [
	{ "from": "creation", "to": "energy" },
	{ "from": "creation", "to": "light" },
	{ "from": "creation", "to": "matter" },
	{ "from": "creation", "to": "time" },
	{ "from": "creation", "to": "space" },
	{ "from": "creation", "to": "consciousness" },
	{ "from": "energy", "to": "light" },
	{ "from": "energy", "to": "matter" },
	{ "from": "energy", "to": "transform" },
	{ "from": "consciousness", "to": "wisdom" },
	{ "from": "consciousness", "to": "joy" },
	{ "from": "consciousness", "to": "peace" },
	{ "from": "life", "to": "evolution" },
	{ "from": "matter", "to": "water" },
	{ "from": "matter", "to": "fire" },
	{ "from": "matter", "to": "earth" },
	{ "from": "matter", "to": "air" },
	{ "from": "harmony", "to": "joy" },
	{ "from": "harmony", "to": "peace" },
	{ "from": "harmony", "to": "unity" },
	{ "from": "connect", "to": "unity" },
]

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect signals between systems
	if player and words_in_space:
		player.words_in_space = words_in_space
	
	if player and player_gui:
		player.gui = player_gui
		player_gui.player = player
	
	# Setup demo words and connections
	_setup_demo_words()
	
	# Set initial position and orientation
	player.global_position = Vector3(0, 1.8, 15)
	player.look_at(Vector3.ZERO, Vector3.UP)
	
	# Show welcome notification
	if player_gui:
		player_gui.show_notification("Welcome to JSH Ethereal Engine - Turn 9", 5.0)
		await get_tree().create_timer(1.0).timeout
		player_gui.show_notification("Press F to toggle flight mode", 3.0)
		await get_tree().create_timer(3.0).timeout
		player_gui.show_notification("Press Tab to toggle movement modes", 3.0)
		await get_tree().create_timer(3.0).timeout
		player_gui.show_notification("Left-click to select words", 3.0)
		await get_tree().create_timer(3.0).timeout
		player_gui.show_notification("Press R to shift reality", 3.0)

# Setup demo words and connections
func _setup_demo_words():
	if not words_in_space:
		return
	
	# Add demo words
	for word_data in demo_words:
		words_in_space.add_word(
			word_data.id,
			word_data.text,
			word_data.position,
			word_data.get("category", "concept")
		)
	
	# Add connections
	for conn in demo_connections:
		words_in_space.connect_words(conn.from, conn.to)
	
	# Update visualization
	words_in_space.update_visualization()