extends Node

# This script demonstrates how to initialize and use the ThreadManager and WordProcessorTasks
# in the 12 Turns System

# References
var thread_manager: ThreadManager
var word_processor: WordProcessorTasks

func _ready():
	print("Starting 12 Turns System initialization...")
	
	# Initialize ThreadManager with auto thread count
	thread_manager = ThreadManager.new()
	add_child(thread_manager)
	
	# Initialize WordProcessorTasks
	word_processor = WordProcessorTasks.new()
	add_child(word_processor)
	
	# Connect signals to handle task completion
	thread_manager.connect("task_completed", Callable(self, "_on_task_completed"))
	thread_manager.connect("task_failed", Callable(self, "_on_task_failed"))
	thread_manager.connect("task_group_completed", Callable(self, "_on_task_group_completed"))
	
	print("12 Turns System initialized with %d threads" % thread_manager.thread_count)
	
	# Example: Process a batch of words
	_run_example_batch()

# Example function demonstrating batch word processing
func _run_example_batch():
	print("\nRunning example batch processing...")
	
	var words = ["divine", "light", "create", "universe", "eternal"]
	var params_array = []
	
	# Create parameter dictionaries for each word
	for word in words:
		params_array.append({
			"word": word,
			"dimension": 3,  # 4D - Time dimension
			"cosmic_age": 1
		})
	
	# Process words in parallel using the thread manager
	var task_ids = thread_manager.add_batch_tasks(
		Callable(word_processor, "calculate_word_power"),
		params_array,
		"example_batch"
	)
	
	print("Batch started with %d tasks" % task_ids.size())
	print("Processing words: %s" % words)

# Task completion handlers
func _on_task_completed(task_id, result):
	if result is Dictionary and result.has("word") and result.has("power"):
		# This is a word power calculation result
		var word = result.word
		var power = result.power
		var tier = result.tier
		
		print("Word processed: %s = %.2f power (%s tier)" % [word, power, tier])
	
func _on_task_failed(task_id, error):
	print("Task %s failed with error: %s" % [task_id, error])

func _on_task_group_completed(group_id):
	if group_id == "example_batch":
		print("\nAll words in example batch have been processed")
		print("Thread statistics: %s" % thread_manager.get_statistics())
		print("\nThe ThreadManager and WordProcessorTasks are now ready for use in your game!")