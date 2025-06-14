# 🏛️ Interactions Bank - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# interactions_bank.gd
extends UniversalBeingBase
class_name InteractionsBank

var interaction_add_number  : String = "interaction_"
var list_add_number : String = "list_"

# InteractionsBank.type_of_interactions_0
const type_of_interactions_0 = [
	"change_scene", "add_scene", "change_text", "call_function", "unload_container", "write" , "shift_keyboard" , "number_letter"  , "return_string" , "undo_char" , "load_file" ,"dunno_yet"
]

const call_function = [
	"initialize_container", "write", "move_around", "show_window", "rotate", "connect", "add_thing", "remove_thing"
]



# InteractionsBank.interactions_list_0
const singular_interactions = {
	0: [
		["interaction_0|singular_records_container|thing_1|scene_0|scenes_frames_0|dunno_yet"], # ["interaction_12|akashic_records|thing_7|scene_7|scenes_frames_7|add_scene"],
		["singular_records_container|thing_2|keyboard"] # ["akashic_records|thing_12|settings"] # 17 exit/back
	],
	1: [
		["interaction_0|singular_records_container|thing_1|scene_0|scenes_frames_0|dunno_yet"],
		["singular_records_container|thing_3|singular_lines"]
	] # add comma ,
}



# InteractionsBank.interactions_list_0
const interactions_list_0 = {
	0: [
		["interaction_0|akashic_records|thing_7|scene_0|scenes_frames_0|change_scene"],
		["akashic_records|thing_0|scene_1|1"]
	],
	1: [
		["interaction_1|akashic_records|thing_7|scene_1|scenes_frames_0|change_scene"],
		["akashic_records|thing_0|scene_0|0"]
	] # add comma ,
}

# InteractionsBank.interactions_list_0
const interactions_list_1 = {
	0: [   # MAIN MENU -> THINGS - 1 things menu - scene_3
		["interaction_2|akashic_records|thing_7|scene_2|scenes_frames_2|change_scene"], # on which datapoint and scene we are on
		["akashic_records|thing_12|scene_3|3"] # 12 things                 # to what scene we travel :)
	],     # Things stuff
	1: [   # THINGS -> MAIN MENU - 0 main menu - scene_2
		["interaction_3|akashic_records|thing_7|scene_3|scenes_frames_3|change_scene|unload_container"],
		["akashic_records|thing_17|scene_2|2|things_creation_container"] # 17 exit/back
	], 
	2: [   # MAIN MENU -> SCENES - 2 scenes menu - scene_4
		["interaction_4|akashic_records|thing_7|scene_2|scenes_frames_2|change_scene"],
		["akashic_records|thing_13|scene_4|4"] # 13 scenes
	],     # Scenes Stuff
	3: [   # SCENES -> MAIN MENU - 0 main menu - scene_2
		["interaction_5|akashic_records|thing_7|scene_4|scenes_frames_4|change_scene"],
		["akashic_records|thing_17|scene_2|2"] # 17 exit/back
	], 
	4: [   # MAIN MENU -> INTERACTIONS - 3 interactions menu - scene_5
		["interaction_6|akashic_records|thing_7|scene_2|scenes_frames_2|change_scene"],
		["akashic_records|thing_14|scene_5|5"] # 14 interactions
	],     # interactions stuff
	5: [   # INTERACTIONS -> MAIN MENU - 0 main menu - scene_2
		["interaction_7|akashic_records|thing_7|scene_5|scenes_frames_5|change_scene"],
		["akashic_records|thing_17|scene_2|2"] # 17 exit/back
	], # add comma ,
	6: [   # MAIN MENU -> INSTRUCTIONS - 4 instructions menu - scene_6
		["interaction_8|akashic_records|thing_7|scene_2|scenes_frames_2|change_scene"],
		["akashic_records|thing_15|scene_6|6"] # 15 instructions
	],     # instructions stuff
	7: [   # INSTRUCTIONS -> MAIN MENU - 0 main menu - scene_2
		["interaction_9|akashic_records|thing_7|scene_6|scenes_frames_6|change_scene"],
		["akashic_records|thing_17|scene_2|2"] # 17 exit/back
	], # add comma ,
	8: [   # MAIN MENU -> SETTINGS - 5 settings menu - scene_7
		["interaction_10|akashic_records|thing_7|scene_2|scenes_frames_2|change_scene"],
		["akashic_records|thing_16|scene_7|7"] # 16 settings
	],     
	
	# settings stuff
	9: [   # SETTINGS -> MAIN MENU - 0 main menu - scene_2
		["interaction_11|akashic_records|thing_7|scene_7|scenes_frames_7|change_scene|unload_container|unload_container|unload_container|unload_container|unload_container"],
		["akashic_records|thing_17|scene_2|2|settings_container|keyboard_container|keyboard_left_container|keyboard_right_container|singular_lines_container"] # 17 exit/back
	],
	10: [   # SETTINGS -> adding new "scene" with clickable stuff to change settings :) 
		["interaction_12|akashic_records|thing_7|scene_7|scenes_frames_7|add_scene"], # |load_file
		["akashic_records|thing_12|settings"] # 17 exit/back # |settings.txtøsingular_lines
	],
	# things creation stuff
	11: [   # Things -> adding new "scene" with creation tools and devices and periphelia and manifestations 
		["interaction_148|akashic_records|thing_7|scene_3|scenes_frames_3|add_scene"],
		["akashic_records|thing_12|things_creation"] # 17 exit/back
	],#,
	12: [   # Things -> adding new "scene" with creation tools and devices and periphelia and manifestations 
		["interaction_149|akashic_records|thing_7|scene_3|scenes_frames_3|change_scene|unload_container"],
		["akashic_records|thing_17|scene_2|2|things_creation"] # 17 exit/back
	]
}

