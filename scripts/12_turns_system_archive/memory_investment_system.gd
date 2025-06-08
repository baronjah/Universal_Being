extends Node

class_name MemoryInvestmentSystem

# Memory Investment System - Tracks value and growth of invested words and concepts
# Integrates with the 12-turn system and provides pause functionality

# Constants
const INVESTMENT_CYCLES = 12
const MIN_INVESTMENT_PERIOD = 3.0 # seconds
const MAX_INVESTMENT_PERIOD = 60.0 # seconds
const DEFAULT_PAUSE_DURATION = 12.0 # seconds
const WORD_VALUE_MULTIPLIERS = {
	"common": 1.0,
	"uncommon": 1.5,
	"rare": 2.0,
	"unique": 3.0,
	"divine": 5.0
}
const INVESTMENT_CATEGORIES = {
	"conceptual": 0,
	"structural": 1,
	"functional": 2,
	"aesthetic": 3,
	"foundational": 4,
	"directional": 5,
	"dimensional": 6
}
const INVESTMENT_RETURN_RATES = {
	"conceptual": 0.05,
	"structural": 0.03,
	"functional": 0.04,
	"aesthetic": 0.02,
	"foundational": 0.06,
	"directional": 0.04,
	"dimensional": 0.08
}

# Structure for investment portfolio
class Investment:
	var word: String
	var category: String
	var initial_value: float
	var current_value: float
	var investment_date: int
	var last_updated: int
	var growth_rate: float
	var maturity_cycle: int
	var rarity: String
	var is_paused: bool
	var pause_until: int
	var direction_vector: Vector3
	
	func _init(w, cat, val, rar):
		word = w
		category = cat
		initial_value = val
		current_value = val
		investment_date = OS.get_unix_time()
		last_updated = investment_date
		growth_rate = INVESTMENT_RETURN_RATES[cat] if cat in INVESTMENT_RETURN_RATES else 0.03
		maturity_cycle = randi() % INVESTMENT_CYCLES + 1
		rarity = rar
		is_paused = false
		pause_until = 0
		# Generate a directional vector based on word characteristics
		direction_vector = Vector3(
			(word.length() % 10) / 10.0,
			(word.to_ascii()[0] % 10) / 10.0,
			(initial_value % 100) / 100.0
		)
	
	func update_value(current_time):
		if is_paused and current_time < pause_until:
			return current_value
			
		# Resume if pause is over
		if is_paused and current_time >= pause_until:
			is_paused = false
		
		# Calculate time elapsed since last update
		var elapsed_time = current_time - last_updated
		
		# Update value based on growth rate and time
		var multiplier = WORD_VALUE_MULTIPLIERS[rarity] if rarity in WORD_VALUE_MULTIPLIERS else 1.0
		var time_factor = elapsed_time / 86400.0 # Convert seconds to days
		
		current_value = initial_value * (1.0 + growth_rate * multiplier * time_factor)
		last_updated = current_time
		
		return current_value
	
	func pause_investment(duration):
		is_paused = true
		pause_until = OS.get_unix_time() + duration
		return pause_until

# System variables
var active_investments = {}
var completed_investments = {}
var paused_investments = {}
var total_portfolio_value = 0.0
var current_cycle = 1
var cycle_start_time = 0
var auto_next_turn = true
var next_turn_timer = null
var pause_timer = null
var is_system_paused = false
var pause_end_time = 0

# Connection to other systems
var memory_system = null
var turn_system = null

# Signals
signal investment_added(word, value, category)
signal investment_matured(word, initial_value, final_value, roi)
signal cycle_completed(cycle_number, total_value)
signal system_paused(duration)
signal system_resumed()
signal turn_advanced(turn_number)

func _ready():
	# Initialize the system
	cycle_start_time = OS.get_unix_time()
	
	# Set up timers
	next_turn_timer = Timer.new()
	next_turn_timer.one_shot = true
	next_turn_timer.connect("timeout", self, "_on_next_turn_timer")
	add_child(next_turn_timer)
	
	pause_timer = Timer.new()
	pause_timer.one_shot = true
	pause_timer.connect("timeout", self, "_on_pause_timer")
	add_child(pause_timer)
	
	# Connect to other systems
	connect_to_memory_system()
	connect_to_turn_system()
	
	# Start the first cycle
	start_cycle(current_cycle)
	
	print("Memory Investment System initialized")
	print("Current cycle: " + str(current_cycle) + "/" + str(INVESTMENT_CYCLES))

