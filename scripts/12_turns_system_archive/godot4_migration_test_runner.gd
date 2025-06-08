class_name Godot4MigrationTestRunner
extends Control

# ----- UI COMPONENTS -----
@onready var test_list = $Layout/TestPanel/ScrollContainer/TestList
@onready var run_all_tests_button = $Layout/ControlPanel/RunAllButton
@onready var run_selected_test_button = $Layout/ControlPanel/RunSelectedButton
@onready var batch_test_button = $Layout/ControlPanel/BatchTestButton
@onready var generate_report_button = $Layout/ControlPanel/GenerateReportButton
@onready var batch_path_input = $Layout/ControlPanel/BatchPathInput
@onready var browse_button = $Layout/ControlPanel/BrowseButton
@onready var progress_bar = $Layout/TestProgress/ProgressBar
@onready var status_label = $Layout/TestProgress/StatusLabel

@onready var result_title = $Layout/ResultPanel/ResultTitle
@onready var result_view = $Layout/ResultPanel/ResultView
@onready var result_tabs = $Layout/ResultPanel/ResultTabs
@onready var expected_tab = $Layout/ResultPanel/ResultTabs/ExpectedTab
@onready var actual_tab = $Layout/ResultPanel/ResultTabs/ActualTab
@onready var diff_tab = $Layout/ResultPanel/ResultTabs/DiffTab
@onready var expected_text = $Layout/ResultPanel/ResultTabs/ExpectedTab/ExpectedText
@onready var actual_text = $Layout/ResultPanel/ResultTabs/ActualTab/ActualText
@onready var diff_text = $Layout/ResultPanel/ResultTabs/DiffTab/DiffText

@onready var summary_panel = $Layout/SummaryPanel/VBoxContainer
@onready var total_tests_label = $Layout/SummaryPanel/VBoxContainer/TotalTests
@onready var passed_tests_label = $Layout/SummaryPanel/VBoxContainer/PassedTests
@onready var failed_tests_label = $Layout/SummaryPanel/VBoxContainer/FailedTests
@onready var success_rate_label = $Layout/SummaryPanel/VBoxContainer/SuccessRate

@onready var file_dialog = $FileDialog

# ----- COMPONENTS -----
var migration_tester = null
var color_system = null

# ----- STATE VARIABLES -----
var current_test_results = {}
var test_items = {}
var selected_test = ""
var is_testing = false

# ----- INITIALIZATION -----
func _ready():
    _find_components()
    _setup_ui()
    _connect_signals()
    _populate_test_list()
    
    print("Godot4 Migration Test Runner initialized")

func _find_components():
    # Find or create the migration tester
    migration_tester = get_node_or_null("/root/Godot4MigrationTester")
    if not migration_tester:
        migration_tester = _find_node_by_class(get_tree().root, "Godot4MigrationTester")
    
    if not migration_tester:
        migration_tester = Godot4MigrationTester.new()
        add_child(migration_tester)
    
    # Find Color System
    color_system = get_node_or_null("/root/DimensionalColorSystem")
    if not color_system:
        color_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
    
    print("Components found - Migration Tester: %s, Color System: %s" % [
        "Yes" if migration_tester else "No",
        "Yes" if color_system else "No"
    ])

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _setup_ui():
    # Set up UI components
    if not is_instance_valid(test_list):
        # Create UI components if not using scene
        _create_ui_components()
    
    # Initialize UI state
    run_selected_test_button.disabled = true
    progress_bar.value = 0
    result_title.text = "Test Results"
    result_view.text = "Run a test to see results"
    
    _clear_result_tabs()
    
    total_tests_label.text = "Total Tests: 0"
    passed_tests_label.text = "Passed: 0"
    failed_tests_label.text = "Failed: 0"
    success_rate_label.text = "Success Rate: 0%"