# InteractionsBank.interactions_list_0
const interactions_list_2 = {
	0: [
		["interaction_13|settings_container|thing_19|scene_0|scenes_frames_0|add_scene"], # ["interaction_12|akashic_records|thing_7|scene_7|scenes_frames_7|add_scene"],
		["settings_container|thing_21|keyboard"] # ["akashic_records|thing_12|settings"] # 17 exit/back
	],
	1: [
		["interaction_14|settings_container|thing_19|scene_0|scenes_frames_0|add_scene"],
		["settings_container|thing_22|singular_lines"]
	] # add comma ,
}

# InteractionsBank.interactions_list_0
const interactions_list_3 = {
	0: [
		["interaction_15|keyboard_container|thing_24|scene_0|scenes_frames_0|add_scene|add_scene"],
		["keyboard_container|thing_29|keyboard_left|keyboard_right"]
	],
	1: [
		["interaction_16|keyboard_container|thing_24|scene_0|scenes_frames_0|dunno_yet"],
		["keyboard_container|thing_25|node_path"]
	] # add comma ,
}



#  keyboard left hehe
#InteractionsBank.interactions_list_0
const interactions_list_4 = {
	0: [
		["interaction_17|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_36|q"]
	],
	1: [
		["interaction_18|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_37|w"]
	], # add comma ,
	2: [
		["interaction_19|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_38|e"]
	], # add comma ,
	3: [
		["interaction_20|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_39|r"]
	], # add comma ,
	4: [
		["interaction_21|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_40|t"]
	], # add comma ,
	5: [
		["interaction_22|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_41|a"]
	], # add comma ,
	6: [
		["interaction_23|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_42|s"]
	], # add comma ,
	7: [
		["interaction_24|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_43|d"]
	], # add comma ,
	8: [
		["interaction_25|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_44|f"]
	], # add comma ,
	9: [ # small letters
		["interaction_26|keyboard_left_container|thing_34|scene_0|scenes_frames_0|shift_keyboard"], # "shift_keyboard" , "number_letter"
		["keyboard_left_container|thing_45|1"] # scene 1
	], # add comma ,
	10: [# big letters
		["interaction_27|keyboard_left_container|thing_34|scene_1|scenes_frames_0|shift_keyboard"], # "shift_keyboard" , "number_letter"
		["keyboard_left_container|thing_45|0"] # scene 1
	], # add comma ,
	11: [ # numbers 1
		["interaction_28|keyboard_left_container|thing_34|scene_2|scenes_frames_0|shift_keyboard"], # "shift_keyboard" , "number_letter"
		["keyboard_left_container|thing_45|3"] # scene 1
	], # add comma ,
	12: [ # numbers 2
		["interaction_29|keyboard_left_container|thing_34|scene_3|scenes_frames_0|shift_keyboard"], # "shift_keyboard" , "number_letter"
		["keyboard_left_container|thing_45|2"] # scene 1
	], # add comma ,
	13: [
		["interaction_30|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_46|z"]
	], # add comma ,
	14: [
		["interaction_31|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_47|x"]
	], # add comma ,
	15: [
		["interaction_32|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_48|c"]
	], # add comma ,
	16: [
		["interaction_33|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_49|v"]
	], # add comma ,
	17: [# num button, small letters, goes to scene 2, which is numbers 1
		["interaction_34|keyboard_left_container|thing_34|scene_0|scenes_frames_0|number_letter"], #"number_letter"
		["keyboard_left_container|thing_50|2"]
	], # add comma ,
	18: [ # numb but big letters, goes to numbers 2
		["interaction_35|keyboard_left_container|thing_34|scene_1|scenes_frames_0|number_letter"], #"number_letter"
		["keyboard_left_container|thing_50|3"]
	], # add comma ,
	19: [ # numb but, numbers 1, goes to 0 , small letters
		["interaction_36|keyboard_left_container|thing_34|scene_2|scenes_frames_0|number_letter"], #"number_letter"
		["keyboard_left_container|thing_50|0"]
	], # add comma ,
	20: [ # numb but, numbers 2, goes to 2? numbers 1 again?!
		["interaction_37|keyboard_left_container|thing_34|scene_3|scenes_frames_0|number_letter"], #"number_letter"
		["keyboard_left_container|thing_50|1"]
	], # add comma ,
	21: [
		["interaction_38|keyboard_left_container|thing_34|scene_0|scenes_frames_0|write"],
		["keyboard_left_container|thing_51| "]
	], # add comma ,
	22: [
		["interaction_39|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_36|Q"]
	],
	23: [
		["interaction_40|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_37|W"]
	], # add comma ,
	24: [
		["interaction_41|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_38|E"]
	], # add comma ,
	25: [
		["interaction_42|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_39|R"]
	], # add comma ,
	26: [
		["interaction_43|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_40|T"]
	], # add comma ,
	27: [
		["interaction_44|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_41|A"]
	], # add comma ,
	28: [
		["interaction_45|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_42|S"]
	], # add comma ,
	29: [
		["interaction_46|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_43|D"]
	], # add comma ,
	30: [
		["interaction_47|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_44|F"]
	], # add comma ,
	31: [
		["interaction_48|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_46|Z"]
	], # add comma ,
	32: [
		["interaction_49|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_47|X"]
	], # add comma ,
	33: [
		["interaction_50|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_48|C"]
	], # add comma ,
	34: [
		["interaction_51|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_49|V"]
	], # add comma ,
	35: [
		["interaction_52|keyboard_left_container|thing_34|scene_1|scenes_frames_0|write"],
		["keyboard_left_container|thing_51| "]
	], # add comma ,
	36: [
		["interaction_53|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_36|1"]
	],
	37: [
		["interaction_54|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_37|2"]
	], # add comma ,
	38: [
		["interaction_55|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_38|3"]
	], # add comma ,
	39: [
		["interaction_56|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_39|4"]
	], # add comma ,
	40: [
		["interaction_57|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_40|5"]
	], # add comma ,
	41: [
		["interaction_58|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_41|-"]
	], # add comma ,
	42: [
		["interaction_59|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_42|/"]
	], # add comma ,
	43: [
		["interaction_60|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_43|:"]
	], # add comma ,
	44: [
		["interaction_61|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_44|("]
	], # add comma ,
	45: [
		["interaction_62|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_46|."]
	], # add comma ,
	46: [
		["interaction_63|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_47|、"]
	], # add comma ,
	47: [
		["interaction_64|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_48|?"]
	], # add comma ,
	48: [
		["interaction_65|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_49|!"]
	], # add comma ,
	49: [
		["interaction_66|keyboard_left_container|thing_34|scene_2|scenes_frames_0|write"],
		["keyboard_left_container|thing_51| "]
	], # add comma ,
	50: [
		["interaction_67|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_36|["]
	],
	51: [
		["interaction_68|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_37|]"]
	], # add comma ,
	52: [
		["interaction_69|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_38|{"]
	], # add comma ,
	53: [
		["interaction_70|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_39|}"]
	], # add comma ,
	54: [
		["interaction_71|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_40|#"]
	], # add comma ,
	55: [
		["interaction_72|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_41|_"]
	], # add comma ,
	56: [
		["interaction_73|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_42|ø"]
	], # add comma ,
	57: [
		["interaction_74|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_43|┃"]
	], # add comma ,
	58: [
		["interaction_75|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_44|<"]
	], # add comma ,
	59: [
		["interaction_76|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_46|."]
	], # add comma ,
	60: [
		["interaction_77|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_47|、"]
	], # add comma ,
	61: [
		["interaction_78|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_48|?"]
	], # add comma ,
	62: [
		["interaction_79|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_49|!"]
	], # add comma ,
	63: [
		["interaction_80|keyboard_left_container|thing_34|scene_3|scenes_frames_0|write"],
		["keyboard_left_container|thing_51| "]
	] # add comma ,
}



