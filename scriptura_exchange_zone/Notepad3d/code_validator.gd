extends Node

class_name CodeValidator

# ----- CONFIGURATION -----
@export var auto_initialize: bool = true
@export var enable_gdscript_validation: bool = true
@export var enable_python_validation: bool = true
@export var enable_javascript_validation: bool = true
@export var validation_timeout: float = 10.0  # seconds
@export var max_file_size_kb: int = 1024  # 1MB

# ----- VALIDATION RULES -----
@export_group("GDScript Rules")
@export var gdscript_check_syntax: bool = true
@export var gdscript_check_naming: bool = true
@export var gdscript_check_structure: bool = true
@export var gdscript_max_line_length: int = 100
@export var gdscript_max_function_lines: int = 50
@export var gdscript_required_sections: Array[String] = [
    "# ----- VARIABLES -----",
    "# ----- INITIALIZATION -----",
    "func _ready"
]

@export_group("Python Rules")
@export var python_check_syntax: bool = true
@export var python_check_pep8: bool = true
@export var python_check_imports: bool = true
@export var python_max_line_length: int = 79
@export var python_max_function_lines: int = 50
@export var python_style_guide: String = "PEP 8"

@export_group("JavaScript Rules")
@export var js_check_syntax: bool = true
@export var js_check_standards: bool = true
@export var js_check_es_version: bool = true
@export var js_max_line_length: int = 80
@export var js_max_function_lines: int = 40
@export var js_style_guide: String = "Standard"

# ----- EXTERNAL TOOLS -----
@export_group("External Tools")
@export var gdscript_parser_path: String = "res://addons/gdscript_parser.gd"
@export var python_executable: String = "python3"
@export var eslint_executable: String = "npx eslint"
@export var use_external_tools: bool = true

# ----- COMPONENT CONNECTIONS -----
@export_node_path var file_tracker_path: NodePath
@export_node_path var terminal_system_path: NodePath

# ----- STATE VARIABLES -----
var file_tracker = null
var terminal_system = null
var validation_queue = []
var current_validation = null
var validation_in_progress = false
var validation_results = {}
var validation_start_time = 0
var validation_history = []

# ----- PATTERNS -----
# GDScript patterns
var gdscript_patterns = {
    "class_definition": "^class_name\\s+([A-Za-z0-9_]+)\\s*(?:extends\\s+([A-Za-z0-9_]+))?",
    "function_definition": "^func\\s+([A-Za-z0-9_]+)\\s*\\(",
    "variable_definition": "^(?:var|const|export|onready var)\\s+([A-Za-z0-9_]+)\\s*(?::\\s*([A-Za-z0-9_]+))?\\s*=",
    "signal_definition": "^signal\\s+([A-Za-z0-9_]+)",
    "enum_definition": "^enum\\s+([A-Za-z0-9_]+)",
    "extends_statement": "^extends\\s+([A-Za-z0-9_]+)"
}

# Python patterns
var python_patterns = {
    "class_definition": "^class\\s+([A-Za-z0-9_]+)\\s*(?:\\(([A-Za-z0-9_, ]+)\\))?:",
    "function_definition": "^def\\s+([A-Za-z0-9_]+)\\s*\\(",
    "import_statement": "^(?:import|from)\\s+([A-Za-z0-9_.]+)",
    "variable_assignment": "^([A-Za-z0-9_]+)\\s*=",
    "decorated_function": "^@([A-Za-z0-9_.]+)"
}

# JavaScript patterns
var js_patterns = {
    "function_definition": "function\\s+([A-Za-z0-9_$]+)\\s*\\(",
    "arrow_function": "(?:const|let|var)\\s+([A-Za-z0-9_$]+)\\s*=\\s*\\([^)]*\\)\\s*=>",
    "class_definition": "class\\s+([A-Za-z0-9_$]+)",
    "import_statement": "import\\s+(?:{[^}]*}|[A-Za-z0-9_$]+)\\s+from",
    "export_statement": "export\\s+(?:default\\s+)?(?:const|let|var|function|class)",
    "variable_declaration": "(?:const|let|var)\\s+([A-Za-z0-9_$]+)"
}

# ----- SIGNALS -----
signal validation_completed(file_path, result)
signal syntax_error_found(file_path, line, message)
signal style_issue_found(file_path, line, rule, message)
signal validation_stats_updated(stats)
signal batch_validation_completed(files_processed)

# ----- INITIALIZATION -----
func _ready():
    if auto_initialize:
        initialize()

func initialize():
    print("CodeValidator: Initializing...")
    
    # Connect to file tracker if available
    _connect_systems()
    
    # Initialize validation history
    validation_history = []
    
    print("CodeValidator: Initialized")
    print("- GDScript validation: ", "Enabled" if enable_gdscript_validation else "Disabled")
    print("- Python validation: ", "Enabled" if enable_python_validation else "Disabled")
    print("- JavaScript validation: ", "Enabled" if enable_javascript_validation else "Disabled")

