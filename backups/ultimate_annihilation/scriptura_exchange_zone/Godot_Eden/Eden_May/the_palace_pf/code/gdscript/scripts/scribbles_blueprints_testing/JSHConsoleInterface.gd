extends RefCounted
class_name JSHConsoleInterface

# Console interface defines standard methods that all console systems should implement

# Core console methods
func register_command(command_name: String, command_data: Dictionary) -> bool:
    push_error("JSHConsoleInterface: register_command() method must be implemented by subclass")
    return false

func unregister_command(command_name: String) -> bool:
    push_error("JSHConsoleInterface: unregister_command() method must be implemented by subclass")
    return false

func execute_command(command_text: String) -> Dictionary:
    push_error("JSHConsoleInterface: execute_command() method must be implemented by subclass")
    return {}

func get_command_list() -> Array:
    push_error("JSHConsoleInterface: get_command_list() method must be implemented by subclass")
    return []

func get_command_help(command_name: String) -> String:
    push_error("JSHConsoleInterface: get_command_help() method must be implemented by subclass")
    return ""

# Console output
func print_line(text: String, color: Color = Color.WHITE) -> void:
    push_error("JSHConsoleInterface: print_line() method must be implemented by subclass")

func print_error(text: String) -> void:
    push_error("JSHConsoleInterface: print_error() method must be implemented by subclass")

func print_warning(text: String) -> void:
    push_error("JSHConsoleInterface: print_warning() method must be implemented by subclass")

func print_success(text: String) -> void:
    push_error("JSHConsoleInterface: print_success() method must be implemented by subclass")

func clear() -> void:
    push_error("JSHConsoleInterface: clear() method must be implemented by subclass")

# Console state
func is_visible() -> bool:
    push_error("JSHConsoleInterface: is_visible() method must be implemented by subclass")
    return false

func set_visible(visible: bool) -> void:
    push_error("JSHConsoleInterface: set_visible() method must be implemented by subclass")

func toggle_visibility() -> void:
    push_error("JSHConsoleInterface: toggle_visibility() method must be implemented by subclass")

# History management
func get_command_history() -> Array:
    push_error("JSHConsoleInterface: get_command_history() method must be implemented by subclass")
    return []

func clear_command_history() -> void:
    push_error("JSHConsoleInterface: clear_command_history() method must be implemented by subclass")

# Autocomplete
func get_autocomplete_suggestions(partial_command: String) -> Array:
    push_error("JSHConsoleInterface: get_autocomplete_suggestions() method must be implemented by subclass")
    return []

# Variables and context
func set_variable(variable_name: String, value) -> void:
    push_error("JSHConsoleInterface: set_variable() method must be implemented by subclass")

func get_variable(variable_name: String):
    push_error("JSHConsoleInterface: get_variable() method must be implemented by subclass")
    return null

func get_all_variables() -> Dictionary:
    push_error("JSHConsoleInterface: get_all_variables() method must be implemented by subclass")
    return {}