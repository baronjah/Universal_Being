# 🏛️ Banks Combiner - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# banks_combiner.gd

# res://code/gdscript/scripts/Menu_Keyboard_Console/banks_combiner.gd

# class_name BanksCombiner
#

# combine record, scene, action, instruction into one data_pack with data_point container
# node thing container type shape direction list contour color shader visual hide create
# console records combo commands terminal computer window layer split view duplicate

# edit change continue check settings file folder name scale zoom in out rx tx
# chunk heightmap marching_cube view pre_view window layer perspective
# camera head player scale clothes menu direction velocity turns animations

# combine conts strings pack array directories into one datapack to split it later too and send it, we will be hiding and spliting and packing
# data too with splitter later with buttons it splits and shows
# colors scales directions transform 3d in 2d windows too with shapes and look at from galaxies functions

# file name node path part split join merge symbol command combo
# pathway blocked
# reason rule boundary split join de_attatch 

# debug window screen button color change distance
# ray cast ray points centers gravity pull push
# combo segments areas shapes lenghts directions

# positions local global container node thing path
# teleport move rotate position get set call data
# frame still change animate send receive store

# words connect we need easy connections with buttons and lines i can connect and store as file and code

# JSH Ethereal Banks Combiner

#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┳┓    ┓    ┏┓     ┓ •      
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┣┫┏┓┏┓┃┏┏  ┃ ┏┓┏┳┓┣┓┓┏┓┏┓┏┓
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┻┛┗┻┛┗┛┗┛  ┗┛┗┛┛┗┗┗┛┗┛┗┗ ┛
#       888 oo     .d8P  888     888          
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#
# JSH Ethereal Banks Combiner

#
# patches like bugs and words

# we just add paths and lines to stitch the first net

extends UniversalBeingBase
#

class_name BanksCombiner #BanksCombiner.combination_0 

#BanksCombiner.set_containers_names

#func _init():
	#print(" ready on each script ? 3")
#

# BanksCombiner.data_names_0
const data_names_0 = [
	"records", "instructions", "scenes", "interactions"
]
const data_layers_0 = [
	"window", "scale", "layer", "distance"
]
# BanksCombiner.data_names_0
const data_names_2_numbers = {
	"records" = 0, 
	"instructions" = 1, 
	"scenes" = 2, 
	"interactions" = 3
	}


const data_names_a0 = [
	"thing", "things", "_", "0"
]

const data_bank_0 = [
	"akashic_records", "player", "world", "space", "3d_space", "distances"
]

const data_bank_0_header = [
	"node", "path", "direction", ""
]
const shift_data_0 = [
	"shift", "number", "letter", "symbol", "lenght", "distance", "layer"
]

const data_names_1 = [
	"records", "record", "scene", "scenes", "action", "interaction", "instructions", "instruction"
]

const data_names_2 = [
	"instructions", "scenes", "interactions"
]

# BanksCombiner.data_names_3
# recreator, needs records, scenes, interactions
const data_names_3 = [
	"records", "scenes", "interactions"
]

#class_name BanksCombiner #BanksCombiner.combination_0
const data_sets_names = [
	"base_", "menu_", "settings_", "keyboard_", "keyboard_left_", "keyboard_right_", "things_creation_", "singular_lines_", "snake_", "racing_game_"
]
# BanksCombiner.data_sets_names "base_"
# BanksCombiner.data_sets_names_0 "base"
const data_sets_names_0 = [
	"base", "menu", "settings", "keyboard", "keyboard_left", "keyboard_right", "things_creation", "singular_lines", "snake", "racing_game"
]

const dataSetLimits = { # dataSetLimits and data_sets_names in BanksCombiner
	"base_": 1,
	"menu_": 1,
	"settings_": 1,
	"keyboard_": 1,
	"keyboard_left_": 1,
	"keyboard_right_": 1,
	"things_creation_": 2,
	"singular_lines_": 8,
	"snake_": 1,
	"racing_game_": 1
}