# ----- SYSTEM CONNECTIONS -----
func _connect_systems():
    # Connect to File Tracker if path provided
    if file_tracker_path:
        file_tracker = get_node_or_null(file_tracker_path)
    
    if not file_tracker:
        # Try to find by class name or in specific paths
        file_tracker = get_node_or_null("/root/UnifiedFileTracker")
        if not file_tracker:
            var potential_nodes = get_tree().get_nodes_in_group("file_tracker")
            if potential_nodes.size() > 0:
                file_tracker = potential_nodes[0]
    
    # Connect to Terminal system if path provided
    if terminal_system_path:
        terminal_system = get_node_or_null(terminal_system_path)
    
    if not terminal_system:
        # Try to find by class name or in specific paths
        terminal_system = get_node_or_null("/root/TerminalSystem")
        if not terminal_system:
            var potential_nodes = get_tree().get_nodes_in_group("terminal_system")
            if potential_nodes.size() > 0:
                terminal_system = potential_nodes[0]
    
    # Connect signals from file tracker
    if file_tracker and file_tracker.has_signal("file_changed"):
        file_tracker.connect("file_changed", Callable(self, "_on_file_changed"))
    
    print("CodeValidator: System connections:")
    print("- File Tracker: ", "Connected" if file_tracker else "Not found")
    print("- Terminal System: ", "Connected" if terminal_system else "Not found")

# ----- VALIDATION LOGIC -----
func _process(delta):
    # Process validation queue
    if not validation_in_progress and validation_queue.size() > 0:
        _start_next_validation()
    
    # Check for validation timeout
    if validation_in_progress and Time.get_unix_time_from_system() - validation_start_time > validation_timeout:
        _handle_validation_timeout()

func _start_next_validation():
    if validation_queue.size() == 0:
        return
    
    current_validation = validation_queue.pop_front()
    validation_in_progress = true
    validation_start_time = Time.get_unix_time_from_system()
    
    # Check file exists and has valid extension
    if not FileAccess.file_exists(current_validation.file_path):
        _complete_validation({"success": false, "error": "File not found", "file_path": current_validation.file_path})
        return
    
    var extension = current_validation.file_path.get_extension().to_lower()
    
    # Validate based on file type
    match extension:
        "gd":
            if enable_gdscript_validation:
                _validate_gdscript(current_validation.file_path)
            else:
                _complete_validation({"success": false, "error": "GDScript validation disabled", "file_path": current_validation.file_path})
        "py":
            if enable_python_validation:
                _validate_python(current_validation.file_path)
            else:
                _complete_validation({"success": false, "error": "Python validation disabled", "file_path": current_validation.file_path})
        "js":
            if enable_javascript_validation:
                _validate_javascript(current_validation.file_path)
            else:
                _complete_validation({"success": false, "error": "JavaScript validation disabled", "file_path": current_validation.file_path})
        _:
            _complete_validation({"success": false, "error": "Unsupported file type", "file_path": current_validation.file_path})

func _handle_validation_timeout():
    print("CodeValidator: Validation timeout for ", current_validation.file_path)
    
    _complete_validation({
        "success": false,
        "error": "Validation timeout",
        "file_path": current_validation.file_path,
        "duration": Time.get_unix_time_from_system() - validation_start_time
    })

func _complete_validation(result):
    # Store the validation result
    validation_results[current_validation.file_path] = result
    
    # Add to history
    validation_history.append({
        "file_path": current_validation.file_path,
        "timestamp": Time.get_unix_time_from_system(),
        "success": result.success,
        "error_count": result.errors.size() if result.has("errors") else 0,
        "warning_count": result.warnings.size() if result.has("warnings") else 0
    })
    
    if validation_history.size() > 100:
        validation_history.pop_front()
    
    # Reset state
    validation_in_progress = false
    current_validation = null
    
    # Emit signal
    emit_signal("validation_completed", result.file_path, result)
    
    # If all queue processed, emit batch completion
    if validation_queue.size() == 0:
        emit_signal("batch_validation_completed", validation_history.size())
    
    # Log to terminal if available
    if terminal_system and terminal_system.has_method("log_message"):
        if result.success:
            terminal_system.log_message("Validation passed: " + result.file_path)
        else:
            terminal_system.log_message("Validation failed: " + result.file_path + " - " + result.error)

# ----- GDSCRIPT VALIDATION -----
func _validate_gdscript(file_path):
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        _complete_validation({"success": false, "error": "Could not open file", "file_path": file_path})
        return
    
    # Check file size
    var size_kb = file.get_length() / 1024.0
    if size_kb > max_file_size_kb:
        _complete_validation({
            "success": false, 
            "error": "File too large (" + str(size_kb) + " KB, max " + str(max_file_size_kb) + " KB)",
            "file_path": file_path
        })
        return
    
    # Read file content
    var content = file.get_as_text()
    
    # Validation result structure
    var result = {
        "success": true,
        "file_path": file_path,
        "errors": [],
        "warnings": [],
        "info": [],
        "file_size_kb": size_kb,
        "line_count": 0,
        "class_count": 0,
        "function_count": 0,
        "signal_count": 0,
        "complexity": 0
    }
    
    # Check syntax if external parser is available
    if gdscript_check_syntax and use_external_tools and FileAccess.file_exists(gdscript_parser_path):
        var parser_result = _run_gdscript_parser(file_path)
        if not parser_result.success:
            for error in parser_result.errors:
                result.errors.append({
                    "line": error.line,
                    "column": error.column,
                    "message": error.message,
                    "type": "syntax"
                })
            
            result.success = false
    else:
        # Simple syntax check
        result = _check_gdscript_syntax(content, result)
    
    # Structure and style checks
    if gdscript_check_structure:
        result = _check_gdscript_structure(content, result)
    
    # Naming convention checks
    if gdscript_check_naming:
        result = _check_gdscript_naming(content, result)
    
    # Line length checks
    result = _check_line_lengths(content, result, gdscript_max_line_length)
    
    # Function length checks
    result = _check_function_lengths(content, result, gdscript_max_function_lines)
    
    # Section checks
    result = _check_required_sections(content, result, gdscript_required_sections)
    
    # Complete validation
    _complete_validation(result)

