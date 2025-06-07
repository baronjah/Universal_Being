# ==================================================
# SYSTEM: Universal Being Print Collector
# PURPOSE: Manage console output to prevent spam and organize logging
# GENIUS IDEA: Replace all print() calls with organized, collectable logging
# ==================================================

extends Node
class_name UBPrintCollector

# ===== PRINT COLLECTION PROPERTIES =====
@export var collection_interval: float = 2.0  # Collect and flush every 2 seconds
@export var max_repeats_shown: int = 10  # Show "x10" instead of 10 identical messages
@export var enable_filtering: bool = true  # Enable smart filtering

# Collection storage
var collected_prints: Dictionary = {}  # Key: message_signature, Value: print_data
var collection_timer: float = 0.0
var total_prints_collected: int = 0
var last_flush_time: float = 0.0

# Message signature structure: "script_name::function_name::message_id"
# Message data structure: {count, first_timestamp, last_timestamp, message, type}

signal print_flushed(formatted_output: String)

func _ready() -> void:
	name = "UBPrintCollector" 
	set_process(true)
	print("🗂️ UB Print Collector: Initializing organized logging system...")

func _process(delta: float) -> void:
	collection_timer += delta
	
	if collection_timer >= collection_interval:
		flush_collected_prints()
		collection_timer = 0.0

# ===== MAIN LOGGING API =====

func log_message(script_name: String, function_name: String, message: String, message_id: String = "default", log_type: String = "info") -> void:
	"""Main logging function to replace all print() calls"""
	var signature = "%s::%s::%s" % [script_name, function_name, message_id]
	var current_time = Time.get_ticks_msec() / 1000.0
	
	total_prints_collected += 1
	
	if signature in collected_prints:
		# Update existing entry
		var entry = collected_prints[signature]
		entry.count += 1
		entry.last_timestamp = current_time
		entry.message = message  # Update to latest message version
	else:
		# Create new entry
		collected_prints[signature] = {
			"count": 1,
			"first_timestamp": current_time,
			"last_timestamp": current_time,
			"message": message,
			"script_name": script_name,
			"function_name": function_name,
			"message_id": message_id,
			"type": log_type
		}

# ===== CONVENIENCE LOGGING METHODS =====

func info(script_name: String, function_name: String, message: String, message_id: String = "info") -> void:
	log_message(script_name, function_name, message, message_id, "info")

func warning(script_name: String, function_name: String, message: String, message_id: String = "warning") -> void:
	log_message(script_name, function_name, message, message_id, "warning")

func error(script_name: String, function_name: String, message: String, message_id: String = "error") -> void:
	log_message(script_name, function_name, message, message_id, "error")

func debug(script_name: String, function_name: String, message: String, message_id: String = "debug") -> void:
	log_message(script_name, function_name, message, message_id, "debug")

func success(script_name: String, function_name: String, message: String, message_id: String = "success") -> void:
	log_message(script_name, function_name, message, message_id, "success")

# ===== CONSCIOUSNESS-SPECIFIC LOGGING =====

func consciousness(script_name: String, function_name: String, message: String, level: int = 0) -> void:
	pass
	var message_id = "consciousness_level_%d" % level
	log_message(script_name, function_name, message, message_id, "consciousness")

func ai_thought(script_name: String, function_name: String, message: String, thought_type: String = "decision") -> void:
	log_message(script_name, function_name, message, thought_type, "ai")

func human_action(script_name: String, function_name: String, message: String, action_type: String = "input") -> void:
	log_message(script_name, function_name, message, action_type, "human")

# ===== PRINT COLLECTION & FORMATTING =====

func flush_collected_prints() -> void:
	"""Flush collected prints to console in organized format"""
	if collected_prints.is_empty():
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	var time_span = current_time - last_flush_time
	last_flush_time = current_time
	
	# Group by script for organized output
	var scripts_data: Dictionary = {}
	
	for signature in collected_prints.keys():
		var entry = collected_prints[signature]
		var script_name = entry.script_name
		
		if script_name not in scripts_data:
			scripts_data[script_name] = []
		
		scripts_data[script_name].append(entry)
	
	# Format and output organized logs
	var formatted_output = _format_collected_output(scripts_data, time_span)
	
	# Output to both regular print and signal
	print(formatted_output)
	print_flushed.emit(formatted_output)
	
	# Clear collected prints
	collected_prints.clear()

