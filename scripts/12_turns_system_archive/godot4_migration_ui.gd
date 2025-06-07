class_name Godot4MigrationUI
extends Control

# ----- UI COMPONENTS -----
@onready var godot3_path_input = $Paths/Godot3Path/LineEdit
@onready var godot4_path_input = $Paths/Godot4Path/LineEdit
@onready var browse_godot3_button = $Paths/Godot3Path/BrowseButton
@onready var browse_godot4_button = $Paths/Godot4Path/BrowseButton

@onready var backup_checkbox = $Options/BackupCheckbox
@onready var auto_fix_checkbox = $Options/AutoFixCheckbox
@onready var migrate_resources_checkbox = $Options/MigrateResourcesCheckbox
@onready var verbose_checkbox = $Options/VerboseCheckbox

@onready var progress_bar = $Progress/ProgressBar
@onready var status_label = $Progress/StatusLabel
@onready var start_button = $Progress/StartButton
@onready var report_button = $Progress/ReportButton

@onready var log_text = $Log/LogText
@onready var file_tree = $Files/FileTree
@onready var file_dialog = $FileDialog

# ----- MIGRATION TOOL -----
var migration_tool = null

# ----- STATE VARIABLES -----
var is_migrating = false
var current_file = 0
var total_files = 0
var selected_dir = ""
var migration_stats = {}
var file_status = {}

# ----- SIGNALS -----
signal migration_complete()

# ----- INITIALIZATION -----
func _ready():
    _setup_ui()
    _connect_signals()
    _find_migration_tool()
    
    _update_status("Ready to migrate. Please select project paths.")
    print("Godot 4 Migration UI initialized")

func _setup_ui():
    # Set up UI components
    if not is_instance_valid(godot3_path_input):
        # Create UI components if not using scene
        _create_ui_components()
    
    # Initialize UI state
    start_button.disabled = true
    report_button.disabled = true
    progress_bar.value = 0
    progress_bar.max_value = 100

func _create_ui_components():
    # Create UI components if not using scene
    # This is just a fallback for when the UI is not instantiated from a scene
    
    # Create layout containers
    var main_vbox = VBoxContainer.new()
    main_vbox.set_anchors_preset(PRESET_FULL_RECT)
    add_child(main_vbox)
    
    # Create path section
    var paths_section = VBoxContainer.new()
    main_vbox.add_child(paths_section)
    
    var paths_label = Label.new()
    paths_label.text = "Project Paths"
    paths_section.add_child(paths_label)
    
    # Godot 3 path
    var godot3_hbox = HBoxContainer.new()
    paths_section.add_child(godot3_hbox)
    
    var godot3_label = Label.new()
    godot3_label.text = "Godot 3 Project:"
    godot3_hbox.add_child(godot3_label)
    
    godot3_path_input = LineEdit.new()
    godot3_path_input.size_flags_horizontal = SIZE_EXPAND_FILL
    godot3_hbox.add_child(godot3_path_input)
    
    browse_godot3_button = Button.new()
    browse_godot3_button.text = "Browse"
    godot3_hbox.add_child(browse_godot3_button)
    
    # Godot 4 path
    var godot4_hbox = HBoxContainer.new()
    paths_section.add_child(godot4_hbox)
    
    var godot4_label = Label.new()
    godot4_label.text = "Godot 4 Project:"
    godot4_hbox.add_child(godot4_label)
    
    godot4_path_input = LineEdit.new()
    godot4_path_input.size_flags_horizontal = SIZE_EXPAND_FILL
    godot4_hbox.add_child(godot4_path_input)
    
    browse_godot4_button = Button.new()
    browse_godot4_button.text = "Browse"
    godot4_hbox.add_child(browse_godot4_button)
    
    # Options section
    var options_section = VBoxContainer.new()
    main_vbox.add_child(options_section)
    
    var options_label = Label.new()
    options_label.text = "Migration Options"
    options_section.add_child(options_label)
    
    backup_checkbox = CheckBox.new()
    backup_checkbox.text = "Create backup before migration"
    backup_checkbox.pressed = true
    options_section.add_child(backup_checkbox)
    
    auto_fix_checkbox = CheckBox.new()
    auto_fix_checkbox.text = "Auto-fix deprecated features"
    auto_fix_checkbox.pressed = true
    options_section.add_child(auto_fix_checkbox)
    
    migrate_resources_checkbox = CheckBox.new()
    migrate_resources_checkbox.text = "Migrate resources (.tres, .tscn)"
    migrate_resources_checkbox.pressed = true
    options_section.add_child(migrate_resources_checkbox)
    
    verbose_checkbox = CheckBox.new()
    verbose_checkbox.text = "Verbose logging"
    verbose_checkbox.pressed = true
    options_section.add_child(verbose_checkbox)
    
    # Progress section
    var progress_section = VBoxContainer.new()
    main_vbox.add_child(progress_section)
    
    var progress_label = Label.new()
    progress_label.text = "Migration Progress"
    progress_section.add_child(progress_label)
    
    progress_bar = ProgressBar.new()
    progress_bar.min_value = 0
    progress_bar.max_value = 100
    progress_bar.value = 0
    progress_bar.size_flags_horizontal = SIZE_EXPAND_FILL
    progress_section.add_child(progress_bar)
    
    status_label = Label.new()
    status_label.text = "Ready"
    progress_section.add_child(status_label)
    
    var button_hbox = HBoxContainer.new()
    progress_section.add_child(button_hbox)
    
    start_button = Button.new()
    start_button.text = "Start Migration"
    start_button.disabled = true
    button_hbox.add_child(start_button)
    
    report_button = Button.new()
    report_button.text = "Generate Report"
    report_button.disabled = true
    button_hbox.add_child(report_button)
    
    # Log section
    var log_section = VBoxContainer.new()
    main_vbox.add_child(log_section)
    log_section.size_flags_vertical = SIZE_EXPAND_FILL
    
    var log_label = Label.new()
    log_label.text = "Migration Log"
    log_section.add_child(log_label)
    
    log_text = TextEdit.new()
    log_text.editable = false
    log_text.size_flags_vertical = SIZE_EXPAND_FILL
    log_section.add_child(log_text)
    
    # File tree section
    var files_section = VBoxContainer.new()
    main_vbox.add_child(files_section)
    files_section.size_flags_vertical = SIZE_EXPAND_FILL
    
    var files_label = Label.new()
    files_label.text = "Project Files"
    files_section.add_child(files_label)
    
    file_tree = Tree.new()
    file_tree.size_flags_vertical = SIZE_EXPAND_FILL
    files_section.add_child(file_tree)
    
    # File dialog
    file_dialog = FileDialog.new()
    file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
    add_child(file_dialog)

