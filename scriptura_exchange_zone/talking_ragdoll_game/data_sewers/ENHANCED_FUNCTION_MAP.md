# ENHANCED FUNCTION MAP

**Project:** Talking Ragdoll Game
**Total Scripts:** 238
**Total Functions:** 4726

## System Architecture Overview

The Talking Ragdoll Game is built around several core systems:

- **Universal Being System** - Core entity transformation and manifestation
- **Floodgate Controller** - Central operation queue and rate limiting
- **Console Manager** - In-game command interface and debugging
- **Asset Library** - Centralized asset management and loading
- **Ragdoll Systems** - Physics-based character movement
- **JSH Framework** - Advanced data management and processing

## Core Systems
**Scripts:** 111 | **Functions:** 2882

### 📄 scripts/jsh_framework/core/main.gd
**Functions:** 390

#### `_init(parent_node = null)`
- **Purpose:** Function in main system
- **Lines:** 0
- **Returns:** `void`

#### `register_command(cmd_name, target, method_name)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`

#### `parse(raw_input: String)`
- **Purpose:** Function in main system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** call_command, size, has, slice, to_lower

#### `call_command(cmd: String, args: Array)`
- **Purpose:** Function in main system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** call

#### `_init()`
- **Purpose:** Function in main system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, prepare_akashic_records_init, print_tree_pretty, setup_system_checks, print

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start_up_scene_tree, create_tasks_from_structure, print, track_task_status, get_mouse_position

#### `_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _input_event

#### `_input_event(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ray_points, input, process_ray_cast

#### `_process(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_mouse_button_pressed, process_system, each_blimp_of_delta, process, process_roll

#### `_physics_process(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Quaternion, lerp

#### `process_system()`
- **Purpose:** Handle ongoing operations or data
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** process_system_8, process_system_9, process_system_7, process_system_2, process_system_4

#### `each_blimp_of_delta()`
- **Purpose:** Function in main system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, pop_front, get_ticks_msec, size

#### `update_delta_history(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, unlock, lock

#### `calculate_time(delta_current, time, hour, minute, second)`
- **Purpose:** Function in main system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, print

#### `before_time_blimp(how_many_finished, how_many_shall_been_finished)`
- **Purpose:** Function in main system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec

*... and 375 more functions*

---

### 📄 scripts/jsh_framework/core/JSH_console.gd
**Functions:** 218

#### `_ready_add()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** update_input_display, update_output_display, update_memory_display, update_status

#### `_process_add(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** update_cursor

#### `update_cursor()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, length

#### `update_input_display()`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** update_cursor

#### `update_output_display()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`

#### `update_status(status: String)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`

#### `update_memory_display(percentage: int)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str

#### `handle_key_input(key: String)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** execute_command, substr, length, update_input_display

#### `history_up()`
- **Purpose:** Function in JSH_console system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** update_input_display, size

#### `history_down()`
- **Purpose:** Function in JSH_console system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** update_input_display, size

#### `execute_command()`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** update_output_display, size, pop_front, push_back, strip_edges

#### `process_command(command_text: String)`
- **Purpose:** Handle ongoing operations or data
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** list_things, show_command_history, size, find, show_help

#### `setup_terminal()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start, print, add_child, new, connect

#### `terminal_blink_cursor()`
- **Purpose:** Function in JSH_console system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** jsh_tree_get_node

#### `handle_terminal_key_press(key: String)`
- **Purpose:** Function in JSH_console system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** len, update_terminal_display

*... and 203 more functions*

---

### 📄 scripts/jsh_framework/core/text_screen.gd
**Functions:** 197

#### `register_command(name: String, callback: Callable)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** to_lower

#### `unregister_command(name: String)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, to_lower, erase

#### `execute_command(name: String, args: Array)`
- **Purpose:** Run command or operation
- **Lines:** 36
- **Returns:** `Dictionary`
- **Key Calls:** has, to_lower

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_signals, emit_signal, find_integration_nodes, _update_display, _setup_components
- **Signals:** window_focused

#### `_process(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, is_mouse_button_pressed, project_ray_normal, Plane, Vector3

#### `_input(event)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _submit_text, scroll_messages_up, unfocus, scroll_messages_down, _navigate_command_history

#### `_ready_0()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, register_default_commands, setup_window, set_text, find_integration_nodes
- **Signals:** window_focused

#### `_process_0(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, is_mouse_button_pressed, project_ray_normal, Plane, Vector3

#### `_input_0(event)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _submit_text, scroll_messages_up, unfocus, scroll_messages_down, _navigate_command_history

#### `_setup_components()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** duplicate, Vector3, add_child, create_control_buttons, new

#### `_create_border()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, new, add_child

#### `_setup_signals()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect

#### `find_integration_nodes()`
- **Purpose:** Function in text_screen system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** track_data_flow, get_node_or_null, has_method

#### `setup_window()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_cursor, create_input_line, create_window_background, create_title_bar, create_control_buttons

#### `setup_signals()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect

*... and 182 more functions*

---

### 📄 scripts/core/floodgate_controller.gd
**Functions:** 83

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, set_process, get_datetime_string_from_system, print, add_child

#### `_exit_tree()`
- **Purpose:** Function in floodgate_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _flush_log_buffer, wait_to_finish, is_started, close

#### `_process(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** each_blimp_of_delta, process_system

#### `each_blimp_of_delta()`
- **Purpose:** Function in floodgate_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, pop_front, get_ticks_msec, size

#### `process_system()`
- **Purpose:** Handle ongoing operations or data
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** process_system_8, process_system_9, process_system_10, process_system_7, process_system_2

#### `queue_operation(type: OperationType, params: Dictionary, priority: int = 0)`
- **Purpose:** Add operation to processing queue with priority
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_unix_time_from_system, append, unlock, _generate_operation_id, emit_signal
- **Signals:** operation_queued, operation_failed

#### `_process_next_operation()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_unix_time_from_system, append, unlock, emit_signal, _execute_operation
- **Signals:** operation_completed, operation_started

#### `_execute_operation(operation: Dictionary)`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** _op_scale_node, _op_move_node, _op_create_universal_being, _op_modify_property, _op_disconnect_signal

#### `_op_create_node(params: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** _register_node, get_parent, add_child, _log, has

#### `_op_delete_node(params: Dictionary)`
- **Purpose:** Function in floodgate_controller system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** _unregister_node_recursive, queue_free, has, _log, get_node_or_null

#### `_op_move_node(params: Dictionary)`
- **Purpose:** Function in floodgate_controller system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** str, _unlock_node, has_method, has, _log

#### `_op_rotate_node(params: Dictionary)`
- **Purpose:** Function in floodgate_controller system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** str, _unlock_node, _log, has, get_node_or_null

#### `_op_scale_node(params: Dictionary)`
- **Purpose:** Function in floodgate_controller system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** str, _unlock_node, _log, has, get_node_or_null

#### `_op_reparent_node(params: Dictionary)`
- **Purpose:** Function in floodgate_controller system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** get_parent, add_child, _unlock_node, _log, has

#### `_op_load_asset(params: Dictionary)`
- **Purpose:** Function in floodgate_controller system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** append, get_unix_time_from_system, emit_signal, str, _log
- **Signals:** asset_approval_needed, asset_loaded

*... and 68 more functions*

---

### 📄 scripts/jsh_framework/core/data_point.gd
**Functions:** 70

#### `setup_terminal()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start, add_child, set_connection_target, new, connect

#### `terminal_blink_cursor()`
- **Purpose:** Function in data_point system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** jsh_tree_get_node

#### `handle_terminal_key_press(key: String)`
- **Purpose:** Function in data_point system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** len, update_terminal_display

#### `handle_terminal_backspace()`
- **Purpose:** Function in data_point system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** substr, length, update_terminal_display

#### `update_terminal_display()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, length, jsh_tree_get_node

#### `history_up()`
- **Purpose:** Function in data_point system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, update_terminal_display

#### `history_down()`
- **Purpose:** Function in data_point system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, update_terminal_display

#### `execute_command()`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, push_back, strip_edges

#### `_init()`
- **Purpose:** Function in data_point system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `process_delta_fake()`
- **Purpose:** Handle ongoing operations or data
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `connect_keyboard_to_field(target_container, target_thing)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** eight_dimensional_magic, get_node_or_null, create_new_task

#### `receive_keyboard_connection(connection_info)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `on_keyboard_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_empty, update_text_and_cursor

#### `set_connection_target(target_container, target_thing, target_datapoint)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** unlock, update_text_and_cursor, update_cursor_position, size, lock

#### `finishied_setting_up_datapoint(my_name)`
- **Purpose:** Function in data_point system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_parent

*... and 55 more functions*

---

### 📄 scripts/jsh_framework/core/jsh_digital_earthlings.gd
**Functions:** 62

#### `_ready_add()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** initialize_grid, print, get_node_or_null

#### `initialize_grid()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, create_title, create_axis_labels, add_child, create_info_panel

#### `set_grid_size(width, height)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** initialize_grid, clear_grid

#### `set_data(data_array)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** track_data_flow, emit_signal, size, update_grid_visualization, print
- **Signals:** grid_updated

#### `update_cell_value(x, y, value)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** update_cell_visualization, record_interaction, has_method

#### `highlight_cell(x, y, highlight = true)`
- **Purpose:** Function in jsh_digital_earthlings system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3

#### `set_title(title_text)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`

#### `set_data_properties(label, units)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** update_info_panel

#### `animate_to_new_data(new_data, duration = 1.0)`
- **Purpose:** Function in jsh_digital_earthlings system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, set_data, set_trans, set_delay, tween_property

#### `generate_wave_pattern()`
- **Purpose:** Function in jsh_digital_earthlings system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, sin, float, range

#### `generate_ripple_pattern()`
- **Purpose:** Function in jsh_digital_earthlings system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, sin, range, sqrt

#### `generate_random_pattern()`
- **Purpose:** Function in jsh_digital_earthlings system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_unix_time_from_system, get_ticks_msec, get_noise_2d, range

#### `generate_gradient_pattern()`
- **Purpose:** Function in jsh_digital_earthlings system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, float, range

#### `generate_mountain_pattern()`
- **Purpose:** Function in jsh_digital_earthlings system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_unix_time_from_system, pow, float, get_noise_2d

#### `create_grid_cells()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, create_cell, range, add_child

*... and 47 more functions*

---

### 📄 scripts/jsh_framework/core/jsh_snake_game.gd
**Functions:** 62

#### `_ready_add()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** initialize_console, log_message, setup_window_layers, initialize_camera, initialize_menu_system

#### `_process_add(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** process_window, update_camera, has_method

#### `_ready_add0()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, initialize_materials, create_ui_elements, get_tree, initialize_animator

#### `_process_add0(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, reset_game, start_game, process_animations, is_action_just_pressed

#### `initialize_console()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_console_commands

#### `initialize_keyboard()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, add_child, has_method, setup_text_handling, load

#### `initialize_menu_system()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child

#### `initialize_camera()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Color, new, add_child

#### `initialize_thread_system()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_child, set_script, load, new, get_node_or_null

#### `initialize_records_system()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child, set_script, load

#### `setup_window_layers()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, get_node

#### `show_scene(scene_number)`
- **Purpose:** Function in jsh_snake_game system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, log_message, scene_to_set_number_later, has_method

#### `upload_scene_data(container_name, scene_data)`
- **Purpose:** Function in jsh_snake_game system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, upload_scenes_frames, has_method, append

#### `show_main_menu()`
- **Purpose:** Function in jsh_snake_game system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_node, set_view_mode

#### `hide_menu_container(container_name)`
- **Purpose:** Function in jsh_snake_game system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_node_or_null

*... and 47 more functions*

---

### 📄 scripts/jsh_framework/core/jsh_marching_shapes_system.gd
**Functions:** 61

#### `_ready_add()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, initialize_scalar_field, setup_nodes, generate_mesh, get_node_or_null

#### `_process_add(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** update_scalar_field, generate_mesh

#### `_ready_old()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, setup_task_manager, create_data_grid, create_pattern_controls, start

#### `_process_old(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_ready_old_0()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** initialize_grid, print, get_node_or_null

#### `add_quad_seven(vertices, indices, v1, v2, v3, v4, v5)`
- **Purpose:** Function in jsh_marching_shapes_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, size, print

#### `setup_nodes()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child

#### `initialize_scalar_field()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, range, get_noise_value

#### `update_scalar_field()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** range, get_noise_value

#### `get_noise_value(x, y)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** float, get_noise_2d

#### `generate_mesh()`
- **Purpose:** Function in jsh_marching_shapes_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_from, add_quad, has_method, resize, PackedInt32Array
- **Signals:** mesh_generated

#### `set_iso_level(value)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, generate_mesh, clamp
- **Signals:** contour_changed

#### `lerp_vertex(x1, y1, x2, y2, val1, val2)`
- **Purpose:** Function in jsh_marching_shapes_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, abs, lerp

#### `add_triangle(vertices, indices, v1, v2, v3)`
- **Purpose:** Function in jsh_marching_shapes_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, size

#### `add_quad(vertices, indices, v1, v2, v3, v4)`
- **Purpose:** Function in jsh_marching_shapes_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, size

*... and 46 more functions*

---

### 📄 scripts/jsh_framework/core/jsh_task_manager.gd
**Functions:** 61

#### `_init(container_seed : int, pos : Vector3)`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** sha1_text, str, substr

#### `evolve(turn : int, command)`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, duplicate, apply_scale_pattern, has, new

#### `apply_scale_pattern(data)`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `serialize()`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_child, print, initialize_task_system, new

#### `add_task(task_name, priority = 0, dependencies = [])`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, size, prune_completed_tasks, append

#### `start_task(task_id)`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, _find_task_index, print

#### `complete_task(task_id, success = true)`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, _find_task_index

#### `track_data_flow(source_path, target_path, data_type, amount = 1.0)`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, get_ticks_msec, _update_flow_visualization

#### `record_interaction(position, type, data = null)`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, size, _visualize_interaction

#### `track_scene_movement(scene_path, from_position, to_position, duration)`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, _visualize_movement, size, has

#### `complete_scene_movement(scene_path, movement_index)`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, size

#### `generate_statistics()`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, size, has, values

#### `export_data(file_path = "user://task_manager_data.json")`
- **Purpose:** Function in jsh_task_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_unix_time_from_system, store_string, close, open, stringify

#### `create_3d_visualization(parent_node)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _visualize_movement, size, add_child, queue_free, _create_flow_line

*... and 46 more functions*

---

### 📄 scripts/core/scene_editor_integration.gd
**Functions:** 55

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_console_commands, print, _setup_references

#### `_setup_references()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_node_or_null

#### `_register_console_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command

#### `_cmd_scene_edit(args: Array)`
- **Purpose:** Function in scene_editor_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _exit_edit_mode, size, print, _enter_edit_mode

#### `_cmd_scene_save(args: Array)`
- **Purpose:** Function in scene_editor_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _save_scene, size, print, ends_with

#### `_cmd_scene_load(args: Array)`
- **Purpose:** Function in scene_editor_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _load_scene_for_editing, size, print

#### `_cmd_scene_new(_args: Array)`
- **Purpose:** Function in scene_editor_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_new_scene, print

#### `_cmd_scene_export(args: Array)`
- **Purpose:** Function in scene_editor_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, _export_scene, print

#### `_cmd_select(args: Array)`
- **Purpose:** Function in scene_editor_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, print, _find_node_by_name, _select_object

#### `_cmd_select_all(_args: Array)`
- **Purpose:** Function in scene_editor_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, get_tree, str, print, _select_all_children

#### `_cmd_deselect(_args: Array)`
- **Purpose:** Function in scene_editor_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, _deselect_all

#### `_cmd_delete_selected(_args: Array)`
- **Purpose:** Function in scene_editor_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, str, print, _queue_delete_operation, clear

#### `_cmd_duplicate_selected(_args: Array)`
- **Purpose:** Function in scene_editor_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _queue_duplicate_operation, _deselect_all, _select_object, size

#### `_cmd_move(args: Array)`
- **Purpose:** Function in scene_editor_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _queue_move_operation, Vector3, size, float, print

#### `_cmd_rotate(args: Array)`
- **Purpose:** Function in scene_editor_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _queue_rotate_operation, Vector3, size, float, print

*... and 40 more functions*

---

### 📄 scripts/jsh_framework/core/JSH_mainframe_database.gd
**Functions:** 51

#### `update_ram(usage: int)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** min

#### `update_cpu(usage: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** min

#### `update_nodes(count: int)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** min

#### `update_file_ops(count: int)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** min

#### `get_ram_percentage()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** float

#### `get_cpu_percentage()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`

#### `get_node_percentage()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** float

#### `get_file_percentage()`
- **Purpose:** Retrieve data or property value
- **Lines:** 4
- **Returns:** `float`
- **Key Calls:** float

#### `_init(p_name: String, p_type: int, p_execution_time: float = 5.0)`
- **Purpose:** Function in JSH_mainframe_database system
- **Lines:** 0
- **Returns:** `void`

#### `add_dependency(func_name: String)`
- **Purpose:** Function in JSH_mainframe_database system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, append

#### `set_resource_requirement(resource: String, amount)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`

#### `set_error_probability(probability: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clamp

#### `execute()`
- **Purpose:** Run command or operation
- **Lines:** 8
- **Returns:** `bool`
- **Key Calls:** randf

#### `_init(p_name: String)`
- **Purpose:** Function in JSH_mainframe_database system
- **Lines:** 0
- **Returns:** `void`

#### `add_pack(pack_name: String)`
- **Purpose:** Function in JSH_mainframe_database system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** append, size

*... and 36 more functions*

---

### 📄 scripts/jsh_framework/core/jsh_database_system.gd
**Functions:** 45

#### `_init(func_name: String)`
- **Purpose:** Function in jsh_database_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** analyze_name

#### `analyze_name()`
- **Purpose:** Function in jsh_database_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, has, get_char_type

#### `get_char_type(c: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 13
- **Returns:** `int`
- **Key Calls:** unicode_at

#### `add_function(func_text: String)`
- **Purpose:** Function in jsh_database_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, extract_return_type, count_parameters, extract_function_name, is_empty

#### `extract_function_name(declaration: String)`
- **Purpose:** Function in jsh_database_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** strip_edges, substr, find

#### `count_parameters(declaration: String)`
- **Purpose:** Function in jsh_database_system system
- **Lines:** 0
- **Returns:** `int`
- **Key Calls:** size, find, strip_edges, is_empty, substr

#### `extract_return_type(declaration: String)`
- **Purpose:** Function in jsh_database_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** strip_edges, substr, length, find

#### `get_function_analysis(func_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `FunctionAnalysis`
- **Key Calls:** get

#### `print_analysis(func_name: String)`
- **Purpose:** Function in jsh_database_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_function_analysis, get_type_name

#### `get_type_name(type_code: int)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** check_all_settings_data, initialize_parser

#### `check_all_things()`
- **Purpose:** Function in jsh_database_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `initialize_parser()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_empty, push_error

#### `collect_system_stats()`
- **Purpose:** Function in jsh_database_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** float, max

#### `get_parse_stats()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** duplicate, unlock, lock

*... and 30 more functions*

---

### 📄 scripts/core/akashic_bridge_system.gd
**Functions:** 42

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_websocket, _setup_http_client, _setup_file_monitoring, _attempt_server_connection, _print

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** poll, back, values, _sync_project_state, _process_websocket_messages

#### `_setup_http_client()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, new, add_child

#### `_setup_websocket()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new

#### `_attempt_server_connection()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _send_http_request, _print

#### `_on_http_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray)`
- **Purpose:** Function in akashic_bridge_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _connect_websocket, create_timer, size, str, server

#### `_connect_websocket()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, connect_to_url

#### `_process_websocket_messages()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _handle_server_message, get_packet, get_available_packet_count, get_string_from_utf8, get_ready_state

#### `_register_with_server()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _send_http_request, get_ticks_msec, get_executable_path, str, get_base_dir

#### `_send_http_request(endpoint: String, data: Dictionary, method: HTTPClient.Method)`
- **Purpose:** Function in akashic_bridge_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** stringify, request

#### `_send_websocket_message(message: Dictionary)`
- **Purpose:** Function in akashic_bridge_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** stringify, send_text, get_ready_state

#### `_handle_server_message(message: String)`
- **Purpose:** Function in akashic_bridge_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _execute_console_command, parse, _start_tutorial, _execute_tutorial_step, _handle_file_update

#### `_execute_console_command(command: String)`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, keys, _on_command_submitted, get_tree, str

#### `_start_tutorial(steps: Array)`
- **Purpose:** Function in akashic_bridge_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, size, str, has_method, _execute_tutorial_step

#### `_execute_tutorial_step(step_index: int)`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _complete_tutorial, _tutorial_wait_for_command, size, str, _tutorial_spawn_object

*... and 27 more functions*

---

### 📄 scripts/core/talking_astral_being.gd
**Functions:** 41

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_detection_area, _create_visual_components, _apply_personality, add_to_group, set_physics_process

#### `_create_visual_components()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child

#### `_create_detection_area()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, new, add_child

#### `_apply_personality()`
- **Purpose:** Function in talking_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, get

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_free_flight, _update_energy, _update_connection_awareness, _process_orbiting, _consider_speaking

#### `_process_free_flight(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, distance_to, start_orbiting, _calculate_pattern_position, lerp

#### `_process_orbiting(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** sin, Vector3, look_at, lerp, is_instance_valid

#### `_process_creating(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, sin, _create_trail_light, size, Vector3

#### `_process_following(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_instance_valid, Vector3, lerp

#### `_process_assisting(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, _perform_assistance, lerp

#### `_process_hovering(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, get_ticks_msec, sin

#### `_process_assistance(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _harmonize_environment, _organize_scene, _assist_ragdoll, _assist_objects, _assist_creation

#### `_assist_ragdoll(delta: float)`
- **Purpose:** Function in talking_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_body, Vector3, has_method, apply_central_impulse, get

#### `_assist_objects(delta: float)`
- **Purpose:** Function in talking_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_linear_velocity, Vector3, has_method, length, randf

#### `_organize_scene(delta: float)`
- **Purpose:** Function in talking_astral_being system
- **Lines:** 0
- **Returns:** `void`

*... and 26 more functions*

---

### 📄 scripts/jsh_framework/core/jsh_scene_tree_system.gd
**Functions:** 40

#### `_init()`
- **Purpose:** Function in jsh_scene_tree_system system
- **Lines:** 0
- **Returns:** `void`

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_scene_tree_monitoring, get_tree, start_up_scene_tree, print

#### `start_up_scene_tree()`
- **Purpose:** Function in jsh_scene_tree_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** duplicate, get_ticks_msec, unlock, emit_signal, lock
- **Signals:** tree_updated

#### `add_branch(branch_path: String, branch_data: Dictionary)`
- **Purpose:** Function in jsh_scene_tree_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** duplicate, unlock, emit_signal, size, lock
- **Signals:** branch_added, tree_updated

#### `remove_branch(branch_path: String)`
- **Purpose:** Function in jsh_scene_tree_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** unlock, erase, emit_signal, lock, has
- **Signals:** branch_removed, tree_updated

#### `get_branch(branch_path: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** duplicate, unlock, size, lock, has

#### `set_branch_status(branch_path: String, status: String)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** unlock, emit_signal, size, lock, has
- **Signals:** branch_status_changed, tree_updated

#### `get_branch_status(branch_path: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get, get_branch

#### `disable_branch(branch_path: String)`
- **Purpose:** Function in jsh_scene_tree_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** set_branch_status

#### `activate_branch(branch_path: String)`
- **Purpose:** Function in jsh_scene_tree_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** set_branch_status

#### `set_branch_node(branch_path: String, node: Node)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** unlock, emit_signal, size, lock, has
- **Signals:** tree_updated

#### `get_branch_node(branch_path: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** get, get_branch

#### `jsh_tree_get_node(node_path: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** unlock, size, lock, has, range

#### `validate_branch_nodes(branch_path: String)`
- **Purpose:** Check if data/state is valid
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, get_branch, has, empty, is_instance_valid

#### `cache_branch_data(branch_path: String, branch_data: Dictionary)`
- **Purpose:** Function in jsh_scene_tree_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** duplicate, unlock, lock, has, split

*... and 25 more functions*

---

### 📄 scripts/core/dimensional_color_system.gd
**Functions:** 39

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _initialize_frequency_color_map, _generate_tertiary_colors, _initialize_mesh_point_map, size, str

#### `_generate_tertiary_colors()`
- **Purpose:** Function in dimensional_color_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, Color, size, float, range

#### `_initialize_frequency_color_map()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, size, float, has, range

#### `_initialize_mesh_point_map()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, size, range, append

#### `_generate_color_palettes()`
- **Purpose:** Function in dimensional_color_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color

#### `_find_systems()`
- **Purpose:** Function in dimensional_color_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, _find_node_by_class, print, get_node_or_null

#### `_find_node_by_class(node, class_name_str)`
- **Purpose:** Function in dimensional_color_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_node_by_class, or, get_script, find, get_children

#### `_process(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_animations

#### `_update_animations(delta)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, erase, emit_signal, _update_pulse_animation, _update_mesh_point_animation
- **Signals:** animation_completed

#### `_update_pulse_animation(animation, progress)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, lerp, sin
- **Signals:** color_frequency_updated

#### `_update_fade_animation(animation, progress)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, lerp
- **Signals:** color_frequency_updated

#### `_update_cycle_animation(animation, progress)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, size, fmod, lerp, int
- **Signals:** color_frequency_updated

#### `_update_rainbow_animation(animation, progress)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** from_hsv, emit_signal, fmod
- **Signals:** color_frequency_updated

#### `_update_mesh_point_animation(animation, progress)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, fmod, lerp, sin
- **Signals:** mesh_point_activated, color_frequency_updated

#### `get_color_for_frequency(frequency: int)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Color`
- **Key Calls:** has, Color, clamp

*... and 24 more functions*

---

### 📄 scripts/core/seven_part_ragdoll_integration.gd
**Functions:** 36

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_unix_time_from_system, _connect_to_floodgate, has_node, _setup_seven_part_body, create_timer

#### `_setup_seven_part_body()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, Vector3, _create_joints, add_child, set_meta

#### `_setup_enhanced_walker()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, add_child, added, set_script, load

#### `_create_body_part(part_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** Vector3, new, add_child, part

#### `_create_joints(parts: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_knee_joint, _create_ankle_joint, _create_hip_joint

#### `_create_hip_joint(parts: Dictionary, parent_name: String, child_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_param_y, set_flag_z, set_param_x, Vector3, set_param_z

#### `_create_knee_joint(parts: Dictionary, parent_name: String, child_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, add_child, has, set_flag, get_path

#### `_create_ankle_joint(parts: Dictionary, parent_name: String, child_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, add_child, has, set_flag, get_path

#### `_connect_to_jsh_framework()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, print, get_node_or_null, has_method

#### `_connect_to_floodgate()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, print, get_node_or_null, queue_ragdoll_position_update

#### `_setup_dialogue_system()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, new, add_child, randf_range

#### `_speak_random_phrase()`
- **Purpose:** Function in seven_part_ragdoll_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, print, randi, emit

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_dialogue, _process_walking_movement

#### `_process_walking_movement(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** distance_to, has_node, _handle_target_reached, get_meta, start_walking

#### `come_to_position(pos: Vector3)`
- **Purpose:** Function in seven_part_ragdoll_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, print, emit

*... and 21 more functions*

---

### 📄 scripts/core/universal_gizmo_system.gd
**Functions:** 36

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_translation_gizmos, _create_rotation_gizmos, call_deferred, _create_scale_gizmos, print

#### `attach_to_object(object: Node3D)`
- **Purpose:** Function in universal_gizmo_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_gizmo_position, set_mode, call_deferred, size, detach

#### `detach()`
- **Purpose:** Function in universal_gizmo_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `_unhandled_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, _is_gizmo_component, project_ray_normal, _end_drag, get_world_3d

#### `_create_translation_gizmos()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_arrow_visual, _setup_plane_visual, _create_gizmo_being, print, add_child

#### `_create_rotation_gizmos()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_gizmo_being, _setup_ring_visual, add_child, set_property, _setup_gizmo_interaction

#### `_create_scale_gizmos()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_gizmo_being, add_child, _setup_uniform_scale_visual, set_property, _setup_gizmo_interaction

#### `_create_gizmo_being(being_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** new, set_property, set_script, load

#### `_setup_arrow_visual(arrow_being: Node3D, axis: String)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child, set_property

#### `_setup_plane_visual(plane_being: Node3D, plane: String)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector2, Vector3, new, add_child

#### `_setup_ring_visual(ring_being: Node3D, axis: String)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child, set_property

#### `_setup_scale_visual(scale_being: Node3D, axis: String)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child, set_property

#### `_setup_uniform_scale_visual(uniform_being: Node3D)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child, set_property

#### `_setup_gizmo_interaction(gizmo_being: Node3D, axis: String, mode: String)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_to_group, set_property, set_meta, _on_gizmo_selected

#### `_process(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_mouse_button_pressed, _handle_drag, _end_drag, _update_gizmo_position

*... and 21 more functions*

---

### 📄 scripts/core/asset_library.gd
**Functions:** 35

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _count_total_assets, push_error, str, print, connect

#### `register_asset(category: String, asset_id: String, asset_info: Dictionary)`
- **Purpose:** Add new asset to the library
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** has, emit_signal, print, push_error
- **Signals:** asset_catalog_updated

#### `unregister_asset(category: String, asset_id: String)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** has, emit_signal, is_empty, erase
- **Signals:** asset_catalog_updated

#### `get_asset_info(category: String, asset_id: String)`
- **Purpose:** Get metadata about an asset
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** has

#### `get_assets_by_category(category: String)`
- **Purpose:** Get all assets in a category
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** has

#### `get_assets_by_tag(tag: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** has, append

#### `search_assets(search_term: String)`
- **Purpose:** Function in asset_library system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, to_lower, contains, has

#### `load_asset(category: String, asset_id: String, auto_approve: bool = false)`
- **Purpose:** Load asset from catalog by name
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, queue_operation, push_error, get_asset_info, print

#### `unload_asset(category: String, asset_id: String)`
- **Purpose:** Function in asset_library system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** has, emit_signal, queue_operation, erase
- **Signals:** asset_unloaded

#### `preload_category(category: String, auto_approve: bool = false)`
- **Purpose:** Function in asset_library system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, load_asset, print, push_error

#### `preload_by_tag(tag: String, auto_approve: bool = false)`
- **Purpose:** Function in asset_library system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, str, print, get_assets_by_tag, load_asset

#### `spawn_asset(category: String, asset_id: String, parent: Node, position: Vector3 = Vector3.ZERO)`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** queue_operation, push_error, get_asset_info, has, get_path

#### `_on_asset_approval_needed(asset_path: String)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, emit_signal, _find_asset_by_path, push_warning, is_empty
- **Signals:** asset_approval_requested

#### `approve_asset(full_id: String)`
- **Purpose:** Function in asset_library system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, approve_asset, emit_signal, size, remove_at
- **Signals:** asset_approved

#### `reject_asset(full_id: String)`
- **Purpose:** Function in asset_library system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, emit_signal, size, remove_at, range
- **Signals:** asset_rejected

*... and 20 more functions*

---

### 📄 scripts/core/enhanced_ragdoll_walker.gd
**Functions:** 34

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _configure_physics, values, get_tree, print, _find_body_parts

#### `_find_body_parts()`
- **Purpose:** Function in enhanced_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_meta, get_parent, print, get, has_meta

#### `_configure_physics()`
- **Purpose:** Function in enhanced_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_step_cycle, _clear_movement_command, _update_state_machine, print, _update_state_blending

#### `_process_movement_input()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, length, get_camera_3d, normalized

#### `_update_state_machine(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _enter_state, _is_action_safe, length, _is_action_just_pressed_safe

#### `_enter_state(new_state: MovementState)`
- **Purpose:** Function in enhanced_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _perform_landing, _perform_jump

#### `_update_state_blending(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** lerp, values

#### `_apply_blended_physics(delta: float)`
- **Purpose:** Function in enhanced_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_strafing_forces, _adjust_height_to_target, _apply_balance_forces, lerp, _apply_rotation_forces

#### `_apply_walking_forces(weight: float)`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_central_force, _apply_step_animation

#### `_apply_running_forces(weight: float)`
- **Purpose:** Function in enhanced_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_central_force, _apply_step_animation

#### `_apply_crouch_walking_forces(weight: float)`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_central_force, _apply_step_animation

#### `_apply_strafing_forces(weight: float)`
- **Purpose:** Function in enhanced_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** cross, apply_central_force

#### `_apply_rotation_forces(weight: float)`
- **Purpose:** Function in enhanced_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_torque

#### `_apply_step_animation(weight: float, speed: float)`
- **Purpose:** Function in enhanced_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** sin, apply_central_force, cos, fmod

*... and 19 more functions*

---

### 📄 scripts/core/mouse_interaction_system.gd
**Functions:** 33

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process, _find_camera, print, set_process_unhandled_input, _create_debug_panel

#### `_exit_tree()`
- **Purpose:** Function in mouse_interaction_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_parent, queue_free, call_deferred

#### `_find_camera()`
- **Purpose:** Function in mouse_interaction_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, print, get_camera_3d, push_error

#### `_create_debug_panel()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, push_error, Vector2, Color, call_deferred

#### `_unhandled_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _handle_mouse_click, print, _handle_mouse_hover, _clear_selection, _handle_mouse_release

#### `_handle_mouse_click(mouse_pos: Vector2)`
- **Purpose:** Function in mouse_interaction_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _clear_selection, project_ray_normal, get_world_3d, _select_object, print

#### `_select_object(obj: Node)`
- **Purpose:** Function in mouse_interaction_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, get_first_node_in_group, _update_debug_panel, get_meta, get_parent

#### `_clear_selection()`
- **Purpose:** Function in mouse_interaction_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _on_close_pressed, print, get_node_or_null, has_method

#### `_update_debug_panel()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_meta_list, get_groups, get_file, get_meta, size

#### `_update_panel_position()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, get_visible_rect, clamp

#### `_process(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_panel_position, _update_debug_panel

#### `cmd_toggle_debug_panel()`
- **Purpose:** Function in mouse_interaction_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, print

#### `cmd_inspect_scene()`
- **Purpose:** Function in mouse_interaction_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_nodes_in_group, size, get_tree, str, print

#### `cmd_set_panel_offset(x: float, y: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector2, str, print

#### `cmd_toggle_panel_follow()`
- **Purpose:** Function in mouse_interaction_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, print

*... and 18 more functions*

---

### 📄 scripts/core/ragdoll_controller.gd
**Functions:** 33

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, _setup_default_patrol, print, _find_ragdoll_body, get_node