func _run_gdscript_parser(file_path):
    # This would normally call an external GDScript parser
    # For this example, we're simulating a parser
    
    # In a real implementation, you might use:
    # 1. The GDScript parser in Godot's codebase
    # 2. A custom GDScript parser addon
    # 3. A subprocess that runs Godot in headless mode to check syntax
    
    # Placeholder implementation
    return {"success": true, "errors": []}

func _check_gdscript_syntax(content, result):
    var lines = content.split("\n")
    result.line_count = lines.size()
    
    var brace_stack = []
    var paren_stack = []
    var bracket_stack = []
    
    for line_num in range(lines.size()):
        var line = lines[line_num]
        var stripped_line = line.strip_edges()
        
        # Skip comments
        if stripped_line.begins_with("#"):
            continue
        
        # Check for mismatched braces, parentheses, and brackets
        for char_idx in range(line.length()):
            var char = line[char_idx]
            
            match char:
                "{":
                    brace_stack.append({"line": line_num + 1, "column": char_idx + 1})
                "}":
                    if brace_stack.size() == 0:
                        result.errors.append({
                            "line": line_num + 1,
                            "column": char_idx + 1,
                            "message": "Unexpected closing brace",
                            "type": "syntax"
                        })
                        result.success = false
                    else:
                        brace_stack.pop_back()
                "(":
                    paren_stack.append({"line": line_num + 1, "column": char_idx + 1})
                ")":
                    if paren_stack.size() == 0:
                        result.errors.append({
                            "line": line_num + 1,
                            "column": char_idx + 1,
                            "message": "Unexpected closing parenthesis",
                            "type": "syntax"
                        })
                        result.success = false
                    else:
                        paren_stack.pop_back()
                "[":
                    bracket_stack.append({"line": line_num + 1, "column": char_idx + 1})
                "]":
                    if bracket_stack.size() == 0:
                        result.errors.append({
                            "line": line_num + 1,
                            "column": char_idx + 1,
                            "message": "Unexpected closing bracket",
                            "type": "syntax"
                        })
                        result.success = false
                    else:
                        bracket_stack.pop_back()
        
        # Check for class definitions
        if stripped_line.match(gdscript_patterns.class_definition):
            result.class_count += 1
        
        # Check for function definitions
        if stripped_line.match(gdscript_patterns.function_definition):
            result.function_count += 1
        
        # Check for signal definitions
        if stripped_line.match(gdscript_patterns.signal_definition):
            result.signal_count += 1
    
    # Check for unclosed braces, parentheses, and brackets
    if brace_stack.size() > 0:
        var pos = brace_stack[0]
        result.errors.append({
            "line": pos.line,
            "column": pos.column,
            "message": "Unclosed brace",
            "type": "syntax"
        })
        result.success = false
    
    if paren_stack.size() > 0:
        var pos = paren_stack[0]
        result.errors.append({
            "line": pos.line,
            "column": pos.column,
            "message": "Unclosed parenthesis",
            "type": "syntax"
        })
        result.success = false
    
    if bracket_stack.size() > 0:
        var pos = bracket_stack[0]
        result.errors.append({
            "line": pos.line,
            "column": pos.column,
            "message": "Unclosed bracket",
            "type": "syntax"
        })
        result.success = false
    
    return result

func _check_gdscript_structure(content, result):
    var lines = content.split("\n")
    
    # Check for basic structure elements
    var has_class_name = false
    var has_extends = false
    var has_ready_func = false
    var has_section_comments = false
    
    for line in lines:
        var stripped_line = line.strip_edges()
        
        if stripped_line.begins_with("class_name "):
            has_class_name = true
        
        if stripped_line.begins_with("extends "):
            has_extends = true
        
        if stripped_line.begins_with("func _ready"):
            has_ready_func = true
        
        if stripped_line.begins_with("# -----"):
            has_section_comments = true
    
    # Add structure warnings
    if not has_extends:
        result.warnings.append({
            "line": 1,
            "column": 1,
            "message": "Script should extend a base class",
            "type": "structure"
        })
    
    if not has_class_name:
        result.warnings.append({
            "line": 1,
            "column": 1,
            "message": "Consider adding a class_name for reusability",
            "type": "structure"
        })
    
    if not has_ready_func:
        result.warnings.append({
            "line": 1,
            "column": 1,
            "message": "Script should have a _ready function for initialization",
            "type": "structure"
        })
    
    if not has_section_comments:
        result.warnings.append({
            "line": 1,
            "column": 1,
            "message": "Consider using section comments (# ----- SECTION -----) for better organization",
            "type": "structure"
        })
    
    return result

