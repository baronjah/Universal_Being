# instructions_bank.gd #

# record instruction action scene $
# bank data point tunnel #

# bridge path crossroad#
# road ravine hide #
# split merge visibility #
# change move rotate #

# lod viewport #
# screen view port viewport window scale curve depth layer limits direction animation scene camera input velocity durations #

# repeat return break pass continue store change clear add create load store move recreate clean #
# move around group folder container slider trigger switch level button color value float #
# connect datapoint globalstate containers and check them in cycles and emoticon of icons emot_icon #




#    oooo  .oooooo..o ooooo   ooooo #
#    `888 d8P'    `Y8 `888'   `888' #
#     888 Y88bo.       888     888  #
#     888  `"Y8888o.   888ooooo888  #
#     888      `"Y88b  888     888  #
#     888 oo     .d8P  888     888  #
# .o. 88P 8""88888P'  o888o   o888o #
# `Y888P                            #

#
# instruction is like a first push and rocked fuel we need to start a thing


extends Node3D#
class_name InstructionsBank # InstructionsBank.instructions_set_0   InstructionsBank.type_of_instruction_0#


var instruction_add_number : String = "instruction_"#
var set_add_number : String = "set_"#



const type_of_instruction_0 = [#
	"assign_priority_to_datapoint", "assign_things_to_datapoint", "set_max_things_number", "connect_containter_datapoint", "add_things_to_container", "set_the_scene", "rotate_container", "setup_text_bracet", "set_interaction_check_mode", "move_container", "load_file"
]#





#    oooo  .oooooo..o ooooo   ooooo #
#    `888 d8P'    `Y8 `888'   `888' #
#     888 Y88bo.       888     888  #
#     888  `"Y8888o.   888ooooo888  #
#     888      `"Y88b  888     888  #
#     888 oo     .d8P  888     888  #
# .o. 88P 8""88888P'  o888o   o888o #
# `Y888P                            

#
# happens once, could be a repeated cycle for functions#

# header can be made later too, from list of rest of files scenes things groups too#
# scales sizes colors directions too#
#
# instructions set 0#
const instructions_set_0 = {#
	0: [ # send things to datapoint#
		["instruction_0|assign_priority_to_datapoint"],#
		["akashic_records|thing_7"],#
		["0"]#
	] ,# add coma ,#
	1: [ # send things to datapoint#
		["instruction_1|assign_things_to_datapoint"],#
		["akashic_records|thing_7"],#
		["akashic_records|thing_2|thing_3|thing_5|thing_4|thing_6|thing_1|thing_8|thing_9"]#
	] ,# add coma ,#
	2:[ # send max things to datapoint#
		["instruction_2|set_max_things_number"],#
		["akashic_records|thing_7"],#
		["100"]#
	], # add coma ,#
	3:[ # connect containter and datapoint#
		["instruction_3|connect_containter_datapoint"],#
		["akashic_records|thing_7|0"],#
		["akashic_records"]#
	],#
	#4:[
	#	["instruction_4|set_the_scene"],
	#	["akashic_records|thing_7|0"],
	#	["0"]
	#],
	5:[#
		["instruction_5|set_interaction_check_mode"],#
		["akashic_records|thing_7"],#
		["single|1"]#
	]#
}#




#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            

#
## stuff is connected yet there are paths that could be faster

# second isntructions set, after menu
# menu button header list too
# when we change and add, we multiply amd duplicate too
# connect paths later too, as one day we start and finish and restart pc too