const data_set_type = {
	"base_": 0,
	"menu_": 0,
	"settings_": 0,
	"keyboard_": 0,
	"keyboard_left_": 0,
	"keyboard_right_": 0,
	"things_creation_": 0,
	"singular_lines_": 1,
	"snake_": 0,
	"racing_game_": 0
}

const set_container_name = {
	"base_": "akashic_records",
	"menu_": "akashic_records",
	"settings_": "settings_container",
	"keyboard_": "keyboard_container",
	"keyboard_left_": "keyboard_left_container",
	"keyboard_right_": "keyboard_right_container",
	"things_creation_": "things_creation_container",
	"singular_lines_": "singular_lines_container",
	"snake" : "snake_container",
	"racing_game_" : "racing_game_container"
}

const container_set_name = {
	"akashic_records": ["base", "menu"],
	"settings_container" : "settings",
	"keyboard_container": "keyboard",
	"keyboard_left_container" : "keyboard_left",
	"keyboard_right_container": "keyboard_right",
	"things_creation_container" : "things_creation",
	"singular_lines_container" : "singular_lines",
	"grid_of_creation_container" : ["grid_of_creation", "shape_view"],
	"snake_container" : "snake",
	"racing_game_container" : "racing_game"
	
}

const set_active_name = {
	"base_": "base",
	"menu_": "menu",
	"settings_": "settings",
	"keyboard_": "keyboard",
	"keyboard_left_": "keyboard_left",
	"keyboard_right_": "keyboard_right",
	"things_creation_": "things_creation",
	"singular_lines_": "singular_lines",
	"snake_container_": "snake_container",
	"racing_game_": "racing_game"
}

const set_containers_names = {
	"base": "akashic_records",
	"menu": "akashic_records",
	"settings": "settings_container",
	"keyboard": "keyboard_container",
	"keyboard_left": "keyboard_left_container",
	"keyboard_right": "keyboard_right_container",
	"things_creation": "things_creation_container",
	"singular_lines": "singular_lines_container",
	"snake" :"snake_container",
	"racing_game" : "racing_game_container"
}

const turn_system_0 = [
	"base", "menu", "settings", "keyboard", "left", "right", "things_creation", "racing_game"
]
const symbols_net_0 = [
	"|", "/", ":", "ø", "()", "[]", "{}", "#", "_"
]
const functions_net_0 = [
	"var", "func", "return", "break", "pass", "continue", "#", "enums", "const", "=", "@", "!", "$", "%", "|", "*", "&", "^", "0010110", "type"
]
const command_list_0 = [
	"create", "move", "change", "distance", "debug", "window", "scale", "rotation", "space", "find"
]
const files_names_0 = [
	"main.gd", "banks_combiner.gd", "records_bank.gd", "instructions_bank.gd"
]
const nodes_names_list_0 = [
	"main", "sphere", "Player_Head", "JSH_Core", "Patch", "World"
]
const Prayers_0 = [
	"galaxy", "star", "clouds", "noise", "2d_3d_space_veiw", "shape", "lists", "chunks"
]

# the new way to do things
const combination_new_gen_0 = [
	[0]
]

# the new way to do things
const combination_new_gen_1 = [
	[1], [2], [3]
]

# the base one
const combination_0 = [
	[0], [1], [2], [3]
]

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#
# simple lists and patches




#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#
# mistakes were already made and unnecessarily


# the menu one
const combination_1 = [
	[0], [1], [2], [3]
]

# the settings one
const combination_2 = [
	[0], [1], [2], [3]
]

# the keyboard bracekt one
const combination_3 = [
	[0], [1], [2], [3]
]

# keyboard left
const combination_4 = [
	[0], [1], [2], [3]
]

# keyboard migi
const combination_5 = [
	[0], [1], [2], [3]
]

# things creation
const combination_6 = [
	[0], [1], [2], [3]
]

# things creation
const combination_7 = [
	[0], [1], [2], [3]
]

# racing game
const combination_8 = [
	[0], [1], [2], [3]
]


func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	# Pentagon setup - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass