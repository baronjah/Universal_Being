# project_architecture.gd
# JSH Ethereal Engine Architecture
extends Node

# Core Systems Structure
const CORE_SYSTEMS = {
	"initialization": {
		"order": ["system_check", "timers", "records", "tree"],
		"dependencies": {
			"records": ["system_check"],
			"tree": ["system_check", "records"]
		}
	},
	
	"file_structure": {
		"metadata": ["global_variants", "global_variants_update"],
		"core": ["init_function", "ready_function", "process_delta"],
		"systems": ["system_check", "data_center", "thread_pool"]
	},
	
	"data_flow": {
		"blimps": {
			"timing": true,
			"max_stored": 9,
			"storage_path": "D:/Eden_Backup"
		},
		"archive": {
			"format": "zip",
			"max_file_size": 369 * 1024 * 1024, # 369MB
			"token_tracking": true
		}
	}
}

# File Size Tracking
var file_metrics = {
	"tokens": {},
	"sizes": {},
	"timestamps": {}
}

# System Health Checks  
var system_states = {
	"active": [],
	"pending": [],
	"needs_repair": []
}
