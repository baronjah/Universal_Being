# ripple_system.gd
extends Node

class_name RippleSystem

# Event queue for processing changes
var event_queue = []
var simulation_speed = 1.0  # Adjustable speed

signal event_processed(event_data)

func _ready():
	$SimulationTimer.wait_time = 0.1  # Base tick rate
	$SimulationTimer.start()

func _process(delta):
	# Optional: Process some events every frame for more fluid updates
	process_immediate_events()

func process_immediate_events():
	# Process high-priority events that can't wait for the timer
	var immediate_events = event_queue.filter(func(event): return event.priority == "immediate")
	for event in immediate_events:
		process_event(event)
		event_queue.erase(event)

func _on_SimulationTimer_timeout():
	# Process a batch of events on each timer tick
	var batch_size = min(10, event_queue.size())  # Process up to 10 events per tick
	
	for i in range(batch_size):
		if event_queue.size() > 0:
			var event = event_queue.pop_front()
			process_event(event)

func add_event(event_type: String, position: Vector2, data: Dictionary, priority: String = "normal"):
	event_queue.append({
		"type": event_type,
		"position": position,
		"data": data,
		"priority": priority,
		"timestamp": Time.get_ticks_msec()
	})
	
	# Sort by priority and timestamp
	event_queue.sort_custom(func(a, b): 
		if a.priority == "immediate" and b.priority != "immediate":
			return true
		elif b.priority == "immediate" and a.priority != "immediate":
			return false
		return a.timestamp < b.timestamp
	)

func process_event(event):
	match event.type:
		"temperature_change":
			process_temperature_change(event)
		"moisture_change":
			process_moisture_change(event)
		"entity_action":
			process_entity_action(event)
		# Add more event types as needed
	
	emit_signal("event_processed", event)

# Example event processors
func process_temperature_change(event):
	var pos = event.position
	var world = get_node("/root/World")  # Reference to your world node
	
	# Apply temperature change
	world.temperature_layer[pos.x][pos.y] += event.data.amount
	
	# Create ripple effects - temperature affects neighboring cells
	for dx in range(-2, 3):
		for dy in range(-2, 3):
			var nx = pos.x + dx
			var ny = pos.y + dy
			if world.is_valid_cell(nx, ny):
				var distance = sqrt(dx*dx + dy*dy)
				if distance > 0:
					var effect = event.data.amount * (1.0 / distance) * 0.5
					
					# Schedule a new event with reduced impact
					if abs(effect) > 0.01:  # Threshold to prevent too small changes
						add_event("temperature_change", Vector2(nx, ny), {
							"amount": effect
						}, "normal")

# Additional event processors would be implemented similarly
func process_moisture_change(event):
	# to implement
	pass
	
func process_entity_action(event):
	# to implement
	pass
