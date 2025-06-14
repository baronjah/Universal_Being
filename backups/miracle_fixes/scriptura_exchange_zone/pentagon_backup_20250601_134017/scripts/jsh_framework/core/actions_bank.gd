# 🏛️ Actions Bank - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# actions_bank.gd

# res://scripts/Menu_Keyboard_Console/actions_bank.gd

# res://scripts/Menu_Keyboard_Console/interactions_bank.gd

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

#
# Actions_Bank

# actions, scenes, records, instructions
# node script name file code shader, command
# terminal window, view, screen lines, size

# connect it all in bank
# bank combiner maybe, so 5 files and codes
# to collect and combine and see the sky

# folder path classname node file_name
# path container thing node name directory

extends UniversalBeingBase
class_name ActionsBank

#

var interaction_add_number  : String = "interaction_"
var list_add_number : String = "list_"
var Action_name : String = "Action_"

# InteractionsBank.type_of_interactions_0

const type_of_interactions_0 = [
	"change_scene", "add_scene", "change_text", "call_function", "unload_container", "write" , "shift_keyboard" , "number_letter"  , "return_string" , "undo_char" , "load_file" ,"key_interaction" , "value_interaction", "dunno_yet"
]

const call_function = [
	"initialize_container", "write", "move_around", "show_window", "rotate", "connect", "add_thing", "remove_thing"
]




#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

# logo is packed in scenes
# can you remember all files or its names?
# the game of story and memory in messages or few

# one thing changes place
# and can connect too
# InteractionsBank.interactions_list_0

# change thing from scene 0 to 1 and 2 and 1 into 0 in some block layer
# window menu screen
# it is first so base not menu yet, so container and datapoints are created now

const singular_interactions = {
	0: [
		["interaction_0|singular_records_container|thing_1"], # header
		["scene_0"], # where
		["thing_2"], # what trigger
		["change_scene"], # type of action
		["scene_1"] # specifics
	],
	1: [
		["interaction_0|singular_records_container|thing_1"],
		["scene_1"],
		["thing_2"],
		["change_scene"],
		["scene_0"]
	] # add comma ,
}



#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

# action was inter_action as it split as it was similar to instruction
# i had to make it easy for me
# container name

# thing name and number
# the same again number and thing name and container, |
# split remember number and find it

# InteractionsBank.interactions_list_0
# path like folder and number of metadata anyway
# find place to go there

const interactions_list_0 = {
	0: [
		["interaction_0|akashic_records|thing_7"],
		["scene_0|scene_2"],
		["thing_0|thing_1"],
		["change_scene"],
		["scene_1"]
	],
	1: [
		["interaction_1|akashic_records|thing_7"],
		["scene_1"],
		["thing_0"],
		["change_scene"],
		["scene_0"]
	] # add comma ,
}












#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

# scene number int
# thing scene action change of model like instruction?
# scene frame can move points of it all

# amounts limits
# here is more than one point and space
# 100 things as each can have aura and colision and few nodes too

# move things around in datapoints script, beside main code
# InteractionsBank.interactions_list_0
# names adds up, do similar things or in turns and threads codes task queue

# answers are many