func _format_collected_output(scripts_data: Dictionary, time_span: float) -> String:
	"""Format collected prints into organized, readable output"""
	var output = []
	
	# Header
	output.append("┌─ 🗂️ UB Print Collection (%.1fs span) ─┐" % time_span)
	
	# Sort scripts by importance (consciousness > ai > human > systems > others)
	var script_priority = {
		"consciousness": 0, "ai": 1, "human": 2, "systems": 3
	}
	
	var sorted_scripts = scripts_data.keys()
	sorted_scripts.sort_custom(func(a, b): 
		var priority_a = _get_script_priority(a, script_priority)
		var priority_b = _get_script_priority(b, script_priority)
		return priority_a < priority_b
	)
	
	for script_name in sorted_scripts:
		var entries = scripts_data[script_name]
		output.append("│")
		output.append("├─ 📄 %s" % script_name)
		
		# Sort entries by function name, then by frequency
		entries.sort_custom(func(a, b): 
			if a.function_name != b.function_name:
				return a.function_name < b.function_name
			return a.count > b.count
		)
		
		for entry in entries:
			var count_text = ""
			if entry.count > 1:
				if entry.count <= max_repeats_shown:
					count_text = " (x%d)" % entry.count
				else:
					count_text = " (x%d+)" % max_repeats_shown
			
			var type_icon = _get_type_icon(entry.type)
			var function_text = entry.function_name if entry.function_name != "default" else ""
			var id_text = entry.message_id if entry.message_id != "default" else ""
			
			var line_parts = ["│  %s" % type_icon]
			if function_text:
				line_parts.append(function_text + "()")
			if id_text and id_text != function_text:
				line_parts.append("[%s]" % id_text)
			line_parts.append(entry.message)
			if count_text:
				line_parts.append(count_text)
			
			output.append(" ".join(line_parts))
	
	output.append("└─ Total: %d messages collected ─┘" % total_prints_collected)
	
	return "\n".join(output)

func _get_script_priority(script_name: String, priority_map: Dictionary) -> int:
	"""Get priority for script ordering"""
	for key in priority_map.keys():
		if script_name.to_lower().contains(key):
			return priority_map[key]
	return 999  # Default low priority

func _get_type_icon(log_type: String) -> String:
	"""Get emoji icon for log type"""
	match log_type:
		"consciousness": return "🧠"
		"ai": return "🤖"
		"human": return "👤"
		"info": return "ℹ️"
		"warning": return "⚠️"
		"error": return "❌"
		"success": return "✅"
		"debug": return "🔍"
		_: return "📝"

# ===== FILTERING & MANAGEMENT =====

func set_filter_enabled(enabled: bool) -> void:
	"""Enable/disable smart filtering"""
	enable_filtering = enabled

func set_collection_interval(seconds: float) -> void:
	"""Set how often to flush collected prints"""
	collection_interval = max(0.1, seconds)

func get_collection_stats() -> Dictionary:
	"""Get statistics about collected prints"""
	return {
		"total_collected": total_prints_collected,
		"currently_collected": collected_prints.size(),
		"collection_interval": collection_interval,
		"last_flush_time": last_flush_time
	}

func force_flush() -> void:
	"""Force immediate flush of collected prints"""
	flush_collected_prints()

func clear_collection() -> void:
	"""Clear all collected prints without flushing"""
	collected_prints.clear()

# ===== GLOBAL SINGLETON ACCESS =====

# This should be added to autoload as "UBPrint"
# Then scripts can use: UBPrint.log("script_name", "function_name", "message")

# UBPrintCollector: Class loaded - Ready to organize the chaos of consciousness!