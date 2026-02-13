extends RefCounted
class_name DreamCalculator

const COMMAND_MULTIPLY: String = "mul"
const COMMAND_DIVIDE: String = "div"

func evaluate(raw_command: String) -> Dictionary:
	var normalized := raw_command.strip_edges().replace(" ", "")
	if normalized.is_empty():
		return _error("Empty calculator command")

	# One function per command, comma-separated: operation,a,b
	# Supported operations: mul/div or x/: aliases
	var parts := normalized.split(",", false)
	if parts.size() != 3:
		return _error("Use format: operation,a,b (example: mul,6,7)")

	var operation := _normalize_operation(parts[0])
	if operation.is_empty():
		return _error("Unknown operation '%s'. Use mul/div (or x/:)." % parts[0])

	if not _is_number(parts[1]) or not _is_number(parts[2]):
		return _error("Arguments must be numbers")

	var a := float(parts[1])
	var b := float(parts[2])

	if operation == COMMAND_DIVIDE and is_zero_approx(b):
		return _error("Division by zero")

	var result := a * b if operation == COMMAND_MULTIPLY else a / b
	return {
		"ok": true,
		"operation": operation,
		"a": a,
		"b": b,
		"result": result
	}

func _normalize_operation(operation: String) -> String:
	var op := operation.to_lower()
	match op:
		"mul", "x", "*":
			return COMMAND_MULTIPLY
		"div", ":", "/":
			return COMMAND_DIVIDE
		_:
			return ""

func _is_number(text: String) -> bool:
	return text.is_valid_float() or text.is_valid_int()

func _error(message: String) -> Dictionary:
	return {
		"ok": false,
		"error": message
	}