func _connect_signals():
    # Connect UI signals
    browse_godot3_button.pressed.connect(_on_browse_godot3_pressed)
    browse_godot4_button.pressed.connect(_on_browse_godot4_pressed)
    
    start_button.pressed.connect(_on_start_pressed)
    report_button.pressed.connect(_on_report_pressed)
    
    godot3_path_input.text_changed.connect(_on_path_changed)
    godot4_path_input.text_changed.connect(_on_path_changed)
    
    file_dialog.dir_selected.connect(_on_dir_selected)
    
    # Connect migration tool signals if available
    if migration_tool:
        migration_tool.migration_started.connect(_on_migration_started)
        migration_tool.migration_completed.connect(_on_migration_completed)
        migration_tool.file_processed.connect(_on_file_processed)
        migration_tool.migration_error.connect(_on_migration_error)
        migration_tool.migration_warning.connect(_on_migration_warning)
        migration_tool.progress_updated.connect(_on_progress_updated)

func _find_migration_tool():
    # Find migration tool instance
    migration_tool = get_node_or_null("/root/Godot4MigrationTool")
    
    if not migration_tool:
        # Try to find using class name
        migration_tool = _find_node_by_class(get_tree().root, "Godot4MigrationTool")
    
    if not migration_tool:
        # Create a new instance
        migration_tool = Godot4MigrationTool.new()
        add_child(migration_tool)
    
    # Connect signals
    if migration_tool:
        migration_tool.migration_started.connect(_on_migration_started)
        migration_tool.migration_completed.connect(_on_migration_completed)
        migration_tool.file_processed.connect(_on_file_processed)
        migration_tool.migration_error.connect(_on_migration_error)
        migration_tool.migration_warning.connect(_on_migration_warning)
        migration_tool.progress_updated.connect(_on_progress_updated)
        
        print("Migration tool initialized")
    else:
        push_error("Failed to find or create migration tool")

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

# ----- UI EVENT HANDLERS -----
func _on_browse_godot3_pressed():
    file_dialog.title = "Select Godot 3 Project Directory"
    file_dialog.popup_centered_ratio(0.7)
    selected_dir = "godot3"

func _on_browse_godot4_pressed():
    file_dialog.title = "Select Godot 4 Project Directory"
    file_dialog.popup_centered_ratio(0.7)
    selected_dir = "godot4"

