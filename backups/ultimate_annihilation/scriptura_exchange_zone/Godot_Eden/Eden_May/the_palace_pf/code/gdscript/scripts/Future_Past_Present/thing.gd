# scripts/thing.gd
extends Node

# Data for current visible position, orientation, direction, center of mass, so where it is, where it is going, and it will be needed for physics stuff, like every node? so maybe lets make one script for just thing appearing?
var current_position : Array = []
var current_rotation : Array = []
var current_direction : Array = []
var center_of_mass : Array = []

# more stuff for calculating movement, slowing down, max speed
var velocity : float = 0.0
var max_speed : float = 10.0
var speeding_up : float = 0.1
var slowing_down : float = -0.1

# basic memory stuff, we will probably do it based on thing type? lets make 10 spaces
var memory_0 : Array = []
var memory_1 : Array = []
var memory_2 : Array = []
var memory_3 : Array = []
var memory_4 : Array = []
var memory_5 : Array = []
var memory_6 : Array = []
var memory_7 : Array = []
var memory_8 : Array = []
var memory_9 : Array = []

const type_of_thing = [
	"flat_shape", "text", "model", "button", "cursor", "connection", "screen", "datapoint"
]

# Data received

# Data to send

# Update 