func _process(delta):
	# Update investment values in real-time
	if not is_system_paused:
		update_all_investments()
	
	# Check if it's time for auto-next turn
	if auto_next_turn and next_turn_timer and not next_turn_timer.is_stopped():
		var time_left = next_turn_timer.time_left
		if time_left <= 0.5:
			# Prepare visual indication that turn is about to advance
			pass

func connect_to_memory_system():
	# Connect to ProjectMemorySystem if available
	if has_node("/root/ProjectMemorySystem") or get_node_or_null("/root/ProjectMemorySystem"):
		memory_system = get_node("/root/ProjectMemorySystem")
		print("Connected to ProjectMemorySystem")
		return true
	
	# Try SmartAccountSystem path
	if has_node("/root/SmartAccountSystem/ProjectMemorySystem") or get_node_or_null("/root/SmartAccountSystem/ProjectMemorySystem"):
		memory_system = get_node("/root/SmartAccountSystem/ProjectMemorySystem")
		print("Connected to ProjectMemorySystem under SmartAccountSystem")
		return true
	
	return false

func connect_to_turn_system():
	# Look for turn system in different paths
	var potential_paths = [
		"/root/TurnSystem",
		"/root/SmartAccountSystem/TurnSystem",
		"/root/12_turns_system",
		"/root/turn_manager"
	]
	
	for path in potential_paths:
		if has_node(path) or get_node_or_null(path):
			turn_system = get_node(path)
			print("Connected to Turn System at: " + path)
			return true
	
	# Create internal turn tracking if no system found
	print("No turn system found, using internal tracking")
	return false

func invest_word(word, category = "conceptual", initial_value = 10.0, rarity = "common"):
	# Validate inputs
	if word.empty():
		print("Cannot invest empty word")
		return null
	
	if not category in INVESTMENT_CATEGORIES:
		print("Invalid category: " + category)
		category = "conceptual"
	
	if not rarity in WORD_VALUE_MULTIPLIERS:
		print("Invalid rarity: " + rarity)
		rarity = "common"
	
	# Generate unique ID for this investment
	var investment_id = _generate_investment_id(word)
	
	# Check if already invested
	if investment_id in active_investments:
		print("Word already invested: " + word)
		return null
	
	# Create investment
	var investment = Investment.new(word, category, initial_value, rarity)
	
	# Add to active investments
	active_investments[investment_id] = investment
	
	# Update portfolio value
	total_portfolio_value += initial_value
	
	# Add to memory system if connected
	if memory_system and memory_system.has_method("add_memory"):
		var memory_id = memory_system.add_memory(
			"Investment: " + word + " (" + category + ")",
			"investment_memories",
			[word, category, rarity]
		)
		
		if memory_id:
			print("Added investment to memory system: " + memory_id)
	
	# Emit signal
	emit_signal("investment_added", word, initial_value, category)
	
	print("Invested in word: " + word + " (" + category + ") with " + str(initial_value) + " value")
	return investment_id

func update_investment(investment_id):
	if not investment_id in active_investments:
		print("Investment not found: " + investment_id)
		return null
	
	var investment = active_investments[investment_id]
	var current_time = OS.get_unix_time()
	
	# Update investment value
	var old_value = investment.current_value
	var new_value = investment.update_value(current_time)
	
	# Update portfolio value
	total_portfolio_value += (new_value - old_value)
	
	# Check if investment has matured
	if current_cycle >= investment.maturity_cycle:
		mature_investment(investment_id)
	
	return new_value

func update_all_investments():
	var current_time = OS.get_unix_time()
	var total_old_value = total_portfolio_value
	total_portfolio_value = 0
	
	# Update each active investment
	for investment_id in active_investments:
		var investment = active_investments[investment_id]
		if not investment.is_paused or current_time >= investment.pause_until:
			investment.update_value(current_time)
		total_portfolio_value += investment.current_value
	
	# Calculate portfolio growth
	var growth = total_portfolio_value - total_old_value
	
	return {
		"total_value": total_portfolio_value,
		"growth": growth,
		"active_investments": active_investments.size()
	}

