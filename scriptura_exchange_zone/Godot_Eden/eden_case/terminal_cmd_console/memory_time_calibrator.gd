extends Node

class_name MemoryTimeCalibrator

# Time tracking
var calibration_start_time = 0
var calibration_points = []
var merge_history = []
var split_history = []

# Memory configuration
var memory_fragments = {}
var truth_anchors = {}
var story_threads = {}

# Calibration settings
var calibration_interval = 120 # seconds
var truth_threshold = 0.75
var merge_threshold = 0.60
var split_threshold = 0.30

# Game story integration
var active_story_elements = []
var potential_story_branches = []
var dimension_influence = {}

# System connections
var word_system
var quest_system
var trajectory_tracker

func _ready():
	initialize_systems()
	start_calibration()
	
func initialize_systems():
	if has_node("/root/WorldOfWords"):
		word_system = get_node("/root/WorldOfWords")
		
	if has_node("/root/WordQuestCreator"):
		quest_system = get_node("/root/WordQuestCreator")
		
	if has_node("/root/MemoryTrajectoryTracker"):
		trajectory_tracker = get_node("/root/MemoryTrajectoryTracker")
	
	# Create timer for auto-calibration
	var timer = Timer.new()
	timer.wait_time = calibration_interval
	timer.autostart = true
	timer.connect("timeout", self, "perform_calibration")
	add_child(timer)

func start_calibration():
	calibration_start_time = OS.get_unix_time()
	print("Memory time calibration started at: " + str(calibration_start_time))
	add_calibration_point("GENESIS", 1.0)

# Memory fragment management
func create_memory_fragment(content, source, truth_value=0.5):
	var fragment_id = "frag_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
	
	memory_fragments[fragment_id] = {
		"id": fragment_id,
		"content": content,
		"source": source,
		"created_at": OS.get_unix_time(),
		"truth_value": truth_value,
		"connections": [],
		"calibration_point": get_latest_calibration_point(),
		"dimension": get_current_dimension(),
		"split_from": null,
		"merged_with": []
	}
	
	# If truth value is high enough, create a truth anchor
	if truth_value >= truth_threshold:
		create_truth_anchor(fragment_id)
	
	return fragment_id

func create_truth_anchor(fragment_id):
	if not memory_fragments.has(fragment_id):
		return null
		
	var anchor_id = "anchor_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
	
	truth_anchors[anchor_id] = {
		"id": anchor_id,
		"fragment_id": fragment_id,
		"created_at": OS.get_unix_time(),
		"stability": memory_fragments[fragment_id].truth_value,
		"reality_influence": calculate_reality_influence(memory_fragments[fragment_id]),
		"dimension": memory_fragments[fragment_id].dimension
	}
	
	# Connect fragment to anchor
	memory_fragments[fragment_id].anchor_id = anchor_id
	
	return anchor_id

func get_current_dimension():
	# Try to get from trajectory tracker first
	if trajectory_tracker:
		return trajectory_tracker.get_current_dimension()
	
	# Fallback to quest system
	if quest_system:
		return quest_system.get_current_dimension()
		
	# Default
	return "GENESIS"

# Calibration management
func add_calibration_point(dimension, stability):
	var point = {
		"time": OS.get_unix_time(),
		"dimension": dimension,
		"stability": stability,
		"memory_count": memory_fragments.size(),
		"truth_anchors": truth_anchors.size(),
		"story_elements": active_story_elements.size()
	}
	
	calibration_points.append(point)
	
	if calibration_points.size() > 12:
		calibration_points.remove(0) # Keep only the last 12 points
		
	return point

func get_latest_calibration_point():
	if calibration_points.size() > 0:
		return calibration_points[calibration_points.size() - 1]
	return null

func perform_calibration():
	# Get current time and calculate elapsed time
	var current_time = OS.get_unix_time()
	var elapsed = current_time - calibration_start_time
	
	# Calculate overall system stability
	var stability = calculate_system_stability()
	
	# Determine if we need to split or merge
	if stability < split_threshold:
		perform_split_operation()
	elif stability > merge_threshold:
		perform_merge_operation()
	
	# Add new calibration point
	add_calibration_point(get_current_dimension(), stability)
	
	# Update story integration
	update_story_elements()
	
	print("Memory calibration performed. Stability: " + str(stability))
	return stability

