extends Node

# A very simple interpreter for LuminusOS Script (.ls files)
# Inspired by TempleOS's HolyC but much more simplified

signal output_text(text)

var current_script = ""
var variables = {}

func execute_script(script_text):
	current_script = script_text
	variables.clear()
	
	# Simple parsing and execution
	var lines = script_text.split("\n")
	var in_function = false
	var current_function = ""
	var function_body = []
	
	for line in lines:
		line = line.strip_edges()
		
		# Skip comments and empty lines
		if line.begins_with("//") or line.strip_edges() == "":
			continue
			
		# Function declaration
		if line.find("func ") != -1 and line.find("{") != -1:
			in_function = true
			current_function = line.substr(line.find("func ") + 5, line.find("(") - line.find("func ") - 5)
			function_body = []
			continue
			
		# End of function
		if in_function and line.strip_edges() == "}":
			in_function = false
			if current_function == "main":
				execute_function_body(function_body)
			continue
			
		# Collect function body
		if in_function:
			function_body.append(line)
			
	return "Script executed."

func execute_function_body(body):
	for line in body:
		line = line.strip_edges()
		
		# Print statement
		if line.begins_with("Print(") and line.ends_with(");"):
			var content = line.substr(6, line.length() - 8)
			
			# Handle string literals
			if content.begins_with("\"") and content.ends_with("\""):
				content = content.substr(1, content.length() - 2)
				emit_signal("output_text", content + "\n")
			
			# Handle variable printing
			elif variables.has(content):
				emit_signal("output_text", str(variables[content]) + "\n")
				
		# Variable assignment
		elif line.find("=") != -1 and not line.find("==") != -1:
			var parts = line.split("=", true, 1)
			var var_name = parts[0].strip_edges()
			var value = parts[1].strip_edges()
			
			# Remove semicolon if present
			if value.ends_with(";"):
				value = value.substr(0, value.length() - 1)
				
			# Store number
			if value.is_valid_int():
				variables[var_name] = int(value)
			elif value.is_valid_float():
				variables[var_name] = float(value)
			# Store string (with quotes removed)
			elif value.begins_with("\"") and value.ends_with("\""):
				variables[var_name] = value.substr(1, value.length() - 2)
			# Store boolean
			elif value == "true":
				variables[var_name] = true
			elif value == "false":
				variables[var_name] = false

func get_help_text():
	return """
LuminusOS Script (.ls) Help:

Basic Syntax:
  // Comment
  func main() {
    // Code goes here
  }

Built-in Functions:
  Print("text");  - Print text to console

Variables:
  x = 10;         - Assign a number
  name = "John";  - Assign a string
  flag = true;    - Assign a boolean
  Print(x);       - Print a variable

Example:
  func main() {
    Print("Hello from LuminusOS!");
    x = 42;
    Print(x);
    return 0;
  }
"""