#  keyboard left hehe
#InteractionsBank.interactions_list_0
const interactions_list_5 = {
	0: [
		["interaction_81|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_55|p"]
	],
	1: [
		["interaction_82|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_56|o"]
	], # add comma ,
	2: [
		["interaction_83|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_57|i"]
	], # add comma ,
	3: [
		["interaction_84|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_58|u"]
	], # add comma ,
	4: [
		["interaction_85|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_59|y"]
	], # add comma ,
	5: [
		["interaction_86|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_60|l"]
	], # add comma ,
	6: [
		["interaction_87|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_61|k"]
	], # add comma ,
	7: [
		["interaction_88|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_62|j"]
	], # add comma ,
	8: [
		["interaction_89|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_63|h"]
	], # add comma ,
	9: [
		["interaction_90|keyboard_right_container|thing_53|scene_0|scenes_frames_0|undo_char"], # "shift_keyboard" , "number_letter" return_string undo_char
		["keyboard_right_container|thing_64|undo"] # scene 1
	], # add comma ,
	10: [
		["interaction_91|keyboard_right_container|thing_53|scene_1|scenes_frames_0|undo_char"], # "shift_keyboard" , "number_letter"
		["keyboard_right_container|thing_64|undo"] # scene 1
	], # add comma ,
	11: [
		["interaction_92|keyboard_right_container|thing_53|scene_2|scenes_frames_0|undo_char"], # "shift_keyboard" , "number_letter"
		["keyboard_right_container|thing_64|undo"] # scene 1
	], # add comma ,
	12: [
		["interaction_93|keyboard_right_container|thing_53|scene_3|scenes_frames_0|undo_char"], # "shift_keyboard" , "number_letter"
		["keyboard_right_container|thing_64|undo"] # scene 1
	], # add comma ,
	13: [
		["interaction_94|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_65|m"]
	], # add comma ,
	14: [
		["interaction_95|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_66|n"]
	], # add comma ,
	15: [
		["interaction_96|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_67|b"]
	], # add comma ,
	16: [
		["interaction_97|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_68|g"]
	], # add comma ,
	17: [
		["interaction_98|keyboard_right_container|thing_53|scene_0|scenes_frames_0|return_string"], # return
		["keyboard_right_container|thing_69|return"]
	], # add comma ,
	18: [
		["interaction_99|keyboard_right_container|thing_53|scene_1|scenes_frames_0|return_string"], #"number_letter"
		["keyboard_right_container|thing_69|return"]
	], # add comma ,
	19: [
		["interaction_100|keyboard_right_container|thing_53|scene_2|scenes_frames_0|return_string"], #"number_letter"
		["keyboard_right_container|thing_69|return"]
	], # add comma ,
	20: [
		["interaction_101|keyboard_right_container|thing_53|scene_3|scenes_frames_0|return_string"], #"number_letter"
		["keyboard_right_container|thing_69|return"]
	], # add comma ,
	21: [
		["interaction_102|keyboard_right_container|thing_53|scene_0|scenes_frames_0|write"],
		["keyboard_right_container|thing_70| "]
	], # add comma ,
	22: [
		["interaction_103|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_55|P"]
	],
	23: [
		["interaction_104|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_56|O"]
	], # add comma ,
	24: [
		["interaction_105|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_57|I"]
	], # add comma ,
	25: [
		["interaction_106|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_58|U"]
	], # add comma ,
	26: [
		["interaction_107|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_59|Y"]
	], # add comma ,
	27: [
		["interaction_108|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_60|L"]
	], # add comma ,
	28: [
		["interaction_109|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_61|K"]
	], # add comma ,
	29: [
		["interaction_110|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_62|J"]
	], # add comma ,
	30: [
		["interaction_111|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_63|H"]
	], # add comma ,
	31: [
		["interaction_112|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_65|M"]
	], # add comma ,
	32: [
		["interaction_113|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_66|N"]
	], # add comma ,
	33: [
		["interaction_114|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_67|B"]
	], # add comma ,
	34: [
		["interaction_115|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_68|G"]
	], # add comma ,
	35: [
		["interaction_116|keyboard_right_container|thing_53|scene_1|scenes_frames_0|write"],
		["keyboard_right_container|thing_70| "]
	], # add comma ,
	36: [
		["interaction_117|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_55|0"]
	],
	37: [
		["interaction_118|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_56|9"]
	], # add comma ,
	38: [
		["interaction_119|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_57|8"]
	], # add comma ,
	39: [
		["interaction_120|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_58|7"]
	], # add comma ,
	40: [
		["interaction_121|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_59|6"]
	], # add comma ,
	41: [
		["interaction_122|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_60|¤"]
	], # add comma ,
	42: [
		["interaction_123|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_61|@"]
	], # add comma ,
	43: [
		["interaction_124|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_62|&"]
	], # add comma ,
	44: [
		["interaction_125|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_63|;"]
	], # add comma ,
	45: [
		["interaction_126|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_65|'"]
	], # add comma ,
	46: [
		["interaction_127|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_66|¥"]
	], # add comma ,
	47: [
		["interaction_128|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_67|§"]
	], # add comma ,
	48: [
		["interaction_129|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_68|)"]
	], # add comma ,
	49: [
		["interaction_130|keyboard_right_container|thing_53|scene_2|scenes_frames_0|write"],
		["keyboard_right_container|thing_70| "]
	], # add comma ,
	50: [
		["interaction_131|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_55|="]
	],
	51: [
		["interaction_132|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_56|+"]
	], # add comma ,
	52: [
		["interaction_133|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_57|*"]
	], # add comma ,
	53: [
		["interaction_134|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_58|^"]
	], # add comma ,
	54: [
		["interaction_135|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_59|%"]
	], # add comma ,
	55: [
		["interaction_136|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_60|$"]
	], # add comma ,
	56: [
		["interaction_137|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_61|∩"]
	], # add comma ,
	57: [
		["interaction_138|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_62|†"]
	], # add comma ,
	58: [
		["interaction_139|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_63|·"]
	], # add comma ,
	59: [
		["interaction_140|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_65|¨"]
	], # add comma ,
	60: [
		["interaction_141|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_66|¯"]
	], # add comma ,
	61: [
		["interaction_142|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_67|»"]
	], # add comma ,
	62: [
		["interaction_143|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_68|>"]
	], # add comma ,
	63: [
		["interaction_145|keyboard_right_container|thing_53|scene_3|scenes_frames_0|write"],
		["keyboard_right_container|thing_70| "]
	] # add comma ,
}


