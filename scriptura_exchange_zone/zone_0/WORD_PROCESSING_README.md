# Word Processing System for 12 Turns

This document explains how to use the multi-threaded word processing system implemented in the 12 Turns framework.

## Overview

The Word Processing System consists of two main components:

1. **ThreadManager**: Handles multi-threaded task execution across multiple CPU cores
2. **WordProcessorTasks**: Contains word processing functions designed to be run as individual tasks

This architecture allows for efficient parallel processing of words, which is particularly important when dealing with large amounts of text or complex word calculations.

## Key Features

- Multi-threaded word power calculation
- Word connections and relationships
- Physics properties for words in different dimensions
- Word evolution across cosmic ages
- Text input processing and word extraction

## Getting Started

### Initializing the System

```gdscript
# Create a ThreadManager (auto-detects optimal thread count)
var thread_manager = ThreadManager.new()
add_child(thread_manager)

# Create a WordProcessorTasks instance
var word_processor = WordProcessorTasks.new()
add_child(word_processor)

# Connect signals to handle task completion
thread_manager.connect("task_completed", Callable(self, "_on_task_completed"))
thread_manager.connect("task_failed", Callable(self, "_on_task_failed"))
thread_manager.connect("task_group_completed", Callable(self, "_on_task_group_completed"))
```

### Processing a Word

```gdscript
# Create parameters for the word
var params = {
    "word": "divine",
    "dimension": 3,  # 4D - Time dimension
    "cosmic_age": 1
}

# Add the task to the thread manager's queue
var task_id = thread_manager.add_task(
    Callable(word_processor, "calculate_word_power"),
    params
)

# The result will be returned via the task_completed signal
```

### Processing Multiple Words in Parallel

```gdscript
# Create parameters for each word
var param_array = [
    {"word": "light", "dimension": 3, "cosmic_age": 1},
    {"word": "dark", "dimension": 3, "cosmic_age": 1},
    {"word": "create", "dimension": 3, "cosmic_age": 1},
    {"word": "destroy", "dimension": 3, "cosmic_age": 1}
]

# Process all words in parallel
var task_ids = thread_manager.add_batch_tasks(
    Callable(word_processor, "calculate_word_power"),
    param_array,
    "word_batch"  # Optional group ID
)

# All results will be returned via the task_completed signal
# When all words in the group are processed, task_group_completed signal is emitted
```

### Processing Text Input

```gdscript
# Process text input to extract words
var params = {
    "text": "divine light creates eternal universe",
    "dimension": 3
}

var task_id = thread_manager.add_task(
    Callable(word_processor, "process_text_input"),
    params
)

# The result will contain an array of extracted words
```

## Available Word Processing Functions

### calculate_word_power

Calculates the power level of a word, influenced by dimension and cosmic age.

**Parameters:**
- `word` (String): The word to process
- `dimension` (int): The dimension level (0-11)
- `cosmic_age` (int, optional): The cosmic age to apply
- `evolution_stage` (int, optional): The evolution stage of the word

**Returns:**
- Dictionary containing word power information

### calculate_word_connections

Finds connections between a word and existing words.

**Parameters:**
- `word` (String): The word to process
- `existing_words` (Array): Array of existing word objects

**Returns:**
- Dictionary containing connection information

### calculate_word_physics

Calculates physical properties for a word in the specified dimension.

**Parameters:**
- `word_data` (Dictionary): The word data (from calculate_word_power)
- `dimension` (int): The dimension level (0-11)

**Returns:**
- Dictionary containing physics properties

### calculate_word_evolution

Evolves a word to its next stage, increasing its power.

**Parameters:**
- `word_data` (Dictionary): The word data (from calculate_word_power)
- `current_stage` (int): Current evolution stage
- `dimension` (int): The dimension level (0-11)
- `cosmic_age` (int): The cosmic age

**Returns:**
- Dictionary containing evolved word information

### process_text_input

Splits text into individual words for processing.

**Parameters:**
- `text` (String): The text to process
- `dimension` (int): The dimension level (0-11)

**Returns:**
- Dictionary containing extracted words

## Handling Results

Your task completion handlers should process the results as follows:

```gdscript
func _on_task_completed(task_id, result):
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
```

## Examples

See the following files for usage examples:
- `word_processing_demo.gd`: Interactive demo with UI
- `startup_example.gd`: Simple startup example

## ThreadManager Statistics

You can get current statistics from the ThreadManager:

```gdscript
var stats = thread_manager.get_statistics()
print("Tasks processed: %d" % stats.tasks_processed)
print("Available threads: %d/%d" % [stats.available_threads, stats.thread_count])
```

## Advanced Usage

### Task Groups

You can group related tasks together and receive a notification when all tasks in the group complete:

```gdscript
# Add tasks with the same group ID
thread_manager.add_task(callable, params, "my_group")
thread_manager.add_task(callable, params, "my_group")
thread_manager.add_task(callable, params, "my_group")

# Wait for all tasks in the group to complete
thread_manager.wait_for_group("my_group")
# or handle via signal
func _on_task_group_completed(group_id):
    if group_id == "my_group":
        print("All tasks in my_group are complete")
```

### Blocking vs Non-Blocking Result Retrieval

```gdscript
# Blocking (waits for task to complete)
var result = thread_manager.get_task_result(task_id)

# Non-blocking (returns null if not yet complete)
var result = thread_manager.try_get_task_result(task_id)
if result != null:
    # Process result
```

## System Constants

The system uses several constant dictionaries to determine word properties:

- `POWER_TIERS`: Defines power level categories and their visual colors
- `WORD_POWER`: Special power values for important words
- `WORD_OPPOSITES`: Dictionary of word opposites for connection calculations
- `EVOLUTION_STAGES`: Defines the stages and multipliers for word evolution
- `DIMENSION_MULTIPLIERS`: Power multipliers for each dimension

## Performance Considerations

- The ThreadManager automatically uses an optimal number of threads based on CPU cores
- Thread count can be manually specified with `ThreadManager.new(thread_count)`
- For very large text processing, break up tasks into smaller batches
- Use `clear_completed_tasks()` and `clear_completed_groups()` periodically to free memory