func _create_ui_components():
    # Create UI components programmatically if not using a scene
    # This is a fallback for when the runner is not instantiated from a scene
    
    # Create main layout
    var main_vbox = VBoxContainer.new()
    main_vbox.set_anchors_preset(PRESET_FULL_RECT)
    add_child(main_vbox)
    
    # Create top section with controls
    var control_panel = HBoxContainer.new()
    main_vbox.add_child(control_panel)
    
    run_all_tests_button = Button.new()
    run_all_tests_button.text = "Run All Tests"
    control_panel.add_child(run_all_tests_button)
    
    run_selected_test_button = Button.new()
    run_selected_test_button.text = "Run Selected Test"
    run_selected_test_button.disabled = true
    control_panel.add_child(run_selected_test_button)
    
    batch_test_button = Button.new()
    batch_test_button.text = "Batch Test Directory"
    control_panel.add_child(batch_test_button)
    
    batch_path_input = LineEdit.new()
    batch_path_input.placeholder_text = "Enter directory path for batch testing"
    batch_path_input.size_flags_horizontal = SIZE_EXPAND_FILL
    control_panel.add_child(batch_path_input)
    
    browse_button = Button.new()
    browse_button.text = "Browse"
    control_panel.add_child(browse_button)
    
    generate_report_button = Button.new()
    generate_report_button.text = "Generate Report"
    control_panel.add_child(generate_report_button)
    
    # Create progress section
    var progress_panel = VBoxContainer.new()
    main_vbox.add_child(progress_panel)
    
    progress_bar = ProgressBar.new()
    progress_bar.min_value = 0
    progress_bar.max_value = 100
    progress_bar.value = 0
    progress_bar.size_flags_horizontal = SIZE_EXPAND_FILL
    progress_panel.add_child(progress_bar)
    
    status_label = Label.new()
    status_label.text = "Ready"
    progress_panel.add_child(status_label)
    
    # Create content section with test list and results
    var content_panel = HBoxContainer.new()
    content_panel.size_flags_vertical = SIZE_EXPAND_FILL
    main_vbox.add_child(content_panel)
    
    # Test list panel
    var test_panel = VBoxContainer.new()
    test_panel.size_flags_horizontal = SIZE_EXPAND_FILL
    test_panel.size_flags_stretch_ratio = 0.3
    content_panel.add_child(test_panel)
    
    var test_label = Label.new()
    test_label.text = "Test Cases"
    test_panel.add_child(test_label)
    
    var scroll_container = ScrollContainer.new()
    scroll_container.size_flags_vertical = SIZE_EXPAND_FILL
    test_panel.add_child(scroll_container)
    
    test_list = VBoxContainer.new()
    test_list.size_flags_horizontal = SIZE_EXPAND_FILL
    scroll_container.add_child(test_list)
    
    # Results panel
    var result_panel = VBoxContainer.new()
    result_panel.size_flags_horizontal = SIZE_EXPAND_FILL
    result_panel.size_flags_stretch_ratio = 0.7
    content_panel.add_child(result_panel)
    
    result_title = Label.new()
    result_title.text = "Test Results"
    result_panel.add_child(result_title)
    
    result_view = RichTextLabel.new()
    result_view.bbcode_enabled = true
    result_view.size_flags_vertical = SIZE_EXPAND_FILL
    result_panel.add_child(result_view)
    
    # Result tabs
    result_tabs = TabContainer.new()
    result_tabs.size_flags_vertical = SIZE_EXPAND_FILL
    result_panel.add_child(result_tabs)
    
    expected_tab = VBoxContainer.new()
    expected_tab.name = "Expected"
    result_tabs.add_child(expected_tab)
    
    expected_text = TextEdit.new()
    expected_text.syntax_highlighter = SyntaxHighlighter.new()
    expected_text.editable = false
    expected_text.size_flags_vertical = SIZE_EXPAND_FILL
    expected_tab.add_child(expected_text)
    
    actual_tab = VBoxContainer.new()
    actual_tab.name = "Actual"
    result_tabs.add_child(actual_tab)
    
    actual_text = TextEdit.new()
    actual_text.syntax_highlighter = SyntaxHighlighter.new()
    actual_text.editable = false
    actual_text.size_flags_vertical = SIZE_EXPAND_FILL
    actual_tab.add_child(actual_text)
    
    diff_tab = VBoxContainer.new()
    diff_tab.name = "Diff"
    result_tabs.add_child(diff_tab)
    
    diff_text = RichTextLabel.new()
    diff_text.bbcode_enabled = true
    diff_text.size_flags_vertical = SIZE_EXPAND_FILL
    diff_tab.add_child(diff_text)
    
    # Summary panel
    var summary_panel = VBoxContainer.new()
    summary_panel.size_flags_horizontal = SIZE_EXPAND_FILL
    main_vbox.add_child(summary_panel)
    
    var summary_label = Label.new()
    summary_label.text = "Test Summary"
    summary_panel.add_child(summary_label)
    
    total_tests_label = Label.new()
    total_tests_label.text = "Total Tests: 0"
    summary_panel.add_child(total_tests_label)
    
    passed_tests_label = Label.new()
    passed_tests_label.text = "Passed: 0"
    summary_panel.add_child(passed_tests_label)
    
    failed_tests_label = Label.new()
    failed_tests_label.text = "Failed: 0"
    summary_panel.add_child(failed_tests_label)
    
    success_rate_label = Label.new()
    success_rate_label.text = "Success Rate: 0%"
    summary_panel.add_child(success_rate_label)
    
    # File dialog
    file_dialog = FileDialog.new()
    file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
    add_child(file_dialog)

