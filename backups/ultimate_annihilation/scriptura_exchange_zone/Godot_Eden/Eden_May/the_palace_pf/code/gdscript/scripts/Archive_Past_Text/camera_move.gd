# camera_move.gd
# root/main/sphere/cameramove
#Where Camera is? so kinda most important Node? kinda what we will call our first space with memory in scene?
extends Node3D

# Rotation memory? vec3?
var direction #xyz so Vector3 of three rotation degrees?
var rotated # additional vec3 for rotation, maybe memory of last? next?
var to_rotate # three means time? past, current next ?

#Curremt Speed? max speed?
var velocity
var speed

#Position for node?
var coordinates
var coords
var last_position
var current_position
var next_position


#Places in game? scenes? folders? main places?
var home
var rest
var treasury
var memory_bank
var storage
var items
var vault
var store


#Places to hide things?
var bag
var bags
var backpack
var pocket
var satchet
var inventory


#Scenes represented in smaller wayes? different perspective?
var scene
var map
var interface
var hud
var bottom_bar
var side_bar
var upper_bar
var crosshair

#Memory for multi tasking? Ram?
var state
var task

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_camera_mover_movement_send(current_origin: Vector3) -> void:
	#print("current origin first node",current_origin)
	pass
	
func calculate_movement(add: Vector3):
	pass
	print("to add : ", add, " current velocity : ", " current direction",)