func _check_gdscript_naming(content, result):
    var lines = content.split("\n")
    
    for line_num in range(lines.size()):
        var line = lines[line_num]
        var stripped_line = line.strip_edges()
        
        # Check class naming (PascalCase)
        var class_regex = RegEx.new()
        class_regex.compile(gdscript_patterns.class_definition)
        var class_match = class_regex.search(stripped_line)
        
        if class_match:
            var class_name = class_match.get_string(1)
            if not _is_pascal_case(class_name):
                result.warnings.append({
                    "line": line_num + 1,
                    "column": class_match.get_start(1) + 1,
                    "message": "Class name '" + class_name + "' should use PascalCase",
                    "type": "naming"
                })
        
        # Check function naming (snake_case)
        var func_regex = RegEx.new()
        func_regex.compile(gdscript_patterns.function_definition)
        var func_match = func_regex.search(stripped_line)
        
        if func_match:
            var func_name = func_match.get_string(1)
            if not _is_snake_case(func_name) and not func_name.begins_with("_"):
                result.warnings.append({
                    "line": line_num + 1,
                    "column": func_match.get_start(1) + 1,
                    "message": "Function name '" + func_name + "' should use snake_case",
                    "type": "naming"
                })
        
        # Check variable naming (snake_case)
        var var_regex = RegEx.new()
        var_regex.compile(gdscript_patterns.variable_definition)
        var var_match = var_regex.search(stripped_line)
        
        if var_match:
            var var_name = var_match.get_string(1)
            if not _is_snake_case(var_name) and not var_name.begins_with("_"):
                result.warnings.append({
                    "line": line_num + 1,
                    "column": var_match.get_start(1) + 1,
                    "message": "Variable name '" + var_name + "' should use snake_case",
                    "type": "naming"
                })
        
        # Check signal naming (snake_case)
        var signal_regex = RegEx.new()
        signal_regex.compile(gdscript_patterns.signal_definition)
        var signal_match = signal_regex.search(stripped_line)
        
        if signal_match:
            var signal_name = signal_match.get_string(1)
            if not _is_snake_case(signal_name):
                result.warnings.append({
                    "line": line_num + 1,
                    "column": signal_match.get_start(1) + 1,
                    "message": "Signal name '" + signal_name + "' should use snake_case",
                    "type": "naming"
                })
    
    return result

# ----- PYTHON VALIDATION -----
func _validate_python(file_path):
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        _complete_validation({"success": false, "error": "Could not open file", "file_path": file_path})
        return
    
    # Check file size
    var size_kb = file.get_length() / 1024.0
    if size_kb > max_file_size_kb:
        _complete_validation({
            "success": false, 
            "error": "File too large (" + str(size_kb) + " KB, max " + str(max_file_size_kb) + " KB)",
            "file_path": file_path
        })
        return
    
    # Read file content
    var content = file.get_as_text()
    
    # Validation result structure
    var result = {
        "success": true,
        "file_path": file_path,
        "errors": [],
        "warnings": [],
        "info": [],
        "file_size_kb": size_kb,
        "line_count": 0,
        "class_count": 0,
        "function_count": 0,
        "import_count": 0,
        "complexity": 0
    }
    
    # Check syntax if external tool is available
    if python_check_syntax and use_external_tools:
        var syntax_result = _run_python_syntax_check(file_path)
        if not syntax_result.success:
            for error in syntax_result.errors:
                result.errors.append(error)
            
            result.success = false
    else:
        # Simple syntax check
        result = _check_python_syntax(content, result)
    
    # PEP8 checks
    if python_check_pep8:
        result = _check_python_pep8(content, result)
    
    # Import checks
    if python_check_imports:
        result = _check_python_imports(content, result)
    
    # Line length checks
    result = _check_line_lengths(content, result, python_max_line_length)
    
    # Function length checks
    result = _check_function_lengths(content, result, python_max_function_lines)
    
    # Complete validation
    _complete_validation(result)

func _run_python_syntax_check(file_path):
    # This would normally call an external Python syntax checker
    # For this example, we're simulating a checker
    
    # In a real implementation, you might use:
    # 1. A subprocess that runs "python -m py_compile {file_path}"
    # 2. A Python linter like pylint or flake8
    
    # Placeholder implementation
    return {"success": true, "errors": []}