func _connect_signals():
    # Connect UI signals
    run_all_tests_button.pressed.connect(_on_run_all_tests_pressed)
    run_selected_test_button.pressed.connect(_on_run_selected_test_pressed)
    batch_test_button.pressed.connect(_on_batch_test_pressed)
    browse_button.pressed.connect(_on_browse_pressed)
    generate_report_button.pressed.connect(_on_generate_report_pressed)
    file_dialog.dir_selected.connect(_on_dir_selected)
    
    # Connect migration tester signals
    migration_tester.test_started.connect(_on_test_started)
    migration_tester.test_completed.connect(_on_test_completed)
    migration_tester.test_case_started.connect(_on_test_case_started)
    migration_tester.test_case_completed.connect(_on_test_case_completed)

func _populate_test_list():
    # Clear existing items
    for child in test_list.get_children():
        child.queue_free()
    
    # Add test cases
    for test_name in migration_tester.test_cases.keys():
        var test_button = Button.new()
        test_button.text = test_name
        test_button.size_flags_horizontal = SIZE_EXPAND_FILL
        test_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        test_button.pressed.connect(_on_test_selected.bind(test_name))
        
        test_list.add_child(test_button)
        test_items[test_name] = test_button

# ----- UI EVENT HANDLERS -----
func _on_run_all_tests_pressed():
    if is_testing:
        return
    
    is_testing = true
    _clear_result_tabs()
    result_view.text = "Running all tests..."
    
    # Run tests in a deferred call to allow UI to update
    call_deferred("_run_all_tests")

func _run_all_tests():
    var results = migration_tester.run_all_tests()
    current_test_results = results
    is_testing = false

func _on_run_selected_test_pressed():
    if is_testing or selected_test.is_empty():
        return
    
    is_testing = true
    _clear_result_tabs()
    result_view.text = "Running test: " + selected_test + "..."
    
    # Run tests in a deferred call to allow UI to update
    call_deferred("_run_selected_test")

func _run_selected_test():
    var result = migration_tester.run_single_test(selected_test)
    
    # Create a results structure similar to full test run
    current_test_results = {
        "total": 1,
        "passed": 1 if result.passed else 0,
        "failed": 0 if result.passed else 1,
        "details": {}
    }
    current_test_results.details[selected_test] = result
    
    _update_test_result_view(selected_test, result)
    _update_summary(current_test_results)
    
    is_testing = false

func _on_batch_test_pressed():
    if is_testing:
        return
    
    var batch_path = batch_path_input.text
    if batch_path.is_empty() or not DirAccess.dir_exists_absolute(batch_path):
        _show_error("Invalid directory path for batch testing")
        return
    
    is_testing = true
    _clear_result_tabs()
    result_view.text = "Running batch tests on directory: " + batch_path + "..."
    
    # Run batch test in a deferred call to allow UI to update
    call_deferred("_run_batch_test", batch_path)