func mature_investment(investment_id):
	if not investment_id in active_investments:
		print("Investment not found: " + investment_id)
		return null
	
	var investment = active_investments[investment_id]
	
	# Calculate final return
	var roi = (investment.current_value - investment.initial_value) / investment.initial_value
	
	# Move to completed investments
	completed_investments[investment_id] = investment
	active_investments.erase(investment_id)
	
	# Emit signal
	emit_signal("investment_matured", investment.word, investment.initial_value, investment.current_value, roi)
	
	print("Investment matured: " + investment.word + 
		  " with ROI of " + str(roi * 100) + "% (" + 
		  str(investment.initial_value) + " -> " + str(investment.current_value) + ")")
	
	return {
		"word": investment.word,
		"initial_value": investment.initial_value,
		"final_value": investment.current_value,
		"roi": roi,
		"category": investment.category,
		"direction": investment.direction_vector
	}

func start_cycle(cycle_number):
	current_cycle = cycle_number
	cycle_start_time = OS.get_unix_time()
	
	print("Starting investment cycle " + str(current_cycle) + "/" + str(INVESTMENT_CYCLES))
	
	# Set up auto-next turn if enabled
	if auto_next_turn:
		var turn_duration = _calculate_turn_duration()
		next_turn_timer.wait_time = turn_duration
		next_turn_timer.start()
		
		print("Auto-next turn in " + str(turn_duration) + " seconds")
	
	return {
		"cycle": current_cycle,
		"start_time": cycle_start_time,
		"portfolio_value": total_portfolio_value,
		"active_investments": active_investments.size()
	}

func end_cycle():
	# Process any remaining investments
	for investment_id in active_investments.keys():
		if current_cycle >= active_investments[investment_id].maturity_cycle:
			mature_investment(investment_id)
	
	# Emit signal
	emit_signal("cycle_completed", current_cycle, total_portfolio_value)
	
	print("Cycle " + str(current_cycle) + " completed with final value: " + str(total_portfolio_value))
	
	# Advance to next cycle if not at max
	if current_cycle < INVESTMENT_CYCLES:
		current_cycle += 1
		start_cycle(current_cycle)
	else:
		print("All investment cycles completed")
	
	return current_cycle

func pause_system(duration = DEFAULT_PAUSE_DURATION):
	if is_system_paused:
		print("System already paused")
		return false
	
	# Pause the system
	is_system_paused = true
	pause_end_time = OS.get_unix_time() + duration
	
	# Pause all active investments
	for investment_id in active_investments:
		active_investments[investment_id].pause_investment(duration)
	
	# Stop next turn timer if running
	if next_turn_timer and not next_turn_timer.is_stopped():
		next_turn_timer.stop()
	
	# Start pause timer
	pause_timer.wait_time = duration
	pause_timer.start()
	
	# Emit signal
	emit_signal("system_paused", duration)
	
	print("System paused for " + str(duration) + " seconds (coffee/smoke break)")
	return true

func resume_system():
	if not is_system_paused:
		print("System not paused")
		return false
	
	# Resume the system
	is_system_paused = false
	
	# Resume next turn timer if auto-next turn is enabled
	if auto_next_turn:
		var remaining_time = pause_end_time - OS.get_unix_time()
		if remaining_time <= 0:
			# Start a new turn timer with default duration
			var turn_duration = _calculate_turn_duration()
			next_turn_timer.wait_time = turn_duration
			next_turn_timer.start()
		else:
			# Resume with remaining time
			next_turn_timer.wait_time = remaining_time
			next_turn_timer.start()
	
	# Emit signal
	emit_signal("system_resumed")
	
	print("System resumed")
	return true

func advance_turn():
	# End current cycle
	end_cycle()
	
	# Trigger turn advancement in turn system if connected
	if turn_system and turn_system.has_method("advance_turn"):
		turn_system.advance_turn()
	
	# Emit signal
	emit_signal("turn_advanced", current_cycle)
	
	print("Advanced to turn " + str(current_cycle))
	return current_cycle

