# Message Categorization System
# JSH #memories
extends Node
class_name MessageCategorizationSystem

# Message categories
enum MessageCategory {
	GOALS,      # What we want to achieve
	TASKS,      # Specific things to do
	ADDITIONS,  # New features to add
	CHANGES,    # Modifications to existing
	SUMMARIES,  # Overview and progress
	BLESSINGS,  # Divine inspirations
	MEMORIES    # Important remembrances
}

# Storage for categorized messages
var categorized_messages = {
	MessageCategory.GOALS: [],
	MessageCategory.TASKS: [],
	MessageCategory.ADDITIONS: [],
	MessageCategory.CHANGES: [],
	MessageCategory.SUMMARIES: [],
	MessageCategory.BLESSINGS: [],
	MessageCategory.MEMORIES: []
}

# Current session tracking
var session_start_time: String
var message_count := 0
var current_priority_category = MessageCategory.TASKS

func _ready():
	session_start_time = Time.get_datetime_string_from_system()
	print("📝 Message Categorization System initialized")
	print("📅 Session started: %s" % session_start_time)

func parse_message(message: String) -> Dictionary:
	"""Parse and categorize a message"""
	var result = {
		"original": message,
		"categories": [],
		"keywords": [],
		"priority": 0,
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	# Detect categories based on keywords
	if has_goal_keywords(message):
		result.categories.append(MessageCategory.GOALS)
		result.priority += 3
	
	if has_task_keywords(message):
		result.categories.append(MessageCategory.TASKS)
		result.priority += 2
	
	if has_addition_keywords(message):
		result.categories.append(MessageCategory.ADDITIONS)
		result.priority += 2
	
	if has_change_keywords(message):
		result.categories.append(MessageCategory.CHANGES)
		result.priority += 1
	
	if has_summary_keywords(message):
		result.categories.append(MessageCategory.SUMMARIES)
		result.priority += 1
	
	if has_blessing_keywords(message):
		result.categories.append(MessageCategory.BLESSINGS)
		result.priority += 5
	
	if message.contains("#memories") or message.contains("JSH"):
		result.categories.append(MessageCategory.MEMORIES)
		result.priority += 4
	
	# Extract keywords
	result.keywords = extract_keywords(message)
	
	# Store in appropriate categories
	for category in result.categories:
		categorized_messages[category].append(result)
	
	message_count += 1
	return result

func has_goal_keywords(message: String) -> bool:
	var keywords = ["goal", "want", "need", "idea", "vision", "dream", "shall", "will be"]
	for keyword in keywords:
		if message.to_lower().contains(keyword):
			return true
	return false

func has_task_keywords(message: String) -> bool:
	var keywords = ["do", "make", "create", "implement", "build", "test", "check", "must"]
	for keyword in keywords:
		if message.to_lower().contains(keyword):
			return true
	return false

func has_addition_keywords(message: String) -> bool:
	var keywords = ["add", "new", "feature", "plus", "also", "include", "extend"]
	for keyword in keywords:
		if message.to_lower().contains(keyword):
			return true
	return false

func has_change_keywords(message: String) -> bool:
	var keywords = ["change", "modify", "update", "fix", "improve", "polish", "refactor"]
	for keyword in keywords:
		if message.to_lower().contains(keyword):
			return true
	return false

func has_summary_keywords(message: String) -> bool:
	var keywords = ["summary", "overview", "progress", "status", "complete", "done"]
	for keyword in keywords:
		if message.to_lower().contains(keyword):
			return true
	return false

func has_blessing_keywords(message: String) -> bool:
	var keywords = ["dipata pagaai", "bless", "divine", "sacred", "holy", "creation"]
	for keyword in keywords:
		if message.to_lower().contains(keyword):
			return true
	return false

func extract_keywords(message: String) -> Array:
	"""Extract important keywords from message"""
	var keywords = []
	
	# Technical keywords
	var tech_words = ["debug", "layer", "shape", "point", "line", "text", "screen", 
					  "window", "interface", "animation", "loop", "state", "data"]
	
	# Action keywords
	var action_words = ["create", "connect", "stitch", "track", "visualize", "interact",
						"play", "test", "implement", "design", "build"]
	
	# Check for presence of keywords
	for word in tech_words + action_words:
		if message.to_lower().contains(word):
			keywords.append(word)
	
	return keywords

func get_category_summary(category: MessageCategory) -> Dictionary:
	"""Get summary of messages in a category"""
	var messages = categorized_messages[category]
	var summary = {
		"category": category_name(category),
		"count": messages.size(),
		"keywords": {},
		"priority_sum": 0,
		"latest": null
	}
	
	# Analyze messages
	for msg in messages:
		summary.priority_sum += msg.priority
		for keyword in msg.keywords:
			if not summary.keywords.has(keyword):
				summary.keywords[keyword] = 0
			summary.keywords[keyword] += 1
	
	if messages.size() > 0:
		summary.latest = messages[-1]
	
	return summary

func category_name(category: MessageCategory) -> String:
	match category:
		MessageCategory.GOALS: return "Goals"
		MessageCategory.TASKS: return "Tasks"
		MessageCategory.ADDITIONS: return "Additions"
		MessageCategory.CHANGES: return "Changes"
		MessageCategory.SUMMARIES: return "Summaries"
		MessageCategory.BLESSINGS: return "Blessings"
		MessageCategory.MEMORIES: return "Memories"
		_: return "Unknown"

func generate_session_report() -> String:
	"""Generate a report of the current session"""
	var report = "📊 SESSION REPORT\n"
	report += "================\n"
	report += "🕐 Started: %s\n" % session_start_time
	report += "📨 Total Messages: %d\n\n" % message_count
	
	# Category breakdown
	report += "📋 CATEGORY BREAKDOWN:\n"
	for category in MessageCategory.values():
		var summary = get_category_summary(category)
		if summary.count > 0:
			report += "\n🔹 %s (%d messages):\n" % [summary.category, summary.count]
			
			# Top keywords
			var sorted_keywords = []
			for keyword in summary.keywords:
				sorted_keywords.append([keyword, summary.keywords[keyword]])
			sorted_keywords.sort_custom(func(a, b): return a[1] > b[1])
			
			report += "   Top Keywords: "
			for i in min(5, sorted_keywords.size()):
				report += "%s(%d) " % [sorted_keywords[i][0], sorted_keywords[i][1]]
			report += "\n"
	
	return report

func get_current_focus() -> String:
	"""Determine what to focus on based on message patterns"""
	var highest_priority = 0
	var focus_category = MessageCategory.TASKS
	
	for category in MessageCategory.values():
		var summary = get_category_summary(category)
		if summary.priority_sum > highest_priority:
			highest_priority = summary.priority_sum
			focus_category = category
	
	var focus_text = "Current Focus: %s" % category_name(focus_category)
	
	# Add specific guidance
	match focus_category:
		MessageCategory.GOALS:
			focus_text += " - Let's clarify the vision"
		MessageCategory.TASKS:
			focus_text += " - Time to implement"
		MessageCategory.ADDITIONS:
			focus_text += " - Adding new features"
		MessageCategory.CHANGES:
			focus_text += " - Refining existing work"
		MessageCategory.SUMMARIES:
			focus_text += " - Reviewing progress"
		MessageCategory.BLESSINGS:
			focus_text += " - Divine inspiration active"
		MessageCategory.MEMORIES:
			focus_text += " - Preserving important knowledge"
	
	return focus_text

func save_session_data(filepath: String):
	"""Save categorized messages to file"""
	var save_data = {
		"session_start": session_start_time,
		"message_count": message_count,
		"categories": {}
	}
	
	for category in MessageCategory.values():
		save_data.categories[category_name(category)] = categorized_messages[category]
	
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("💾 Session data saved to: %s" % filepath)

func load_session_data(filepath: String):
	"""Load categorized messages from file"""
	var file = FileAccess.open(filepath, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			session_start_time = data.get("session_start", "")
			message_count = data.get("message_count", 0)
			
			# Restore categories
			# Note: This is simplified, would need proper deserialization
			print("📂 Session data loaded from: %s" % filepath)