func _run_batch_test(path):
    var results = migration_tester.batch_test_directory(path)
    
    # Display batch test results
    result_view.clear()
    result_view.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
    result_view.append_text("Batch Test Results for: " + path + "\n\n")
    result_view.append_text("Total Files: " + str(results.total_files) + "\n")
    result_view.append_text("Successful Migrations: " + str(results.successful_migrations) + "\n")
    result_view.append_text("Failed Migrations: " + str(results.failed_migrations) + "\n\n")
    
    if results.total_files > 0:
        var success_rate = float(results.successful_migrations) / results.total_files * 100
        result_view.append_text("Success Rate: " + str(success_rate) + "%\n\n")
    
    result_view.append_text("File Details:\n")
    
    for file_path in results.details.keys():
        var file_result = results.details[file_path]
        var status = "✓ SUCCESS" if file_result.success and file_result.modified else "✗ FAILED"
        
        result_view.append_text("\n" + file_path + ": " + status + "\n")
        
        if file_result.has("warnings") and file_result.warnings.size() > 0:
            result_view.append_text("  Warnings:\n")
            for warning in file_result.warnings:
                result_view.append_text("  - " + warning + "\n")
        
        if file_result.has("errors") and file_result.errors.size() > 0:
            result_view.append_text("  Errors:\n")
            for error in file_result.errors:
                result_view.append_text("  - " + error + "\n")
    
    result_view.pop()
    
    is_testing = false

func _on_browse_pressed():
    file_dialog.title = "Select Directory for Batch Testing"
    file_dialog.popup_centered_ratio(0.7)

func _on_dir_selected(dir_path):
    batch_path_input.text = dir_path

func _on_generate_report_pressed():
    if is_testing:
        return
    
    is_testing = true
    _clear_result_tabs()
    result_view.text = "Generating test report..."
    
    # Generate report in a deferred call to allow UI to update
    call_deferred("_generate_report")

func _generate_report():
    var report_path = OS.get_user_data_dir().path_join("godot4_migration_test_report.md")
    var report = migration_tester.generate_test_report(report_path)
    
    result_view.clear()
    result_view.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
    result_view.append_text("Test Report Generated\n\n")
    result_view.append_text("Report saved to: " + report_path + "\n\n")
    result_view.append_text("Report Preview:\n\n")
    result_view.append_text(report.substr(0, 1000) + "...\n\n")
    result_view.append_text("(Report has been truncated for preview. See full report at the saved path.)")
    result_view.pop()
    
    is_testing = false

func _on_test_selected(test_name):
    selected_test = test_name
    run_selected_test_button.disabled = false
    
    # Highlight selected test
    for name in test_items.keys():
        var button = test_items[name]
        button.disabled = (name == test_name)
    
    # If we have results for this test already, show them
    if current_test_results.has("details") and current_test_results.details.has(test_name):
        _update_test_result_view(test_name, current_test_results.details[test_name])

# ----- MIGRATION TESTER EVENT HANDLERS -----
func _on_test_started(total_tests):
    progress_bar.max_value = total_tests
    progress_bar.value = 0
    
    status_label.text = "Running tests (0/" + str(total_tests) + ")"
    
    _clear_test_item_highlights()

func _on_test_completed(results):
    progress_bar.value = progress_bar.max_value
    status_label.text = "Tests completed: " + str(results.passed) + "/" + str(results.total) + " passed"
    
    _update_summary(results)
    
    # Show overall results
    result_view.clear()
    result_view.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
    result_view.append_text("Test Results Summary\n\n")
    result_view.append_text("Total Tests: " + str(results.total) + "\n")
    result_view.append_text("Passed: " + str(results.passed) + "\n")
    result_view.append_text("Failed: " + str(results.failed) + "\n")
    
    if results.total > 0:
        var success_rate = float(results.passed) / results.total * 100
        result_view.append_text("Success Rate: " + str(success_rate) + "%\n\n")
    
    result_view.append_text("Test Details:\n")
    
    for test_name in results.details.keys():
        var test_result = results.details[test_name]
        var status = "✓ PASSED" if test_result.passed else "✗ FAILED"
        
        result_view.append_text("\n" + test_name + ": " + status + "\n")
        
        if not test_result.passed:
            result_view.append_text("  (Click on the test name to see details)\n")
    
    result_view.pop()
    
    current_test_results = results

func _on_test_case_started(test_name):
    progress_bar.value += 1
    status_label.text = "Running test: " + test_name + " (" + str(progress_bar.value) + "/" + str(progress_bar.max_value) + ")"
    
    # Highlight current test in list
    if test_items.has(test_name):
        test_items[test_name].modulate = Color(1, 1, 0)  # Yellow for in-progress

func _on_test_case_completed(test_name, passed, details):
    # Update test item in list
    if test_items.has(test_name):
        test_items[test_name].modulate = Color(0, 1, 0) if passed else Color(1, 0, 0)  # Green for passed, red for failed
    
    # If this is the selected test, update the result view
    if test_name == selected_test:
        _update_test_result_view(test_name, details)