func calculate_system_stability():
	# Start with base stability
	var stability = 0.5
	
	# Factor 1: Truth anchor ratio
	if memory_fragments.size() > 0:
		var anchor_ratio = float(truth_anchors.size()) / memory_fragments.size()
		stability += anchor_ratio * 0.2
	
	# Factor 2: Recent merge/split balance
	var recent_merges = count_recent_operations(merge_history, 300) # Last 5 minutes
	var recent_splits = count_recent_operations(split_history, 300)
	var operation_balance = 0.0
	
	if recent_merges + recent_splits > 0:
		operation_balance = float(recent_merges - recent_splits) / (recent_merges + recent_splits)
		stability += operation_balance * 0.1
	
	# Factor 3: Dimensional influence
	var dimension = get_current_dimension()
	if dimension_influence.has(dimension):
		stability += dimension_influence[dimension] * 0.2
	
	# Clamp final value
	return clamp(stability, 0.0, 1.0)

func count_recent_operations(history, time_window):
	var current_time = OS.get_unix_time()
	var count = 0
	
	for operation in history:
		if current_time - operation.time <= time_window:
			count += 1
			
	return count

func calculate_reality_influence(fragment):
	# Base influence
	var influence = fragment.truth_value * 0.5
	
	# Connection bonus
	influence += min(fragment.connections.size() * 0.05, 0.3)
	
	# Dimension factor
	var dimension_factor = 0.1
	if dimension_influence.has(fragment.dimension):
		dimension_factor = dimension_influence[fragment.dimension]
	
	influence += dimension_factor
	
	return clamp(influence, 0.0, 1.0)

# Split and merge operations
func perform_split_operation():
	# Find fragments to split (ones with multiple potential interpretations)
	var candidates = []
	
	for fragment_id in memory_fragments:
		var fragment = memory_fragments[fragment_id]
		
		# Only consider fragments without previous splits
		if fragment.split_from == null and fragment.connections.size() >= 2:
			candidates.append(fragment_id)
	
	if candidates.size() == 0:
		return false
	
	# Choose a random candidate
	var target_id = candidates[randi() % candidates.size()]
	var target = memory_fragments[target_id]
	
	# Create split fragments
	var splits = []
	var split_count = min(target.connections.size(), 3) # At most 3 splits
	
	for i in range(split_count):
		var content = target.content
		if target.content.length() > 10:
			# Take a substring to represent different interpretations
			var start = randi() % (target.content.length() - 10)
			content = target.content.substr(start, min(20, target.content.length() - start))
		
		var split_id = create_memory_fragment(content, "split", target.truth_value * 0.8)
		memory_fragments[split_id].split_from = target_id
		
		# Connect to a subset of the original connections
		if target.connections.size() > 0:
			var connection = target.connections[i % target.connections.size()]
			memory_fragments[split_id].connections.append(connection)
		
		splits.append(split_id)
	
	# Record the split operation
	split_history.append({
		"time": OS.get_unix_time(),
		"source": target_id,
		"results": splits,
		"dimension": get_current_dimension()
	})
	
	return true

