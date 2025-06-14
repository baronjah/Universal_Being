extends Node

class_name TurnCycleManager

signal turn_completed(turn_number)
signal cycle_completed
signal rest_period_started
signal rest_period_ended

const MAX_TURNS_PER_CYCLE = 12
const REST_PERIOD_DEFAULT = 60 # seconds

var current_turn: int = 0
var total_cycles_completed: int = 0
var is_resting: bool = false
var rest_period_duration: int = REST_PERIOD_DEFAULT
var rest_timer: Timer

# Color system - 9 base colors + 3 extension colors
enum ColorSystem {
	AZURE,     # Dimension 1 - Foundation
	EMERALD,   # Dimension 2 - Growth
	AMBER,     # Dimension 3 - Energy
	VIOLET,    # Dimension 4 - Insight
	CRIMSON,   # Dimension 5 - Force
	INDIGO,    # Dimension 6 - Vision
	SAPPHIRE,  # Dimension 7 - Wisdom
	GOLD,      # Dimension 8 - Transcendence
	SILVER,    # Dimension 9 - Unity
	OBSIDIAN,  # Extension 1 - Void
	PLATINUM,  # Extension 2 - Ascension
	DIAMOND    # Extension 3 - Purity
}

# Mapping colors to their hex values for visualization
var color_values = {
	ColorSystem.AZURE: Color("#1E90FF"),
	ColorSystem.EMERALD: Color("#50C878"),
	ColorSystem.AMBER: Color("#FFBF00"),
	ColorSystem.VIOLET: Color("#8F00FF"),
	ColorSystem.CRIMSON: Color("#DC143C"),
	ColorSystem.INDIGO: Color("#4B0082"),
	ColorSystem.SAPPHIRE: Color("#0F52BA"),
	ColorSystem.GOLD: Color("#FFD700"),
	ColorSystem.SILVER: Color("#C0C0C0"),
	ColorSystem.OBSIDIAN: Color("#1A1110"),
	ColorSystem.PLATINUM: Color("#E5E4E2"),
	ColorSystem.DIAMOND: Color("#B9F2FF")
}

# Each turn has a dominant color influence
var turn_color_mapping = [
	ColorSystem.AZURE,
	ColorSystem.EMERALD,
	ColorSystem.AMBER,
	ColorSystem.VIOLET,
	ColorSystem.CRIMSON,
	ColorSystem.INDIGO,
	ColorSystem.SAPPHIRE,
	ColorSystem.GOLD,
	ColorSystem.SILVER,
	ColorSystem.OBSIDIAN,
	ColorSystem.PLATINUM,
	ColorSystem.DIAMOND
]

func _ready():
	rest_timer = Timer.new()
	rest_timer.one_shot = true
	rest_timer.timeout.connect(_on_rest_timer_timeout)
	add_child(rest_timer)
	
	# Initialize from saved state if available
	_load_cycle_state()

func _load_cycle_state():
	if FileAccess.file_exists("user://eden_cycle_state.save"):
		var file = FileAccess.open("user://eden_cycle_state.save", FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			current_turn = data.current_turn
			total_cycles_completed = data.total_cycles_completed
			rest_period_duration = data.rest_period_duration

func _save_cycle_state():
	var data = {
		"current_turn": current_turn,
		"total_cycles_completed": total_cycles_completed,
		"rest_period_duration": rest_period_duration
	}
	
	var json_string = JSON.stringify(data)
	var file = FileAccess.open("user://eden_cycle_state.save", FileAccess.WRITE)
	file.store_string(json_string)
	file.close()

func advance_turn():
	if is_resting:
		return false
		
	current_turn += 1
	
	if current_turn > MAX_TURNS_PER_CYCLE:
		current_turn = 1
		total_cycles_completed += 1
		emit_signal("cycle_completed")
		_begin_rest_period()
		_save_cycle_state()
		return false
	
	emit_signal("turn_completed", current_turn)
	_save_cycle_state()
	return true

func _begin_rest_period():
	is_resting = true
	emit_signal("rest_period_started")
	rest_timer.start(rest_period_duration)

func _on_rest_timer_timeout():
	is_resting = false
	emit_signal("rest_period_ended")

func get_current_color() -> Color:
	return color_values[turn_color_mapping[current_turn - 1]]

func get_current_color_name() -> String:
	return ColorSystem.keys()[turn_color_mapping[current_turn - 1]]

func set_rest_period_duration(seconds: int):
	rest_period_duration = seconds
	_save_cycle_state()

func skip_rest_period():
	if is_resting:
		rest_timer.stop()
		is_resting = false
		emit_signal("rest_period_ended")

func get_turn_progress() -> float:
	return float(current_turn) / float(MAX_TURNS_PER_CYCLE)

func reset_cycle():
	current_turn = 0
	is_resting = false
	rest_timer.stop()
	_save_cycle_state()