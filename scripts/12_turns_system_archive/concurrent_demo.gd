extends Node

# Concurrent Demo - Example implementation showing how to use the concurrent processor 
# with terminal memory system to run 2-3 functions simultaneously

var terminal_memory
var concurrent_processor

func _ready():
	# Create the terminal memory system
	terminal_memory = load("res://12_turns_system/terminal_memory_system.gd").new()
	add_child(terminal_memory)
	
	# Get reference to the concurrent processor
	concurrent_processor = terminal_memory.processor
	
	# Display welcome message
	terminal_memory.add_memory_text("Concurrent Demo Initialized", "system")
	terminal_memory.add_memory_text("This demo shows how to run 2-3 functions concurrently", "system")
	terminal_memory.add_memory_text("Type '#run save,load,display' to run 3 functions at once", "system")
	
	# Set up some example data
	setup_example_data()
	
	# Demonstrate concurrent execution
	demonstrate_concurrent_execution()

# Set up some example data for the demo
func setup_example_data():
	terminal_memory.add_memory_text("[past] This is a memory from the past", "general")
	terminal_memory.add_memory_text("[present] This is a current memory", "general")
	terminal_memory.add_memory_text("[future] This is a potential future memory", "general")
	terminal_memory.process_tdic_entry("[past] First entry in temporal dictionary")
	terminal_memory.process_tdic_entry("[present] Current state in temporal dictionary")
	terminal_memory.process_tdic_entry("[future] Future possibility in temporal dictionary")

# Demonstrate the concurrent execution of functions
func demonstrate_concurrent_execution():
	terminal_memory.add_memory_text("DEMONSTRATION: Running multiple functions concurrently", "system")
	
	# Example 1: Run 3 functions in parallel
	terminal_memory.add_memory_text("Example 1: Running 3 functions in parallel", "system")
	
	var functions = ["display_time", "count_entries", "check_system_status"]
	var args_list = [[], [], []]
	
	concurrent_processor.create_parallel_tasks(
		"demo_parallel", 
		self, 
		functions, 
		args_list
	)
	
	# Example 2: Run functions in a chain (one after another)
	yield(get_tree().create_timer(2.0), "timeout")
	terminal_memory.add_memory_text("Example 2: Running functions in sequence", "system")
	
	var chain_functions = ["prepare_data", "process_data", "finalize_data"]
	var chain_args = [[], [], []]
	
	concurrent_processor.create_task_chain(
		"demo_chain",
		self,
		chain_functions,
		chain_args
	)
	
	# Example 3: Mixed priority tasks
	yield(get_tree().create_timer(4.0), "timeout")
	terminal_memory.add_memory_text("Example 3: Tasks with different priorities", "system")
	
	concurrent_processor.schedule_task(
		"low_priority", 
		self, 
		"long_running_task", 
		["Low priority task"], 
		ConcurrentProcessor.Priority.LOW
	)
	
	concurrent_processor.schedule_task(
		"high_priority", 
		self, 
		"quick_task", 
		["High priority task"], 
		ConcurrentProcessor.Priority.HIGH
	)
	
	concurrent_processor.schedule_task(
		"medium_priority", 
		self, 
		"medium_task", 
		["Medium priority task"], 
		ConcurrentProcessor.Priority.MEDIUM
	)

# Example function: Display current time
func display_time():
	var datetime = OS.get_datetime()
	var time_str = "%02d:%02d:%02d" % [datetime.hour, datetime.minute, datetime.second]
	terminal_memory.add_memory_text("Current time: " + time_str, "system")
	return time_str

# Example function: Count entries in TDIC
func count_entries():
	var past_count = terminal_memory.tdic_entries.past.size()
	var present_count = terminal_memory.tdic_entries.present.size()
	var future_count = terminal_memory.tdic_entries.future.size()
	var total = past_count + present_count + future_count
	
	terminal_memory.add_memory_text("TDIC entry count: %d total (%d past, %d present, %d future)" % 
		[total, past_count, present_count, future_count], "system")
	
	return total

# Example function: Check system status
func check_system_status():
	var status = "Operational"
	terminal_memory.add_memory_text("System status: " + status, "system")
	return status

# Chain example: Step 1 - Prepare data
func prepare_data():
	terminal_memory.add_memory_text("Step 1: Preparing data...", "system")
	yield(get_tree().create_timer(0.5), "timeout")
	return {"status": "prepared", "timestamp": OS.get_unix_time()}

# Chain example: Step 2 - Process data
func process_data():
	terminal_memory.add_memory_text("Step 2: Processing data...", "system")
	yield(get_tree().create_timer(0.5), "timeout")
	return {"status": "processed", "operations": 5}

# Chain example: Step 3 - Finalize data
func finalize_data():
	terminal_memory.add_memory_text("Step 3: Finalizing data...", "system")
	yield(get_tree().create_timer(0.5), "timeout")
	terminal_memory.add_memory_text("Data processing complete!", "system")
	return {"status": "completed", "success": true}

# Priority example: Low priority, long-running task
func long_running_task(message):
	terminal_memory.add_memory_text("Starting: " + message, "system")
	yield(get_tree().create_timer(1.5), "timeout")
	terminal_memory.add_memory_text("Completed: " + message, "system")
	return "Long task completed"

# Priority example: Medium priority task
func medium_task(message):
	terminal_memory.add_memory_text("Starting: " + message, "system")
	yield(get_tree().create_timer(1.0), "timeout")
	terminal_memory.add_memory_text("Completed: " + message, "system")
	return "Medium task completed"

# Priority example: High priority, quick task
func quick_task(message):
	terminal_memory.add_memory_text("Starting: " + message, "system")
	yield(get_tree().create_timer(0.5), "timeout")
	terminal_memory.add_memory_text("Completed: " + message, "system")
	return "Quick task completed"

# Input handling
func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_SPACE:
		# Demonstrate running multiple functions with the '#run' command
		terminal_memory._on_text_entered("#run display_time,count_entries,check_system_status")