func perform_merge_operation():
	# Find pairs of fragments that could be merged
	var candidates = []
	
	# Simple approach: look for fragments with connections to each other
	for id1 in memory_fragments:
		for id2 in memory_fragments:
			if id1 != id2:
				var fragment1 = memory_fragments[id1]
				var fragment2 = memory_fragments[id2]
				
				# Check if they're connected to each other
				if fragment1.connections.has(id2) or fragment2.connections.has(id1):
					# Check they're not already merged
					if not fragment1.merged_with.has(id2) and not fragment2.merged_with.has(id1):
						candidates.append([id1, id2])
	
	if candidates.size() == 0:
		return false
	
	# Choose a random candidate pair
	var pair = candidates[randi() % candidates.size()]
	var fragment1 = memory_fragments[pair[0]]
	var fragment2 = memory_fragments[pair[1]]
	
	# Create merged fragment
	var merged_content = fragment1.content + " " + fragment2.content
	var merged_truth = (fragment1.truth_value + fragment2.truth_value) / 2.0
	
	var merged_id = create_memory_fragment(merged_content, "merge", merged_truth)
	
	# Connect the merged fragment to all connections of the source fragments
	for conn in fragment1.connections:
		if not memory_fragments[merged_id].connections.has(conn):
			memory_fragments[merged_id].connections.append(conn)
			
	for conn in fragment2.connections:
		if not memory_fragments[merged_id].connections.has(conn):
			memory_fragments[merged_id].connections.append(conn)
	
	# Record merge history in all involved fragments
	memory_fragments[merged_id].merged_with = [pair[0], pair[1]]
	memory_fragments[pair[0]].merged_with.append(pair[1])
	memory_fragments[pair[1]].merged_with.append(pair[0])
	
	# Record the merge operation
	merge_history.append({
		"time": OS.get_unix_time(),
		"sources": [pair[0], pair[1]],
		"result": merged_id,
		"dimension": get_current_dimension()
	})
	
	return true

# Story Integration
func create_story_element(name, description, importance=0.5):
	var element = {
		"id": "story_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000),
		"name": name,
		"description": description,
		"created_at": OS.get_unix_time(),
		"importance": importance,
		"dimension": get_current_dimension(),
		"truth_anchors": [],
		"memory_fragments": [],
		"quest_potential": calculate_quest_potential(name, description)
	}
	
	active_story_elements.append(element)
	
	# Create a memory fragment for this story element
	var fragment_id = create_memory_fragment(description, "story", importance)
	element.memory_fragments.append(fragment_id)
	
	# If element is important enough, create a truth anchor
	if importance >= truth_threshold:
		var anchor_id = create_truth_anchor(fragment_id)
		if anchor_id:
			element.truth_anchors.append(anchor_id)
	
	# Check if it should become a quest
	if quest_system and element.quest_potential >= 0.7:
		create_story_quest(element)
		
	return element

func calculate_quest_potential(name, description):
	# Simple heuristic based on name and description
	var potential = 0.4 # Base value
	
	# Keywords that suggest quest potential
	var quest_keywords = ["find", "discover", "collect", "defeat", "rescue", "craft", "build", "explore"]
	
	for keyword in quest_keywords:
		if name.to_lower().find(keyword) >= 0 or description.to_lower().find(keyword) >= 0:
			potential += 0.1
			
	# Length bonus (detailed descriptions have higher potential)
	potential += min(description.length() / 100.0, 0.3)
	
	return clamp(potential, 0.0, 1.0)

func create_story_quest(story_element):
	if not quest_system:
		return null
		
	var quest_type = "word_discovery" # Default type
	var objective = story_element.description
	
	# Try to detect better quest type
	if objective.to_lower().find("collect") >= 0 or objective.to_lower().find("find") >= 0:
		quest_type = "word_collection"
	elif objective.to_lower().find("combine") >= 0 or objective.to_lower().find("craft") >= 0:
		quest_type = "word_combination"
	elif objective.to_lower().find("transform") >= 0 or objective.to_lower().find("change") >= 0:
		quest_type = "word_transformation"
		
	var quest_id = quest_system.create_quest(story_element.name, quest_type, objective, "reality_fragment")
	
	return quest_id

func update_story_elements():
	# Updates story elements based on recent memory calibration
	var current_dimension = get_current_dimension()
	
	# First, check if we need to evolve any story elements
	var stability = calculate_system_stability()
	if stability >= 0.8 and randf() <= 0.3:
		evolve_random_story_element()
		
	# Then, check if we should create a branch
	if stability < 0.4 and randf() <= 0.4:
		create_story_branch()
		
	# Update dimension influence
	if not dimension_influence.has(current_dimension):
		dimension_influence[current_dimension] = 0.5
	else:
		# Slightly adjust dimension influence based on stability
		var influence = dimension_influence[current_dimension]
		influence = lerp(influence, stability, 0.2)
		dimension_influence[current_dimension] = clamp(influence, 0.1, 0.9)

