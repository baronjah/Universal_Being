extends Node

class_name GodotResearchSystem

# Godot Source Code Research and Analysis System
# Provides tools for searching, analyzing, and understanding Godot Engine source code

# Signals
signal search_completed(search_term, results)
signal analysis_completed(file_path, metrics)
signal code_indexed(status, file_count)
signal visualization_generated(visualization_type, data)

# Configuration
const GODOT_SOURCE_CACHE = "/mnt/c/Users/Percision 15/LuminusOS/code_cache/godot_source/"
const INDEX_PATH = "/mnt/c/Users/Percision 15/LuminusOS/code_cache/godot_index.json"
const RESEARCH_DB_PATH = "/mnt/c/Users/Percision 15/LuminusOS/code_cache/godot_research.db"

# Index of all Godot source files and classes
var file_index = {}
var class_index = {}
var function_index = {}
var signal_index = {}
var keyword_index = {}

# Source code stats
var total_files = 0
var total_lines = 0
var total_classes = 0
var total_functions = 0
var total_signals = 0

# Analysis metrics
var code_metrics = {
    "file_types": {},
    "class_hierarchy": {},
    "complexity_scores": {},
    "documentation_coverage": {},
    "file_dependencies": {}
}

# Internal state
var indexing_in_progress = false
var current_operation = ""
var research_db = null

# Thread for background operations
var thread = null

func _ready():
    print("Godot Research System initializing...")
    
    # Create directory if it doesn't exist
    var dir = DirAccess.open("res://")
    if not dir.dir_exists(GODOT_SOURCE_CACHE):
        dir.make_dir_recursive(GODOT_SOURCE_CACHE)
    
    # Load index if it exists
    _load_index()
    
    # Initialize database
    _init_research_db()
    
    print("Godot Research System initialized")
    print("Total indexed files: " + str(total_files))
    print("Total indexed classes: " + str(total_classes))
    print("Total indexed functions: " + str(total_functions))

# Public methods

func search_code(search_term, filters = {}):
    # Search through indexed code for the specified term
    if search_term.length() < 2:
        return {"error": "Search term must be at least 2 characters long"}
    
    var results = {
        "files": [],
        "classes": [],
        "functions": [],
        "signals": [],
        "usages": []
    }
    
    # Check for special search syntax
    if search_term.begins_with("class:"):
        return search_for_class(search_term.substr(6).strip_edges())
    elif search_term.begins_with("func:"):
        return search_for_function(search_term.substr(5).strip_edges())
    elif search_term.begins_with("signal:"):
        return search_for_signal(search_term.substr(7).strip_edges())
    elif search_term.begins_with("extends:"):
        return search_inherited_classes(search_term.substr(8).strip_edges())
    
    # Standard search through all indices
    if keyword_index.has(search_term.to_lower()):
        var keyword_matches = keyword_index[search_term.to_lower()]
        
        for file_path in keyword_matches.files:
            results.files.append({
                "path": file_path,
                "relevance": keyword_matches.files[file_path]
            })
        
        for class_name in keyword_matches.classes:
            results.classes.append({
                "name": class_name,
                "file": class_index[class_name].file,
                "relevance": keyword_matches.classes[class_name]
            })
        
        for func_key in keyword_matches.functions:
            var parts = func_key.split(":", false, 1)
            var class_name = parts[0]
            var func_name = parts[1]
            
            results.functions.append({
                "name": func_name,
                "class": class_name,
                "file": class_index[class_name].file,
                "relevance": keyword_matches.functions[func_key]
            })
    
    # Sort results by relevance
    results.files.sort_custom(func(a, b): return a.relevance > b.relevance)
    results.classes.sort_custom(func(a, b): return a.relevance > b.relevance)
    results.functions.sort_custom(func(a, b): return a.relevance > b.relevance)
    
    # Add usage examples for top results
    if results.functions.size() > 0:
        var top_function = results.functions[0]
        results.usages = _find_usage_examples(top_function.class, top_function.name)
    elif results.classes.size() > 0:
        var top_class = results.classes[0]
        results.usages = _find_class_usage_examples(top_class.name)
    
    emit_signal("search_completed", search_term, results)
    return results

func search_for_class(class_name):
    var results = {
        "classes": [],
        "derived_classes": [],
        "methods": [],
        "signals": [],
        "properties": [],
        "constants": []
    }
    
    # Find exact and partial class matches
    var exact_match = false
    for c in class_index:
        if c.to_lower() == class_name.to_lower():
            exact_match = true
            results.classes.append({
                "name": c,
                "file": class_index[c].file,
                "line": class_index[c].line,
                "inherits": class_index[c].inherits,
                "relevance": 100
            })
        elif c.to_lower().find(class_name.to_lower()) >= 0:
            results.classes.append({
                "name": c,
                "file": class_index[c].file,
                "line": class_index[c].line,
                "inherits": class_index[c].inherits,
                "relevance": 70
            })
    
    # If we have an exact match, get more details
    if exact_match:
        var class_data = class_index[results.classes[0].name]
        
        # Get methods
        for method_key in function_index:
            var parts = method_key.split(":", false, 1)
            if parts[0] == results.classes[0].name:
                results.methods.append({
                    "name": parts[1],
                    "return_type": function_index[method_key].return_type,
                    "arguments": function_index[method_key].arguments,
                    "line": function_index[method_key].line
                })
        
        # Get signals
        for signal_key in signal_index:
            var parts = signal_key.split(":", false, 1)
            if parts[0] == results.classes[0].name:
                results.signals.append({
                    "name": parts[1],
                    "arguments": signal_index[signal_key].arguments,
                    "line": signal_index[signal_key].line
                })
        
        # Find derived classes
        for c in class_index:
            if class_index[c].inherits == results.classes[0].name:
                results.derived_classes.append({
                    "name": c,
                    "file": class_index[c].file,
                    "line": class_index[c].line
                })
        
        # TODO: Add properties and constants extraction
    
    return results

func search_for_function(func_name):
    var results = {
        "functions": [],
        "usages": []
    }
    
    # Find functions matching the name
    for func_key in function_index:
        var parts = func_key.split(":", false, 1)
        var class_name = parts[0]
        var method_name = parts[1]
        
        if method_name.to_lower() == func_name.to_lower():
            results.functions.append({
                "name": method_name,
                "class": class_name,
                "file": class_index[class_name].file,
                "line": function_index[func_key].line,
                "return_type": function_index[func_key].return_type,
                "arguments": function_index[func_key].arguments,
                "relevance": 100
            })
        elif method_name.to_lower().find(func_name.to_lower()) >= 0:
            results.functions.append({
                "name": method_name,
                "class": class_name,
                "file": class_index[class_name].file,
                "line": function_index[func_key].line,
                "return_type": function_index[func_key].return_type,
                "arguments": function_index[func_key].arguments,
                "relevance": 70
            })
    
    # Sort by relevance
    results.functions.sort_custom(func(a, b): return a.relevance > b.relevance)
    
    # Add usage examples for top result
    if results.functions.size() > 0:
        var top_function = results.functions[0]
        results.usages = _find_usage_examples(top_function.class, top_function.name)
    
    return results