func _on_dir_selected(dir_path):
    if selected_dir == "godot3":
        godot3_path_input.text = dir_path
    elif selected_dir == "godot4":
        godot4_path_input.text = dir_path
    
    _update_file_tree(dir_path)
    _check_paths()

func _on_path_changed(new_text):
    _check_paths()

func _check_paths():
    # Enable/disable start button based on path validity
    var godot3_path = godot3_path_input.text
    var godot4_path = godot4_path_input.text
    
    var godot3_valid = DirAccess.dir_exists_absolute(godot3_path)
    var godot4_valid = DirAccess.dir_exists_absolute(godot4_path)
    
    start_button.disabled = not (godot3_valid and godot4_valid)
    report_button.disabled = not godot3_valid
    
    if start_button.disabled:
        if not godot3_valid:
            _update_status("Godot 3 project path is invalid")
        elif not godot4_valid:
            _update_status("Godot 4 project path is invalid")
    else:
        _update_status("Ready to migrate")

func _on_start_pressed():
    # Get options
    migration_tool.godot3_project_path = godot3_path_input.text
    migration_tool.godot4_project_path = godot4_path_input.text
    migration_tool.backup_before_migration = backup_checkbox.button_pressed
    migration_tool.auto_fix_deprecated = auto_fix_checkbox.button_pressed
    migration_tool.migrate_resources = migrate_resources_checkbox.button_pressed
    migration_tool.verbose_logging = verbose_checkbox.button_pressed
    
    # Clear log
    log_text.text = ""
    file_status.clear()
    
    # Start migration
    is_migrating = true
    start_button.disabled = true
    report_button.disabled = true
    
    # Log start
    _log_message("Starting migration from:\n" + godot3_path_input.text + "\nto:\n" + godot4_path_input.text)
    _log_message("Options: Backup=" + str(backup_checkbox.button_pressed) + 
                 ", AutoFix=" + str(auto_fix_checkbox.button_pressed) + 
                 ", MigrateResources=" + str(migrate_resources_checkbox.button_pressed))
    
    # Start migration process
    migration_tool.start_migration()

func _on_report_pressed():
    # Generate compatibility report
    var report = migration_tool.generate_migration_report(godot3_path_input.text)
    
    # Display report
    _log_message("\n----- COMPATIBILITY REPORT -----")
    _log_message("Total files: " + str(report.total_files))
    _log_message("Compatible files: " + str(report.compatible_files))
    _log_message("Incompatible files: " + str(report.incompatible_files))
    _log_message("\nFile details:")
    
    for file_info in report.file_details:
        var status = "✓ Compatible" if file_info.compatible else "✗ Incompatible"
        _log_message("\n" + file_info.path + ": " + status)
        
        if not file_info.compatible:
            _log_message("Issues:")
            for issue in file_info.issues:
                _log_message("  - " + issue)
        
        if file_info.warnings.size() > 0:
            _log_message("Warnings:")
            for warning in file_info.warnings:
                _log_message("  - " + warning)
        
        if file_info.errors.size() > 0:
            _log_message("Errors:")
            for error in file_info.errors:
                _log_message("  - " + error)
    
    _update_status("Report generated successfully")

# ----- MIGRATION TOOL EVENT HANDLERS -----
func _on_migration_started(total):
    total_files = total
    current_file = 0
    progress_bar.max_value = total
    progress_bar.value = 0
    
    _update_status("Migration started. Total files: " + str(total))
    _log_message("\n----- MIGRATION STARTED -----")
    _log_message("Total files to process: " + str(total))

func _on_migration_completed(stats):
    migration_stats = stats
    is_migrating = false
    start_button.disabled = false
    report_button.disabled = false
    
    _update_status("Migration completed")
    _log_message("\n----- MIGRATION COMPLETED -----")
    _log_message("Files processed: " + str(stats.files_processed))
    _log_message("Files modified: " + str(stats.files_modified))
    _log_message("Errors encountered: " + str(stats.errors_encountered))
    _log_message("Warnings generated: " + str(stats.warnings_generated))
    
    # Update progress to 100%
    progress_bar.value = progress_bar.max_value
    
    emit_signal("migration_complete")