func _update_test_result_view(test_name, details):
    result_title.text = "Test Result: " + test_name
    
    # Clear existing content
    _clear_result_tabs()
    
    # Set expected content
    expected_text.text = details.expected
    
    # Set actual content
    actual_text.text = details.actual
    
    # Set diff content
    _update_diff_view(details.expected, details.actual)
    
    # Create summary view
    result_view.clear()
    result_view.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
    var status = "✓ PASSED" if details.passed else "✗ FAILED"
    result_view.append_text("Test: " + test_name + " - " + status + "\n\n")
    
    if not details.passed:
        result_view.append_text("The migrated code does not match the expected output.\n")
        result_view.append_text("Check the 'Expected', 'Actual', and 'Diff' tabs to see the differences.\n\n")
    
    if details.has("migration_error"):
        result_view.append_text("Migration Error: " + details.migration_error + "\n\n")
    
    if details.has("warnings") and details.warnings.size() > 0:
        result_view.append_text("Warnings:\n")
        for warning in details.warnings:
            result_view.append_text("- " + warning + "\n")
        result_view.append_text("\n")
    
    if details.has("errors") and details.errors.size() > 0:
        result_view.append_text("Errors:\n")
        for error in details.errors:
            result_view.append_text("- " + error + "\n")
    
    result_view.pop()

func _update_diff_view(expected, actual):
    # Create a simple line-by-line diff
    var expected_lines = expected.split("\n")
    var actual_lines = actual.split("\n")
    
    diff_text.clear()
    diff_text.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
    
    var max_lines = max(expected_lines.size(), actual_lines.size())
    
    for i in range(max_lines):
        var expected_line = ""
        var actual_line = ""
        
        if i < expected_lines.size():
            expected_line = expected_lines[i]
        
        if i < actual_lines.size():
            actual_line = actual_lines[i]
        
        if expected_line == actual_line:
            diff_text.append_text(str(i + 1) + ": " + expected_line + "\n")
        else:
            diff_text.push_color(Color(1, 0, 0))  # Red for expected that doesn't match
            diff_text.append_text(str(i + 1) + " -: " + expected_line + "\n")
            diff_text.pop()
            
            diff_text.push_color(Color(0, 1, 0))  # Green for actual that doesn't match
            diff_text.append_text(str(i + 1) + " +: " + actual_line + "\n")
            diff_text.pop()
            
            diff_text.append_text("\n")
    
    diff_text.pop()

func _update_summary(results):
    total_tests_label.text = "Total Tests: " + str(results.total)
    passed_tests_label.text = "Passed: " + str(results.passed)
    failed_tests_label.text = "Failed: " + str(results.failed)
    
    if results.total > 0:
        var success_rate = float(results.passed) / results.total * 100
        success_rate_label.text = "Success Rate: " + str(success_rate) + "%"
    else:
        success_rate_label.text = "Success Rate: 0%"

# ----- HELPER FUNCTIONS -----
func _clear_result_tabs():
    expected_text.text = ""
    actual_text.text = ""
    diff_text.clear()

func _clear_test_item_highlights():
    for name in test_items.keys():
        test_items[name].modulate = Color(1, 1, 1)
        test_items[name].disabled = false

func _show_error(message):
    OS.alert(message, "Error")

# ----- COLOR INTEGRATION -----
func integrate_with_color_system():
    if not color_system:
        print("Color system not found, color integration not available")
        return
    
    # In a real implementation, this would:
    # 1. Register test result colors with the color system
    # 2. Set up callback hooks to update UI elements based on color system state
    # 3. Use color system for visualization of test progress and results
    
    print("Color system integration enabled")
    
    # Example: Update summary panel with color system colors
    if current_test_results.has("total") and current_test_results.total > 0:
        var success_rate = float(current_test_results.passed) / current_test_results.total
        
        # In a real implementation, color_system would provide these colors
        var text_color = Color(1, 1, 1)
        var background_color = Color(0.2, 0.2, 0.2)
        
        if success_rate >= 0.8:
            text_color = Color(0, 1, 0)
        elif success_rate >= 0.5:
            text_color = Color(1, 1, 0)
        else:
            text_color = Color(1, 0, 0)
        
        # Apply colors
        summary_panel.modulate = text_color