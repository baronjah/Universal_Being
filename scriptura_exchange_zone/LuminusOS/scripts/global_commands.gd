extends Node

var commands = {
	"help": "Show available commands",
	"clear": "Clear the terminal",
	"echo": "Display a message",
	"version": "Show version information",
	"exit": "Exit LuminusOS",
	"ls": "List directory contents",
	"bible": "Display a random Bible verse",
	"god": "Acknowledge the divine",
	"color": "Change terminal color",
	"draw": "Simple drawing functions",
	"about": "About LuminusOS"
}

var godot_version = Engine.get_version_info().string
var system_version = "1.0"
var update_available = false

func _ready():
	# Check for updates
	check_for_updates()

func check_for_updates():
	# This would normally connect to a server to check for updates
	# For demonstration purposes, we'll pretend there's no update
	update_available = false
	
func get_command_list():
	return commands

func get_system_info():
	var info = {}
	info["system_name"] = "LuminusOS"
	info["version"] = system_version
	info["godot_version"] = godot_version
	info["update_available"] = update_available
	return info