func evolve_random_story_element():
	if active_story_elements.size() == 0:
		return null
		
	# Choose a random element
	var index = randi() % active_story_elements.size()
	var element = active_story_elements[index]
	
	# Create an evolved version with higher importance
	var evolved_name = element.name + " (Evolved)"
	var evolved_description = element.description + "\n\nThis story has evolved through calibration in the " + get_current_dimension() + " dimension."
	
	var evolved = create_story_element(evolved_name, evolved_description, min(element.importance * 1.2, 1.0))
	
	# Connect to the original
	for fragment_id in element.memory_fragments:
		if memory_fragments.has(fragment_id) and not evolved.memory_fragments.has(fragment_id):
			memory_fragments[evolved.memory_fragments[0]].connections.append(fragment_id)
	
	return evolved

func create_story_branch():
	if active_story_elements.size() == 0:
		return null
		
	# Choose a random element to branch from
	var index = randi() % active_story_elements.size()
	var element = active_story_elements[index]
	
	# Create a branched version with slightly different details
	var branch_name = "Alt: " + element.name
	var branch_description = "Alternative reality branch of: " + element.description
	
	var branch = create_story_element(branch_name, branch_description, element.importance * 0.8)
	
	# Add to potential branches
	potential_story_branches.append({
		"original": element.id,
		"branch": branch.id,
		"created_at": OS.get_unix_time(),
		"dimension": get_current_dimension()
	})
	
	return branch

# Time calibration utilities
func get_elapsed_time():
	return OS.get_unix_time() - calibration_start_time

func get_time_based_stability():
	var elapsed = get_elapsed_time()
	
	# Example: stability decreases the longer the system runs without calibration
	var last_calibration = 0
	if calibration_points.size() > 0:
		last_calibration = calibration_points[calibration_points.size() - 1].time
		
	var time_since_calibration = OS.get_unix_time() - last_calibration
	
	# Decrease stability as time passes
	var time_stability = 1.0 - min(time_since_calibration / 600.0, 0.5) # Max 50% reduction after 10 minutes
	
	return time_stability

# External interface methods
func get_merged_story():
	# Creates a merged storyline from all active story elements
	var story = "# The Calibrated Story\n\n"
	
	# Sort elements by importance
	var sorted_elements = active_story_elements.duplicate()
	sorted_elements.sort_custom(self, "sort_by_importance")
	
	for element in sorted_elements:
		story += "## " + element.name + "\n\n"
		story += element.description + "\n\n"
		
		# Add truth anchors if any
		if element.truth_anchors.size() > 0:
			story += "Truth anchors: " + str(element.truth_anchors.size()) + "\n\n"
			
	# Add calibration information
	story += "## Calibration Information\n\n"
	story += "Calibration points: " + str(calibration_points.size()) + "\n"
	story += "Current dimension: " + get_current_dimension() + "\n"
	story += "System stability: " + str(calculate_system_stability()) + "\n"
	
	return story

func sort_by_importance(a, b):
	return a.importance > b.importance

func get_dimension_story(dimension):
	# Creates a storyline specific to the given dimension
	var story = "# Story of " + dimension + " Dimension\n\n"
	
	# Find all elements from this dimension
	var dimension_elements = []
	for element in active_story_elements:
		if element.dimension == dimension:
			dimension_elements.append(element)
	
	if dimension_elements.size() == 0:
		story += "No story elements exist in this dimension yet.\n"
		return story
		
	# Sort by creation time
	dimension_elements.sort_custom(self, "sort_by_creation")
	
	for element in dimension_elements:
		story += "## " + element.name + "\n\n"
		story += element.description + "\n\n"
		
	return story

func sort_by_creation(a, b):
	return a.created_at < b.created_at

