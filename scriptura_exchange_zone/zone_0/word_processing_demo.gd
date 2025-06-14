extends Node

# Word Processing Demo
# Demonstrates how to use ThreadManager with WordProcessorTasks

# References to our systems
var thread_manager: ThreadManager
var word_processor: WordProcessorTasks
var current_dimension: int = 3  # Start with 4D (Time dimension)
var cosmic_age: int = 1  # Starting cosmic age

# UI elements (for demo purposes)
var input_text_edit: TextEdit
var output_rich_text: RichTextLabel
var dimension_label: Label
var cosmic_age_label: Label
var processing_indicator: ProgressBar

# Text samples for quick testing
const TEXT_SAMPLES = [
	"light dark create destroy divine universe",
	"reality energy power mind spirit soul",
	"time space dimension eternal god life death",
	"order chaos above below open closed good evil"
]

func _ready():
	# Create our systems
	thread_manager = ThreadManager.new()
	word_processor = WordProcessorTasks.new()
	
	# Add systems to the scene tree
	add_child(thread_manager)
	add_child(word_processor)
	
	# Connect signals to handle task completion
	thread_manager.connect("task_completed", Callable(self, "_on_task_completed"))
	thread_manager.connect("task_failed", Callable(self, "_on_task_failed"))
	thread_manager.connect("task_group_completed", Callable(self, "_on_task_group_completed"))
	
	# Get references to UI elements
	input_text_edit = $"%InputTextEdit"
	output_rich_text = $"%OutputRichText"
	dimension_label = $"%DimensionLabel"
	cosmic_age_label = $"%CosmicAgeLabel"
	processing_indicator = $"%ProcessingIndicator"
	
	print("Word Processing Demo initialized")
	print("Thread Manager created with %d threads" % thread_manager.thread_count)
	
	# For demo purposes, let's process a sample text automatically after a short delay
	await get_tree().create_timer(0.5).timeout
	_process_sample_text(0)

# Process text input into words
func process_text(input_text: String) -> void:
	print("Processing text: %s" % input_text)
	
	# Reset any previous results
	if output_rich_text:
		output_rich_text.clear()
		output_rich_text.append_text("Processing...\n")
	
	# Update the progress indicator
	if processing_indicator:
		processing_indicator.value = 10
	
	# First task: Split text into words
	var process_params = {
		"text": input_text,
		"dimension": current_dimension
	}
	
	var task_id = thread_manager.add_task(
		Callable(word_processor, "process_text_input"),
		process_params
	)
	
	print("Text processing task started with ID: %s" % task_id)
	
	# We'll handle the rest in the task completion callback

# Handle task completion
func _on_task_completed(task_id: String, result):
	print("Task completed: %s" % task_id)
	
	# Check what kind of result we got
	if result is Dictionary:
		if result.has("words") and result.has("word_count"):
			# This is the result from process_text_input
			_handle_text_processing_result(result)
		elif result.has("word") and result.has("power"):
			# This is the result from calculate_word_power
			_handle_word_power_result(result)
		elif result.has("word") and result.has("connections"):
			# This is the result from calculate_word_connections
			_handle_word_connections_result(result)
		elif result.has("word") and result.has("physics"):
			# This is the result from calculate_word_physics
			_handle_word_physics_result(result)
		elif result.has("word") and result.has("evolution_stage"):
			# This is the result from calculate_word_evolution
			_handle_word_evolution_result(result)

# Handle text processing result
func _handle_text_processing_result(result: Dictionary) -> void:
	print("Text processed: %d words found" % result.word_count)
	
	if output_rich_text:
		output_rich_text.clear()
		output_rich_text.append_text("Found %d words. Processing...\n\n" % result.word_count)
	
	# Update the progress indicator
	if processing_indicator:
		processing_indicator.value = 25
	
	# Start processing each word
	for word in result.words:
		var word_params = {
			"word": word,
			"dimension": current_dimension,
			"cosmic_age": cosmic_age
		}
		
		# Process word power
		thread_manager.add_task(
			Callable(word_processor, "calculate_word_power"),
			word_params
		)

# Handle word power result
func _handle_word_power_result(result: Dictionary) -> void:
	var word = result.word
	var power = result.power
	var tier = result.tier
	var color = result.color
	
	print("Word power calculated: %s = %.2f (%s)" % [word, power, tier])
	
	# For this demo, we'll just create a formatted output
	if output_rich_text:
		var color_str = "#%s" % color.to_html(false)
		output_rich_text.append_text("[color=%s]%s[/color] (%.2f, %s)\n" % [color_str, word, power, tier])
	
	# Update progress
	if processing_indicator:
		# Increment progress slightly for each word
		var current = processing_indicator.value
		processing_indicator.value = min(current + 5, 90)
	
	# Now let's also calculate physics for this word
	var physics_params = {
		"word_data": result,
		"dimension": current_dimension
	}
	
	thread_manager.add_task(
		Callable(word_processor, "calculate_word_physics"),
		physics_params
	)
	
	# And calculate evolution for this word
	var evolution_params = {
		"word_data": result,
		"current_stage": 0,
		"dimension": current_dimension,
		"cosmic_age": cosmic_age
	}
	
	thread_manager.add_task(
		Callable(word_processor, "calculate_word_evolution"),
		evolution_params
	)

