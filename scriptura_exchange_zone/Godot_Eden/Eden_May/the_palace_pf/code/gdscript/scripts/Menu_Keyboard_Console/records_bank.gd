# records_bank.gd
# scripts/records_bank.gd
# RecordsBank

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

# space, vehicles, beings
# loops, while, return rx tx
# records in splitted manner, single, or more
# the "|"
# zone
# where we split as it is large maybe?
# stars and chunks and layers and lod is connected for a game, for me to see
# my eyes are cursed with knowledge

extends Node3D
class_name RecordsBank # RecordsBank.records_map_0 # RecordsBank.type_of_thing_0

var thing_add_number : String = "thing_"
var record_add_number : String = "record_"

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
# 
# consts

# type of things
const type_of_thing_0 = [
	"flat_shape", "text", "model", "button", "cursor", "connection", "screen", "datapoint", "circle", "container", "text_mesh", "icon", "snake", "terminal", "square_button", "rounded_frame"
]


const symbols_duality_0 = [
	"●", "○", "×", "△", "▲"
]



	# each container name can have things from 0 to 99 and even more
# thing_52
# we limit things amounts per container, priorirty, type, state etc
#
# special nodes like datapoints too, spacebar, return, undo shift, number/letter big/small sliders
# container
# Akashic Records
# main menu base, _ |
# datapoint
#	"active": "●",
#	"pending": "○", 
#	"disabled": "×"
# △▲
# screen|1:1
# 
# space, return, 0010110 , bar   , undo






#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

# Akashic Records
# main menu base, _ |

#	"active": "●",
#	"pending": "○", 
#	"disabled": "×"

# we need menu, settings, keyboard, icons, files, folders, shapes, layers, paths, changes, loops

#
#┳┳┓         ┳         ┏┓        
#┃┃┃┏┓┏┓┓┏   ┃┏┏┓┏┓┏   ┗┓┏┓┏┓┏┏┓┏
#┛ ┗┗ ┛┗┗┻╻  ┻┗┗┛┛┗┛╻  ┗┛┣┛┗┻┗┗ ┛
						#┛       
#┓ ┏•   ┓        ┏┓┓          ┓          
#┃┃┃┓┏┓┏┫┏┓┓┏┏┏  ┗┓┣┓┏┓┏┓┏┓┏  ┃ ┏┓┓┏┏┓┏┓┏
#┗┻┛┗┛┗┗┻┗┛┗┻┛┛  ┗┛┛┗┗┻┣┛┗ ┛  ┗┛┗┻┗┫┗ ┛ ┛
					  #┛           ┛     

# Dictionary containing all record definitions
const records_map_0 = {
	0: [ # container
		["thing_0|0.0,0.0,0.0|0.0,0.0,0.0|container|base|main|akashic_records|containers|instruction_set_0"],
		["akashic_records|0"]
	],
	1: [ # data_point
		["thing_7|0.0,0.0,0.0|0.0,0.0,0.0|datapoint|0|akashic_records|akashic_records/thing_7|datapoints|instruction_set_0"],
		["100"]
	],
	2: [ # Text
		["thing_2|0.0,0.0,0.0|0.0,0.0,0.0|text|square|akashic_records|akashic_records/thing_2|Akashic_Records|instruction_set_0"],
		["Akashic_Records|33"]
	],
	3: [ # Line
		["thing_3|0.0,0.0,0.0|0.0,0.0,0.0|connection|line|akashic_records|akashic_records/thing_3|Akashic_Records|instruction_set_0"],
		["0.0,0.0,-6.0|0.0,0.0,6.0|0.69"]
	],
	4: [ # Triangle
		["thing_5|0.0,0.0,0.0|0.0,0.0,0.0|cursor|triangle|akashic_records|akashic_records/thing_5|Akashic_Records|instruction_set_0"],
		["-1,-2,0|1,2,0|-1,3,0|0.19,0.19,0.19"],
		["0.69|1.0"]
	],
	5: [ # Screen, like with ratio
		["thing_4|0.0,0.0,0.0|0.0,0.0,0.0|text_mesh|config|akashic_records|akashic_records/thing_4|Akashic_Records|instruction_set_0"],
		["point"],
		["JSH|369|0.05|0.02|0.59|1.0"]
	],
	6: [ # Button, like with ratio
		["thing_6|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|akashic_records|akashic_records/thing_6|Akashic_Records|instruction_set_0"],
		["-2,-0.5,0|2,-0.5,0|2,0.5,0|-2,0.5,0"],
		["Start|369|0.69|1.0"]
	],
	7: [ # Flat_shape
		["thing_1|0.0,0.0,0.0|0.0,0.0,0.0|flat_shape|0|akashic_records|akashic_records/thing_1|Akashic_Records|instruction_set_0"],
		["0,3,0|3,-1,0|2,-3,0|-2,-3,0|-3,-1,0"],
		["0.69|1.0"]
	],
	8: [ # circle
		["thing_8|0.0,0.0,0.0|0.0,0.0,0.0|circle|0|akashic_records|akashic_records/thing_8|Akashic_Records|instruction_set_0"],
		["3|8"],
		["0.69|1.0"]
	],
	9: [ # Square
		["thing_9|0.0,0.0,0.0|0.0,0.0,0.0|model|square|akashic_records|akashic_records/thing_9|Akashic_Records|instruction_set_0"],
		["-1,-1,0|1,-1,0|1,1,0|-1,1,0"],
		["0.69|1.0"]
	]
}

# lets try making a button
# we maybe dont use it anymore, it was a path
# last few will fall off and dissapear, we could keep and hide them to reuse them too

const records_map_1 = {
	0: [ # Square
		["thing_10|0.0,0.0,0.0|0.0,0.0,0.0|model|square|akashic_records|akashic_records/thing_9|group_0"],
		["-1,-1,0|1,-1,0|1,1,0|-1,1,0"],
		["0.69|1.0"]
	],
	1: [ # Text
		["thing_18|0.0,0.0,0.0|0.0,0.0,0.0|text|square|akashic_records|akashic_records/thing_10|group_0"],
		["Akashic_Records|33"],
		["0.69|1.0"]
	]
}

# the records for menu
# icons can change into 3d things too, with distance


const records_map_2 = {
	0: [ # Main screen
		["thing_11|0.0,0.0,0.0|0.0,0.0,0.0|screen|16:9|akashic_records|akashic_records/thing_11|Akashic_Records|instruction_set_1"],
		["-8,-4.5,0|8,-4.5,0|8,4.5,0|-8,4.5,0"],
		["0.022|1.0"]
	],
	1: [ # Things Button
		["thing_12|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|akashic_records|akashic_records/thing_12|Akashic_Records|instruction_set_1"],
		["-2,-0.5,0|2,-0.5,0|2,0.5,0|-2,0.5,0"],
		["Things|36|0.05|1.0"] 
	],
	2: [ # Scenes Button
		["thing_13|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|akashic_records|akashic_records/thing_13|Akashic_Records|instruction_set_1"],
		["-2,-0.5,0|2,-0.5,0|2,0.5,0|-2,0.5,0"],
		["Scenes|36|0.05|1.0"]
	],
	3: [ # Interactions Button
		["thing_14|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|akashic_records|akashic_records/thing_14|Akashic_Records|instruction_set_1"],
		["-2,-0.5,0|2,-0.5,0|2,0.5,0|-2,0.5,0"],
		["Interactions|36|0.05|1.0"]
	],
	4: [ # Instructions Button
		["thing_15|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|akashic_records|akashic_records/thing_15|Akashic_Records|instruction_set_1"],
		["-2,-0.5,0|2,-0.5,0|2,0.5,0|-2,0.5,0"],
		["Instructions|36|0.05|1.0"]
	],
	5: [ # Settings Button
		["thing_16|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|akashic_records|akashic_records/thing_16|Akashic_Records|instruction_set_1"],
		["-2,-0.5,0|2,-0.5,0|2,0.5,0|-2,0.5,0"],
		["Settings|36|0.05|1.0"]
	],
	6: [ # Exit Button
		["thing_17|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|akashic_records|akashic_records/thing_17|Akashic_Records|instruction_set_1"],
		["-2,-0.5,0|2,-0.5,0|2,0.5,0|-2,0.5,0"],
		["Exit|36|0.05|1.0"]
	]
}

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