func search_for_signal(signal_name):
    var results = {
        "signals": [],
        "usages": []
    }
    
    # Find signals matching the name
    for signal_key in signal_index:
        var parts = signal_key.split(":", false, 1)
        var class_name = parts[0]
        var sig_name = parts[1]
        
        if sig_name.to_lower() == signal_name.to_lower():
            results.signals.append({
                "name": sig_name,
                "class": class_name,
                "file": class_index[class_name].file,
                "line": signal_index[signal_key].line,
                "arguments": signal_index[signal_key].arguments,
                "relevance": 100
            })
        elif sig_name.to_lower().find(signal_name.to_lower()) >= 0:
            results.signals.append({
                "name": sig_name,
                "class": class_name,
                "file": class_index[class_name].file,
                "line": signal_index[signal_key].line,
                "arguments": signal_index[signal_key].arguments,
                "relevance": 70
            })
    
    # Sort by relevance
    results.signals.sort_custom(func(a, b): return a.relevance > b.relevance)
    
    # Add emit and connect examples for top result
    if results.signals.size() > 0:
        var top_signal = results.signals[0]
        results.usages = _find_signal_usage_examples(top_signal.class, top_signal.name)
    
    return results

func search_inherited_classes(base_class):
    var results = {
        "base_class": base_class,
        "derived_classes": []
    }
    
    # Find classes that inherit from the specified class
    for c in class_index:
        if class_index[c].inherits == base_class:
            results.derived_classes.append({
                "name": c,
                "file": class_index[c].file,
                "line": class_index[c].line
            })
    
    # Sort alphabetically
    results.derived_classes.sort_custom(func(a, b): return a.name < b.name)
    
    return results

func analyze_file(file_path):
    if not file_index.has(file_path) and not FileAccess.file_exists(file_path):
        return {"error": "File not found: " + file_path}
    
    # If not in index, read directly from the path
    var file_content = ""
    if file_index.has(file_path):
        file_content = _read_file_from_index(file_path)
    else:
        var file = FileAccess.open(file_path, FileAccess.READ)
        file_content = file.get_as_text()
        file.close()
    
    var metrics = {
        "file_path": file_path,
        "line_count": 0,
        "code_lines": 0,
        "comment_lines": 0,
        "blank_lines": 0,
        "classes": [],
        "functions": [],
        "signals": [],
        "complexity": 0
    }
    
    var lines = file_content.split("\n")
    metrics.line_count = lines.size()
    
    var in_multiline_comment = false
    var multiline_string = false
    
    for i in range(lines.size()):
        var line = lines[i].strip_edges()
        
        # Skip blank lines
        if line.is_empty():
            metrics.blank_lines += 1
            continue
        
        # Check for multiline string markers
        if line.count("\"\"\"") % 2 == 1 or line.count("'''") % 2 == 1:
            multiline_string = !multiline_string
        
        # Skip if in multiline string
        if multiline_string:
            continue
        
        # Handle comments
        if line.begins_with("#"):
            metrics.comment_lines += 1
            continue
        
        # Handle multiline comments
        if line.find("/*") >= 0 and line.find("*/") < 0:
            in_multiline_comment = true
            metrics.comment_lines += 1
            continue
        
        if in_multiline_comment:
            metrics.comment_lines += 1
            if line.find("*/") >= 0:
                in_multiline_comment = false
            continue
        
        # Count as code line
        metrics.code_lines += 1
        
        # Calculate complexity (simplified)
        if line.find("if ") >= 0 or line.find("else") >= 0 or line.find("for ") >= 0 or \
           line.find("while ") >= 0 or line.find("switch ") >= 0 or line.find("case ") >= 0:
            metrics.complexity += 1
        
        # Look for class definitions
        if line.find("class ") >= 0 and (line.find("{") >= 0 or i+1 < lines.size() and lines[i+1].strip_edges() == "{"):
            var class_name = _extract_class_name(line)
            if class_name:
                metrics.classes.append(class_name)
        
        # Look for function definitions
        if line.find("func ") >= 0 or line.find("function ") >= 0:
            var func_name = _extract_function_name(line)
            if func_name:
                metrics.functions.append(func_name)
        
        # Look for signal definitions
        if line.find("signal ") >= 0:
            var signal_name = _extract_signal_name(line)
            if signal_name:
                metrics.signals.append(signal_name)
    
    emit_signal("analysis_completed", file_path, metrics)
    return metrics

func build_class_hierarchy():
    var hierarchy = {}
    
    # First pass: identify base classes (those that don't inherit from anything or inherit from Object)
    for class_name in class_index:
        var inherits = class_index[class_name].inherits
        if inherits.empty() or inherits == "Object" or inherits == "Reference":
            hierarchy[class_name] = {
                "inherits": inherits,
                "children": []
            }
    
    # Second pass: add all remaining classes to the hierarchy
    for class_name in class_index:
        if hierarchy.has(class_name):
            continue  # Already added as a base class
        
        var inherits = class_index[class_name].inherits
        
        # Skip if inherits is empty (should have been handled in the first pass)
        if inherits.empty():
            continue
        
        # Add class to its parent's children
        if not hierarchy.has(inherits):
            hierarchy[inherits] = {
                "inherits": "",  # We don't know its parent yet
                "children": []
            }
        
        hierarchy[inherits].children.append(class_name)
        
        # Add the class itself to the hierarchy
        hierarchy[class_name] = {
            "inherits": inherits,
            "children": []
        }
    
    # Convert to a more readable format for visualization
    var result = _format_hierarchy_for_visualization(hierarchy)
    
    emit_signal("visualization_generated", "class_hierarchy", result)
    code_metrics.class_hierarchy = hierarchy
    
    return result

func visualize_code_structure(file_path = ""):
    var structure = []
    
    if file_path.empty():
        # Visualize overall code structure
        structure = _generate_overall_structure()
    else:
        # Visualize specific file structure
        structure = _generate_file_structure(file_path)
    
    emit_signal("visualization_generated", "code_structure", structure)
    return structure