# Handle word physics result
func _handle_word_physics_result(result: Dictionary) -> void:
	var word = result.word
	var physics = result.physics
	
	print("Physics calculated for word: %s" % word)
	print("- Position: %s" % physics.position)
	print("- Mass: %.2f" % physics.mass)
	
	# In a real app, we would use this to position the word in 3D space

# Handle word connections result
func _handle_word_connections_result(result: Dictionary) -> void:
	var word = result.word
	var connections = result.connections
	
	print("Connections calculated for word: %s" % word)
	print("- Found %d connections" % connections.size())
	
	# In a real app, we would use this to draw connection lines

# Handle word evolution result
func _handle_word_evolution_result(result: Dictionary) -> void:
	var word = result.word
	var power = result.power
	var stage = result.evolution_stage
	var stage_name = result.stage_name
	
	print("Evolution calculated for word: %s" % word)
	print("- Stage: %s (level %d)" % [stage_name, stage])
	print("- New power: %.2f" % power)
	
	# In a real app, we would use this to show the evolution animation

# Handle task failure
func _on_task_failed(task_id: String, error):
	print("Task failed: %s" % task_id)
	print("Error: %s" % error)
	
	# Update UI to show the error
	output_rich_text.append_text("[color=red]Error processing text: %s[/color]\n" % error)

# Handle task group completion
func _on_task_group_completed(group_id: String):
	print("Task group completed: %s" % group_id)
	
	# Update UI to show completion
	if output_rich_text:
		output_rich_text.append_text("\n[All processing complete]\n")
	
	# Reset progress indicator
	if processing_indicator:
		processing_indicator.value = 100
		
		# Reset to 0 after a short delay
		var timer = get_tree().create_timer(1.0)
		await timer.timeout
		processing_indicator.value = 0

# Process one of our sample texts
func _process_sample_text(index: int) -> void:
	var sample_text = TEXT_SAMPLES[index % TEXT_SAMPLES.size()]
	process_text(sample_text)

# Change the current dimension
func change_dimension(new_dimension: int) -> void:
	current_dimension = new_dimension
	print("Dimension changed to %d" % current_dimension)
	
	if dimension_label:
		dimension_label.text = "Dimension: %d" % (current_dimension + 1)

# Change the cosmic age
func change_cosmic_age(new_age: int) -> void:
	cosmic_age = new_age
	print("Cosmic age changed to %d" % cosmic_age)
	
	if cosmic_age_label:
		cosmic_age_label.text = "Cosmic Age: %d" % cosmic_age

# Demo function to run a batch of word power calculations
func run_word_power_batch() -> void:
	print("Running batch word power calculations")
	
	var words = ["light", "dark", "fire", "water", "earth", "air", "spirit", "mind", "soul", "body"]
	var param_array = []
	
	for word in words:
		param_array.append({
			"word": word,
			"dimension": current_dimension,
			"cosmic_age": cosmic_age
		})
	
	var task_ids = thread_manager.add_batch_tasks(
		Callable(word_processor, "calculate_word_power"),
		param_array,
		"word_power_batch"
	)
	
	print("Batch started with %d tasks" % task_ids.size())

# Get current thread manager statistics
func get_thread_stats() -> String:
	var stats = thread_manager.get_statistics()
	
	var stats_text = "Thread Manager Stats:\n"
	stats_text += "- Threads: %d/%d available\n" % [stats.available_threads, stats.thread_count]
	stats_text += "- Tasks Processed: %d\n" % stats.tasks_processed
	stats_text += "- Failed Tasks: %d\n" % stats.tasks_failed
	stats_text += "- Avg Processing Time: %.2f ms\n" % stats.avg_processing_time
	stats_text += "- Max Processing Time: %.2f ms\n" % stats.max_processing_time
	stats_text += "- Current Queue Size: %d\n" % stats.current_queue_size
	
	return stats_text

# This would be called from UI buttons in a real implementation
func _on_process_button_pressed() -> void:
	if input_text_edit:
		process_text(input_text_edit.text)

func _on_sample_button_pressed(index: int) -> void:
	_process_sample_text(index)

func _on_dimension_changed(value: int) -> void:
	change_dimension(value)

func _on_cosmic_age_changed(value: int) -> void:
	change_cosmic_age(value)

func _on_batch_button_pressed() -> void:
	run_word_power_batch()

func _on_stats_button_pressed() -> void:
	print(get_thread_stats())