const interactions_list_1 = {
	0: [   # MAIN MENU -> THINGS - 1 things menu - scene_3
		["interaction_2|akashic_records|thing_7"], # on which datapoint and scene we are on
		["scene_2"],
		["thing_12"],
		["change_scene|fake_now"],
		["scene_3|testing"] # 12 things                 # to what scene we travel :)
	],     # Things stuff
	1: [   # THINGS -> MAIN MENU - 0 main menu - scene_2
		["interaction_3|akashic_records|thing_7"],
		["scene_3"],
		["thing_17"],
		["change_scene|unload_container"],
		["scene_2|things_creation_container"] # 17 exit/back
	], 
	2: [   # MAIN MENU -> SCENES - 2 scenes menu - scene_4
		["interaction_4|akashic_records|thing_7"],
		["scene_2"],
		["thing_13"],
		["change_scene"],
		["scene_4"] # 13 scenes
	],     # Scenes Stuff
	3: [   # SCENES -> MAIN MENU - 0 main menu - scene_2
		["interaction_5|akashic_records|thing_7"],
		["scene_4"],
		["thing_17"],
		["change_scene"],
		["scene_2"] # 17 exit/back
	], 
	4: [   # MAIN MENU -> INTERACTIONS - 3 interactions menu - scene_5
		["interaction_6|akashic_records|thing_7"],
		["scene_2"],
		["thing_14"],
		["change_scene"],
		["scene_5"] # 14 interactions
	],     # interactions stuff
	5: [   # INTERACTIONS -> MAIN MENU - 0 main menu - scene_2
		["interaction_7|akashic_records|thing_7"],
		["scene_5"],
		["thing_17"],
		["change_scene"],
		["scene_2"] # 17 exit/back
	], # add comma ,
	6: [   # MAIN MENU -> INSTRUCTIONS - 4 instructions menu - scene_6
		["interaction_8|akashic_records|thing_7"],
		["scene_2"],
		["thing_15"],
		["change_scene"],
		["scene_6"] # 15 instructions
	],     # instructions stuff
	7: [   # MAIN MENU -> RACING GAME - Start World of Pallets Racing
		["interaction_50|akashic_records|thing_7"],
		["scene_2"],
		["thing_30"],
		["call_function"],
		["start_racing_game"] # Start racing game
	],     # racing game
	8: [   # INSTRUCTIONS -> MAIN MENU - 0 main menu - scene_2
		["interaction_9|akashic_records|thing_7"],
		["scene_6"],
		["thing_17"],
		["change_scene"],
		["scene_2"] # 17 exit/back
	], # add comma ,
	14: [   # MAIN MENU -> SETTINGS - 5 settings menu - scene_7
		["interaction_10|akashic_records|thing_7"],
		["scene_2"],
		["thing_16"],
		["change_scene"],
		["scene_7"] # 16 settings
	],     
	
	# settings stuff
	9: [   # SETTINGS -> MAIN MENU - 0 main menu - scene_2
		["interaction_11|akashic_records|thing_7"],
		["scene_7"],
		["thing_17"],
		["change_scene|unload_container|unload_container|unload_container|unload_container|unload_container"],
		["scene_2|settings_container|keyboard_container|keyboard_left_container|keyboard_right_container|singular_lines_container"] # 17 exit/back
	],
	10: [   # SETTINGS -> adding new "scene" with clickable stuff to change settings :) 
		["interaction_12|akashic_records|thing_7"], # |load_file
		["scene_7"],
		["thing_12"],
		["add_scene|load_file"],
		["settings|settings_containerøsettings.txt"] # 17 exit/back # |settings.txtøsingular_lines
	],
	# things creation stuff
	11: [   # Things -> adding new "scene" with creation tools and devices and periphelia and manifestations 
		["interaction_148|akashic_records|thing_7"],
		["scene_3"],
		["thing_12"],
		["add_scene"],
		["things_creation"] # 17 exit/back
	],#,
	12: [   # Things -> adding new "scene" with creation tools and devices and periphelia and manifestations 
		["interaction_149|akashic_records|thing_7"],
		["scene_3"],
		["thing_17"],
		["change_scene|unload_container"],
		["scene_2|things_creation"] # 17 exit/back
	],
	13: [   # SETTINGS -> adding new "scene" with clickable stuff to change settings :) 
		["interaction_13|akashic_records|thing_7"], # |load_file
		["scene_7"],
		["thing_16"],
		["add_scene|load_file"],
		["settings|settings_containerømodules.txt"] # 17 exit/back # |settings.txtøsingular_lines
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

# repeat in the same places too
# few times
# maybe once

# here we load a file
# change scene too, can add another scene to a scene, with points, maybe layers of lines and distance
# maybe just word

# connect keyboard, load unload container or construct
# InteractionsBank.interactions_list_0
# or game or thing from scene, hide it somewhere, maybe even in head or pocket

const interactions_list_2 = {
	0: [
		["interaction_13|settings_container|thing_19"], 
		["scene_0"],
		["thing_21"],
		["connect_keyboard"],
		["thing_21"] 
	],
	1: [
		["interaction_13|settings_container|thing_19"], 
		["scene_0"],
		["thing_22"],
		["connect_keyboard"],
		["thing_22"] 
	],
	2: [
		["interaction_13|settings_container|thing_19"], 
		["scene_0"],
		["thing_23"],
		["connect_keyboard"],
		["thing_23"] 
	],
	3: [
		["interaction_13|settings_container|thing_19"], 
		["scene_0"],
		["thing_24"],
		["connect_keyboard"],
		["thing_24"] 
	],
	4: [
		["interaction_13|settings_container|thing_19"], 
		["scene_0"],
		["thing_25"],
		["connect_keyboard"],
		["thing_25"] 
	],
	5: [
		["interaction_13|settings_container|thing_19"], 
		["scene_0"],
		["thing_26"],
		["connect_keyboard"],
		["thing_26"] 
	],
	6: [
		["interaction_13|settings_container|thing_19"], 
		["scene_0"],
		["thing_27"],
		["connect_keyboard"],
		["thing_27"] 
	],
	7: [
		["interaction_13|settings_container|thing_19"], 
		["scene_0"],
		["thing_28"],
		["connect_keyboard"],
		["thing_28"] 
	],
	8: [
		["interaction_13|settings_container|thing_19"], 
		["scene_0"],
		["thing_29"],
		["connect_keyboard"],
		["thing_29"] 
	],
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
# here we add keyboard
#

#
# add create load cache active store unload branch path node file code script
# InteractionsBank.interactions_list_0

const interactions_list_3 = {
	0: [
		["interaction_15|keyboard_container|thing_24"],
		["scene_0"],
		["thing_29"],
		["add_scene|add_scene"],
		["keyboard_left|keyboard_right"]
	],
	1: [
		["interaction_16|keyboard_container|thing_24"],
		["scene_0"],
		["thing_25"],
		["dunno_yet"],
		["node_path"]
	] # add comma ,
}



#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            


# letters repeat and symbols too
# numbers too
# split of keyboard with left and right hand, as i have two, like phone 

# combine path and add more frames to what we have so far
#  keyboard left hehe
#InteractionsBank.interactions_list_0

const interactions_list_4 = {
	0: [
		["interaction_17|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_36"],
		["write"],
		["q"]
	],
	1: [
		["interaction_18|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_37"],
		["write"],
		["w"]
	], # add comma ,
	2: [
		["interaction_19|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_38"],
		["write"],
		["e"]
	], # add comma ,
	3: [
		["interaction_20|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_39"],
		["write"],
		["r"]
	], # add comma ,
	4: [
		["interaction_21|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_40"],
		["write"],
		["t"]
	], # add comma ,
	5: [
		["interaction_22|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_41"],
		["write"],
		["a"]
	], # add comma ,
	6: [
		["interaction_23|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_42"],
		["write"],
		["s"]
	], # add comma ,
	7: [
		["interaction_24|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_43"],
		["write"],
		["d"]
	], # add comma ,
	8: [
		["interaction_25|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_44"],
		["write"],
		["f"]
	], # add comma ,
	9: [ # small letters
		["interaction_26|keyboard_left_container|thing_34"], # "shift_keyboard" , "number_letter"
		["scene_0"],
		["thing_45"],
		["shift_keyboard"],
		["1"] # scene 1
	], # add comma ,
	10: [# big letters
		["interaction_27|keyboard_left_container|thing_34"], # "shift_keyboard" , "number_letter"
		["scene_1"],
		["thing_45"],
		["shift_keyboard"],
		["0"] # scene 1
	], # add comma ,
	11: [ # numbers 1
		["interaction_28|keyboard_left_container|thing_34"], # "shift_keyboard" , "number_letter"
		["scene_2"],
		["thing_45"],
		["shift_keyboard"],
		["3"] # scene 1
	], # add comma ,
	12: [ # numbers 2
		["interaction_29|keyboard_left_container|thing_34"], # "shift_keyboard" , "number_letter"
		["scene_3"],
		["thing_45"],
		["shift_keyboard"],
		["2"] # scene 1
	], # add comma ,
	13: [
		["interaction_30|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_46"],
		["write"],
		["z"]
	], # add comma ,
	14: [
		["interaction_31|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_47"],
		["write"],
		["x"]
	], # add comma ,
	15: [
		["interaction_32|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_48"],
		["write"],
		["c"]
	], # add comma ,
	16: [
		["interaction_33|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_49"],
		["write"],
		["v"]
	], # add comma ,
	17: [# num button, small letters, goes to scene 2, which is numbers 1
		["interaction_34|keyboard_left_container|thing_34"], #"number_letter"
		["scene_0"],
		["thing_50"],
		["number_letter"],
		["2"]
	], # add comma ,
	18: [ # numb but big letters, goes to numbers 2
		["interaction_35|keyboard_left_container|thing_34"], #"number_letter"
		["scene_1"],
		["thing_50"],
		["number_letter"],
		["3"]
	], # add comma ,
	19: [ # numb but, numbers 1, goes to 0 , small letters
		["interaction_36|keyboard_left_container|thing_34"], #"number_letter"
		["scene_2"],
		["thing_50"],
		["number_letter"],
		["0"]
	], # add comma ,
	20: [ # numb but, numbers 2, goes to 2? numbers 1 again?!
		["interaction_37|keyboard_left_container|thing_34"], #"number_letter"
		["scene_3"],
		["thing_50"],
		["number_letter"],
		["1"]
	], # add comma ,
	21: [
		["interaction_38|keyboard_left_container|thing_34"],
		["scene_0"],
		["thing_51"],
		["write"],
		[" "]
	], # add comma ,
	22: [
		["interaction_39|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_36"],
		["write"],
		["Q"]
	],
	23: [
		["interaction_40|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_37"],
		["write"],
		["W"]
	], # add comma ,
	24: [
		["interaction_41|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_38"],
		["write"],
		["E"]
	], # add comma ,
	25: [
		["interaction_42|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_39"],
		["write"],
		["R"]
	], # add comma ,
	26: [
		["interaction_43|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_40"],
		["write"],
		["T"]
	], # add comma ,
	27: [
		["interaction_44|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_41"],
		["write"],
		["A"]
	], # add comma ,
	28: [
		["interaction_45|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_42"],
		["write"],
		["S"]
	], # add comma ,
	29: [
		["interaction_46|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_43"],
		["write"],
		["D"]
	], # add comma ,
	30: [
		["interaction_47|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_44"],
		["write"],
		["F"]
	], # add comma ,
	31: [
		["interaction_48|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_46"],
		["write"],
		["Z"]
	], # add comma ,
	32: [
		["interaction_49|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_47"],
		["write"],
		["X"]
	], # add comma ,
	33: [
		["interaction_50|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_48"],
		["write"],
		["C"]
	], # add comma ,
	34: [
		["interaction_51|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_49"],
		["write"],
		["V"]
	], # add comma ,
	35: [
		["interaction_52|keyboard_left_container|thing_34"],
		["scene_1"],
		["thing_51"],
		["write"],
		[" "]
	], # add comma ,
	36: [
		["interaction_53|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_36"],
		["write"],
		["1"]
	],
	37: [
		["interaction_54|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_37"],
		["write"],
		["2"]
	], # add comma ,
	38: [
		["interaction_55|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_38"],
		["write"],
		["3"]
	], # add comma ,
	39: [
		["interaction_56|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_39"],
		["write"],
		["4"]
	], # add comma ,
	40: [
		["interaction_57|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_40"],
		["write"],
		["5"]
	], # add comma ,
	41: [
		["interaction_58|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_41"],
		["write"],
		["-"]
	], # add comma ,
	42: [
		["interaction_59|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_42"],
		["write"],
		["/"]
	], # add comma ,
	43: [
		["interaction_60|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_43"],
		["write"],
		[":"]
	], # add comma ,
	44: [
		["interaction_61|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_44"],
		["write"],
		["("]
	], # add comma ,
	45: [
		["interaction_62|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_46"],
		["write"],
		["."]
	], # add comma ,
	46: [
		["interaction_63|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_47"],
		["write"],
		["、"]
	], # add comma ,
	47: [
		["interaction_64|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_48"],
		["write"],
		["?"]
	], # add comma ,
	48: [
		["interaction_65|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_49"],
		["write"],
		["!"]
	], # add comma ,
	49: [
		["interaction_66|keyboard_left_container|thing_34"],
		["scene_2"],
		["thing_51"],
		["write"],
		[" "]
	], # add comma ,
	50: [
		["interaction_67|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_36"],
		["write"],
		["["]
	],
	51: [
		["interaction_68|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_37"],
		["write"],
		["]"]
	], # add comma ,
	52: [
		["interaction_69|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_38"],
		["write"],
		["{"]
	], # add comma ,
	53: [
		["interaction_70|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_39"],
		["write"],
		["}"]
	], # add comma ,
	54: [
		["interaction_71|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_40"],
		["write"],
		["#"]
	], # add comma ,
	55: [
		["interaction_72|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_41"],
		["write"],
		["_"]
	], # add comma ,
	56: [
		["interaction_73|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_42"],
		["write"],
		["ø"]
	], # add comma ,
	57: [
		["interaction_74|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_43"],
		["write"],
		["┃"]
	], # add comma ,
	58: [
		["interaction_75|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_44"],
		["write"],
		["<"]
	], # add comma ,
	59: [
		["interaction_76|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_46"],
		["write"],
		["."]
	], # add comma ,
	60: [
		["interaction_77|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_47"],
		["write"],
		["、"]
	], # add comma ,
	61: [
		["interaction_78|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_48"],
		["write"],
		["?"]
	], # add comma ,
	62: [
		["interaction_79|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_49"],
		["write"],
		["!"]
	], # add comma ,
	63: [
		["interaction_80|keyboard_left_container|thing_34"],
		["scene_3"],
		["thing_51"],
		["write"],
		[" "]
	] # add comma ,
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
#  keyboard left hehe
# right keyboard now
# we must clean data
#InteractionsBank.interactions_list_0
const interactions_list_5 = {
	0: [
		["interaction_81|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_55"],
		["write"],
		["p"]
	],
	1: [
		["interaction_82|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_56"],
		["write"],
		["o"]
	], # add comma ,
	2: [
		["interaction_83|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_57"],
		["write"],
		["i"]
	], # add comma ,
	3: [
		["interaction_84|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_58"],
		["write"],
		["u"]
	], # add comma ,
	4: [
		["interaction_85|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_59"],
		["write"],
		["y"]
	], # add comma ,
	5: [
		["interaction_86|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_60"],
		["write"],
		["l"]
	], # add comma ,
	6: [
		["interaction_87|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_61"],
		["write"],
		["k"]
	], # add comma ,
	7: [
		["interaction_88|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_62"],
		["write"],
		["j"]
	], # add comma ,
	8: [
		["interaction_89|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_63"],
		["write"],
		["h"]
	], # add comma ,
	9: [
		["interaction_90|keyboard_right_container|thing_53"], # "shift_keyboard" , "number_letter" return_string undo_char
		["scene_0"],
		["thing_64"],
		["undo_char"],
		["undo"] # scene 1
	], # add comma ,
	10: [
		["interaction_91|keyboard_right_container|thing_53"], # "shift_keyboard" , "number_letter"
		["scene_1"],
		["thing_64"],
		["undo_char"],
		["undo"] # scene 1
	], # add comma ,
	11: [
		["interaction_92|keyboard_right_container|thing_53"], # "shift_keyboard" , "number_letter"
		["scene_2"],
		["thing_64"],
		["undo_char"],
		["undo"] # scene 1
	], # add comma ,
	12: [
		["interaction_93|keyboard_right_container|thing_53"], # "shift_keyboard" , "number_letter"
		["scene_3"],
		["thing_64"],
		["undo_char"],
		["undo"] # scene 1
	], # add comma ,
	13: [
		["interaction_94|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_65"],
		["write"],
		["m"]
	], # add comma ,
	14: [
		["interaction_95|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_66"],
		["write"],
		["n"]
	], # add comma ,
	15: [
		["interaction_96|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_67"],
		["write"],
		["b"]
	], # add comma ,
	16: [
		["interaction_97|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_68"],
		["write"],
		["g"]
	], # add comma ,
	17: [
		["interaction_98|keyboard_right_container|thing_53"], # return
		["scene_0"],
		["thing_69"],
		["return_string"],
		["return"]
	], # add comma ,
	18: [
		["interaction_99|keyboard_right_container|thing_53"], #"number_letter"
		["scene_1"],
		["thing_69"],
		["return_string"],
		["return"]
	], # add comma ,
	19: [
		["interaction_100|keyboard_right_container|thing_53"], #"number_letter"
		["scene_2"],
		["thing_69"],
		["return_string"],
		["return"]
	], # add comma ,
	20: [
		["interaction_101|keyboard_right_container|thing_53"], #"number_letter"
		["scene_3"],
		["thing_69"],
		["return_string"],
		["return"]
	], # add comma ,
	21: [
		["interaction_102|keyboard_right_container|thing_53"],
		["scene_0"],
		["thing_70"],
		["write"],
		[" "]
	], # add comma ,
	22: [
		["interaction_103|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_55"],
		["write"],
		["P"]
	],
	23: [
		["interaction_104|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_56"],
		["write"],
		["O"]
	], # add comma ,
	24: [
		["interaction_105|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_57"],
		["write"],
		["I"]
	], # add comma ,
	25: [
		["interaction_106|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_58"],
		["write"],
		["U"]
	], # add comma ,
	26: [
		["interaction_107|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_59"],
		["write"],
		["Y"]
	], # add comma ,
	27: [
		["interaction_108|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_60"],
		["write"],
		["L"]
	], # add comma ,
	28: [
		["interaction_109|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_61"],
		["write"],
		["K"]
	], # add comma ,
	29: [
		["interaction_110|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_62"],
		["write"],
		["J"]
	], # add comma ,
	30: [
		["interaction_111|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_63"],
		["write"],
		["H"]
	], # add comma ,
	31: [
		["interaction_112|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_65"],
		["write"],
		["M"]
	], # add comma ,
	32: [
		["interaction_113|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_66"],
		["write"],
		["N"]
	], # add comma ,
	33: [
		["interaction_114|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_67"],
		["write"],
		["B"]
	], # add comma ,
	34: [
		["interaction_115|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_68"],
		["write"],
		["G"]
	], # add comma ,
	35: [
		["interaction_116|keyboard_right_container|thing_53"],
		["scene_1"],
		["thing_70"],
		["write"],
		[" "]
	], # add comma ,
	36: [
		["interaction_117|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_55"],
		["write"],
		["0"]
	],
	37: [
		["interaction_118|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_56"],
		["write"],
		["9"]
	], # add comma ,
	38: [
		["interaction_119|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_57"],
		["write"],
		["8"]
	], # add comma ,
	39: [
		["interaction_120|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_58"],
		["write"],
		["7"]
	], # add comma ,
	40: [
		["interaction_121|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_59"],
		["write"],
		["6"]
	], # add comma ,
	41: [
		["interaction_122|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_60"],
		["write"],
		["¤"]
	], # add comma ,
	42: [
		["interaction_123|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_61"],
		["write"],
		["@"]
	], # add comma ,
	43: [
		["interaction_124|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_62"],
		["write"],
		["&"]
	], # add comma ,
	44: [
		["interaction_125|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_63"],
		["write"],
		[";"]
	], # add comma ,
	45: [
		["interaction_126|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_65"],
		["write"],
		["'"]
	], # add comma ,
	46: [
		["interaction_127|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_66"],
		["write"],
		["¥"]
	], # add comma ,
	47: [
		["interaction_128|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_67"],
		["write"],
		["§"]
	], # add comma ,
	48: [
		["interaction_129|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_68"],
		["write"],
		[")"]
	], # add comma ,
	49: [
		["interaction_130|keyboard_right_container|thing_53"],
		["scene_2"],
		["thing_70"],
		["write"],
		[" "]
	], # add comma ,
	50: [
		["interaction_131|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_55"],
		["write"],
		["="]
	],
	51: [
		["interaction_132|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_56"],
		["write"],
		["+"]
	], # add comma ,
	52: [
		["interaction_133|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_57"],
		["write"],
		["*"]
	], # add comma ,
	53: [
		["interaction_134|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_58"],
		["write"],
		["^"]
	], # add comma ,
	54: [
		["interaction_135|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_59"],
		["write"],
		["%"]
	], # add comma ,
	55: [
		["interaction_136|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_60"],
		["write"],
		["$"]
	], # add comma ,
	56: [
		["interaction_137|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_61"],
		["write"],
		["∩"]
	], # add comma ,
	57: [
		["interaction_138|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_62"],
		["write"],
		["†"]
	], # add comma ,
	58: [
		["interaction_139|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_63"],
		["write"],
		["·"]
	], # add comma ,
	59: [
		["interaction_140|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_65"],
		["write"],
		["¨"]
	], # add comma ,
	60: [
		["interaction_141|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_66"],
		["write"],
		["¯"]
	], # add comma ,
	61: [
		["interaction_142|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_67"],
		["write"],
		["»"]
	], # add comma ,
	62: [
		["interaction_143|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_68"],
		["write"],
		[">"]
	], # add comma ,
	63: [
		["interaction_145|keyboard_right_container|thing_53"],
		["scene_3"],
		["thing_70"],
		["write"],
		[" "]
	] # add comma ,
}






#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

# scene frame change shape
# to move thing around too
# where things are created

# keyboard menu buttons words strings change see
# test help change slider button switch
# value 1 2 3, -1, 0, 1, value int float change slider

# InteractionsBank.interactions_list_0
# rotation lenght and scale and change
# distance and postion and key frames

const interactions_list_6 = {
	0: [
		["interaction_146|things_creation_container|thing_72"], # ["interaction_12|akashic_records|thing_7|scene_7|scenes_frames_7|add_scene"],
		["scene_0"],
		["thing_73"],
		["add_scene"],
		["keyboard"] # ["akashic_records|thing_12|settings"] # 17 exit/back
	],
	1: [
		["interaction_147|things_creation_container|thing_72"],
		["scene_0"],
		["thing_74"],
		["dunno_yet"],
		["node_path"]
	] # add comma ,
}
# interaction 148 in menus stuff eh











#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# singular lines of dual data path
# not always cleaned
# maybe we can change it later, write, undo, press, hold, repeat, time, task combo write, console, terminal

# InteractionsBank.interactions_list_0
const interactions_list_7 = {
	0: [
		["interaction_0|singular_lines_container|thing_1"], # ["interaction_12|akashic_records|thing_7|scene_7|scenes_frames_7|add_scene"],
		["scene_0|scene_1|scene_2|scene_3|scene_4|scene_5|scene_6|scene_7|scene_8|scene_9"],
		["thing_2"],
		["key_interaction"],
		["send_data_over"] # ["akashic_records|thing_12|settings"] # 17 exit/back
	],
	1: [
		["interaction_1|singular_lines_container|thing_1"],
		["scene_0|scene_1|scene_2|scene_3|scene_4|scene_5|scene_6|scene_7|scene_8|scene_9"],
		["thing_3"],
		["value_interaction"], # "key_interaction" , "value_interaction"
		["send_data_over"]
	] # add comma ,
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

# we wanna add snake to inputs and keystrokes
# adding scenes, paths, repeats, changing positions and shapes and colors
# we could add time already here too

#######################

## from Claude
# Add this to your ActionsBank class to integrate the Snake game
# You can copy this section into your interactions_bank.gd file

# Snake game interactions
const interactions_list_snake = {
	0: [ # Up button interaction
		["interaction_200|snake_game_container|thing_101"],
		["scene_20|scene_21|scene_22"],
		["thing_104"],
		["call_function"],
		["snake_turn_up"]
	],
	1: [ # Down button interaction
		["interaction_201|snake_game_container|thing_101"],
		["scene_20|scene_21|scene_22"],
		["thing_105"],
		["call_function"],
		["snake_turn_down"]
	],
	2: [ # Left button interaction
		["interaction_202|snake_game_container|thing_101"],
		["scene_20|scene_21|scene_22"],
		["thing_106"],
		["call_function"],
		["snake_turn_left"]
	],
	3: [ # Right button interaction
		["interaction_203|snake_game_container|thing_101"],
		["scene_20|scene_21|scene_22"],
		["thing_107"],
		["call_function"],
		["snake_turn_right"]
	],
	4: [ # Add segment button interaction
		["interaction_204|snake_game_container|thing_101"],
		["scene_20|scene_21|scene_22"],
		["thing_108"],
		["call_function"],
		["snake_add_segment"]
	],
	5: [ # Reset button interaction
		["interaction_205|snake_game_container|thing_101"],
		["scene_20|scene_21|scene_22"],
		["thing_109"],
		["call_function"],
		["snake_reset"]
	],
	6: [ # Speed 1 button interaction
		["interaction_206|snake_game_container|thing_101"],
		["scene_20|scene_21|scene_22"],
		["thing_110"],
		["call_function"],
		["snake_speed_1"]
	],
	7: [ # Speed 2 button interaction
		["interaction_207|snake_game_container|thing_101"],
		["scene_20|scene_21|scene_22"],
		["thing_111"],
		["call_function"],
		["snake_speed_2"]
	],
	8: [ # Speed 3 button interaction
		["interaction_208|snake_game_container|thing_101"],
		["scene_20|scene_21|scene_22"],
		["thing_112"],
		["call_function"],
		["snake_speed_3"]
	],
	9: [ # Back button interaction
		["interaction_209|snake_game_container|thing_101"],
		["scene_20|scene_21|scene_22"],
		["thing_114"],
		["change_scene|unload_container"],
		["scene_2|snake_game_container"]
	],
	10: [ # Add scene from main menu
		["interaction_210|akashic_records|thing_7"],
		["scene_3"], # From Things menu
		["thing_13"], # Using a button in the Things menu
		["add_scene"],
		["snake_game"]
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


# Terminal / Console interactions for ActionsBank
# Add to actions_bank.gd

const interactions_list_terminal = {
	0: [ # Open Terminal from Main Menu
		["interaction_400|akashic_records|thing_7"],
		["scene_2"], # From main menu
		["thing_14"], # Using the Interactions button
		["add_scene"],
		["terminal"]
	],
	1: [ # Close Terminal Button
		["interaction_401|terminal_container|thing_301"],
		["scene_0|scene_1|scene_2|scene_3"],
		["thing_311"],
		["change_scene|unload_container"],
		["scene_2|terminal_container"]
	],
	2: [ # Clear Terminal Button
		["interaction_402|terminal_container|thing_301"],
		["scene_0|scene_1|scene_2|scene_3"],
		["thing_313"],
		["call_function"],
		["clear_terminal"]
	],
	3: [ # Execute Command Button
		["interaction_403|terminal_container|thing_301"],
		["scene_0|scene_1|scene_2|scene_3"],
		["thing_315"],
		["call_function"],
		["execute_command"]
	],
	4: [ # Help Button
		["interaction_404|terminal_container|thing_301"],
		["scene_0|scene_1|scene_2|scene_3"],
		["thing_314"],
		["call_function"],
		["show_terminal_help"]
	],
	5: [ # History Button
		["interaction_405|terminal_container|thing_301"],
		["scene_0|scene_1|scene_2|scene_3"],
		["thing_312"],
		["call_function"],
		["show_command_history"]
	],
	6: [ # Connect Keyboard by clicking input line
		["interaction_406|terminal_container|thing_301"],
		["scene_0|scene_1|scene_2|scene_3"],
		["thing_316"], 
		["connect_keyboard"],
		["thing_309"] # Connect to input text
	],
	7: [ # Return Key from keyboard
		["interaction_407|terminal_container|thing_301"],
		["scene_0|scene_1|scene_2|scene_3"],
		["thing_69"], # Return key from keyboard
		["call_function"],
		["execute_command"]
	],
	8: [ # Tab 1 Button (for tabs)
		["interaction_408|terminal_container|thing_301"],
		["scene_0|scene_1|scene_2|scene_3"],
		["thing_321"],
		["call_function"],
		["switch_terminal_tab|1"]
	]
}

#
# add comment as prayer of script code file node name
# path folder command
# letter symbol number

# lenght of meanings too

# debug windows are needed too
# grid thing
# 2d and 3d handshake



# Console/Terminal interactions for ActionsBank
# This can be added to your actions_bank.gd file

const interactions_list_terminal_ = {
	0: [ # Open Terminal from Main Menu
		["interaction_300|akashic_records|thing_7"],
		["scene_2"], # From main menu
		["thing_14"], # Using the Interactions button
		["add_scene"],
		["terminal"]
	],
	1: [ # Close Terminal Button
		["interaction_301|terminal_container|thing_201"],
		["scene_0"],
		["thing_209"],
		["change_scene|unload_container"],
		["scene_2|terminal_container"]
	],
	2: [ # Clear Terminal Button
		["interaction_302|terminal_container|thing_201"],
		["scene_0"],
		["thing_207"],
		["call_function"],
		["clear_terminal"]
	],
	3: [ # Execute Command Button
		["interaction_303|terminal_container|thing_201"],
		["scene_0"],
		["thing_208"],
		["call_function"],
		["execute_command"]
	],
	4: [ # Help Button
		["interaction_304|terminal_container|thing_201"],
		["scene_0"],
		["thing_210"],
		["call_function"],
		["show_terminal_help"]
	],
	5: [ # History Button
		["interaction_305|terminal_container|thing_201"],
		["scene_0"],
		["thing_206"],
		["call_function"],
		["show_command_history"]
	],
	6: [ # Connect Keyboard
		["interaction_306|terminal_container|thing_201"],
		["scene_0"],
		["thing_204"], # Clicking on input bracket
		["connect_keyboard"],
		["thing_205"] # Connect to input text
	],
	7: [ # Terminal Input Return Key
		["interaction_307|terminal_container|thing_201"],
		["scene_0"],
		["thing_69"], # Return key from keyboard
		["call_function"],
		["execute_command"]
	]
}














# Terminal / Console interactions for ActionsBank
# Add to actions_bank.gd

const interactions_list_terminal__ = {
	0: [ # Open Terminal from Main Menu
		["interaction_400|akashic_records|thing_7"],
		["scene_2"], # From main menu
		["thing_14"], # Using the Interactions button
		["add_scene"],
		["terminal"]
	],
	1: [ # Close Terminal Button
		["interaction_401|terminal_container|thing_301"],
		["scene_0"],
		["thing_311"],
		["change_scene|unload_container"],
		["scene_2|terminal_container"]
	],
	2: [ # Clear Terminal Button
		["interaction_402|terminal_container|thing_301"],
		["scene_0"],
		["thing_313"],
		["call_function"],
		["clear_terminal"]
	],
	3: [ # Execute Command Button
		["interaction_403|terminal_container|thing_301"],
		["scene_0"],
		["thing_315"],
		["call_function"],
		["execute_command"]
	],
	4: [ # Help Button
		["interaction_404|terminal_container|thing_301"],
		["scene_0"],
		["thing_314"],
		["call_function"],
		["show_terminal_help"]
	],
	5: [ # History Button
		["interaction_405|terminal_container|thing_301"],
		["scene_0"],
		["thing_312"],
		["call_function"],
		["show_command_history"]
	],
	6: [ # Connect Keyboard by clicking input line
		["interaction_406|terminal_container|thing_301"],
		["scene_0"],
		["thing_316"], 
		["connect_keyboard"],
		["thing_309"] # Connect to input text
	],
	7: [ # Return Key from keyboard
		["interaction_407|terminal_container|thing_301"],
		["scene_0"],
		["thing_69"], # Return key from keyboard
		["call_function"],
		["execute_command"]
	],
	8: [ # Pressing arrow up (history navigation)
		["interaction_408|terminal_container|thing_301"],
		["scene_0|scene_1|scene_2|scene_3"],
		["keyboard_up"],
		["call_function"],
		["history_up"]
	],
	9: [ # Pressing arrow down (history navigation)
		["interaction_409|terminal_container|thing_301"],
		["scene_0|scene_1|scene_2|scene_3"],
		["keyboard_down"],
		["call_function"],
		["history_down"]
	]
}


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

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