func index_godot_source(source_path = ""):
    if indexing_in_progress:
        return {"error": "Indexing already in progress: " + current_operation}
    
    indexing_in_progress = true
    current_operation = "Preparing indexing"
    
    # Start indexing in a thread to avoid blocking the main thread
    if thread == null:
        thread = Thread.new()
    
    if source_path.empty():
        # Try to use default locations
        var potential_paths = [
            "/mnt/c/Users/Percision 15/Desktop/JustStuff/godot 4.2.2 sourcecode/godot-4.2/",
            "/mnt/c/Users/Percision 15/godot-4.2/",
            "/mnt/c/godot-4.2/",
            "/usr/local/src/godot/"
        ]
        
        for path in potential_paths:
            if DirAccess.dir_exists_absolute(path):
                source_path = path
                break
        
        if source_path.empty():
            indexing_in_progress = false
            return {"error": "Could not find Godot source code. Please specify a path."}
    
    thread.start(_index_source_thread.bind(source_path))
    
    return {"status": "Indexing started", "source_path": source_path}

func get_documentation(item_type, item_name):
    var documentation = ""
    
    match item_type:
        "class":
            if class_index.has(item_name):
                documentation = _extract_class_documentation(class_index[item_name].file, class_index[item_name].line)
        "function":
            for func_key in function_index:
                var parts = func_key.split(":", false, 1)
                if parts[1] == item_name:
                    documentation = _extract_function_documentation(class_index[parts[0]].file, function_index[func_key].line)
                    break
        "signal":
            for signal_key in signal_index:
                var parts = signal_key.split(":", false, 1)
                if parts[1] == item_name:
                    documentation = _extract_signal_documentation(class_index[parts[0]].file, signal_index[signal_key].line)
                    break
    
    return documentation

# Command processor for integrating with terminal
func process_command(args):
    if args.size() == 0:
        return _cmd_help()
    
    var command = args[0].to_lower()
    var command_args = args.slice(1)
    
    match command:
        "search":
            return _cmd_search(command_args)
        "analyze":
            return _cmd_analyze(command_args)
        "class":
            return _cmd_class(command_args)
        "function", "func":
            return _cmd_function(command_args)
        "signal":
            return _cmd_signal(command_args)
        "index":
            return _cmd_index(command_args)
        "hierarchy":
            return _cmd_hierarchy(command_args)
        "visualize":
            return _cmd_visualize(command_args)
        "stats":
            return _cmd_stats()
        "extract":
            return _cmd_extract(command_args)
        "help":
            return _cmd_help()
        _:
            return "Unknown command: " + command + "\nUse 'code godot help' for available commands"

# Private helper methods

func _load_index():
    if not FileAccess.file_exists(INDEX_PATH):
        print("No index file found at: " + INDEX_PATH)
        return false
    
    var file = FileAccess.open(INDEX_PATH, FileAccess.READ)
    var content = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var error = json.parse(content)
    
    if error == OK:
        var data = json.get_data()
        
        file_index = data.file_index
        class_index = data.class_index
        function_index = data.function_index
        signal_index = data.signal_index
        keyword_index = data.keyword_index
        
        total_files = data.stats.total_files
        total_lines = data.stats.total_lines
        total_classes = data.stats.total_classes
        total_functions = data.stats.total_functions
        total_signals = data.stats.total_signals
        
        print("Loaded index from: " + INDEX_PATH)
        return true
    else:
        print("Failed to parse index file: " + json.get_error_message())
        return false

func _save_index():
    var index_data = {
        "file_index": file_index,
        "class_index": class_index,
        "function_index": function_index,
        "signal_index": signal_index,
        "keyword_index": keyword_index,
        "stats": {
            "total_files": total_files,
            "total_lines": total_lines,
            "total_classes": total_classes,
            "total_functions": total_functions,
            "total_signals": total_signals,
            "updated_at": Time.get_datetime_string_from_system()
        }
    }
    
    var file = FileAccess.open(INDEX_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(index_data, "  "))
    file.close()
    
    print("Saved index to: " + INDEX_PATH)
    return true

func _init_research_db():
    # SQLite DB for storing research notes and code examples
    # This would use an SQLite plugin in a real implementation
    research_db = {}
    
    if FileAccess.file_exists(RESEARCH_DB_PATH):
        var file = FileAccess.open(RESEARCH_DB_PATH, FileAccess.READ)
        var content = file.get_as_text()
        file.close()
        
        var json = JSON.new()
        var error = json.parse(content)
        
        if error == OK:
            research_db = json.get_data()
            print("Loaded research database from: " + RESEARCH_DB_PATH)
        else:
            print("Failed to parse research database: " + json.get_error_message())
    else:
        # Initialize empty database
        research_db = {
            "notes": {},
            "examples": {},
            "tutorials": {},
            "created_at": Time.get_datetime_string_from_system(),
            "updated_at": Time.get_datetime_string_from_system()
        }
        
        # Save initial database
        _save_research_db()

func _save_research_db():
    var file = FileAccess.open(RESEARCH_DB_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(research_db, "  "))
    file.close()
    
    print("Saved research database to: " + RESEARCH_DB_PATH)
    return true

func _index_source_thread(source_path):
    # Reset indices
    file_index = {}
    class_index = {}
    function_index = {}
    signal_index = {}
    keyword_index = {}
    
    total_files = 0
    total_lines = 0
    total_classes = 0
    total_functions = 0
    total_signals = 0
    
    # List of extensions to index
    var extensions_to_index = [".h", ".c", ".cpp", ".hpp", ".cc", ".gd", ".shader"]
    
    # First pass: gather file list
    current_operation = "Scanning files"
    var file_list = _scan_directory_recursively(source_path, extensions_to_index)
    
    # Second pass: index files
    current_operation = "Indexing files"
    var file_count = file_list.size()
    var files_processed = 0
    
    for file_path in file_list:
        # Index file content
        _index_file(file_path)
        
        # Update progress
        files_processed += 1
        if files_processed % 100 == 0:
            var progress = float(files_processed) / file_count
            call_deferred("emit_signal", "code_indexed", {"status": "Indexing files: " + str(files_processed) + "/" + str(file_count), "progress": progress}, files_processed)
    
    # Save the index
    _save_index()
    
    # Complete indexing
    indexing_in_progress = false
    current_operation = "Idle"
    
    call_deferred("emit_signal", "code_indexed", {"status": "Indexing completed", "progress": 1.0}, file_count)
    
    return {"status": "complete", "files_indexed": file_count}

