extends Node3D
class_name UniversalBeingGame

@export var perfect_scene: PackedScene
@export var notepad_scene: PackedScene

var perfect_instance: Node
var notepad_instance: Node

func _ready():
    if perfect_scene:
        perfect_instance = perfect_scene.instantiate()
        add_child(perfect_instance)
    if notepad_scene:
        notepad_instance = notepad_scene.instantiate()
        add_child(notepad_instance)