func toggle_auto_next_turn():
	auto_next_turn = !auto_next_turn
	
	if auto_next_turn:
		# Start next turn timer
		var turn_duration = _calculate_turn_duration()
		next_turn_timer.wait_time = turn_duration
		next_turn_timer.start()
		
		print("Auto-next turn enabled, next turn in " + str(turn_duration) + " seconds")
	else:
		# Stop next turn timer if running
		if next_turn_timer and not next_turn_timer.is_stopped():
			next_turn_timer.stop()
		
		print("Auto-next turn disabled")
	
	return auto_next_turn

func get_top_investments(count = 5):
	# Get top investments by current value
	var investments = []
	
	# Collect all investments
	for investment_id in active_investments:
		investments.append(active_investments[investment_id])
	
	# Sort by current value
	investments.sort_custom(self, "_sort_by_value")
	
	# Return top investments
	return investments.slice(0, min(count - 1, investments.size() - 1))

func get_investment_distribution():
	# Get distribution of investments by category
	var distribution = {}
	
	# Initialize categories
	for category in INVESTMENT_CATEGORIES:
		distribution[category] = {
			"count": 0,
			"total_value": 0.0,
			"average_growth": 0.0
		}
	
	# Count investments by category
	for investment_id in active_investments:
		var investment = active_investments[investment_id]
		var category = investment.category
		
		distribution[category]["count"] += 1
		distribution[category]["total_value"] += investment.current_value
		
		# Calculate growth rate
		var growth = (investment.current_value - investment.initial_value) / investment.initial_value
		distribution[category]["average_growth"] += growth
	
	# Calculate averages
	for category in distribution:
		if distribution[category]["count"] > 0:
			distribution[category]["average_growth"] /= distribution[category]["count"]
	
	return distribution

func get_portfolio_summary():
	# Get summary of portfolio performance
	var total_initial = 0.0
	var total_current = 0.0
	var total_growth = 0.0
	var category_counts = {}
	var rarity_counts = {}
	
	# Initialize categories and rarities
	for category in INVESTMENT_CATEGORIES:
		category_counts[category] = 0
	
	for rarity in WORD_VALUE_MULTIPLIERS:
		rarity_counts[rarity] = 0
	
	# Collect data from active investments
	for investment_id in active_investments:
		var investment = active_investments[investment_id]
		
		total_initial += investment.initial_value
		total_current += investment.current_value
		
		if investment.category in category_counts:
			category_counts[investment.category] += 1
		
		if investment.rarity in rarity_counts:
			rarity_counts[investment.rarity] += 1
	
	# Calculate total growth
	if total_initial > 0:
		total_growth = (total_current - total_initial) / total_initial
	
	return {
		"total_initial": total_initial,
		"total_current": total_current,
		"total_growth": total_growth,
		"active_count": active_investments.size(),
		"completed_count": completed_investments.size(),
		"category_distribution": category_counts,
		"rarity_distribution": rarity_counts,
		"current_cycle": current_cycle,
		"auto_next_turn": auto_next_turn,
		"is_paused": is_system_paused
	}

func _on_next_turn_timer():
	# Auto-advance turn when timer expires
	if auto_next_turn and not is_system_paused:
		# Pause briefly before advancing turn
		pause_system(3.0) # Short pause for break
		yield(get_tree().create_timer(3.0), "timeout")
		advance_turn()

func _on_pause_timer():
	# Resume system when pause timer expires
	resume_system()

func _calculate_turn_duration():
	# Calculate duration for current turn based on complexity and progress
	var base_duration = 30.0 # 30 seconds base duration
	var cycle_factor = current_cycle / float(INVESTMENT_CYCLES) # 0.0 to 1.0
	
	# Shorter turns as we progress
	var duration = base_duration * (1.0 - (cycle_factor * 0.5))
	
	# Add randomness
	duration += rand_range(-5.0, 5.0)
	
	# Clamp to valid range
	duration = clamp(duration, MIN_INVESTMENT_PERIOD, MAX_INVESTMENT_PERIOD)
	
	return duration

func _generate_investment_id(word):
	# Generate unique ID for investment
	return "inv_" + word.replace(" ", "_") + "_" + str(OS.get_unix_time())

func _sort_by_value(a, b):
	return a.current_value > b.current_value