# string of keyboard bracet connect to a label of words

# settings

#┏┓    •       ┓          
#┗┓┏┓╋╋┓┏┓┏┓┏  ┃ ┏┓┓┏┏┓┏┓┏
#┗┛┗ ┗┗┗┛┗┗┫┛  ┗┛┗┻┗┫┗ ┛ ┛
		  #┛        ┛     
#
# RecordsBank Settings_layers in words too maybe

# we need menu, settings, keyboard, icons, files, folders, shapes, layers, paths, changes, loops
# we need menu, settings, keyboard, 
# icons, files, folders, shapes, layers, 
# paths, changes, loops

# settings stuff
# settings and data storage, how much keycaps for laptop and keyboard per piano in numbers weight with sounds too?

const records_map_3 = {
	0: [ # container
		["thing_18|0.0,0.0,0.0|0.0,0.0,0.0|container|settings|main|settings_container|containers|instruction_set_2"],
		["settings_container|0"]
	],
	1: [ # datapoint
		["thing_19|0.0,0.0,0.0|0.0,0.0,0.0|datapoint|1|settings_container|settings_container/thing_19|datapoints|instruction_set_2"],
		["100"]
	],
	2:[ # screen
		["thing_20|0.0,0.0,0.0|0.0,0.0,0.0|screen|12:9|settings_container|settings_container/thing_20|settings_container|instruction_set_2"],
		["-6,-4.5,0|6,-4.5,0|6,4.5,0|-6,4.5,0"],
		["0.033|0.69"]
	],
	3:[ # button 1
		["thing_21|0.0,0.0,0.0|0.0,0.0,0.0|button|square|settings_container|settings_container/thing_21|settings_container|instruction_set_2"],
		["-5.75,-0.44,0|5.75,-0.44,0|5.75,0.44,0|-5.75,0.44,0"],
		["|36|0.05|1.0"]
	],
	4:[ # button 2
		["thing_22|0.0,0.0,0.0|0.0,0.0,0.0|button|square|settings_container|settings_container/thing_22|settings_container|instruction_set_2"],
		["-5.75,-0.44,0|5.75,-0.44,0|5.75,0.44,0|-5.75,0.44,0"],
		["|36|0.05|1.0"]
	],
	5: [ # button 3
		["thing_23|0.0,0.0,0.0|0.0,0.0,0.0|button|square|settings_container|settings_container/thing_23|settings_container|instructions_set_2"],
		["-5.75,-0.44,0|5.75,-0.44,0|5.75,0.44,0|-5.75,0.44,0"],
		["|36|0.05|1.0"]
	],
	6: [ # button 4
		["thing_24|0.0,0.0,0.0|0.0,0.0,0.0|button|square|settings_container|settings_container/thing_24|settings_container|instructions_set_2"],
		["-5.75,-0.44,0|5.75,-0.44,0|5.75,0.44,0|-5.75,0.44,0"],
		["|36|0.05|1.0"]
	],
	7: [ # button 5
		["thing_25|0.0,0.0,0.0|0.0,0.0,0.0|button|square|settings_container|settings_container/thing_25|settings_container|instructions_set_2"],
		["-5.75,-0.44,0|5.75,-0.44,0|5.75,0.44,0|-5.75,0.44,0"],
		["|36|0.05|1.0"]
	],
	8: [ # button 6
		["thing_26|0.0,0.0,0.0|0.0,0.0,0.0|button|square|settings_container|settings_container/thing_26|settings_container|instructions_set_2"],
		["-5.75,-0.44,0|5.75,-0.44,0|5.75,0.44,0|-5.75,0.44,0"],
		["|36|0.05|1.0"]
	],
	9: [ # button 7
		["thing_27|0.0,0.0,0.0|0.0,0.0,0.0|button|square|settings_container|settings_container/thing_27|settings_container|instructions_set_2"],
		["-5.75,-0.44,0|5.75,-0.44,0|5.75,0.44,0|-5.75,0.44,0"],
		["|36|0.05|1.0"]
	],
	10: [ # button 8
		["thing_28|0.0,0.0,0.0|0.0,0.0,0.0|button|square|settings_container|settings_container/thing_28|settings_container|instructions_set_2"],
		["-5.75,-0.44,0|5.75,-0.44,0|5.75,0.44,0|-5.75,0.44,0"],
		["|36|0.05|1.0"]
	],
	11: [ # button 9
		["thing_29|0.0,0.0,0.0|0.0,0.0,0.0|button|square|settings_container|settings_container/thing_29|settings_container|instructions_set_2"],
		["-5.75,-0.44,0|5.75,-0.44,0|5.75,0.44,0|-5.75,0.44,0"],
		["|36|0.05|1.0"]
	]
}




























#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

# keyboard split into keys and string

#
#
#┓┏┓    ┓        ┓
#┃┫ ┏┓┓┏┣┓┏┓┏┓┏┓┏┫
#┛┗┛┗ ┗┫┗┛┗┛┗┻┛ ┗┻
	  #┛          
#keyboard
#
#┓┏┓    ┓        ┓  ┏┓   •    
#┃┫ ┏┓┓┏┣┓┏┓┏┓┏┓┏┫  ┗┓╋┏┓┓┏┓┏┓
#┛┗┛┗ ┗┫┗┛┗┛┗┻┛ ┗┻  ┗┛┗┛ ┗┛┗┗┫
	  #┛                     ┛
#keyboard string
#
###
# we need menu, settings, keyboard, 
# cmd console, text windows, with shapes and amountes of lenghts
###
# icons, files, folders, shapes, layers, 
# distance from center of screen, its conrenrs and limits now
###
# paths, changes, loops
# file path, folder path, node path, distance number, layers
###

# keyboard for writing
const records_map_4 = {
	0: [ # container  #0.0,0.0,0.0 # 0.0,-4.5,0.41
		["thing_23|0.0,0.0,0.0|0.0,0.0,0.0|container|keyboard|main|keyboard_container|containers|instruction_set_3"],
		["keyboard_container|0"]
	],
	1: [ # datapoint
		["thing_24|0.0,0.0,0.0|0.0,0.0,0.0|datapoint|1|keyboard_container|keyboard_container/thing_24|datapoints|instruction_set_3"],
		["100"]
	],

## screen where ? different order?


	2:[ # connecting mechanism?
		["thing_25|0.0,0.0,0.0|0.0,0.0,0.0|model|square|keyboard_container|keyboard_container/thing_25|keyboard_container|instruction_set_3"],
		["-0.25,-0.25,0|0.25,-0.25,0|0.25,0.25,0|-0.25,0.25,0"],
		["0.33|1.0"]
	],
	3:[ # another button?
		["thing_26|0.0,0.0,0.0|0.0,0.0,0.0|model|square|keyboard_container|keyboard_container/thing_26|keyboard_container|instruction_set_3"],
		["-0.25,-0.25,0|0.25,-0.25,0|0.25,0.25,0|-0.25,0.25,0"],
		["0.66|1.0"]
	],
	4:[ # text bracket
		["thing_27|0.0,0.0,0.0|0.0,0.0,0.0|model|square|keyboard_container|keyboard_container/thing_27|keyboard_container|instruction_set_3"],
		["-2,-0.25,0|2,-0.25,0|2,0.25,0|-2,0.25,0"],
		["0.89|1.0"]
	],
	5: [ # Text for bracet
		["thing_28|0.0,0.0,0.0|0.0,0.0,0.0|text|square|keyboard_container|keyboard_container/thing_28|keyboard_container|instruction_set_3"],
		["|33"]
	],
	6: [ # button to close
		["thing_29|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_container|keyboard_container/thing_29|keyboard_container|instruction_set_3"],
		["-0.25,-0.25,0|0.25,-0.25,0|0.25,0.25,0|-0.25,0.25,0"],
		["x|36|0.11|1.0"]
	],
	7: [ # shape to hold it all together hehe
		["thing_30|0.0,0.0,0.0|0.0,0.0,0.0|model|square|keyboard_container|keyboard_container/thing_30|keyboard_container|instruction_set_3"],
		["-2.66,-0.62,0|2.66,-0.62,0|2.66,0.62,0|-2.66,0.62,0"],
		["0.11|1.0"]
	]
	
}

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