func _check_python_syntax(content, result):
    var lines = content.split("\n")
    result.line_count = lines.size()
    
    var paren_stack = []
    var bracket_stack = []
    var brace_stack = []
    
    for line_num in range(lines.size()):
        var line = lines[line_num]
        var stripped_line = line.strip_edges()
        
        # Skip comments
        if stripped_line.begins_with("#"):
            continue
        
        # Check for mismatched braces, parentheses, and brackets
        for char_idx in range(line.length()):
            var char = line[char_idx]
            
            match char:
                "(":
                    paren_stack.append({"line": line_num + 1, "column": char_idx + 1})
                ")":
                    if paren_stack.size() == 0:
                        result.errors.append({
                            "line": line_num + 1,
                            "column": char_idx + 1,
                            "message": "Unexpected closing parenthesis",
                            "type": "syntax"
                        })
                        result.success = false
                    else:
                        paren_stack.pop_back()
                "[":
                    bracket_stack.append({"line": line_num + 1, "column": char_idx + 1})
                "]":
                    if bracket_stack.size() == 0:
                        result.errors.append({
                            "line": line_num + 1,
                            "column": char_idx + 1,
                            "message": "Unexpected closing bracket",
                            "type": "syntax"
                        })
                        result.success = false
                    else:
                        bracket_stack.pop_back()
                "{":
                    brace_stack.append({"line": line_num + 1, "column": char_idx + 1})
                "}":
                    if brace_stack.size() == 0:
                        result.errors.append({
                            "line": line_num + 1,
                            "column": char_idx + 1,
                            "message": "Unexpected closing brace",
                            "type": "syntax"
                        })
                        result.success = false
                    else:
                        brace_stack.pop_back()
        
        # Check for class definitions
        if _line_matches_pattern(stripped_line, python_patterns.class_definition):
            result.class_count += 1
        
        # Check for function definitions
        if _line_matches_pattern(stripped_line, python_patterns.function_definition):
            result.function_count += 1
        
        # Check for import statements
        if _line_matches_pattern(stripped_line, python_patterns.import_statement):
            result.import_count += 1
    
    # Check for unclosed parentheses, brackets, and braces
    if paren_stack.size() > 0:
        var pos = paren_stack[0]
        result.errors.append({
            "line": pos.line,
            "column": pos.column,
            "message": "Unclosed parenthesis",
            "type": "syntax"
        })
        result.success = false
    
    if bracket_stack.size() > 0:
        var pos = bracket_stack[0]
        result.errors.append({
            "line": pos.line,
            "column": pos.column,
            "message": "Unclosed bracket",
            "type": "syntax"
        })
        result.success = false
    
    if brace_stack.size() > 0:
        var pos = brace_stack[0]
        result.errors.append({
            "line": pos.line,
            "column": pos.column,
            "message": "Unclosed brace",
            "type": "syntax"
        })
        result.success = false
    
    return result

func _check_python_pep8(content, result):
    var lines = content.split("\n")
    
    for line_num in range(lines.size()):
        var line = lines[line_num]
        var stripped_line = line.strip_edges()
        
        # Check indentation (should be 4 spaces)
        var indent_count = 0
        for char_idx in range(line.length()):
            if line[char_idx] == " ":
                indent_count += 1
            elif line[char_idx] == "\t":
                result.warnings.append({
                    "line": line_num + 1,
                    "column": char_idx + 1,
                    "message": "Use 4 spaces for indentation, not tabs",
                    "type": "style"
                })
                break
            else:
                break
        
        if indent_count > 0 and indent_count % 4 != 0:
            result.warnings.append({
                "line": line_num + 1,
                "column": 1,
                "message": "Indentation should be a multiple of 4 spaces",
                "type": "style"
            })
        
        # Check for whitespace around operators
        if stripped_line.find("=") >= 0 and not (
            stripped_line.find(" = ") >= 0 or
            stripped_line.find("==") >= 0 or
            stripped_line.find("+=") >= 0 or
            stripped_line.find("-=") >= 0 or
            stripped_line.find("*=") >= 0 or
            stripped_line.find("/=") >= 0
        ):
            result.warnings.append({
                "line": line_num + 1,
                "column": stripped_line.find("=") + 1,
                "message": "Missing whitespace around operator",
                "type": "style"
            })
        
        # Check for trailing whitespace
        if line.strip_edges(false, true) != line:
            result.warnings.append({
                "line": line_num + 1,
                "column": line.length(),
                "message": "Trailing whitespace",
                "type": "style"
            })
    
    return result

func _check_python_imports(content, result):
    var lines = content.split("\n")
    var import_lines = []
    
    # Find all import statements
    for line_num in range(lines.size()):
        var line = lines[line_num]
        var stripped_line = line.strip_edges()
        
        if _line_matches_pattern(stripped_line, python_patterns.import_statement):
            import_lines.append({"line": stripped_line, "num": line_num + 1})
    
    # Check for import order
    if import_lines.size() > 1:
        for i in range(1, import_lines.size()):
            var prev = import_lines[i-1].line
            var curr = import_lines[i].line
            
            # Standard library should come before third-party
            if (prev.begins_with("import") and curr.begins_with("from")) or (
                prev.begins_with("from") and curr.begins_with("import")
            ):
                result.warnings.append({
                    "line": import_lines[i].num,
                    "column": 1,
                    "message": "Import order: standard library imports should come before third-party imports",
                    "type": "style"
                })
    
    # Check for unused imports
    # This is a simple check and would be more robust with actual parsing
    for import_line in import_lines:
        var module_name = ""
        if import_line.line.begins_with("import "):
            module_name = import_line.line.substr(7).strip_edges().split(" ")[0]
        elif import_line.line.begins_with("from "):
            var parts = import_line.line.split(" ")
            if parts.size() >= 2:
                module_name = parts[1]
        
        if module_name and module_name.strip_edges() != "":
            var module_used = false
            
            for line_num in range(import_line.num, lines.size()):
                if lines[line_num].find(module_name) >= 0 and line_num != import_line.num - 1:
                    module_used = true
                    break
            
            if not module_used:
                result.warnings.append({
                    "line": import_line.num,
                    "column": 1,
                    "message": "Potentially unused import: " + module_name,
                    "type": "style"
                })
    
    return result

