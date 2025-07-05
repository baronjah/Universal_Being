extends Node

# Simple script to spawn DIVINE_LIVING_NOTEPAD_3D in current scene
# Just run this script and it spawns

func _ready():
	var notepad_scene = load("res://DIVINE_LIVING_NOTEPAD_3D.tscn")
	if notepad_scene:
		var notepad = notepad_scene.instantiate()
		get_tree().current_scene.add_child(notepad)
		notepad.position = Vector3(0, 0, 0)
		print("✨ DIVINE_LIVING_NOTEPAD_3D spawned in current scene")
	else:
		print("❌ Failed to load DIVINE_LIVING_NOTEPAD_3D.tscn")