# keyboard

#┓┏┓    ┓        ┓   ┓              
#┃┫ ┏┓┓┏┣┓┏┓┏┓┏┓┏┫  ┏┣┓┏┓┏┓┏┓┏╋┏┓┏┓┏
#┛┗┛┗ ┗┫┗┛┗┛┗┻┛ ┗┻  ┗┛┗┗┻┛ ┗┻┗┗┗ ┛ ┛
	  #┛# keyboard characters                            
###
# we need menu, settings, keyboard, 
# cmd console, text windows, with shapes and amountes of lenghts
# string we can edit, but not trully freely, we need controler for that like arrows for precise edit with keyboard
###
# icons, files, folders, shapes, layers, 
# distance from center of screen, its conrenrs and limits now
# we have shapes with files, words, numbers, we must connect icons with shapes, from center, to outside, and shape of the outside
###
# paths, changes, loops
# file path, folder path, node path, distance number, layers
# tree path, change of visibility, point, direction, distance
###

# keyboard for writing i mean first left side

# record had datapoint, container, window screen layer with scenes

const records_map_5 = {
	0: [ # container for keyboard left 0.0,-4.5,0.41 positiopn dude relax 0|1 so it is 1 lol
		["thing_33|0.0,0.0,0.0|0.0,0.0,0.0|container|keyboard_left|main|keyboard_left_container|containers|instruction_set_4"],
		["keyboard_left_container|0"]
	],
	1: [ # datapoint for keyboard left
		["thing_34|0.0,0.0,0.0|0.0,0.0,0.0|datapoint|1|keyboard_left_container|keyboard_left_container/thing_34|datapoints|instruction_set_4"],
		["100"]
	],
	2:[ # screen, to hold them keys here
		["thing_35|0.0,0.0,0.0|0.0,0.0,0.0|screen|1:1|keyboard_left_container|keyboard_left_container/thing_35|keyboard_left_container|instruction_set_4"],
		["-5,-5,0|0,-5,0|0,0,0|-5,0,0"],
		["0.033|0.69"]
	],

#
	#┓     
#┓┏┏┓┃┓┏┏┓┏
#┗┛┗┻┗┗┻┗ ┛
		  #


	3: [ # q button
		["thing_36|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_36|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["q|36|0.11|1.0"]
	],
	4: [ # w button
		["thing_37|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_37|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["w|36|0.11|1.0"]
	],
	5: [ # e button
		["thing_38|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_38|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["e|36|0.11|1.0"]
	],
	6: [ # r button
		["thing_39|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_39|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["r|36|0.11|1.0"]
	],
	7: [ # t button
		["thing_40|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_40|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["t|36|0.11|1.0"]
	],
	
	# where is y
	
	8: [ # a button
		["thing_41|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_41|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["a|36|0.11|1.0"]
	],
	9: [ # s button
		["thing_42|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_42|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["s|36|0.11|1.0"]
	],
	10: [ # d button
		["thing_43|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_43|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["d|36|0.11|1.0"]
	],
	11: [ # f button
		["thing_44|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_44|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["f|36|0.11|1.0"]
	],
	
	
	
	## special delta
	
	12: [ # shift button △▲
		["thing_45|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_45|keyboard_left_container|instruction_set_4"],
		["-0.69,-0.58,0|0.69,-0.58,0|0.69,0.58,0|-0.69,0.58,0"],
		["△|36|0.11|1.0"]
	],
	
	
	
	13: [ # z button 
		["thing_46|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_46|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["z|36|0.11|1.0"]
	],
	14: [ # x button 
		["thing_47|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_47|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["x|36|0.11|1.0"]
	],
	15: [ # c button 
		["thing_48|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_48|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["c|36|0.11|1.0"]
	],
	16: [ # v button 
		["thing_49|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_49|keyboard_left_container|instruction_set_4"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["v|36|0.11|1.0"]

#
#┓┏┓    ┓        ┓      •  ┓    
#┃┫ ┏┓┓┏┣┓┏┓┏┓┏┓┏┫  ┏┓┏┏┓╋┏┣┓┏┓┏
#┛┗┛┗ ┗┫┗┛┗┛┗┻┛ ┗┻  ┛┗┻┛┗┗┗┛┗┗ ┛
	  #┛                        
# keyboard switches


	],
	17: [ # numbers button 
		["thing_50|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_50|keyboard_left_container|instruction_set_4"],
		["-0.69,-0.58,0|0.69,-0.58,0|0.69,0.58,0|-0.69,0.58,0"],
		["0010110|36|0.11|1.0"]
	],
	18: [ # space button 
		["thing_51|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_left_container|keyboard_left_container/thing_51|keyboard_left_container|instruction_set_4"],
		["-1.73,-0.58,0|1.73,-0.58,0|1.73,0.58,0|-1.73,0.58,0"],
		["space|36|0.11|1.0"]
	]
}



# keyboard for writing right side
const records_map_6 = {
	0: [ # container for keyboard right 0.0,-4.5,0.41
		["thing_52|0.0,0.0,0.0|0.0,0.0,0.0|container|keyboard_right|main|keyboard_right_container|containers|instruction_set_5"],
		["keyboard_right_container|0"]
	],
	1: [ # datapoint for keyboard right
		["thing_53|0.0,0.0,0.0|0.0,0.0,0.0|datapoint|1|keyboard_right_container|keyboard_right_container/thing_53|datapoints|instruction_set_5"],
		["100"]
	],
	2:[ # screen, to hold them keys here
		["thing_54|0.0,0.0,0.0|0.0,0.0,0.0|screen|1:1|keyboard_right_container|keyboard_right_container/thing_54|keyboard_right_container|instruction_set_5"],
		["0,-5,0|5,-5,0|5,0,0|0,0,0"],
		["0.033|0.69"]
	],

#
	#┓     
#┓┏┏┓┃┓┏┏┓┏
#┗┛┗┻┗┗┻┗ ┛
		  #
# values



	3: [ # p button
		["thing_55|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_55|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["p|36|0.11|1.0"]
	],
	4: [ # o button
		["thing_56|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_56|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["o|36|0.11|1.0"]
	],
	5: [ # i button
		["thing_57|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_57|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["i|36|0.11|1.0"]
	],
	6: [ # u button
		["thing_58|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_58|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["u|36|0.11|1.0"]
	],
	7: [ # y button
		["thing_59|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_59|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["y|36|0.11|1.0"]
	],
	8: [ # l button
		["thing_60|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_60|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["l|36|0.11|1.0"]
	],
	9: [ # k button
		["thing_61|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_61|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["k|36|0.11|1.0"]
	],
	10: [ # j button
		["thing_62|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_62|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["j|36|0.11|1.0"]
	],
	11: [ # h button
		["thing_63|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_63|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["h|36|0.11|1.0"]
	],
	
	##
	12: [ # undo button
		["thing_64|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_64|keyboard_right_container|instruction_set_5"],
		["-0.69,-0.58,0|0.69,-0.58,0|0.69,0.58,0|-0.69,0.58,0"],
		["undo|36|0.11|1.0"]
	],
	
	##
	
	
	13: [ # m button 
		["thing_65|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_65|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["m|36|0.11|1.0"]
	],
	14: [ # n button 
		["thing_66|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_66|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["n|36|0.11|1.0"]
	],
	15: [ # b button 
		["thing_67|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_67|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["b|36|0.11|1.0"]
	],
	16: [ # g button 
		["thing_68|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_68|keyboard_right_container|instruction_set_5"],
		["-0.44,-0.58,0|0.44,-0.58,0|0.44,0.58,0|-0.44,0.58,0"],
		["g|36|0.11|1.0"]
	],





#
#
#┓┏┓    ┓        ┓      •  ┓    
#┃┫ ┏┓┓┏┣┓┏┓┏┓┏┓┏┫  ┏┓┏┏┓╋┏┣┓┏┓┏
#┛┗┛┗ ┗┫┗┛┗┛┗┻┛ ┗┻  ┛┗┻┛┗┗┗┛┗┗ ┛
	  #┛                        
# keyboard switches


	17: [ # return button 
		["thing_69|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_69|keyboard_right_container|instruction_set_5"],
		["-0.69,-0.58,0|0.69,-0.58,0|0.69,0.58,0|-0.69,0.58,0"],
		["return|36|0.11|1.0"]
	],
	18: [ # return button 
		["thing_70|0.0,0.0,0.0|0.0,0.0,0.0|button|menu|keyboard_right_container|keyboard_right_container/thing_70|keyboard_right_container|instruction_set_5"],
		["-1.73,-0.58,0|1.73,-0.58,0|1.73,0.58,0|-1.73,0.58,0"],
		["bar     |36|0.11|1.0"]
	]
}



































#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

# things creation

###
# we need menu, settings, keyboard, 
# cmd console, text windows, with shapes and amountes of lenghts
# string we can edit, but not trully freely, we need controler for that like arrows for precise edit with keyboard
###
# icons, files, folders, shapes, layers, 
# distance from center of screen, its conrenrs and limits now
# we have shapes with files, words, numbers, we must connect icons with shapes, from center, to outside, and shape of the outside
###
# paths, changes, loops
# file path, folder path, node path, distance number, layers
# tree path, change of visibility, point, direction, distance
###
# add new thing with previous thing
# like switch, points, shape, light, color, meaning
# simple meaning of a thing, scares me
###





# things creation stuff
const records_map_7 = {
	0: [ # container
		["thing_71|0.0,0.0,0.0|0.0,0.0,0.0|container|things_creation|main|things_creation_container|containers|instruction_set_6"],
		["things_creation_container|0"]
	],
	1: [ # datapoint
		["thing_72|0.0,0.0,0.0|0.0,0.0,0.0|datapoint|1|things_creation_container|things_creation_container/thing_72|datapoints|instruction_set_6"],
		["100"]
	],
	2:[ # screen
		["thing_73|0.0,0.0,0.0|0.0,0.0,0.0|screen|12:9|things_creation_container|things_creation_container/thing_73|things_creation_container|instruction_set_6"],
		["-6,-4.5,0|6,-4.5,0|6,4.5,0|-6,4.5,0"],
		["0.033|0.69"]
	],
	3:[ # model smaller
		["thing_74|0.0,0.0,0.0|0.0,0.0,0.0|model|square|things_creation_container|things_creation_container/thing_74|things_creation_container|instruction_set_6"],
		["-1,-0.25,0|1,-0.25,0|1,0.25,0|-1,0.25,0"],
		["0.066|0.88"]
	],
	4:[ # model bigger
		["thing_75|0.0,0.0,0.0|0.0,0.0,0.0|model|square|things_creation_container|things_creation_container/thing_75|things_creation_container|instruction_set_6"],
		["-3,-0.25,0|3,-0.25,0|3,0.25,0|-3,0.25,0"],
		["0.066|0.88"]
	]
}

# singular lines, shape, position, center plus text, lenght too, if we put limit in height
const records_map_8 = {
	0:[ # container
		["thing_0|0.0,0.0,0.0|0.0,0.0,0.0|container|singular_lines|main|singular_lines_container|containers|instructions_set_7"],
		["singular_lines_container|0"]
	],
	1: [ # data_point
		["thing_1|0.0,0.0,0.0|0.0,0.0,0.0|datapoint|0|singular_lines_container|singular_lines_container/thing_1|datapoints|instructions_set_7"],
		["100"]
	],
	2:[ # model smaller
		["thing_2|0.0,0.0,0.0|0.0,0.0,0.0|model|square|singular_lines_container|singular_lines_container/thing_2|singular_lines_container|instructions_set_7"],
		["-1,-0.25,0|1,-0.25,0|1,0.25,0|-1,0.25,0"],
		["0.066|0.88"]
	],
	3:[ # model bigger
		["thing_3|0.0,0.0,0.0|0.0,0.0,0.0|model|square|singular_lines_container|singular_lines_container/thing_3|singular_lines_container|instructions_set_7"],
		["-3,-0.25,0|3,-0.25,0|3,0.25,0|-3,0.25,0"],
		["0.066|0.88"]
	],
	4: [ # Text
		["thing_4|0.0,0.0,0.0|0.0,0.0,0.0|text|square|singular_lines_container|singular_lines_container/thing_4|singular_lines_container|instructions_set_7"],
		["text|33"]
	],
	5: [ # Text
		["thing_5|0.0,0.0,0.0|0.0,0.0,0.0|text|square|singular_lines_container|singular_lines_container/thing_5|singular_lines_container|instructions_set_7"],
		["text|33"]
	]
}


#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            


#
#
	 #┓              
#┏┏┓┏┓┃┏┏┓  ┏┓┏┓┏┳┓┏┓
#┛┛┗┗┻┛┗┗   ┗┫┗┻┛┗┗┗ 
			#┛       



###
# we need menu, settings, keyboard, 
# cmd console, text windows, with shapes and amountes of lenghts
# string we can edit, but not trully freely, we need controler for that like arrows for precise edit with keyboard
###
# icons, files, folders, shapes, layers, 
# distance from center of screen, its conrenrs and limits now
# we have shapes with files, words, numbers, we must connect icons with shapes, from center, to outside, and shape of the outside
###
# paths, changes, loops
# file path, folder path, node path, distance number, layers
# tree path, change of visibility, point, direction, distance
###
# add new thing with previous thing
# like switch, points, shape, light, color, meaning
# simple meaning of a thing, scares me
###
# again we add something like icon in settings, menu, windows, shapes, positions, relative to what was, so
# time stuff, repeat, return, input, output, rx, tx, everything is just words that repeats
# we must cut it a little with snake game, what we nead, head, camera, menu, settings, movement,
###



######################## from Claude


# Add this to your RecordsBank class to integrate the Snake game
# You can copy this section into your records_bank.gd file

# Space Snake records 
const records_map_snake = {
	0: [ # Snake Container
		["thing_100|0.0,0.0,0.0|0.0,0.0,0.0|container|snake_game|main|snake_game_container|containers|instruction_set_10"],
		["snake_game_container|0"]
	],
	1: [ # Snake Datapoint
		["thing_101|0.0,0.0,0.0|0.0,0.0,0.0|datapoint|0|snake_game_container|snake_game_container/thing_101|datapoints|instruction_set_10"],
		["100"]
	],
	2: [ # Snake Game Module 
		["thing_102|0.0,0.0,0.0|0.0,0.0,0.0|model|square|snake_game_container|snake_game_container/thing_102|snake_game_container|instruction_set_10"],
		["0.0,0.0,0.0|10.0,10.0,0.5"],
		["0.1|1.0"]
	],
	3: [ # Info Text
		["thing_103|0.0,0.0,5.0|0.0,0.0,0.0|text|square|snake_game_container|snake_game_container/thing_103|snake_game_container|instruction_set_10"],
		["Space Snake - Use Arrow Keys|33"],
		["0.69|1.0"]
	],
	4: [ # Up Button
		["thing_104|0.0,5.0,0.0|0.0,0.0,0.0|button|menu|snake_game_container|snake_game_container/thing_104|snake_game_container|instruction_set_10"],
		["-1,-0.5,0|1,-0.5,0|1,0.5,0|-1,0.5,0"],
		["Up|36|0.69|1.0"]
	],
	5: [ # Down Button
		["thing_105|0.0,4.0,0.0|0.0,0.0,0.0|button|menu|snake_game_container|snake_game_container/thing_105|snake_game_container|instruction_set_10"],
		["-1,-0.5,0|1,-0.5,0|1,0.5,0|-1,0.5,0"],
		["Down|36|0.69|1.0"]
	],
	6: [ # Left Button
		["thing_106|-1.5,4.5,0.0|0.0,0.0,0.0|button|menu|snake_game_container|snake_game_container/thing_106|snake_game_container|instruction_set_10"],
		["-1,-0.5,0|1,-0.5,0|1,0.5,0|-1,0.5,0"],
		["Left|36|0.69|1.0"]
	],
	7: [ # Right Button
		["thing_107|1.5,4.5,0.0|0.0,0.0,0.0|button|menu|snake_game_container|snake_game_container/thing_107|snake_game_container|instruction_set_10"],
		["-1,-0.5,0|1,-0.5,0|1,0.5,0|-1,0.5,0"],
		["Right|36|0.69|1.0"]
	],
	8: [ # Add Segment Button
		["thing_108|3.0,5.0,0.0|0.0,0.0,0.0|button|menu|snake_game_container|snake_game_container/thing_108|snake_game_container|instruction_set_10"],
		["-1.5,-0.5,0|1.5,-0.5,0|1.5,0.5,0|-1.5,0.5,0"],
		["Add Segment|36|0.69|1.0"]
	],
	9: [ # Reset Button
		["thing_109|3.0,4.0,0.0|0.0,0.0,0.0|button|menu|snake_game_container|snake_game_container/thing_109|snake_game_container|instruction_set_10"],
		["-1.5,-0.5,0|1.5,-0.5,0|1.5,0.5,0|-1.5,0.5,0"],
		["Reset|36|0.69|1.0"]
	],
	10: [ # Speed Slider (shown as buttons)
		["thing_110|-3.0,5.0,0.0|0.0,0.0,0.0|button|menu|snake_game_container|snake_game_container/thing_110|snake_game_container|instruction_set_10"],
		["-1,-0.5,0|1,-0.5,0|1,0.5,0|-1,0.5,0"],
		["Speed 1|36|0.69|1.0"]
	],
	11: [ 
		["thing_111|-3.0,4.0,0.0|0.0,0.0,0.0|button|menu|snake_game_container|snake_game_container/thing_111|snake_game_container|instruction_set_10"],
		["-1,-0.5,0|1,-0.5,0|1,0.5,0|-1,0.5,0"],
		["Speed 2|36|0.69|1.0"]
	],
	12: [ 
		["thing_112|-3.0,3.0,0.0|0.0,0.0,0.0|button|menu|snake_game_container|snake_game_container/thing_112|snake_game_container|instruction_set_10"],
		["-1,-0.5,0|1,-0.5,0|1,0.5,0|-1,0.5,0"],
		["Speed 3|36|0.69|1.0"]
	],
	13: [ # Score text
		["thing_113|0.0,6.0,0.0|0.0,0.0,0.0|text|square|snake_game_container|snake_game_container/thing_113|snake_game_container|instruction_set_10"],
		["Score: 0|33"],
		["0.69|1.0"]
	],
	14: [ # Back button
		["thing_114|-4.0,6.0,0.0|0.0,0.0,0.0|button|menu|snake_game_container|snake_game_container/thing_114|snake_game_container|instruction_set_10"],
		["-1,-0.5,0|1,-0.5,0|1,0.5,0|-1,0.5,0"],
		["Back|36|0.69|1.0"]
	]
}

# from 101 to 114
#
#
# 
#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#                                   
#                                  
##
#
#┏┓┳┳┓┳┓  ┏┓       ┓    ┏┳┓       •    ┓  ┓          
#┃ ┃┃┃┃┃  ┃ ┏┓┏┓┏┏┓┃┏┓   ┃ ┏┓┏┓┏┳┓┓┏┓┏┓┃  ┃ ┏┓┓┏┏┓┏┓┏
#┗┛┛ ┗┻┛  ┗┛┗┛┛┗┛┗┛┗┗    ┻ ┗ ┛ ┛┗┗┗┛┗┗┻┗  ┗┛┗┻┗┫┗ ┛ ┛
#                                             #┛     
#



# Terminal / Console records for RecordsBank
# Add to records_bank.gd

const records_map_terminal = {
	0: [ # Terminal Container
		["thing_300|0.0,0.0,0.0|0.0,0.0,0.0|container|terminal|main|terminal_container|containers|instruction_set_terminal"],
		["terminal_container|0"]
	],
	1: [ # Terminal Datapoint
		["thing_301|0.0,0.0,0.0|0.0,0.0,0.0|datapoint|0|terminal_container|terminal_container/thing_301|datapoints|instruction_set_terminal"],
		["100"]
	],
	2: [ # Terminal Screen - Main viewport
		["thing_302|0.0,0.0,0.0|0.0,0.0,0.0|screen|16:9|terminal_container|terminal_container/thing_302|terminal_container|instruction_set_terminal"],
		["-8,-4.5,0|8,-4.5,0|8,4.5,0|-8,4.5,0"],
		["0.033|0.85"]
	],
	3: [ # Terminal Header Bar
		["thing_303|0.0,4.25,0.1|0.0,0.0,0.0|model|square|terminal_container|terminal_container/thing_303|terminal_container|instruction_set_terminal"],
		["-8,-0.25,0|8,-0.25,0|8,0.25,0|-8,0.25,0"],
		["0.22|0.95"]
	],
	4: [ # Terminal Title Text 
		["thing_304|0.0,4.25,0.2|0.0,0.0,0.0|text|terminal|terminal_container|terminal_container/thing_304|terminal_container|instruction_set_terminal"],
		["JSH Terminal|28"]
	],
	5: [ # Output Area Background
		["thing_305|0.0,0.55,0.1|0.0,0.0,0.0|model|square|terminal_container|terminal_container/thing_305|terminal_container|instruction_set_terminal"],
		["-7.75,-3.45,0|7.75,-3.45,0|7.75,3.45,0|-7.75,3.45,0"],
		["0.11|0.9"]
	],
	6: [ # Terminal Output Text Area
		["thing_306|0.0,0.55,0.2|0.0,0.0,0.0|text_mesh|terminal|terminal_container|terminal_container/thing_306|terminal_container|instruction_set_terminal"],
		["Terminal_Output"],
		["JSH Terminal v1.0\nInitializing system...\nSystem ready.\n>_|600|0.025|0.02|0.75|1.0"]
	],
	7: [ # Input Line Background
		["thing_307|0.0,-4.0,0.1|0.0,0.0,0.0|model|square|terminal_container|terminal_container/thing_307|terminal_container|instruction_set_terminal"],
		["-7.75,-0.35,0|7.75,-0.35,0|7.75,0.35,0|-7.75,0.35,0"],
		["0.15|0.95"]
	],
	8: [ # Input Prompt Symbol
		["thing_308|-7.5,-4.0,0.2|0.0,0.0,0.0|text|terminal_prompt|terminal_container|terminal_container/thing_308|terminal_container|instruction_set_terminal"],
		[">|24"]
	],
	9: [ # Input Text (what user is typing)
		["thing_309|-7.25,-4.0,0.2|0.0,0.0,0.0|text|terminal_input|terminal_container|terminal_container/thing_309|terminal_container|instruction_set_terminal"],
		["_|24"]
	],
	10: [ # Cursor
		["thing_310|-7.25,-4.0,0.25|0.0,0.0,0.0|flat_shape|cursor|terminal_container|terminal_container/thing_310|terminal_container|instruction_set_terminal"],
		["-0.05,0.2,0|0.05,0.2,0|0.05,-0.2,0|-0.05,-0.2,0"],
		["0.85|1.0"]
	],
	11: [ # Close Button
		["thing_311|7.5,4.25,0.2|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_311|terminal_container|instruction_set_terminal"],
		["-0.25,-0.25,0|0.25,-0.25,0|0.25,0.25,0|-0.25,0.25,0"],
		["X|24|0.22|1.0"]
	],
	12: [ # History Button
		["thing_312|-7.0,4.25,0.2|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_312|terminal_container|instruction_set_terminal"],
		["-0.75,-0.25,0|0.75,-0.25,0|0.75,0.25,0|-0.75,0.25,0"],
		["History|20|0.22|1.0"]
	],
	13: [ # Clear Button
		["thing_313|-5.0,4.25,0.2|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_313|terminal_container|instruction_set_terminal"],
		["-0.75,-0.25,0|0.75,-0.25,0|0.75,0.25,0|-0.75,0.25,0"],
		["Clear|20|0.22|1.0"]
	],
	14: [ # Help Button
		["thing_314|-3.0,4.25,0.2|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_314|terminal_container|instruction_set_terminal"],
		["-0.75,-0.25,0|0.75,-0.25,0|0.75,0.25,0|-0.75,0.25,0"],
		["Help|20|0.22|1.0"]
	],
	15: [ # Execute Button
		["thing_315|6.0,4.25,0.2|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_315|terminal_container|instruction_set_terminal"],
		["-1.0,-0.25,0|1.0,-0.25,0|1.0,0.25,0|-1.0,0.25,0"],
		["Execute|20|0.22|1.0"]
	],
	16: [ # Keyboard Activation Zone (for input line)
		["thing_316|0.0,-4.0,0.15|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_316|terminal_container|instruction_set_terminal"],
		["-7.75,-0.35,0|7.75,-0.35,0|7.75,0.35,0|-7.75,0.35,0"],
		["||20|0.0|0.0"]
	],
	17: [ # Status Bar
		["thing_317|0.0,-4.5,0.1|0.0,0.0,0.0|model|square|terminal_container|terminal_container/thing_317|terminal_container|instruction_set_terminal"],
		["-8,-0.15,0|8,-0.15,0|8,0.15,0|-8,0.15,0"],
		["0.15|0.9"]
	],
	18: [ # Status Text
		["thing_318|-7.5,-4.5,0.15|0.0,0.0,0.0|text|status|terminal_container|terminal_container/thing_318|terminal_container|instruction_set_terminal"],
		["Ready|18"]
	],
	19: [ # Memory Display
		["thing_319|7.0,-4.5,0.15|0.0,0.0,0.0|text|memory|terminal_container|terminal_container/thing_319|terminal_container|instruction_set_terminal"],
		["MEM: 100%|18"]
	],
	20: [ # Tab List Background
		["thing_320|-7.5,3.5,0.1|0.0,0.0,0.0|model|square|terminal_container|terminal_container/thing_320|terminal_container|instruction_set_terminal"],
		["-0.5,-0.25,0|1.5,-0.25,0|1.5,0.25,0|-0.5,0.25,0"],
		["0.15|0.95"]
	],
	21: [ # Tab 1
		["thing_321|-7.0,3.5,0.2|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_321|terminal_container|instruction_set_terminal"],
		["-0.5,-0.25,0|0.5,-0.25,0|0.5,0.25,0|-0.5,0.25,0"],
		["1|18|0.22|1.0"]
	]
}
##
## Terminal / Console records for RecordsBank
## Add to records_bank.gd
#
#const records_map_terminal = {
	#0: [ # Terminal Container
		#["thing_300|0.0,0.0,0.0|0.0,0.0,0.0|container|terminal|main|terminal_container|containers|instruction_set_terminal"],
		#["terminal_container|0"]
	#],
	#1: [ # Terminal Datapoint
		#["thing_301|0.0,0.0,0.0|0.0,0.0,0.0|datapoint|0|terminal_container|terminal_container/thing_301|datapoints|instruction_set_terminal"],
		#["100"]
	#],
	#2: [ # Terminal Screen - Main viewport
		#["thing_302|0.0,0.0,0.0|0.0,0.0,0.0|screen|16:9|terminal_container|terminal_container/thing_302|terminal_container|instruction_set_terminal"],
		#["-8,-4.5,0|8,-4.5,0|8,4.5,0|-8,4.5,0"],
		#["0.033|0.85"]
	#],
	#3: [ # Terminal Header Bar
		#["thing_303|0.0,4.25,0.1|0.0,0.0,0.0|model|square|terminal_container|terminal_container/thing_303|terminal_container|instruction_set_terminal"],
		#["-8,-0.25,0|8,-0.25,0|8,0.25,0|-8,0.25,0"],
		#["0.22|0.95"]
	#],
	#4: [ # Terminal Title Text 
		#["thing_304|0.0,4.25,0.2|0.0,0.0,0.0|text|terminal|terminal_container|terminal_container/thing_304|terminal_container|instruction_set_terminal"],
		#["JSH Terminal|28"]
	#],
	#5: [ # Output Area Background
		#["thing_305|0.0,0.55,0.1|0.0,0.0,0.0|model|square|terminal_container|terminal_container/thing_305|terminal_container|instruction_set_terminal"],
		#["-7.75,-3.45,0|7.75,-3.45,0|7.75,3.45,0|-7.75,3.45,0"],
		#["0.11|0.9"]
	#],
	#6: [ # Terminal Output Text Area
		#["thing_306|0.0,0.55,0.2|0.0,0.0,0.0|text_mesh|terminal|terminal_container|terminal_container/thing_306|terminal_container|instruction_set_terminal"],
		#["Terminal_Output"],
		#["JSH Terminal v1.0\nInitializing system...\nSystem ready.\n>_|600|0.025|0.02|0.75|1.0"]
	#],
	#7: [ # Input Line Background
		#["thing_307|0.0,-4.0,0.1|0.0,0.0,0.0|model|square|terminal_container|terminal_container/thing_307|terminal_container|instruction_set_terminal"],
		#["-7.75,-0.35,0|7.75,-0.35,0|7.75,0.35,0|-7.75,0.35,0"],
		#["0.15|0.95"]
	#],
	#8: [ # Input Prompt Symbol
		#["thing_308|-7.5,-4.0,0.2|0.0,0.0,0.0|text|terminal_prompt|terminal_container|terminal_container/thing_308|terminal_container|instruction_set_terminal"],
		#[">|24"]
	#],
	#9: [ # Input Text (what user is typing)
		#["thing_309|-7.25,-4.0,0.2|0.0,0.0,0.0|text|terminal_input|terminal_container|terminal_container/thing_309|terminal_container|instruction_set_terminal"],
		#["_|24"]
	#],
	#10: [ # Cursor
		#["thing_310|-7.25,-4.0,0.25|0.0,0.0,0.0|flat_shape|cursor|terminal_container|terminal_container/thing_310|terminal_container|instruction_set_terminal"],
		#["-0.05,0.2,0|0.05,0.2,0|0.05,-0.2,0|-0.05,-0.2,0"],
		#["0.85|1.0"]
	#],
	#11: [ # Close Button
		#["thing_311|7.5,4.25,0.2|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_311|terminal_container|instruction_set_terminal"],
		#["-0.25,-0.25,0|0.25,-0.25,0|0.25,0.25,0|-0.25,0.25,0"],
		#["X|24|0.22|1.0"]
	#],
	#12: [ # History Button
		#["thing_312|-7.0,4.25,0.2|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_312|terminal_container|instruction_set_terminal"],
		#["-0.75,-0.25,0|0.75,-0.25,0|0.75,0.25,0|-0.75,0.25,0"],
		#["History|20|0.22|1.0"]
	#],
	#13: [ # Clear Button
		#["thing_313|-5.0,4.25,0.2|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_313|terminal_container|instruction_set_terminal"],
		#["-0.75,-0.25,0|0.75,-0.25,0|0.75,0.25,0|-0.75,0.25,0"],
		#["Clear|20|0.22|1.0"]
	#],
	#14: [ # Help Button
		#["thing_314|-3.0,4.25,0.2|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_314|terminal_container|instruction_set_terminal"],
		#["-0.75,-0.25,0|0.75,-0.25,0|0.75,0.25,0|-0.75,0.25,0"],
		#["Help|20|0.22|1.0"]
	#],
	#15: [ # Execute Button
		#["thing_315|6.0,4.25,0.2|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_315|terminal_container|instruction_set_terminal"],
		#["-1.0,-0.25,0|1.0,-0.25,0|1.0,0.25,0|-1.0,0.25,0"],
		#["Execute|20|0.22|1.0"]
	#],
	#16: [ # Keyboard Activation Zone (for input line)
		#["thing_316|0.0,-4.0,0.15|0.0,0.0,0.0|button|square|terminal_container|terminal_container/thing_316|terminal_container|instruction_set_terminal"],
		#["-7.75,-0.35,0|7.75,-0.35,0|7.75,0.35,0|-7.75,0.35,0"],
		#["||20|0.0|0.0"]
	#],
	#17: [ # Status Bar
		#["thing_317|0.0,-4.5,0.1|0.0,0.0,0.0|model|square|terminal_container|terminal_container/thing_317|terminal_container|instruction_set_terminal"],
		#["-8,-0.15,0|8,-0.15,0|8,0.15,0|-8,0.15,0"],
		#["0.15|0.9"]
	#],
	#18: [ # Status Text
		#["thing_318|-7.5,-4.5,0.15|0.0,0.0,0.0|text|status|terminal_container|terminal_container/thing_318|terminal_container|instruction_set_terminal"],
		#["Ready|18"]
	#],
	#19: [ # Memory Display
		#["thing_319|7.0,-4.5,0.15|0.0,0.0,0.0|text|memory|terminal_container|terminal_container/thing_319|terminal_container|instruction_set_terminal"],
		#["MEM: 100%|18"]
	#]
#}

###
# we need menu, settings, keyboard, 
# cmd console, text windows, with shapes and amountes of lenghts
# string we can edit, but not trully freely, we need controler for that like arrows for precise edit with keyboard
###
# icons, files, folders, shapes, layers, 
# distance from center of screen, its conrenrs and limits now
# we have shapes with files, words, numbers, we must connect icons with shapes, from center, to outside, and shape of the outside
###

# Console/Terminal records for RecordsBank
# This can be added to your records_bank.gd file

const records_map_terminal_ = {
	0: [ # Terminal Container
		["thing_200|0.0,0.0,0.0|0.0,0.0,0.0|container|terminal|main|terminal_container|containers|instruction_set_terminal"],
		["terminal_container|0"]
	],
	1: [ # Terminal Datapoint
		["thing_201|0.0,0.0,0.0|0.0,0.0,0.0|datapoint|0|terminal_container|terminal_container/thing_201|datapoints|instruction_set_terminal"],
		["100"]
	],
	2: [ # Terminal Screen/Window
		["thing_202|0.0,0.0,0.0|0.0,0.0,0.0|screen|16:9|terminal_container|terminal_container/thing_202|terminal_container|instruction_set_terminal"],
		["-8,-4.5,0|8,-4.5,0|8,4.5,0|-8,4.5,0"],
		["0.033|0.69"]
	],
	3: [ # Terminal Output Text Area
		["thing_203|0.0,0.0,0.0|0.0,0.0,0.0|text_mesh|terminal|terminal_container|terminal_container/thing_203|terminal_container|instruction_set_terminal"],
		["Terminal_Output"],
		["Console Ready...|240|0.03|0.02|0.75|1.0"]
	],
	4: [ # Input Bracket (visual element for input line)
		["thing_204|0.0,-3.5,0.0|0.0,0.0,0.0|model|square|terminal_container|terminal_container/thing_204|terminal_container|instruction_set_terminal"],
		["-7.5,-0.4,0|7.5,-0.4,0|7.5,0.4,0|-7.5,0.4,0"],
		["0.15|0.85"]
	],
	5: [ # Input Text (what user is typing)
		["thing_205|0.0,-3.5,0.0|0.0,0.0,0.0|text|terminal_input|terminal_container|terminal_container/thing_205|terminal_container|instruction_set_terminal"],
		[">_|33"]
	],
	6: [ # Command History Button
		["thing_206|-7.0,4.0,0.0|0.0,0.0,0.0|button|menu|terminal_container|terminal_container/thing_206|terminal_container|instruction_set_terminal"],
		["-1,-0.3,0|1,-0.3,0|1,0.3,0|-1,0.3,0"],
		["History|24|0.11|1.0"]
	],
	7: [ # Clear Button
		["thing_207|-4.5,4.0,0.0|0.0,0.0,0.0|button|menu|terminal_container|terminal_container/thing_207|terminal_container|instruction_set_terminal"],
		["-1,-0.3,0|1,-0.3,0|1,0.3,0|-1,0.3,0"],
		["Clear|24|0.11|1.0"]
	],
	8: [ # Execute Button
		["thing_208|-2.0,4.0,0.0|0.0,0.0,0.0|button|menu|terminal_container|terminal_container/thing_208|terminal_container|instruction_set_terminal"],
		["-1,-0.3,0|1,-0.3,0|1,0.3,0|-1,0.3,0"],
		["Execute|24|0.11|1.0"]
	],
	9: [ # Close Button
		["thing_209|7.0,4.0,0.0|0.0,0.0,0.0|button|menu|terminal_container|terminal_container/thing_209|terminal_container|instruction_set_terminal"],
		["-0.3,-0.3,0|0.3,-0.3,0|0.3,0.3,0|-0.3,0.3,0"],
		["X|24|0.11|1.0"]
	],
	10: [ # Help Button
		["thing_210|0.5,4.0,0.0|0.0,0.0,0.0|button|menu|terminal_container|terminal_container/thing_210|terminal_container|instruction_set_terminal"],
		["-1,-0.3,0|1,-0.3,0|1,0.3,0|-1,0.3,0"],
		["Help|24|0.11|1.0"]
	],
	11: [ # Cursor
		["thing_211|-7.0,-3.5,0.1|0.0,0.0,0.0|flat_shape|cursor|terminal_container|terminal_container/thing_211|terminal_container|instruction_set_terminal"],
		["0.0,0.3,0|0.1,0.3,0|0.1,-0.3,0|0.0,-0.3,0"],
		["0.85|1.0"]
	]
}


# paths, changes, loops
# file path, folder path, node path, distance number, layers
# tree path, change of visibility, point, direction, distance
###
# add new thing with previous thing
# like switch, points, shape, light, color, meaning
# simple meaning of a thing, scares me
###
# again we add something like icon in settings, menu, windows, shapes, positions, relative to what was, so
# time stuff, repeat, return, input, output, rx, tx, everything is just words that repeats
# we must cut it a little with snake game, what we nead, head, camera, menu, settings, movement,
###
# console commands and simple things, like fight, flee, run, figure out, find out, find, search
# simple command of states and actions, jump, crouch, change aura, shape, layer, distance, space
# points shapes, layers, distance, connections, paths, load, unload set, record, what is the class file again? is this file important for my 
###
# space game

# console can fill in things up to 400 commands to run it all with nets of words
# data, file, path
# number, position, space


#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

#
#
#┳┓•  •   ┓  ┏┓     ┓ ┓•     
#┃┃┓┏┓┓╋┏┓┃  ┣ ┏┓┏┓╋┣┓┃┓┏┓┏┓┏
#┻┛┗┗┫┗┗┗┻┗  ┗┛┗┻┛ ┗┛┗┗┗┛┗┗┫┛
	#┛                     ┛ 
	
	
# pathways as they walk and crawl
###
# we need menu, settings, keyboard, 
# cmd console, text windows, with shapes and amountes of lenghts
# string we can edit, but not trully freely, we need controler for that like arrows for precise edit with keyboard
###
# icons, files, folders, shapes, layers, 
# distance from center of screen, its conrenrs and limits now
# we have shapes with files, words, numbers, we must connect icons with shapes, from center, to outside, and shape of the outside
###
# paths, changes, loops
# file path, folder path, node path, distance number, layers
# tree path, change of visibility, point, direction, distance
###
# add new thing with previous thing
# like switch, points, shape, light, color, meaning
# simple meaning of a thing, scares me
###
# again we add something like icon in settings, menu, windows, shapes, positions, relative to what was, so
# time stuff, repeat, return, input, output, rx, tx, everything is just words that repeats
# we must cut it a little with snake game, what we nead, head, camera, menu, settings, movement,
###
# console commands and simple things, like fight, flee, run, figure out, find out, find, search
# simple command of states and actions, jump, crouch, change aura, shape, layer, distance, space
# points shapes, layers, distance, connections, paths, load, unload set, record, what is the class file again? is this file important for my 
###
# space game, we need beings and computers in my game and for space, i need my own head, space, spaceship, hub, freight, so many things
# are needed in good game, they need to connect in their own god way too? realism of continuation lol
# stars, galaxies, shaders, points, movement, change, time duration, frequency per things, simple, with numbers, net
###
# files have data in them too? we can use ram like rom hmm, what are scripts, var, func, class, const? change and make,
# attach script to a file
# attach file, script to a node
# check tree, script, node
# we had it month ago too
# that game needs that window of text too

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

#
#┏┳┓       ┓ ┏•   ┓       ┓          
 #┃ ┏┓┓┏╋  ┃┃┃┓┏┓┏┫┏┓┓┏┏  ┃ ┏┓┓┏┏┓┏┓┏
 #┻ ┗ ┛┗┗  ┗┻┛┗┛┗┗┻┗┛┗┻┛  ┗┛┗┻┗┫┗ ┛ ┛
							  #┛     
							

###
# again we add something like icon in settings, menu, windows, shapes, positions, relative to what was, so
# time stuff, repeat, return, input, output, rx, tx, everything is just words that repeats
# we must cut it a little with snake game, what we nead, head, camera, menu, settings, movement,
###
# console commands and simple things, like fight, flee, run, figure out, find out, find, search
# simple command of states and actions, jump, crouch, change aura, shape, layer, distance, space
# points shapes, layers, distance, connections, paths, load, unload set, record, what is the class file again? is this file important for my 
###
# space game, we need beings and computers in my game and for space, i need my own head, space, spaceship, hub, freight, so many things
# are needed in good game, they need to connect in their own god way too? realism of continuation lol
# stars, galaxies, shaders, points, movement, change, time duration, frequency per things, simple, with numbers, net
###
# files have data in them too? we can use ram like rom hmm, what are scripts, var, func, class, const? change and make,
# attach script to a file
# attach file, script to a node
# check tree, script, node
# we had it month ago too
# that game needs that window of text too
###
# so what is important for my window of text
# the one i will like and use
# connections, limits, paths, numbers
###

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#
#┏┓   ┓    ┓           ┳┓•      •    
#┗┓┏┏┓┃┏┓  ┃ ┏┓┓┏┏┓┏┓  ┃┃┓┏┓┏┓┏╋┓┏┓┏┓
#┗┛┗┗┻┗┗   ┗┛┗┻┗┫┗ ┛   ┻┛┗┛ ┗ ┗┗┗┗┛┛┗
			   #┛                    

###
# space game, we need beings and computers in my game and for space, i need my own head, space, spaceship, hub, freight, so many things
# are needed in good game, they need to connect in their own god way too? realism of continuation lol
# stars, galaxies, shaders, points, movement, change, time duration, frequency per things, simple, with numbers, net
###
# files have data in them too? we can use ram like rom hmm, what are scripts, var, func, class, const? change and make,
# attach script to a file
# attach file, script to a node
# check tree, script, node
# we had it month ago too
# that game needs that window of text too
###
# so what is important for my window of text
# the one i will like and use
# connections, limits, paths, numbers
###
# scale, direction, movement
# simple things, per record, that is like storage of time, we have a lot of gray and consts, in that records file, a bank needs short script maybe
# who knows
###
#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#
#┓            ┏┓  •      ┳┓       ┏┓  ┓•   ┏┓       
#┃ ┏┓┓┏┏┓┏┓┏  ┃┃┏┓┓┏┓╋┏  ┃┃┏┓╋┏┓  ┗┓┏┓┃┓╋  ┃┃┏┓┏┓┏┏┓
#┗┛┗┻┗┫┗ ┛ ┛  ┣┛┗┛┗┛┗┗┛  ┻┛┗┻┗┗┻  ┗┛┣┛┗┗┗  ┣┛┗┻┛ ┛┗ 
	 #┛                             ┛               

###
# space game, we need beings and computers in my game and for space, i need my own head, space, spaceship, hub, freight, so many things
# are needed in good game, they need to connect in their own god way too? realism of continuation lol
# stars, galaxies, shaders, points, movement, change, time duration, frequency per things, simple, with numbers, net
###
# files have data in them too? we can use ram like rom hmm, what are scripts, var, func, class, const? change and make,
# attach script to a file
# attach file, script to a node
# check tree, script, node
# we had it month ago too
# that game needs that window of text too
###
# so what is important for my window of text
# the one i will like and use
# connections, limits, paths, numbers
###
# scale, direction, movement
# simple things, per record, that is like storage of time, we have a lot of gray and consts, in that records file, a bank needs short script maybe
# who knows
###
# datasplitter
# data, split, splitter, parse, parser, oars, amounts of bones, paths
# points bones, points of bones and directions of paths in 3d and points way
###

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#
#
#┏┓   ┓    ┏┓┓         ┓   ┏┓          •       ┓ •     
#┃┃┏┓╋┣┓┏  ┃ ┣┓┏┓┏┓┏┓┏┓┃┏  ┃ ┏┓┏┓┏┓┏┓┏╋┓┏┓┏┓┏  ┃ ┓┏┓┏┓┏
#┣┛┗┻┗┛┗┛  ┗┛┛┗┗┻┛┗┛┗┗ ┗┛  ┗┛┗┛┛┗┛┗┗ ┗┗┗┗┛┛┗┛  ┗┛┗┛┗┗ ┛
													  #
###
# space game, we need beings and computers in my game and for space, i need my own head, space, spaceship, hub, freight, so many things
# are needed in good game, they need to connect in their own god way too? realism of continuation lol
# stars, galaxies, shaders, points, movement, change, time duration, frequency per things, simple, with numbers, net
###
# files have data in them too? we can use ram like rom hmm, what are scripts, var, func, class, const? change and make,
# attach script to a file
# attach file, script to a node
# check tree, script, node
# we had it month ago too
# that game needs that window of text too
###
# so what is important for my window of text
# the one i will like and use
# connections, limits, paths, numbers
###
# scale, direction, movement
# simple things, per record, that is like storage of time, we have a lot of gray and consts, in that records file, a bank needs short script maybe
# who knows
###
# datasplitter
# data, split, splitter, parse, parser, oars, amounts of bones, paths
# points bones, points of bones and directions of paths in 3d and points way
###
# nets paths lines
# connections channels points
# connect them and move them and see them lines cmon
###
# my comment is like 333 lines long cmon
# to much at once, maybe for a day? to trully understand what i want?
# the comments with # can have more than one way to be written,
# they are like falling stars that bring hope for alien cutie somewhere