# ----- JAVASCRIPT VALIDATION -----
func _validate_javascript(file_path):
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        _complete_validation({"success": false, "error": "Could not open file", "file_path": file_path})
        return
    
    # Check file size
    var size_kb = file.get_length() / 1024.0
    if size_kb > max_file_size_kb:
        _complete_validation({
            "success": false, 
            "error": "File too large (" + str(size_kb) + " KB, max " + str(max_file_size_kb) + " KB)",
            "file_path": file_path
        })
        return
    
    # Read file content
    var content = file.get_as_text()
    
    # Validation result structure
    var result = {
        "success": true,
        "file_path": file_path,
        "errors": [],
        "warnings": [],
        "info": [],
        "file_size_kb": size_kb,
        "line_count": 0,
        "function_count": 0,
        "class_count": 0,
        "import_count": 0,
        "complexity": 0
    }
    
    # Check syntax if external tool is available
    if js_check_syntax and use_external_tools:
        var eslint_result = _run_eslint(file_path)
        if not eslint_result.success:
            for error in eslint_result.errors:
                result.errors.append(error)
            
            for warning in eslint_result.warnings:
                result.warnings.append(warning)
            
            if eslint_result.errors.size() > 0:
                result.success = false
    else:
        # Simple syntax check
        result = _check_javascript_syntax(content, result)
    
    # Standards check
    if js_check_standards:
        result = _check_javascript_standards(content, result)
    
    # ES version check
    if js_check_es_version:
        result = _check_javascript_es_version(content, result)
    
    # Line length checks
    result = _check_line_lengths(content, result, js_max_line_length)
    
    # Function length checks
    result = _check_function_lengths(content, result, js_max_function_lines)
    
    # Complete validation
    _complete_validation(result)

func _run_eslint(file_path):
    # This would normally call ESLint
    # For this example, we're simulating ESLint
    
    # In a real implementation, you might use:
    # 1. A subprocess that runs "npx eslint {file_path}"
    # 2. A Node.js bridge to ESLint
    
    # Placeholder implementation
    return {"success": true, "errors": [], "warnings": []}

func _check_javascript_syntax(content, result):
    var lines = content.split("\n")
    result.line_count = lines.size()
    
    var paren_stack = []
    var bracket_stack = []
    var brace_stack = []
    
    for line_num in range(lines.size()):
        var line = lines[line_num]
        var stripped_line = line.strip_edges()
        
        # Skip comments
        if stripped_line.begins_with("//") or stripped_line.begins_with("/*"):
            continue
        
        # Check for mismatched braces, parentheses, and brackets
        for char_idx in range(line.length()):
            var char = line[char_idx]
            
            match char:
                "(":
                    paren_stack.append({"line": line_num + 1, "column": char_idx + 1})
                ")":
                    if paren_stack.size() == 0:
                        result.errors.append({
                            "line": line_num + 1,
                            "column": char_idx + 1,
                            "message": "Unexpected closing parenthesis",
                            "type": "syntax"
                        })
                        result.success = false
                    else:
                        paren_stack.pop_back()
                "[":
                    bracket_stack.append({"line": line_num + 1, "column": char_idx + 1})
                "]":
                    if bracket_stack.size() == 0:
                        result.errors.append({
                            "line": line_num + 1,
                            "column": char_idx + 1,
                            "message": "Unexpected closing bracket",
                            "type": "syntax"
                        })
                        result.success = false
                    else:
                        bracket_stack.pop_back()
                "{":
                    brace_stack.append({"line": line_num + 1, "column": char_idx + 1})
                "}":
                    if brace_stack.size() == 0:
                        result.errors.append({
                            "line": line_num + 1,
                            "column": char_idx + 1,
                            "message": "Unexpected closing brace",
                            "type": "syntax"
                        })
                        result.success = false
                    else:
                        brace_stack.pop_back()
        
        # Check for function definitions
        if _line_matches_pattern(stripped_line, js_patterns.function_definition) or _line_matches_pattern(stripped_line, js_patterns.arrow_function):
            result.function_count += 1
        
        # Check for class definitions
        if _line_matches_pattern(stripped_line, js_patterns.class_definition):
            result.class_count += 1
        
        # Check for import statements
        if _line_matches_pattern(stripped_line, js_patterns.import_statement):
            result.import_count += 1
    
    # Check for unclosed parentheses, brackets, and braces
    if paren_stack.size() > 0:
        var pos = paren_stack[0]
        result.errors.append({
            "line": pos.line,
            "column": pos.column,
            "message": "Unclosed parenthesis",
            "type": "syntax"
        })
        result.success = false
    
    if bracket_stack.size() > 0:
        var pos = bracket_stack[0]
        result.errors.append({
            "line": pos.line,
            "column": pos.column,
            "message": "Unclosed bracket",
            "type": "syntax"
        })
        result.success = false
    
    if brace_stack.size() > 0:
        var pos = brace_stack[0]
        result.errors.append({
            "line": pos.line,
            "column": pos.column,
            "message": "Unclosed brace",
            "type": "syntax"
        })
        result.success = false
    
    return result