func _on_file_processed(file_path, modified):
    current_file += 1
    progress_bar.value = current_file
    
    # Create relative path
    var rel_path = file_path.replace(godot3_path_input.text, "")
    if rel_path.begins_with("/"):
        rel_path = rel_path.substr(1)
    
    # Log file status
    var status = "Modified" if modified else "No changes needed"
    _log_message(rel_path + ": " + status)
    
    # Update file status dictionary
    file_status[rel_path] = {
        "status": status,
        "modified": modified
    }
    
    # Update file tree
    _update_file_status_in_tree(rel_path, modified)
    
    _update_status("Processing: " + str(current_file) + "/" + str(total_files) + " - " + rel_path)

func _on_migration_error(file_path, error_message):
    # Create relative path
    var rel_path = file_path.replace(godot3_path_input.text, "")
    if rel_path.begins_with("/"):
        rel_path = rel_path.substr(1)
    
    # Log error
    _log_message("ERROR in " + rel_path + ": " + error_message)
    
    # Update file status
    if file_status.has(rel_path):
        file_status[rel_path].errors = file_status[rel_path].get("errors", [])
        file_status[rel_path].errors.append(error_message)
    else:
        file_status[rel_path] = {
            "status": "Error",
            "errors": [error_message]
        }
    
    # Update file tree
    _update_file_status_in_tree(rel_path, false, true)

func _on_migration_warning(file_path, warning_message):
    # Create relative path
    var rel_path = file_path.replace(godot3_path_input.text, "")
    if rel_path.begins_with("/"):
        rel_path = rel_path.substr(1)
    
    # Log warning
    _log_message("WARNING in " + rel_path + ": " + warning_message)
    
    # Update file status
    if file_status.has(rel_path):
        file_status[rel_path].warnings = file_status[rel_path].get("warnings", [])
        file_status[rel_path].warnings.append(warning_message)
    else:
        file_status[rel_path] = {
            "status": "Warning",
            "warnings": [warning_message]
        }
    
    # Update file tree
    _update_file_status_in_tree(rel_path, false, false, true)

func _on_progress_updated(current, total):
    current_file = current
    progress_bar.value = current
    
    var percentage = int((float(current) / total) * 100)
    _update_status("Progress: " + str(current) + "/" + str(total) + " (" + str(percentage) + "%)")

# ----- HELPER FUNCTIONS -----
func _update_status(text):
    status_label.text = text

func _log_message(message):
    log_text.text += message + "\n"
    log_text.scroll_vertical = log_text.get_line_count()

func _update_file_tree(dir_path):
    # Build file tree for the selected directory
    file_tree.clear()
    var root = file_tree.create_item()
    root.set_text(0, dir_path.get_file() if dir_path.get_file() != "" else dir_path)
    
    _populate_file_tree(root, dir_path)

func _populate_file_tree(parent_item, dir_path):
    var dir = DirAccess.open(dir_path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name != "." and file_name != "..":
                var full_path = dir_path.path_join(file_name)
                
                if dir.current_is_dir():
                    var item = file_tree.create_item(parent_item)
                    item.set_text(0, file_name)
                    item.set_icon(0, _get_folder_icon())
                    _populate_file_tree(item, full_path)
                elif file_name.ends_with(".gd") or file_name.ends_with(".tscn") or file_name.ends_with(".tres"):
                    var item = file_tree.create_item(parent_item)
                    item.set_text(0, file_name)
                    item.set_icon(0, _get_file_icon(file_name))
                
            file_name = dir.get_next()
    else:
        _log_message("Could not open directory: " + dir_path)

func _update_file_status_in_tree(rel_path, modified = false, has_error = false, has_warning = false):
    # Find and update file in tree
    var root = file_tree.get_root()
    if not root:
        return
    
    var parts = rel_path.split("/")
    var current_item = root
    var found = true
    
    # Navigate to file
    for i in range(parts.size()):
        var part = parts[i]
        var found_part = false
        
        var child = current_item.get_first_child()
        while child:
            if child.get_text(0) == part:
                current_item = child
                found_part = true
                break
            child = child.get_next()
        
        if not found_part:
            found = false
            break
    
    # Update item if found
    if found:
        if has_error:
            current_item.set_custom_color(0, Color(1, 0, 0))  # Red for error
        elif has_warning:
            current_item.set_custom_color(0, Color(1, 0.7, 0))  # Orange for warning
        elif modified:
            current_item.set_custom_color(0, Color(0, 0.8, 0))  # Green for modified
        else:
            current_item.set_custom_color(0, Color(0.5, 0.5, 0.5))  # Gray for unchanged

func _get_folder_icon():
    # Return a folder icon
    # In a real implementation, this would load an actual icon
    return null

func _get_file_icon(file_name):
    # Return appropriate icon based on file type
    # In a real implementation, this would load actual icons
    return null