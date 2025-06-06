# ==================================================
# COMPONENT: Desktop Bridge
# DESCRIPTION: Bridge component for Claude Desktop integration
# ==================================================

extends Node
#class_name DesktopBridgeComponent # Commented to avoid duplicate

# Component properties
var bridge_ready: bool = false
var bridge_status: String = "disconnected"

func _ready() -> void:
	name = "DesktopBridgeComponent"
	print("🌉 Desktop Bridge Component loaded")

func initialize_component() -> void:
	"""Initialize desktop bridge component"""
	bridge_ready = true
	bridge_status = "ready"
	print("🌉 Desktop Bridge initialized")

func get_component_info() -> Dictionary:
	"""Get component information"""
	return {
		"name": "Desktop Bridge",
		"status": bridge_status,
		"ready": bridge_ready
	}