# InteractionsBank.interactions_list_0
const interactions_list_6 = {
	0: [
		["interaction_146|things_creation_container|thing_72|scene_0|scenes_frames_0|add_scene"], # ["interaction_12|akashic_records|thing_7|scene_7|scenes_frames_7|add_scene"],
		["things_creation_container|thing_73|keyboard"] # ["akashic_records|thing_12|settings"] # 17 exit/back
	],
	1: [
		["interaction_147|things_creation_container|thing_72|scene_0|scenes_frames_0|dunno_yet"],
		["things_creation_container|thing_74|node_path"]
	] # add comma ,
}
# interaction 148 in menus stuff eh


# InteractionsBank.interactions_list_0
const interactions_list_7 = {
	0: [
		["interaction_0|singular_lines_container|thing_1|scene_0|scenes_frames_0|dunno_yet"], # ["interaction_12|akashic_records|thing_7|scene_7|scenes_frames_7|add_scene"],
		["singular_lines_container|thing_2|keyboard"] # ["akashic_records|thing_12|settings"] # 17 exit/back
	],
	1: [
		["interaction_1|singular_lines_container|thing_1|scene_0|scenes_frames_0|dunno_yet"],
		["singular_lines_container|thing_3|singular_lines"]
	] # add comma ,
}






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