#### `_spawn_seven_part_ragdoll()`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, get_tree, print, add_child, set_script

#### `_find_ragdoll_body()`
- **Purpose:** Function in ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_nodes_in_group, size, get_tree, print, _spawn_seven_part_ragdoll

#### `_setup_default_patrol()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_investigating, _process_idle, _process_organizing, _process_walking, _process_carrying

#### `_process_idle(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** move_to_object, _find_nearby_objects, move_to_position, size, set_behavior_state

#### `_process_walking(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** distance_to, emit_signal, size, _apply_movement_to_ragdoll, set_behavior_state
- **Signals:** movement_completed

#### `_process_investigating(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_nearby_objects, size, set_behavior_state, attempt_pickup

#### `_process_carrying(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_carried_object_position, set_behavior_state, _look_for_organization_spot

#### `_process_helping(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_process_organizing(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** drop_object_at_position, _find_good_drop_position

#### `_apply_movement_to_ragdoll(delta: float)`
- **Purpose:** Function in ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_body, normalized, atan2, angle_difference, start_walking

#### `_find_nearby_objects(radius: float = 5.0)`
- **Purpose:** Function in ragdoll_controller system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, distance_to, get_nodes_in_group, get_tree, sort_custom

#### `_update_carried_object_position()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`

#### `_look_for_organization_spot()`
- **Purpose:** Function in ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_behavior_state, randf

*... and 18 more functions*

---

### 📄 scripts/core/self_repair_system.gd
**Functions:** 32

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_repair_strategies, _scan_all_scripts, size, str, _setup_python_integration

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_csv_data, _perform_health_check

#### `_scan_all_scripts()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, str, _register_script, _find_all_scripts, _print

#### `_find_all_scripts()`
- **Purpose:** Function in self_repair_system system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** _scan_directory

#### `_scan_directory(path: String, scripts: Array)`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, ends_with, list_dir_begin, get_next, begins_with

#### `_register_script(script_path: String)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _analyze_script_content, _categorize_script, get_modified_time

#### `_categorize_script(script_path: String)`
- **Purpose:** Function in self_repair_system system
- **Lines:** 0
- **Returns:** `String`

#### `_analyze_script_content(script_path: String)`
- **Purpose:** Function in self_repair_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** close, get_as_text, open, count, _detect_potential_issues

#### `_detect_potential_issues(content: String)`
- **Purpose:** Function in self_repair_system system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, contains

#### `_perform_health_check()`
- **Purpose:** Function in self_repair_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _check_script_health, str, _print, _attempt_repair, emit

#### `_check_script_health(script_path: String)`
- **Purpose:** Function in self_repair_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** _analyze_script_content, file_exists, get_modified_time, _find_script_instances, is_instance_valid

#### `_find_script_instances(script_path: String)`
- **Purpose:** Function in self_repair_system system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** get_tree, _find_instances_recursive

#### `_find_instances_recursive(node: Node, script_path: String, instances: Array)`
- **Purpose:** Function in self_repair_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, str, get_script, _find_instances_recursive, get_children

#### `_setup_repair_strategies()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`

#### `_attempt_repair(script_path: String, issue: String)`
- **Purpose:** Function in self_repair_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, emit, call

*... and 17 more functions*

---

### 📄 scripts/core/perfect_astral_being.gd
**Functions:** 31

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_awareness, _create_perfect_form, _begin_existence

#### `_create_perfect_form()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Color, new, add_child

#### `_setup_awareness()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, new, add_child

#### `_begin_existence()`
- **Purpose:** Function in perfect_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _next_action

#### `_physics_process(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_helping, _process_behavior_script, _update_visual_effects, _process_idle, _process_organizing

#### `_process_idle(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** sin

#### `_process_hovering(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** sin

#### `_process_flying(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** distance_to, normalized, looking_at, length, interpolate_with

#### `_process_following(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_instance_valid, Vector3, _process_flying

#### `_process_creating(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_magical_object

#### `_process_organizing(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _organize_nearby_objects

#### `_process_helping(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _help_nearest_entity

#### `_process_patrolling(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, cos, _process_flying, sin

#### `_process_dancing(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** cos, sin

#### `_update_visual_effects(delta)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, sin

*... and 16 more functions*

---

### 📄 scripts/core/debug_3d_screen.gd
**Functions:** 27

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** call_deferred, get_tree, print, _safe_initialize

#### `_safe_initialize()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process, _create_3d_screen, _create_debug_gizmo

#### `_create_3d_screen()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_image, str, print, add_child, deg_to_rad

#### `_create_debug_gizmo()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_axis_indicator, new, add_child

#### `_create_axis_indicator(direction: Vector3, color: Color, label: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** deg_to_rad, new, add_child

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_gizmo_position, _update_debug_display

#### `_update_debug_display()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _draw_camera_info, _collect_scene_debug_info, set_image, _draw_scene_overview, _draw_selected_object_info

#### `_collect_scene_debug_info()`
- **Purpose:** Function in debug_3d_screen system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_nodes_in_group, get_tree, size, has_method, append_array

#### `_get_object_type(obj: Node3D)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** to_lower

#### `_draw_scene_overview()`
- **Purpose:** Function in debug_3d_screen system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, get, _draw_text

#### `_draw_object_list()`
- **Purpose:** Function in debug_3d_screen system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, str, _draw_text, _get_object_type, range

#### `_draw_selected_object_info()`
- **Purpose:** Function in debug_3d_screen system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, str, _draw_text, rad_to_deg, _get_object_type

#### `_draw_camera_info()`
- **Purpose:** Function in debug_3d_screen system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, str, _draw_text, get_camera_3d

#### `_draw_text(text: String, x: int, y: int, color: Color)`
- **Purpose:** Function in debug_3d_screen system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_height, _draw_char, length, range, get_width

#### `_draw_char(character: String, x: int, y: int, color: Color)`
- **Purpose:** Function in debug_3d_screen system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_height, set_pixel, get_width, range

*... and 12 more functions*

---

### 📄 scripts/core/interface_manifestation_system.gd
**Functions:** 27

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _initialize_eden_records_references

#### `_initialize_eden_records_references()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_script, new, get_node_or_null, load

#### `create_3d_interface_from_eden_records(interface_type: String, properties: Dictionary = {})`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** print, _create_3d_interface_from_blueprint, _create_fallback_interface, is_empty, _load_3d_blueprint

#### `_load_3d_blueprint(interface_type: String)`
- **Purpose:** Function in interface_manifestation_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** file_exists, create_default_blueprint, print, parse_blueprint_file, load

#### `_create_3d_interface_from_blueprint(blueprint_data: Dictionary, interface_type: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** _create_interface_soul_effects, size, print, add_child, _create_interaction_area

#### `_create_element_from_blueprint(element: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** _create_3d_text, Vector2, _create_3d_slider, _create_3d_particles, print

#### `_create_3d_panel(position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** Vector3, add_child, _get_color_from_string, get, new

#### `_create_3d_button(position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** Vector3, add_child, _get_color_from_string, set_meta, has

#### `_create_3d_text(position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** add_child, _get_color_from_string, has, new, get

#### `_create_3d_slider(position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** Vector3, add_child, _get_color_from_string, get, new

#### `_create_3d_particles(position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** Vector3, add_child, _get_color_from_string, new, get

#### `_get_color_from_string(color_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Color`
- **Key Calls:** Color, to_lower

#### `_get_records_map_for_interface(interface_type: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** has, _create_generic_interface_records

#### `_create_ui_from_records(records_map: Dictionary, interface_type: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Control`
- **Key Calls:** add_theme_font_size_override, Vector2, Color, add_child, _create_elements_from_records

#### `_create_elements_from_records(container: Control, records_map: Dictionary, interface_type: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, Vector2, to_float, size, Color

*... and 12 more functions*

---

### 📄 scripts/core/physics_state_manager.gd
**Functions:** 27

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_physics_process

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_state_transitions, _apply_custom_physics

#### `set_object_state(object: Node3D, new_state: PhysicsState, force: bool = false)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** append, get_ticks_msec, get_object_state, print, _state_to_string

#### `get_object_state(object: Node3D)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `PhysicsState`
- **Key Calls:** get

#### `_can_transition(from_state: PhysicsState, to_state: PhysicsState)`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `bool`

#### `_process_state_transitions(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _complete_state_transition, append, size, remove_at, range

#### `_complete_state_transition(transition: Dictionary)`
- **Purpose:** Function in physics_state_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, print, _state_to_string, is_instance_valid, _apply_physics_state
- **Signals:** state_changed

#### `_update_state_transition(transition: Dictionary, _delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_instance_valid, sin, _apply_transition_physics, has_method

#### `_apply_physics_state(object: Node3D, state: PhysicsState)`
- **Purpose:** Function in physics_state_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _make_kinematic, _make_dynamic, _make_static, _make_connected, _make_ethereal

#### `_make_static(object: Node3D)`
- **Purpose:** Function in physics_state_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_physics_process, _set_collision_enabled

#### `_make_kinematic(object: Node3D)`
- **Purpose:** Function in physics_state_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_physics_process, _set_collision_enabled

#### `_make_dynamic(object: Node3D)`
- **Purpose:** Function in physics_state_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_physics_process, _set_collision_enabled

#### `_make_ethereal(object: Node3D)`
- **Purpose:** Function in physics_state_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_method, _set_collision_enabled

#### `_make_connected(object: Node3D)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _make_kinematic

#### `_set_collision_enabled(object: Node3D, enabled: bool)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_collision_shapes

*... and 12 more functions*

---

### 📄 scripts/core/simple_ragdoll_walker.gd
**Functions:** 27

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _configure_physics, get_tree, print, set_physics_process, _find_body_parts

#### `_find_body_parts()`
- **Purpose:** Function in simple_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_meta, get_parent, print, get, has_meta

#### `_configure_physics()`
- **Purpose:** Function in simple_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_falling, _process_idle, _process_standing_up, _process_balancing, _update_state

#### `_update_state(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _is_on_ground, _is_upright, length, _is_falling

#### `_process_idle()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_process_standing_up()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, _apply_upright_torque, _position_feet_for_standing, apply_central_impulse, _apply_leg_straightening_forces

#### `_process_balancing()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_upright_torque, _maintain_height, _balance_over_feet

#### `_process_stepping(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_upright_torque, _maintain_height, _apply_step_forces

#### `_process_falling()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _orient_feet_down

#### `_maintain_height()`
- **Purpose:** Function in simple_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_central_force

#### `_apply_upright_torque()`
- **Purpose:** Function in simple_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** length_squared, dot, is_zero_approx, apply_torque, cross

#### `_balance_over_feet()`
- **Purpose:** Maintain ragdoll balance and stability
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, apply_central_force, _calculate_center_of_mass

#### `_apply_step_forces()`
- **Purpose:** Function in simple_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _stabilize_foot, apply_central_force

#### `_apply_leg_straightening_forces()`
- **Purpose:** Function in simple_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, apply_central_force, limit_length

*... and 12 more functions*

---

### 📄 scripts/core/eden_action_system.gd
**Functions:** 26

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_action_queue, _cleanup_old_combos, _update_active_actions

#### `queue_action(action_name: String, target: Node, params: Dictionary = {})`
- **Purpose:** Function in eden_action_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** append, get_ticks_msec, push_error, emit_signal, _check_action_requirements
- **Signals:** action_failed

#### `process_combo_input(input_type: String, target: Node = null)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, _check_combo_pattern, clear, filter

#### `_check_action_requirements(action_def: Dictionary, target: Node)`
- **Purpose:** Function in eden_action_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** has, size, is_class

#### `_cleanup_old_combos()`
- **Purpose:** Function in eden_action_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, filter

#### `_process_action_queue(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_empty, pop_front, _start_action

#### `_start_action(action: Dictionary)`
- **Purpose:** Function in eden_action_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _execute_action_step, emit_signal
- **Signals:** action_started

#### `_execute_action_step(action: Dictionary)`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, _step_grasp, _step_lift, _complete_action, _step_target

#### `_update_active_actions(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, range, _execute_action_step

#### `_complete_action(action: Dictionary)`
- **Purpose:** Function in eden_action_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, erase
- **Signals:** action_completed

#### `_check_combo_pattern(pattern: Dictionary)`
- **Purpose:** Function in eden_action_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** has, size, range

#### `_trigger_combo(combo_name: String, pattern: Dictionary)`
- **Purpose:** Function in eden_action_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, queue_action, has, emit_signal
- **Signals:** combo_triggered

#### `_step_look(action: Dictionary)`
- **Purpose:** Function in eden_action_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `_step_analyze(action: Dictionary)`
- **Purpose:** Function in eden_action_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_groups, get_class

*... and 11 more functions*

---

### 📄 scripts/core/universal_entity/lists_viewer_system.gd
**Functions:** 26

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _ensure_directories, start, add_child, load_all_rules, new

#### `_ensure_directories()`
- **Purpose:** Function in lists_viewer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** make_dir, open, dir_exists

#### `_create_example_files()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** store_line, open, file_exists, close

#### `load_all_lists()`
- **Purpose:** Function in lists_viewer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** ends_with, list_dir_begin, get_next, open, load_list

#### `load_list(filename: String)`
- **Purpose:** Function in lists_viewer_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** append, _print, close, get_modified_time, trim_suffix

#### `_parse_list_line(line: String)`
- **Purpose:** Function in lists_viewer_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** Vector3, size, to_float, range, is_empty

#### `load_all_rules()`
- **Purpose:** Function in lists_viewer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** ends_with, list_dir_begin, load_rules, get_next, open

#### `load_rules(filename: String)`
- **Purpose:** Function in lists_viewer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, close, get_modified_time, str, begins_with

#### `_parse_rule(line: String)`
- **Purpose:** Function in lists_viewer_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** split, _parse_interval, _parse_condition, strip_edges, replace

#### `_parse_condition(condition_str: String)`
- **Purpose:** Function in lists_viewer_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** to_int, split, to_float, size, replace

#### `_parse_interval(interval_str: String)`
- **Purpose:** Function in lists_viewer_system system
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** to_float, replace

#### `check_and_execute_rules()`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _execute_action, get_ticks_msec, _check_condition

#### `_check_condition(condition: Dictionary)`
- **Purpose:** Function in lists_viewer_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** get_frames_per_second, _check_proximity, get_static_memory_usage, get_tree, size

#### `_compare_values(value1, operator: String, value2)`
- **Purpose:** Function in lists_viewer_system system
- **Lines:** 0
- **Returns:** `bool`

#### `_check_proximity(target_type: String)`
- **Purpose:** Function in lists_viewer_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** get_first_node_in_group, get_tree, distance_to

*... and 11 more functions*

---

### 📄 scripts/core/dimensional_ragdoll_system.gd
**Functions:** 25

#### `_init(px: float = 0, py: float = 0, pz: float = 0, pw: float = 0, pv: float = 0.1)`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 8
- **Returns:** `void`

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _initialize_consciousness, _setup_dimensional_physics, print

#### `_setup_dimensional_physics()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`

#### `_initialize_consciousness()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _learn_initial_spells

#### `_learn_initial_spells()`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** learn_spell

#### `shift_dimension(target_dimension: Dimension)`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** keys, _apply_dimensional_effects, emit_signal, float, print
- **Signals:** dimension_changed

#### `_apply_dimensional_effects(dimension: Dimension)`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`

#### `add_consciousness_experience(amount: float, source: String = "")`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, _evolve_to_stage, emit_signal, print
- **Signals:** consciousness_evolved

#### `_get_evolution_stage(level: float)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

#### `_evolve_to_stage(new_stage: String)`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** learn_spell, _update_emotion_state, print

#### `learn_spell(spell_name: String)`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, print, emit_signal
- **Signals:** spell_learned

#### `cast_spell(spell_name: String, target: Node3D = null)`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** add_consciousness_experience, _spell_reality_shift, _spell_float, _spell_glow, print

#### `set_emotion(emotion: String, value: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_emotion_state, clamp

#### `_update_emotion_state()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, s, print
- **Signals:** emotion_changed

#### `process_interaction(interaction_type: String, object: Node3D = null)`
- **Purpose:** Handle ongoing operations or data
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, add_consciousness_experience, get_ticks_msec, set_emotion, _detect_interaction_patterns

*... and 10 more functions*

---

### 📄 scripts/core/magical_astral_being.gd
**Functions:** 25

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_particles, print, set_physics_process, _create_visuals

#### `_create_visuals()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child

#### `_setup_particles()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, new, add_child

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, sin, size, rotate_y, _process_next_task

#### `add_task(task_type: String, params: Dictionary = {})`
- **Purpose:** Function in magical_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, print

#### `_process_next_task()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _task_organize_area, _task_patrol, _task_collect_objects, pop_front, print

#### `_task_move_to(target_position: Vector3)`
- **Purpose:** Function in magical_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_teleport_effect, print, tween_property, create_tween, tween_callback

#### `_task_collect_objects(radius: float)`
- **Purpose:** Function in magical_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_world_3d, create_timer, intersect_shape, get_tree, print

#### `_task_organize_area(center: Vector3)`
- **Purpose:** Function in magical_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_magic_circle, _levitate_object_to, sin, _find_nearby_objects, size

#### `_task_create_light(light_position: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Color, get_tree, print, add_child

#### `_task_help_ragdoll()`
- **Purpose:** Function in magical_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_health, emit, get_nodes_in_group, Vector3, get_tree

#### `_task_clean_scene()`
- **Purpose:** Function in magical_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, create_timer, get_tree, size, print

#### `_task_patrol(points: Array)`
- **Purpose:** Function in magical_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _patrol_loop, Vector3, size, print, is_empty

#### `_patrol_loop(points: Array)`
- **Purpose:** Function in magical_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _task_organize_area, _patrol_loop, create_timer, size, get_tree

#### `_create_teleport_effect(pos: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, add_child, tween_property, create_tween, tween_callback

*... and 10 more functions*

---

### 📄 scripts/core/universal_being_visualizer.gd
**Functions:** 25

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, _generate_uuid, str, _create_interaction_area, _setup_transformation_system

#### `_generate_uuid()`
- **Purpose:** Function in universal_being_visualizer system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_ticks_msec, str, randi

#### `_create_star_visualization()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, Vector3, get_tree, tween_property, add_child

#### `_create_star_texture()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `ImageTexture`
- **Key Calls:** set_pixel, Vector2i, Vector2, Color, set_image

#### `_create_interaction_area()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** created, add_child, new, _print, connect

#### `_setup_transformation_system()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, connect, new, add_child

#### `_register_with_systems()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, get_tree, add_to_group, set_meta, has_method

#### `_on_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _on_clicked

#### `_on_clicked()`
- **Purpose:** Function in universal_being_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, Being, emit, keys, size

#### `_create_click_effect()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, get_tree, tween_property, create_tween

#### `_on_body_entered(body: Node3D)`
- **Purpose:** Function in universal_being_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, size, str, _analyze_transformation_possibilities, _print

#### `_on_body_exited(body: Node3D)`
- **Purpose:** Function in universal_being_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** erase, size, str, _print, emit

#### `_on_area_entered(area: Area3D)`
- **Purpose:** Function in universal_being_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_parent, _print, is_in_group

#### `_on_area_exited(area: Area3D)`
- **Purpose:** Function in universal_being_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_parent, _print, erase

#### `transform_into(new_form: String, properties: Dictionary = {})`
- **Purpose:** Function in universal_being_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start, _print, _start_transformation_visual, emit

*... and 10 more functions*

---

### 📄 scripts/core/the_universal_thing.gd
**Functions:** 24

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, _initialize_as_point, get_instance_id, str, register_thing

#### `_initialize_as_point()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, new, add_child

#### `become(what: Variant, properties: Dictionary = {})`
- **Purpose:** Function in the_universal_thing system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _become_connector, _become_word, emit_signal, _become_point_form, _become_creator
- **Signals:** became_something

#### `_become_point_form(props: Dictionary)`
- **Purpose:** Function in the_universal_thing system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, get
- **Signals:** state_changed

#### `_become_shape(props: Dictionary)`
- **Purpose:** Function in the_universal_thing system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, add_child, has, new, get
- **Signals:** became_something

#### `_become_ragdoll(props: Dictionary)`
- **Purpose:** Function in the_universal_thing system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** exists, reparent, emit_signal, add_child, new
- **Signals:** became_something

#### `_become_word(props: Dictionary)`
- **Purpose:** Function in the_universal_thing system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, Color, add_child, new, randf
- **Signals:** became_something

#### `_become_connector(props: Dictionary)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, get, connect_to_thing
- **Signals:** became_something

#### `_become_container(props: Dictionary)`
- **Purpose:** Function in the_universal_thing system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, get
- **Signals:** became_something

#### `_become_creator(props: Dictionary)`
- **Purpose:** Function in the_universal_thing system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, max, get
- **Signals:** became_something

#### `_become_data(props: Dictionary)`
- **Purpose:** Function in the_universal_thing system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, merge, get
- **Signals:** became_something

#### `_become_anything(props: Dictionary)`
- **Purpose:** Function in the_universal_thing system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, set_meta
- **Signals:** became_something

#### `_become_like(other)`
- **Purpose:** Function in the_universal_thing system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, duplicate
- **Signals:** became_something

#### `_cleanup_current_form()`
- **Purpose:** Function in the_universal_thing system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_parent, queue_free

#### `connect_to_thing(other: UniversalThing)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, emit_signal
- **Signals:** connected_to

*... and 9 more functions*

---

### 📄 scripts/core/astral_beings_OLD_DEPRECATED.gd
**Functions:** 23

#### `_init(spawn_pos: Vector3)`
- **Purpose:** Function in astral_beings_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `void`

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, _spawn_initial_beings, size, str, print

#### `_spawn_initial_beings()`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, Vector3, _create_being_visualization, randf_range, range

#### `_create_being_visualization(being: AstralBeing)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, size, str, add_child, AABB

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_being

#### `_update_being(being: AstralBeing, delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _assist_scene_organization, normalized, _assist_creative_work, _assist_ragdoll_support, _assist_object_manipulation

#### `_assist_ragdoll_support(being: AstralBeing, delta: float)`
- **Purpose:** Function in astral_beings_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_body, Vector3, _help_ragdoll_stand_up, has_method, abs

#### `_help_ragdoll_stand_up(ragdoll_body: RigidBody3D, being: AstralBeing)`
- **Purpose:** Function in astral_beings_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_torque_impulse, _create_assistance_effect, Vector3, print, apply_central_impulse

#### `_assist_object_manipulation(being: AstralBeing, delta: float)`
- **Purpose:** Function in astral_beings_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_instance_valid, Vector3, apply_central_force, is_in_group

#### `_assist_scene_organization(being: AstralBeing, delta: float)`
- **Purpose:** Function in astral_beings_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, get_nodes_in_group, Vector3, size, get_tree

#### `_assist_environmental_harmony(being: AstralBeing, delta: float)`
- **Purpose:** Function in astral_beings_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, int, randf, sin

#### `_assist_creative_work(being: AstralBeing, delta: float)`
- **Purpose:** Function in astral_beings_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, randf

#### `_create_assistance_effect(position: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, get_tree, create_timer, add_child, queue_free

#### `_on_player_needs_help()`
- **Purpose:** Function in astral_beings_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `_on_object_interaction(object: RigidBody3D)`
- **Purpose:** Function in astral_beings_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_available_being, print

*... and 8 more functions*

---

### 📄 scripts/core/universal_being_scene_container.gd
**Functions:** 23

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_visual_elements, _setup_interaction_area, _initialize_spatial_points

#### `_initialize_spatial_points()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, size, print

#### `_create_visual_elements()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_connection_point_visualization, new, add_child, _create_boundary_visualization

#### `_create_boundary_visualization()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, size, _create_point_marker, str, add_child

#### `_create_connection_point_visualization()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, Vector2, size, _get_face_normal, add_child

#### `_create_point_marker(position: Vector3, color: Color, size: float, marker_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** new, add_child

#### `_create_connection_point_visualizer(connection_data: Dictionary, index: int)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** connect, Vector3, bind, str, add_child

#### `_get_face_normal(side_index: int)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Vector3`
- **Key Calls:** Vector3

#### `_setup_interaction_area()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, new, add_child

#### `add_being_to_container(being: UniversalBeing, target_position: Vector3 = Vector3.ZERO)`
- **Purpose:** Function in universal_being_scene_container system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** append, reparent, emit_signal, print, set_meta
- **Signals:** being_added_to_container

#### `remove_being_from_container(being: UniversalBeing)`
- **Purpose:** Function in universal_being_scene_container system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** emit_signal, print, find, remove_at, remove_meta
- **Signals:** being_removed_from_container

#### `get_snap_position(world_position: Vector3)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Vector3`
- **Key Calls:** to_local, distance_to, position

#### `_is_position_within_bounds(position: Vector3)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** return, abs

#### `create_connection_point(position: Vector3, connection_type: String, properties: Dictionary = {})`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** append, Vector2, emit_signal, size, print
- **Signals:** connection_point_created

#### `connect_to_container(other_container: UniversalBeingSceneContainer, my_connection_id: int, other_connection_id: int)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** get_unix_time_from_system, append, emit_signal, size, print
- **Signals:** containers_connected

*... and 8 more functions*

---

### 📄 scripts/core/universal_being.gd
**Functions:** 22

#### `_ready()`
- **Purpose:** Initialize universal being with UUID and name
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, str

#### `become(new_form: String)`
- **Purpose:** Transform this being into a new form/type
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** manifest, print

#### `manifest(form_type: String)`
- **Purpose:** Create visual representation in the 3D world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_parent, _create_basic_manifestation, print, add_child, has_method

#### `_create_basic_manifestation(form_type: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Color, print, add_child, new

#### `set_property(key: String, value: Variant)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`

#### `get_property(key: String, default_value: Variant = null)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Variant`
- **Key Calls:** get

#### `become_interface(interface_type: String, properties: Dictionary = {})`
- **Purpose:** Function in universal_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_console_interface, print, _create_grid_interface, queue_free, _create_generic_interface

#### `become_container(container_type: String, size: Vector3 = Vector3(10, 5, 10), properties: Dictionary = {})`
- **Purpose:** Function in universal_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, add_child, queue_free, set_property, new

#### `get_container()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `UniversalBeingSceneContainer`
- **Key Calls:** get_property

#### `connect_to(other: UniversalBeing)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connection, print

#### `freeze()`
- **Purpose:** Function in universal_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** being, print, set_process

#### `unfreeze()`
- **Purpose:** Function in universal_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** being, print, set_process

#### `_to_string()`
- **Purpose:** Function in universal_being system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** UniversalBeing

#### `_create_asset_creator_interface(properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_basic_interface_fallback, create_3d_interface_from_eden_records, print, add_child, load

#### `_create_console_interface(properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_basic_interface_fallback, create_3d_interface_from_eden_records, print, add_child, load

*... and 7 more functions*

---

### 📄 scripts/core/universal_being_layer_system.gd
**Functions:** 22

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_commands, _setup_interface_materials, print, add_to_group

#### `_register_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, get_node_or_null

#### `add_to_layer(node: Node3D, layer: LayerType)`
- **Purpose:** Function in universal_being_layer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _apply_world_layer, keys, _apply_interface_layer, print

#### `remove_from_all_layers(node: Node3D)`
- **Purpose:** Function in universal_being_layer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** erase

#### `_apply_world_layer(node: Node3D)`
- **Purpose:** Function in universal_being_layer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _reset_node_rendering

#### `_apply_interface_layer(node: Node3D)`
- **Purpose:** Function in universal_being_layer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _make_always_visible, _apply_interface_materials_to_node

#### `_apply_overlay_layer(node: Node3D)`
- **Purpose:** Function in universal_being_layer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _make_always_visible, _apply_overlay_materials_to_node

#### `_make_always_visible(node: Node3D)`
- **Purpose:** Function in universal_being_layer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_always_visible_recursive

#### `_apply_always_visible_recursive(node: Node)`
- **Purpose:** Function in universal_being_layer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_layer_mask, set_meta, set_layer_mask, get_children, _apply_always_visible_recursive

#### `_get_always_visible_material()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `StandardMaterial3D`
- **Key Calls:** Color, new

#### `_setup_interface_materials()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `_apply_interface_materials_to_node(node: Node3D)`
- **Purpose:** Function in universal_being_layer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _make_always_visible, set_meta

#### `_apply_overlay_materials_to_node(node: Node3D)`
- **Purpose:** Function in universal_being_layer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _make_always_visible, set_meta

#### `_reset_node_rendering(node: Node3D)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _reset_rendering_recursive

#### `_reset_rendering_recursive(node: Node)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_meta, _reset_rendering_recursive, set_layer_mask, get_children, remove_meta

*... and 7 more functions*

---

### 📄 scripts/core/astral_being_enhanced_OLD_DEPRECATED.gd
**Functions:** 21

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_star_being, print, set_physics_process, get_node_or_null

#### `_create_star_being()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, connect, new, add_child

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_free_flight, _update_connection_awareness, _process_orbiting, _process_creating, _process_blinking

#### `_process_free_flight(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, distance_to, start_orbiting, sin, Vector3

#### `_process_orbiting(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** sin, Vector3, look_at, lerp, is_instance_valid

#### `_process_creating(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, sin, _create_trail_light, size, Vector3

#### `_process_following(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_process_blinking(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_update_connection_awareness()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _is_connected_to, Color, size, clear

#### `_is_connected_to(obj: Node3D)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** get_parent, get_groups, is_in_group

#### `_create_trail_light()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** new, add_child

#### `_find_closest_object()`
- **Purpose:** Function in astral_being_enhanced_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** distance_to

#### `start_orbiting(target: Node3D)`
- **Purpose:** Function in astral_being_enhanced_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_bounding_box, length, angle_to, has_method

#### `stop_orbiting()`
- **Purpose:** Function in astral_being_enhanced_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `void`

#### `enter_creation_mode()`
- **Purpose:** Function in astral_being_enhanced_OLD_DEPRECATED system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_instance_valid, clear, queue_free

*... and 6 more functions*

---

### 📄 scripts/core/triangular_bird_walker.gd
**Functions:** 21

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_sensors, _create_bird_physics, _set_idle_position, _create_visual_meshes

#### `_create_bird_physics()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, _create_joints, _create_body_part

#### `_create_body_part(part_name: String, offset: Vector3, part_mass: float)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `RigidBody3D`
- **Key Calls:** new, add_child

#### `_create_joints()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _connect_bodies

#### `_connect_bodies(body_a: RigidBody3D, body_b: RigidBody3D)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child, get_path

#### `_create_visual_meshes()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, new, add_child

#### `_create_sensors()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, new, add_child

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _maintain_balance, _process_drinking, _process_idle, _process_walking, _process_flying

#### `_process_idle(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, size, randf_range, randf

#### `_process_walking(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** distance_to, normalized, sin, Vector3, max

#### `_process_flying(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, get_ticks_msec, apply_central_force, sin

#### `_process_eating(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, get_ticks_msec, apply_central_force, sin

#### `_process_drinking(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, get_ticks_msec, apply_central_force, sin

#### `_maintain_balance(delta: float)`
- **Purpose:** Function in triangular_bird_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, apply_central_force

#### `_update_triangle_meshes()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** PackedVector3Array, _update_mesh

*... and 6 more functions*

---