func _check_javascript_standards(content, result):
    var lines = content.split("\n")
    
    for line_num in range(lines.size()):
        var line = lines[line_num]
        var stripped_line = line.strip_edges()
        
        # Check for semicolons (if using Standard style, they're discouraged)
        if js_style_guide == "Standard" and stripped_line.ends_with(";"):
            result.warnings.append({
                "line": line_num + 1,
                "column": stripped_line.length(),
                "message": "Unnecessary semicolon (Standard style discourages them)",
                "type": "style"
            })
        
        # Check for var (prefer let/const)
        if stripped_line.begins_with("var "):
            result.warnings.append({
                "line": line_num + 1,
                "column": 1,
                "message": "Use 'let' or 'const' instead of 'var'",
                "type": "style"
            })
        
        # Check for == instead of ===
        if stripped_line.find(" == ") >= 0 and not stripped_line.find(" === ") >= 0:
            result.warnings.append({
                "line": line_num + 1,
                "column": stripped_line.find(" == ") + 1,
                "message": "Use '===' instead of '=='",
                "type": "style"
            })
    
    return result

func _check_javascript_es_version(content, result):
    var lines = content.split("\n")
    var es6_features = 0
    
    for line in lines:
        var stripped_line = line.strip_edges()
        
        # Check for ES6+ features
        if stripped_line.find("=>") >= 0:  # Arrow functions
            es6_features += 1
        
        if stripped_line.begins_with("class "):  # Classes
            es6_features += 1
        
        if stripped_line.begins_with("const ") or stripped_line.begins_with("let "):  # let/const
            es6_features += 1
        
        if stripped_line.find("...") >= 0:  # Spread operator
            es6_features += 1
        
        if stripped_line.find("**") >= 0:  # Exponentiation
            es6_features += 1
        
        if stripped_line.find("`") >= 0:  # Template literals
            es6_features += 1
    
    # Add information about ES version
    if es6_features > 0:
        result.info.append({
            "type": "es_version",
            "message": "File uses ES6+ features (" + str(es6_features) + " detected)",
            "details": "ES6+ features are well-supported in modern browsers but may need transpilation for older targets"
        })
    else:
        result.info.append({
            "type": "es_version",
            "message": "File uses ES5 syntax",
            "details": "ES5 has broad compatibility but lacks modern JavaScript features"
        })
    
    return result

# ----- COMMON VALIDATION FUNCTIONS -----
func _check_line_lengths(content, result, max_length):
    var lines = content.split("\n")
    
    for line_num in range(lines.size()):
        var line = lines[line_num]
        
        if line.length() > max_length:
            result.warnings.append({
                "line": line_num + 1,
                "column": max_length + 1,
                "message": "Line exceeds maximum length of " + str(max_length) + " characters",
                "type": "style"
            })
    
    return result

func _check_function_lengths(content, result, max_lines):
    var lines = content.split("\n")
    var in_function = false
    var function_start_line = 0
    var function_name = ""
    var brace_count = 0
    
    for line_num in range(lines.size()):
        var line = lines[line_num]
        var stripped_line = line.strip_edges()
        
        # Check for function start
        if not in_function:
            var is_function = false
            var name = ""
            
            # Check different function patterns based on language
            if _file_is_gdscript(result.file_path):
                if stripped_line.begins_with("func "):
                    is_function = true
                    var parts = stripped_line.split("(", false, 1)
                    if parts.size() > 0:
                        name = parts[0].substr(5).strip_edges()
            elif _file_is_python(result.file_path):
                if stripped_line.begins_with("def "):
                    is_function = true
                    var parts = stripped_line.split("(", false, 1)
                    if parts.size() > 0:
                        name = parts[0].substr(4).strip_edges()
            elif _file_is_javascript(result.file_path):
                if stripped_line.begins_with("function ") or stripped_line.find(" function ") >= 0:
                    is_function = true
                    var parts = stripped_line.split("function ", false, 1)
                    if parts.size() > 1:
                        var name_parts = parts[1].split("(", false, 1)
                        if name_parts.size() > 0:
                            name = name_parts[0].strip_edges()
                elif stripped_line.find(" => ") >= 0:
                    is_function = true
                    var parts = stripped_line.split("=", false, 1)
                    if parts.size() > 0:
                        name = parts[0].strip_edges()
            
            if is_function:
                in_function = true
                function_start_line = line_num
                function_name = name
        
        # Count braces to track function body (primarily for JS)
        if in_function and _file_is_javascript(result.file_path):
            for c in line:
                if c == "{":
                    brace_count += 1
                elif c == "}":
                    brace_count -= 1
                    if brace_count <= 0:
                        # Function end found
                        var function_length = line_num - function_start_line + 1
                        
                        if function_length > max_lines:
                            result.warnings.append({
                                "line": function_start_line + 1,
                                "column": 1,
                                "message": "Function '" + function_name + "' is " + str(function_length) + " lines long (max " + str(max_lines) + ")",
                                "type": "complexity"
                            })
                        
                        in_function = false
                        brace_count = 0
                        
        # Check for Python function end (indentation)
        elif in_function and _file_is_python(result.file_path):
            var indent_level = 0
            for c in line:
                if c == " ":
                    indent_level += 1
                elif c == "\t":
                    indent_level += 4
                else:
                    break
            
            if indent_level == 0 and line.strip_edges() != "":
                # Function end found (dedent)
                var function_length = line_num - function_start_line
                
                if function_length > max_lines:
                    result.warnings.append({
                        "line": function_start_line + 1,
                        "column": 1,
                        "message": "Function '" + function_name + "' is " + str(function_length) + " lines long (max " + str(max_lines) + ")",
                        "type": "complexity"
                    })
                
                in_function = false
    
    return result