const instructions_set_1 = {
	0: [ # send things to datapoint
		["instruction_6|assign_things_to_datapoint"],
		["akashic_records|thing_7"],
		["akashic_records|thing_11|thing_12|thing_13|thing_14|thing_15|thing_16|thing_17"]
	],
	1:[
		["instruction_7|set_the_scene"],
		["akashic_records|thing_7|0"],
		["2"]
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
# max amount of things, type of thing, type of visual appearance of thing

# the added scene instructions lol

const instructions_set_2 = {
	0: [ # send things to datapoint
		["instruction_5|assign_priority_to_datapoint"],
		["settings_container|thing_19"],
		["1"]
	] ,# add coma ,
	1: [ # send things to datapoint
		["instruction_6|assign_things_to_datapoint"],
		["settings_container|thing_19"],
		["settings_container|thing_19|thing_20|thing_21|thing_22|thing_23|thing_24"]
	] ,# add coma ,
	2:[ # send max things to datapoint
		["instruction_7|set_max_things_number"],
		["settings_container|thing_19"],
		["100"]
	], # add coma ,
	3:[ # connect containter and datapoint
		["instruction_8|connect_containter_datapoint"],
		["settings_container|thing_19|1"],
		["settings_container"]
	],
	4:[
		["instruction_31|set_the_scene"],
		["settings_container|thing_19|0"],
		["0"]
	],
	5:[
		["instruction_9|load_file"],#load_file
		["settings_container|thing_19|0"],
		["settings.txt"]
	],
	6:[
		["instruction_10|set_interaction_check_mode"],
		["settings_container|thing_19"],
		["single|1"]
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
# connections with paths and names of things too

# keyboard instructions

const instructions_set_3 = { #
	0: [ # send things to datapoint
		["instruction_9|assign_priority_to_datapoint"], #
		["keyboard_container|thing_24"], #
		["1"] #
	] ,# add coma , # 
	1: [ # send things to datapoint # 
		["instruction_10|assign_things_to_datapoint"], #
		["keyboard_container|thing_24"], # 	 # #    # ## ### #  #   #		# ## ### #
		["keyboard_container|thing_24|thing_25|thing_26|thing_27|thing_28|thing_29|thing_30"] #
	] ,# add coma ,#
	2:[ # send max things to datapoint #
		["instruction_11|set_max_things_number"], #
		["keyboard_container|thing_24"], #
		["100"] # 
	], # add coma ,
	3:[ # connect containter and datapoint #
		["instruction_12|connect_containter_datapoint"], #
		["keyboard_container|thing_24|2"], #
		["keyboard_container"] #
	],
	4:[ # rotate keyboard
		["instruction_13|rotate_container"], #
		["keyboard_container|thing_24|2"], #
		["keyboard_container|90.0"] #
	],
	5:[ # setup text bracet keyboard
		["instruction_14|setup_text_bracet"], #
		["keyboard_container|thing_24|2"], #
		["keyboard_container|call_function"] ##
	],#
	6:[##
		["instruction_32|set_the_scene"],##
		["keyboard_container|thing_24|0"],#@
		["0"]#!
	],#"move_container"#$
	7:[ #  move_container#%
		["instruction_15|move_container"], #^
		["keyboard_container|thing_24|2"], #
		["keyboard_container|0.0,-4.5,0.41"]#
	],#
	8:[#
		["instruction_16|set_interaction_check_mode"],#
		["keyboard_container|thing_24"],#
		["single|1"]#
	]#
}#





#    oooo  .oooooo..o ooooo   ooooo #!
#    `888 d8P'    `Y8 `888'   `888' #@
#     888 Y88bo.       888     888  ##
#     888  `"Y8888o.   888ooooo888  #$
#     888      `"Y88b  888     888  #%
#     888 oo     .d8P  888     888  #^
# .o. 88P 8""88888P'  o888o   o888o #*
# `Y888P                            #)

#+-0987654321 #
#=+_ #
#_=- #
#--= 3#
#0_+ #

# 1234567890-= #
# =-0987654321 #
#-=+_```~~~~~~`~~--== #
# repair keyboard so i have one tylda too

# ,./<>?:"|;'\}{P][p #
# enter return undo backspace back
# shift left right middle split center points

# paths combo segments code
# combine all scripts Luminus
# avra ca di vra
# vra cra like crow

# hokus pokus levity tempos #
# change code int codes into script and gdscripts s and cSharpCodes into C Basic func var s iants tions asic sic ] #
# c C d D / // # ##  [];'l.//":L|":}{{P?><<>??||\/\ #
# fight for console and atleast ## #
# /\ #
#
# we found tip of asci symetry now and we can see shapes in 3d #
# better than horror of realist of 3d that we see too, like shape of window and mirror ##
# screen of computer that fog that could be here, as we knew the word in scripts##
 ###
# we continue what we started and find better pipes these dumb 2d gamesthat connect god or bad can help us out too ##
# in my game we judge too and wrestle but we shoot laser first#
# as we must be sure it is worth our time #

# words shape code and script i shall add words and symbolism in code of shape symbol words
# begins_with split join/merge find/check/create store/load/where where/find/file /what/path/root 
# connect scripts C# #// C gdscript and shaders with disks and pages of books and book shelf in game

# as we have things and we can have files like pages that combine into book and icons to load my game

# human words repeat of function and database sizes
# what we wanna do plus infinite
# unfortunately


## different points of thing
# connections
# we need pauses and connections
# ghost can break a thing

# but it needs switch to repair #
# patter changes #

# keyboard left instructions

const instructions_set_4 = {
	0: [ # send things to datapoint
		["instruction_15|assign_priority_to_datapoint"],
		["keyboard_left_container|thing_34"],
		["1"]
	] ,# add coma ,
	1: [ # send things to datapoint
		["instruction_16|assign_things_to_datapoint"],
		["keyboard_left_container|thing_34"],
		["keyboard_left_container|thing_35|thing_36|thing_37|thing_38|thing_39|thing_40|thing_41|thing_42|thing_43|thing_44|thing_45|thing_46|thing_47|thing_48|thing_49|thing_50|thing_51"]
	] ,# add coma ,
	2:[ # send max things to datapoint
		["instruction_17|set_max_things_number"],
		["keyboard_left_container|thing_34"],
		["100"]
	], # add coma ,
	3:[ # connect containter and datapoint
		["instruction_18|connect_containter_datapoint"],
		["keyboard_left_container|thing_34|3"],
		["keyboard_left_container"]
	],
	4:[ # rotate keyboard
		["instruction_19|rotate_container"],
		["keyboard_left_container|thing_34|3"],
		["keyboard_left_container|90.0"]
	],
	5:[
		["instruction_33|set_the_scene"],
		["keyboard_left_container|thing_34|0"],
		["0"]
	],
	6:[ #  move_container
		["instruction_20|move_container"],
		["keyboard_left_container|thing_34|3"],
		["keyboard_left_container|0.0,-4.5,0.41"]
	],
	7:[
		["instruction_21|set_interaction_check_mode"],
		["keyboard_left_container|thing_34"],
		["single|1"]
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

# string window left and right
# button to connect, center of three, left right words we have stars like points and keys split and destinations too
# keyboard is splited in three

# keyboard right instructions
# destination position direction
# nodes amounts paths names codes

# words terminal console connect combo
# function var_name type_name var
# func fumctopm create_new task thread queue turn create setup ready _ __ big_letter Big_letter BIG_letter multiple_letter_s S_nake_game

# maximum lenghts of windows scalable as we have limits of zoom too, to zoom from and know where we were
# with satelites music movement position, we keep scales and postions and numbers in check to know #
# how it was and will be #


const instructions_set_5 = {
	0: [ # send things to datapoint
		["instruction_20|assign_priority_to_datapoint"],
		["keyboard_right_container|thing_53"],
		["1"]
	] ,# add coma ,
	1: [ # send things to datapoint
		["instruction_21|assign_things_to_datapoint"],
		["keyboard_right_container|thing_53"],
		["keyboard_right_container|thing_54|thing_55|thing_56|thing_57|thing_58|thing_59|thing_60|thing_61|thing_62|thing_63|thing_64|thing_65|thing_66|thing_67|thing_68|thing_69|thing_70"]
	] ,# add coma ,
	2:[ # send max things to datapoint
		["instruction_22|set_max_things_number"],
		["keyboard_right_container|thing_53"],
		["100"]
	], # add coma ,
	3:[ # connect containter and datapoint
		["instruction_23|connect_containter_datapoint"],
		["keyboard_right_container|thing_53|4"],
		["keyboard_right_container"]
	],
	4:[ # rotate keyboard
		["instruction_24|rotate_container"],
		["keyboard_right_container|thing_53|4"],
		["keyboard_right_container|90.0"]
	],
	5:[
		["instruction_34|set_the_scene"],
		["keyboard_right_container|thing_53|0"],
		["0"]
	],
	6:[ #  move_container
		["instruction_25|move_container"],
		["keyboard_right_container|thing_53|4"],
		["keyboard_right_container|0.0,-4.5,0.41"]
	],
	7:[
		["instruction_26|set_interaction_check_mode"],
		["keyboard_right_container|thing_53"],
		["single|1"]
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



# Terminal / Console instructions for InstructionsBank
# Add to instructions_bank.gd

const instructions_set_terminal = {
	0: [ # Set priority to datapoint
		["instruction_100|assign_priority_to_datapoint"],
		["terminal_container|thing_301"],
		["0"]
	],
	1: [ # Assign things to datapoint
		["instruction_101|assign_things_to_datapoint"],
		["terminal_container|thing_301"],
		["terminal_container|thing_302|thing_303|thing_304|thing_305|thing_306|thing_307|thing_308|thing_309|thing_310|thing_311|thing_312|thing_313|thing_314|thing_315|thing_316|thing_317|thing_318|thing_319|thing_320|thing_321"]
	],
	2: [ # Max things number
		["instruction_102|set_max_things_number"],
		["terminal_container|thing_301"],
		["100"]
	],
	3: [ # Connect container and datapoint
		["instruction_103|connect_containter_datapoint"],
		["terminal_container|thing_301|0"],
		["terminal_container"]
	],
	4: [ # Set the scene
		["instruction_104|set_the_scene"],
		["terminal_container|thing_301|0"],
		["0"]
	],
	5: [ # Set interaction mode
		["instruction_105|set_interaction_check_mode"],
		["terminal_container|thing_301"],
		["multi|2"]
	],
	6: [ # Set position
		["instruction_106|move_container"],
		["terminal_container|thing_301|0"],
		["terminal_container|0.0,0.0,1.0"]
	],
	7: [ # Setup text bracket for terminal input field
		["instruction_107|setup_text_bracet"],
		["terminal_container|thing_301|0"],
		["terminal_container|call_function"]
	]
}


# create thing anything some thing some where path bridge tunnel connection road cross 
# write command in console and terminal cmd string split join merge symbol
# we must create lines for keyboard too maybe? words letters numbers symbols

# know_your_limits of_limit as_things_can be random too
# up to three in two we continue we check limits from time of time of repeat and # symbols too that was two or one if we cut ## # 
# the added scene instructions lol now # we have more limits where symbols or space bar checks stuff for terminall too and we#
# check where we started and ended too #
# with space_bar or without space bar with space in middle too #
# start and end #
# as there is a long way to break the combo with enters too #


# Terminal / Console instructions for InstructionsBank
# Add to instructions_bank.gd

const instructions_set_terminal_ = {
	0: [ # Set priority to datapoint
		["instruction_100|assign_priority_to_datapoint"],
		["terminal_container|thing_301"],
		["0"]
	],
	1: [ # Assign things to datapoint
		["instruction_101|assign_things_to_datapoint"],
		["terminal_container|thing_301"],
		["terminal_container|thing_302|thing_303|thing_304|thing_305|thing_306|thing_307|thing_308|thing_309|thing_310|thing_311|thing_312|thing_313|thing_314|thing_315|thing_316|thing_317|thing_318|thing_319"]
	],
	2: [ # Max things number
		["instruction_102|set_max_things_number"],
		["terminal_container|thing_301"],
		["100"]
	],
	3: [ # Connect container and datapoint
		["instruction_103|connect_containter_datapoint"],
		["terminal_container|thing_301|0"],
		["terminal_container"]
	],
	4: [ # Set the scene
		["instruction_104|set_the_scene"],
		["terminal_container|thing_301|0"],
		["0"]
	],
	5: [ # Set interaction mode
		["instruction_105|set_interaction_check_mode"],
		["terminal_container|thing_301"],
		["multi|2"]
	],
	6: [ # Set position
		["instruction_106|move_container"],
		["terminal_container|thing_301|0"],
		["terminal_container|0.0,0.0,1.0"]
	]
}


# but we can continue too if we know what space can fold unfold how connect if we know the code, cheat spread sheet |! start end return #
# retunr is and but a start # and start behings with in check find duration frequency lenght is calculator for for #
# for and match and file size is what we need to repeat similar functions too with more cores #

# cores numbers # split join merge # in one line more if we limit to how much there will be too, up to 1 to 2 k thousands of lines of code #
# splits happens too, human make mistakes too, so you limit to limit of tokens no matter what, if we limit up to 100 lines and my words #
# connections # symbols # words # numbers #

# rules # sets # files # paths # names # nodes # stop # end # : # ; # ) # } # ] #
# start ( [ { func var class const @ | and or add minus plus equal null float int Array String #
# aA bB cC dD eE fF gG hH #
# aA iI uU eE oO #
# q w e r t y 1 2 3 4 5 6 #
# limits 2d space 3d duration of lenght of layer height as screen have layer? how they made games flat without botle neck somewhere

# words connect like bridges with limits of parts amounts numbers crosses
# symbols splits for loops
# like games and shapes and layers and windows



const instructions_set_6 = {
	0: [ # send things to datapoint
		["instruction_25|assign_priority_to_datapoint"],
		["things_creation_container|thing_72"],
		["1"]
	] ,# add coma ,
	1: [ # send things to datapoint
		["instruction_26|assign_things_to_datapoint"],
		["things_creation_container|thing_72"],
		["things_creation_container|thing_73|thing_74|thing_75"]
	] ,# add coma ,
	2:[ # send max things to datapoint
		["instruction_27|set_max_things_number"],
		["things_creation_container|thing_72"],
		["100"]
	], # add coma ,
	3:[ # connect containter and datapoint
		["instruction_28|connect_containter_datapoint"],
		["things_creation_container|thing_72|1"],
		["things_creation_container"]
	],
	4:[
		["instruction_35|set_the_scene"],
		["things_creation_container|thing_72|0"],
		["0"]
	],
	7:[
		["instruction_36|set_interaction_check_mode"],
		["things_creation_container|thing_72"],
		["single|1"]
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

# singular lines are in need of pipes checks too
# single and multi thread works different
# pipes and scripts can be repaired and checked in automation based on start and stop and duration and frequency

# and layers for things to connect too

const instructions_set_7 = {
	0: [ # send things to datapoint
		["instruction_0|assign_priority_to_datapoint"],
		["singular_lines_container|thing_1"],
		["0"]
	] ,# add coma ,
	1: [ # send things to datapoint
		["instruction_1|assign_things_to_datapoint"],
		["singular_lines_container|thing_1"],
		["singular_lines_container|thing_0|thing_1|thing_2|thing_3|thing_4|thing_5"]
	] ,# add coma ,
	2:[ # send max things to datapoint
		["instruction_2|set_max_things_number"],
		["singular_lines_container|thing_1"],
		["100"]
	], # add coma ,
	3:[ # connect containter and datapoint
		["instruction_3|connect_containter_datapoint"],
		["singular_lines_container|thing_1|0"],
		["singular_lines_container"]
	],
	4:[
		["instruction_4|set_the_scene"],
		["singular_lines_container|thing_1|0"],
		["0"]
	],
	5:[
		["instruction_5|set_interaction_check_mode"],
		["singular_lines_container|thing_1"],
		["multi|2"]
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

# space star galaxy planet moon cross_roads
# snake apple move head body object jsh
# apple tree fog world heightmap marching_cube noise_view noise_create

# vehicle move spin continue duration frequency pitch speed
# ship space water direction duration velocity rules sets boundaries landing
# repeat change shift roll check giroscopes and gizmos all in one
# return combine debug like tool for checking directions of simulations

# space galaxy star planet moon orbit repeat
# process input move rotate position velocity move
# rotate because mouse and we moved in past

# combo breaker combine console terminal cmd computer
# snake space ship vehicle camera direction speed
# local global node path space 3d position merge

# commands retry try check find
# create move rotate end
# start continue limits

# size number scale duration frequency connect combo
# command commander commands lists segments
