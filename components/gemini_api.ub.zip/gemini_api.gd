# ==================================================
# COMPONENT: Gemini API
# DESCRIPTION: Google Gemini API integration component
# ==================================================

extends Node
class_name GeminiAPIComponent

var api_ready: bool = false

func _ready() -> void:
	name = "GeminiAPIComponent"
	print("🤖 Gemini API Component loaded")

func initialize_component() -> void:
	api_ready = true
	print("🤖 Gemini API initialized")

func get_component_info() -> Dictionary:
	return {"name": "Gemini API", "ready": api_ready}