func _check_required_sections(content, result, required_sections):
    # Check if all required sections are present
    for section in required_sections:
        if content.find(section) < 0:
            result.warnings.append({
                "line": 1,
                "column": 1,
                "message": "Missing required section: " + section,
                "type": "structure"
            })
    
    return result

# ----- HELPER FUNCTIONS -----
func _is_pascal_case(name: String) -> bool:
    if name.is_empty():
        return false
    
    # First character should be uppercase
    if not name[0].to_upper() == name[0]:
        return false
    
    # Should not contain underscores
    if name.find("_") >= 0:
        return false
    
    return true

func _is_snake_case(name: String) -> bool:
    if name.is_empty():
        return false
    
    # Should be all lowercase with underscores
    for c in name:
        if c != "_" and not (c >= "a" and c <= "z") and not (c >= "0" and c <= "9"):
            return false
    
    return true

func _is_camel_case(name: String) -> bool:
    if name.is_empty():
        return false
    
    # First character should be lowercase
    if not name[0].to_lower() == name[0]:
        return false
    
    # Should not contain underscores
    if name.find("_") >= 0:
        return false
    
    return true

func _line_matches_pattern(line: String, pattern: String) -> bool:
    var regex = RegEx.new()
    regex.compile(pattern)
    return regex.search(line) != null

func _file_is_gdscript(file_path: String) -> bool:
    return file_path.get_extension().to_lower() == "gd"

func _file_is_python(file_path: String) -> bool:
    return file_path.get_extension().to_lower() == "py"

func _file_is_javascript(file_path: String) -> bool:
    return file_path.get_extension().to_lower() == "js"

# ----- PUBLIC API -----
func validate_file(file_path: String) -> bool:
    # Check if file exists
    if not FileAccess.file_exists(file_path):
        print("CodeValidator: File not found: " + file_path)
        return false
    
    # Check file type
    var extension = file_path.get_extension().to_lower()
    
    if extension == "gd" and not enable_gdscript_validation:
        print("CodeValidator: GDScript validation is disabled")
        return false
    
    if extension == "py" and not enable_python_validation:
        print("CodeValidator: Python validation is disabled")
        return false
    
    if extension == "js" and not enable_javascript_validation:
        print("CodeValidator: JavaScript validation is disabled")
        return false
    
    if not ["gd", "py", "js"].has(extension):
        print("CodeValidator: Unsupported file type: " + extension)
        return false
    
    # Add to validation queue
    validation_queue.append({
        "file_path": file_path,
        "queued_at": Time.get_unix_time_from_system()
    })
    
    return true

func validate_files(file_paths: Array) -> int:
    var queued_count = 0
    
    for file_path in file_paths:
        if validate_file(file_path):
            queued_count += 1
    
    return queued_count

func get_validation_result(file_path: String) -> Dictionary:
    if validation_results.has(file_path):
        return validation_results[file_path]
    return {}

func get_validation_history() -> Array:
    return validation_history

func get_validation_stats() -> Dictionary:
    var total_validations = validation_history.size()
    var success_count = 0
    var error_count = 0
    var warning_count = 0
    
    for entry in validation_history:
        if entry.success:
            success_count += 1
        
        error_count += entry.error_count
        warning_count += entry.warning_count
    
    return {
        "total_validations": total_validations,
        "success_count": success_count,
        "failure_count": total_validations - success_count,
        "error_count": error_count,
        "warning_count": warning_count,
        "gdscript_enabled": enable_gdscript_validation,
        "python_enabled": enable_python_validation,
        "javascript_enabled": enable_javascript_validation
    }

func clear_validation_results():
    validation_results.clear()
    validation_history.clear()
    print("CodeValidator: Validation results cleared")

# ----- SIGNAL HANDLERS -----
func _on_file_changed(file_path, change_type, details):
    # Validate file if it's a new or modified code file
    if change_type == "new" or change_type == "modified":
        var extension = file_path.get_extension().to_lower()
        
        if ["gd", "py", "js"].has(extension):
            validate_file(file_path)