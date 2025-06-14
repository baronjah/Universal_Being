# 🏛️ Record Set Manager - Resource management system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Resource management system
# Connection: Part of Pentagon Architecture migration

# record_set_manager.gd
# root/JSH_records_system
extends UniversalBeingBase
#
# res://code/gdscript/scripts/Menu_Keyboard_Console/record_set_manager.gd
# res://code/gdscript/scripts/Archive_Past_Text/ARF_global_load.gd
# JSH_Core/JSH_mainframe_database/JSH_records_system
#
# Record set storage
var active_records = {}
var cached_records = {}

var records_sets_packs = {
	"basic" = {},
	"keyboard" = {},
	"screen" = {},
	"text" = {},
	"2d" = {},
	"3d" = {}
}

var basic_set : Dictionary = {"base":"base_", "menu":"menu_"}
var keyboard : Dictionary = {"keyboard":"keyboard", "left":"right"}
var screen : Dictionary = {"distance":"distance", "layer":"layer", "rotation":"rotation", "position":"position"}
var text : Dictionary = {"label":"label", "orientation":"orientation", "follow":"follow", "path":"path"}
var a0_2d : Dictionary = {"sprite":"Sprite3D", "shape":"Mesh", "layer":"distance", "mesh":"Mesh"}
var a0_3d : Dictionary = {"A":"a", "a":"1", "a1":"A"}
var a1_basic_set : Dictionary = {"terminal":"terminal_", "console":"console_", "finder":"finder_"}

var state_of_set = "pending"

var record_mutex = Mutex.new()

# Configuration
const MAX_CACHE_SIZE_MB = 50
const CLEANUP_INTERVAL = 300  # 5 minutes

# Metadata tracking
var last_cleanup_time = 0
var total_cache_size = 0

#func _process(_delta):
	#var current_time = Time.get_ticks_msec()
	#if current_time - last_cleanup_time > CLEANUP_INTERVAL * 1000:
		#cleanup_cache()
		#last_cleanup_time = current_time



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
func check_all_things():
	print(" JSH_records_system check connection")
	return true

func add_stuff_to_basic(list_of_things):
	#if list_of_things is String:
		#print(" it is String ")
	#if list_of_things is Array:
		#print(" it is array ", list_of_things[0])
	if records_sets_packs["basic"].is_empty():
		#print(" that basic is empty ")
		for thing in list_of_things:
			#print(" we got these things to add : " , thing)
			records_sets_packs["basic"][thing] = {}
	#if list_of_things is PackedStringArray:
		#print(" it is packedstring array ")
	#print(" records_sets_packs[basic] : " , records_sets_packs["basic"])


func check_basic_set_if_loaded():
	for set_to_pull in records_sets_packs["basic"]:
		print(" set to pull out " , set_to_pull)
		if records_sets_packs["basic"][set_to_pull].is_empty():
			records_sets_packs["basic"][set_to_pull]["status"] = state_of_set
			return set_to_pull

func add_record_set_to_list(key_input_a, key_input_b, record_pack):
	
	# check if inputs are strings
	if key_input_a is String:
		print(" it is string")
	else:
		return false
	if key_input_a is String:
		print(" it is string")
	else:
		return false



	# check if record_pack is a list file, packed array strings maybe
	if record_pack is PackedStringArray:
		print(" that pack is PackedStringArray")
		
	# if it is aray we could parse it in different way later
	elif record_pack is Array:
		print(" that pack is Array")
		return
		
	# same
	elif record_pack is String:
		print(" that pack is String")
		return
	
	# same
	elif record_pack is Dictionary:
		print(" that pack is a string")
		return
		
		
	if records_sets_packs.has(key_input_a):
		print(" we already had that pack ")
		# we should check if there is something new in there
		
		if records_sets_packs[key_input_a].has(key_input_b):
			print(" we already had something in there ")
			# we can check if it is different than what we have, since we are already there
			
		else:
			print(" we didnt have that one before, we can add something in it")
			# we had that type of sets, but it is new layer_1 data
			records_sets_packs[key_input_a][key_input_b] = record_pack
			
	else:
		print(" it is new, we could add it ")
		# add new cathegory and add record pack list
		records_sets_packs[key_input_a] = {}
		records_sets_packs[key_input_a][key_input_b] = record_pack

func get_all_records_packs():
	return records_sets_packs
	
func get_one_records_pack(key_input_a, key_input_b):
	
	if key_input_b is String:
		print(" it is string, we can try it")
		if key_input_a is String:
			print(" it is string, we can try it")
			if records_sets_packs.has(key_input_a):
				print(" it had it, we can send it")
				if records_sets_packs[key_input_a].has(key_input_b):
					# we check 4 things
					return records_sets_packs[key_input_a][key_input_b]
				else:
					print(" didnt find it at second key")
					return false
				
			else:
				print(" we didnt find it ")
				return false
		else:
			print(" something is wrong ")
			return false
	else:
		print(" something is wrong")
		return false



func compare_list_of_records(key_input_a, _key_input_b, record_pack):
	var _data_to_check_0
	var _data_to_check_1
	
	var function_state : int = -1
	
	if records_sets_packs.has(key_input_a):
		function_state = 1
		print()
		
	if record_pack is PackedStringArray:
		function_state = 2



	if function_state == 2:
		print(" two for loops can happen ")



func add_record_set(record_set_name: String, data: Dictionary) -> bool:
	record_mutex.lock()
	if record_set_name in active_records:
		record_mutex.unlock()
		return false
		
	active_records[record_set_name] = {
		"data": data,
		"created_at": Time.get_ticks_msec(),
		"last_accessed": Time.get_ticks_msec()
	}
	record_mutex.unlock()
	return true

func get_record_set(record_set_name: String) -> Dictionary:
	record_mutex.lock()
	if record_set_name in active_records:
		var record = active_records[record_set_name]
		record["last_accessed"] = Time.get_ticks_msec()
		record_mutex.unlock()
		return record["data"]
	elif record_set_name in cached_records:
		var cached = cached_records[record_set_name]
		# Move from cache to active
		active_records[record_set_name] = cached
		cached_records.erase(record_set_name)
		record_mutex.unlock()
		return cached["data"]
	record_mutex.unlock()
	return {}

func cache_record_set(record_set_name: String) -> bool:
	record_mutex.lock()
	if record_set_name in active_records:
		cached_records[record_set_name] = active_records[record_set_name]
		active_records.erase(record_set_name)
		record_mutex.unlock()
		return true
	record_mutex.unlock()
	return false

func cleanup_cache():
	record_mutex.lock()
	var _current_time = Time.get_ticks_msec()
	var cache_size = 0
	
	# Calculate current cache size
	for record in cached_records.values():
		cache_size += get_record_size(record)
	
	# Remove old records if over size limit
	if cache_size > MAX_CACHE_SIZE_MB * 1024 * 1024:
		var records_by_age = cached_records.keys()
		records_by_age.sort_custom(func(a, b): 
			return cached_records[a]["last_accessed"] < cached_records[b]["last_accessed"]
		)
		
		while cache_size > MAX_CACHE_SIZE_MB * 1024 * 1024 and records_by_age:
			var oldest = records_by_age.pop_front()
			cache_size -= get_record_size(cached_records[oldest])
			cached_records.erase(oldest)
	
	record_mutex.unlock()

func get_record_size(record: Dictionary) -> int:
	# Estimate size in bytes
	var size = 0
	for key in record["data"]:
		size += 8  # Assume 8 bytes per number/reference
		if record["data"][key] is String:
			size += record["data"][key].length()
	return size
