extends Node

# Script to activate the multi-core system
func _ready():
	print("Activating LuminusOS multi-core system...")
	
	# Get the MultiCoreSystem instance
	var multi_core_system = MultiCoreSystem
	
	# Initialize with maximum cores
	multi_core_system.initialize_cores(16)
	
	# Turn on auto-ticking for simulation
	multi_core_system.auto_tick_enabled = true
	multi_core_system.tick_speed = 0.05  # Fast ticking
	
	print("Multi-core system activated with 16 cores")
	print("Auto-tick enabled at 0.05s intervals")
	
	# Create some initial tasks
	var compute_task = {
		"id": 1,
		"type": "compute",
		"operation": "add",
		"operands": [42, 58]
	}
	
	var io_task = {
		"id": 2,
		"type": "io",
		"operation": "read",
		"path": "/system/welcome.txt"
	}
	
	var memory_task = {
		"id": 3,
		"type": "memory",
		"operation": "write",
		"address": "system_status",
		"value": "online"
	}
	
	# Schedule the tasks
	multi_core_system.schedule_task(compute_task)
	multi_core_system.schedule_task(io_task)
	multi_core_system.schedule_task(memory_task)
	
	print("Initial tasks scheduled")
	print("Multi-core system is now running")