func _scan_directory_recursively(path, extensions_to_index):
    var file_list = []
    var dir = DirAccess.open(path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            var full_path = path.path_join(file_name)
            
            if dir.current_is_dir() and not file_name in [".git", ".github", "thirdparty"]:
                # Recursively scan subdirectories
                file_list.append_array(_scan_directory_recursively(full_path, extensions_to_index))
            elif not dir.current_is_dir():
                # Check if file has an extension we want to index
                var extension = "." + file_name.get_extension().to_lower()
                if extensions_to_index.has(extension):
                    file_list.append(full_path)
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    return file_list

func _index_file(file_path):
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        print("Failed to open file: " + file_path)
        return
    
    var content = file.get_as_text()
    file.close()
    
    # Store file in the index
    file_index[file_path] = {
        "path": file_path,
        "size": content.length(),
        "extension": file_path.get_extension().to_lower(),
        "indexed_at": Time.get_unix_time_from_system()
    }
    
    var lines = content.split("\n")
    var total_file_lines = lines.size()
    
    # Update stats
    total_files += 1
    total_lines += total_file_lines
    
    # Index file content
    _parse_file_content(file_path, lines)
    
    # Cache file in the code cache
    _cache_file_content(file_path, content)

func _parse_file_content(file_path, lines):
    var in_class = false
    var current_class = ""
    var line_number = 0
    
    var in_multiline_comment = false
    var pending_doc_comment = []
    
    for line in lines:
        line_number += 1
        var trimmed = line.strip_edges()
        
        # Handle multiline comments
        if trimmed.find("/*") >= 0 and trimmed.find("*/") < 0:
            in_multiline_comment = true
            pending_doc_comment.append(trimmed)
            continue
        
        if in_multiline_comment:
            pending_doc_comment.append(trimmed)
            if trimmed.find("*/") >= 0:
                in_multiline_comment = false
            continue
        
        # Handle class definitions
        var class_match = false
        
        # C++ class definition: class ClassName {
        if (trimmed.begins_with("class ") or trimmed.find(" class ") > 0) and (trimmed.find("{") > 0 or trimmed.ends_with(":")):
            var class_name = _extract_class_name(trimmed)
            if not class_name.empty():
                current_class = class_name
                in_class = true
                class_match = true
                
                # Extract inherits info
                var inherits = ""
                if trimmed.find(":") > 0:
                    var parts = trimmed.split(":", false, 1)
                    var inherits_part = parts[1].strip_edges()
                    
                    # Handle different inheritance syntax (C++, GDScript)
                    var inherits_match = inherits_part.match("* extends *")
                    if inherits_match:
                        inherits = inherits_match[1].strip_edges()
                    else:
                        # Try to extract the first class after visibility specifier
                        var words = inherits_part.split(" ", false)
                        for i in range(words.size()):
                            if words[i] in ["public", "protected", "private"]:
                                if i + 1 < words.size():
                                    inherits = words[i + 1].replace(",", "").strip_edges()
                                    break
                
                # Add to index
                class_index[class_name] = {
                    "name": class_name,
                    "file": file_path,
                    "line": line_number,
                    "inherits": inherits,
                    "methods": [],
                    "signals": [],
                    "doc_comment": _format_doc_comment(pending_doc_comment)
                }
                
                total_classes += 1
                _add_to_keyword_index(class_name, "class", file_path)
                
                # Clear pending doc comment
                pending_doc_comment = []
        
        # GDScript class definition: class_name ClassName
        elif trimmed.begins_with("class_name "):
            var parts = trimmed.split(" ", false, 1)
            if parts.size() > 1:
                current_class = parts[1].strip_edges()
                in_class = true
                class_match = true
                
                # Extract inherits info
                var inherits = ""
                # Look for "extends" on this line or nearby lines
                for i in range(line_number, min(line_number + 5, lines.size())):
                    var ext_line = lines[i].strip_edges()
                    if ext_line.begins_with("extends "):
                        var ext_parts = ext_line.split(" ", false, 1)
                        if ext_parts.size() > 1:
                            inherits = ext_parts[1].strip_edges()
                            break
                
                # Add to index
                class_index[current_class] = {
                    "name": current_class,
                    "file": file_path,
                    "line": line_number,
                    "inherits": inherits,
                    "methods": [],
                    "signals": [],
                    "doc_comment": _format_doc_comment(pending_doc_comment)
                }
                
                total_classes += 1
                _add_to_keyword_index(current_class, "class", file_path)
                
                # Clear pending doc comment
                pending_doc_comment = []
        
        if not class_match and trimmed.begins_with("# "):
            # This might be a doc comment
            pending_doc_comment.append(trimmed)
            continue
        
        # If not a doc comment, clear the pending comments
        if not trimmed.empty() and not trimmed.begins_with("#") and not class_match:
            pending_doc_comment = []
        
        # Handle function definitions
        if in_class and (trimmed.begins_with("func ") or trimmed.find(" func ") > 0 or 
                        trimmed.begins_with("function ") or trimmed.find(" function ") > 0 or
                        trimmed.find("(") > 0 and (trimmed.find("{") > 0 or trimmed.ends_with(":"))):
            
            var func_name = _extract_function_name(trimmed)
            if not func_name.empty() and not func_name.begins_with("_") and func_name.is_valid_identifier():
                var return_type = ""
                var arguments = _extract_function_arguments(trimmed)
                
                # Extract return type
                if trimmed.find("->") > 0:
                    var parts = trimmed.split("->", false, 1)
                    return_type = parts[1].strip_edges()
                    if return_type.ends_with(":"):
                        return_type = return_type.substr(0, return_type.length() - 1).strip_edges()
                
                # Add to function index
                var func_key = current_class + ":" + func_name
                function_index[func_key] = {
                    "name": func_name,
                    "class": current_class,
                    "file": file_path,
                    "line": line_number,
                    "return_type": return_type,
                    "arguments": arguments,
                    "doc_comment": _format_doc_comment(pending_doc_comment)
                }
                
                total_functions += 1
                _add_to_keyword_index(func_name, "function", func_key)
                
                # Clear pending doc comment
                pending_doc_comment = []
        
        # Handle signal definitions
        if in_class and trimmed.begins_with("signal "):
            var signal_name = _extract_signal_name(trimmed)
            if not signal_name.empty():
                var arguments = []
                
                # Extract signal arguments
                if trimmed.find("(") > 0 and trimmed.find(")") > 0:
                    var arg_str = trimmed.substr(trimmed.find("(") + 1, trimmed.find(")") - trimmed.find("(") - 1)
                    arguments = _parse_signal_arguments(arg_str)
                
                # Add to signal index
                var signal_key = current_class + ":" + signal_name
                signal_index[signal_key] = {
                    "name": signal_name,
                    "class": current_class,
                    "file": file_path,
                    "line": line_number,
                    "arguments": arguments,
                    "doc_comment": _format_doc_comment(pending_doc_comment)
                }
                
                total_signals += 1
                _add_to_keyword_index(signal_name, "signal", signal_key)
                
                # Clear pending doc comment
                pending_doc_comment = []
        
        # Check for end of class
        if in_class and (trimmed == "}" or (trimmed.ends_with("}") and trimmed.find("class") < 0)):
            in_class = false
            current_class = ""

func _cache_file_content(file_path, content):
    # Cache file in the code cache for quick access
    var cache_path = GODOT_SOURCE_CACHE + file_path.md5_text() + ".cache"
    var cache_dir = cache_path.get_base_dir()
    
    var dir = DirAccess.open("res://")
    if not dir.dir_exists(cache_dir):
        dir.make_dir_recursive(cache_dir)
    
    var file = FileAccess.open(cache_path, FileAccess.WRITE)
    file.store_string(content)
    file.close()

func _read_file_from_index(file_path):
    # Read file from cache
    var cache_path = GODOT_SOURCE_CACHE + file_path.md5_text() + ".cache"
    
    if FileAccess.file_exists(cache_path):
        var file = FileAccess.open(cache_path, FileAccess.READ)
        var content = file.get_as_text()
        file.close()
        return content
    
    # Fall back to reading from actual file
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var content = file.get_as_text()
        file.close()
        return content
    
    return ""

func _extract_class_name(line):
    # C++ style: class ClassName { or class ClassName : public BaseClass {
    if line.find("class ") >= 0:
        var parts = line.split("class ", false, 1)
        if parts.size() > 1:
            var class_part = parts[1].strip_edges()
            var end_idx = class_part.find(" ")
            if end_idx < 0:
                end_idx = class_part.find("{")
            if end_idx < 0:
                end_idx = class_part.find(":")
            if end_idx < 0:
                end_idx = class_part.length()
            
            var class_name = class_part.substr(0, end_idx).strip_edges()
            if class_name.is_valid_identifier():
                return class_name
    
    # GDScript style: class_name ClassName
    if line.begins_with("class_name "):
        var parts = line.split(" ", false, 1)
        if parts.size() > 1:
            var class_name = parts[1].strip_edges()
            if class_name.is_valid_identifier():
                return class_name
    
    return ""

func _extract_function_name(line):
    # GDScript style: func function_name(...):
    if line.find("func ") >= 0:
        var parts = line.split("func ", false, 1)
        if parts.size() > 1:
            var func_part = parts[1].strip_edges()
            var end_idx = func_part.find("(")
            if end_idx < 0:
                end_idx = func_part.find(" ")
            if end_idx < 0:
                end_idx = func_part.length()
            
            var func_name = func_part.substr(0, end_idx).strip_edges()
            if func_name.is_valid_identifier():
                return func_name
    
    # C++ style: ReturnType function_name(...) {
    var open_paren = line.find("(")
    if open_paren > 0:
        var func_part = line.substr(0, open_paren).strip_edges()
        var parts = func_part.split(" ")
        
        if parts.size() > 0:
            var func_name = parts[parts.size() - 1].strip_edges()
            if func_name.is_valid_identifier():
                return func_name
    
    return ""

func _extract_function_arguments(line):
    var arguments = []
    
    if line.find("(") > 0 and line.find(")") > 0:
        var arg_str = line.substr(line.find("(") + 1, line.find(")") - line.find("(") - 1)
        var args = arg_str.split(",")
        
        for arg in args:
            var arg_parts = arg.strip_edges().split(":", false, 1)
            var arg_name = arg_parts[0].strip_edges()
            var arg_type = ""
            
            if arg_parts.size() > 1:
                arg_type = arg_parts[1].strip_edges()
            
            if not arg_name.empty():
                arguments.append({
                    "name": arg_name,
                    "type": arg_type
                })
    
    return arguments

func _extract_signal_name(line):
    if line.begins_with("signal "):
        var parts = line.split(" ", false, 1)
        if parts.size() > 1:
            var signal_part = parts[1].strip_edges()
            var end_idx = signal_part.find("(")
            if end_idx < 0:
                end_idx = signal_part.length()
            
            var signal_name = signal_part.substr(0, end_idx).strip_edges()
            if signal_name.is_valid_identifier():
                return signal_name
    
    return ""

func _parse_signal_arguments(arg_str):
    var arguments = []
    var args = arg_str.split(",")
    
    for arg in args:
        var arg_parts = arg.strip_edges().split(":", false, 1)
        var arg_name = arg_parts[0].strip_edges()
        var arg_type = ""
        
        if arg_parts.size() > 1:
            arg_type = arg_parts[1].strip_edges()
        
        if not arg_name.empty():
            arguments.append({
                "name": arg_name,
                "type": arg_type
            })
    
    return arguments

func _format_doc_comment(comments):
    if comments.size() == 0:
        return ""
    
    var formatted = ""
    
    for line in comments:
        # Remove comment markers
        var text = line
        text = text.replace("/**", "").replace("*/", "")
        text = text.replace("/*", "").replace("*/", "")
        text = text.replace("#", "").replace("//", "")
        text = text.strip_edges()
        
        if not text.empty():
            formatted += text + "\n"
    
    return formatted.strip_edges()

func _add_to_keyword_index(keyword, type, identifier):
    var normalized = keyword.to_lower()
    
    if not keyword_index.has(normalized):
        keyword_index[normalized] = {
            "files": {},
            "classes": {},
            "functions": {}
        }
    
    match type:
        "class":
            keyword_index[normalized].files[identifier] = 100
            keyword_index[normalized].classes[keyword] = 100
        "function":
            var parts = identifier.split(":", false, 1)
            if parts.size() > 1:
                var class_name = parts[0]
                keyword_index[normalized].files[class_index[class_name].file] = 80
                keyword_index[normalized].functions[identifier] = 100
        "signal":
            var parts = identifier.split(":", false, 1)
            if parts.size() > 1:
                var class_name = parts[0]
                keyword_index[normalized].files[class_index[class_name].file] = 80

func _find_usage_examples(class_name, function_name):
    var examples = []
    var max_examples = 3
    
    # Find files that might use this function
    var files_to_search = []
    
    for file_path in file_index:
        var content = _read_file_from_index(file_path)
        
        # Quick check if file might contain the function call
        if content.find(function_name + "(") >= 0:
            files_to_search.append(file_path)
        
        if files_to_search.size() >= 10:
            break
    
    # Search for actual usage
    for file_path in files_to_search:
        var content = _read_file_from_index(file_path)
        var lines = content.split("\n")
        
        for i in range(lines.size()):
            var line = lines[i].strip_edges()
            
            # Look for function calls
            if (line.find(class_name + "." + function_name + "(") >= 0 or 
                line.find(function_name + "(") >= 0 and not line.find("func " + function_name) >= 0):
                
                var example = {
                    "file": file_path,
                    "line": i + 1,
                    "code": line,
                    "context": _get_code_context(lines, i)
                }
                
                examples.append(example)
                
                if examples.size() >= max_examples:
                    break
        
        if examples.size() >= max_examples:
            break
    
    return examples

func _find_class_usage_examples(class_name):
    var examples = []
    var max_examples = 3
    
    # Find files that might use this class
    var files_to_search = []
    
    for file_path in file_index:
        var content = _read_file_from_index(file_path)
        
        # Quick check if file might contain the class
        if content.find(class_name) >= 0:
            files_to_search.append(file_path)
        
        if files_to_search.size() >= 10:
            break
    
    # Search for actual usage
    for file_path in files_to_search:
        var content = _read_file_from_index(file_path)
        var lines = content.split("\n")
        
        for i in range(lines.size()):
            var line = lines[i].strip_edges()
            
            # Look for class instantiation or extends
            if (line.find("var") >= 0 and line.find(class_name) >= 0 and line.find("=") >= 0 or
                line.find("extends " + class_name) >= 0 or
                line.find(class_name + ".new(") >= 0):
                
                var example = {
                    "file": file_path,
                    "line": i + 1,
                    "code": line,
                    "context": _get_code_context(lines, i)
                }
                
                examples.append(example)
                
                if examples.size() >= max_examples:
                    break
        
        if examples.size() >= max_examples:
            break
    
    return examples

func _find_signal_usage_examples(class_name, signal_name):
    var examples = []
    
    # Find emit examples
    var emit_examples = _find_emit_examples(class_name, signal_name)
    
    # Find connect examples
    var connect_examples = _find_connect_examples(class_name, signal_name)
    
    # Combine results
    examples.append_array(emit_examples)
    examples.append_array(connect_examples)
    
    return examples

func _find_emit_examples(class_name, signal_name):
    var examples = []
    var max_examples = 2
    
    for file_path in file_index:
        var content = _read_file_from_index(file_path)
        var lines = content.split("\n")
        
        for i in range(lines.size()):
            var line = lines[i].strip_edges()
            
            if (line.find("emit_signal(\"" + signal_name + "\"") >= 0 or
                line.find("emit_signal(\"" + signal_name + "\"") >= 0):
                
                var example = {
                    "file": file_path,
                    "line": i + 1,
                    "code": line,
                    "context": _get_code_context(lines, i),
                    "type": "emit"
                }
                
                examples.append(example)
                
                if examples.size() >= max_examples:
                    break
        
        if examples.size() >= max_examples:
            break
    
    return examples

func _find_connect_examples(class_name, signal_name):
    var examples = []
    var max_examples = 2
    
    for file_path in file_index:
        var content = _read_file_from_index(file_path)
        var lines = content.split("\n")
        
        for i in range(lines.size()):
            var line = lines[i].strip_edges()
            
            if (line.find("connect(\"" + signal_name + "\"") >= 0 or
                line.find("connect(\"" + signal_name + "\"") >= 0):
                
                var example = {
                    "file": file_path,
                    "line": i + 1,
                    "code": line,
                    "context": _get_code_context(lines, i),
                    "type": "connect"
                }
                
                examples.append(example)
                
                if examples.size() >= max_examples:
                    break
        
        if examples.size() >= max_examples:
            break
    
    return examples

func _get_code_context(lines, line_index):
    var context = []
    var context_size = 3  # Number of lines before and after
    
    var start = max(0, line_index - context_size)
    var end = min(lines.size() - 1, line_index + context_size)
    
    for i in range(start, end + 1):
        context.append({
            "line": i + 1,
            "code": lines[i],
            "current": i == line_index
        })
    
    return context

func _extract_class_documentation(file_path, line_number):
    var content = _read_file_from_index(file_path)
    var lines = content.split("\n")
    
    # Look for comments above class definition
    var start_line = max(0, line_number - 20)
    var docs = []
    var in_doc_comment = false
    
    for i in range(start_line, line_number):
        var line = lines[i].strip_edges()
        
        if line.begins_with("/**") or line.begins_with("/*"):
            in_doc_comment = true
            docs.append(line)
        elif in_doc_comment:
            docs.append(line)
            if line.find("*/") >= 0:
                in_doc_comment = false
        elif line.begins_with("//") or line.begins_with("#"):
            docs.append(line)
        elif line.empty():
            # Skip empty lines
            continue
        else:
            # Non-comment, non-empty line, clear docs unless we're right before the class
            if i < line_number - 1:
                docs = []
    
    return _format_doc_comment(docs)

func _extract_function_documentation(file_path, line_number):
    # Similar to class documentation extraction
    return _extract_class_documentation(file_path, line_number)

func _extract_signal_documentation(file_path, line_number):
    # Similar to class documentation extraction
    return _extract_class_documentation(file_path, line_number)

func _generate_overall_structure():
    var structure = {
        "name": "Godot Engine",
        "children": []
    }
    
    # Group classes by module/category
    var modules = {}
    
    for class_name in class_index:
        var file_path = class_index[class_name].file
        
        # Determine module from file path
        var module = "core"
        
        if file_path.find("/scene/") >= 0:
            module = "scene"
        elif file_path.find("/servers/") >= 0:
            module = "servers"
        elif file_path.find("/editor/") >= 0:
            module = "editor"
        elif file_path.find("/platform/") >= 0:
            module = "platform"
        elif file_path.find("/drivers/") >= 0:
            module = "drivers"
        elif file_path.find("/modules/") >= 0:
            module = "modules/" + file_path.split("/modules/")[1].split("/")[0]
        
        if not modules.has(module):
            modules[module] = []
        
        modules[module].append(class_name)
    
    # Add modules to structure
    for module in modules:
        var module_node = {
            "name": module,
            "children": []
        }
        
        for class_name in modules[module]:
            module_node.children.append({
                "name": class_name,
                "type": "class"
            })
        
        structure.children.append(module_node)
    
    return structure

func _generate_file_structure(file_path):
    if not file_index.has(file_path):
        return []
    
    var content = _read_file_from_index(file_path)
    var lines = content.split("\n")
    
    var structure = []
    var current_indent = 0
    var indent_stack = []
    var context_stack = []
    
    for i in range(lines.size()):
        var line = lines[i]
        var trimmed = line.strip_edges()
        
        # Skip empty lines and comments
        if trimmed.empty() or trimmed.begins_with("#") or trimmed.begins_with("//"):
            continue
        
        # Calculate indentation
        var indent = line.length() - line.strip_edges(true, false).length()
        
        # Handle class definitions
        if trimmed.begins_with("class ") or trimmed.begins_with("class_name "):
            var class_name = _extract_class_name(trimmed)
            
            if not class_name.empty():
                var node = {
                    "type": "class",
                    "name": class_name,
                    "line": i + 1,
                    "children": []
                }
                
                while indent_stack.size() > 0 and indent <= indent_stack[indent_stack.size() - 1]:
                    indent_stack.pop_back()
                    context_stack.pop_back()
                
                if context_stack.size() > 0:
                    context_stack[context_stack.size() - 1].children.append(node)
                else:
                    structure.append(node)
                
                indent_stack.append(indent)
                context_stack.append(node)
        
        # Handle function definitions
        elif trimmed.begins_with("func ") or trimmed.begins_with("static func "):
            var func_name = _extract_function_name(trimmed)
            
            if not func_name.empty():
                var node = {
                    "type": "function",
                    "name": func_name,
                    "line": i + 1,
                    "children": []
                }
                
                while indent_stack.size() > 0 and indent <= indent_stack[indent_stack.size() - 1]:
                    indent_stack.pop_back()
                    context_stack.pop_back()
                
                if context_stack.size() > 0:
                    context_stack[context_stack.size() - 1].children.append(node)
                else:
                    structure.append(node)
                
                indent_stack.append(indent)
                context_stack.append(node)
        
        # Handle signal definitions
        elif trimmed.begins_with("signal "):
            var signal_name = _extract_signal_name(trimmed)
            
            if not signal_name.empty():
                var node = {
                    "type": "signal",
                    "name": signal_name,
                    "line": i + 1
                }
                
                if context_stack.size() > 0:
                    context_stack[context_stack.size() - 1].children.append(node)
                else:
                    structure.append(node)
    
    return structure

func _format_hierarchy_for_visualization(hierarchy):
    var result = []
    
    # Start with base classes (those that don't inherit or inherit from Object)
    for class_name in hierarchy:
        var class_data = hierarchy[class_name]
        
        if class_data.inherits.empty() or class_data.inherits == "Object" or class_data.inherits == "Reference":
            var node = _build_hierarchy_node(class_name, hierarchy)
            result.append(node)
    
    return result

func _build_hierarchy_node(class_name, hierarchy):
    var node = {
        "name": class_name,
        "children": []
    }
    
    if not hierarchy.has(class_name):
        return node
    
    var class_data = hierarchy[class_name]
    
    for child_class in class_data.children:
        var child_node = _build_hierarchy_node(child_class, hierarchy)
        node.children.append(child_node)
    
    return node

# Command implementations

func _cmd_search(args):
    if args.size() == 0:
        return "Usage: code godot search <search_term>"
    
    var search_term = args.join(" ")
    var results = search_code(search_term)
    
    if results.has("error"):
        return "Error: " + results.error
    
    var result_text = "Search Results for '" + search_term + "':\n\n"
    
    # Format classes
    if results.has("classes") and results.classes.size() > 0:
        result_text += "Classes:\n"
        for i in range(min(5, results.classes.size())):
            var class_data = results.classes[i]
            result_text += "- " + class_data.name
            if class_data.has("file"):
                result_text += " (" + class_data.file.get_file() + ")"
            result_text += "\n"
        result_text += "\n"
    
    # Format functions
    if results.has("functions") and results.functions.size() > 0:
        result_text += "Functions:\n"
        for i in range(min(5, results.functions.size())):
            var func_data = results.functions[i]
            result_text += "- " + func_data.class + "." + func_data.name + "()"
            if func_data.has("file"):
                result_text += " (" + func_data.file.get_file() + ")"
            result_text += "\n"
        result_text += "\n"
    
    # Format usages
    if results.has("usages") and results.usages.size() > 0:
        result_text += "Usage Examples:\n"
        for i in range(min(3, results.usages.size())):
            var usage = results.usages[i]
            result_text += "- " + usage.file.get_file() + ":" + str(usage.line) + "\n"
            result_text += "  " + usage.code.strip_edges() + "\n"
        result_text += "\n"
    
    # If no results
    if (not results.has("classes") or results.classes.size() == 0) and
       (not results.has("functions") or results.functions.size() == 0) and
       (not results.has("signals") or results.signals.size() == 0) and
       (not results.has("usages") or results.usages.size() == 0):
        result_text += "No results found for '" + search_term + "'\n"
    
    return result_text

func _cmd_analyze(args):
    if args.size() == 0:
        return "Usage: code godot analyze <file_path>"
    
    var file_path = args[0]
    
    if not file_path.begins_with("/"):
        # Try to find the file in the index
        var found = false
        
        for indexed_path in file_index:
            if indexed_path.find(file_path) >= 0:
                file_path = indexed_path
                found = true
                break
        
        if not found:
            return "File not found: " + file_path + "\nSpecify the full path or a unique filename"
    
    var metrics = analyze_file(file_path)
    
    if metrics.has("error"):
        return "Error: " + metrics.error
    
    var result = "Analysis for " + file_path + ":\n\n"
    result += "Lines: " + str(metrics.line_count) + " total\n"
    result += "Code: " + str(metrics.code_lines) + " lines\n"
    result += "Comments: " + str(metrics.comment_lines) + " lines\n"
    result += "Blank: " + str(metrics.blank_lines) + " lines\n"
    result += "Classes: " + str(metrics.classes.size()) + "\n"
    result += "Functions: " + str(metrics.functions.size()) + "\n"
    result += "Signals: " + str(metrics.signals.size()) + "\n"
    result += "Complexity: " + str(metrics.complexity) + "\n"
    
    return result

func _cmd_class(args):
    if args.size() == 0:
        return "Usage: code godot class <class_name>"
    
    var class_name = args[0]
    var results = search_for_class(class_name)
    
    if results.classes.size() == 0:
        return "Class not found: " + class_name
    
    var result = "Class: " + results.classes[0].name + "\n"
    result += "File: " + results.classes[0].file + "\n"
    
    if not results.classes[0].inherits.empty():
        result += "Inherits: " + results.classes[0].inherits + "\n"
    
    if results.derived_classes.size() > 0:
        result += "\nDerived Classes:\n"
        for derived in results.derived_classes:
            result += "- " + derived.name + "\n"
    
    if results.methods.size() > 0:
        result += "\nMethods:\n"
        for method in results.methods:
            var args_str = ""
            for arg in method.arguments:
                if args_str.length() > 0:
                    args_str += ", "
                args_str += arg.name
                if not arg.type.empty():
                    args_str += ": " + arg.type
            
            result += "- " + method.name + "(" + args_str + ")"
            if not method.return_type.empty():
                result += " -> " + method.return_type
            result += "\n"
    
    if results.signals.size() > 0:
        result += "\nSignals:\n"
        for signal_data in results.signals:
            var args_str = ""
            for arg in signal_data.arguments:
                if args_str.length() > 0:
                    args_str += ", "
                args_str += arg.name
                if not arg.type.empty():
                    args_str += ": " + arg.type
            
            result += "- " + signal_data.name + "(" + args_str + ")\n"
    
    return result

func _cmd_function(args):
    if args.size() == 0:
        return "Usage: code godot function <function_name>"
    
    var function_name = args[0]
    var results = search_for_function(function_name)
    
    if results.functions.size() == 0:
        return "Function not found: " + function_name
    
    var result = "Function Results:\n\n"
    
    for func_data in results.functions:
        var args_str = ""
        for arg in func_data.arguments:
            if args_str.length() > 0:
                args_str += ", "
            args_str += arg.name
            if not arg.type.empty():
                args_str += ": " + arg.type
        
        result += func_data.class + "." + func_data.name + "(" + args_str + ")"
        if not func_data.return_type.empty():
            result += " -> " + func_data.return_type
        result += "\n"
        result += "File: " + func_data.file + ":" + str(func_data.line) + "\n\n"
    
    if results.usages.size() > 0:
        result += "Usage Examples:\n"
        for usage in results.usages:
            result += usage.file.get_file() + ":" + str(usage.line) + "\n"
            result += usage.code.strip_edges() + "\n\n"
    
    return result

func _cmd_signal(args):
    if args.size() == 0:
        return "Usage: code godot signal <signal_name>"
    
    var signal_name = args[0]
    var results = search_for_signal(signal_name)
    
    if results.signals.size() == 0:
        return "Signal not found: " + signal_name
    
    var result = "Signal Results:\n\n"
    
    for signal_data in results.signals:
        var args_str = ""
        for arg in signal_data.arguments:
            if args_str.length() > 0:
                args_str += ", "
            args_str += arg.name
            if not arg.type.empty():
                args_str += ": " + arg.type
        
        result += signal_data.class + "." + signal_data.name + "(" + args_str + ")\n"
        result += "File: " + signal_data.file + ":" + str(signal_data.line) + "\n\n"
    
    if results.usages.size() > 0:
        result += "Usage Examples:\n"
        for usage in results.usages:
            result += "Type: " + usage.type + "\n"
            result += usage.file.get_file() + ":" + str(usage.line) + "\n"
            result += usage.code.strip_edges() + "\n\n"
    
    return result

func _cmd_index(args):
    if indexing_in_progress:
        return "Indexing already in progress: " + current_operation
    
    var source_path = ""
    if args.size() > 0:
        source_path = args[0]
    
    var result = index_godot_source(source_path)
    
    if result.has("error"):
        return "Error: " + result.error
    
    return "Started indexing Godot source code.\nThis may take a few minutes."

func _cmd_hierarchy(args):
    var result = build_class_hierarchy()
    
    if typeof(result) == TYPE_DICTIONARY and result.has("error"):
        return "Error: " + result.error
    
    # Return a simplified version of the hierarchy
    var output = "Class Hierarchy:\n\n"
    
    for base_class in result:
        output += _format_hierarchy_node_text(base_class, 0)
    
    return output

func _format_hierarchy_node_text(node, indent):
    var result = ""
    var indent_str = ""
    
    for i in range(indent):
        indent_str += "  "
    
    result += indent_str + "- " + node.name + "\n"
    
    for child in node.children:
        result += _format_hierarchy_node_text(child, indent + 1)
    
    return result

func _cmd_visualize(args):
    if args.size() == 0:
        return "Usage: code godot visualize [file_path]"
    
    var file_path = ""
    if args.size() > 0:
        file_path = args[0]
    
    var structure = visualize_code_structure(file_path)
    
    if typeof(structure) == TYPE_DICTIONARY and structure.has("error"):
        return "Error: " + structure.error
    
    # Return a text representation of the structure
    var output = "Code Structure Visualization:\n\n"
    
    if file_path.empty():
        # Overall structure
        for module in structure.children:
            output += "Module: " + module.name + "\n"
            output += "  Classes: " + str(module.children.size()) + "\n\n"
        
        output += "Use 'code godot visualize <file_path>' for detailed file structure"
    else:
        # File structure
        for item in structure:
            output += _format_structure_item(item, 0)
    
    return output

func _format_structure_item(item, indent):
    var result = ""
    var indent_str = ""
    
    for i in range(indent):
        indent_str += "  "
    
    result += indent_str + "- " + item.type + ": " + item.name + " (line " + str(item.line) + ")\n"
    
    if item.has("children"):
        for child in item.children:
            result += _format_structure_item(child, indent + 1)
    
    return result

func _cmd_stats():
    var result = "Godot Engine Source Code Statistics:\n\n"
    
    result += "Files: " + str(total_files) + "\n"
    result += "Lines: " + str(total_lines) + "\n"
    result += "Classes: " + str(total_classes) + "\n"
    result += "Functions: " + str(total_functions) + "\n"
    result += "Signals: " + str(total_signals) + "\n"
    
    if file_index.size() > 0:
        # Count file types
        var extensions = {}
        
        for file_path in file_index:
            var ext = file_path.get_extension().to_lower()
            if not extensions.has(ext):
                extensions[ext] = 0
            extensions[ext] += 1
        
        result += "\nFile Types:\n"
        for ext in extensions:
            result += "." + ext + ": " + str(extensions[ext]) + " files\n"
    
    return result

func _cmd_extract(args):
    if args.size() < 2:
        return "Usage: code godot extract <type> <name>\nTypes: class, function, signal"
    
    var type = args[0]
    var name = args[1]
    
    var documentation = get_documentation(type, name)
    
    if documentation.empty():
        return "No documentation found for " + type + " '" + name + "'"
    
    return "Documentation for " + type + " '" + name + "':\n\n" + documentation

func _cmd_help():
    return "Godot Research System Commands:\n\n" + \
           "search <term>      - Search for classes, functions, or signals\n" + \
           "analyze <file>     - Analyze a source file\n" + \
           "class <name>       - Get information about a class\n" + \
           "function <name>    - Get information about a function\n" + \
           "signal <name>      - Get information about a signal\n" + \
           "index [path]       - Index the Godot source code\n" + \
           "hierarchy          - Show the class inheritance hierarchy\n" + \
           "visualize [file]   - Visualize code structure\n" + \
           "stats              - Show source code statistics\n" + \
           "extract <type> <name> - Extract documentation\n" + \
           "help               - Show this help message\n\n" + \
           "Special search patterns:\n" + \
           "- class:Name       - Search for specific class\n" + \
           "- func:Name        - Search for specific function\n" + \
           "- signal:Name      - Search for specific signal\n" + \
           "- extends:Name     - Find classes inheriting from base class"