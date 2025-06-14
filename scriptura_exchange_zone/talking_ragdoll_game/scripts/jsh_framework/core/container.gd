# 🏛️ Container - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# containter.gd
extends UniversalBeingBase
var container_number : int = -1
var containter_datapoint = null
var additional_datapoints : Array = []
var connected_containers : Array = []

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	super.pentagon_init()
	print(" ready on each script ? 3 container.gd")


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
func containter_start_up(con_num, data):
	#print(" containter stuff, are we connected :( con_num, data : ", con_num, data, " also self name :", self.name)
	#print(" containter start up")
	container_number = con_num
	if containter_datapoint == null:
#		print(" cont_fia it was null before? ")
		containter_datapoint = data
	else:
#		print(" cont_fia additional container : " , data)
		additional_datapoints.append(data)
#		print(" additional_datapoints : " , additional_datapoints)

func get_datapoint():
	#print(" well ? get_datapoint ? containter_datapoint : ", containter_datapoint)
	return containter_datapoint

func containter_get_data():
	return[container_number, containter_datapoint]
	
func container_get_additional_datapoints():
	return additional_datapoints

func containers_connections(data):
#	print(" the idea is simple, we shall also connect containers")
	connected_containers.append(data)

func get_containers_connected():
	return connected_containers