# Process memory input (for parsing commands and creating memory fragments)
func process_memory_input(input):
	# Check for commands indicated by special patterns
	if input.begins_with("##"):
		# Command format
		return process_command(input.substr(2).strip_edges())
	elif input.find("#") >= 0:
		# Memory with marker
		return process_memory_with_markers(input)
	else:
		# Regular memory
		var fragment_id = create_memory_fragment(input, "user", 0.6)
		return "Memory fragment created: " + fragment_id
		
func process_command(command):
	var parts = command.split(" ", false)
	
	if parts.size() == 0:
		return "Invalid command"
	
	match parts[0].to_lower():
		"calibrate":
			var stability = perform_calibration()
			return "Calibration performed. System stability: " + str(stability)
			
		"story":
			if parts.size() >= 2 and parts[1].to_lower() == "create":
				if parts.size() < 4:
					return "Usage: ## story create <name> <description>"
				
				var name = parts[2]
				var description = command.substr(command.find(name) + name.length()).strip_edges()
				
				var element = create_story_element(name, description)
				return "Story element created: " + element.name
				
			else:
				return get_merged_story()
				
		"dimension":
			if parts.size() >= 2:
				return get_dimension_story(parts[1].to_upper())
			else:
				return "Current dimension: " + get_current_dimension()
				
		"merge":
			if perform_merge_operation():
				return "Merge operation successful"
			else:
				return "No suitable fragments found for merging"
				
		"split":
			if perform_split_operation():
				return "Split operation successful"
			else:
				return "No suitable fragments found for splitting"
				
		"status":
			return get_status_report()
			
		"help":
			return """
MEMORY TIME CALIBRATOR - COMMANDS

## calibrate - Perform manual time calibration
## story - Get the merged storyline
## story create <name> <description> - Create a new story element
## dimension [name] - Get story for specific dimension
## merge - Force a merge operation
## split - Force a split operation
## status - Get system status report
## help - Show this help text
"""
		_:
			return "Unknown command: " + parts[0]

func process_memory_with_markers(input):
	# Extract the markers and content
	var markers = []
	var content = input
	
	var pos = 0
	while (pos = content.find("#", pos)) >= 0:
		var marker_end = pos
		while marker_end < content.length() and content[marker_end] == "#":
			marker_end += 1
			
		var marker = content.substr(pos, marker_end - pos)
		markers.append(marker)
		
		pos = marker_end
	
	# Clean up content by removing markers
	for marker in markers:
		content = content.replace(marker, "")
	
	content = content.strip_edges()
	
	# Create the memory fragment
	var fragment_id = create_memory_fragment(content, "user_marked", 0.7)
	
	# Special handling based on marker count
	if markers.size() > 0:
		var fragment = memory_fragments[fragment_id]
		
		# More markers = higher truth value
		fragment.truth_value = min(0.5 + markers.size() * 0.1, 1.0)
		
		# Multiple markers may trigger truth anchor creation
		if fragment.truth_value >= truth_threshold and not fragment.has("anchor_id"):
			create_truth_anchor(fragment_id)
	
	return "Marked memory created with " + str(markers.size()) + " markers: " + fragment_id

func get_status_report():
	var report = "MEMORY TIME CALIBRATOR STATUS\n\n"
	
	report += "System running for: " + str(get_elapsed_time()) + " seconds\n"
	report += "Calibration points: " + str(calibration_points.size()) + "\n"
	report += "Current dimension: " + get_current_dimension() + "\n"
	report += "System stability: " + str(calculate_system_stability()) + "\n\n"
	
	report += "Memory fragments: " + str(memory_fragments.size()) + "\n"
	report += "Truth anchors: " + str(truth_anchors.size()) + "\n"
	report += "Story elements: " + str(active_story_elements.size()) + "\n"
	report += "Merge operations: " + str(merge_history.size()) + "\n"
	report += "Split operations: " + str(split_history.size()) + "\n\n"
	
	report += "Dimension influences:\n"
	for dim in dimension_influence:
		report += "- " + dim + ": " + str(dimension_influence[dim]) + "\n"
	
	return report