### 📄 scripts/core/universal_data_hub.gd
**Functions:** 21

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, set_process

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `register_system(system_name: String, system: Node)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** push_warning, print, emit

#### `get_system(system_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** get

#### `register_object(obj: Node, type: String = "generic")`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, _generate_uuid, set_meta, has_method, emit

#### `get_object(uuid: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** get

#### `get_objects_by_type(type: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** is_instance_valid, get, append

#### `unregister_object(uuid: String)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_meta, erase

#### `get_all_beings()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** is_instance_valid, append

#### `get_beings_by_form(form: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, get, get_all_beings

#### `register_rule(rule_name: String, callable: Callable)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `execute_rule(rule_name: String, params: Array = [])`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `Variant`
- **Key Calls:** callv, push_error

#### `set_global(var_name: String, value: Variant)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`

#### `get_global(var_name: String, default: Variant = null)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Variant`
- **Key Calls:** get

#### `check_limits()`
- **Purpose:** Function in universal_data_hub system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** _estimate_memory, get_frames_per_second

*... and 6 more functions*

---

### 📄 scripts/core/universal_entity/global_variable_inspector.gd
**Functions:** 21

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** scan_all_variables, _print, get_node_or_null

#### `scan_all_variables()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _scan_scene_variables, _scan_autoloads, _scan_engine_settings, _scan_project_settings

#### `_scan_autoloads()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_property_list, begins_with, _scan_node_properties, clear, trim_prefix

#### `_scan_project_settings()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, get_property_list, get_setting, begins_with

#### `_scan_engine_settings()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_frames_per_second

#### `_scan_scene_variables()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, get_tree, _scan_node_recursive

#### `_scan_node_properties(node: Node)`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_property_list, get

#### `_scan_node_recursive(node: Node, max_depth: int = 3, current_depth: int = 0)`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** _scan_node_recursive, _scan_node_properties, get_children, get_path, get_class

#### `get_variable(path: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, split, path

#### `set_variable(path: String, value)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** _set_engine_setting, _set_autoload_variable, _set_project_setting, split

#### `_set_autoload_variable(parts: Array, value)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** emit, size, slice, join, set

#### `_set_project_setting(parts: Array, value)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** emit, size, slice, join, get_setting

#### `_set_engine_setting(parts: Array, value)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** join, size, emit

#### `watch_variable(path: String, callback: Callable)`
- **Purpose:** Function in global_variable_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, append

#### `unwatch_variable(path: String, callback: Callable)`
- **Purpose:** Function in global_variable_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, erase

*... and 6 more functions*

---

### 📄 scripts/jsh_framework/core/system_check.gd
**Functions:** 21

#### `check_all_things()`
- **Purpose:** Function in system_check system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `_init()`
- **Purpose:** Function in system_check system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** initialize_word_system, print, scan_available_storage

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, bind, has_signal, get_node, connect

#### `find_matching_symbols(text: String, start_symbol: String, end_symbol: String)`
- **Purpose:** Function in system_check system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, length, substr, range

#### `verify_system_component(component_name: String)`
- **Purpose:** Function in system_check system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_ticks_msec, unlock, lock

#### `_on_system_ready(system_name: String)`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 6
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, unlock, lock

#### `verify_system(system_name: String)`
- **Purpose:** Function in system_check system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** emit_signal, get_ticks_msec
- **Signals:** system_verified

#### `get_data_structure_size(data)`
- **Purpose:** Retrieve data or property value
- **Lines:** 48
- **Returns:** `int`
- **Key Calls:** size, get_data_structure_size, length, var_to_bytes, typeof

#### `get_jsh(property_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `void`

#### `check_memory_state()`
- **Purpose:** Function in system_check system
- **Lines:** 30
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, keys, get_data_structure_size, print, get_jsh

#### `clean_dictionary(dict_name: String)`
- **Purpose:** Function in system_check system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, get, keys, erase

#### `clean_array(array_name: String)`
- **Purpose:** Function in system_check system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, size, filter, slice

#### `scan_available_storage()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** dir_exists_absolute, get_name, range, to_lower, substr

#### `initialize_word_system()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has

#### `get_next_word()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, get_ticks_msec

*... and 6 more functions*

---

### 📄 scripts/core/advanced_being_system.gd
**Functions:** 20

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_physics_bones, _setup_animation_system, _setup_ik_systems, print, _setup_spring_bones

#### `_create_skeleton()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_custom_skeleton, new, add_child, _create_humanoid_skeleton

#### `_create_humanoid_skeleton()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Transform3D, Basis, set_bone_rest, set_bone_parent

#### `_create_custom_skeleton()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`

#### `_setup_physics_bones()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, add_child, has, _get_joint_type, new

#### `_get_bone_mass(bone_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`

#### `_get_joint_type(bone_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `PhysicalBone3D.JointType`

#### `_setup_spring_bones()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, new, add_child

#### `_setup_ik_systems()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, new, add_child

#### `_setup_animation_system()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child, NodePath

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_ik_targets, _process_hybrid, _process_recovery, _process_physics, _process_animated

#### `_process_animated(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_process_physics(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_process_hybrid(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_process_recovery(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

*... and 5 more functions*

---

### 📄 scripts/core/akashic_records_database.gd
**Functions:** 20

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, _start_server_connection, _initialize_core_records

#### `_initialize_core_records()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`

#### `create_record(type: String, data: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, get_ticks_msec, _generate_akashic_id, emit_signal, get
- **Signals:** record_created

#### `query_records(criteria: Dictionary)`
- **Purpose:** Function in akashic_records_database system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, _matches_criteria

#### `manifest_record(record_id: String, forced_lod: String = "")`
- **Purpose:** Function in akashic_records_database system
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** _manifest_as_3d_simple, _manifest_fully, emit_signal, _calculate_lod, _find_record
- **Signals:** record_manifested

#### `_manifest_as_text(record: Dictionary)`
- **Purpose:** Function in akashic_records_database system
- **Lines:** 11
- **Returns:** `Node`
- **Key Calls:** new, set_meta

#### `get_text_representation()`
- **Purpose:** Retrieve data or property value
- **Lines:** 5
- **Returns:** `String`
- **Key Calls:** get_meta_list, str, get_meta

#### `_manifest_as_2d_simple(record: Dictionary)`
- **Purpose:** Function in akashic_records_database system
- **Lines:** 0
- **Returns:** `Node2D`
- **Key Calls:** Vector2, Color, add_child, PackedVector2Array, get

#### `_manifest_as_3d_simple(record: Dictionary)`
- **Purpose:** Function in akashic_records_database system
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** get, new, add_child

#### `_manifest_as_3d_detailed(record: Dictionary)`
- **Purpose:** Function in akashic_records_database system
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** _manifest_as_3d_simple, add_child, has, new, int

#### `_manifest_fully(record: Dictionary)`
- **Purpose:** Function in akashic_records_database system
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** has, instantiate, _manifest_as_3d_detailed, load

#### `_calculate_lod(record: Dictionary)`
- **Purpose:** Function in akashic_records_database system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** distance_to, max, get

#### `update_all_lods(new_viewer_position: Vector3, new_consciousness: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** erase, size, _calculate_lod, queue_free, is_instance_valid

#### `create_connection(from_id: String, to_id: String, connection_type: String = "linked")`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, _find_record

#### `_generate_akashic_id()`
- **Purpose:** Function in akashic_records_database system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_ticks_msec, str, randi

*... and 5 more functions*

---

### 📄 scripts/core/universal_entity/universal_entity.gd
**Functions:** 20

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_universal_commands, create_timer, get_tree, str, _realize_the_dream

#### `_initialize_core_systems()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, add_child, has_signal, new, _print

#### `_register_universal_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, get_node_or_null

#### `_realize_the_dream()`
- **Purpose:** Function in universal_entity system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start, add_child, _check_perfection, new, _print

#### `_self_regulate()`
- **Purpose:** Function in universal_entity system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** force_cleanup, get_health_report, check_and_execute_rules, _update_satisfaction

#### `_check_perfection()`
- **Purpose:** Function in universal_entity system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** values, size, get_health_status, _print, emit

#### `_update_satisfaction()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_frames_per_second, values, get_health_status, str, _print

#### `_cmd_universal_status(args: Array)`
- **Purpose:** Function in universal_entity system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** int, _print, str

#### `_cmd_evolve(args: Array)`
- **Purpose:** Function in universal_entity system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, is_empty, emit

#### `_cmd_make_perfect(args: Array)`
- **Purpose:** Function in universal_entity system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _check_perfection, force_cleanup, _print, set_auto_fix

#### `_cmd_check_satisfaction(args: Array)`
- **Purpose:** Function in universal_entity system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** int, _print, str, _update_satisfaction

#### `_cmd_health_check(args: Array)`
- **Purpose:** Function in universal_entity system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _status_to_string, force_health_check, size, str, get_health_report

#### `_cmd_list_variables(args: Array)`
- **Purpose:** Function in universal_entity system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** export_to_txt, is_empty, size, str, search_variables

#### `_cmd_show_lists(args: Array)`
- **Purpose:** Function in universal_entity system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, _print, str

#### `_cmd_optimize_now(args: Array)`
- **Purpose:** Function in universal_entity system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** force_cleanup, _print, _apply_fps_fix

*... and 5 more functions*

---

### 📄 scripts/core/universal_entity/universal_loader_unloader.gd
**Functions:** 20

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, set_process, get_node_or_null

#### `load_node(path: String, parent: Node = null, priority: int = 0)`
- **Purpose:** Function in universal_loader_unloader system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _optimize_memory, get_ticks_msec, get_tree, sort_custom

#### `load_node_immediate(path: String, parent: Node = null)`
- **Purpose:** Function in universal_loader_unloader system
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** get_ticks_msec, exists, get_tree, add_child, has_method

#### `unload_node(node: Node, priority: UnloadPriority = UnloadPriority.NORMAL)`
- **Purpose:** Function in universal_loader_unloader system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_instance_valid, append, set_meta, is_in_group

#### `unload_nodes_by_distance(center: Vector3, max_distance: float)`
- **Purpose:** Function in universal_loader_unloader system
- **Lines:** 0
- **Returns:** `int`
- **Key Calls:** unload_node, get_tree, distance_to, get_nodes_in_group

#### `unload_heavy_nodes(memory_threshold_mb: float = 50)`
- **Purpose:** Function in universal_loader_unloader system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, unload_node, get_nodes_in_group, get_tree, has_method

#### `freeze_node_scripts(node: Node)`
- **Purpose:** Function in universal_loader_unloader system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process, get_script, set_physics_process, set_meta, set_process_unhandled_input

#### `unfreeze_node_scripts(node: Node)`
- **Purpose:** Function in universal_loader_unloader system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process, get_meta, set_physics_process, set_script, get_children

#### `_process(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _get_average_fps, get_frames_per_second, _emergency_optimization, get_tree

#### `_process_load_queue()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_empty, pop_front, load_node_immediate

#### `_process_unload_queue()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_instance_valid, is_empty, pop_front, _perform_unload

#### `_perform_unload(node: Node)`
- **Purpose:** Function in universal_loader_unloader system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, queue_free, get_path, fifth_dimensional_magic, emit

#### `_can_load_new_node()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** return, _get_average_fps

#### `_optimize_memory()`
- **Purpose:** Function in universal_loader_unloader system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** unload_node, has_cached, get_meta, get_nodes_in_group, erase

#### `_emergency_optimization()`
- **Purpose:** Function in universal_loader_unloader system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, distance_to, get_nodes_in_group, get_tree, unload_heavy_nodes

*... and 5 more functions*

---

### 📄 scripts/jsh_framework/core/jsh_data_splitter.gd
**Functions:** 20

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** check_all_settings_data, initialize_parser

#### `check_all_things()`
- **Purpose:** Function in jsh_data_splitter system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `initialize_parser()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_empty, push_error

#### `process_directory(path: String = "")`
- **Purpose:** Handle ongoing operations or data
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** process_file, duplicate, append, unlock, emit_signal
- **Signals:** parsing_completed

#### `process_file(file_path: String)`
- **Purpose:** Handle ongoing operations or data
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** unlock, file_exists, lock, get_as_text, parse_jsh_file

#### `update_parse_stats(success: bool, file_path: String)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`

#### `get_parse_stats()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** duplicate, unlock, lock

#### `parse_jsh_file(content: String)`
- **Purpose:** Function in jsh_data_splitter system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** append, trim_suffix, size, begins_with, has

#### `parse_block_metadata(metadata_str: String)`
- **Purpose:** Function in jsh_data_splitter system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** strip_edges, size, split

#### `validate_file_format(content: String)`
- **Purpose:** Check if data/state is valid
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** append, contains, begins_with

#### `collect_system_stats()`
- **Purpose:** Function in jsh_data_splitter system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** float, max

#### `analyze_file_content(content: String)`
- **Purpose:** Function in jsh_data_splitter system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** append, has, length, contains, split

#### `split_by_rules(content: String, level: String)`
- **Purpose:** Function in jsh_data_splitter system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** has, append_array, split

#### `parse_function_data(function_content: String)`
- **Purpose:** Function in jsh_data_splitter system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_function_body, get_function_inputs, get_function_name, analyze_file_content

#### `get_function_name(function_content: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** strip_edges, substr, split, begins_with

*... and 5 more functions*

---

### 📄 scripts/core/miracle_declutterer.gd
**Functions:** 19

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, start, print, add_child, get_node

#### `_update_declutter()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** erase, _scan_for_new_objects, is_instance_valid, _update_object_state, _update_player_position

#### `_update_player_position()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, get_nodes_in_group, get_tree, size, get_camera_3d

#### `_scan_for_new_objects()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _should_track, get_tree, _start_tracking, _get_all_3d_nodes

#### `_get_all_3d_nodes(from_node: Node)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, append_array, get_children, _get_all_3d_nodes

#### `_should_track(node: Node3D)`
- **Purpose:** Determine if action should be taken
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** has_method

#### `_start_tracking(node: Node3D)`
- **Purpose:** Function in miracle_declutterer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_object_state, get_script, new

#### `_update_object_state(node: Node3D)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_zone_state, distance_to, _get_zone_for_distance

#### `_get_zone_for_distance(distance: float)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

#### `_apply_zone_state(state: ObjectState)`
- **Purpose:** Function in miracle_declutterer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process, _simplify_visuals, has_method, _restore_details, emit

#### `_simplify_visuals(state: ObjectState, quality: float)`
- **Purpose:** Function in miracle_declutterer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _fade_object

#### `_restore_details(state: ObjectState)`
- **Purpose:** Function in miracle_declutterer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _fade_object, emit

#### `_fade_object(node: Node3D, alpha: float)`
- **Purpose:** Function in miracle_declutterer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_surface_override_material, get_surface_override_material_count

#### `get_zone_report()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** size, values

#### `force_declutter_all()`
- **Purpose:** Function in miracle_declutterer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_declutter, objects, print, emit

*... and 4 more functions*

---

### 📄 scripts/core/scene_tree_tracker.gd
**Functions:** 19

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start_up_scene_tree

#### `start_up_scene_tree()`
- **Purpose:** Function in scene_tree_tracker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** duplicate, get_ticks_msec, unlock, get_tree, lock

#### `track_node(node: Node, category: String = "")`
- **Purpose:** Function in scene_tree_tracker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, duplicate, get_ticks_msec, get_base_dir, unlock

#### `untrack_node(node: Node)`
- **Purpose:** Function in scene_tree_tracker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** unlock, str, lock, _remove_branch_by_path, get_path

#### `jsh_tree_get_node(node_path_get: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** unlock, size, lock, has, range

#### `build_pretty_print(start_branch: Dictionary = {}, prefix: String = "", is_last: bool = true)`
- **Purpose:** Function in scene_tree_tracker system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** keys, size, range, build_pretty_print, is_empty

#### `print_tree_structure()`
- **Purpose:** Function in scene_tree_tracker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** build_pretty_print, print

#### `get_nodes_by_type(jsh_type: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array[Node]`
- **Key Calls:** _collect_nodes_by_type, unlock, lock

#### `_collect_nodes_by_type(branches: Dictionary, jsh_type: String, nodes: Array[Node])`
- **Purpose:** Function in scene_tree_tracker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _collect_nodes_by_type, get, has

#### `_remove_branch_by_path(path: String)`
- **Purpose:** Function in scene_tree_tracker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, erase, size, has, range

#### `get_tree_stats()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** _collect_stats, lock, unlock

#### `_collect_stats(branches: Dictionary, stats: Dictionary)`
- **Purpose:** Function in scene_tree_tracker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, _collect_stats, get

#### `has_branch(path: String)`
- **Purpose:** Check if something exists or is available
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** has, unlock, lock, split

#### `get_branch(path: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** has, unlock, lock, split

#### `_set_branch_unsafe(path: String, data: Dictionary)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, size, range, split

*... and 4 more functions*

---

### 📄 scripts/core/simple_astral_being.gd
**Functions:** 19

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _start_behavior, _create_visual_form

#### `_create_visual_form()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Color, new, add_child

#### `_physics_process(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, _process_current_action, sin

#### `_process_current_action(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _next_action, _transform_something, _follow_target, _hover_in_place, _fly_to_position

#### `_next_action()`
- **Purpose:** Function in simple_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, size, _find_random_target, _find_named_target, is_empty
- **Signals:** action_completed

#### `_fly_to_target(delta)`
- **Purpose:** Function in simple_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** length, normalized, look_at

#### `_fly_to_position(target_pos: Vector3, delta)`
- **Purpose:** Function in simple_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** distance_to, normalized

#### `_hover_in_place(delta)`
- **Purpose:** Function in simple_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, sin

#### `_look_around(delta)`
- **Purpose:** Function in simple_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** rotate_y

#### `_follow_target(delta)`
- **Purpose:** Function in simple_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, _fly_to_position

#### `_create_something()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_parent, Vector3, preload, Color, add_child

#### `_transform_something()`
- **Purpose:** Function in simple_astral_being system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_nearest_object, become, has_method

#### `_find_random_target()`
- **Purpose:** Function in simple_astral_being system
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** randi, get_nodes_in_group, Vector3, get_tree, get_parent

#### `_find_named_target(target_name: String)`
- **Purpose:** Function in simple_astral_being system
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** get_first_node_in_group, get_tree, get_node_or_null

#### `_find_nearest_object()`
- **Purpose:** Function in simple_astral_being system
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** get_tree, distance_to, get_nodes_in_group

*... and 4 more functions*

---

### 📄 scripts/core/delta_frame_guardian.gd
**Functions:** 18

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_guardian_commands, print, set_process

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, get_frames_per_second, _exit_emergency_mode, _enter_emergency_mode, _distribute_frame_time

#### `register_script(node: Node, priority: int = 50, update_rate: float = 60.0)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, get_file, get_script, print

#### `unregister_script(node: Node)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_script, print, get_file, erase

#### `get_managed_delta(node: Node)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** get_ticks_msec, get_process_delta_time, _should_update, get_script, get

#### `_distribute_frame_time(delta: float)`
- **Purpose:** Function in delta_frame_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, float, get, _should_update

#### `_should_update(info: ScriptInfo)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** get_ticks_msec

#### `_track_frame_time(frame_time: float)`
- **Purpose:** Function in delta_frame_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, size, pop_front, _analyze_performance_issue

#### `_analyze_performance_issue()`
- **Purpose:** Function in delta_frame_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, sort_custom, size, _throttle_script

#### `_throttle_script(info: ScriptInfo, reason: String)`
- **Purpose:** Function in delta_frame_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_file, print, emit, min

#### `_enter_emergency_mode()`
- **Purpose:** Function in delta_frame_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, _throttle_script

#### `_exit_emergency_mode()`
- **Purpose:** Function in delta_frame_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, min

#### `get_performance_report()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** size, filter

#### `_register_guardian_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, get_node_or_null

#### `_cmd_fps_status(_args: Array)`
- **Purpose:** Function in delta_frame_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, get_performance_report, get_node

*... and 3 more functions*

---

### 📄 scripts/core/universal_inspection_bridge.gd
**Functions:** 18

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** call_deferred, print

#### `_connect_to_systems()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit, get_tree, print, _register_bridge_commands, _find_inspector_in_scene

#### `_find_inspector_in_scene()`
- **Purpose:** Function in universal_inspection_bridge system
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** get_first_node_in_group, get_nodes_in_group, get_tree, size, print

#### `_setup_scene_tree_monitoring()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, connect, is_connected, print

#### `_on_any_node_added(node: Node)`
- **Purpose:** Function in universal_inspection_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_instance_valid, _make_object_inspectable, _should_make_inspectable

#### `_should_make_inspectable(node: Node)`
- **Purpose:** Determine if action should be taken
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** to_lower, any_keyword_in_string

#### `any_keyword_in_string(text: String, keywords: Array)`
- **Purpose:** Function in universal_inspection_bridge system
- **Lines:** 0
- **Returns:** `bool`

#### `_make_object_inspectable(object: Node, source: String = "unknown")`
- **Purpose:** Function in universal_inspection_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _get_object_position, get_ticks_msec, add_tracked_object, get_instance_id, str

#### `_get_object_position(object: Node)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Vector3`
- **Key Calls:** Vector3

#### `_connect_floodgate_signals()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_signal, connect

#### `_connect_universal_signals()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_signal, connect

#### `_on_floodgate_object_created(object: Node)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _make_object_inspectable

#### `_on_universal_object_spawned(object: Node)`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _make_object_inspectable

#### `_register_bridge_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, has_method

#### `_cmd_list_inspectable(_args: Array)`
- **Purpose:** Function in universal_inspection_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_instance_valid, _print_to_console, s, at

*... and 3 more functions*

---

### 📄 scripts/jsh_framework/core/functions_database.gd
**Functions:** 18

#### `register_command(command_name: String, target_node: Node, function_name: String)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`

#### `create_chain(chain_name: String, commands: Array)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`

#### `execute_chain(chain_name: String, args = null)`
- **Purpose:** Run command or operation
- **Lines:** 41
- **Returns:** `void`
- **Key Calls:** has, get_ticks_msec, call, append

#### `_init(func_name: String)`
- **Purpose:** Function in functions_database system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** analyze_name

#### `analyze_name()`
- **Purpose:** Function in functions_database system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, has, get_char_type

#### `get_char_type(c: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 14
- **Returns:** `int`
- **Key Calls:** unicode_at

#### `add_function(func_text: String)`
- **Purpose:** Function in functions_database system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, extract_return_type, count_parameters, extract_function_name, is_empty

#### `extract_function_name(declaration: String)`
- **Purpose:** Function in functions_database system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** strip_edges, substr, find

#### `count_parameters(declaration: String)`
- **Purpose:** Function in functions_database system
- **Lines:** 0
- **Returns:** `int`
- **Key Calls:** size, find, strip_edges, is_empty, substr

#### `extract_return_type(declaration: String)`
- **Purpose:** Function in functions_database system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** strip_edges, substr, length, find

#### `get_function_analysis(func_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `FunctionAnalysis`
- **Key Calls:** get

#### `print_analysis(func_name: String)`
- **Purpose:** Function in functions_database system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_function_analysis, get_type_name

#### `get_type_name(type_code: int)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

#### `analyze_function_requirements(function_name: String)`
- **Purpose:** Function in functions_database system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** append, has_node, get_parent, NodePath, has

#### `check_function_compatibility(function_name: String)`
- **Purpose:** Function in functions_database system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** append, get_dependency_chain, is_empty, get

*... and 3 more functions*

---

### 📄 scripts/core/architecture_harmony_system.gd
**Functions:** 17

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, _register_harmony_commands, _scan_project_architecture, _map_script_connections

#### `_scan_project_architecture()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _analyze_process_usage, size, print, open, _scan_directory

#### `_scan_directory(dir: DirAccess, path: String)`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** ends_with, list_dir_begin, _analyze_script, get_next, begins_with

#### `_analyze_script(script_path: String)`
- **Purpose:** Function in architecture_harmony_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process, close, get_file, get_as_text, open

#### `_extract_extends(content: String)`
- **Purpose:** Function in architecture_harmony_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** compile, get_string, search, new

#### `_extract_signals(content: String)`
- **Purpose:** Function in architecture_harmony_system system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** compile, append, get_string, search_all, new

#### `_map_script_connections()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `_analyze_process_usage()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** keys, size, print, push_warning, emit

#### `get_best_ragdoll()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

#### `get_ragdoll_info(type: String = "")`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get

#### `find_conflicts()`
- **Purpose:** Function in architecture_harmony_system system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** _guess_purpose, append, values

#### `_guess_purpose(script_path: String)`
- **Purpose:** Function in architecture_harmony_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** to_lower, get_file

#### `_register_harmony_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, get_node_or_null

#### `_cmd_architecture_status(_args: Array)`
- **Purpose:** Function in architecture_harmony_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, size, get_node, get_best_ragdoll

#### `_cmd_ragdoll_status(_args: Array)`
- **Purpose:** Function in architecture_harmony_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** join, _print_to_console, get_node, s

*... and 2 more functions*

---

### 📄 scripts/core/heightmap_world_generator.gd
**Functions:** 17

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_containers, _setup_noise

#### `_setup_noise()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new

#### `_create_containers()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child

#### `generate_world()`
- **Purpose:** Function in heightmap_world_generator system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_terrain_mesh, _generate_heightmap, print, _place_vegetation, _create_water_sources

#### `_generate_heightmap()`
- **Purpose:** Function in heightmap_world_generator system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** pow, get_noise_2d, range, sqrt, resize

#### `_create_terrain_mesh()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, PackedInt32Array, Vector2, Vector3, float

#### `_create_terrain_collision()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_trimesh_collision, new, add_child

#### `_place_vegetation()`
- **Purpose:** Function in heightmap_world_generator system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _place_bush, print, get_node, range, _place_tree

#### `_place_tree(container: Node3D)`
- **Purpose:** Function in heightmap_world_generator system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_world_object, randi, Vector3, add_child, _check_slope_at

#### `_place_bush(container: Node3D)`
- **Purpose:** Function in heightmap_world_generator system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_world_object, randi, _create_bush_with_fruits, Vector3, add_child

#### `_create_tree_with_fruits(pos: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** _create_fruit, sin, Color, Vector3, add_to_group

#### `_create_bush_with_fruits(pos: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** _create_fruit, sin, Color, Vector3, add_to_group

#### `_create_fruit()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `RigidBody3D`
- **Key Calls:** Color, new, add_child, add_to_group

#### `_create_water_sources()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, Vector3, add_child, get_node, range

#### `_create_water_pool(pos: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Area3D`
- **Key Calls:** rotate_x, Vector2, Color, Vector3, add_to_group

*... and 2 more functions*

---

### 📄 scripts/core/upright_ragdoll_controller.gd
**Functions:** 17

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _store_rest_positions, _configure_physics, _find_body_parts

#### `_find_body_parts()`
- **Purpose:** Function in upright_ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_children

#### `_store_rest_positions()`
- **Purpose:** Function in upright_ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3

#### `_configure_physics()`
- **Purpose:** Function in upright_ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_balance_forces, _process_physics_mode, _process_controlled_mode, _process_blend_mode

#### `_process_controlled_mode(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _maintain_rest_pose, _process_walking, apply_torque, get_euler, apply_central_force

#### `_process_walking(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** sin, Vector3, _apply_rotation_force, length, max

#### `_maintain_rest_pose()`
- **Purpose:** Function in upright_ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get, apply_central_force

#### `_apply_rotation_force(body: RigidBody3D, target_euler: Vector3)`
- **Purpose:** Function in upright_ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_torque

#### `_apply_balance_forces()`
- **Purpose:** Maintain ragdoll balance and stability
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, abs, apply_central_force

#### `_process_physics_mode(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_process_blend_mode(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_controlled_mode

#### `start_walking(direction: Vector3)`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** normalized

#### `stop_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`

#### `set_ragdoll_mode(new_mode: RagdollMode)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`

*... and 2 more functions*

---

### 📄 scripts/core/console_channel_system.gd
**Functions:** 16

#### `setup_channels(console_ui: Control)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, values, Vector2, Color, bind

#### `print_to_channel(message: String, channel: Channel = Channel.GAME)`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, _display_message, size, pop_front

#### `_on_channel_toggled(pressed: bool, channel: Channel)`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _refresh_display, emit

#### `_enable_all_channels()`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _refresh_display

#### `_disable_all_channels()`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _refresh_display

#### `_refresh_display()`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _clear_display, _display_message, get

#### `_clear_console()`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, _clear_display

#### `_display_message(formatted_text: String)`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** message

#### `_clear_display()`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** display

#### `print_system(message: String)`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print_to_channel

#### `print_game(message: String)`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print_to_channel

#### `print_universal(message: String)`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print_to_channel

#### `print_error(message: String)`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print_to_channel

#### `print_debug(message: String)`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print_to_channel

#### `print_player(message: String)`
- **Purpose:** Function in console_channel_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print_to_channel

*... and 1 more functions*

---

### 📄 scripts/core/shape_gesture_system.gd
**Functions:** 16

#### `start_gesture(start_pos: Vector2)`
- **Purpose:** Function in shape_gesture_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, get_ticks_msec, append

#### `add_gesture_point(pos: Vector2)`
- **Purpose:** Function in shape_gesture_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, distance_to, size, pop_front

#### `end_gesture()`
- **Purpose:** Function in shape_gesture_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, size, _detect_shape
- **Signals:** shape_detected, gesture_completed, spell_gesture_recognized

#### `_detect_shape(points: Array)`
- **Purpose:** Function in shape_gesture_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** _is_star, _is_zigzag, size, _is_triangle, _is_line

#### `_is_circle(points: Array)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** size, abs, distance_to

#### `_is_triangle(points: Array)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** _find_corners, size, distance_to, _get_shape_size

#### `_is_square(points: Array)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** size, _calculate_angle, abs, range, _find_corners

#### `_is_star(points: Array)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** _find_corners, size

#### `_is_spiral(points: Array)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** size, range, distance_to

#### `_is_line(points: Array)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** distance_to, normalized, dot, size, max

#### `_is_zigzag(points: Array)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** normalized, size, abs, range, angle_to

#### `_find_corners(points: Array)`
- **Purpose:** Function in shape_gesture_system system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, _calculate_angle, size, range

#### `_calculate_angle(p1: Vector2, p2: Vector2, p3: Vector2)`
- **Purpose:** Function in shape_gesture_system system
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** dot, normalized, acos, clamp

#### `_get_shape_size(points: Array)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** max, distance_to, min

#### `get_gesture_direction(points: Array)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** size, range

*... and 1 more functions*

---

### 📄 scripts/core/standardized_objects.gd
**Functions:** 16

#### `create_object(object_type: String, position: Vector3, properties: Dictionary = {})`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** _setup_skeleton_ragdoll, _setup_no_gravity, _setup_sun, _add_collision, _add_visuals

#### `_add_visuals(obj: Node3D, def: Dictionary)`
- **Purpose:** Function in standardized_objects system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get, new, add_child

#### `_add_collision(obj: Node3D, def: Dictionary)`
- **Purpose:** Function in standardized_objects system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get, new, add_child

#### `_apply_property(obj: Node3D, property: String, value)`
- **Purpose:** Function in standardized_objects system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, float, deg_to_rad, _start_action

#### `_setup_ragdoll(obj: Node3D)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** preload, set_script

#### `_setup_skeleton_ragdoll(obj: Node3D)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** preload, set_script, add_to_group

#### `_setup_sun(obj: Node3D)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, Vector3, new, add_child

#### `_setup_astral_being(obj: Node3D)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_script, load

#### `_setup_fruit(obj: Node3D)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_meta

#### `_setup_no_gravity(obj: Node3D)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `_start_action(obj: Node3D, action: String)`
- **Purpose:** Function in standardized_objects system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, get_meta

#### `_generate_unique_name(object_type: String)`
- **Purpose:** Function in standardized_objects system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** str, get_main_loop, find_child, capitalize

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** size, str, print, _load_custom_assets

#### `save_custom_assets()`
- **Purpose:** Function in standardized_objects system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** store_string, close, size, str, print

#### `_load_custom_assets()`
- **Purpose:** Function in standardized_objects system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** close, file_exists, size, parse, print

*... and 1 more functions*

---

### 📄 scripts/core/unified_being_system.gd
**Functions:** 16

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_commands, print, _migrate_existing_beings

#### `_register_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, get_node_or_null

#### `create_being(type: String = "basic", position: Vector3 = Vector3.ZERO, properties: Dictionary = {})`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** append, duplicate, get_tree, size, add_to_group

#### `_create_visual_for_type(type: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** Color, add_child, has_method, create_object, new

#### `_add_capabilities(being: Node3D, type: String)`
- **Purpose:** Function in unified_being_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_meta

#### `transform_being(being: Node3D, new_type: String)`
- **Purpose:** Function in unified_being_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** append, push_error, erase, get_instance_id, _add_capabilities

#### `_migrate_existing_beings()`
- **Purpose:** Function in unified_being_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_nodes_in_group, get_instance_id, get_tree, print

#### `_cmd_being(args: Array)`
- **Purpose:** Function in unified_being_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** _create_container_being, Vector3, size, to_float, _create_interface_being

#### `_create_interface_being(interface_type: String, pos_args: Array)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, duplicate, Vector3, size, to_float

#### `_cmd_list_beings(args: Array)`
- **Purpose:** Function in unified_being_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** size, is_empty

#### `_cmd_transform_being(args: Array)`
- **Purpose:** Function in unified_being_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** transform_being, get_tree, size, get_nodes_in_group

#### `_cmd_container(args: Array)`
- **Purpose:** Function in unified_being_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** _create_container_being, Vector3, size, to_float, is_empty

#### `_create_container_being(container_type: String, size: Vector3, pos: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, duplicate, become_container, get_tree, size

#### `_cmd_list_containers(args: Array)`
- **Purpose:** Function in unified_being_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** size, get_container, get_container_info, s, is_empty

#### `_cmd_connect_containers(args: Array)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** size, get_available_connection_points, _find_container_by_name, is_empty, connect_to_container

*... and 1 more functions*

---

### 📄 scripts/core/unified_scene_manager.gd
**Functions:** 16

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, add_child, _find_original_ground, _create_containers, new

#### `_create_containers()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child

#### `_find_original_ground()`
- **Purpose:** Function in unified_scene_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, contains, get_children, to_lower, get_node_or_null

#### `clear_current_scene()`
- **Purpose:** Function in unified_scene_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, queue_free, get_children, is_instance_valid, emit

#### `load_static_scene(scene_name: String)`
- **Purpose:** Function in unified_scene_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear_current_scene, print, has_method, get_node, load_scene

#### `generate_procedural_world(size: int = 128)`
- **Purpose:** Function in unified_scene_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit, clear_current_scene, get_parent, get_tree, print

#### `load_hybrid_scene(scene_name: String, with_procedural: bool = true)`
- **Purpose:** Function in unified_scene_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** load_static_scene, print, clear_current_scene

#### `restore_default_scene()`
- **Purpose:** Function in unified_scene_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, emit, clear_current_scene

#### `add_object_to_scene(object: Node3D, category: String = "object")`
- **Purpose:** Function in unified_scene_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_child

#### `get_spawn_position()`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `Vector3`
- **Key Calls:** get_height_at_position, has_method

#### `get_ground_height_at(position: Vector3)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** get_height_at_position, has_method

#### `get_current_scene_info()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_child_count, keys

#### `is_procedural_scene()`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`

#### `has_terrain()`
- **Purpose:** Check if something exists or is available
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** or

#### `_ensure_ground_visible()`
- **Purpose:** Function in unified_scene_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_original_ground, print, _create_emergency_ground

*... and 1 more functions*

---

### 📄 scripts/jsh_framework/core/godot_timers_system.gd
**Functions:** 16

#### `_init(p_timer: Timer, p_duration: float, p_callback: Callable = Callable(), p_user_data: Variant = null)`
- **Purpose:** Function in godot_timers_system system
- **Lines:** 8
- **Returns:** `void`

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, create_timer, start_timer
- **Signals:** interval_tick

#### `create_timer(timer_id: String, duration: float, callback: Callable = Callable(), repeating: bool = false, user_data: Variant = null)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Error`
- **Key Calls:** bind, add_child, has, push_warning, new

#### `start_timer(timer_id: String)`
- **Purpose:** Function in godot_timers_system system
- **Lines:** 0
- **Returns:** `Error`
- **Key Calls:** has, start, push_warning, emit_signal
- **Signals:** timer_started

#### `stop_timer(timer_id: String)`
- **Purpose:** Function in godot_timers_system system
- **Lines:** 0
- **Returns:** `Error`
- **Key Calls:** has, emit_signal, stop
- **Signals:** timer_stopped

#### `pause_timer(timer_id: String)`
- **Purpose:** Function in godot_timers_system system
- **Lines:** 0
- **Returns:** `Error`
- **Key Calls:** has, emit_signal
- **Signals:** timer_paused

#### `resume_timer(timer_id: String)`
- **Purpose:** Function in godot_timers_system system
- **Lines:** 0
- **Returns:** `Error`
- **Key Calls:** has, emit_signal
- **Signals:** timer_resumed

#### `remove_timer(timer_id: String)`
- **Purpose:** Function in godot_timers_system system
- **Lines:** 0
- **Returns:** `Error`
- **Key Calls:** append, erase, queue_free, has, stop

#### `clear_all_timers()`
- **Purpose:** Function in godot_timers_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** keys, remove_timer

#### `get_time_left(timer_id: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** has

#### `get_progress(timer_id: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** has, get_time_left

#### `is_timer_active(timer_id: String)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** has

#### `is_timer_paused(timer_id: String)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** has

#### `get_active_timers()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array[String]`
- **Key Calls:** append, is_timer_active

#### `_on_timer_timeout(timer_id: String)`
- **Purpose:** Function in godot_timers_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_valid, erase, emit_signal, start, has
- **Signals:** timer_completed

*... and 1 more functions*

---

### 📄 scripts/core/bird_ai_behavior.gd
**Functions:** 15

#### `setup(bird: RigidBody3D)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_physics_process

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_drinking, _process_seeking_water, _check_state_transitions, _process_seeking_food, _process_resting

#### `_process_wandering(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** sin, _find_nearby_food, Vector3, randf_range, has_method

#### `_process_seeking_food(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_instance_valid, _change_state, distance_to, has_method

#### `_process_eating(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** min, has_method, queue_free, _change_state, randf

#### `_process_seeking_water(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** distance_to, _find_nearby_water, has_method, _change_state, is_instance_valid

#### `_process_drinking(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _change_state, min

#### `_process_resting(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _change_state

#### `_check_state_transitions()`
- **Purpose:** Function in bird_ai_behavior system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_nearby_food, _change_state, _find_nearby_water

#### `_change_state(new_state: AIState)`
- **Purpose:** Function in bird_ai_behavior system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_ai_state, has_method

#### `_find_nearby_food()`
- **Purpose:** Function in bird_ai_behavior system
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** is_instance_valid, get_tree, distance_to, get_nodes_in_group

#### `_find_nearby_water()`
- **Purpose:** Function in bird_ai_behavior system
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** is_instance_valid, get_tree, distance_to, get_nodes_in_group

#### `get_status()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** keys

#### `feed()`
- **Purpose:** Function in bird_ai_behavior system
- **Lines:** 0
- **Returns:** `void`

#### `give_water()`
- **Purpose:** Function in bird_ai_behavior system
- **Lines:** 2
- **Returns:** `void`

---

### 📄 scripts/core/pigeon_physics_controller.gd
**Functions:** 15

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_visual_mesh, set_physics_process, _set_idle_position, _setup_collision, _create_physics_points

#### `_create_physics_points()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, new, add_child

#### `_create_visual_mesh()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_triangles, Color, new, add_child

#### `_setup_collision()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_triangles, _process_landing, _process_idle, _update_balance, _process_walking

#### `_process_walking(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** normalized, sin, Vector3, get_vector, abs

#### `_process_flying(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** normalized, sin, Vector3, get_vector, lerp

#### `_process_landing(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_movement_mode, lerp

#### `_process_idle(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, randf_range, randf, sin

#### `_update_balance(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** lerp

#### `_update_triangles()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, clear_surfaces, Color, add_surface_from_arrays, PackedVector3Array

#### `set_movement_mode(mode: MovementMode)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit

#### `jump()`
- **Purpose:** Function in pigeon_physics_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_movement_mode

#### `_set_idle_position()`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3

#### `_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 12
- **Returns:** `void`
- **Key Calls:** is_action_pressed, jump, set_movement_mode

---

### 📄 scripts/core/game_launcher.gd
**Functions:** 14

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, _run_startup_diagnostics

#### `_run_startup_diagnostics()`
- **Purpose:** Function in game_launcher system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _check_floodgate_systems, print, _check_autoload_systems, _generate_status_report, _check_scene_structure

#### `_check_autoload_systems()`
- **Purpose:** Function in game_launcher system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, print, get_node_or_null

#### `_check_floodgate_systems()`
- **Purpose:** Function in game_launcher system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, create_timer, size, get_tree, print

#### `_check_scene_structure()`
- **Purpose:** Function in game_launcher system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, append, get_first_node_in_group, get_tree, str

#### `_check_critical_assets()`
- **Purpose:** Function in game_launcher system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_file, exists, print, queue_free

#### `_generate_status_report()`
- **Purpose:** Function in game_launcher system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, size, str, print, _save_diagnostic_report
- **Signals:** systems_ready, startup_error

#### `_save_diagnostic_report()`
- **Purpose:** Function in game_launcher system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** store_string, close, print, open, stringify

#### `get_system_status()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** duplicate

#### `get_error_log()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** duplicate

#### `is_startup_complete()`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`

#### `run_health_check()`
- **Purpose:** Function in game_launcher system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, _run_startup_diagnostics

#### `test_floodgate_system()`
- **Purpose:** Function in game_launcher system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** first_dimensional_magic, Vector3, get_tree, create_timer, print

#### `quick_test()`
- **Purpose:** Function in game_launcher system
- **Lines:** 6
- **Returns:** `void`
- **Key Calls:** print, get_node_or_null

---

### 📄 scripts/core/skeleton_ragdoll_hybrid.gd
**Functions:** 14

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_ragdoll_mode, _create_joints, print, _create_physics_bodies, _create_skeleton

#### `_create_skeleton()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_bone_pose_position, add_child, has, Transform3D, set_bone_rest

#### `_create_physics_bodies()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, print, add_child, set_meta, has

#### `_get_bone_length(bone_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`

#### `_create_joints()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_joint

#### `_create_joint(parent_bone: String, child_bone: String, joint_name: String, joint_type)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_child, has, set_flag, get_path, new

#### `_create_visuals()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, add_child, has, _get_bone_length, new

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _sync_physics_to_skeleton, _sync_skeleton_to_physics

#### `_sync_skeleton_to_physics()`
- **Purpose:** Function in skeleton_ragdoll_hybrid system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_bone_pose_position, set_bone_pose_rotation, has, get_rotation_quaternion, inverse

#### `_sync_physics_to_skeleton()`
- **Purpose:** Function in skeleton_ragdoll_hybrid system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, get_bone_global_pose

#### `set_ragdoll_mode(mode: RagdollMode)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit, values

#### `apply_impulse_to_bone(bone_name: String, impulse: Vector3)`
- **Purpose:** Function in skeleton_ragdoll_hybrid system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, emit, apply_central_impulse

#### `get_bone_position(bone_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Vector3`
- **Key Calls:** has, return, get_bone_global_pose

#### `stand_up()`
- **Purpose:** Function in skeleton_ragdoll_hybrid system
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** print

---

### 📄 scripts/core/synchronicity_pathfinder.gd
**Functions:** 14

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _establish_mirrors, _map_all_paths, print

#### `_map_all_paths()`
- **Purpose:** Function in synchronicity_pathfinder system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size

#### `synchronize(var_name: String, new_value: Variant, source: String = "")`
- **Purpose:** Function in synchronicity_pathfinder system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, get_ticks_msec, append, _update_mirror
- **Signals:** synchronicity_update

#### `_update_mirror(location: String, value: Variant)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** ends_with, _set_nested_property, trim_suffix, size, has_method

#### `follow_path(from_function: String, to_function: String, data: Variant = null)`
- **Purpose:** Function in synchronicity_pathfinder system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, push_warning, emit_signal
- **Signals:** path_taken

#### `get_available_paths(current_function: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`

#### `trace_path_history(steps_back: int = 10)`
- **Purpose:** Function in synchronicity_pathfinder system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** size, max, slice

#### `find_variable_locations(var_name: String)`
- **Purpose:** Function in synchronicity_pathfinder system
- **Lines:** 0
- **Returns:** `Array`

#### `register_mirror(var_name: String, location: String)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, print

#### `check_harmony()`
- **Purpose:** Function in synchronicity_pathfinder system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** emit_signal, _get_mirror_value, push_warning
- **Signals:** harmony_achieved

#### `_establish_mirrors()`
- **Purpose:** Function in synchronicity_pathfinder system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** synchronize

#### `_get_mirror_value(location: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Variant`
- **Key Calls:** size, get, split, get_node_or_null

#### `_set_nested_property(obj: Object, path: String, value: Variant)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, has, range, set, get

#### `generate_path_report()`
- **Purpose:** Function in synchronicity_pathfinder system
- **Lines:** 24
- **Returns:** `String`
- **Key Calls:** has, trace_path_history, str

---

### 📄 scripts/core/universal_workflow_analyzer.gd
**Functions:** 14

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, analyze_entire_project

#### `analyze_entire_project()`
- **Purpose:** Function in universal_workflow_analyzer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_duplicates, _scan_all_scripts, _suggest_combinations, emit_signal, _map_execution_flows
- **Signals:** analysis_complete

#### `_scan_all_scripts()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** open, _scan_directory_recursive

#### `_scan_directory_recursive(dir: DirAccess, path: String)`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** ends_with, list_dir_begin, _analyze_script, get_next, begins_with

#### `_analyze_script(script_path: String)`
- **Purpose:** Function in universal_workflow_analyzer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** compile, append, close, search_all, get_string

#### `_determine_purpose(script_path: String)`
- **Purpose:** Function in universal_workflow_analyzer system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_basename, get_file, get_base_dir

#### `_map_execution_flows()`
- **Purpose:** Function in universal_workflow_analyzer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _trace_execution_path

#### `_trace_execution_path(func_name: String, visited: Array = [])`
- **Purpose:** Function in universal_workflow_analyzer system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, duplicate, append_array, get, _trace_execution_path

#### `_find_duplicates()`
- **Purpose:** Function in universal_workflow_analyzer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, size, emit_signal
- **Signals:** duplicate_found

#### `_suggest_combinations()`
- **Purpose:** Function in universal_workflow_analyzer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, size, append

#### `_generate_workflow_graph()`
- **Purpose:** Function in universal_workflow_analyzer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _get_files_with_substring

#### `_get_files_with_substring(substring: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append

#### `generate_complete_report()`
- **Purpose:** Function in universal_workflow_analyzer system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_file, min, size, str, to_upper

#### `generate_combination_script(suggestion: Dictionary)`
- **Purpose:** Function in universal_workflow_analyzer system
- **Lines:** 44
- **Returns:** `String`
- **Key Calls:** append_array, str, get, to_upper

---

### 📄 scripts/jsh_framework/core/pallets_racing_game.gd
**Functions:** 14

#### `setup_main_reference(main_ref)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, initialize_racing_game

#### `initialize_racing_game()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** setup_race_ui, setup_player_vehicle, print, setup_race_track

#### `setup_race_track()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Color, print, add_child, create_pallet_obstacle

#### `create_pallet_obstacle(position: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Color, new, add_child

#### `setup_checkpoints()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, size, str, Color, add_child

#### `setup_player_vehicle()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Color, print, add_child, new

#### `setup_race_ui()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, print, add_child, new

#### `start_race()`
- **Purpose:** Function in pallets_racing_game system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_node, print

#### `process_input(delta)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** rotate_y, is_action_just_pressed, clamp, is_action_pressed, start_race

#### `_process(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, get_node, snapped, finish_race, process_input

#### `finish_race()`
- **Purpose:** Function in pallets_racing_game system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, get_node, print, snapped

#### `reset_race()`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, get_node

#### `exit_to_menu()`
- **Purpose:** Function in pallets_racing_game system
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** hide_racing_game, print, has_method

---

### 📄 scripts/core/performance_guardian.gd
**Functions:** 13

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, set_process, get_node_or_null

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_frames_per_second, size, pop_front, _check_performance

#### `_check_performance()`
- **Purpose:** Function in performance_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _get_average_fps, _standard_optimization, _emergency_optimization, get_nodes_in_group, _critical_optimization

#### `_get_average_fps()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** size, is_empty

#### `_standard_optimization()`
- **Purpose:** Function in performance_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _get_player_position, get_nodes_in_group, freeze, get_tree

#### `_critical_optimization()`
- **Purpose:** Function in performance_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _standard_optimization, get_nodes_in_group, get_tree, print

#### `_emergency_optimization()`
- **Purpose:** Function in performance_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** distance_to, _get_player_position, get_nodes_in_group, freeze, get_tree

#### `_reduce_optimization()`
- **Purpose:** Function in performance_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** unfreeze, str, print, slice, is_instance_valid

#### `_reduce_nodes()`
- **Purpose:** Function in performance_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_nodes_in_group, get_tree, str, print, queue_free

#### `_reduce_beings()`
- **Purpose:** Function in performance_guardian system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** distance_to, get_nodes_in_group, size, get_tree, print

#### `_get_player_position()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Vector3`
- **Key Calls:** get_viewport, get_first_node_in_group, get_tree, get_camera_3d

#### `get_performance_stats()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** _get_average_fps, get_frames_per_second, get_nodes_in_group, get_static_memory_usage, get_tree

#### `force_optimization(level: int)`
- **Purpose:** Function in performance_guardian system
- **Lines:** 7
- **Returns:** `void`
- **Key Calls:** _standard_optimization, _reduce_optimization, _emergency_optimization, _critical_optimization

---

### 📄 scripts/core/unified_creation_system.gd
**Functions:** 13

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_node, print

#### `create(what: String, where: Vector3 = Vector3.ZERO, properties: Dictionary = {})`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** append, _create_standard_object, _is_universal_being_type, get_ticks_msec, _create_universal_being

#### `_is_universal_being_type(type: String)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** file_exists

#### `_create_universal_being(type: String, position: Vector3, properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** _generate_unique_name, load_universal_being

#### `_create_standard_object(type: String, position: Vector3, properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** create_object, _generate_unique_name

#### `_create_from_scene(scene_path: String, position: Vector3, properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** get_file, _generate_unique_name, get_basename, load, instantiate

#### `_register_object(obj: Node3D, type: String)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, randi, str, add_to_group, set_meta

#### `_apply_properties(obj: Node3D, properties: Dictionary)`
- **Purpose:** Function in unified_creation_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set, call, set_meta, has_method

#### `_route_through_floodgate(obj: Node3D)`
- **Purpose:** Function in unified_creation_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** second_dimensional_magic, get_tree, add_child

#### `_generate_unique_name(base_type: String)`
- **Purpose:** Function in unified_creation_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** str, get, capitalize

#### `destroy(obj: Node3D)`
- **Purpose:** Clean up and remove object/component
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_meta, erase, queue_free, is_instance_valid, max

#### `get_all_of_type(type: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** is_instance_valid, get_meta, append

#### `get_statistics()`
- **Purpose:** Retrieve data or property value
- **Lines:** 8
- **Returns:** `Dictionary`
- **Key Calls:** size, filter, values

---

### 📄 scripts/core/universal_entity/system_health_monitor.gd
**Functions:** 13

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start, add_child, new, _print, connect

#### `_perform_health_check()`
- **Purpose:** Function in system_health_monitor system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _status_to_string, get_ticks_msec, get_frames_per_second, _check_floodgate_queues

#### `_estimate_memory_usage()`
- **Purpose:** Function in system_health_monitor system
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** get_tree, get_node_count, node

#### `_check_floodgate_queues()`
- **Purpose:** Function in system_health_monitor system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** append, size, str

#### `_apply_fps_fix()`
- **Purpose:** Function in system_health_monitor system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, _emergency_optimization, get_nodes_in_group, get_tree, queue_free

#### `_apply_node_limit_fix()`
- **Purpose:** Function in system_health_monitor system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_nodes_in_group, get_tree, queue_free, force_cleanup, _print

#### `_apply_memory_fix()`
- **Purpose:** Function in system_health_monitor system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_timer, get_tree, force_cleanup, _print, emit

#### `get_health_status()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `HealthStatus`

#### `get_health_report()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** duplicate, size, range, min, is_empty

#### `set_auto_fix(enabled: bool)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print

#### `force_health_check()`
- **Purpose:** Function in system_health_monitor system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _perform_health_check

#### `_status_to_string(status: HealthStatus)`
- **Purpose:** Function in system_health_monitor system
- **Lines:** 0
- **Returns:** `String`

#### `_print(message: String)`
- **Purpose:** Function in system_health_monitor system
- **Lines:** 6
- **Returns:** `void`
- **Key Calls:** _print_to_console, print, has_method

---

### 📄 scripts/core/perfect_delta_process.gd
**Functions:** 12

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_commands, print, set_process

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_adaptive_skipping, erase, _optimize_process_order, get_ticks_usec, is_instance_valid

#### `register_process(node: Node, callback: Callable, priority: int = 50, group: String = "default")`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, set_process, _optimize_process_order, get_script, print

#### `unregister_process(node: Node)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, erase

#### `_optimize_process_order()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, sort_custom, append_array, append

#### `_apply_adaptive_skipping(info: ProcessorInfo)`
- **Purpose:** Function in perfect_delta_process system
- **Lines:** 0
- **Returns:** `void`

#### `get_processor_stats()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** size, max

#### `force_process_all()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** immediately, get_process_delta_time, print, is_instance_valid, call

#### `_register_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, get_node_or_null

#### `_cmd_show_stats(_args: Array)`
- **Purpose:** Function in perfect_delta_process system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_processor_stats, _print_to_console, get_node

#### `_cmd_list_processors(_args: Array)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, get_node

#### `_cmd_force_process(_args: Array)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** _print_to_console, size, get_node, force_process_all

---

### 📄 scripts/jsh_framework/core/record_set_manager.gd
**Functions:** 12

#### `check_all_things()`
- **Purpose:** Function in record_set_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `add_stuff_to_basic(list_of_things)`
- **Purpose:** Function in record_set_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_empty

#### `check_basic_set_if_loaded()`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_empty, print

#### `add_record_set_to_list(key_input_a, key_input_b, record_pack)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, print

#### `get_all_records_packs()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `void`

#### `get_one_records_pack(key_input_a, key_input_b)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, print

#### `compare_list_of_records(key_input_a, key_input_b, record_pack)`
- **Purpose:** Function in record_set_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, print

#### `add_record_set(set_name: String, data: Dictionary)`
- **Purpose:** Function in record_set_manager system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** get_ticks_msec, unlock, lock

#### `get_record_set(set_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_ticks_msec, unlock, lock, erase

#### `cache_record_set(set_name: String)`
- **Purpose:** Function in record_set_manager system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** unlock, lock, erase

#### `cleanup_cache()`
- **Purpose:** Function in record_set_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, get_record_size, unlock, keys, values

#### `get_record_size(record: Dictionary)`
- **Purpose:** Retrieve data or property value
- **Lines:** 9
- **Returns:** `int`
- **Key Calls:** length

---

### 📄 scripts/core/background_process_manager.gd
**Functions:** 11

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_physics_process, print, set_process

#### `register_physics_process(node: Node, callback: Callable, priority: int = 5)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, sort_custom, print

#### `register_visual_process(node: Node, callback: Callable, priority: int = 5)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, sort_custom, print

#### `register_debug_process(node: Node, callback: Callable)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, print

#### `unregister_process(node: Node)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** filter

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, range, get_ticks_usec, is_instance_valid, emit

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, size, pop_front, range, get_ticks_usec

#### `set_debug_enabled(enabled: bool)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `get_performance_stats()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** size

#### `set_process_active(node: Node, active: bool)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_sort_by_priority(a: Dictionary, b: Dictionary)`
- **Purpose:** Function in background_process_manager system
- **Lines:** 2
- **Returns:** `bool`

---

### 📄 scripts/core/universal_being_3d_blueprint_parser.gd
**Functions:** 11

#### `parse_blueprint_file(file_path: String)`
- **Purpose:** Function in universal_being_3d_blueprint_parser system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** append, close, _parse_element_line, file_exists, size

#### `_parse_element_line(line: String, line_number: int)`
- **Purpose:** Function in universal_being_3d_blueprint_parser system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** Vector2, Vector3, size, to_float, print

#### `_parse_properties(properties_string: String)`
- **Purpose:** Function in universal_being_3d_blueprint_parser system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** _convert_property_value, size, strip_edges, is_empty, split

#### `_convert_property_value(value_str: String)`
- **Purpose:** Function in universal_being_3d_blueprint_parser system
- **Lines:** 0
- **Returns:** `Variant`
- **Key Calls:** to_int, is_valid_float, to_float, is_valid_int, to_lower

#### `get_elements_by_type(element_type: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append

#### `get_element_by_text(text: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`

#### `create_default_blueprint(interface_type: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** _create_default_asset_creator, _create_default_inspector, _create_generic_blueprint, _create_default_console

#### `_create_default_asset_creator()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** Vector2, Vector3

#### `_create_default_console()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** Vector2, Vector3

#### `_create_default_inspector()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** Vector2, Vector3

#### `_create_generic_blueprint(interface_type: String)`
- **Purpose:** Create new instance or object
- **Lines:** 36
- **Returns:** `Dictionary`
- **Key Calls:** Vector2, Vector3, capitalize

---

### 📄 scripts/jsh_framework/core/JSH_reality_shaders.gd
**Functions:** 10

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** load_reality_shader, print, add_child, get_node, new

#### `_process(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** process_transition

#### `load_reality_shader(reality_name)`
- **Purpose:** Function in JSH_reality_shaders system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** unlock, push_error, emit_signal, print, lock
- **Signals:** shader_loaded

#### `start_transition(from_reality, to_reality)`
- **Purpose:** Function in JSH_reality_shaders system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** unlock, push_error, print, lock, has

#### `process_transition(delta)`
- **Purpose:** Handle ongoing operations or data
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** unlock, lock, finish_transition, min, get_next_reality

#### `finish_transition()`
- **Purpose:** Function in JSH_reality_shaders system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_next_reality, print, load_reality_shader, emit_signal
- **Signals:** transition_complete

#### `get_next_reality()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, split, keys

#### `create_glitch_effect(parameter, intensity, duration_str)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** unlock, ends_with, push_error, float, get_tree

#### `remove_glitch_effect(parameter)`
- **Purpose:** Function in JSH_reality_shaders system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** lock, unlock, print

#### `apply_color_palette(palette_name)`
- **Purpose:** Function in JSH_reality_shaders system
- **Lines:** 73
- **Returns:** `void`
- **Key Calls:** lock, Color, unlock, print

---

### 📄 scripts/core/multi_layer_record_system.gd
**Functions:** 9

#### `move_between_layers(data_key: String, from_layer: String, to_layer: String)`
- **Purpose:** Function in multi_layer_record_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** unlock, erase, emit_signal, lock, has
- **Signals:** layer_transition

#### `check_state_in_layers(data_key: String)`
- **Purpose:** Function in multi_layer_record_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** has, is_empty, unlock, lock

#### `promote_to_active(data_key: String)`
- **Purpose:** Function in multi_layer_record_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** check_state_in_layers, move_between_layers

#### `demote_from_active(data_key: String)`
- **Purpose:** Function in multi_layer_record_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** check_state_in_layers, move_between_layers

#### `batch_operation(keys: Array, operation: String)`
- **Purpose:** Function in multi_layer_record_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** demote_from_active, check_state_in_layers, promote_to_active, move_between_layers

#### `get_layer_stats()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** size, unlock, lock, keys

#### `cleanup_empty_entries()`
- **Purpose:** Function in multi_layer_record_system system
- **Lines:** 0
- **Returns:** `int`
- **Key Calls:** append, unlock, erase, lock, is_empty

#### `store_with_metadata(key: String, data: Variant, layer: String = "pending")`
- **Purpose:** Function in multi_layer_record_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** get_ticks_msec, unlock, emit_signal, lock, has
- **Signals:** state_changed

#### `access_data(key: String)`
- **Purpose:** Function in multi_layer_record_system system
- **Lines:** 20
- **Returns:** `Variant`
- **Key Calls:** get_ticks_msec, check_state_in_layers, unlock, lock, has

---

### 📄 scripts/jsh_framework/core/thread_pool_manager.gd
**Functions:** 9

#### `_init()`
- **Purpose:** Function in thread_pool_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** setup_thread_pool

#### `setup_thread_pool()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** range

#### `add_task(task_data)`
- **Purpose:** Function in thread_pool_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** process_queue, unlock, lock, push_back

#### `process_queue()`
- **Purpose:** Handle ongoing operations or data
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start_task, unlock, pop_front, lock, find_available_thread

#### `find_available_thread()`
- **Purpose:** Function in thread_pool_manager system
- **Lines:** 0
- **Returns:** `void`

#### `start_task(thread_id, task)`
- **Purpose:** Function in thread_pool_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, bind, start, Callable, new

#### `cleanup_thread(thread_id)`
- **Purpose:** Function in thread_pool_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** process_queue

#### `check_timeouts()`
- **Purpose:** Function in thread_pool_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, handle_timeout

#### `handle_timeout(thread_id)`
- **Purpose:** Function in thread_pool_manager system
- **Lines:** 8
- **Returns:** `void`
- **Key Calls:** is_alive, cleanup_thread, wait_to_finish, emit

---

### 📄 scripts/core/debug_manager.gd
**Functions:** 8

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, set_process

#### `is_debug_enabled(category: String)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** get

#### `set_debug_category(category: String, enabled: bool)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, emit

#### `toggle_debug_category(category: String)`
- **Purpose:** Function in debug_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_debug_category

#### `should_print(message: String)`
- **Purpose:** Determine if action should be taken
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** to_lower, get

#### `filtered_print(message: String)`
- **Purpose:** Function in debug_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** should_print, print

#### `get_debug_status()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

#### `_on_console_command(command: String, args: Array)`
- **Purpose:** Function in debug_manager system
- **Lines:** 26
- **Returns:** `void`
- **Key Calls:** get_debug_status, set_debug_category, size, disabled, get

---

### 📄 scripts/core/txt_rule_editor.gd
**Functions:** 8

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_ui, _load_file_list

#### `_create_ui()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, add_color_region, set_custom_minimum_size, Vector2, add_keyword_color

#### `_load_file_list()`
- **Purpose:** Function in txt_rule_editor system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, _scan_directory

#### `_scan_directory(path: String, category: String)`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** ends_with, list_dir_begin, get_next, open, add_item

#### `_on_file_selected(index: int)`
- **Purpose:** Function in txt_rule_editor system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** close, get_as_text, open, get_item_text, get_node

#### `_on_text_changed()`
- **Purpose:** Function in txt_rule_editor system
- **Lines:** 0
- **Returns:** `void`

#### `_save_current_file()`
- **Purpose:** Function in txt_rule_editor system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** store_string, close, _notify_rule_change, print, open

#### `_notify_rule_change(file_path: String)`
- **Purpose:** Function in txt_rule_editor system
- **Lines:** 16
- **Returns:** `void`
- **Key Calls:** get_file, reload_file, has_method, contains, reload_definitions

---

### 📄 scripts/core/astral_ragdoll_helper.gd
**Functions:** 7

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process

#### `start_helping_ragdoll()`
- **Purpose:** Function in astral_ragdoll_helper system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, set_process, get_nodes_in_group, start_assisting, get_tree

#### `stop_helping()`
- **Purpose:** Function in astral_ragdoll_helper system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process, set_movement_mode, print, has_method, clear

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_body, get_linear_velocity, Vector3, size, has_method

#### `_find_ragdoll()`
- **Purpose:** Function in astral_ragdoll_helper system
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** get_tree, get_nodes_in_group, is_empty, get_node_or_null

#### `toggle_help()`
- **Purpose:** Function in astral_ragdoll_helper system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** stop_helping, start_helping_ragdoll

#### `assign_specific_being(being: Node3D)`
- **Purpose:** Function in astral_ragdoll_helper system
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** append, start_assisting, has_method

---

### 📄 scripts/core/scene_setup.gd
**Functions:** 7

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_timer, get_tree, _setup_ragdoll_system, print

#### `_setup_ragdoll_system()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, print, add_child, set_script, load

#### `_setup_astral_beings()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, get_node_or_null

#### `_setup_existing_ragdoll()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_nodes_in_group, get_tree, add_to_group, print, is_in_group

#### `create_test_objects()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_box_at_position, create_tree_at_position, Vector3, str, print

#### `cmd_setup_scene()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_existing_ragdoll, _setup_ragdoll_system, print

#### `cmd_create_test_objects()`
- **Purpose:** Create new instance or object
- **Lines:** 2
- **Returns:** `void`
- **Key Calls:** create_test_objects

---

### 📄 scripts/jsh_framework/core/container.gd
**Functions:** 7

#### `_init()`
- **Purpose:** Function in container system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `containter_start_up(con_num, data)`
- **Purpose:** Function in container system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append

#### `get_datapoint()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `void`

#### `containter_get_data()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `void`

#### `container_get_additional_datapoints()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `void`

#### `containers_connections(data)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append

#### `get_containers_connected()`
- **Purpose:** Establish connection between systems
- **Lines:** 3
- **Returns:** `void`

---

### 📄 scripts/jsh_framework/core/function_metadata.gd
**Functions:** 7

#### `get_function_metadata(script_path: String, function_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** has, duplicate

#### `get_category_functions(category: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append

#### `get_mutex_dependencies(script_path: String, function_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** get_function_metadata

#### `get_global_variables(script_path: String, function_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** get_function_metadata

#### `get_function_dependencies(script_path: String, function_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** get_function_metadata

#### `generate_report(script_path: String = "", category: String = "")`
- **Purpose:** Function in function_metadata system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** has, is_empty, _generate_function_report, get_category_functions

#### `_generate_function_report(script_path: String, function_name: String)`
- **Purpose:** Function in function_metadata system
- **Lines:** 29
- **Returns:** `String`
- **Key Calls:** is_empty, str, length, get_function_metadata

---

### 📄 scripts/core/universal_being_floodgate_integration.gd
**Functions:** 5

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_references

#### `_setup_references()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, get_node_or_null

#### `create_universal_being_through_floodgate(type: String, position: Vector3, properties: Dictionary = {})`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** queue_operation, _create_being_directly, print, has_method, has_asset

#### `_on_being_created(result: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, get, print

#### `_create_being_directly(type: String, position: Vector3, properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 35
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, get_parent, get_tree, str, print

---

### 📄 scripts/jsh_framework/core/jsh_thread_pool_manager.gd
**Functions:** 4

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, print, get_processor_count

#### `check_all_things()`
- **Purpose:** Function in jsh_thread_pool_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, print, get_processor_count

#### `store_thread_check(thread_data: Dictionary)`
- **Purpose:** Function in jsh_thread_pool_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, size, pop_front, has

#### `analyze_thread_performance()`
- **Purpose:** Function in jsh_thread_pool_manager system
- **Lines:** 76
- **Returns:** `Dictionary`
- **Key Calls:** get_ticks_msec

---

### 📄 scripts/core/pigeon_input_manager.gd
**Functions:** 3

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_input_actions

#### `_setup_input_actions()`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _add_action_if_missing

#### `_add_action_if_missing(action_name: String, keys: Array)`
- **Purpose:** Function in pigeon_input_manager system
- **Lines:** 8
- **Returns:** `void`
- **Key Calls:** has_action, new, action_add_event, add_action

---

### 📄 scripts/jsh_framework/core/line.gd
**Functions:** 3

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** send_any_message

#### `change_points_of_line(start_end_points)`
- **Purpose:** Function in line system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear_surfaces, Vector3, surface_end, surface_add_vertex, surface_begin

#### `send_any_message()`
- **Purpose:** Function in line system
- **Lines:** 3
- **Returns:** `void`
- **Key Calls:** print

---

### 📄 scripts/jsh_framework/core/racing_menu_integrator.gd
**Functions:** 3

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_racing_to_menu, get_parent, get_tree, register_racing_actions, print

#### `register_racing_actions()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, register_action, has_method

#### `add_racing_to_menu()`
- **Purpose:** Function in racing_menu_integrator system
- **Lines:** 21
- **Returns:** `void`
- **Key Calls:** create_menu_button, print, add_menu_button, has_method

---

### 📄 scripts/jsh_framework/core/init_function.gd
**Functions:** 2

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 26
- **Returns:** `void`

---

### 📄 scripts/jsh_framework/core/system_interfaces.gd
**Functions:** 2

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 3
- **Returns:** `void`

---

### 📄 scripts/jsh_framework/core/text_label.gd
**Functions:** 2

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 3
- **Returns:** `void`

---

### 📄 scripts/core/universal_entity/initialize_universal_entity.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 40
- **Returns:** `void`
- **Key Calls:** print

---

### 📄 scripts/jsh_framework/core/scene_tree_check.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 6
- **Returns:** `void`

---

## Core Systems - Autoload
**Scripts:** 13 | **Functions:** 366

### 📄 scripts/autoload/console_manager.gd
**Functions:** 181

#### `debug_print(message: String, level: int = 2)`
- **Purpose:** Function in console_manager system
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** print

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, call_deferred, print, add_child, _ready

#### `_safe_initialize()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_console_ui, debug_print, _create_windows_console_fix, _create_timer_system, print

#### `_wait_for_floodgate_systems()`
- **Purpose:** Function in console_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** debug_print, create_timer, get_tree, str, push_warning

#### `_check_systems_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** _print_to_console, get_node_or_null

#### `_create_passive_controller()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** exists, debug_print, preload, add_child, new

#### `_create_threaded_system()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** exists, debug_print, preload, add_child, new

#### `_create_physics_manager()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** exists, get_tree, preload, print, add_child

#### `_create_project_manager()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start_waiting_for_user, exists, preload, print, add_child

#### `_create_timer_system()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_autonomous_project, exists, preload, print, add_child

#### `_create_todo_manager()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** exists, preload, print, add_child, new

#### `_create_object_inspector()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** exists, get_tree, preload, add_to_group, add_child

#### `_create_windows_console_fix()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** exists, preload, print, add_child, patch_console_manager

#### `_unhandled_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, toggle_console, str, print, _navigate_history

#### `_create_console_ui()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, add_theme_font_size_override, connect, Vector2, Color

*... and 166 more functions*

---

### 📄 scripts/autoload/layer_reality_system.gd
**Functions:** 32

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process_unhandled_input, _setup_debug_draw, _initialize_layers

#### `_initialize_layers()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** values, str, add_child, set_layer_visibility, new

#### `_setup_debug_draw()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_debug_material, new, add_child

#### `_create_debug_material()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `StandardMaterial3D`
- **Key Calls:** new

#### `_unhandled_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** toggle_layer, cycle_view_mode, align_to_camera, toggle_split_screen, align_to_origin

#### `set_layer_visibility(layer: Layer, visible: bool)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _update_viewport_layout, erase, has, emit

#### `toggle_layer(layer: Layer)`
- **Purpose:** Function in layer_reality_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_layer_visibility, get

#### `cycle_view_mode()`
- **Purpose:** Function in layer_reality_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, _apply_view_mode

#### `_apply_view_mode()`
- **Purpose:** Function in layer_reality_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_layer_visibility, values

#### `_update_viewport_layout()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, _setup_quad_view, size, _setup_dual_view, _setup_single_view

#### `_setup_single_view(_screen_size: Vector2)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`

#### `_setup_dual_view(_screen_size: Vector2)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`

#### `_setup_triple_view(_screen_size: Vector2)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`

#### `_setup_quad_view(_screen_size: Vector2)`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`

#### `add_debug_point(position: Vector3, color: Color = Color.WHITE, size: float = 0.1)`
- **Purpose:** Function in layer_reality_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _update_debug_draw

*... and 17 more functions*

---

### 📄 scripts/autoload/world_builder.gd
**Functions:** 27

#### `debug_print(message: String, level: int = 2)`
- **Purpose:** Function in world_builder system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `_get_std_objects()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** get_node_or_null

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** debug_print, get_node, push_error

#### `get_mouse_spawn_position()`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `Vector3`
- **Key Calls:** get_viewport, project_ray_normal, get_world_3d, Vector3, get_tree

#### `create_tree()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, debug_print, str, create_object, _fallback_create_tree

#### `_fallback_create_tree()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_tree, add_child, create_object, get_mouse_spawn_position

#### `create_rock()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, debug_print, str, create_object, second_dimensional_magic

#### `create_box()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _fallback_create_box, debug_print, str, create_object

#### `create_ball()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _fallback_create_ball, debug_print, str, create_object

#### `create_ramp()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, debug_print, str, _fallback_create_ramp, create_object

#### `create_ragdoll()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_nodes_in_group, debug_print, get_tree, add_child, queue_free

#### `create_sun()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_tree, add_child, has_method, create_object

#### `create_astral_being()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, randi, debug_print, size, str

#### `create_pathway()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_tree, add_child, create_object, get_mouse_spawn_position

#### `create_bush()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_tree, add_child, create_object, get_mouse_spawn_position

*... and 12 more functions*

---

### 📄 scripts/autoload/universal_object_manager.gd
**Functions:** 22

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _connect_to_systems, print, set_process

#### `_connect_to_systems()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_node_or_null

#### `create_object(type: String, position: Vector3, properties: Dictionary = {})`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** append, get_ticks_msec, _generate_uuid, push_error, is_inside_tree

#### `_register_with_all_systems(uuid: String, obj: Node, type: String, data: Dictionary)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, add_to_group, has_method, register_spawned_asset, second_dimensional_magic

#### `get_object_by_uuid(uuid: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** has

#### `get_object_by_name(name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** has, get_object_by_uuid

#### `get_object_data(uuid: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get

#### `get_objects_by_type(type: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** has, append

#### `get_all_objects()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** is_instance_valid, append, values

#### `get_object_count()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `int`
- **Key Calls:** is_instance_valid, values

#### `modify_object(uuid: String, changes: Dictionary)`
- **Purpose:** Function in universal_object_manager system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** append, get_ticks_msec, has, _get_caller_info, is_instance_valid

#### `destroy_object(uuid: String)`
- **Purpose:** Clean up and remove object/component
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** erase, print, queue_free, has, is_instance_valid

#### `destroy_all_objects()`
- **Purpose:** Clean up and remove object/component
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** destroy_object, keys, emit

#### `_generate_uuid()`
- **Purpose:** Function in universal_object_manager system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_ticks_msec, str

#### `_get_caller_info()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_stack, size, str

*... and 7 more functions*

---

### 📄 scripts/autoload/astral_being_manager.gd
**Functions:** 19

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_commands, print, _create_test_panel

#### `_register_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, get_node_or_null

#### `_create_test_panel()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** hide, exists, call_deferred, get_tree, preload

#### `_cmd_spawn_being(args: Array)`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, str, reached, _print, spawn_astral_being

#### `_cmd_list_beings(_args: Array)`
- **Purpose:** Function in astral_being_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_being_name, is_empty, size, Beings, has_method

#### `_cmd_clear_beings(_args: Array)`
- **Purpose:** Function in astral_being_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, _print, size, queue_free

#### `_cmd_assign_task(args: Array)`
- **Purpose:** Function in astral_being_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, size, _find_being, float, add_task

#### `_cmd_organize_scene(_args: Array)`
- **Purpose:** Function in astral_being_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, Vector3, size, add_task, range

#### `_cmd_start_patrol(_args: Array)`
- **Purpose:** Function in astral_being_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, Vector3, size, add_task, range

#### `_cmd_help_ragdoll(_args: Array)`
- **Purpose:** Function in astral_being_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, is_empty, add_task, spawn_astral_being

#### `_cmd_create_lights(_args: Array)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _print, Vector3, size, add_task

#### `_cmd_toggle_test_panel(_args: Array)`
- **Purpose:** Function in astral_being_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print

#### `_cmd_test_all_features(_args: Array)`
- **Purpose:** Function in astral_being_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, show

#### `spawn_astral_being(being_name: String = "", position: Vector3 = Vector3.ZERO)`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** str, has_method, set_being_name, queue_operation, Vector3

#### `get_nearest_being(position: Vector3)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** distance_to

*... and 4 more functions*

---

### 📄 scripts/autoload/dynamic_viewport_manager.gd
**Functions:** 17

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_commands, print, _detect_and_apply_optimal_settings

#### `_detect_and_apply_optimal_settings()`
- **Purpose:** Function in dynamic_viewport_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** screen_get_size, screen_get_usable_rect, print, window_get_current_screen

#### `_register_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, size, mode, get_node_or_null

#### `_set_window_size(size: Vector2i)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, emit, window_set_size, get_window

#### `_center_window()`
- **Purpose:** Function in dynamic_viewport_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** window_get_size, window_set_position, screen_get_size, print, screen_get_position

#### `_set_fullscreen(enabled: bool)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** window_set_mode, emit, _detect_and_apply_optimal_settings

#### `_cmd_viewport_info(_args: Array)`
- **Purpose:** Function in dynamic_viewport_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** window_get_mode, _print_to_console, get_viewport, _get_aspect_ratio_name, window_get_size

#### `_cmd_set_window_size(args: Array)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, laptop, size, _center_window, QHD

#### `_cmd_toggle_fullscreen(args: Array)`
- **Purpose:** Function in dynamic_viewport_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, size, get_node, to_lower, _set_fullscreen

#### `_cmd_set_window_mode(args: Array)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, window_set_mode, size, get_node, to_lower

#### `_cmd_center_window(_args: Array)`
- **Purpose:** Function in dynamic_viewport_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, get_node, _center_window

#### `_cmd_list_screens(_args: Array)`
- **Purpose:** Function in dynamic_viewport_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, screen_get_size, screen_get_dpi, screen_get_position, get_node

#### `_cmd_move_to_screen(args: Array)`
- **Purpose:** Function in dynamic_viewport_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, size, _center_window, window_set_current_screen, get_node

#### `_get_window_mode_name(mode: int)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

#### `_get_aspect_ratio_name(ratio: float)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** abs

*... and 2 more functions*

---

### 📄 scripts/autoload/claude_timer_system.gd
**Functions:** 16

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, connect, set_process

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, emit

#### `start_task(task_name: String, project: String = "")`
- **Purpose:** Function in claude_timer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, print

#### `complete_task()`
- **Purpose:** Function in claude_timer_system system
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** get_ticks_msec, str, print

#### `user_message_received()`
- **Purpose:** Function in claude_timer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _exit_autonomous_mode, get_ticks_msec

#### `switch_project(project_id: String)`
- **Purpose:** Function in claude_timer_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** print

#### `get_session_metrics()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_ticks_msec

#### `get_project_time(project_id: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`

#### `add_autonomous_project(project_id: String, priority: int = 1)`
- **Purpose:** Function in claude_timer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, sort_custom

#### `_sort_by_priority(a, b)`
- **Purpose:** Function in claude_timer_system system
- **Lines:** 0
- **Returns:** `bool`

#### `_on_user_wait_threshold(wait_time: float)`
- **Purpose:** Function in claude_timer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _start_autonomous_mode, size

#### `_start_autonomous_mode()`
- **Purpose:** Function in claude_timer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, str, print, _perform_autonomous_work, int

#### `_perform_autonomous_work(project_id: String)`
- **Purpose:** Function in claude_timer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `_exit_autonomous_mode()`
- **Purpose:** Function in claude_timer_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** int, str, print, completed

#### `get_timer_report()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_session_metrics, get_ticks_msec, str, int

*... and 1 more functions*

---

### 📄 scripts/autoload/multi_todo_manager.gd
**Functions:** 13

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _initialize_default_todos, get_ticks_msec

#### `_initialize_default_todos()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_todo

#### `add_todo(project_id: String, content: String, priority: String = "medium")`
- **Purpose:** Function in multi_todo_manager system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** append, generate_todo_id, get_ticks_msec, print

#### `complete_todo(project_id: String, todo_id: String)`
- **Purpose:** Function in multi_todo_manager system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** get_ticks_msec, size, range, print

#### `modify_todo(project_id: String, todo_id: String, new_content: String, reason: String = "")`
- **Purpose:** Function in multi_todo_manager system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** append, get_ticks_msec, print

#### `step_back_todo(project_id: String, todo_id: String)`
- **Purpose:** Function in multi_todo_manager system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** pop_back, size, print

#### `get_project_todos(project_id: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`

#### `get_all_pending_todos()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append

#### `get_priority_todos(priority: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append

#### `get_session_summary()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_ticks_msec, size

#### `generate_todo_id()`
- **Purpose:** Function in multi_todo_manager system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_ticks_msec, str

#### `get_formatted_todos(project_id: String = "")`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** else, to_upper

#### `balance_workload()`
- **Purpose:** Function in multi_todo_manager system
- **Lines:** 20
- **Returns:** `Dictionary`
- **Key Calls:** get_priority_todos, size

---

### 📄 scripts/autoload/scene_loader.gd
**Functions:** 13

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** file_exists, _copy_example_scenes, dir_exists, save_default_scene, make_dir

#### `_copy_example_scenes()`
- **Purpose:** Function in scene_loader system
- **Lines:** 7
- **Returns:** `void`

#### `save_default_scene()`
- **Purpose:** Function in scene_loader system
- **Lines:** 7
- **Returns:** `void`

#### `load_scene(scene_name: String)`
- **Purpose:** Function in scene_loader system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** clear_all_objects, close, file_exists, get_nodes_in_group, emit_signal
- **Signals:** scene_loaded

#### `_parse_scene_line(line: String, line_number: int)`
- **Purpose:** Function in scene_loader system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** to_float, size, str, print, Vector3

#### `_create_object_at_position(type: String, position: Vector3, properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_ramp, create_ball, create_pathway, create_tree, create_astral_being

#### `_create_ragdoll_at_position(position: Vector3, properties: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_ragdoll, get_nodes_in_group, start_walking, get_tree, print

#### `_apply_properties(obj: Node3D, properties: Dictionary)`
- **Purpose:** Function in scene_loader system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** to_float, deg_to_rad

#### `save_current_scene()`
- **Purpose:** Function in scene_loader system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _vector_to_string, close, get_nodes_in_group, emit_signal, _object_to_scene_line
- **Signals:** scene_saved

#### `_object_to_scene_line(obj: Node3D)`
- **Purpose:** Function in scene_loader system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** rad_to_deg, _vector_to_string, str

#### `_vector_to_string(v: Vector3)`
- **Purpose:** Function in scene_loader system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** str

#### `list_available_scenes()`
- **Purpose:** Function in scene_loader system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, ends_with, list_dir_begin, get_next, open

#### `create_scene_from_template(scene_name: String, template: String)`
- **Purpose:** Create new instance or object
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** store_string, close, open

---

### 📄 scripts/autoload/windows_console_fix.gd
**Functions:** 11

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _detect_terminal_capabilities

#### `_detect_terminal_capabilities()`
- **Purpose:** Function in windows_console_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** to_int, size, print, find, get_environment

#### `safe_print(text: String)`
- **Purpose:** Function in windows_console_fix system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** _convert_to_ascii

#### `_convert_to_ascii(text: String)`
- **Purpose:** Function in windows_console_fix system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** _sanitize_unicode, replace

#### `_sanitize_unicode(text: String)`
- **Purpose:** Function in windows_console_fix system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** unicode_at, length, range

#### `create_ascii_frame(width: int, height: int, title: String = "")`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** length, repeat, range

#### `create_progress_bar(current: float, maximum: float, width: int = 20)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** int, repeat

#### `create_status_display(project: String, status: String, progress: float)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** int, str, to_upper, create_progress_bar

#### `console_print(manager: Node, text: String)`
- **Purpose:** Function in windows_console_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** safe_print, _print_to_console, print, has_method

#### `test_terminal_calibration()`
- **Purpose:** Function in windows_console_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_status_display, str, print, safe_print, create_ascii_frame

#### `patch_console_manager(console_manager: Node)`
- **Purpose:** Function in windows_console_fix system
- **Lines:** 10
- **Returns:** `void`
- **Key Calls:** set_meta, has_method

---

### 📄 scripts/autoload/ui_settings_manager.gd
**Functions:** 8

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, connect, load_settings

#### `load_settings()`
- **Purpose:** Function in ui_settings_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, Color, save_settings, get_value, load
- **Signals:** settings_changed

#### `save_settings()`
- **Purpose:** Function in ui_settings_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, set_value, new, save
- **Signals:** settings_changed

#### `get_scaled_value(base_value: float)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`

#### `get_console_rect()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Rect2`
- **Key Calls:** get_viewport, Vector2, Rect2

#### `set_ui_scale(scale: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** save_settings, clamp

#### `set_console_position(pos: String)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** save_settings

#### `_on_viewport_size_changed()`
- **Purpose:** Function in ui_settings_manager system
- **Lines:** 2
- **Returns:** `void`
- **Key Calls:** emit_signal
- **Signals:** settings_changed

---

### 📄 scripts/autoload/dialogue_system.gd
**Functions:** 5

#### `make_ragdoll_say(text: String)`
- **Purpose:** Function in dialogue_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_nodes_in_group, get_tree, has_method, _say_something_custom

#### `get_next_custom_dialogue()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** is_empty, pop_front

#### `set_mood(new_mood: String)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`

#### `modify_dialogue(base_text: String)`
- **Purpose:** Function in dialogue_system system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** size, randi

#### `show_dialogue(text: String, position: Vector3)`
- **Purpose:** Function in dialogue_system system
- **Lines:** 20
- **Returns:** `void`
- **Key Calls:** Color, get_tree, Vector3, add_child, tween_property

---

### 📄 scripts/autoload/advanced_inspector_loader.gd
**Functions:** 2

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, _load_integration_patch

#### `_load_integration_patch()`
- **Purpose:** Function in advanced_inspector_loader system
- **Lines:** 14
- **Returns:** `void`
- **Key Calls:** exists, get_tree, preload, print, add_child

---

## Interface Systems
**Scripts:** 19 | **Functions:** 413

### 📄 scripts/ui/advanced_object_inspector.gd
**Functions:** 64

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** hide, _connect_signals, print, _setup_shortcuts, _setup_ui

#### `_setup_ui()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_advanced_style, Vector2, _create_physics_tab, _create_scene_tab, add_child

#### `_create_title_bar(parent: VBoxContainer)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_check_item, Vector2, add_child, add_separator, get_popup

#### `_create_properties_tab()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, new, add_child

#### `_create_transform_tab()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Rotation, new, add_child, _create_vector3_editor

#### `_create_materials_tab()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child

#### `_create_physics_tab()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child

#### `_create_scene_tab()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_filter, new, add_child

#### `_create_vector3_editor()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `HBoxContainer`
- **Key Calls:** new, add_child

#### `_apply_advanced_style()`
- **Purpose:** Function in advanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, Color, add_theme_color_override, add_theme_stylebox_override, new

#### `_connect_signals()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_popup, connect

#### `_setup_shortcuts()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`

#### `inspect_object(object: Node)`
- **Purpose:** Function in advanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_materials_tab, _update_scene_tab, _update_properties_tab, print, _add_to_history

#### `_update_properties_tab()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _populate_properties, _clear_properties

#### `_update_transform_tab()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** rad_to_deg, get_children

*... and 49 more functions*

---

### 📄 scripts/ui/feature_test_panel.gd
**Functions:** 31

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_buttons, print, _setup_ui, set_anchors_and_offsets_preset, _setup_references

#### `_setup_ui()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, connect, Vector2, Color, add_child

#### `_create_buttons()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** duplicate, add_theme_font_size_override, connect, Color, bind

#### `_setup_references()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_node_or_null

#### `_on_button_pressed(button: Button)`
- **Purpose:** Function in feature_test_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_status, _execute_command, _mark_success, get_meta, call_deferred

#### `_test_console(button: Button)`
- **Purpose:** Function in feature_test_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _mark_result, create_timer, get_tree

#### `_test_commands(button: Button)`
- **Purpose:** Function in feature_test_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _mark_result

#### `_test_console_fix(button: Button)`
- **Purpose:** Function in feature_test_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_timer, get_tree, _mark_success

#### `_test_inspector(button: Button)`
- **Purpose:** Function in feature_test_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_nodes_in_group, create_timer, get_tree, size, _mark_result

#### `_test_selection(button: Button)`
- **Purpose:** Function in feature_test_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_timer, get_tree, _mark_success

#### `_test_edit(button: Button)`
- **Purpose:** Function in feature_test_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_timer, get_tree, _mark_success

#### `_spawn_astral_being()`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, Vector3, size, str, preload

#### `_test_astral_spawn(button: Button)`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_timer, get_tree, size, _spawn_astral_being, _mark_result

#### `_test_astral_move(button: Button)`
- **Purpose:** Function in feature_test_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _mark_success, Vector3, get_tree, add_task, create_timer

#### `_test_astral_organize(button: Button)`
- **Purpose:** Function in feature_test_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _mark_success, Vector3, get_tree, add_task, create_timer

*... and 16 more functions*

---

### 📄 scripts/ui/unified_grid_list_system.gd
**Functions:** 31

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_grid_container, print, _setup_console_overlay, set_process_unhandled_input, _load_page

#### `_load_page(page_num: int)`
- **Purpose:** Function in unified_grid_list_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _generate_page_data, erase, emit_signal, has, _wait_for_pending_page
- **Signals:** page_changed

#### `_generate_page_data(page_num: int)`
- **Purpose:** Function in unified_grid_list_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, _get_item_type, range, min

#### `_get_item_type(index: int)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** size

#### `_get_item_icon(index: int)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** size

#### `_cycle_display_mode()`
- **Purpose:** Function in unified_grid_list_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, _refresh_display, size, values
- **Signals:** mode_changed

#### `_move_cursor(direction: Vector2i)`
- **Purpose:** Function in unified_grid_list_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** wrapi, _update_cursor_visual, clamp

#### `_update_cursor_visual()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_child_count, _highlight_item, get_child

#### `_execute_console_command(command: String)`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _prev_page, emit_signal, _select_item_by_id, size, _next_page
- **Signals:** command_executed

#### `_goto_item(global_index: int)`
- **Purpose:** Function in unified_grid_list_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _load_page

#### `set_player_state(state_name: String, value: bool)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, set_process_unhandled_input

#### `_unhandled_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_action_pressed, _cycle_focus, has_focus, call

#### `_cycle_focus(direction: int)`
- **Purpose:** Function in unified_grid_list_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** wrapi, _update_cursor_visual

#### `_setup_grid_container()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_constant_override

#### `_setup_list_container()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`

*... and 16 more functions*

---

### 📄 scripts/ui/global_variable_spreadsheet.gd
**Functions:** 27

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_ui, print, _scan_everything

#### `_create_ui()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, connect, _create_scene_nodes_tab, _create_autoloads_tab, _create_performance_tab

#### `_create_autoloads_tab()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_tab_title, new, add_child

#### `_create_scene_nodes_tab()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_tab_title, new, add_child

#### `_create_scripts_tab()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_tab_title, new, add_child

#### `_create_performance_tab()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_tab_title, new, add_child

#### `_scan_everything()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_all_displays, _scan_scripts, _scan_autoloads, print, _scan_scene_tree

#### `_scan_autoloads()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _get_all_methods, get_script, _get_all_properties, get_node_or_null

#### `_scan_scene_tree()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, _scan_node_recursive

#### `_scan_node_recursive(node: Node, path: String = "")`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_script, _scan_node_recursive, get_child_count, get_children, get_class

#### `_scan_scripts()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _get_script_static_vars, values

#### `_get_all_properties(obj: Object)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_property_list, get, begins_with

#### `_get_all_methods(obj: Object)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, get_method_list, begins_with

#### `_get_script_static_vars(script: Script)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`

#### `_update_all_displays()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_autoloads_display, _update_scene_nodes_display, _update_scripts_display, _update_performance_display

*... and 12 more functions*

---

### 📄 scripts/ui/blink_animation_controller.gd
**Functions:** 26

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_node_by_class, connect, get_current_turn, get_tree, str

#### `_find_node_by_class(node, class_name_str)`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_node_by_class, or, get_script, find, get_children

#### `_initialize_timers()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Callable, connect, new, add_child

#### `_create_default_animations()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** track_insert_key, add_track, add_animation_library, track_set_path, new

#### `_schedule_next_blink()`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_debug_build, pow, start, str, print

#### `_schedule_next_wink()`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_debug_build, pow, start, str, print

#### `_schedule_next_flicker()`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_debug_build, pow, start, str, print

#### `_execute_blink()`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_debug_build, create_timer, _blink_node, str, print

#### `_execute_wink()`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** wink, is_debug_build, _wink_node, create_timer, get_tree

#### `_execute_flicker()`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, is_debug_build, create_timer, _flicker_node, str

#### `_blink_node(node_name: String, blink_count: int)`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** erase, emit_signal, create_timer, get_tree, tween_property
- **Signals:** blink_started, blink_ended

#### `_wink_node(node_name: String, is_left: bool)`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** erase, emit_signal, Color, tween_property, has_method
- **Signals:** wink_ended, wink_started

#### `_flicker_node(node_name: String, flicker_count: int)`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** erase, emit_signal, create_timer, get_tree, tween_property
- **Signals:** flicker_started, flicker_ended

#### `_on_blink_timer_timeout()`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _execute_blink

#### `_on_wink_timer_timeout()`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _execute_wink

*... and 11 more functions*

---

### 📄 scripts/ui/object_inspector.gd
**Functions:** 24

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** hide, _connect_signals, print, _setup_ui

#### `_setup_ui()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector2, add_child, set_anchors_and_offsets_preset, _apply_inspector_style, new

#### `_apply_inspector_style()`
- **Purpose:** Function in object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_color_override, Color, add_theme_stylebox_override, new

#### `_connect_signals()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect

#### `inspect_object(object: Node)`
- **Purpose:** Function in object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, show, get_class, _clear_properties, _populate_properties

#### `_clear_properties()`
- **Purpose:** Function in object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, get_children, queue_free

#### `_populate_properties()`
- **Purpose:** Function in object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_property_list, size, _create_category_section

#### `_create_category_section(category_name: String, properties: Array)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, _create_property_editor, add_child, add_theme_color_override, new

#### `_create_property_editor(property: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _connect_editor_signal, _create_editor_for_type, add_child, new, _should_show_property

#### `_create_editor_for_type(type: int, current_value: Variant)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Control`
- **Key Calls:** str, add_child, add_theme_color_override, get_class, new

#### `_connect_editor_signal(editor: Control, prop_name: String, prop_type: int)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** bind, connect, get_child

#### `_should_show_property(property: Dictionary)`
- **Purpose:** Determine if action should be taken
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** to_lower, contains, begins_with

#### `_on_bool_changed(value: bool, prop_name: String)`
- **Purpose:** Function in object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_property_change

#### `_on_number_changed(value: float, prop_name: String)`
- **Purpose:** Function in object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** int, _apply_property_change, get, typeof

#### `_on_string_changed(text: String, prop_name: String)`
- **Purpose:** Function in object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_property_change

*... and 9 more functions*

---

### 📄 scripts/ui/enhanced_object_inspector.gd
**Functions:** 23

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, add_child, new, _create_inspector_ui, connect

#### `_position_panel()`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, Vector2

#### `_create_inspector_ui()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, connect, Vector2, call_deferred, add_child

#### `inspect_object(obj: Node)`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _add_transform_properties, _add_physics_properties, _add_basic_properties, get_meta, _add_metadata_properties

#### `_add_basic_properties()`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _add_string_property, get_groups, size, _add_section_header, get_class

#### `_add_transform_properties()`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _add_section_header, _add_vector3_property

#### `_add_physics_properties()`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _add_section_header, _add_float_property, _add_vector3_property, _add_bool_property

#### `_add_metadata_properties()`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_meta_list, get_meta, size, str, _add_section_header

#### `_add_custom_properties()`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_meta, size, _add_action_button, _add_section_header, _add_label_property

#### `_add_section_header(text: String)`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, Color, add_child, add_theme_color_override, new

#### `_add_label_property(label: String, value: String)`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_color_override, Color, new, add_child

#### `_add_string_property(label: String, property: String, value: String)`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _on_property_changed, connect, new, add_child

#### `_add_float_property(label: String, property: String, value: float)`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _on_property_changed, connect, new, add_child

#### `_add_bool_property(label: String, property: String, value: bool, is_metadata: bool = false)`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _on_property_changed, connect, new, add_child

#### `_add_vector3_property(label: String, property: String, value: Vector3)`
- **Purpose:** Function in enhanced_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, new, add_child, _on_vector3_component_changed

*... and 8 more functions*

---

### 📄 scripts/ui/universal_object_inspector.gd
**Functions:** 20

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** hide, print, _setup_ui

#### `_setup_ui()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector2, add_child, _create_gizmo_section, _create_properties_section, new

#### `_create_transform_section()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, else, connect, _create_axis_control, Color

#### `_create_axis_control(label_text: String, axis: String, color: Color)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** _on_transform_changed, Vector2, add_child, new, to_lower

#### `_create_gizmo_section()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, add_child, new, _set_gizmo_mode, connect

#### `_create_properties_section()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, add_theme_font_size_override, new, add_child

#### `_apply_inspector_style()`
- **Purpose:** Function in universal_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, Color, add_theme_color_override, add_theme_stylebox_override, new

#### `inspect_object(object: Node)`
- **Purpose:** Function in universal_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_transform_controls, print, show, _update_properties, get_class

#### `_update_transform_controls()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_value_no_signal

#### `_update_properties()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _add_property_control, get_children, queue_free

#### `_add_property_control(label: String, property: String, value: Variant)`
- **Purpose:** Function in universal_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector2, _on_property_changed, add_child, new, connect

#### `_on_transform_changed(transform_type: String, axis: String, value: float)`
- **Purpose:** Function in universal_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, Vector3, set_value_no_signal, begins_with
- **Signals:** property_changed

#### `_on_property_changed(property: String, value: Variant)`
- **Purpose:** Function in universal_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, set
- **Signals:** property_changed

#### `_on_gizmo_requested()`
- **Purpose:** Function in universal_object_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, _update_gizmo_button_text, emit_signal, get_tree, print
- **Signals:** gizmo_requested

#### `_update_gizmo_button_text(is_active: bool)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_children, contains

*... and 5 more functions*

---

### 📄 scripts/ui/height_map_overlay.gd
**Functions:** 19

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_legend, _create_height_gradient, _initialize_map

#### `_initialize_map()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_from_image, Color, fill, create

#### `_create_height_gradient()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new

#### `_setup_legend()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Water, Deep, Ground, High, Peak

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_map

#### `_update_map()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** update, _fade_map, _draw_entities, _update_terrain_heights

#### `_fade_map()`
- **Purpose:** Function in height_map_overlay system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, int, get_data, range

#### `_update_terrain_heights()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_pixel, _pixel_to_world, get_noise_2d, _height_to_color, range

#### `_draw_entities()`
- **Purpose:** Function in height_map_overlay system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _draw_circle_on_map, Vector2, float, size

#### `_world_to_pixel(world_pos: Vector2)`
- **Purpose:** Function in height_map_overlay system
- **Lines:** 0
- **Returns:** `Vector2i`
- **Key Calls:** int, Vector2i

#### `_pixel_to_world(pixel_pos: Vector2i)`
- **Purpose:** Function in height_map_overlay system
- **Lines:** 0
- **Returns:** `Vector2`
- **Key Calls:** Vector2

#### `_is_valid_pixel(pos: Vector2i)`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`

#### `_height_to_color(height: float)`
- **Purpose:** Function in height_map_overlay system
- **Lines:** 0
- **Returns:** `Color`
- **Key Calls:** sample, clamp

#### `_draw_circle_on_map(center: Vector2i, radius: int, color: Color)`
- **Purpose:** Function in height_map_overlay system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_pixelv, range, _is_valid_pixel, Vector2i

#### `update_entity_position(entity_id: String, position: Vector3)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`

*... and 4 more functions*

---

### 📄 scripts/ui/grid_list_console_bridge.gd
**Functions:** 18

#### `register_grid_cell(x: int, y: int, page: int, command: String)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector2i

#### `register_list_item(index: int, page: int, command: String)`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`

#### `visual_to_command(action: String, target: Dictionary)`
- **Purpose:** Function in grid_list_console_bridge system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** emit_signal, str, get
- **Signals:** command_generated

#### `execute_unified_command(command: String, source: String = "console")`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** _handle_page_change, has_node, execute_command, _handle_delete, _handle_create

#### `get_command_suggestions(partial: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, _get_entity_types, _get_selectable_items, size, _get_page_numbers

#### `get_item_from_page(page: int, index: int)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`

#### `grid_to_list_index(x: int, y: int, columns: int)`
- **Purpose:** Function in grid_list_console_bridge system
- **Lines:** 0
- **Returns:** `int`

#### `list_to_grid_pos(index: int, columns: int)`
- **Purpose:** Function in grid_list_console_bridge system
- **Lines:** 0
- **Returns:** `Vector2i`
- **Key Calls:** Vector2i

#### `_handle_select(args: Array)`
- **Purpose:** Function in grid_list_console_bridge system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** size, begins_with, int, is_empty, substr

#### `_handle_create(args: Array)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** size

#### `_handle_page_change(args: Array)`
- **Purpose:** Function in grid_list_console_bridge system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** is_empty, int

#### `_get_entity_types()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`

#### `_get_page_numbers()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, str, range

#### `_get_selectable_items()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, get_tree, get_nodes_in_group

#### `_log_command(command: String, source: String, result: Dictionary)`
- **Purpose:** Function in grid_list_console_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** store_with_metadata, get_ticks_msec, has_node, get_node

*... and 3 more functions*

---

### 📄 scripts/ui/script_orchestra_interface.gd
**Functions:** 17

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _ready_console_commands, _create_interface, print, _setup_monitoring

#### `_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_action_pressed, get_viewport, set_input_as_handled, toggle_visibility

#### `_create_interface()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, connect, Vector2, add_child, add_theme_constant_override

#### `_setup_monitoring()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, start, add_child, get_node, new

#### `_update_orchestra()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_file, _get_player_position, get_nodes_in_group, _update_miracle_ratio

#### `_scan_node_recursive(node: Node, player_pos: Vector3)`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** distance_to, _analyze_creation_state, get_parent, get_script, _scan_node_recursive

#### `_get_player_position()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Vector3`
- **Key Calls:** get_viewport, to_lower, get_camera_3d

#### `_analyze_creation_state(node: Node)`
- **Purpose:** Function in script_orchestra_interface system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** to_lower, has_meta, has_method

#### `_get_creation_icon(info: ScriptInfo)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

#### `_update_miracle_ratio()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** values, float, size, randf, emit

#### `_on_script_selected(index: int)`
- **Purpose:** Function in script_orchestra_interface system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_file, values, size, _get_creation_icon, sort_custom

#### `_on_distance_changed(value: float)`
- **Purpose:** Function in script_orchestra_interface system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `toggle_visibility()`
- **Purpose:** Function in script_orchestra_interface system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_orchestra

#### `get_orchestra_report()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** size, values

#### `_ready_console_commands()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, get_node_or_null

*... and 2 more functions*

---

### 📄 scripts/ui/visual_indicator_system.gd
**Functions:** 17

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_time_tracker, str, print, _apply_mode_settings, _setup_timers

#### `_setup_timers()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, new, add_child

#### `_find_time_tracker()`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_node_by_class, get_nodes_in_group, size, get_tree, print

#### `_find_node_by_class(node: Node, class_name: String)`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** _find_node_by_class, get_children, get_class

#### `_apply_mode_settings(mode_index)`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _set_symbol, emit_signal
- **Signals:** mode_changed

#### `_set_symbol(symbol_index)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal
- **Signals:** symbol_changed

#### `_on_blink_timer_timeout()`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal
- **Signals:** blink_occurred

#### `_on_color_cycle_timer_timeout()`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, size
- **Signals:** layer_changed, color_updated

#### `_on_animation_timer_timeout()`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `void`

#### `_on_time_updated(session_time, total_time)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _set_symbol, size, floor, min

#### `_on_hour_limit_reached(hours)`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _set_symbol, create_timer, get_tree

#### `set_mode(mode_index: int)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** _apply_mode_settings, size

#### `cycle_mode()`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `int`
- **Key Calls:** _apply_mode_settings, size

#### `toggle_enabled()`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `bool`

#### `get_current_symbol()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

*... and 2 more functions*

---

### 📄 scripts/ui/console_world_view.gd
**Functions:** 16

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, _initialize_world_grid, load, add_theme_font_override, get_node_or_null

#### `_initialize_world_grid()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, range, append

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_world_display

#### `_update_world_display()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _generate_display_text, _place_entity_on_grid, _initialize_world_grid

#### `_place_entity_on_grid(entity_data: Dictionary)`
- **Purpose:** Function in console_world_view system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector2, _world_to_grid, get, has

#### `_world_to_grid(world_pos: Vector2)`
- **Purpose:** Function in console_world_view system
- **Lines:** 0
- **Returns:** `Vector2i`
- **Key Calls:** int, Vector2i

#### `_generate_display_text()`
- **Purpose:** Function in console_world_view system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, repeat, range, join, get

#### `update_entity(entity_id: String, data: Dictionary)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`

#### `remove_entity(entity_id: String)`
- **Purpose:** Function in console_world_view system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** erase

#### `clear_entities()`
- **Purpose:** Function in console_world_view system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear

#### `pan_view(direction: Vector2)`
- **Purpose:** Function in console_world_view system
- **Lines:** 0
- **Returns:** `void`

#### `zoom_view(factor: float)`
- **Purpose:** Function in console_world_view system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clamp

#### `center_on_position(world_pos: Vector3)`
- **Purpose:** Function in console_world_view system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector2

#### `_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** pan_view, zoom_view

#### `_on_layer_visibility_changed(layer: int, visible: bool)`
- **Purpose:** Function in console_world_view system
- **Lines:** 0
- **Returns:** `void`

*... and 1 more functions*

---

### 📄 scripts/ui/creative_mode_inventory.gd
**Functions:** 15

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_ui, print, set_process_unhandled_input, _populate_inventory, get_node_or_null

#### `_create_ui()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, add_theme_font_size_override, connect, Vector2, Color

#### `_unhandled_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, toggle_inventory, hide_inventory, is_action_pressed, set_input_as_handled

#### `toggle_inventory()`
- **Purpose:** Function in creative_mode_inventory system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** hide_inventory, show_inventory

#### `show_inventory()`
- **Purpose:** Function in creative_mode_inventory system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree

#### `hide_inventory()`
- **Purpose:** Function in creative_mode_inventory system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree

#### `_populate_inventory()`
- **Purpose:** Function in creative_mode_inventory system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, _create_item_slot, _get_filtered_items, queue_free

#### `_get_filtered_items()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get

#### `_create_item_slot(item_id: String, item_data: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, add_theme_font_size_override, connect, Color, bind

#### `_generate_placeholder_icon(item_id: String)`
- **Purpose:** Function in creative_mode_inventory system
- **Lines:** 0
- **Returns:** `ImageTexture`
- **Key Calls:** create_from_image, fill, create, new

#### `_on_category_selected(category_id: String)`
- **Purpose:** Function in creative_mode_inventory system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _populate_inventory

#### `_on_item_selected(item_id: String, item_data: Dictionary)`
- **Purpose:** Function in creative_mode_inventory system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_node_or_null, execute_command, print, has_method, emit

#### `_on_close_pressed()`
- **Purpose:** Function in creative_mode_inventory system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** hide_inventory

#### `refresh_inventory()`
- **Purpose:** Function in creative_mode_inventory system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _populate_inventory

#### `set_category(category_id: String)`
- **Purpose:** Assign data or property value
- **Lines:** 10
- **Returns:** `void`
- **Key Calls:** keys, get_child, get_child_count, _populate_inventory, range

---

### 📄 scripts/ui/interactive_tutorial_system.gd
**Functions:** 15

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _save_initial_state, _create_ui

#### `_save_initial_state()`
- **Purpose:** Function in interactive_tutorial_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, get_nodes_in_group, size, get_tree, get_camera_3d

#### `_create_ui()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, Vector2, add_child, new, connect

#### `_start_tutorial()`
- **Purpose:** Function in interactive_tutorial_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, print, _update_test_ui

#### `_update_test_ui()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, _show_final_results, add_child, begins_with, queue_free

#### `_add_test_buttons(tests: Array)`
- **Purpose:** Function in interactive_tutorial_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, bind, add_child, new, get

#### `_run_test(test_name: String, command: String)`
- **Purpose:** Function in interactive_tutorial_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, _execute_command, _update_results

#### `_record_result(test_name: String, success: bool)`
- **Purpose:** Function in interactive_tutorial_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, get_datetime_string_from_system, _update_results
- **Signals:** test_completed

#### `_next_test()`
- **Purpose:** Function in interactive_tutorial_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_test_ui

#### `_reset_scene()`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, _execute_command, _update_results, print, has

#### `_update_results(text: String)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append_text

#### `_show_final_results()`
- **Purpose:** Function in interactive_tutorial_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, float, append_text, clear, _save_results_to_file
- **Signals:** tutorial_finished

#### `_save_results_to_file()`
- **Purpose:** Function in interactive_tutorial_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** store_string, close, _update_results, open, stringify

#### `_close_tutorial()`
- **Purpose:** Function in interactive_tutorial_system system
- **Lines:** 0
- **Returns:** `void`

#### `show_tutorial()`
- **Purpose:** Function in interactive_tutorial_system system
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** _save_initial_state

---

### 📄 scripts/ui/systematic_test_tutorial.gd
**Functions:** 15

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_tutorial_ui, _position_ui, _start_tutorial

#### `_create_tutorial_ui()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, connect, Vector2, Color, add_child

#### `_position_ui()`
- **Purpose:** Function in systematic_test_tutorial system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, get_visible_rect

#### `_start_tutorial()`
- **Purpose:** Function in systematic_test_tutorial system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, _update_current_test

#### `_update_current_test()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _finish_tutorial, size

#### `_run_current_test()`
- **Purpose:** Function in systematic_test_tutorial system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** executed, get_nodes_in_group, create_timer, get_tree, execute_command

#### `_record_test_result(test_name: String, result: String, success: bool)`
- **Purpose:** Function in systematic_test_tutorial system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_datetime_string_from_system, print, emit_signal
- **Signals:** test_completed

#### `_next_test()`
- **Purpose:** Function in systematic_test_tutorial system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _finish_tutorial, size, _update_current_test

#### `_previous_test()`
- **Purpose:** Function in systematic_test_tutorial system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_current_test

#### `_finish_tutorial()`
- **Purpose:** Function in systematic_test_tutorial system
- **Lines:** 7
- **Returns:** `void`
- **Key Calls:** size, filter

#### `_generate_final_report()`
- **Purpose:** Function in systematic_test_tutorial system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, FUNCTIONS, print, repeat, range

#### `_restart_tutorial()`
- **Purpose:** Function in systematic_test_tutorial system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, _start_tutorial, disconnect

#### `_close_tutorial()`
- **Purpose:** Function in systematic_test_tutorial system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** queue_free

#### `_count_scene_objects()`
- **Purpose:** Function in systematic_test_tutorial system
- **Lines:** 0
- **Returns:** `int`
- **Key Calls:** _count_children_recursive, get_tree

#### `_count_children_recursive(node: Node)`
- **Purpose:** Function in systematic_test_tutorial system
- **Lines:** 5
- **Returns:** `int`
- **Key Calls:** _count_children_recursive, get_children

---

### 📄 scripts/ui/asset_creator_panel.gd
**Functions:** 13

#### `get_spectrum_color(value: float)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Color`
- **Key Calls:** Yellow, White, Purple, Color, size

#### `_on_spectrum_changed(value: float, color_preview: Panel)`
- **Purpose:** Function in asset_creator_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_spectrum_color, add_theme_stylebox_override, new, _update_preview_mesh

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_preview, _setup_ui

#### `_setup_ui()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Static, Character, Rigid, _create_ui_elements, connect

#### `_create_ui_elements()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, set_anchors_preset, connect, set_custom_minimum_size, Size

#### `_create_preview()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_preview_mesh, Vector3, add_child, queue_free, new

#### `_update_preview_mesh()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_selected_id, get_spectrum_color, Vector3, new

#### `_on_type_changed(index: int)`
- **Purpose:** Function in asset_creator_panel system
- **Lines:** 0
- **Returns:** `void`

#### `_on_mesh_changed(index: int)`
- **Purpose:** Function in asset_creator_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_preview_mesh

#### `_on_size_changed(value: float)`
- **Purpose:** Function in asset_creator_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_preview_mesh

#### `_on_create_pressed()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit, push_error, Vector3, print, get_spectrum_color

#### `_on_cancel_pressed()`
- **Purpose:** Function in asset_creator_panel system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit

#### `show_panel()`
- **Purpose:** Display UI panel or window
- **Lines:** 4
- **Returns:** `void`
- **Key Calls:** grab_focus

---

### 📄 scripts/ui/bryce_grid_interface.gd
**Functions:** 13

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _calculate_grid_layout, _load_sample_entities, _create_grid_cells, print, connect

#### `_calculate_grid_layout()`
- **Purpose:** Function in bryce_grid_interface system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector2, print, get_viewport_rect, max, int

#### `_create_grid_cells()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _create_cell, add_child, queue_free, range

#### `_create_cell(col: int, row: int)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Control`
- **Key Calls:** Vector2, bind, str, add_child, add_theme_color_override

#### `_on_cell_input(event: InputEvent, cell_index: int)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _select_cell

#### `_on_cell_hover(cell_index: int)`
- **Purpose:** Function in bryce_grid_interface system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, size, _update_cell_visual
- **Signals:** cell_hovered

#### `_on_cell_unhover(cell_index: int)`
- **Purpose:** Function in bryce_grid_interface system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_cell_visual

#### `_select_cell(cell_index: int)`
- **Purpose:** Function in bryce_grid_interface system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, size, _update_cell_visual, print
- **Signals:** cell_selected

#### `_update_cell_visual(cell_index: int)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, get_theme_stylebox, get_child

#### `_on_window_resized()`
- **Purpose:** Function in bryce_grid_interface system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _calculate_grid_layout, _create_grid_cells, _populate_grid

#### `_load_sample_entities()`
- **Purpose:** Function in bryce_grid_interface system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _populate_grid

#### `_populate_grid()`
- **Purpose:** Function in bryce_grid_interface system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, range, _update_cell_visual, min

#### `get_grid_info()`
- **Purpose:** Retrieve data or property value
- **Lines:** 8
- **Returns:** `Dictionary`
- **Key Calls:** float

---

### 📄 scripts/ui/simple_testing_guide.gd
**Functions:** 9

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_test_message, _create_guide_ui, show_guide_temporarily

#### `_create_guide_ui()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, Vector2, Color, add_child, add_theme_color_override

#### `_update_test_message()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 4
- **Returns:** `void`

#### `show_guide_temporarily()`
- **Purpose:** Function in simple_testing_guide system
- **Lines:** 0
- **Returns:** `void`

#### `_fade_out_guide()`
- **Purpose:** Function in simple_testing_guide system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, connect, tween_property, create_tween

#### `_hide_guide()`
- **Purpose:** Function in simple_testing_guide system
- **Lines:** 0
- **Returns:** `void`

#### `_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_test_message, _hide_guide

#### `update_test_message(new_message: String)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_test_message

#### `show_success_message(feature: String)`
- **Purpose:** Function in simple_testing_guide system
- **Lines:** 4
- **Returns:** `void`

---

## Ragdoll Systems
**Scripts:** 8 | **Functions:** 150

### 📄 scripts/ragdoll/biomechanical_walker.gd
**Functions:** 30

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_physics, _create_skeleton, _initialize_gait

#### `_create_skeleton()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, add_child, _create_leg, get_path, new

#### `_create_leg(side: String, offset: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Leg`
- **Key Calls:** _create_knee_joint, _create_ankle_joint, Vector3, _create_midfoot_joint, add_child

#### `_create_body(name: String, mass: float, size: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `RigidBody3D`
- **Key Calls:** bind, connect, new, add_child

#### `_create_hip_joint(pelvis: RigidBody3D, hip: RigidBody3D, thigh: RigidBody3D)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Generic6DOFJoint3D`
- **Key Calls:** set_param_y, set_param_x, set_param_z, add_child, get_path

#### `_create_knee_joint(thigh: RigidBody3D, shin: RigidBody3D)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `HingeJoint3D`
- **Key Calls:** add_child, set_flag, get_path, new, set_param

#### `_create_ankle_joint(shin: RigidBody3D, heel: RigidBody3D)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Generic6DOFJoint3D`
- **Key Calls:** set_param_x, set_param_z, add_child, get_path, new

#### `_create_midfoot_joint(heel: RigidBody3D, foot: RigidBody3D)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `HingeJoint3D`
- **Key Calls:** add_child, set_flag, get_path, new, set_param

#### `_create_toe_joint(foot: RigidBody3D, toes: RigidBody3D)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `HingeJoint3D`
- **Key Calls:** add_child, set_flag, get_path, new, set_param

#### `_setup_physics()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`

#### `_initialize_gait()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_leg_phase, _maintain_balance, _apply_gait_forces, _update_center_of_mass

#### `_update_leg_phase(leg: Leg, delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _transition_to_next_phase

#### `_transition_to_next_phase(leg: Leg)`
- **Purpose:** Function in biomechanical_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** keys, emit

#### `_apply_gait_forces(leg: Leg)`
- **Purpose:** Function in biomechanical_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_mid_swing_forces, _apply_initial_swing_forces, _apply_heel_off_forces, _apply_heel_strike_forces, _apply_foot_flat_forces

*... and 15 more functions*

---

### 📄 scripts/ragdoll_v2/advanced_ragdoll_controller.gd
**Functions:** 28

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, print, _create_subsystems

#### `initialize_ragdoll(parts: Dictionary)`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_body_parts, push_error, print, _change_state, set_ground_detection

#### `_create_subsystems()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_state_machine, _apply_ik_to_animation_goals, _update_velocity, _update_balance, _update_ground_state

#### `_update_ground_state()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_foot_ground_info

#### `_update_balance()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _is_point_in_polygon, size, _calculate_center_of_mass, _point_to_line_distance

#### `_update_velocity()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`

#### `_update_state_machine(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_walking_state, _update_falling_state, _update_running_state, _update_preparing_state, _update_turning_state

#### `_update_idle_state(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** play_cycle, _change_state, length, not

#### `_update_preparing_state(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _change_state, length

#### `_update_walking_state(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** play_cycle, _plan_next_step, _change_state, length

#### `_update_running_state(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** play_cycle, _change_state, length

#### `_update_turning_state(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _change_state

#### `_update_falling_state(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _change_state

#### `_update_recovering_state(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _change_state

*... and 13 more functions*

---

### 📄 scripts/ragdoll/unified_biomechanical_walker.gd
**Functions:** 20

#### `_init()`
- **Purpose:** Function in unified_biomechanical_walker system
- **Lines:** 4
- **Returns:** `void`

#### `_init()`
- **Purpose:** Function in unified_biomechanical_walker system
- **Lines:** 4
- **Returns:** `void`
- **Key Calls:** new

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_joints, print, _setup_physics, _create_body

#### `_create_body()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_leg, Vector3, add_child, _create_rigid_body

#### `_create_leg(side: String, offset: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Leg`
- **Key Calls:** Vector3, new, add_child, _create_rigid_body

#### `_create_rigid_body(name: String, size: Vector3, mass: float)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `RigidBody3D`
- **Key Calls:** new, add_child

#### `_create_joints()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_6dof_joint, print, _limit_6dof_joint, _create_leg_joints

#### `_create_leg_joints(leg: Leg, pelvis_body: RigidBody3D)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_6dof_joint, set_flag, _create_hinge_joint, _limit_6dof_joint, set_param

#### `_create_6dof_joint(body_a: RigidBody3D, body_b: RigidBody3D, joint_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Generic6DOFJoint3D`
- **Key Calls:** new, add_child, get_path

#### `_create_hinge_joint(body_a: RigidBody3D, body_b: RigidBody3D, joint_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `HingeJoint3D`
- **Key Calls:** new, add_child, get_path

#### `_limit_6dof_joint(joint: Generic6DOFJoint3D, x_degrees: float, y_degrees: float, z_degrees: float)`
- **Purpose:** Function in unified_biomechanical_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_param_y, set_flag_z, set_param_x, set_param_z, deg_to_rad

#### `_setup_physics()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _maintain_balance, _update_gait

#### `_update_gait(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_leg_phase, _apply_gait_forces

#### `_update_leg_phase(leg: Leg, delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** keys, emit

*... and 5 more functions*

---

### 📄 scripts/ragdoll_v2/keypoint_animation_system.gd
**Functions:** 19

#### `get_frame_at_time(normalized_time: float)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** lerp, size, range, _apply_easing

#### `_apply_easing(t: float, easing: String)`
- **Purpose:** Function in keypoint_animation_system system
- **Lines:** 17
- **Returns:** `float`
- **Key Calls:** pow

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_animation_cycles, print, _setup_default_keypoints

#### `set_body_parts(parts: Dictionary)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_rest_positions

#### `set_ground_detection(detector: GroundDetectionSystem)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`

#### `_setup_default_keypoints()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new

#### `_update_rest_positions()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`

#### `_create_animation_cycles()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, duplicate, _create_crouch_cycle, _create_run_cycle, Vector3

#### `_create_run_cycle()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new

#### `_create_turn_cycle()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new

#### `_create_crouch_cycle()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new

#### `play_cycle(cycle_name: String, transition_time: float = 0.3)`
- **Purpose:** Function in keypoint_animation_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, push_error

#### `update_animation(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_frame_at_time, fmod, _apply_frame_goals, lerp, min

#### `_apply_frame_goals(goals: Dictionary)`
- **Purpose:** Function in keypoint_animation_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_parent, get, ends_with, get_ground_info

#### `_process_animation_events(normalized_time: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

*... and 4 more functions*

---

### 📄 scripts/ragdoll_v2/ik_solver.gd
**Functions:** 18

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `set_body_parts(parts: Dictionary)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_ik_chains

#### `_setup_ik_chains()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, size, print, _has_parts, new

#### `_has_parts(part_names: Array)`
- **Purpose:** Check if something exists or is available
- **Lines:** 0
- **Returns:** `bool`

#### `solve_chain(chain_name: String, target_position: Vector3, weight: float = 1.0)`
- **Purpose:** Function in ik_solver system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _solve_two_bone_ik_physics

#### `_solve_two_bone_ik_physics(chain: IKChain, target: Vector3, weight: float)`
- **Purpose:** Function in ik_solver system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** rotated, distance_to, _apply_ik_forces, normalized, _calculate_pole_direction

#### `_calculate_pole_direction(chain: IKChain, root_pos: Vector3, target: Vector3)`
- **Purpose:** Function in ik_solver system
- **Lines:** 0
- **Returns:** `Vector3`
- **Key Calls:** cross, length, normalized, dot

#### `_apply_ik_forces(chain: IKChain, middle_target: Vector3, end_target: Vector3, weight: float)`
- **Purpose:** Function in ik_solver system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_alignment_torques, length, apply_central_force

#### `_apply_alignment_torques(chain: IKChain, weight: float)`
- **Purpose:** Function in ik_solver system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** cross, normalized, apply_torque

#### `solve_all_chains(targets: Dictionary, weights: Dictionary = {})`
- **Purpose:** Function in ik_solver system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get, solve_chain

#### `get_chain_info(chain_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** _get_chain_length, _get_chain_bend_angle

#### `_get_chain_length(chain: IKChain)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** distance_to

#### `_get_chain_bend_angle(chain: IKChain)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** normalized, dot, rad_to_deg, acos, clamp

#### `enable_debug(enabled: bool)`
- **Purpose:** Function in ik_solver system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _clear_debug_lines

#### `_create_debug_line(from: Vector3, to: Vector3, color: Color)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** line

*... and 3 more functions*

---

### 📄 scripts/ragdoll_v2/ground_detection_system.gd
**Functions:** 14

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_edge_detection, get_tree, _setup_foot_rays, print, _create_debug_markers

#### `set_body_parts(parts: Dictionary)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _position_rays, get

#### `_setup_foot_rays()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, Vector3, add_child, range, new

#### `_setup_edge_detection()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, Vector3, new, add_child

#### `_position_rays()`
- **Purpose:** Function in ground_detection_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, size, range

#### `get_ground_info(world_position: Vector3, use_cache: bool = true)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `GroundInfo`
- **Key Calls:** _perform_ground_check, get_ticks_msec, str, snapped

#### `_perform_ground_check(world_pos: Vector3)`
- **Purpose:** Function in ground_detection_system system
- **Lines:** 0
- **Returns:** `GroundInfo`
- **Key Calls:** distance_to, get_world_3d, dot, get_meta, _check_for_edge

#### `_check_for_edge(world_pos: Vector3)`
- **Purpose:** Function in ground_detection_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** Vector3, create, get_world_3d, intersect_ray

#### `get_foot_ground_info(foot_name: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `GroundInfo`
- **Key Calls:** distance_to, normalized, dot, _check_for_edge, force_raycast_update

#### `get_safe_foot_placement(current_pos: Vector3, desired_direction: Vector3, step_length: float)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Vector3`
- **Key Calls:** rotated, deg_to_rad, get_ground_info

#### `get_balance_assessment()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** abs, get_foot_ground_info

#### `_create_debug_markers()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, range, add_child, new

#### `update_debug_visualization()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** dot, size, rad_to_deg, is_colliding, get_collision_normal

#### `_physics_process(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 14
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, erase, size, update_debug_visualization

---

### 📄 scripts/ragdoll/gait_phase_visualizer.gd
**Functions:** 12

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_timeline_ui, connect, _create_debug_labels, get_node_or_null

#### `_setup_timeline_ui()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector2, new, add_child

#### `_create_debug_labels()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_child

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_force_vectors, _update_phase_labels, is_layer_visible, _update_timeline, _update_contact_visualization

#### `_update_phase_labels()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, get_current_phase, get

#### `_update_contact_visualization()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, add_debug_point, add_debug_line, clear_debug_draw, is_foot_on_ground

#### `_update_force_vectors()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, length, normalized, add_debug_line

#### `_update_timeline()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_stylebox_override, new, _calculate_cycle_progress

#### `_calculate_cycle_progress(leg: BiomechanicalWalker.Leg)`
- **Purpose:** Function in gait_phase_visualizer system
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** get, lerp

#### `_on_phase_changed(leg_side: String, phase_name: String)`
- **Purpose:** Function in gait_phase_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `_on_step_completed(foot: String)`
- **Purpose:** Function in gait_phase_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, print, get_node, play_footstep

#### `handle_console_command(command: String, args: Array)`
- **Purpose:** Function in gait_phase_visualizer system
- **Lines:** 28
- **Returns:** `String`
- **Key Calls:** size, str

---

### 📄 scripts/ragdoll_v2/ragdoll_v2_spawner.gd
**Functions:** 9

#### `spawn_ragdoll_v2(spawn_position: Vector3 = Vector3.ZERO)`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** get_tree, _create_body_parts, _create_joints, print, add_child

#### `_create_body_parts(parent: Node3D)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** Vector3, new, add_child, set_meta

#### `_create_joints(parts: Dictionary, parent: Node3D)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_joint

#### `_create_joint(body_a: RigidBody3D, body_b: RigidBody3D, joint_name: String, parent: Node3D)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** push_error, add_child, deg_to_rad, set_flag, get_path

#### `register_console_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, get_node_or_null, has_method

#### `_cmd_spawn_ragdoll_v2(args: Array)`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** spawn_ragdoll_v2, Vector3, size, float, print

#### `_cmd_ragdoll2_move(args: Array)`
- **Purpose:** Function in ragdoll_v2_spawner system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, set_movement_input, get_meta, Vector2, size

#### `_cmd_ragdoll2_state(args: Array)`
- **Purpose:** Function in ragdoll_v2_spawner system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, get_meta, get_tree, print, get_state_info

#### `_cmd_ragdoll2_debug(args: Array)`
- **Purpose:** Function in ragdoll_v2_spawner system
- **Lines:** 16
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, get_meta, get_tree, print, enable_debug

---

## JSH Framework
**Scripts:** 2 | **Functions:** 1

### 📄 scripts/jsh_framework/jsh_adapter.gd
**Functions:** 1

#### `initialize_jsh_for_ragdoll()`
- **Purpose:** Set up initial state and connections
- **Lines:** 31
- **Returns:** `void`
- **Key Calls:** get_main_loop, print, has_method, setup_terminal_variables, get_node_or_null

---

## Component Systems
**Scripts:** 1 | **Functions:** 12

### 📄 scripts/components/multi_layer_entity.gd
**Functions:** 12

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_instance_id, str, _create_layer_representations, is_empty, connect

#### `_create_layer_representations()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_debug_representation

#### `_create_debug_representation()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new, add_to_layer

#### `_physics_process(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, distance_to, size, _update_debug_layer, _update_text_layer

#### `_update_text_layer()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_layer_visible, add_text_entity, get, has_method

#### `_update_map_layer()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_layer_visible, Vector2, lerp, clamp, update_height_map

#### `_update_debug_layer()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** normalized, is_layer_visible, size, has_method, add_debug_line

#### `_on_layer_visibility_changed(layer: int, visible: bool)`
- **Purpose:** Function in multi_layer_entity system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_debug_layer, _update_text_layer, clear_debug_draw, _update_map_layer

#### `set_text_state(state: String)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`

#### `set_map_icon(icon: String, color: Color = Color.WHITE)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`

#### `add_debug_marker(offset: Vector3, color: Color, label: String = "")`
- **Purpose:** Function in multi_layer_entity system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_layer_visible, add_debug_point

#### `get_layer_representation(layer: int)`
- **Purpose:** Retrieve data or property value
- **Lines:** 12
- **Returns:** `Variant`

---

## Debug & Testing
**Scripts:** 4 | **Functions:** 25

### 📄 scripts/debug/ragdoll_debug_visualizer.gd
**Functions:** 14

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_materials, print, set_process

#### `_create_materials()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new

#### `set_ragdoll(ragdoll: Node3D)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, print, get_node

#### `_process(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _visualize_walker_state, _clear_debug_elements, get_meta, _visualize_joints, _visualize_center_of_mass

#### `_clear_debug_elements()`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, queue_free

#### `_visualize_joints(body_parts: Dictionary)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, _draw_line

#### `_visualize_center_of_mass(body_parts: Dictionary)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, _create_label, _draw_sphere

#### `_visualize_velocities(body_parts: Dictionary)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, _create_label, length, _draw_line

#### `_visualize_walker_state()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_status, _create_label, get_meta, Vector3, get

#### `_visualize_support_polygon(body_parts: Dictionary)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get, _draw_line, _draw_sphere

#### `_draw_line(start: Vector3, end: Vector3, material: Material, thickness: float = 0.02)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, rotate_object_local, distance_to, add_child, look_at

#### `_draw_sphere(position: Vector3, radius: float, material: Material)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, new, add_child

#### `_create_label(position: Vector3, text: String, color: Color)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, new, add_child

#### `toggle_debug_option(option: String)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 31
- **Returns:** `String`
- **Key Calls:** str

---

### 📄 scripts/debug/ragdoll_physics_test.gd
**Functions:** 9

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `test_configuration(config_name: String)`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, keys, get_tree, str, print

#### `_apply_config_to_ragdoll(config: Dictionary)`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_rigid_bodies_recursive, size, str, print, has

#### `_find_rigid_bodies_recursive(node: Node, bodies: Array)`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _find_rigid_bodies_recursive, get_children

#### `show_physics_info()`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, _find_rigid_bodies_recursive, get_tree, str, print

#### `adjust_single_property(property: String, value: float)`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, _find_rigid_bodies_recursive, get_tree, str, print

#### `run_movement_test()`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, get_tree, str, print

#### `compare_all_configs()`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, print, to_upper

#### `handle_physics_command(args: Array)`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 27
- **Returns:** `String`
- **Key Calls:** float, size, compare_all_configs, show_physics_info, test_configuration

---

### 📄 scripts/debug/movement_test.gd
**Functions:** 1

#### `test_movement_stacking()`
- **Purpose:** Function in movement_test system
- **Lines:** 58
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, execute_movement_command, get_tree, create_timer, print

---

### 📄 scripts/debug/universal_entity_debug.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 84
- **Returns:** `void`
- **Key Calls:** exists, get_tree, get_script, print, str

---

## Deprecated/Archive
**Scripts:** 5 | **Functions:** 50

### 📄 scripts/old_implementations/stable_ragdoll.gd
**Functions:** 14

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_stable_ragdoll, set_physics_process

#### `_create_stable_ragdoll()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, Vector3, Color, add_to_group, add_child

#### `_create_leg(is_left: bool)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, Vector3, Color, bind, add_child

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** normalized, _process_dialogue, length, _process_walking

#### `_process_walking(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_central_impulse

#### `_process_dialogue(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, emit_signal, show_dialogue, size, Vector3
- **Signals:** dialogue_spoken

#### `_on_body_collision(other_body: Node)`
- **Purpose:** Function in stable_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, show_dialogue, Vector3, size, is_in_group

#### `_on_head_collision(other_body: Node)`
- **Purpose:** Function in stable_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, Vector3, is_in_group

#### `_on_leg_collision(other_body: Node, is_left: bool)`
- **Purpose:** Function in stable_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, is_in_group

#### `start_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, Vector3

#### `stop_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, Vector3

#### `toggle_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start_walking, stop_walking

#### `set_walk_speed(speed: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, Vector3, str, clamp

#### `get_body()`
- **Purpose:** Retrieve data or property value
- **Lines:** 3
- **Returns:** `RigidBody3D`

---

### 📄 scripts/old_implementations/ragdoll_with_legs.gd
**Functions:** 13

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_to_group, set_physics_process, _create_ragdoll_parts, _setup_joints, _apply_materials

#### `_create_ragdoll_parts()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, new, add_child

#### `_setup_joints()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_param_x, Vector3, set_param_z, add_child, get_path

#### `_apply_materials()`
- **Purpose:** Function in ragdoll_with_legs system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, new, get_child

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _check_balance, _apply_walking_forces, _update_walk_cycle

#### `_update_walk_cycle(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _stumble, randf

#### `_apply_walking_forces()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, apply_central_force, sin

#### `_check_balance()`
- **Purpose:** Maintain ragdoll balance and stability
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_torque, Vector3

#### `_stumble()`
- **Purpose:** Function in ragdoll_with_legs system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, has_method, randf_range, apply_central_impulse, call

#### `start_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`

#### `stop_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`

#### `set_walk_speed(speed: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clamp

#### `get_body()`
- **Purpose:** Retrieve data or property value
- **Lines:** 2
- **Returns:** `RigidBody3D`

---

### 📄 scripts/old_implementations/talking_ragdoll.gd
**Functions:** 13

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_contact_monitor, set_angular_damp, Vector3, randf_range, set_gravity_scale

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, _get_mouse_world_position, randf_range, set_gravity_scale, look_at

#### `_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_action_released, distance_to, Vector3, _get_mouse_world_position, randf_range

#### `_get_mouse_world_position()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Vector3`
- **Key Calls:** get_viewport, project_ray_normal, Plane, get_world_3d, get_mouse_position

#### `_say_something(category: String)`
- **Purpose:** Function in talking_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, create_timer, get_tree, size, print

#### `_on_body_entered(body: Node)`
- **Purpose:** Function in talking_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randf_range, take_damage, length, set_action_state, _say_something

#### `set_floppiness(factor: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_angular_damp, _say_something, set_linear_damp, clamp

#### `_say_something_custom(text: String)`
- **Purpose:** Function in talking_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_timer, get_tree, connect, print

#### `_setup_blink_animation()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, find_child, add_child, print, has_signal

#### `_on_blink_started()`
- **Purpose:** Function in talking_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _say_something_custom, size, randi, randf

#### `_setup_visual_indicators()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** setup_indicator, print, add_child, has_method, set_script

#### `set_action_state(action: String)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** update_status, has_method

#### `take_damage(amount: float)`
- **Purpose:** Function in talking_ragdoll system
- **Lines:** 13
- **Returns:** `void`
- **Key Calls:** _say_something_custom, max, update_health, has_method

---

### 📄 scripts/old_implementations/simple_walking_ragdoll.gd
**Functions:** 10

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_simple_ragdoll

#### `_create_simple_ragdoll()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_simple_leg, Vector3, Color, add_child, new

#### `_create_simple_leg(is_left: bool)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Color, add_child, get_path, new

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** dot, randf_range, _speak_random_dialogue, apply_central_force, _take_step

#### `_take_step()`
- **Purpose:** Function in simple_walking_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_central_impulse

#### `_speak_random_dialogue()`
- **Purpose:** Function in simple_walking_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, show_dialogue, Vector3, size, print

#### `start_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, Vector3

#### `stop_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, Vector3

#### `toggle_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start_walking, stop_walking

#### `get_body()`
- **Purpose:** Retrieve data or property value
- **Lines:** 2
- **Returns:** `RigidBody3D`

---

## Development Tools
**Scripts:** 3 | **Functions:** 17

### 📄 scripts/tools/script_migration_helper.gd
**Functions:** 12

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `scan_all_scripts()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** clear, size, print, _scan_directory

#### `_scan_directory(path: String)`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** ends_with, list_dir_begin, _analyze_script, get_next, begins_with

#### `_analyze_script(script_path: String)`
- **Purpose:** Function in script_migration_helper system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _process, close, get_as_text, open

#### `generate_migration_plan(script_analysis: Dictionary)`
- **Purpose:** Function in script_migration_helper system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** _process, get_file, register_process, _ready, to_lower

#### `auto_migrate_script(script_path: String)`
- **Purpose:** Function in script_migration_helper system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** compile, register_process, sub, print, open

#### `migrate_all_scripts()`
- **Purpose:** Function in script_migration_helper system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, print, scan_all_scripts, auto_migrate_script, emit

#### `get_migration_report()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** size, get_file, get_datetime_string_from_system

#### `register_console_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, get_node_or_null

#### `_cmd_scan_scripts(_args: Array)`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, get_node, scan_all_scripts

#### `_cmd_show_report(_args: Array)`
- **Purpose:** Function in script_migration_helper system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, get_node, scan_all_scripts, get_file

#### `_cmd_migrate_all(_args: Array)`
- **Purpose:** Function in script_migration_helper system
- **Lines:** 4
- **Returns:** `void`
- **Key Calls:** _print_to_console, get_node, migrate_all_scripts

---

### 📄 scripts/tools/optimize_autoloads.gd
**Functions:** 3

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, analyze_autoloads

#### `analyze_autoloads()`
- **Purpose:** Function in optimize_autoloads system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, Unknown, Essential, get_tree, get_script

#### `disable_heavy_autoloads()`
- **Purpose:** Function in optimize_autoloads system
- **Lines:** 17
- **Returns:** `void`
- **Key Calls:** set_process, get_tree, print, set_physics_process, has_method

---

### 📄 scripts/tools/organize_project_files.gd
**Functions:** 2

#### `organize_files()`
- **Purpose:** Function in organize_project_files system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _move_files_to_folder, print, dir_exists, make_dir, open

#### `_move_files_to_folder(dir: DirAccess, files: Array, target_folder: String)`
- **Purpose:** Function in organize_project_files system
- **Lines:** 11
- **Returns:** `void`
- **Key Calls:** s, file_exists, print, rename

---

## Passive Mode Systems
**Scripts:** 7 | **Functions:** 163

### 📄 scripts/passive_mode/autonomous_developer.gd
**Functions:** 38

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start_passive_mode, _load_state

#### `start_passive_mode()`
- **Purpose:** Function in autonomous_developer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, set_process, print, _log_activity, _change_state

#### `stop_passive_mode()`
- **Purpose:** Function in autonomous_developer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process, _save_state, print, _log_activity, _change_state

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_testing, _process_idle, _process_committing, _process_documenting, _check_limits

#### `_check_limits()`
- **Purpose:** Function in autonomous_developer system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** emit_signal, float, get_ticks_msec, _log_activity
- **Signals:** token_limit_approaching

#### `_process_idle()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _generate_passive_tasks, is_empty, _change_state

#### `_process_planning()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_task_plan, get_ticks_msec, _log_activity, _change_state, get

#### `_process_coding()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _change_state, _log_activity, _complete_task, _execute_coding_task, get

#### `_process_testing()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _run_tests, _complete_task, _log_activity, _revert_changes, _change_state

#### `_process_documenting()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _change_state, _update_documentation

#### `_process_reviewing()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _requires_approval, _complete_task, _log_activity, _queue_for_approval, _change_state

#### `_process_committing()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_version, _complete_task, get, _commit_changes

#### `_process_resting()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, _generate_daily_report, _save_state, _check_limits, _change_state

#### `_select_next_task()`
- **Purpose:** Function in autonomous_developer system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** is_empty, pop_front, get, sort_custom

#### `_generate_passive_tasks()`
- **Purpose:** Function in autonomous_developer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, append_array

*... and 23 more functions*

---

### 📄 scripts/passive_mode/threaded_test_system.gd
**Functions:** 29

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _initialize_test_containers, set_process

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _start_next_zone, is_empty, _should_start_new_zone, _process_tests_this_frame

#### `_initialize_test_containers()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _get_test_dependencies

#### `_get_test_dependencies(feature: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`

#### `start_zone_test(zone: String)`
- **Purpose:** Function in threaded_test_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, size, str, print, has

#### `_dependencies_met(feature: String)`
- **Purpose:** Function in threaded_test_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** get

#### `_process_tests_this_frame()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_test_step, size, _check_zone_completion

#### `_process_test_step(feature: String, container: Dictionary)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get, print, _run_feature_test

#### `_run_feature_test(feature: String)`
- **Purpose:** Function in threaded_test_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** _test_version_control, _test_dialogue_system, _test_astral_beings, _test_ragdoll_walking, _test_ragdoll_physics

#### `_test_console_system()`
- **Purpose:** Function in threaded_test_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_node_or_null, has_method

#### `_test_physics_system()`
- **Purpose:** Function in threaded_test_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_node_or_null, has_method

#### `_test_object_spawning()`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_node_or_null, has_method

#### `_test_ragdoll_physics()`
- **Purpose:** Function in threaded_test_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_nodes_in_group, get_tree, has_method, is_empty, get_node_or_null

#### `_test_ragdoll_walking()`
- **Purpose:** Function in threaded_test_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_tree, is_empty, get_nodes_in_group, has_method

#### `_test_scene_loading()`
- **Purpose:** Function in threaded_test_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** list_available_scenes, size, str, has_method, get_node_or_null

*... and 14 more functions*

---

### 📄 scripts/passive_mode/version_backup_system.gd
**Functions:** 28

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _ensure_backup_directory, _load_version_history

#### `run_test_suite()`
- **Purpose:** Function in version_backup_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** append, emit_signal, print, has, _test_feature
- **Signals:** test_completed, feature_status_changed

#### `_test_feature(feature: String)`
- **Purpose:** Function in version_backup_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** _test_version_control, _test_dialogue_system, _test_astral_beings, _test_ragdoll_walking, _test_ragdoll_physics

#### `_test_console_system()`
- **Purpose:** Function in version_backup_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_node_or_null, has_method

#### `_test_object_spawning()`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** size, create_tree, get_node_or_null, has_method

#### `_test_ragdoll_physics()`
- **Purpose:** Function in version_backup_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_body, get_nodes_in_group, get_tree, has_method, is_empty

#### `_test_ragdoll_walking()`
- **Purpose:** Function in version_backup_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_tree, is_empty, get_nodes_in_group, has_method

#### `_test_scene_loading()`
- **Purpose:** Function in version_backup_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** list_available_scenes, size, str, has_method, get_node_or_null

#### `_test_scene_saving()`
- **Purpose:** Function in version_backup_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_node_or_null, has_method

#### `_test_dialogue_system()`
- **Purpose:** Function in version_backup_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_node_or_null, has_method

#### `_test_astral_beings()`
- **Purpose:** Function in version_backup_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_node_or_null, has_method

#### `_test_passive_mode()`
- **Purpose:** Function in version_backup_system system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** has_node, get_node_or_null

#### `_test_version_control()`
- **Purpose:** Function in version_backup_system system
- **Lines:** 0
- **Returns:** `Dictionary`

#### `_create_version_backup(test_results: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, duplicate, close, _get_files_snapshot, emit_signal
- **Signals:** version_backed_up

#### `_get_files_snapshot()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_datetime_string_from_system

*... and 13 more functions*

---

### 📄 scripts/passive_mode/multi_project_manager.gd
**Functions:** 24

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, _initialize_todo_lists, _load_project_data, set_process

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _on_user_timeout

#### `start_waiting_for_user()`
- **Purpose:** Function in multi_project_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, print

#### `user_responded()`
- **Purpose:** Function in multi_project_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, str, print

#### `_on_user_timeout()`
- **Purpose:** Function in multi_project_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, str, print, _start_background_work, reached
- **Signals:** user_timeout_reached

#### `_start_background_work()`
- **Purpose:** Function in multi_project_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, _select_background_project, _perform_background_tasks, switch_project
- **Signals:** background_work_started

#### `_select_background_project()`
- **Purpose:** Function in multi_project_manager system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, is_empty, _priority_value, sort_custom

#### `_priority_value(priority: String)`
- **Purpose:** Function in multi_project_manager system
- **Lines:** 0
- **Returns:** `int`

#### `_perform_background_tasks()`
- **Purpose:** Function in multi_project_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _execute_background_task, get_project_todos, filter, is_empty, get

#### `_execute_background_task(task: Dictionary)`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, emit_signal, print, _update_documentation, _research_feature
- **Signals:** task_completed_in_background

#### `switch_project(project_id: String)`
- **Purpose:** Function in multi_project_manager system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** has, get_ticks_msec, print, emit_signal
- **Signals:** project_switched

#### `get_project_todos(project_id: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** has

#### `add_task_to_project(project_id: String, task: Dictionary)`
- **Purpose:** Function in multi_project_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, get_project_todos, get_ticks_msec, append

#### `get_current_project_status()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** size, get_project_todos, filter

#### `get_all_projects_status()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** size, get_ticks_msec, get_project_todos, filter

*... and 9 more functions*

---

### 📄 scripts/passive_mode/workflow_manager.gd
**Functions:** 22

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _load_workflow_state

#### `create_feature_branch(branch_name: String, description: String = "")`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** has, _log_workflow, get_datetime_string_from_system, emit_signal
- **Signals:** branch_created

#### `switch_branch(branch_name: String)`
- **Purpose:** Function in workflow_manager system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** has, _log_workflow

#### `track_change(file_path: String, change_type: ChangeType, content: String = "")`
- **Purpose:** Function in workflow_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, get_ticks_msec

#### `commit_changes(message: String, author: String = "Autonomous Developer")`
- **Purpose:** Function in workflow_manager system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, duplicate, _allow_direct_main_commit, get_datetime_string_from_system, _reset_change_summary
- **Signals:** changes_committed

#### `create_merge_request(title: String, description: String = "")`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, duplicate, emit_signal, size, str
- **Signals:** merge_requested

#### `review_merge_request(mr_id: String, approved: bool, comments: String = "")`
- **Purpose:** Function in workflow_manager system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** append, has, _log_workflow, get_datetime_string_from_system, _find_merge_request

#### `merge_branch(mr_id: String)`
- **Purpose:** Function in workflow_manager system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** emit_signal, _bump_version, append_array, _perform_merge, _log_workflow
- **Signals:** merge_completed

#### `_perform_merge(source: String, target: String)`
- **Purpose:** Function in workflow_manager system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** is_empty, _check_conflicts

#### `_check_conflicts(source: String, target: String)`
- **Purpose:** Function in workflow_manager system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** has, get, append

#### `_bump_version(merge_request: Dictionary)`
- **Purpose:** Function in workflow_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, str, _log_workflow, to_lower, int
- **Signals:** version_released

#### `get_workflow_status()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** size, _get_open_merge_requests, get, keys

#### `get_change_diff(branch: String = "")`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** str, is_empty, _get_change_symbol, get

#### `_get_change_symbol(type: ChangeType)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

#### `_find_merge_request(mr_id: String)`
- **Purpose:** Function in workflow_manager system
- **Lines:** 0
- **Returns:** `Dictionary`

*... and 7 more functions*

---

### 📄 scripts/passive_mode/passive_mode_controller.gd
**Functions:** 21

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, preload, new, add_child

#### `start_passive_mode()`
- **Purpose:** Function in passive_mode_controller system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** start_passive_mode

#### `stop_passive_mode()`
- **Purpose:** Function in passive_mode_controller system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** stop_passive_mode

#### `get_status()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_status, size, str, get_workflow_status, _state_to_string

#### `add_task(name: String, priority: String = "medium")`
- **Purpose:** Function in passive_mode_controller system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** _parse_priority, _infer_task_type, add_task

#### `create_branch(branch_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** create_feature_branch

#### `switch_branch(branch_name: String)`
- **Purpose:** Function in passive_mode_controller system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** switch_branch

#### `commit(message: String)`
- **Purpose:** Function in passive_mode_controller system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** commit_changes

#### `create_mr(title: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** create_merge_request

#### `approve_mr(mr_id: String)`
- **Purpose:** Function in passive_mode_controller system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** review_merge_request

#### `merge(mr_id: String)`
- **Purpose:** Function in passive_mode_controller system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** merge_branch, get

#### `show_diff()`
- **Purpose:** Function in passive_mode_controller system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_change_diff

#### `set_token_budget(budget: int)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** str

#### `set_auto_commit(enabled: bool)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `String`

#### `set_require_approval(enabled: bool)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `String`

*... and 6 more functions*

---

### 📄 scripts/passive_mode/passive_mode_test.gd
**Functions:** 1

#### `run_test()`
- **Purpose:** Function in passive_mode_test system
- **Lines:** 38
- **Returns:** `void`
- **Key Calls:** stop_passive_mode, get_status, switch_branch, preload, print

---

## Patches & Fixes
**Scripts:** 27 | **Functions:** 215

### 📄 scripts/patches/floodgate_console_bridge.gd
**Functions:** 32

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** push_error, get_tree, print, _register_floodgate_commands, get_node_or_null

#### `_register_floodgate_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command

#### `_cmd_create_node(args: Array)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** queue_operation, Vector3, size, float, _print

#### `_cmd_delete_node(args: Array)`
- **Purpose:** Function in floodgate_console_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, size, queue_operation

#### `_cmd_duplicate_node(args: Array)`
- **Purpose:** Function in floodgate_console_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** queue_operation, Vector3, size, float, get_parent

#### `_cmd_move_node(args: Array)`
- **Purpose:** Function in floodgate_console_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** queue_operation, Vector3, size, float, _print

#### `_cmd_rotate_node(args: Array)`
- **Purpose:** Function in floodgate_console_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** queue_operation, Vector3, size, float, deg_to_rad

#### `_cmd_scale_node(args: Array)`
- **Purpose:** Function in floodgate_console_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** queue_operation, Vector3, size, float, _print

#### `_cmd_reparent_node(args: Array)`
- **Purpose:** Function in floodgate_console_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, size, queue_operation

#### `_cmd_set_property(args: Array)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** queue_operation, Vector3, size, _parse_value, _print

#### `_cmd_get_property(args: Array)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, str, has_method, _print, get

#### `_cmd_list_properties(args: Array)`
- **Purpose:** Function in floodgate_console_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_property_list, size, str, has, _print

#### `_cmd_call_method(args: Array)`
- **Purpose:** Function in floodgate_console_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, queue_operation, size, _parse_value, range

#### `_cmd_list_methods(args: Array)`
- **Purpose:** Function in floodgate_console_bridge system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, get_method_list, has, _print, get_node_or_null

#### `_cmd_connect_signal(args: Array)`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, size, queue_operation

*... and 17 more functions*

---

### 📄 scripts/patches/advanced_inspector_integration.gd
**Functions:** 28

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_integration

#### `_setup_integration()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_advanced_inspector, get_tree, print, _create_scene_editor, _register_advanced_commands

#### `_create_advanced_inspector()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, exists, get_tree, preload, print

#### `_create_scene_editor()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** exists, preload, print, add_child, new

#### `_register_advanced_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, object, print, has_method, inspector

#### `_cmd_inspect(args: Array)`
- **Purpose:** Function in advanced_inspector_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, _find_object_by_name, mouse, size, selected

#### `_cmd_inspector_control(args: Array)`
- **Purpose:** Function in advanced_inspector_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** hide, _print_to_console, size, show

#### `_cmd_edit_property(args: Array)`
- **Purpose:** Function in advanced_inspector_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, _update_properties_tab, size, str, _parse_value

#### `_cmd_select(args: Array)`
- **Purpose:** Function in advanced_inspector_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, get_nodes_in_group, _deselect_all, _select_object, size

#### `_cmd_select_all(args: Array)`
- **Purpose:** Function in advanced_inspector_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _cmd_select_all

#### `_cmd_deselect(args: Array)`
- **Purpose:** Function in advanced_inspector_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _cmd_deselect

#### `_cmd_show_selection(args: Array)`
- **Purpose:** Function in advanced_inspector_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, Selection, size, str, get_class

#### `_cmd_set_position(args: Array)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, size, _cmd_move

#### `_cmd_set_rotation(args: Array)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _cmd_rotate, _print_to_console, size

#### `_cmd_set_scale(args: Array)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, size, _cmd_scale

*... and 13 more functions*

---

### 📄 scripts/patches/console_layer_integration.gd
**Functions:** 14

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, _register_layer_commands, print, get_node_or_null

#### `_register_layer_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, push_error

#### `_cmd_layer(args: Array)`
- **Purpose:** Function in console_layer_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_layer_action, _print, size, values

#### `_apply_layer_action(layer: int, action: String, name: String)`
- **Purpose:** Function in console_layer_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** toggled, toggle_layer, is_layer_visible, set_layer_visibility, _print

#### `_cmd_layers(_args: Array)`
- **Purpose:** Function in console_layer_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** F4, is_layer_visible, str, range, _print

#### `_cmd_reality(_args: Array)`
- **Purpose:** Function in console_layer_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, cycle_view_mode, _get_view_mode_name

#### `_cmd_debug_point(args: Array)`
- **Purpose:** Function in console_layer_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _parse_color, Vector3, size, float, str

#### `_cmd_debug_line(args: Array)`
- **Purpose:** Function in console_layer_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _parse_color, Vector3, size, float, add_debug_line

#### `_cmd_debug_clear(_args: Array)`
- **Purpose:** Function in console_layer_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, clear_debug_draw

#### `_cmd_world_view(args: Array)`
- **Purpose:** Function in console_layer_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, is_empty

#### `_cmd_map_view(args: Array)`
- **Purpose:** Function in console_layer_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, is_empty

#### `_print(text: String)`
- **Purpose:** Function in console_layer_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, print, has_method

#### `_get_view_mode_name()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

#### `_parse_color(color_str: String)`
- **Purpose:** Function in console_layer_integration system
- **Lines:** 23
- **Returns:** `Color`
- **Key Calls:** Color, to_lower, begins_with

---

### 📄 scripts/patches/console_spam_filter.gd
**Functions:** 14

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, print, add_child, new, setup_console_commands

#### `should_show_message(message: String)`
- **Purpose:** Determine if action should be taken
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** get_unix_time_from_system, _get_message_key, _apply_filtering_rules, str, has

#### `_get_message_key(message: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** substr, keys, begins_with

#### `_get_message_priority(message: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `MessagePriority`
- **Key Calls:** keys, begins_with

#### `_apply_filtering_rules(message_key: String, priority: MessagePriority, time_since_last: float, current_time: float)`
- **Purpose:** Function in console_spam_filter system
- **Lines:** 0
- **Returns:** `bool`

#### `_cleanup_old_messages()`
- **Purpose:** Function in console_spam_filter system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_unix_time_from_system, keys, erase, append

#### `filter_message(message: String)`
- **Purpose:** Function in console_spam_filter system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** should_show_message

#### `get_filter_stats()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** _count_total_suppressions, size

#### `_count_total_suppressions()`
- **Purpose:** Function in console_spam_filter system
- **Lines:** 0
- **Returns:** `int`
- **Key Calls:** values

#### `setup_console_commands()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, has_method

#### `_cmd_filter_stats(_args: Array)`
- **Purpose:** Function in console_spam_filter system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** keys, is_empty, str, get_filter_stats, _print

#### `_cmd_filter_reset(_args: Array)`
- **Purpose:** Function in console_spam_filter system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, _print

#### `_cmd_filter_config(args: Array)`
- **Purpose:** Function in console_spam_filter system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, size, str, int

#### `_print(text: String)`
- **Purpose:** Function in console_spam_filter system
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** _print_to_console, print

---

### 📄 scripts/patches/ragdoll_neural_integration.gd
**Functions:** 14

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _scan_integration_status, print, _register_neural_commands

#### `_register_neural_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, get_node_or_null

#### `_scan_integration_status()`
- **Purpose:** Check if operation is possible
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** file_exists, print

#### `copy_neural_files()`
- **Purpose:** Function in ragdoll_neural_integration system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** file_exists, size, print, copy, open

#### `enhance_biomechanical_walker()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _add_health_indicators, get_nodes_in_group, _add_emotional_colors, _migrate_to_perfect_delta, get_tree

#### `_add_blinking_to_ragdoll(ragdoll: Node)`
- **Purpose:** Function in ragdoll_neural_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, print, add_child, new, load

#### `_add_health_indicators(ragdoll: Node)`
- **Purpose:** Function in ragdoll_neural_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, print, add_child, new, load

#### `_add_emotional_colors(ragdoll: Node)`
- **Purpose:** Function in ragdoll_neural_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, print, add_child, new, load

#### `_migrate_to_perfect_delta(ragdoll: Node)`
- **Purpose:** Function in ragdoll_neural_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_process, print, set_physics_process, has_method, get_node_or_null

#### `spawn_perfect_ragdoll()`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** _add_health_indicators, emit, _add_emotional_colors, _migrate_to_perfect_delta, get_tree

#### `_cmd_activate_neural(_args: Array)`
- **Purpose:** Function in ragdoll_neural_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_to_console, get_node, enhance_biomechanical_walker, copy_neural_files

#### `_cmd_neural_status(_args: Array)`
- **Purpose:** Function in ragdoll_neural_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _scan_integration_status, _print_to_console, get_node

#### `_cmd_copy_neural_files(_args: Array)`
- **Purpose:** Function in ragdoll_neural_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _scan_integration_status, _print_to_console, get_node, copy_neural_files

#### `_cmd_spawn_perfect_ragdoll(_args: Array)`
- **Purpose:** Instantiate object in the game world
- **Lines:** 13
- **Returns:** `void`
- **Key Calls:** _print_to_console, get_node, spawn_perfect_ragdoll

---

### 📄 scripts/patches/unified_walker_commands.gd
**Functions:** 11

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_walker_commands, get_tree, print, get_node_or_null

#### `_register_walker_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, push_error, print, has_method

#### `_cmd_spawn_walker(args: Array)`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, float, Vector3, size, get_tree

#### `_cmd_walker_speed(args: Array)`
- **Purpose:** Function in unified_walker_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_empty, float, set_walk_speed, str, _print

#### `_cmd_walker_teleport(args: Array)`
- **Purpose:** Function in unified_walker_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, size, teleport_to, float, str

#### `_cmd_walker_info(args: Array)`
- **Purpose:** Function in unified_walker_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, str, get_debug_info

#### `_cmd_walker_destroy(args: Array)`
- **Purpose:** Clean up and remove object/component
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, queue_free

#### `_cmd_walker_debug(args: Array)`
- **Purpose:** Function in unified_walker_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Torso, is_empty, Feet, Legs, to_lower

#### `_on_step_completed(foot: String)`
- **Purpose:** Function in unified_walker_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print

#### `_on_phase_changed(leg: String, phase: String)`
- **Purpose:** Function in unified_walker_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print

#### `_print(message: String)`
- **Purpose:** Function in unified_walker_commands system
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** _print_to_console, print, has_method

---

### 📄 scripts/patches/biomechanical_walker_commands.gd
**Functions:** 10

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_walker_commands, get_tree, print, get_node_or_null

#### `_register_walker_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, push_error, print, has_method

#### `_cmd_spawn_biowalker(args: Array)`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_walker, float, Vector3, size, get_tree

#### `_cmd_walker_speed(args: Array)`
- **Purpose:** Function in biomechanical_walker_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** float, size, str, set_walk_speed, _print

#### `_cmd_walker_phase(_args: Array)`
- **Purpose:** Function in biomechanical_walker_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, str, is_foot_on_ground, get_current_phase

#### `_cmd_walker_debug(args: Array)`
- **Purpose:** Function in biomechanical_walker_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** handle_console_command, _print, is_empty

#### `_cmd_walker_params(args: Array)`
- **Purpose:** Function in biomechanical_walker_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, float, _print, str

#### `_cmd_walker_teleport(args: Array)`
- **Purpose:** Function in biomechanical_walker_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, size, str, float, _print

#### `_cmd_walker_freeze(args: Array)`
- **Purpose:** Function in biomechanical_walker_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, _print

#### `_print(text: String)`
- **Purpose:** Function in biomechanical_walker_commands system
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** _print_to_console, print, has_method

---

### 📄 scripts/patches/console_command_extension.gd
**Functions:** 10

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_signal_connection_list, push_error, get_tree, print, get_object

#### `_find_and_hook_input_field(node: Node)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, is_connected, get_children, _find_and_hook_input_field, connect

#### `_on_extended_input_submitted(text: String)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, _on_input_submitted, print, _cmd_spawn_biowalker, to_lower

#### `_clear_input_field()`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _clear_input_recursive

#### `_clear_input_recursive(node: Node)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _clear_input_recursive, get_children

#### `_cmd_spawn_biowalker(args: Array)`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, size, float, get_tree, add_child

#### `_cmd_walker_debug(args: Array)`
- **Purpose:** Function in console_command_extension system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, str

#### `_cmd_layers(args: Array)`
- **Purpose:** Function in console_command_extension system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, Console, get_node_or_null

#### `_cmd_layer(args: Array)`
- **Purpose:** Function in console_command_extension system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, size, get_node_or_null

#### `_print(text: String)`
- **Purpose:** Function in console_command_extension system
- **Lines:** 4
- **Returns:** `void`
- **Key Calls:** _print_to_console, has_method

---

### 📄 scripts/patches/gizmo_direct_interaction_fix.gd
**Functions:** 10

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process_unhandled_input, print, call_deferred

#### `_setup_gizmo_fix()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _ensure_gizmo_collision_layers, find_gizmo_system, create_timer, get_tree, print

#### `_ensure_gizmo_collision_layers()`
- **Purpose:** Function in gizmo_direct_interaction_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, get_tree, print, get_nodes_in_group

#### `_unhandled_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _on_mouse_pressed, _on_mouse_released, _on_mouse_dragged

#### `_on_mouse_pressed(mouse_pos: Vector2)`
- **Purpose:** Function in gizmo_direct_interaction_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, get_first_node_in_group, _handle_gizmo_click, get_tree, print

#### `_on_mouse_released()`
- **Purpose:** Function in gizmo_direct_interaction_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _end_drag, has_method

#### `_on_mouse_dragged(mouse_pos: Vector2)`
- **Purpose:** Function in gizmo_direct_interaction_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_drag, has_method

#### `_raycast_for_gizmo(mouse_pos: Vector2)`
- **Purpose:** Function in gizmo_direct_interaction_fix system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_viewport, project_ray_normal, get_world_3d, print, get_camera_3d

#### `cmd_debug_gizmo_collisions()`
- **Purpose:** Function in gizmo_direct_interaction_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, print

#### `cmd_list_gizmo_components()`
- **Purpose:** Function in gizmo_direct_interaction_fix system
- **Lines:** 9
- **Returns:** `void`
- **Key Calls:** get_nodes_in_group, get_tree, size, components, print

---

### 📄 scripts/patches/console_ui_fix.gd
**Functions:** 9

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_console_fixes, get_tree

#### `_apply_console_fixes()`
- **Purpose:** Function in console_ui_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, print, _fix_console_sizing, connect, get_node_or_null

#### `_fix_console_sizing()`
- **Purpose:** Function in console_ui_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, _find_node_by_type, add_theme_font_size_override, Vector2, get_child

#### `_center_console()`
- **Purpose:** Function in console_ui_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, Vector2

#### `_find_node_by_type(parent: Node, type_name: String)`
- **Purpose:** Function in console_ui_fix system
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** _find_node_by_type, get_children, get_class

#### `_on_viewport_changed(_new_size: Vector2i)`
- **Purpose:** Function in console_ui_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _fix_console_sizing

#### `_notification(what: int)`
- **Purpose:** Function in console_ui_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, get_tree, has_method

#### `_cmd_fix_console(_args: Array)`
- **Purpose:** Function in console_ui_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _fix_console_sizing, _print_to_console

#### `_cmd_console_scale(args: Array)`
- **Purpose:** Function in console_ui_fix system
- **Lines:** 12
- **Returns:** `void`
- **Key Calls:** _print_to_console, Vector2, float, size, str

---

### 📄 scripts/patches/gizmo_debug_commands.gd
**Functions:** 9

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_debug_commands, print

#### `_register_debug_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, print, get_node_or_null

#### `cmd_gizmo_debug(args: Array)`
- **Purpose:** Function in gizmo_debug_commands system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_first_node_in_group, get_nodes_in_group, get_tree, str, size

#### `cmd_list_gizmo_parts(args: Array)`
- **Purpose:** Function in gizmo_debug_commands system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_nodes_in_group, get_meta, get_parent, size, get_tree

#### `cmd_show_gizmo_layers(args: Array)`
- **Purpose:** Function in gizmo_debug_commands system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_node_or_null

#### `cmd_test_gizmo_click(args: Array)`
- **Purpose:** Function in gizmo_debug_commands system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_viewport, project_ray_normal, get_world_3d, Test, get_meta

#### `cmd_toggle_collision_debug(args: Array)`
- **Purpose:** Function in gizmo_debug_commands system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** size, get_tree

#### `fix_gizmo_layers()`
- **Purpose:** Function in gizmo_debug_commands system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, print, get_nodes_in_group

#### `cmd_test_rotation_fix(args: Array)`
- **Purpose:** Function in gizmo_debug_commands system
- **Lines:** 52
- **Returns:** `String`
- **Key Calls:** get_first_node_in_group, get_nodes_in_group, set_mode, get_tree, str

---

### 📄 scripts/patches/gizmo_system_finder.gd
**Functions:** 8

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_console_commands, print

#### `_register_console_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 10
- **Returns:** `void`
- **Key Calls:** register_command, print, get_node_or_null

#### `cmd_find_gizmo(args: Array)`
- **Purpose:** Function in gizmo_system_finder system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** find_gizmo_system, size, str, has_method, get_path

#### `cmd_gizmo_status(args: Array)`
- **Purpose:** Function in gizmo_system_finder system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_nodes_in_group, find_gizmo_system, get_tree, str, size

#### `cmd_force_show(args: Array)`
- **Purpose:** Function in gizmo_system_finder system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** find_gizmo_system, set_mode, visible, has_method

#### `cmd_gizmo_target(args: Array)`
- **Purpose:** Function in gizmo_system_finder system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** _find_object_by_name, find_gizmo_system, has_method, attach_to_object, is_empty

#### `_find_object_by_name(object_name: String)`
- **Purpose:** Function in gizmo_system_finder system
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** get_tree, _recursive_find_by_name, get_nodes_in_group

#### `_recursive_find_by_name(node: Node, target_name: String)`
- **Purpose:** Function in gizmo_system_finder system
- **Lines:** 11
- **Returns:** `Node3D`
- **Key Calls:** _recursive_find_by_name, get_children

---

### 📄 scripts/patches/add_commands_directly.gd
**Functions:** 6

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** push_error, get_tree, str, print, size

#### `_cmd_spawn_biowalker(args: Array)`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, size, float, get_tree, add_child

#### `_cmd_walker_debug(args: Array)`
- **Purpose:** Function in add_commands_directly system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, str

#### `_cmd_layers(args: Array)`
- **Purpose:** Function in add_commands_directly system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, get_node_or_null

#### `_cmd_layer(args: Array)`
- **Purpose:** Function in add_commands_directly system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print, size

#### `_print(text: String)`
- **Purpose:** Function in add_commands_directly system
- **Lines:** 4
- **Returns:** `void`
- **Key Calls:** _print_to_console, get_node, has_method

---

### 📄 scripts/patches/spawn_limiter.gd
**Functions:** 6

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, connect, print, _count_existing_objects

#### `_count_existing_objects()`
- **Purpose:** Function in spawn_limiter system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, print, get_nodes_in_group, to_lower

#### `_on_node_added(node: Node)`
- **Purpose:** Function in spawn_limiter system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_to_group, print, queue_free, _make_clickable, s

#### `_make_clickable(node: Node3D)`
- **Purpose:** Function in spawn_limiter system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, str, print, set_meta, get_children

#### `reset_counts()`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _count_existing_objects

#### `get_status()`
- **Purpose:** Retrieve data or property value
- **Lines:** 7
- **Returns:** `String`

---

### 📄 scripts/patches/debug_integration_patch.gd
**Functions:** 5

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** push_error, patch_jsh_systems, get_tree, print, patch_console_manager

#### `patch_console_manager(console: Node)`
- **Purpose:** Function in debug_integration_patch system
- **Lines:** 0
- **Returns:** `void`

#### `patch_jsh_systems()`
- **Purpose:** Function in debug_integration_patch system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_verbose, print, get_node_or_null, has_method

#### `add_debug_commands()`
- **Purpose:** Function in debug_integration_patch system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, print, get_node_or_null, _on_console_command

#### `_init()`
- **Purpose:** Function in debug_integration_patch system
- **Lines:** 4
- **Returns:** `void`
- **Key Calls:** set_physics_process, set_process

---

### 📄 scripts/patches/gizmo_comprehensive_diagnostics.gd
**Functions:** 5

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _register_commands, print

#### `_register_commands()`
- **Purpose:** Add to registry or tracking system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, print, get_node_or_null

#### `cmd_full_diagnosis(args: Array)`
- **Purpose:** Function in gizmo_comprehensive_diagnostics system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, get_first_node_in_group, get_nodes_in_group, get_meta, find_gizmo_system

#### `cmd_emergency_fix(args: Array)`
- **Purpose:** Function in gizmo_comprehensive_diagnostics system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, get_nodes_in_group, find_gizmo_system, set_mode, get_tree

#### `cmd_connection_test(args: Array)`
- **Purpose:** Establish connection between systems
- **Lines:** 72
- **Returns:** `String`
- **Key Calls:** get_viewport, append, project_ray_normal, get_nodes_in_group, get_world_3d

---

### 📄 scripts/patches/gizmo_collision_fix.gd
**Functions:** 4

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** call_deferred, print

#### `_fix_gizmo_collisions()`
- **Purpose:** Function in gizmo_collision_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** find_gizmo_system, create_timer, get_tree, print, get_path

#### `_add_collision_to_gizmo(gizmo_being: Node3D, axis: String, mode: String)`
- **Purpose:** Function in gizmo_collision_fix system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, len, print, add_to_group, set_meta

#### `_visualize_collision_shapes(enable: bool = true)`
- **Purpose:** Function in gizmo_collision_fix system
- **Lines:** 4
- **Returns:** `void`
- **Key Calls:** get_tree, print

---

### 📄 scripts/patches/console_debug_overlay.gd
**Functions:** 3

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_theme_font_size_override, Vector2, get_tree, add_child, add_theme_color_override

#### `_process(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_parent, join, str

#### `_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 4
- **Returns:** `void`
- **Key Calls:** queue_free

---

### 📄 scripts/patches/gizmo_perfect_fix.gd
**Functions:** 3

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, get_node_or_null

#### `cmd_perfect_gizmo(args: Array)`
- **Purpose:** Function in gizmo_perfect_fix system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_first_node_in_group, get_nodes_in_group, set_mode, get_tree, size

#### `cmd_gizmo_show(args: Array)`
- **Purpose:** Function in gizmo_perfect_fix system
- **Lines:** 30
- **Returns:** `String`
- **Key Calls:** get_first_node_in_group, set_mode, get_tree, add_child, has_method

---

### 📄 scripts/patches/gizmo_reset_command.gd
**Functions:** 3

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, print, get_node_or_null

#### `cmd_gizmo_reset(args: Array)`
- **Purpose:** Function in gizmo_reset_command system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** get_first_node_in_group, get_tree, print, get_child, add_child

#### `cmd_gizmo_create(args: Array)`
- **Purpose:** Create new instance or object
- **Lines:** 21
- **Returns:** `String`
- **Key Calls:** get_ticks_msec, get_tree, str, get_child, add_child

---

### 📄 scripts/patches/simple_console_test.gd
**Functions:** 3

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, create_timer, get_tree, get_property_list, print

#### `_test_command(_args: Array)`
- **Purpose:** Function in simple_console_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, print

#### `_hello_command(_args: Array)`
- **Purpose:** Function in simple_console_test system
- **Lines:** 4
- **Returns:** `void`
- **Key Calls:** join, size, print

---

### 📄 scripts/patches/debug_test_commands.gd
**Functions:** 2

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** register_command, push_error, get_tree, print, get_method_list

#### `_test_command(args: Array)`
- **Purpose:** Function in debug_test_commands system
- **Lines:** 4
- **Returns:** `void`
- **Key Calls:** _print_to_console, has_node, str, print, get_node

---

### 📄 scripts/patches/universal_console_helper.gd
**Functions:** 2

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_timer, get_tree, _ensure_universal_commands

#### `_ensure_universal_commands()`
- **Purpose:** Function in universal_console_helper system
- **Lines:** 62
- **Returns:** `void`
- **Key Calls:** _cmd_optimize_now, _cmd_list_variables, _print_to_console, _cmd_make_perfect, print

---

### 📄 scripts/patches/console_diagnostic.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 49
- **Returns:** `void`
- **Key Calls:** get_property_list, get_tree, str, print, size

---

### 📄 scripts/patches/delayed_command_injector.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 115
- **Returns:** `void`
- **Key Calls:** _print_to_console, toggle_layer, push_error, create_timer, get_tree

---

### 📄 scripts/patches/scene_command_injector.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 7
- **Returns:** `void`
- **Key Calls:** get_tree, print, add_child, set_script, load

---

### 📄 scripts/patches/universal_quickfix.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 32
- **Returns:** `void`
- **Key Calls:** _cmd_optimize_now, _cmd_list_variables, _cmd_export_variables, create_timer, get_tree

---

## Ragdoll Archive
**Scripts:** 14 | **Functions:** 247

### 📄 copy_ragdoll_all_files/seven_part_ragdoll_integration.gd
**Functions:** 36

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_unix_time_from_system, _connect_to_floodgate, has_node, _setup_seven_part_body, create_timer

#### `_setup_seven_part_body()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, Vector3, _create_joints, add_child, set_meta

#### `_setup_upright_controller()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, add_child, set_script, load, new

#### `_create_body_part(part_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** Vector3, new, add_child

#### `_create_joints(parts: Dictionary)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_knee_joint, _create_ankle_joint, _create_hip_joint

#### `_create_hip_joint(parts: Dictionary, parent_name: String, child_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_param_y, set_flag_z, set_param_x, Vector3, set_param_z

#### `_create_knee_joint(parts: Dictionary, parent_name: String, child_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, add_child, has, set_flag, get_path

#### `_create_ankle_joint(parts: Dictionary, parent_name: String, child_name: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, add_child, has, set_flag, get_path

#### `_connect_to_jsh_framework()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, print, get_node_or_null, has_method

#### `_connect_to_floodgate()`
- **Purpose:** Establish connection between systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, print, get_node_or_null, queue_ragdoll_position_update

#### `_setup_dialogue_system()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, new, add_child, randf_range

#### `_speak_random_phrase()`
- **Purpose:** Function in seven_part_ragdoll_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, print, randi, emit

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_dialogue, _process_walking_movement

#### `_process_walking_movement(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** distance_to, has_node, _handle_target_reached, get_meta, start_walking

#### `come_to_position(pos: Vector3)`
- **Purpose:** Function in seven_part_ragdoll_integration system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, print, emit

*... and 21 more functions*

---

### 📄 copy_ragdoll_all_files/ragdoll_controller.gd
**Functions:** 33

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, _setup_default_patrol, print, _find_ragdoll_body, get_node

#### `_spawn_seven_part_ragdoll()`
- **Purpose:** Instantiate object in the game world
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, get_tree, print, add_child, set_script

#### `_find_ragdoll_body()`
- **Purpose:** Function in ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_nodes_in_group, size, get_tree, print, _spawn_seven_part_ragdoll

#### `_setup_default_patrol()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_investigating, _process_idle, _process_organizing, _process_walking, _process_carrying

#### `_process_idle(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** move_to_object, _find_nearby_objects, move_to_position, size, set_behavior_state

#### `_process_walking(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** distance_to, emit_signal, size, _apply_movement_to_ragdoll, set_behavior_state
- **Signals:** movement_completed

#### `_process_investigating(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_nearby_objects, size, set_behavior_state, attempt_pickup

#### `_process_carrying(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_carried_object_position, set_behavior_state, _look_for_organization_spot

#### `_process_helping(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_process_organizing(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** drop_object_at_position, _find_good_drop_position

#### `_apply_movement_to_ragdoll(_delta: float)`
- **Purpose:** Function in ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_body, normalized, atan2, angle_difference, start_walking

#### `_find_nearby_objects(radius: float = 5.0)`
- **Purpose:** Function in ragdoll_controller system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** append, distance_to, get_nodes_in_group, get_tree, sort_custom

#### `_update_carried_object_position()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`

#### `_look_for_organization_spot()`
- **Purpose:** Function in ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_behavior_state, randf

*... and 18 more functions*

---

### 📄 copy_ragdoll_all_files/dimensional_ragdoll_system.gd
**Functions:** 25

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _initialize_consciousness, _setup_dimensional_physics, print

#### `_setup_dimensional_physics()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`

#### `_initialize_consciousness()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _learn_initial_spells

#### `_learn_initial_spells()`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** learn_spell

#### `shift_dimension(target_dimension: Dimension)`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** keys, _apply_dimensional_effects, emit_signal, float, print
- **Signals:** dimension_changed

#### `_apply_dimensional_effects(dimension: Dimension)`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`

#### `add_consciousness_experience(amount: float, source: String = "")`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, _evolve_to_stage, emit_signal, print
- **Signals:** consciousness_evolved

#### `_get_evolution_stage(level: float)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

#### `_evolve_to_stage(new_stage: String)`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** learn_spell, _update_emotion_state, print

#### `learn_spell(spell_name: String)`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, print, emit_signal
- **Signals:** spell_learned

#### `cast_spell(spell_name: String, target: Node3D = null)`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** add_consciousness_experience, _spell_reality_shift, _spell_float, _spell_glow, print

#### `set_emotion(emotion: String, value: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_emotion_state, clamp

#### `_update_emotion_state()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, s, print
- **Signals:** emotion_changed

#### `process_interaction(interaction_type: String, object: Node3D = null)`
- **Purpose:** Handle ongoing operations or data
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, add_consciousness_experience, get_ticks_msec, set_emotion, _detect_interaction_patterns

#### `_detect_interaction_patterns()`
- **Purpose:** Function in dimensional_ragdoll_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_consciousness_experience, size, print, slice

*... and 10 more functions*

---

### 📄 copy_ragdoll_all_files/simple_ragdoll_walker.gd
**Functions:** 25

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _configure_physics, get_tree, print, set_physics_process, _find_body_parts

#### `_find_body_parts()`
- **Purpose:** Function in simple_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_meta, get_parent, print, get, has_meta

#### `_configure_physics()`
- **Purpose:** Function in simple_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_falling, _process_idle, _process_standing_up, _process_balancing, _update_state

#### `_update_state(_delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _is_on_ground, _is_upright, length, _is_falling

#### `_process_idle()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_process_standing_up()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_upright_torque, Vector3, _apply_leg_straightening_forces, apply_central_force

#### `_process_balancing()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_upright_torque, _maintain_height, _balance_over_feet

#### `_process_stepping(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_upright_torque, _maintain_height, _apply_step_forces

#### `_process_falling()`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _orient_feet_down

#### `_maintain_height()`
- **Purpose:** Function in simple_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_central_force

#### `_apply_upright_torque()`
- **Purpose:** Function in simple_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** normalized, length, apply_torque

#### `_balance_over_feet()`
- **Purpose:** Maintain ragdoll balance and stability
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, apply_central_force, _calculate_center_of_mass

#### `_apply_step_forces()`
- **Purpose:** Function in simple_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _stabilize_foot, apply_central_force

#### `_apply_leg_straightening_forces()`
- **Purpose:** Function in simple_ragdoll_walker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, apply_central_force

*... and 10 more functions*

---

### 📄 copy_ragdoll_all_files/complete_ragdoll_fixed.gd
**Functions:** 18

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, add_to_group, _create_complete_ragdoll, _apply_materials

#### `_create_complete_ragdoll()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_leg, Vector3, new, add_child

#### `_create_leg(side: String, offset: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_param_y, set_param_x, Vector3, set_param_z, add_child

#### `_apply_materials()`
- **Purpose:** Function in complete_ragdoll_fixed system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_child_count, Color, new, get_child

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _maintain_balance, normalized, _update_walk_cycle, length, _apply_walking_forces

#### `_update_walk_cycle(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _stumble, randf

#### `_apply_walking_forces()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** sin, Vector3, has, max, apply_central_force

#### `_maintain_balance()`
- **Purpose:** Maintain ragdoll balance and stability
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_torque, Vector3, abs

#### `_stumble()`
- **Purpose:** Function in complete_ragdoll_fixed system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_central_impulse, Vector3, _say_something, randf_range

#### `start_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _say_something

#### `stop_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _say_something

#### `set_walk_speed(speed: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clamp

#### `set_floppiness(factor: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_param

#### `_say_something(category: String)`
- **Purpose:** Function in complete_ragdoll_fixed system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, size, print, _create_speech_bubble, is_empty

#### `_create_speech_bubble(text: String)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, Vector3, get_tree, create_timer, add_child

*... and 3 more functions*

---

### 📄 copy_ragdoll_all_files/upright_ragdoll_controller.gd
**Functions:** 17

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _store_rest_positions, _configure_physics, _find_body_parts

#### `_find_body_parts()`
- **Purpose:** Function in upright_ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_children

#### `_store_rest_positions()`
- **Purpose:** Function in upright_ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3

#### `_configure_physics()`
- **Purpose:** Function in upright_ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_balance_forces, _process_physics_mode, _process_controlled_mode, _process_blend_mode

#### `_process_controlled_mode(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _maintain_rest_pose, _process_walking, apply_torque, get_euler, apply_central_force

#### `_process_walking(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** sin, Vector3, _apply_rotation_force, length, max

#### `_maintain_rest_pose()`
- **Purpose:** Function in upright_ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get, apply_central_force

#### `_apply_rotation_force(body: RigidBody3D, target_euler: Vector3)`
- **Purpose:** Function in upright_ragdoll_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_torque

#### `_apply_balance_forces()`
- **Purpose:** Maintain ragdoll balance and stability
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, abs, apply_central_force

#### `_process_physics_mode(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_process_blend_mode(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process_controlled_mode

#### `start_walking(direction: Vector3)`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** normalized

#### `stop_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`

#### `set_ragdoll_mode(new_mode: RagdollMode)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`

*... and 2 more functions*

---

### 📄 copy_ragdoll_all_files/ragdoll_debug_visualizer.gd
**Functions:** 14

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_materials, print, set_process

#### `_create_materials()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** new

#### `set_ragdoll(ragdoll: Node3D)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, print, get_node

#### `_process(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _visualize_walker_state, _clear_debug_elements, get_meta, _visualize_joints, _visualize_center_of_mass

#### `_clear_debug_elements()`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clear, queue_free

#### `_visualize_joints(body_parts: Dictionary)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, _draw_line

#### `_visualize_center_of_mass(body_parts: Dictionary)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, _create_label, _draw_sphere

#### `_visualize_velocities(body_parts: Dictionary)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, _create_label, length, _draw_line

#### `_visualize_walker_state()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_status, _create_label, get_meta, Vector3, get

#### `_visualize_support_polygon(body_parts: Dictionary)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get, _draw_line, _draw_sphere

#### `_draw_line(start: Vector3, end: Vector3, material: Material, thickness: float = 0.02)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, rotate_object_local, distance_to, add_child, look_at

#### `_draw_sphere(position: Vector3, radius: float, material: Material)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, new, add_child

#### `_create_label(position: Vector3, text: String, color: Color)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, new, add_child

#### `toggle_debug_option(option: String)`
- **Purpose:** Function in ragdoll_debug_visualizer system
- **Lines:** 31
- **Returns:** `String`
- **Key Calls:** str

---

### 📄 copy_ragdoll_all_files/stable_ragdoll.gd
**Functions:** 14

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_stable_ragdoll, set_physics_process

#### `_create_stable_ragdoll()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, Vector3, Color, add_to_group, add_child

#### `_create_leg(is_left: bool)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, Vector3, Color, bind, add_child

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** normalized, _process_dialogue, length, _process_walking

#### `_process_walking(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_central_impulse

#### `_process_dialogue(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, emit_signal, show_dialogue, size, Vector3
- **Signals:** dialogue_spoken

#### `_on_body_collision(other_body: Node)`
- **Purpose:** Function in stable_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, show_dialogue, Vector3, size, is_in_group

#### `_on_head_collision(other_body: Node)`
- **Purpose:** Function in stable_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, Vector3, is_in_group

#### `_on_leg_collision(other_body: Node, is_left: bool)`
- **Purpose:** Function in stable_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, is_in_group

#### `start_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, Vector3

#### `stop_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, Vector3

#### `toggle_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start_walking, stop_walking

#### `set_walk_speed(speed: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, Vector3, str, clamp

#### `get_body()`
- **Purpose:** Retrieve data or property value
- **Lines:** 3
- **Returns:** `RigidBody3D`

---

### 📄 copy_ragdoll_all_files/complete_ragdoll.gd
**Functions:** 13

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_to_group, _create_complete_ragdoll, _apply_materials, _ready

#### `_create_complete_ragdoll()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_leg, Vector3, new, add_child

#### `_create_leg(side: String, offset: Vector3)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_param_y, set_param_x, Vector3, set_param_z, add_child

#### `_apply_materials()`
- **Purpose:** Function in complete_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, new, get_child

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _maintain_balance, normalized, _update_walk_cycle, length, _physics_process

#### `_update_walk_cycle(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _stumble, randf

#### `_apply_walking_forces()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** sin, Vector3, has, max, apply_central_force

#### `_maintain_balance()`
- **Purpose:** Maintain ragdoll balance and stability
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_torque, Vector3, abs

#### `_stumble()`
- **Purpose:** Function in complete_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_central_impulse, Vector3, _say_something, randf_range

#### `start_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _say_something

#### `stop_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _say_something

#### `set_walk_speed(speed: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clamp

#### `set_floppiness(factor: float)`
- **Purpose:** Assign data or property value
- **Lines:** 8
- **Returns:** `void`
- **Key Calls:** set_param, set_floppiness

---

### 📄 copy_ragdoll_all_files/ragdoll_with_legs.gd
**Functions:** 13

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** add_to_group, set_physics_process, _create_ragdoll_parts, _setup_joints, _apply_materials

#### `_create_ragdoll_parts()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, new, add_child

#### `_setup_joints()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_param_x, Vector3, set_param_z, add_child, get_path

#### `_apply_materials()`
- **Purpose:** Function in ragdoll_with_legs system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, new, get_child

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _check_balance, _apply_walking_forces, _update_walk_cycle

#### `_update_walk_cycle(delta: float)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _stumble, randf

#### `_apply_walking_forces()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, apply_central_force, sin

#### `_check_balance()`
- **Purpose:** Maintain ragdoll balance and stability
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_torque, Vector3

#### `_stumble()`
- **Purpose:** Function in ragdoll_with_legs system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, has_method, randf_range, apply_central_impulse, call

#### `start_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`

#### `stop_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`

#### `set_walk_speed(speed: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** clamp

#### `get_body()`
- **Purpose:** Retrieve data or property value
- **Lines:** 2
- **Returns:** `RigidBody3D`

---

### 📄 copy_ragdoll_all_files/talking_ragdoll.gd
**Functions:** 13

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_contact_monitor, set_angular_damp, Vector3, randf_range, set_gravity_scale

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_viewport, _get_mouse_world_position, randf_range, set_gravity_scale, look_at

#### `_input(event: InputEvent)`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_action_released, distance_to, Vector3, _get_mouse_world_position, randf_range

#### `_get_mouse_world_position()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Vector3`
- **Key Calls:** get_viewport, project_ray_normal, Plane, get_world_3d, get_mouse_position

#### `_say_something(category: String)`
- **Purpose:** Function in talking_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, create_timer, get_tree, size, print

#### `_on_body_entered(body: Node)`
- **Purpose:** Function in talking_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randf_range, take_damage, length, set_action_state, _say_something

#### `set_floppiness(factor: float)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_angular_damp, _say_something, set_linear_damp, clamp

#### `_say_something_custom(text: String)`
- **Purpose:** Function in talking_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_timer, get_tree, connect, print

#### `_setup_blink_animation()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, find_child, add_child, print, has_signal

#### `_on_blink_started()`
- **Purpose:** Function in talking_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _say_something_custom, size, randi, randf

#### `_setup_visual_indicators()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** setup_indicator, print, add_child, has_method, set_script

#### `set_action_state(action: String)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** update_status, has_method

#### `take_damage(amount: float)`
- **Purpose:** Function in talking_ragdoll system
- **Lines:** 13
- **Returns:** `void`
- **Key Calls:** _say_something_custom, max, update_health, has_method

---

### 📄 copy_ragdoll_all_files/simple_walking_ragdoll.gd
**Functions:** 10

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_simple_ragdoll

#### `_create_simple_ragdoll()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _create_simple_leg, Vector3, Color, add_child, new

#### `_create_simple_leg(is_left: bool)`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Color, add_child, get_path, new

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** dot, randf_range, _speak_random_dialogue, apply_central_force, _take_step

#### `_take_step()`
- **Purpose:** Function in simple_walking_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** apply_central_impulse

#### `_speak_random_dialogue()`
- **Purpose:** Function in simple_walking_ragdoll system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, show_dialogue, Vector3, size, print

#### `start_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, Vector3

#### `stop_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** show_dialogue, Vector3

#### `toggle_walking()`
- **Purpose:** Control ragdoll walking movement
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** start_walking, stop_walking

#### `get_body()`
- **Purpose:** Retrieve data or property value
- **Lines:** 2
- **Returns:** `RigidBody3D`

---

### 📄 copy_ragdoll_all_files/ragdoll_physics_test.gd
**Functions:** 9

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `test_configuration(config_name: String)`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, keys, get_tree, str, print

#### `_apply_config_to_ragdoll(config: Dictionary)`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_rigid_bodies_recursive, size, str, print, has

#### `_find_rigid_bodies_recursive(node: Node, bodies: Array)`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, _find_rigid_bodies_recursive, get_children

#### `show_physics_info()`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, _find_rigid_bodies_recursive, get_tree, str, print

#### `adjust_single_property(property: String, value: float)`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, _find_rigid_bodies_recursive, get_tree, str, print

#### `run_movement_test()`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_first_node_in_group, get_tree, str, print

#### `compare_all_configs()`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** str, print, to_upper

#### `handle_physics_command(args: Array)`
- **Purpose:** Function in ragdoll_physics_test system
- **Lines:** 27
- **Returns:** `String`
- **Key Calls:** float, size, compare_all_configs, show_physics_info, test_configuration

---

### 📄 copy_ragdoll_all_files/astral_ragdoll_helper.gd
**Functions:** 7

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process

#### `start_helping_ragdoll()`
- **Purpose:** Function in astral_ragdoll_helper system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, set_process, get_nodes_in_group, start_assisting, get_tree

#### `stop_helping()`
- **Purpose:** Function in astral_ragdoll_helper system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_process, set_movement_mode, print, has_method, clear

#### `_process(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_body, get_linear_velocity, Vector3, size, has_method

#### `_find_ragdoll()`
- **Purpose:** Function in astral_ragdoll_helper system
- **Lines:** 0
- **Returns:** `Node3D`
- **Key Calls:** get_tree, get_nodes_in_group, is_empty, get_node_or_null

#### `toggle_help()`
- **Purpose:** Function in astral_ragdoll_helper system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** stop_helping, start_helping_ragdoll

#### `assign_specific_being(being: Node3D)`
- **Purpose:** Function in astral_ragdoll_helper system
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** append, start_assisting, has_method

---

## Testing Systems
**Scripts:** 18 | **Functions:** 62

### 📄 scripts/test/floodgate_test.gd
**Functions:** 12

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** run_all_tests, push_error, create_timer, get_tree, print

#### `run_all_tests()`
- **Purpose:** Function in floodgate_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** test_third_dimensional_magic, create_timer, get_tree, test_second_dimensional_magic, print

#### `test_first_dimensional_magic()`
- **Purpose:** Function in floodgate_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, first_dimensional_magic, Vector3, get_tree, Magic

#### `test_second_dimensional_magic()`
- **Purpose:** Function in floodgate_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** second_dimensional_magic, Magic, print, new

#### `test_third_dimensional_magic()`
- **Purpose:** Function in floodgate_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Magic, print, third_dimensional_magic

#### `test_fourth_dimensional_magic()`
- **Purpose:** Function in floodgate_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_timer, get_tree, Magic, print, fourth_dimensional_magic

#### `test_sixth_dimensional_magic()`
- **Purpose:** Function in floodgate_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, Magic, print, sixth_dimensional_magic, get_node_or_null

#### `test_asset_library()`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** search_assets, size, str, print, get_catalog_summary

#### `test_stress_operations()`
- **Purpose:** Function in floodgate_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, Test, fourth_dimensional_magic, Vector3, str

#### `show_test_results()`
- **Purpose:** Function in floodgate_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** size, str, print, get_loaded_assets_list, get_registered_nodes

#### `_on_operation_completed(operation, success)`
- **Purpose:** Function in floodgate_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get, str, print

#### `_exit_tree()`
- **Purpose:** Function in floodgate_test system
- **Lines:** 5
- **Returns:** `void`
- **Key Calls:** is_instance_valid, queue_free

---

### 📄 scripts/test/function_flow_tracker.gd
**Functions:** 8

#### `trace_function_call(script_name: String, function_name: String, params: Array = [])`
- **Purpose:** Function in function_flow_tracker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, size, push_back, _check_floodgate_trigger

#### `trace_function_return(script_name: String, function_name: String, return_value = null)`
- **Purpose:** Function in function_flow_tracker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** pop_back, is_empty, get_ticks_msec, back

#### `_check_floodgate_trigger(script_name: String, function_name: String)`
- **Purpose:** Function in function_flow_tracker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, get_ticks_msec

#### `generate_flow_report()`
- **Purpose:** Function in function_flow_tracker system
- **Lines:** 0
- **Returns:** `String`
- **Key Calls:** append, size, sort_custom, min, get

#### `test_execution_path(path_name: String)`
- **Purpose:** Function in function_flow_tracker system
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** has, trace_function_call, trace_function_return, append

#### `record_fix_applied(error_type: String, file_path: String, fix_description: String)`
- **Purpose:** Function in function_flow_tracker system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, get_ticks_msec, append

#### `simulate_user_action(action: String)`
- **Purpose:** Function in function_flow_tracker system
- **Lines:** 0
- **Returns:** `Array`
- **Key Calls:** _on_input_submitted, toggle_console, create_tree, execute_command, _cmd_create_tree

#### `get_test_recommendations()`
- **Purpose:** Retrieve data or property value
- **Lines:** 16
- **Returns:** `Array`
- **Key Calls:** append, size

---

### 📄 scripts/test/layer_system_demo.gd
**Functions:** 7

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_demo_path, _create_demo_ragdoll, print, _create_demo_environment, _print_instructions

#### `_create_demo_ragdoll()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, add_child, set_script, load, new

#### `_create_demo_environment()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, add_child, set_script, load, new

#### `_setup_demo_path()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, size, Color, range, add_debug_line

#### `_print_instructions()`
- **Purpose:** Function in layer_system_demo system
- **Lines:** 2
- **Returns:** `void`

#### `_physics_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** distance_to, normalized, set_text_state, is_layer_visible, Color

#### `handle_console_command(command: String, args: Array)`
- **Purpose:** Function in layer_system_demo system
- **Lines:** 20
- **Returns:** `String`
- **Key Calls:** Vector3, float, size, str

---

### 📄 scripts/test/run_warning_fixes.gd
**Functions:** 7

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process, _on_body_entered, _analyze_files, print, _apply_fixes

#### `_analyze_files()`
- **Purpose:** Function in run_warning_fixes system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, size, file_exists, print

#### `_create_backups()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_file, file_exists, print, dir_exists, make_dir

#### `_apply_fixes()`
- **Purpose:** Function in run_warning_fixes system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_file, file_exists, load, size, print

#### `_generate_report()`
- **Purpose:** Function in run_warning_fixes system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _apply_fixes, print

#### `show_examples()`
- **Purpose:** Function in run_warning_fixes system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _process, _on_body_entered, emit_signal, print, _on_button_pressed
- **Signals:** hit

#### `test_single_file(file_path: String)`
- **Purpose:** Function in run_warning_fixes system
- **Lines:** 14
- **Returns:** `void`
- **Key Calls:** load, size, print, strip_edges, fix_file

---

### 📄 scripts/test/automated_warning_fixer.gd
**Functions:** 6

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_on_body_entered(body: Node2D)`
- **Purpose:** Function in automated_warning_fixer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `calculate_damage(attacker: Node, defender: Node, weapon: String)`
- **Purpose:** Function in automated_warning_fixer system
- **Lines:** 3
- **Returns:** `int`

#### `_process(_delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`

#### `_on_body_entered(_body: Node2D)`
- **Purpose:** Function in automated_warning_fixer system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print

#### `calculate_damage(_attacker: Node, defender: Node, _weapon: String)`
- **Purpose:** Function in automated_warning_fixer system
- **Lines:** 3
- **Returns:** `int`

---

### 📄 scripts/test/startup_diagnostic.gd
**Functions:** 5

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _check_critical_nodes, _check_autoloads, print, _check_input_actions, _check_common_issues

#### `_check_autoloads()`
- **Purpose:** Function in startup_diagnostic system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, get_node_or_null

#### `_check_input_actions()`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_action, print

#### `_check_critical_nodes()`
- **Purpose:** Function in startup_diagnostic system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, has_node, print

#### `_check_common_issues()`
- **Purpose:** Function in startup_diagnostic system
- **Lines:** 14
- **Returns:** `void`
- **Key Calls:** print, get_setting, get_node_or_null, has_method

---

### 📄 scripts/test/debug_scene_inspector.gd
**Functions:** 4

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** inspect_scene

#### `inspect_scene()`
- **Purpose:** Function in debug_scene_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_tree, get_tree, print, get_children, get_class

#### `_print_tree(node: Node, indent: int, max_depth: int)`
- **Purpose:** Function in debug_scene_inspector system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _print_tree, print, get_children, repeat

#### `get_node_info(path: String)`
- **Purpose:** Retrieve data or property value
- **Lines:** 17
- **Returns:** `void`
- **Key Calls:** get_groups, get_script, print, get_class, get_node_or_null

---

### 📄 scripts/test/integration_test.gd
**Functions:** 4

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _test_jsh_systems, _test_ragdoll_enhancements, _test_console_commands, print

#### `_test_jsh_systems()`
- **Purpose:** Function in integration_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, print, get_node, has_method

#### `_test_ragdoll_enhancements()`
- **Purpose:** Function in integration_test system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has_node, get_nodes_in_group, size, get_tree, print

#### `_test_console_commands()`
- **Purpose:** Function in integration_test system
- **Lines:** 14
- **Returns:** `void`
- **Key Calls:** has_node, print, get_node, has_method

---

### 📄 scripts/test/minimal_universal_test.gd
**Functions:** 2

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** create_timer, get_tree, print, get_node_or_null

#### `_test_command(_args: Array)`
- **Purpose:** Function in minimal_universal_test system
- **Lines:** 9
- **Returns:** `void`
- **Key Calls:** _print_to_console, print, get_node_or_null, has_method

---

### 📄 scripts/test/test_universal_being_assets.gd
**Functions:** 2

#### `run_tests()`
- **Purpose:** Function in test_universal_being_assets system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Vector3, print, _check_manifestation, create_being, get_node_or_null

#### `_check_manifestation(being: Node3D, expected_type: String)`
- **Purpose:** Function in test_universal_being_assets system
- **Lines:** 49
- **Returns:** `void`
- **Key Calls:** get_script, print, has_method, get_children, get_class

---

### 📄 scripts/test/final_universal_check.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 45
- **Returns:** `void`
- **Key Calls:** has_node, create_timer, get_tree, print, queue_free

---

### 📄 scripts/test/startup_test.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 29
- **Returns:** `void`
- **Key Calls:** has_node, create_timer, get_tree, execute_command, print

---

### 📄 scripts/test/universal_entity_test.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 49
- **Returns:** `void`
- **Key Calls:** print, get_node_or_null

---

### 📄 scripts/test/universal_launcher.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 41
- **Returns:** `void`
- **Key Calls:** _execute_command, create_timer, get_tree, print, has_method

---

### 📄 scripts/test/universal_ready_check.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 43
- **Returns:** `void`
- **Key Calls:** has_node, create_timer, get_tree, print, queue_free

---

## Tutorial Systems
**Scripts:** 1 | **Functions:** 19

### 📄 scripts/tutorial/tutorial_manager.gd
**Functions:** 19

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** values, print, _create_tutorial_ui, connect, get_node_or_null

#### `_create_tutorial_ui()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** set_anchors_preset, Vector2, add_child, set_anchors_and_offsets_preset, set_offsets_preset

#### `start_tutorial()`
- **Purpose:** Function in tutorial_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, _log_action, _load_tutorial_scene, print, _update_instructions

#### `stop_tutorial()`
- **Purpose:** Function in tutorial_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _log_action, keys, _save_log, get_tree, print

#### `_load_tutorial_scene(phase: TutorialPhase)`
- **Purpose:** Function in tutorial_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _log_action, print, keys

#### `_update_instructions()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`

#### `_process(delta: float)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_progress, _is_phase_complete, _advance_to_next_phase

#### `_update_progress()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_ticks_msec, float, size, has, min

#### `_is_phase_complete()`
- **Purpose:** Check boolean state or condition
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** has, get_ticks_msec

#### `_advance_to_next_phase()`
- **Purpose:** Function in tutorial_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** stop_tutorial, get_ticks_msec, _log_action, keys, _show_phase_transition

#### `_show_phase_transition()`
- **Purpose:** Function in tutorial_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** tween_property, add_child, create_tween, tween_callback, set_anchors_and_offsets_preset

#### `_on_command_executed(command: String, args: Array)`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _log_action, keys, size, begins_with, trim_prefix

#### `_log_action(action_type: String, data: Dictionary)`
- **Purpose:** Function in tutorial_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, get_ticks_msec, print

#### `_save_log()`
- **Purpose:** Function in tutorial_manager system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** store_string, get_ticks_msec, close, print, open

#### `_calculate_completion_percentage()`
- **Purpose:** Function in tutorial_manager system
- **Lines:** 0
- **Returns:** `float`
- **Key Calls:** return, float, int

*... and 4 more functions*

---

## Utility Scripts
**Scripts:** 2 | **Functions:** 22

### 📄 scripts/main_game_controller.gd
**Functions:** 21

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_jsh_framework, connect, get_connections, register_console_commands, size

#### `_setup_jsh_framework()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, print, add_child, new

#### `_on_jsh_tree_updated()`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`

#### `_on_jsh_branch_added(branch_path: String, _branch_data: Dictionary)`
- **Purpose:** Function in main_game_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** contains, get_node_or_null

#### `_on_systems_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _enable_game_features, print

#### `_on_startup_error(error_message: String)`
- **Purpose:** Function in main_game_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, push_error

#### `_enable_game_features()`
- **Purpose:** Function in main_game_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _setup_mouse_interaction, print, _setup_dimensional_ragdoll, _setup_ui_elements, _setup_input_handlers

#### `_setup_input_handlers()`
- **Purpose:** Handle input events from keyboard/mouse
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, add_child, set_script, load, new

#### `_setup_ui_elements()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, add_child, set_script, load, new

#### `get_system_status()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Dictionary`
- **Key Calls:** get_system_status

#### `run_health_check()`
- **Purpose:** Function in main_game_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** run_health_check

#### `test_floodgate()`
- **Purpose:** Function in main_game_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** test_floodgate_system

#### `is_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `bool`

#### `_setup_ragdoll_system()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** push_error, print, add_child, set_script, load

#### `_setup_astral_beings()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** print, get_node_or_null

*... and 6 more functions*

---

### 📄 test_ragdoll_standing.gd
**Functions:** 1

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 14
- **Returns:** `void`
- **Key Calls:** stance, print, forces, damping, detection

---

## Visual Effects
**Scripts:** 3 | **Functions:** 82

### 📄 scripts/effects/dimensional_color_system.gd
**Functions:** 39

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _initialize_frequency_color_map, _generate_tertiary_colors, _initialize_mesh_point_map, size, str

#### `_generate_tertiary_colors()`
- **Purpose:** Function in dimensional_color_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, Color, size, float, range

#### `_initialize_frequency_color_map()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color, size, float, has, range

#### `_initialize_mesh_point_map()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** has, size, range, append

#### `_generate_color_palettes()`
- **Purpose:** Function in dimensional_color_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Color

#### `_find_systems()`
- **Purpose:** Function in dimensional_color_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** get_tree, _find_node_by_class, print, get_node_or_null

#### `_find_node_by_class(node, class_name_str)`
- **Purpose:** Function in dimensional_color_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_node_by_class, or, get_script, find, get_children

#### `_process(delta)`
- **Purpose:** Called every frame, handles continuous updates
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _update_animations

#### `_update_animations(delta)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** append, erase, emit_signal, _update_pulse_animation, _update_mesh_point_animation
- **Signals:** animation_completed

#### `_update_pulse_animation(animation, progress)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, lerp, sin
- **Signals:** color_frequency_updated

#### `_update_fade_animation(animation, progress)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, lerp
- **Signals:** color_frequency_updated

#### `_update_cycle_animation(animation, progress)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, size, fmod, lerp, int
- **Signals:** color_frequency_updated

#### `_update_rainbow_animation(animation, progress)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** from_hsv, emit_signal, fmod
- **Signals:** color_frequency_updated

#### `_update_mesh_point_animation(animation, progress)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, fmod, lerp, sin
- **Signals:** mesh_point_activated, color_frequency_updated

#### `get_color_for_frequency(frequency: int)`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `Color`
- **Key Calls:** has, Color, clamp

*... and 24 more functions*

---

### 📄 scripts/effects/blink_animation_controller.gd
**Functions:** 26

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_node_by_class, connect, get_current_turn, get_tree, str

#### `_find_node_by_class(node, class_name_str)`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_node_by_class, or, get_script, find, get_children

#### `_initialize_timers()`
- **Purpose:** Set up initial state and connections
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** Callable, connect, new, add_child

#### `_create_default_animations()`
- **Purpose:** Create new instance or object
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** track_insert_key, add_track, add_animation_library, track_set_path, new

#### `_schedule_next_blink()`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_debug_build, pow, start, str, print

#### `_schedule_next_wink()`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_debug_build, pow, start, str, print

#### `_schedule_next_flicker()`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_debug_build, pow, start, str, print

#### `_execute_blink()`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** is_debug_build, create_timer, _blink_node, str, print

#### `_execute_wink()`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** wink, is_debug_build, _wink_node, create_timer, get_tree

#### `_execute_flicker()`
- **Purpose:** Run command or operation
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** randi, is_debug_build, create_timer, _flicker_node, str

#### `_blink_node(node_name: String, blink_count: int)`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** erase, emit_signal, create_timer, get_tree, tween_property
- **Signals:** blink_started, blink_ended

#### `_wink_node(node_name: String, is_left: bool)`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** erase, emit_signal, Color, tween_property, has_method
- **Signals:** wink_ended, wink_started

#### `_flicker_node(node_name: String, flicker_count: int)`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** erase, emit_signal, create_timer, get_tree, tween_property
- **Signals:** flicker_started, flicker_ended

#### `_on_blink_timer_timeout()`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _execute_blink

#### `_on_wink_timer_timeout()`
- **Purpose:** Function in blink_animation_controller system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _execute_wink

*... and 11 more functions*

---

### 📄 scripts/effects/visual_indicator_system.gd
**Functions:** 17

#### `_ready()`
- **Purpose:** Initialize component when node enters scene tree
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_time_tracker, str, print, _apply_mode_settings, _setup_timers

#### `_setup_timers()`
- **Purpose:** Configure and initialize component systems
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** connect, new, add_child

#### `_find_time_tracker()`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _find_node_by_class, get_nodes_in_group, size, get_tree, print

#### `_find_node_by_class(node: Node, target_class: String)`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `Node`
- **Key Calls:** _find_node_by_class, get_children, get_class

#### `_apply_mode_settings(mode_index)`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _set_symbol, emit_signal
- **Signals:** mode_changed

#### `_set_symbol(symbol_index)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal
- **Signals:** symbol_changed

#### `_on_blink_timer_timeout()`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal
- **Signals:** blink_occurred

#### `_on_color_cycle_timer_timeout()`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** emit_signal, size
- **Signals:** layer_changed, color_updated

#### `_on_animation_timer_timeout()`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `void`

#### `_on_time_updated(session_time, total_time)`
- **Purpose:** Refresh or modify existing data/state
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _set_symbol, size, floor, min

#### `_on_hour_limit_reached(hours)`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `void`
- **Key Calls:** _set_symbol, create_timer, get_tree

#### `set_mode(mode_index: int)`
- **Purpose:** Assign data or property value
- **Lines:** 0
- **Returns:** `bool`
- **Key Calls:** _apply_mode_settings, size

#### `cycle_mode()`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `int`
- **Key Calls:** _apply_mode_settings, size

#### `toggle_enabled()`
- **Purpose:** Function in visual_indicator_system system
- **Lines:** 0
- **Returns:** `bool`

#### `get_current_symbol()`
- **Purpose:** Retrieve data or property value
- **Lines:** 0
- **Returns:** `String`

*... and 2 more functions*

---

