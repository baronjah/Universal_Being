# COMPLETE FUNCTION MAP

Total Scripts: 238
Total Functions: 4726

## copy_ragdoll_all_files/astral_ragdoll_helper.gd
**Category:** Ragdoll Archive
**Functions:** 7

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_process

### `start_helping_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** start_assisting, set_process, str, is_empty, min, has_method, _find_ragdoll, print, append, get_tree, range, clear, size, get_nodes_in_group

### `stop_helping()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_method, print, set_movement_mode, clear, set_process

### `_process()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** is_instance_valid, Vector3, randf, speak, has_method, has_property, get_linear_velocity, apply_central_impulse, get_body, range, size, get

### `_find_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node3D`
- **Calls:** get_tree, get_node_or_null, is_empty, get_nodes_in_group

### `toggle_help()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** stop_helping, start_helping_ragdoll

### `assign_specific_being()`
- **Lines:** 5
- **Parameters:** `being: Node3D`
- **Returns:** `void`
- **Calls:** append, start_assisting, has_method


## copy_ragdoll_all_files/complete_ragdoll.gd
**Category:** Ragdoll Archive
**Functions:** 13

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_complete_ragdoll, _ready, add_to_group, _apply_materials

### `_create_complete_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, _create_leg, new, add_child

### `_create_leg()`
- **Lines:** 0
- **Parameters:** `side: String, offset: Vector3`
- **Returns:** `void`
- **Calls:** set_param_y, set_param_z, set_param, new, add_child, Vector3, set_param_x, capitalize, get_path

### `_apply_materials()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, Color, get_child

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _apply_walking_forces, length, _update_walk_cycle, _maintain_balance, normalized, _physics_process

### `_update_walk_cycle()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _stumble, randf

### `_apply_walking_forces()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sin, max, Vector3, has, apply_central_force

### `_maintain_balance()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, apply_torque, abs

### `_stumble()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf_range, _say_something, Vector3, apply_central_impulse

### `start_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _say_something

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _say_something

### `set_walk_speed()`
- **Lines:** 0
- **Parameters:** `speed: float`
- **Returns:** `void`
- **Calls:** clamp

### `set_floppiness()`
- **Lines:** 8
- **Parameters:** `factor: float`
- **Returns:** `void`
- **Calls:** set_param, set_floppiness


## copy_ragdoll_all_files/complete_ragdoll_fixed.gd
**Category:** Ragdoll Archive
**Functions:** 18

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_complete_ragdoll, add_to_group, _apply_materials, print

### `_create_complete_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, _create_leg, new, add_child

### `_create_leg()`
- **Lines:** 0
- **Parameters:** `side: String, offset: Vector3`
- **Returns:** `void`
- **Calls:** set_param_y, set_param_z, set_param, new, add_child, Vector3, set_param_x, capitalize, get_path

### `_apply_materials()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_child_count, new, Color, get_child

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** length, _update_walk_cycle, _maintain_balance, normalized, _apply_walking_forces

### `_update_walk_cycle()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _stumble, randf

### `_apply_walking_forces()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sin, max, Vector3, has, apply_central_force

### `_maintain_balance()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, apply_torque, abs

### `_stumble()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf_range, _say_something, Vector3, apply_central_impulse

### `start_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _say_something

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _say_something

### `set_walk_speed()`
- **Lines:** 0
- **Parameters:** `speed: float`
- **Returns:** `void`
- **Calls:** clamp

### `set_floppiness()`
- **Lines:** 0
- **Parameters:** `factor: float`
- **Returns:** `void`
- **Calls:** set_param

### `_say_something()`
- **Lines:** 0
- **Parameters:** `category: String`
- **Returns:** `void`
- **Calls:** is_empty, randi, _create_speech_bubble, print, size

### `_create_speech_bubble()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** create_timer, new, add_child, Vector3, connect, get_tree

### `get_body_parts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`

### `get_main_body()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `RigidBody3D`

### `is_currently_walking()`
- **Lines:** 3
- **Parameters:** ``
- **Returns:** `bool`


## copy_ragdoll_all_files/dimensional_ragdoll_system.gd
**Category:** Ragdoll Archive
**Functions:** 25

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _initialize_consciousness, _setup_dimensional_physics, print

### `_setup_dimensional_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_initialize_consciousness()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _learn_initial_spells

### `_learn_initial_spells()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** learn_spell

### `shift_dimension()`
- **Lines:** 0
- **Parameters:** `target_dimension: Dimension`
- **Returns:** `void`
- **Calls:** keys, print, emit_signal, _apply_dimensional_effects, float
- **Signals:** dimension_changed

### `_apply_dimensional_effects()`
- **Lines:** 0
- **Parameters:** `dimension: Dimension`
- **Returns:** `void`

### `add_consciousness_experience()`
- **Lines:** 0
- **Parameters:** `amount: float, source: String = ""`
- **Returns:** `void`
- **Calls:** _get_evolution_stage, get_ticks_msec, clamp, _evolve_to_stage, emit_signal, print, append, f
- **Signals:** consciousness_evolved

### `_get_evolution_stage()`
- **Lines:** 0
- **Parameters:** `level: float`
- **Returns:** `String`

### `_evolve_to_stage()`
- **Lines:** 0
- **Parameters:** `new_stage: String`
- **Returns:** `void`
- **Calls:** _update_emotion_state, learn_spell, print

### `learn_spell()`
- **Lines:** 0
- **Parameters:** `spell_name: String`
- **Returns:** `void`
- **Calls:** append, emit_signal, print
- **Signals:** spell_learned

### `cast_spell()`
- **Lines:** 0
- **Parameters:** `spell_name: String, target: Node3D = null`
- **Returns:** `bool`
- **Calls:** add_consciousness_experience, _spell_float, _spell_glow, _spell_blink, _spell_teleport_short, _spell_wobble, _spell_giggle, _spell_reality_shift, print, _spell_dimension_peek

### `set_emotion()`
- **Lines:** 0
- **Parameters:** `emotion: String, value: float`
- **Returns:** `void`
- **Calls:** _update_emotion_state, clamp

### `_update_emotion_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** s, emit_signal, print
- **Signals:** emotion_changed

### `process_interaction()`
- **Lines:** 0
- **Parameters:** `interaction_type: String, object: Node3D = null`
- **Returns:** `void`
- **Calls:** add_consciousness_experience, _detect_interaction_patterns, get_ticks_msec, append, set_emotion

### `_detect_interaction_patterns()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** slice, add_consciousness_experience, size, print

### `_spell_wobble()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, randf, apply_impulse

### `_spell_blink()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_spell_giggle()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_spell_float()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, get_tree

### `_spell_glow()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_spell_teleport_short()`
- **Lines:** 0
- **Parameters:** `target: Node3D`
- **Returns:** `void`
- **Calls:** normalized

### `_spell_dimension_peek()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** keys, size, print

### `_spell_reality_shift()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** shift_dimension, randi, size

### `get_state()`
- **Lines:** 19
- **Parameters:** ``
- **Returns:** `Dictionary`

### `_init()`
- **Lines:** 6
- **Parameters:** `px: float = 0, py: float = 0, pz: float = 0, pw: float = 0, pv: float = 0`
- **Returns:** `void`


## copy_ragdoll_all_files/ragdoll_controller.gd
**Category:** Ragdoll Archive
**Functions:** 33

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_default_patrol, get_node, has_node, set_behavior_state, print, _find_ragdoll_body

### `_spawn_seven_part_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, load, add_child, Vector3, set_script, print, get_tree

### `_find_ragdoll_body()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _spawn_seven_part_ragdoll, has_method, print, get_tree, size, get_nodes_in_group

### `_setup_default_patrol()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_investigating, _process_organizing, _process_carrying, _process_idle, _process_helping, _process_walking

### `_process_idle()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** move_to_position, move_to_object, _find_nearby_objects, set_behavior_state, size

### `_process_walking()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** distance_to, set_behavior_state, emit_signal, _apply_movement_to_ragdoll, size
- **Signals:** movement_completed

### `_process_investigating()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _find_nearby_objects, set_behavior_state, size, attempt_pickup

### `_process_carrying()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _update_carried_object_position, set_behavior_state, _look_for_organization_spot

### `_process_helping()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`

### `_process_organizing()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** drop_object_at_position, _find_good_drop_position

### `_apply_movement_to_ragdoll()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** atan2, apply_torque, Vector3, start_walking, length, has_method, normalized, apply_central_force, angle_difference, get_body

### `_find_nearby_objects()`
- **Lines:** 0
- **Parameters:** `radius: float = 5.0`
- **Returns:** `Array`
- **Calls:** sort_custom, distance_to, append, get_tree, get_nodes_in_group

### `_update_carried_object_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_look_for_organization_spot()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf, set_behavior_state

### `_find_good_drop_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`
- **Calls:** randf_range, _is_position_clear, Vector3

### `_is_position_clear()`
- **Lines:** 0
- **Parameters:** `target_position: Vector3, radius: float`
- **Returns:** `bool`
- **Calls:** _find_nearby_objects, distance_to

### `cmd_ragdoll_come()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_method, get_viewport, print, come_to_position, get_camera_3d

### `cmd_ragdoll_pickup()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** pick_up_nearest_object, has_method, print

### `cmd_ragdoll_drop()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_method, handle_console_command, print

### `cmd_ragdoll_organize()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** organize_nearby_objects, has_method, print

### `cmd_ragdoll_patrol()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** move_to_position, set_behavior_state, print

### `move_to_position()`
- **Lines:** 0
- **Parameters:** `target: Vector3`
- **Returns:** `void`
- **Calls:** str, emit_signal, print
- **Signals:** movement_started

### `move_to_object()`
- **Lines:** 0
- **Parameters:** `object: Node3D`
- **Returns:** `void`
- **Calls:** move_to_position

### `attempt_pickup()`
- **Lines:** 0
- **Parameters:** `object: RigidBody3D`
- **Returns:** `bool`
- **Calls:** distance_to, set_behavior_state, emit_signal, print, add_to_group
- **Signals:** object_picked_up

### `drop_object()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** drop_object_at_position, Vector3

### `drop_object_at_position()`
- **Lines:** 0
- **Parameters:** `drop_position: Vector3`
- **Returns:** `void`
- **Calls:** remove_from_group, set_behavior_state, emit_signal, print
- **Signals:** object_dropped

### `set_behavior_state()`
- **Lines:** 0
- **Parameters:** `new_state: BehaviorState`
- **Returns:** `void`
- **Calls:** start_walking, str, stop_walking, has_method, print

### `help_player_with_task()`
- **Lines:** 0
- **Parameters:** `task_description: String`
- **Returns:** `void`
- **Calls:** set_behavior_state, emit_signal, print
- **Signals:** player_needs_help

### `organize_nearby_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_behavior_state, print

### `cmd_ragdoll_come_here()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** move_to_position, get_viewport, get_camera_3d

### `cmd_ragdoll_pickup_nearest()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, attempt_pickup, move_to_object, _find_nearby_objects, get_tree, size

### `get_ragdoll_body()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `RigidBody3D`


## copy_ragdoll_all_files/ragdoll_debug_visualizer.gd
**Category:** Ragdoll Archive
**Functions:** 14

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_materials, set_process, print

### `_create_materials()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new

### `set_ragdoll()`
- **Lines:** 0
- **Parameters:** `ragdoll: Node3D`
- **Returns:** `void`
- **Calls:** get_node, has_node, print

### `_process()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _clear_debug_elements, _visualize_center_of_mass, get_meta, is_empty, _visualize_velocities, _visualize_walker_state, _visualize_support_polygon, _visualize_joints

### `_clear_debug_elements()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, clear

### `_visualize_joints()`
- **Lines:** 0
- **Parameters:** `body_parts: Dictionary`
- **Returns:** `void`
- **Calls:** has, _draw_line

### `_visualize_center_of_mass()`
- **Lines:** 0
- **Parameters:** `body_parts: Dictionary`
- **Returns:** `void`
- **Calls:** _draw_sphere, Vector3, _create_label

### `_visualize_velocities()`
- **Lines:** 0
- **Parameters:** `body_parts: Dictionary`
- **Returns:** `void`
- **Calls:** Vector3, _create_label, length, _draw_line

### `_visualize_walker_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_status, Vector3, get_meta, _create_label, get

### `_visualize_support_polygon()`
- **Lines:** 0
- **Parameters:** `body_parts: Dictionary`
- **Returns:** `void`
- **Calls:** _draw_sphere, get, _draw_line

### `_draw_line()`
- **Lines:** 0
- **Parameters:** `start: Vector3, end: Vector3, material: Material, thickness: float = 0.02`
- **Returns:** `void`
- **Calls:** rotate_object_local, new, distance_to, add_child, look_at, append

### `_draw_sphere()`
- **Lines:** 0
- **Parameters:** `position: Vector3, radius: float, material: Material`
- **Returns:** `void`
- **Calls:** append, new, add_child

### `_create_label()`
- **Lines:** 0
- **Parameters:** `position: Vector3, text: String, color: Color`
- **Returns:** `void`
- **Calls:** append, new, add_child

### `toggle_debug_option()`
- **Lines:** 31
- **Parameters:** `option: String`
- **Returns:** `String`
- **Calls:** str


## copy_ragdoll_all_files/ragdoll_physics_test.gd
**Category:** Ragdoll Archive
**Functions:** 9

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `test_configuration()`
- **Lines:** 0
- **Parameters:** `config_name: String`
- **Returns:** `void`
- **Calls:** keys, str, get_first_node_in_group, _apply_config_to_ragdoll, has, print, get_tree

### `_apply_config_to_ragdoll()`
- **Lines:** 0
- **Parameters:** `config: Dictionary`
- **Returns:** `void`
- **Calls:** _find_rigid_bodies_recursive, str, has, print, size

### `_find_rigid_bodies_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node, bodies: Array`
- **Returns:** `void`
- **Calls:** append, get_children, _find_rigid_bodies_recursive

### `show_physics_info()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _find_rigid_bodies_recursive, str, get_first_node_in_group, print, get_tree

### `adjust_single_property()`
- **Lines:** 0
- **Parameters:** `property: String, value: float`
- **Returns:** `void`
- **Calls:** _find_rigid_bodies_recursive, str, get_first_node_in_group, print, get_tree, size

### `run_movement_test()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, get_tree, get_first_node_in_group, print

### `compare_all_configs()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, to_upper, print

### `handle_physics_command()`
- **Lines:** 27
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** adjust_single_property, test_configuration, show_physics_info, compare_all_configs, float, size


## copy_ragdoll_all_files/ragdoll_with_legs.gd
**Category:** Ragdoll Archive
**Functions:** 13

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_ragdoll_parts, _apply_materials, set_physics_process, _setup_joints, add_to_group

### `_create_ragdoll_parts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `_setup_joints()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_param_z, set_param, new, add_child, Vector3, set_param_x, get_path

### `_apply_materials()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, Color, get_child

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _apply_walking_forces, _check_balance, _update_walk_cycle

### `_update_walk_cycle()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _stumble, randf

### `_apply_walking_forces()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sin, apply_central_force, Vector3

### `_check_balance()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, apply_torque

### `_stumble()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf_range, call, Vector3, has_method, apply_central_impulse

### `start_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `set_walk_speed()`
- **Lines:** 0
- **Parameters:** `speed: float`
- **Returns:** `void`
- **Calls:** clamp

### `get_body()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `RigidBody3D`


## copy_ragdoll_all_files/seven_part_ragdoll_integration.gd
**Category:** Ragdoll Archive
**Functions:** 36

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, _setup_seven_part_body, _connect_to_floodgate, str, has_node, _setup_dialogue_system, stand_up, print, _connect_to_jsh_framework, _setup_upright_controller, get_tree, add_to_group, get_unix_time_from_system

### `_setup_seven_part_body()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_joints, add_child, Vector3, _create_body_part, set_meta, has, append

### `_setup_upright_controller()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, set_script, print

### `_create_body_part()`
- **Lines:** 0
- **Parameters:** `part_name: String`
- **Returns:** `Node3D`
- **Calls:** Vector3, new, add_child

### `_create_joints()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary`
- **Returns:** `void`
- **Calls:** _create_knee_joint, _create_hip_joint, _create_ankle_joint

### `_create_hip_joint()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary, parent_name: String, child_name: String`
- **Returns:** `void`
- **Calls:** set_param_y, set_param_z, set_flag_x, set_flag_y, new, add_child, Vector3, set_param_x, get_path, has, set_flag_z

### `_create_knee_joint()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary, parent_name: String, child_name: String`
- **Returns:** `void`
- **Calls:** set_param, new, add_child, Vector3, get_path, has, set_flag

### `_create_ankle_joint()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary, parent_name: String, child_name: String`
- **Returns:** `void`
- **Calls:** set_param, new, add_child, Vector3, get_path, has, set_flag

### `_connect_to_jsh_framework()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, get_node_or_null, has_method, print

### `_connect_to_floodgate()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_ragdoll_position_update, get_node_or_null, connect, print

### `_setup_dialogue_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf_range, add_child, new, connect

### `_speak_random_phrase()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, randi, size, print

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_walking_movement, _update_dialogue

### `_process_walking_movement()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _handle_target_reached, distance_to, str, has_node, length, is_empty, start_walking, stop_walking, get_meta, _next_patrol_point, pop_front, print, _calculate_movement_direction, get

### `come_to_position()`
- **Lines:** 0
- **Parameters:** `pos: Vector3`
- **Returns:** `void`
- **Calls:** emit, str, print

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** say, has_node, stop_walking, emit, clear

### `pick_up_nearest_object()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** distance_to, Vector3, emit, print, get_tree, get_nodes_in_group

### `organize_nearby_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, min, emit, print, get_tree, range, size, get_nodes_in_group

### `reset_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, has_node, get_meta, stop_walking, emit, stand_up, print, get

### `say_text()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** emit, print

### `get_ragdoll_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`

### `_calculate_movement_direction()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`
- **Calls:** _apply_obstacle_avoidance, normalized

### `_apply_obstacle_avoidance()`
- **Lines:** 0
- **Parameters:** `base_direction: Vector3`
- **Returns:** `Vector3`
- **Calls:** create, get_world_3d, return, Vector3, intersect_ray, normalized

### `_handle_target_reached()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, stop_walking, is_empty, _next_patrol_point, pop_front, print

### `_next_patrol_point()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, str, size, print

### `add_waypoint()`
- **Lines:** 0
- **Parameters:** `waypoint: Vector3`
- **Returns:** `void`
- **Calls:** emit, append, str, print

### `clear_waypoints()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, print

### `start_patrol()`
- **Lines:** 0
- **Parameters:** `points: Array[Vector3]`
- **Returns:** `void`
- **Calls:** str, come_to_position, size, print

### `stop_patrol()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, stop_walking, print

### `_on_ragdoll_state_changed()`
- **Lines:** 0
- **Parameters:** `new_state: String`
- **Returns:** `void`
- **Calls:** get_node_or_null, queue_ragdoll_position_update

### `_on_ragdoll_position_updated()`
- **Lines:** 0
- **Parameters:** `pos: Vector3`
- **Returns:** `void`
- **Calls:** get_node_or_null, queue_ragdoll_position_update

### `handle_console_command()`
- **Lines:** 0
- **Parameters:** `command: String, args: Array`
- **Returns:** `String`
- **Calls:** pick_up_nearest_object, say_text, str, Vector3, stop_patrol, get_ragdoll_status, come_to_position, points, join, organize_nearby_objects, add_waypoint, start_patrol, reset_position, append, range, float, size

### `say()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** get_node_or_null, has_method, show_ragdoll_dialogue, emit, print

### `_update_dialogue()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** say, randf, randi, size, get

### `toggle_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** start_walking, stop_walking

### `start_walking()`
- **Lines:** 8
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** say, stand_up, has_method


## copy_ragdoll_all_files/simple_ragdoll_walker.gd
**Category:** Ragdoll Archive
**Functions:** 25

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _configure_physics, _find_body_parts, print, get_tree, set_physics_process

### `_find_body_parts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_parent, get_meta, print, has_meta, get

### `_configure_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_state, _process_balancing, _process_standing_up, _process_idle, _process_stepping, _process_falling

### `_update_state()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _is_on_ground, length, _is_upright, _is_falling

### `_process_idle()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_process_standing_up()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, _apply_upright_torque, _apply_leg_straightening_forces

### `_process_balancing()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _maintain_height, _apply_upright_torque, _balance_over_feet

### `_process_stepping()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _maintain_height, _apply_step_forces, _apply_upright_torque

### `_process_falling()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _orient_feet_down

### `_maintain_height()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force

### `_apply_upright_torque()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_torque, length, normalized

### `_balance_over_feet()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, _calculate_center_of_mass

### `_apply_step_forces()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, _stabilize_foot

### `_apply_leg_straightening_forces()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3

### `_stabilize_foot()`
- **Lines:** 0
- **Parameters:** `foot: RigidBody3D`
- **Returns:** `void`
- **Calls:** apply_central_force

### `_orient_feet_down()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** cross, apply_torque

### `_is_upright()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** dot

### `_is_falling()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** length

### `_is_on_ground()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`

### `_calculate_center_of_mass()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`

### `start_walking()`
- **Lines:** 0
- **Parameters:** `direction: Vector3`
- **Returns:** `void`
- **Calls:** str, normalized, print

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `stand_up()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `get_status()`
- **Lines:** 7
- **Parameters:** ``
- **Returns:** `String`


## copy_ragdoll_all_files/simple_walking_ragdoll.gd
**Category:** Ragdoll Archive
**Functions:** 10

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_simple_ragdoll

### `_create_simple_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, Color, _create_simple_leg

### `_create_simple_leg()`
- **Lines:** 0
- **Parameters:** `is_left: bool`
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, get_path, Color

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** randf_range, _speak_random_dialogue, dot, _take_step, apply_central_force

### `_take_step()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_impulse

### `_speak_random_dialogue()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** show_dialogue, Vector3, randi, print, size

### `start_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, show_dialogue

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, show_dialogue

### `toggle_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** start_walking, stop_walking

### `get_body()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `RigidBody3D`


## copy_ragdoll_all_files/stable_ragdoll.gd
**Category:** Ragdoll Archive
**Functions:** 14

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_stable_ragdoll, set_physics_process

### `_create_stable_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set, new, add_child, Vector3, connect, get_path, Color, _create_leg, deg_to_rad, add_to_group

### `_create_leg()`
- **Lines:** 0
- **Parameters:** `is_left: bool`
- **Returns:** `void`
- **Calls:** set, new, bind, add_child, Vector3, connect, get_path, Color, deg_to_rad

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_dialogue, _process_walking, length, normalized

### `_process_walking()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** apply_central_impulse

### `_process_dialogue()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** randf_range, show_dialogue, Vector3, randi, emit_signal, size
- **Signals:** dialogue_spoken

### `_on_body_collision()`
- **Lines:** 0
- **Parameters:** `other_body: Node`
- **Returns:** `void`
- **Calls:** show_dialogue, Vector3, randi, is_in_group, size

### `_on_head_collision()`
- **Lines:** 0
- **Parameters:** `other_body: Node`
- **Returns:** `void`
- **Calls:** is_in_group, Vector3, show_dialogue

### `_on_leg_collision()`
- **Lines:** 0
- **Parameters:** `other_body: Node, is_left: bool`
- **Returns:** `void`
- **Calls:** is_in_group, show_dialogue

### `start_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, show_dialogue

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, show_dialogue

### `toggle_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** start_walking, stop_walking

### `set_walk_speed()`
- **Lines:** 0
- **Parameters:** `speed: float`
- **Returns:** `void`
- **Calls:** str, clamp, Vector3, show_dialogue

### `get_body()`
- **Lines:** 3
- **Parameters:** ``
- **Returns:** `RigidBody3D`


## copy_ragdoll_all_files/talking_ragdoll.gd
**Category:** Ragdoll Archive
**Functions:** 13

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf_range, _say_something, set_angular_damp, set_linear_damp, set_action_state, set_freeze_enabled, set_max_contacts_reported, Vector3, connect, set_gravity_scale, set_contact_monitor, apply_central_impulse, _setup_visual_indicators, _setup_blink_animation

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** randf_range, _say_something, _get_mouse_world_position, set_action_state, get_viewport, set_gravity_scale, look_at, apply_central_force, get_camera_3d

### `_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** randf_range, _say_something, is_action_pressed, _get_mouse_world_position, distance_to, Vector3, is_action_released, apply_central_impulse

### `_get_mouse_world_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`
- **Calls:** project_ray_normal, get_mouse_position, get_world_3d, new, get_viewport, intersect_ray, project_ray_origin, Plane, intersects_ray, get_camera_3d

### `_say_something()`
- **Lines:** 0
- **Parameters:** `category: String`
- **Returns:** `void`
- **Calls:** create_timer, randf, connect, randi, print, get_tree, size

### `_on_body_entered()`
- **Lines:** 0
- **Parameters:** `body: Node`
- **Returns:** `void`
- **Calls:** randf_range, _say_something, set_action_state, length, take_damage, is_in_group

### `set_floppiness()`
- **Lines:** 0
- **Parameters:** `factor: float`
- **Returns:** `void`
- **Calls:** set_linear_damp, _say_something, clamp, set_angular_damp

### `_say_something_custom()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, connect, print

### `_setup_blink_animation()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, set_script, connect, has_signal, print, find_child

### `_on_blink_started()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _say_something_custom, randf, randi, size

### `_setup_visual_indicators()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, setup_indicator, add_child, load, set_script, has_method, print

### `set_action_state()`
- **Lines:** 0
- **Parameters:** `action: String`
- **Returns:** `void`
- **Calls:** has_method, update_status

### `take_damage()`
- **Lines:** 13
- **Parameters:** `amount: float`
- **Returns:** `void`
- **Calls:** update_health, _say_something_custom, max, has_method


## copy_ragdoll_all_files/upright_ragdoll_controller.gd
**Category:** Ragdoll Archive
**Functions:** 17

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _configure_physics, _store_rest_positions, _find_body_parts

### `_find_body_parts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children

### `_store_rest_positions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3

### `_configure_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_physics_mode, _process_blend_mode, _apply_balance_forces, _process_controlled_mode

### `_process_controlled_mode()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** apply_torque, _maintain_rest_pose, get_euler, apply_central_force, _process_walking

### `_process_walking()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, max, _apply_rotation_force, Vector3, length, apply_central_force

### `_maintain_rest_pose()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, get

### `_apply_rotation_force()`
- **Lines:** 0
- **Parameters:** `body: RigidBody3D, target_euler: Vector3`
- **Returns:** `void`
- **Calls:** apply_torque

### `_apply_balance_forces()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, abs

### `_process_physics_mode()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`

### `_process_blend_mode()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_controlled_mode

### `start_walking()`
- **Lines:** 0
- **Parameters:** `direction: Vector3`
- **Returns:** `void`
- **Calls:** normalized

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `set_ragdoll_mode()`
- **Lines:** 0
- **Parameters:** `new_mode: RagdollMode`
- **Returns:** `void`

### `stand_up()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, _maintain_rest_pose

### `ragdoll_fall()`
- **Lines:** 3
- **Parameters:** ``
- **Returns:** `void`


## scripts/autoload/advanced_inspector_loader.gd
**Category:** Core Systems - Autoload
**Functions:** 2

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _load_integration_patch, print

### `_load_integration_patch()`
- **Lines:** 14
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, preload, exists, print, get_tree


## scripts/autoload/astral_being_manager.gd
**Category:** Core Systems - Autoload
**Functions:** 19

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_test_panel, _register_commands, print

### `_register_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null

### `_create_test_panel()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** call_deferred, new, preload, exists, hide, get_tree

### `_cmd_spawn_being()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** spawn_astral_being, str, _print, reached, size

### `_cmd_list_beings()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** is_instance_valid, get_being_name, is_empty, _print, has_method, Beings, is_busy, size, get

### `_cmd_clear_beings()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** queue_free, clear, size, _print

### `_cmd_assign_task()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** Vector3, _find_being, _print, add_task, float, size

### `_cmd_organize_scene()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** spawn_astral_being, Vector3, is_empty, min, _print, add_task, range, size

### `_cmd_start_patrol()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** spawn_astral_being, Vector3, is_empty, min, _print, add_task, range, size

### `_cmd_help_ragdoll()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** add_task, spawn_astral_being, is_empty, _print

### `_cmd_create_lights()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** spawn_astral_being, Vector3, is_empty, _print, add_task, append, range, size

### `_cmd_toggle_test_panel()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _print

### `_cmd_test_all_features()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** show, _print

### `spawn_astral_being()`
- **Lines:** 0
- **Parameters:** `being_name: String = "", position: Vector3 = Vector3.ZERO`
- **Returns:** `Node3D`
- **Calls:** call_deferred, new, bind, get_node, set_script, set_being_name, emit, append, get_tree, size, Vector3, has_method, connect, get_path, queue_operation, str, _print, set_color, randf_range, get_node_or_null

### `get_nearest_being()`
- **Lines:** 0
- **Parameters:** `position: Vector3`
- **Returns:** `Node3D`
- **Calls:** distance_to

### `assign_task_to_nearest()`
- **Lines:** 0
- **Parameters:** `position: Vector3, task: String, params: Dictionary = {}`
- **Returns:** `void`
- **Calls:** add_task, get_nearest_being

### `_find_being()`
- **Lines:** 0
- **Parameters:** `identifier: String`
- **Returns:** `Node3D`
- **Calls:** is_valid_int, size, int

### `_print()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, print

### `_on_task_completed()`
- **Lines:** 9
- **Parameters:** `task: String, being: Node3D`
- **Returns:** `void`
- **Calls:** emit, _find_nearby_objects, add_task, size


## scripts/autoload/claude_timer_system.gd
**Category:** Core Systems - Autoload
**Functions:** 16

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, set_process, connect

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** get_ticks_msec, emit

### `start_task()`
- **Lines:** 0
- **Parameters:** `task_name: String, project: String = ""`
- **Returns:** `void`
- **Calls:** get_ticks_msec, print

### `complete_task()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `float`
- **Calls:** get_ticks_msec, str, print

### `user_message_received()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, _exit_autonomous_mode

### `switch_project()`
- **Lines:** 0
- **Parameters:** `project_id: String`
- **Returns:** `bool`
- **Calls:** print

### `get_session_metrics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec

### `get_project_time()`
- **Lines:** 0
- **Parameters:** `project_id: String`
- **Returns:** `float`

### `add_autonomous_project()`
- **Lines:** 0
- **Parameters:** `project_id: String, priority: int = 1`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, sort_custom

### `_sort_by_priority()`
- **Lines:** 0
- **Parameters:** `a, b`
- **Returns:** `bool`

### `_on_user_wait_threshold()`
- **Lines:** 0
- **Parameters:** `wait_time: float`
- **Returns:** `void`
- **Calls:** _start_autonomous_mode, size

### `_start_autonomous_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, str, _perform_autonomous_work, emit, print, int

### `_perform_autonomous_work()`
- **Lines:** 0
- **Parameters:** `project_id: String`
- **Returns:** `void`
- **Calls:** print

### `_exit_autonomous_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** completed, str, int, print

### `get_timer_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_ticks_msec, str, get_session_metrics, int

### `set_wait_threshold()`
- **Lines:** 4
- **Parameters:** `seconds: float`
- **Returns:** `void`
- **Calls:** str, print


## scripts/autoload/console_manager.gd
**Category:** Core Systems - Autoload
**Functions:** 181

### `debug_print()`
- **Lines:** 5
- **Parameters:** `message: String, level: int = 2`
- **Returns:** `void`
- **Calls:** print

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** call_deferred, new, set_anchors_and_offsets_preset, add_child, _ready, set_process_unhandled_input, print, add_theme_font_size_override

### `_safe_initialize()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _wait_for_floodgate_systems, _create_todo_manager, _create_windows_console_fix, _create_physics_manager, _create_project_manager, _create_object_inspector, connect, _create_timer_system, _create_threaded_system, debug_print, _create_console_ui, set_process_unhandled_input, print, _create_passive_controller

### `_wait_for_floodgate_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, str, get_node_or_null, push_warning, debug_print, get_tree

### `_check_systems_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** _print_to_console, get_node_or_null

### `_create_passive_controller()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, preload, exists, debug_print

### `_create_threaded_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, preload, exists, debug_print

### `_create_physics_manager()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, preload, exists, print, get_tree

### `_create_project_manager()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, preload, exists, start_waiting_for_user, print

### `_create_timer_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, preload, exists, add_autonomous_project, print

### `_create_todo_manager()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, preload, exists, print

### `_create_object_inspector()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, preload, exists, print, get_tree, add_to_group

### `_create_windows_console_fix()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, preload, patch_console_manager, exists, print

### `_unhandled_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** is_action_pressed, _navigate_history, str, get_viewport, set_input_as_handled, print, toggle_console

### `_create_console_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _print_to_console, Vector2, call_deferred, new, set_anchors_and_offsets_preset, add_child, add_theme_color_override, add_spacer, connect, _apply_settings, get_tree, Color, print, add_theme_font_size_override, _on_command_submitted, add_theme_stylebox_override

### `_apply_settings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_theme_font_size_override, Vector2, get_console_rect, int

### `toggle_console()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** kill, set_trans, Vector2, parallel, clear, str, connect, tween_property, _create_console_ui, grab_focus, print, get_tree, set_ease, create_tween

### `_on_command_submitted()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** append, _print_to_console, call, is_empty, to_lower, emit, pop_front, has, user_message_received, start_waiting_for_user, slice, user_responded, clear, strip_edges, size, split

### `_print_to_console()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** get_node_or_null, pop_front, append_text, append, clear, size, filter_message

### `_navigate_history()`
- **Lines:** 0
- **Parameters:** `direction: int`
- **Returns:** `void`
- **Calls:** clamp, length, is_empty, clear, size

### `_on_settings_changed()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _apply_settings

### `register_command()`
- **Lines:** 0
- **Parameters:** `command_name: String, callback: Callable, description: String = ""`
- **Returns:** `void`
- **Calls:** get_meta, has_meta, set_meta, to_lower

### `_execute_command()`
- **Lines:** 0
- **Parameters:** `command_text: String`
- **Returns:** `void`
- **Calls:** _print_to_console, call, is_empty, to_lower, has, slice, split

### `_cmd_help()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, direction, place, sun, ragdoll, speed, physics, scale, object, movement, position, gravity

### `_cmd_test_tutorial()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, add_child, load, connect, get_tree

### `_on_tutorial_test_completed()`
- **Lines:** 0
- **Parameters:** `test_name: String, result: String, success: bool`
- **Returns:** `void`
- **Calls:** _print_to_console

### `_on_tutorial_finished()`
- **Lines:** 0
- **Parameters:** `total_tests: int, passed: int, failed: int`
- **Returns:** `void`
- **Calls:** _print_to_console

### `_cmd_console_settings()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, is_empty, set_console_position

### `_cmd_set_scale()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, str, is_empty, to_float, set_ui_scale

### `_cmd_create()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, is_empty, _cmd_create_astral_being, to_lower, _cmd_spawn_ragdoll, capitalize, has, _check_systems_ready, create_object

### `_cmd_create_tree()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** create_tree, _print_to_console, _check_systems_ready

### `_cmd_create_rock()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** create_rock, _check_systems_ready, _print_to_console

### `_cmd_create_box()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** create_box, _check_systems_ready, _print_to_console

### `_cmd_create_ball()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _check_systems_ready, create_ball

### `_cmd_create_ramp()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _check_systems_ready, create_ramp

### `_cmd_create_wall()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, create_object, _check_systems_ready

### `_cmd_create_stick()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, _check_systems_ready, has, create_object

### `_cmd_create_leaf()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, create_object, _check_systems_ready

### `_cmd_list_assets()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, s, get_node_or_null, size, get

### `_on_asset_created()`
- **Lines:** 0
- **Parameters:** `asset_name: String, properties: Dictionary`
- **Returns:** `void`
- **Calls:** _print_to_console

### `_cmd_toggle_rules()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, to_lower, size, get

### `_cmd_clear_objects()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, restore_default_scene, clear_all_objects, str, clear_current_scene, get_node_or_null, _check_systems_ready, size

### `_cmd_list_objects()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_spawned_objects, _print_to_console, is_instance_valid, str, get_meta, get_node_or_null, is_empty, get_statistics, Objects, _check_systems_ready, size, get, get_all_objects

### `_cmd_delete_object()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _check_systems_ready, _print_to_console, is_empty, delete_object

### `_cmd_ragdoll_command()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, Vector3, str, is_empty, has_method, to_lower, get_body, get_tree, get_nodes_in_group

### `_cmd_physics()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_world_3d, str, is_empty, area_set_param, to_float, get_setting, get_tree

### `_cmd_make_ragdoll_say()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** join, _print_to_console, is_empty, make_ragdoll_say

### `_cmd_scene()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** list_available_scenes, is_empty, _print_to_console

### `_cmd_load_scene()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, load, add_child, get_node_or_null, is_empty, set_script, load_scene, load_static_scene, get_tree

### `_cmd_save_scene()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, is_empty, save_current_scene

### `_cmd_ragdoll_walk()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, start_walking, stop_walking, has_method, is_empty, walk, toggle_walking, get_tree, get_nodes_in_group

### `_cmd_spawn_ragdoll()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** create_ragdoll, _print_to_console, _check_systems_ready

### `_cmd_spawn_skeleton_ragdoll()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** randf_range, _print_to_console, add_child, Vector3, get_tree, create_object

### `_cmd_create_sun()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _check_systems_ready, create_sun

### `_cmd_create_astral_being()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _cmd_spawn_being, get_node_or_null, create_astral_being, _check_systems_ready

### `_cmd_astral_control()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get, _print_to_console, is_valid_int, get_being_status, str, has_method, to_lower, handle_console_command, slice, get_tree, size, get_nodes_in_group, int

### `_cmd_create_pathway()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** create_pathway, _print_to_console, _check_systems_ready

### `_cmd_create_bush()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** create_bush, _print_to_console, _check_systems_ready

### `_cmd_create_fruit()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _check_systems_ready, create_fruit

### `_cmd_create_pigeon()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** create_pigeon, _check_systems_ready, _print_to_console

### `_cmd_generate_world()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** generate_procedural_world, _print_to_console, new, load, add_child, get_node_or_null, set_script, to_int, get_tree, size

### `_cmd_scene_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, _print_to_console, get_node_or_null, get_current_scene_info

### `_cmd_restore_ground()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _ensure_ground_visible, _print_to_console, get_node_or_null

### `_cmd_passive_mode()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_status, _print_to_console, set_auto_commit, stop_passive_mode, is_empty, set_token_budget, to_lower, set_require_approval, size, start_passive_mode, int

### `_cmd_add_task()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** add_task, _print_to_console, is_empty, size

### `_cmd_branch()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_status, create_branch, _print_to_console, switch_branch, is_empty, to_lower, size

### `_cmd_commit()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** join, _print_to_console, commit, is_empty

### `_cmd_merge_request()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, create_mr, is_empty, to_lower, join, approve_mr, slice, size

### `_cmd_merge()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** merge, _print_to_console, is_empty

### `_cmd_workflow_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_status, _print_to_console, is_empty, show_diff

### `_cmd_test_features()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, run_zone_test, str, is_empty, run_full_test_suite, get_test_status, size

### `_cmd_test_being_assets()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, add_child, run_tests, load, queue_free

### `_cmd_gizmo()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, load, add_child, get_first_node_in_group, set_script, get_child_count, is_empty, has_method, _cmd_gizmo, get_child, get_tree, add_to_group

### `_cmd_version_control()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, is_empty

### `_cmd_physics_control()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, str, Vector3, is_empty, set_gravity_center, to_float, to_upper, set_scene_zero_point, get_state_info, size

### `_cmd_project_manager()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, list_projects, switch_project, str, is_empty, get_all_projects_status, get_current_project_status, size, int

### `_cmd_timing_info()`
- **Lines:** 4
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_timing_report

### `_cmd_debug_screen()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, add_child, queue_free, preload, set_script, get_tree, size

### `_cmd_select_object()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, is_valid_int, find, str, call, get_first_node_in_group, is_empty, to_int, to_lower, get_tree, range, size, get_nodes_in_group

### `_cmd_move_object()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, call, Vector3, str, to_float, size

### `_cmd_rotate_object()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, Vector3, call, str, to_float, deg_to_rad, rad_to_deg, size

### `_cmd_scale_object()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, Vector3, call, str, is_empty, to_float, size

### `_cmd_awaken_object()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _state_to_string, is_empty, _find_object_by_name_or_id, set_object_state, get_object_state

### `_cmd_change_state()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _string_to_state, _print_to_console, _state_to_string, to_lower, _find_object_by_name_or_id, set_object_state, get_object_state, size

### `_find_object_by_name_or_id()`
- **Lines:** 0
- **Parameters:** `target: String`
- **Returns:** `Node3D`
- **Calls:** is_valid_int, find, to_int, to_lower, get_tree, size, get_nodes_in_group

### `_string_to_state()`
- **Lines:** 0
- **Parameters:** `state_name: String`
- **Returns:** `int`

### `_state_to_string()`
- **Lines:** 0
- **Parameters:** `state: int`
- **Returns:** `String`

### `_cmd_timer_control()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_timer_report, _print_to_console, get_session_metrics, switch_project, set_wait_threshold, str, is_empty, to_float, size, int

### `_cmd_task_management()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_session_metrics, str, is_empty, complete_task, join, start_task, slice, size

### `_cmd_multi_todos()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_session_summary, _print_to_console, add_todo, complete_todo, str, is_empty, join, get_formatted_todos, step_back_todo, get_priority_todos, to_upper, slice, modify_todo, size, int

### `_cmd_balance_workload()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_session_summary, _print_to_console, str, balance_workload

### `_cmd_floodgate_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, _print_to_console, get_node_or_null, size

### `_cmd_queue_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _cmd_floodgate_status

### `_cmd_health_check()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** run_health_check, get_tree, has_method, _print_to_console

### `_cmd_test_floodgate()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_tree, test_floodgate, has_method, _print_to_console

### `_cmd_system_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, is_ready, has_method, get_tree

### `_find_ragdoll_controller()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node`
- **Calls:** get_tree, get_node_or_null

### `_find_astral_beings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node`
- **Calls:** get_tree, get_node_or_null

### `_cmd_ragdoll_come_here()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, cmd_ragdoll_come_here, _find_ragdoll_controller, has_method

### `_cmd_ragdoll_pickup_nearest()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _find_ragdoll_controller, has_method, cmd_ragdoll_pickup_nearest

### `_cmd_ragdoll_drop()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** cmd_ragdoll_drop, _find_ragdoll_controller, has_method, _print_to_console

### `_cmd_ragdoll_organize()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** cmd_ragdoll_organize, _print_to_console, _find_ragdoll_controller, has_method

### `_cmd_ragdoll_patrol()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** cmd_ragdoll_patrol, _find_ragdoll_controller, has_method, _print_to_console

### `_cmd_beings_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** cmd_beings_status, _find_astral_beings, _print_to_console, has_method

### `_cmd_beings_help_ragdoll()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _find_astral_beings, cmd_beings_help_ragdoll, has_method, _print_to_console

### `_cmd_beings_organize()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _find_astral_beings, _print_to_console, has_method, cmd_beings_organize

### `_cmd_beings_harmony()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _find_astral_beings, cmd_beings_harmony, has_method, _print_to_console

### `_cmd_setup_systems()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, has_method, get_tree, _setup_ragdoll_system, _setup_mouse_interaction

### `_cmd_test_mouse_click()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, has_method, cmd_toggle_debug_panel, get_tree

### `_cmd_object_inspector()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, str, get_node_or_null, has_method, is_empty, to_lower, get_debug_panel_status, show_debug_panel, cmd_toggle_debug_panel, get_tree, _setup_mouse_interaction, get, hide_debug_panel

### `_cmd_object_info()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** append_array, _print_to_console, get_class, get_children, length, join, pop_front, get_tree, get_groups, size

### `_cmd_action_list()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _find_mouse_interaction_system, _print_to_console, str, has, size

### `_cmd_action_test()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _find_mouse_interaction_system, _print_to_console, get_node_or_null, queue_action, get_tree, size, get_nodes_in_group

### `_cmd_action_combo()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _find_mouse_interaction_system, process_combo_input, _print_to_console, create_timer, hold, double, triple, get_tree, size

### `_find_mouse_interaction_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node`
- **Calls:** get_tree, get_node_or_null, has_method, get_nodes_in_group

### `_cmd_dimension_shift()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, to_lower, capitalize, _find_dimensional_ragdoll, shift_dimension, size

### `_cmd_consciousness_add()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** add_consciousness_experience, _print_to_console, _find_dimensional_ragdoll, float, size

### `_cmd_emotion_set()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, set_emotion, clamp, _find_dimensional_ragdoll, float, size

### `_cmd_cast_spell()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, size, _find_dimensional_ragdoll, cast_spell

### `_cmd_ragdoll_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_state, _print_to_console, str, _find_dimensional_ragdoll, f, size

### `_find_dimensional_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node`
- **Calls:** get_node_or_null

### `_cmd_console_debug_toggle()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, add_child, load, queue_free, get_node_or_null, get_tree

### `_cmd_performance_stats()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, d, get_node_or_null, has_method, get_monitor, get_performance_stats

### `_cmd_process_manager()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, set_debug_enabled, new, load, add_child, get_node_or_null, is_empty, to_lower, get_tree, size

### `_cmd_debug_panel_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _find_mouse_interaction_system, _print_to_console, get_parent, str, has_method, get_viewport, get_visible_rect

### `_cmd_object_limits()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, size, get_object_statistics

### `_cmd_talk_to_beings()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_status, _print_to_console, speak, is_empty, has_method, randi, get_tree, range, size, get_nodes_in_group

### `_cmd_being_count()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_status, get, _print_to_console, has_method, capitalize, get_tree, size, get_nodes_in_group

### `_cmd_help_ragdoll()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, stop_helping, load, add_child, get_node_or_null, set_script, start_helping_ragdoll, get_tree, size

### `_cmd_jsh_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, has_node

### `_cmd_container()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_children, new, add_child, queue_free, s, get_child_count, get_node_or_null, get_tree, size

### `_cmd_thread_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_status, _print_to_console, get_node, has_node, has_method, get_processor_count, get

### `_cmd_scene_tree()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node, has_node, get_tree, _print_scene_tree_recursive

### `_print_scene_tree_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node, depth: int`
- **Returns:** `void`
- **Calls:** _print_to_console, get_children, repeat, _print_scene_tree_recursive

### `_cmd_akashic_save()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _cmd_save_scene, _print_to_console, get_node, has_node, has_method, save_scene_state, size

### `_cmd_akashic_load()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, load_scene_state, get_node, has_node, has_method, _cmd_load_scene, size

### `_cmd_physics_test()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, add_child, load, queue_free, set_script, handle_physics_command, size

### `_cmd_inspect_object()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_class, _print_to_console, contains, is_valid_int, get_first_node_in_group, to_lower, _find_node_by_name, get_tree, inspect_object, size, get_nodes_in_group, int

### `_find_node_by_name()`
- **Lines:** 0
- **Parameters:** `root: Node, name: String`
- **Returns:** `Node`
- **Calls:** _find_node_by_name, contains, get_children, to_lower

### `_cmd_ragdoll_debug()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, load, add_child, queue_free, get_first_node_in_group, set_script, set_ragdoll, to_lower, toggle_debug_option, get_tree, size

### `_show_debug_physics_info()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get, _print_to_console, str, get_meta, get_node_or_null, is_empty, has, get_frames_per_second, get_setting, get_tree, has_meta, size, get_nodes_in_group

### `_cmd_ragdoll_move()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, Vector2, str, get_first_node_in_group, get_node_or_null, has_method, to_lower, set_movement_input, execute_movement_command, move, get_tree, float, size

### `_cmd_ragdoll_speed()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_first_node_in_group, get_node_or_null, has_method, to_lower, set_speed_mode, get_tree, size

### `_cmd_ragdoll_run()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, get_first_node_in_group, has_method, set_speed_mode, get_current_state, get_tree

### `_cmd_ragdoll_crouch()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** trigger_crouch, _print_to_console, get_node_or_null, get_first_node_in_group, has_method, get_tree

### `_cmd_ragdoll_jump()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, get_first_node_in_group, has_method, trigger_jump, get_tree

### `_cmd_ragdoll_rotate()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_first_node_in_group, get_node_or_null, has_method, to_lower, get_tree, set_rotation_input, size

### `_cmd_ragdoll_stand()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, get_first_node_in_group, has_method, _enter_state, stand_up, get_tree

### `_cmd_ragdoll_state()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_state_name, str, get_node_or_null, get_first_node_in_group, has_method, has, get_tree

### `_cmd_tutorial()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, to_lower, _cmd_tutorial_stop, slice, _cmd_tutorial_start, size, _cmd_tutorial_status

### `_cmd_tutorial_start()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** start_tutorial, _print_to_console, new, load, add_child, get_node_or_null, set_script, has_method, get_tree

### `_cmd_tutorial_stop()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** stop_tutorial, get_node_or_null, has_method, _print_to_console

### `_cmd_tutorial_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_current_phase, get_node_or_null, is_tutorial_active, has_method

### `_cmd_tutorial_hide()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** is_tutorial_active, _print_to_console, get_node_or_null, has_method

### `_cmd_tutorial_show()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** is_tutorial_active, _print_to_console, get_node_or_null, has_method

### `_cmd_spawn_ragdoll_v2()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, load, add_child, queue_free, Vector3, str, set_script, has_method, get_mouse_world_position, spawn_ragdoll_v2, get_tree, float, size

### `_cmd_ragdoll2_move()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, Vector2, get_meta, get_first_node_in_group, to_lower, set_movement_input, get_tree, size

### `_cmd_ragdoll2_state()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, str, get_meta, get_first_node_in_group, has_method, get_tree, get_state_info

### `_cmd_ragdoll2_debug()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_meta, get_first_node_in_group, enable_debug, has, get_tree

### `_cmd_interactive_tutorial()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, load, add_child, get_node_or_null, set_script, get_tree, show_tutorial

### `_cmd_universal_being()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _ubeing_connect, _ubeing_transform, _ubeing_list, _ubeing_inspect, _ubeing_create, _ubeing_interface, slice, _ubeing_edit, size

### `_ubeing_create()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_create_universal_being, _print_to_console, is_valid_float, _get_mouse_world_position, get_ticks_msec, get_node, Vector3, str, get_node_or_null, s, to_float, capitalize, second_dimensional_magic, load_universal_being, size

### `_ubeing_transform()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, str, get_node_or_null, s, _find_universal_being, get_path, become, size, queue_transform_universal_being

### `_ubeing_edit()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** first_dimensional_magic, _print_to_console, get_node, _find_universal_being, size

### `_ubeing_connect()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, str, get_node_or_null, s, _find_universal_being, get_path, queue_connect_universal_beings, size, connect_to

### `_ubeing_list()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get, _print_to_console, contains, str, is_empty, Beings, get_full_state, get_tree, size, get_nodes_in_group

### `_ubeing_inspect()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, str, _find_universal_being, get_full_state, size, get

### `_ubeing_interface()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, load, add_child, get_node, Vector3, set_script, has_method, to_float, capitalize, _register_node, get_tree, add_to_group, size, become_interface

### `_find_universal_being()`
- **Lines:** 0
- **Parameters:** `identifier: String`
- **Returns:** `void`
- **Calls:** get_tree, contains, get_nodes_in_group

### `_cmd_ui_create()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _ubeing_interface, size

### `_cmd_grid_show()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, new, load, get_node, Vector3, get_first_node_in_group, has_method, _populate_grid_data, second_dimensional_magic, get_tree, add_to_group, size, become_interface

### `_cmd_txt_rules()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** create_editor, _print_to_console, Vector2, new, set_anchors_and_offsets_preset, add_child, load, queue_free, connect, set_position, Color, get_tree

### `_get_mouse_world_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`
- **Calls:** project_ray_normal, get_mouse_position, get_world_3d, new, get_viewport, intersect_ray, project_ray_origin, has, Plane, get_tree, intersects_ray, get_camera_3d

### `_cmd_list_scene_objects()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _list_children_recursive, get_tree, _print_to_console

### `_list_children_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node, depth: int, count_ref: int`
- **Returns:** `int`
- **Calls:** get_class, _print_to_console, get_children, _list_children_recursive, s, at, repeat

### `_cmd_open_asset_creator()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_create_universal_being, _print_to_console, _get_mouse_world_position, Being, new, load, add_child, get_node_or_null, set_script, connect, has_signal, get_tree, get_nodes_in_group

### `_cmd_test_cube()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** randf_range, _print_to_console, new, bind, add_child, str, Vector3, randf, connect, randi, Color, get_tree

### `_on_cube_clicked()`
- **Lines:** 0
- **Parameters:** `camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int, cube: RigidBody3D`
- **Returns:** `void`
- **Calls:** Vector3, _print_to_console, apply_central_impulse

### `_cmd_inspect_cube()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_class, _print_to_console, get_children, has_method, cube, begins_with, get_tree

### `_cmd_viewport_info()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, units, Zone, get_viewport, get_render_scale, rad_to_deg, get_visible_rect, deg_to_rad, tan, get_tree, find_child, float

### `_cmd_camera_rays()`
- **Lines:** 49
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, Vector2, new, get_world_3d, distance_to, range, get_viewport, project_position, intersect_ray, get_visible_rect, normalized, get_tree, find_child, camera, size


## scripts/autoload/dialogue_system.gd
**Category:** Core Systems - Autoload
**Functions:** 5

### `make_ragdoll_say()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** _say_something_custom, has_method, is_empty, append, get_tree, get_nodes_in_group

### `get_next_custom_dialogue()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** pop_front, is_empty

### `set_mood()`
- **Lines:** 0
- **Parameters:** `new_mood: String`
- **Returns:** `void`

### `modify_dialogue()`
- **Lines:** 0
- **Parameters:** `base_text: String`
- **Returns:** `String`
- **Calls:** randi, size

### `show_dialogue()`
- **Lines:** 20
- **Parameters:** `text: String, position: Vector3`
- **Returns:** `void`
- **Calls:** new, add_child, tween_callback, Vector3, set_parallel, tween_property, Color, get_tree, chain, create_tween


## scripts/autoload/dynamic_viewport_manager.gd
**Category:** Core Systems - Autoload
**Functions:** 17

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _register_commands, _detect_and_apply_optimal_settings, print

### `_detect_and_apply_optimal_settings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** window_get_current_screen, screen_get_size, screen_get_usable_rect, print

### `_register_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** mode, register_command, get_node_or_null, size

### `_set_window_size()`
- **Lines:** 0
- **Parameters:** `size: Vector2i`
- **Returns:** `void`
- **Calls:** emit, get_window, print, window_set_size

### `_center_window()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** screen_get_position, screen_get_size, window_set_position, window_get_size, print

### `_set_fullscreen()`
- **Lines:** 0
- **Parameters:** `enabled: bool`
- **Returns:** `void`
- **Calls:** emit, _detect_and_apply_optimal_settings, window_set_mode

### `_cmd_viewport_info()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, screen_get_size, screen_get_scale, get_node, window_get_size, get_screen_count, get_viewport, _get_aspect_ratio_name, window_get_mode, _get_window_mode_name, screen_get_dpi, get_visible_rect, window_get_position, float

### `_cmd_set_window_size()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** laptop, _print_to_console, QHD, get_node, clamp, _center_window, _set_window_size, Vector2i, HD, size, int

### `_cmd_toggle_fullscreen()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node, _set_fullscreen, to_lower, size

### `_cmd_set_window_mode()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node, to_lower, window_set_mode, size

### `_cmd_center_window()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, _center_window

### `_cmd_list_screens()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** screen_get_position, _print_to_console, screen_get_size, screen_get_scale, get_node, get_screen_count, screen_get_dpi, range

### `_cmd_move_to_screen()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node, get_screen_count, _center_window, window_set_current_screen, size, int

### `_get_window_mode_name()`
- **Lines:** 0
- **Parameters:** `mode: int`
- **Returns:** `String`

### `_get_aspect_ratio_name()`
- **Lines:** 0
- **Parameters:** `ratio: float`
- **Returns:** `String`
- **Calls:** abs

### `_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** is_action_pressed, set_input_as_handled, _set_fullscreen, get_viewport

### `_notification()`
- **Lines:** 11
- **Parameters:** `what: int`
- **Returns:** `void`
- **Calls:** emit, screen_get_dpi, window_get_size, print


## scripts/autoload/layer_reality_system.gd
**Category:** Core Systems - Autoload
**Functions:** 32

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_debug_draw, _initialize_layers, set_process_unhandled_input

### `_initialize_layers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, str, set_layer_visibility, values

### `_setup_debug_draw()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_debug_material, new, add_child

### `_create_debug_material()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `StandardMaterial3D`
- **Calls:** new

### `_unhandled_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** cycle_view_mode, toggle_layer, align_to_camera, toggle_split_screen, align_to_origin

### `set_layer_visibility()`
- **Lines:** 0
- **Parameters:** `layer: Layer, visible: bool`
- **Returns:** `void`
- **Calls:** emit, erase, has, append, _update_viewport_layout

### `toggle_layer()`
- **Lines:** 0
- **Parameters:** `layer: Layer`
- **Returns:** `void`
- **Calls:** set_layer_visibility, get

### `cycle_view_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, _apply_view_mode

### `_apply_view_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** values, set_layer_visibility

### `_update_viewport_layout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_quad_view, _setup_single_view, get_viewport, _setup_dual_view, get_visible_rect, _setup_triple_view, size

### `_setup_single_view()`
- **Lines:** 0
- **Parameters:** `_screen_size: Vector2`
- **Returns:** `void`

### `_setup_dual_view()`
- **Lines:** 0
- **Parameters:** `_screen_size: Vector2`
- **Returns:** `void`

### `_setup_triple_view()`
- **Lines:** 0
- **Parameters:** `_screen_size: Vector2`
- **Returns:** `void`

### `_setup_quad_view()`
- **Lines:** 0
- **Parameters:** `_screen_size: Vector2`
- **Returns:** `void`

### `add_debug_point()`
- **Lines:** 0
- **Parameters:** `position: Vector3, color: Color = Color.WHITE, size: float = 0.1`
- **Returns:** `void`
- **Calls:** append, _update_debug_draw

### `add_debug_line()`
- **Lines:** 0
- **Parameters:** `from: Vector3, to: Vector3, color: Color = Color.WHITE`
- **Returns:** `void`
- **Calls:** append, _update_debug_draw

### `add_debug_path()`
- **Lines:** 0
- **Parameters:** `points: PackedVector3Array, color: Color = Color.GREEN`
- **Returns:** `void`
- **Calls:** add_debug_line, range, size

### `clear_debug_draw()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, _update_debug_draw

### `_update_debug_draw()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** surface_add_vertex, Vector3, surface_set_color, surface_end, surface_begin, clear_surfaces

### `align_to_camera()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has, get_viewport, get_camera_3d

### `align_to_origin()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** values, has

### `add_to_layer()`
- **Lines:** 0
- **Parameters:** `node: Node, layer: Layer`
- **Returns:** `void`
- **Calls:** has, add_child

### `remove_from_layer()`
- **Lines:** 0
- **Parameters:** `node: Node, layer: Layer`
- **Returns:** `void`
- **Calls:** remove_child, has, get_parent

### `add_text_entity()`
- **Lines:** 0
- **Parameters:** `id: String, text: String, world_pos: Vector3`
- **Returns:** `void`
- **Calls:** get_ticks_msec, get_node, call, has_node

### `update_height_map()`
- **Lines:** 0
- **Parameters:** `position: Vector2, height: float, color: Color`
- **Returns:** `void`

### `toggle_split_screen()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, push_warning

### `get_active_layers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** duplicate

### `is_layer_visible()`
- **Lines:** 0
- **Parameters:** `layer: Layer`
- **Returns:** `bool`
- **Calls:** get

### `get_layer_node()`
- **Lines:** 0
- **Parameters:** `layer: Layer`
- **Returns:** `Node3D`
- **Calls:** get

### `register_console_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** push_error, get_node, has_node, print

### `_console_layer_command()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** set_layer_visibility, is_empty, size, toggle_layer

### `_console_reality_command()`
- **Lines:** 6
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** str, is_empty, cycle_view_mode


## scripts/autoload/multi_todo_manager.gd
**Category:** Core Systems - Autoload
**Functions:** 13

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, _initialize_default_todos

### `_initialize_default_todos()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_todo

### `add_todo()`
- **Lines:** 0
- **Parameters:** `project_id: String, content: String, priority: String = "medium"`
- **Returns:** `bool`
- **Calls:** get_ticks_msec, append, generate_todo_id, print

### `complete_todo()`
- **Lines:** 0
- **Parameters:** `project_id: String, todo_id: String`
- **Returns:** `bool`
- **Calls:** get_ticks_msec, range, size, print

### `modify_todo()`
- **Lines:** 0
- **Parameters:** `project_id: String, todo_id: String, new_content: String, reason: String = ""`
- **Returns:** `bool`
- **Calls:** get_ticks_msec, append, print

### `step_back_todo()`
- **Lines:** 0
- **Parameters:** `project_id: String, todo_id: String`
- **Returns:** `bool`
- **Calls:** print, size, pop_back

### `get_project_todos()`
- **Lines:** 0
- **Parameters:** `project_id: String`
- **Returns:** `Array`

### `get_all_pending_todos()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** append

### `get_priority_todos()`
- **Lines:** 0
- **Parameters:** `priority: String`
- **Returns:** `Array`
- **Calls:** append

### `get_session_summary()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec, size

### `generate_todo_id()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_ticks_msec, str

### `get_formatted_todos()`
- **Lines:** 0
- **Parameters:** `project_id: String = ""`
- **Returns:** `String`
- **Calls:** else, to_upper

### `balance_workload()`
- **Lines:** 20
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_priority_todos, size


## scripts/autoload/scene_loader.gd
**Category:** Core Systems - Autoload
**Functions:** 13

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, file_exists, save_default_scene, _copy_example_scenes, make_dir, dir_exists

### `_copy_example_scenes()`
- **Lines:** 7
- **Parameters:** ``
- **Returns:** `void`

### `save_default_scene()`
- **Lines:** 7
- **Parameters:** ``
- **Returns:** `void`

### `load_scene()`
- **Lines:** 0
- **Parameters:** `scene_name: String`
- **Returns:** `bool`
- **Calls:** eof_reached, clear_all_objects, open, _parse_scene_line, file_exists, close, queue_free, is_empty, get_line, emit_signal, print, begins_with, get_tree, strip_edges, get_nodes_in_group
- **Signals:** scene_loaded

### `_parse_scene_line()`
- **Lines:** 0
- **Parameters:** `line: String, line_number: int`
- **Returns:** `void`
- **Calls:** _create_ragdoll_at_position, str, Vector3, to_lower, to_float, _create_object_at_position, print, range, size, split

### `_create_object_at_position()`
- **Lines:** 0
- **Parameters:** `type: String, position: Vector3, properties: Dictionary`
- **Returns:** `void`
- **Calls:** create_bush, get_spawned_objects, create_rock, create_ball, create_fruit, is_empty, create_astral_being, create_tree, create_pathway, _apply_properties, create_box, create_sun, create_ramp

### `_create_ragdoll_at_position()`
- **Lines:** 0
- **Parameters:** `position: Vector3, properties: Dictionary`
- **Returns:** `void`
- **Calls:** _speak_random_dialogue, start_walking, is_empty, has_method, has, print, create_ragdoll, get_tree, get_nodes_in_group

### `_apply_properties()`
- **Lines:** 0
- **Parameters:** `obj: Node3D, properties: Dictionary`
- **Returns:** `void`
- **Calls:** to_float, deg_to_rad

### `save_current_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_spawned_objects, _vector_to_string, open, close, store_line, _object_to_scene_line, get_datetime_string_from_system, is_empty, emit_signal, get_tree, get_nodes_in_group
- **Signals:** scene_saved

### `_object_to_scene_line()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `String`
- **Calls:** str, _vector_to_string, rad_to_deg

### `_vector_to_string()`
- **Lines:** 0
- **Parameters:** `v: Vector3`
- **Returns:** `String`
- **Calls:** str

### `list_available_scenes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** open, get_next, replace, ends_with, append, list_dir_begin

### `create_scene_from_template()`
- **Lines:** 5
- **Parameters:** `scene_name: String, template: String`
- **Returns:** `void`
- **Calls:** open, close, store_string


## scripts/autoload/ui_settings_manager.gd
**Category:** Core Systems - Autoload
**Functions:** 8

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** load_settings, connect, get_viewport

### `load_settings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, load, save_settings, Color, emit_signal, get_value
- **Signals:** settings_changed

### `save_settings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_value, save, new, emit_signal
- **Signals:** settings_changed

### `get_scaled_value()`
- **Lines:** 0
- **Parameters:** `base_value: float`
- **Returns:** `float`

### `get_console_rect()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Rect2`
- **Calls:** Vector2, Rect2, get_viewport

### `set_ui_scale()`
- **Lines:** 0
- **Parameters:** `scale: float`
- **Returns:** `void`
- **Calls:** save_settings, clamp

### `set_console_position()`
- **Lines:** 0
- **Parameters:** `pos: String`
- **Returns:** `void`
- **Calls:** save_settings

### `_on_viewport_size_changed()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit_signal
- **Signals:** settings_changed


## scripts/autoload/universal_object_manager.gd
**Category:** Core Systems - Autoload
**Functions:** 22

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _connect_to_systems, set_process, print

### `_connect_to_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null

### `create_object()`
- **Lines:** 0
- **Parameters:** `type: String, position: Vector3, properties: Dictionary = {}`
- **Returns:** `Node`
- **Calls:** push_error, get_ticks_msec, add_child, is_inside_tree, set_meta, _get_caller_info, emit, _generate_uuid, get_tree, has, print, append, _register_with_all_systems, create_object

### `_register_with_all_systems()`
- **Lines:** 0
- **Parameters:** `uuid: String, obj: Node, type: String, data: Dictionary`
- **Returns:** `void`
- **Calls:** register_spawned_asset, has_method, second_dimensional_magic, append, add_to_group

### `get_object_by_uuid()`
- **Lines:** 0
- **Parameters:** `uuid: String`
- **Returns:** `Node`
- **Calls:** has

### `get_object_by_name()`
- **Lines:** 0
- **Parameters:** `name: String`
- **Returns:** `Node`
- **Calls:** has, get_object_by_uuid

### `get_object_data()`
- **Lines:** 0
- **Parameters:** `uuid: String`
- **Returns:** `Dictionary`
- **Calls:** get

### `get_objects_by_type()`
- **Lines:** 0
- **Parameters:** `type: String`
- **Returns:** `Array`
- **Calls:** append, has

### `get_all_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** values, append, is_instance_valid

### `get_object_count()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `int`
- **Calls:** values, is_instance_valid

### `modify_object()`
- **Lines:** 0
- **Parameters:** `uuid: String, changes: Dictionary`
- **Returns:** `bool`
- **Calls:** set, is_instance_valid, get_ticks_msec, _get_caller_info, emit, has, append

### `destroy_object()`
- **Lines:** 0
- **Parameters:** `uuid: String`
- **Returns:** `bool`
- **Calls:** is_instance_valid, queue_free, emit, erase, has, print

### `destroy_all_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, destroy_object, keys

### `_generate_uuid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_ticks_msec, str

### `_get_caller_info()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** str, get_stack, size

### `get_statistics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_object_count, size

### `_process()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** get_process_frames, is_instance_valid, keys, str, print

### `register_console_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get

### `_cmd_statistics()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `String`
- **Calls:** get_statistics, str

### `_cmd_list_all()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `String`
- **Calls:** str, S, to_upper, get_objects_by_type, size

### `_cmd_inspect()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** str, get_object_data, is_empty, has, size

### `_cmd_clear_all()`
- **Lines:** 5
- **Parameters:** `_args: Array`
- **Returns:** `String`
- **Calls:** destroy_all_objects, str, get_object_count


## scripts/autoload/windows_console_fix.gd
**Category:** Core Systems - Autoload
**Functions:** 11

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _detect_terminal_capabilities

### `_detect_terminal_capabilities()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** find, get_environment, execute, to_int, get_name, print, size

### `safe_print()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `String`
- **Calls:** _convert_to_ascii

### `_convert_to_ascii()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `String`
- **Calls:** _sanitize_unicode, replace

### `_sanitize_unicode()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `String`
- **Calls:** range, unicode_at, length

### `create_ascii_frame()`
- **Lines:** 0
- **Parameters:** `width: int, height: int, title: String = ""`
- **Returns:** `String`
- **Calls:** range, length, repeat

### `create_progress_bar()`
- **Lines:** 0
- **Parameters:** `current: float, maximum: float, width: int = 20`
- **Returns:** `String`
- **Calls:** repeat, int

### `create_status_display()`
- **Lines:** 0
- **Parameters:** `project: String, status: String, progress: float`
- **Returns:** `String`
- **Calls:** str, to_upper, int, create_progress_bar

### `console_print()`
- **Lines:** 0
- **Parameters:** `manager: Node, text: String`
- **Returns:** `void`
- **Calls:** _print_to_console, safe_print, has_method, print

### `test_terminal_calibration()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_ascii_frame, str, create_status_display, safe_print, print

### `patch_console_manager()`
- **Lines:** 10
- **Parameters:** `console_manager: Node`
- **Returns:** `void`
- **Calls:** set_meta, has_method


## scripts/autoload/world_builder.gd
**Category:** Core Systems - Autoload
**Functions:** 27

### `debug_print()`
- **Lines:** 0
- **Parameters:** `message: String, level: int = 2`
- **Returns:** `void`
- **Calls:** print

### `_get_std_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node`
- **Calls:** get_node_or_null

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, debug_print, push_error

### `get_mouse_spawn_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`
- **Calls:** randf_range, project_ray_normal, get_mouse_position, get_world_3d, new, Vector3, get_viewport, intersect_ray, project_ray_origin, get_tree, get_camera_3d

### `create_tree()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, get_mouse_spawn_position, second_dimensional_magic, debug_print, append, create_object, _fallback_create_tree

### `_fallback_create_tree()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, _get_std_objects, get_mouse_spawn_position, append, get_tree, create_object

### `create_rock()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, get_mouse_spawn_position, second_dimensional_magic, debug_print, _fallback_create_rock, append, create_object

### `create_box()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, _fallback_create_box, get_mouse_spawn_position, second_dimensional_magic, debug_print, append, create_object

### `create_ball()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, get_mouse_spawn_position, _fallback_create_ball, second_dimensional_magic, debug_print, append, create_object

### `create_ramp()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, _fallback_create_ramp, get_mouse_spawn_position, second_dimensional_magic, debug_print, append, create_object

### `create_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, queue_free, is_empty, get_mouse_spawn_position, debug_print, get_tree, create_object, get_nodes_in_group

### `create_sun()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, set_freeze_enabled, has_method, get_mouse_spawn_position, append, get_tree, create_object

### `create_astral_being()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, load, add_child, str, set_script, get_mouse_spawn_position, second_dimensional_magic, debug_print, randi, print, append, get_tree, add_to_group, size, get

### `create_pathway()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, get_mouse_spawn_position, append, get_tree, create_object

### `create_bush()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, get_mouse_spawn_position, append, get_tree, create_object

### `create_fruit()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, get_mouse_spawn_position, append, get_tree, create_object

### `create_pigeon()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, setup, load, add_child, str, set_script, get_mouse_spawn_position, second_dimensional_magic, print, append, get_tree, add_to_group, get

### `clear_all_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `int`
- **Calls:** is_instance_valid, queue_free, str, get_path, fifth_dimensional_magic, print, clear, size

### `get_spawned_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array[Node3D]`
- **Calls:** filter, is_instance_valid

### `register_world_object()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `void`
- **Calls:** append, debug_print, is_instance_valid

### `delete_object()`
- **Lines:** 0
- **Parameters:** `object_name: String`
- **Returns:** `bool`
- **Calls:** is_instance_valid, queue_free, erase, get_path, fifth_dimensional_magic, print

### `_fallback_create_rock()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, get_mouse_spawn_position, append, get_tree, create_object

### `_fallback_create_box()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, get_mouse_spawn_position, append, get_tree, create_object

### `_fallback_create_ball()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, get_mouse_spawn_position, append, get_tree, create_object

### `_fallback_create_ramp()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, get_mouse_spawn_position, append, get_tree, create_object

### `create_object()`
- **Lines:** 0
- **Parameters:** `object_type: String`
- **Returns:** `void`
- **Calls:** get_node_or_null, has_method, _fallback_create_object, get_mouse_spawn_position, second_dimensional_magic, debug_print, append, create_object, add_to_group

### `_fallback_create_object()`
- **Lines:** 14
- **Parameters:** `object_type: String`
- **Returns:** `void`
- **Calls:** add_child, get_node_or_null, get_mouse_spawn_position, debug_print, append, get_tree, create_object


## scripts/components/multi_layer_entity.gd
**Category:** Component Systems
**Functions:** 12

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, get_node_or_null, is_empty, get_instance_id, connect, _create_layer_representations

### `_create_layer_representations()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_debug_representation

### `_create_debug_representation()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_to_layer, new

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** distance_to, _update_map_layer, _update_text_layer, is_empty, _update_debug_layer, append, remove_at, size

### `_update_text_layer()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_text_entity, has_method, is_layer_visible, get

### `_update_map_layer()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, clamp, is_layer_visible, update_height_map, lerp

### `_update_debug_layer()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_debug_path, call, length, is_layer_visible, has_method, add_debug_point, clear_debug_draw, normalized, add_debug_line, size, lerp

### `_on_layer_visibility_changed()`
- **Lines:** 0
- **Parameters:** `layer: int, visible: bool`
- **Returns:** `void`
- **Calls:** _update_map_layer, clear_debug_draw, _update_text_layer, _update_debug_layer

### `set_text_state()`
- **Lines:** 0
- **Parameters:** `state: String`
- **Returns:** `void`

### `set_map_icon()`
- **Lines:** 0
- **Parameters:** `icon: String, color: Color = Color.WHITE`
- **Returns:** `void`

### `add_debug_marker()`
- **Lines:** 0
- **Parameters:** `offset: Vector3, color: Color, label: String = ""`
- **Returns:** `void`
- **Calls:** add_debug_point, is_layer_visible

### `get_layer_representation()`
- **Lines:** 12
- **Parameters:** `layer: int`
- **Returns:** `Variant`


## scripts/core/advanced_being_system.gd
**Category:** Core Systems
**Functions:** 20

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_animation_system, _setup_spring_bones, _setup_ik_systems, _create_skeleton, _setup_physics_bones, print

### `_create_skeleton()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_custom_skeleton, _create_humanoid_skeleton, new, add_child

### `_create_humanoid_skeleton()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_bone_parent, Vector3, add_bone, Transform3D, Basis, set_bone_rest

### `_create_custom_skeleton()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_setup_physics_bones()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _get_joint_type, new, add_child, _get_bone_mass, has, append

### `_get_bone_mass()`
- **Lines:** 0
- **Parameters:** `bone_name: String`
- **Returns:** `float`

### `_get_joint_type()`
- **Lines:** 0
- **Parameters:** `bone_name: String`
- **Returns:** `PhysicalBone3D.JointType`

### `_setup_spring_bones()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has, new, add_child

### `_setup_ik_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `_setup_animation_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** NodePath, new, add_child

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_physics, _process_hybrid, _process_recovery, _process_animated, _update_ik_targets

### `_process_animated()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`

### `_process_physics()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`

### `_process_hybrid()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`

### `_process_recovery()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`

### `_update_ik_targets()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `trigger_ragdoll()`
- **Lines:** 0
- **Parameters:** `impact_force: Vector3, impact_point: Vector3`
- **Returns:** `void`
- **Calls:** length

### `set_animation_state()`
- **Lines:** 0
- **Parameters:** `state_name: String`
- **Returns:** `void`

### `blend_to_physics()`
- **Lines:** 0
- **Parameters:** `amount: float`
- **Returns:** `void`
- **Calls:** physics, clamp

### `get_bone_global_transform()`
- **Lines:** 6
- **Parameters:** `bone_name: String`
- **Returns:** `Transform3D`
- **Calls:** Transform3D, has, get_bone_global_pose


## scripts/core/akashic_bridge_system.gd
**Category:** Core Systems
**Functions:** 42

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _attempt_server_connection, _setup_websocket, _print, _setup_http_client, _setup_file_monitoring

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** get_time_dict_from_system, back, _sync_project_state, poll, _process_websocket_messages, values

### `_setup_http_client()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, new, add_child

### `_setup_websocket()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new

### `_attempt_server_connection()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _send_http_request, _print

### `_on_http_response()`
- **Lines:** 0
- **Parameters:** `result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray`
- **Returns:** `void`
- **Calls:** server, create_timer, contains, _attempt_server_connection, _register_with_server, str, _print, emit, get_tree, get_string_from_utf8, _connect_websocket, size

### `_connect_websocket()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _print, connect_to_url

### `_process_websocket_messages()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_packet, get_available_packet_count, _handle_server_message, _print, emit, get_ready_state, get_string_from_utf8

### `_register_with_server()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_base_dir, get_ticks_msec, str, get_executable_path, _send_http_request

### `_send_http_request()`
- **Lines:** 0
- **Parameters:** `endpoint: String, data: Dictionary, method: HTTPClient.Method`
- **Returns:** `void`
- **Calls:** request, stringify

### `_send_websocket_message()`
- **Lines:** 0
- **Parameters:** `message: Dictionary`
- **Returns:** `void`
- **Calls:** send_text, get_ready_state, stringify

### `_handle_server_message()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** _execute_console_command, new, _execute_tutorial_step, _start_tutorial, parse, _handle_file_update, _print, emit, _send_project_state, get

### `_execute_console_command()`
- **Lines:** 0
- **Parameters:** `command: String`
- **Returns:** `void`
- **Calls:** get_children, _on_line_edit_text_submitted, keys, str, get_node_or_null, has_method, _print, slice, map, get_tree, _on_command_submitted

### `_start_tutorial()`
- **Lines:** 0
- **Parameters:** `steps: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _execute_tutorial_step, str, get_node_or_null, has_method, _print, size

### `_execute_tutorial_step()`
- **Lines:** 0
- **Parameters:** `step_index: int`
- **Returns:** `void`
- **Calls:** _tutorial_spawn_object, str, _tutorial_check_system, _print, _tutorial_wait_for_command, _complete_current_step, _tutorial_wait_for_click, _complete_tutorial, size, get

### `_tutorial_wait_for_click()`
- **Lines:** 0
- **Parameters:** `step_data: Dictionary`
- **Returns:** `void`
- **Calls:** _show_tutorial_message, _monitor_tutorial_action, get

### `_tutorial_spawn_object()`
- **Lines:** 0
- **Parameters:** `step_data: Dictionary`
- **Returns:** `void`
- **Calls:** Vector3, str, get_node_or_null, _print, _complete_current_step, create_object, get

### `_tutorial_wait_for_command()`
- **Lines:** 0
- **Parameters:** `step_data: Dictionary`
- **Returns:** `void`
- **Calls:** _show_tutorial_message, _monitor_tutorial_action, get

### `_tutorial_check_system()`
- **Lines:** 0
- **Parameters:** `step_data: Dictionary`
- **Returns:** `void`
- **Calls:** get, has_node, get_node_or_null, _print, _complete_current_step, _show_tutorial_message, get_tree, size, get_nodes_in_group

### `_show_tutorial_message()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, has_method

### `_monitor_tutorial_action()`
- **Lines:** 0
- **Parameters:** `action_type: String, target: String`
- **Returns:** `void`

### `_complete_current_step()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, _send_websocket_message, _execute_tutorial_step, emit, _complete_tutorial, get_tree, size, get

### `_complete_tutorial()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, has_method, _print

### `_setup_file_monitoring()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_file_checksum, _ensure_file_exists

### `_ensure_file_exists()`
- **Lines:** 0
- **Parameters:** `file_path: String`
- **Returns:** `void`
- **Calls:** get_base_dir, open, make_dir_recursive, store_line, file_exists, get_file, close, replace, dir_exists

### `_update_file_checksum()`
- **Lines:** 0
- **Parameters:** `file_path: String`
- **Returns:** `void`
- **Calls:** get_as_text, open, close, hash

### `_check_file_changes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_as_text, open, close, file_exists, _handle_file_changed, get, hash

### `_handle_file_changed()`
- **Lines:** 0
- **Parameters:** `file_path: String, content: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, emit, _send_websocket_message, _print

### `_handle_file_update()`
- **Lines:** 0
- **Parameters:** `file_path: String, content: String`
- **Returns:** `void`
- **Calls:** _update_file_checksum, open, close, _print, store_string

### `_sync_project_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_time_dict_from_system, _send_websocket_message, back, get_ticks_msec, _update_project_state, values

### `_update_project_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _count_spawned_objects, _get_systems_status, _get_available_commands, get_node_count, get_tree, get_frames_per_second

### `_get_systems_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_tree, get_node_or_null, get_first_node_in_group

### `_count_spawned_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `int`
- **Calls:** get_tree, _count_nodes_recursive

### `_count_nodes_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `int`
- **Calls:** _count_nodes_recursive, get_children

### `_get_available_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** get_node_or_null, keys

### `_send_project_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_project_state, _send_websocket_message

### `register_console_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_command, get_node_or_null, has_method

### `_cmd_connect()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** _attempt_server_connection

### `_cmd_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get_ticks_msec, str, size

### `_cmd_sync()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** _check_file_changes, _sync_project_state

### `_cmd_tutorial()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** str, active, size, _send_websocket_message

### `_print()`
- **Lines:** 2
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** print


## scripts/core/akashic_records_database.gd
**Category:** Core Systems
**Functions:** 20

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _initialize_core_records, _start_server_connection, print

### `_initialize_core_records()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `create_record()`
- **Lines:** 0
- **Parameters:** `type: String, data: Dictionary`
- **Returns:** `String`
- **Calls:** get_ticks_msec, _generate_akashic_id, emit_signal, append, get
- **Signals:** record_created

### `query_records()`
- **Lines:** 0
- **Parameters:** `criteria: Dictionary`
- **Returns:** `Array`
- **Calls:** _matches_criteria, append

### `manifest_record()`
- **Lines:** 0
- **Parameters:** `record_id: String, forced_lod: String = ""`
- **Returns:** `Node`
- **Calls:** _calculate_lod, _manifest_as_text, is_empty, _manifest_as_2d_simple, _manifest_as_2d_detailed, _manifest_as_3d_detailed, _find_record, has, _manifest_fully, emit_signal, _manifest_as_3d_simple
- **Signals:** record_manifested

### `_manifest_as_text()`
- **Lines:** 11
- **Parameters:** `record: Dictionary`
- **Returns:** `Node`
- **Calls:** set_meta, new

### `get_text_representation()`
- **Lines:** 5
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** str, get_meta, get_meta_list

### `_manifest_as_2d_simple()`
- **Lines:** 0
- **Parameters:** `record: Dictionary`
- **Returns:** `Node2D`
- **Calls:** Vector2, new, add_child, Color, PackedVector2Array, get

### `_manifest_as_3d_simple()`
- **Lines:** 0
- **Parameters:** `record: Dictionary`
- **Returns:** `Node3D`
- **Calls:** new, get, add_child

### `_manifest_as_3d_detailed()`
- **Lines:** 0
- **Parameters:** `record: Dictionary`
- **Returns:** `Node3D`
- **Calls:** new, add_child, has, _manifest_as_3d_simple, get, int

### `_manifest_fully()`
- **Lines:** 0
- **Parameters:** `record: Dictionary`
- **Returns:** `Node3D`
- **Calls:** _manifest_as_3d_detailed, has, instantiate, load

### `_calculate_lod()`
- **Lines:** 0
- **Parameters:** `record: Dictionary`
- **Returns:** `String`
- **Calls:** max, get, distance_to

### `update_all_lods()`
- **Lines:** 0
- **Parameters:** `new_viewer_position: Vector3, new_consciousness: float`
- **Returns:** `void`
- **Calls:** _calculate_lod, is_instance_valid, queue_free, erase, size

### `create_connection()`
- **Lines:** 0
- **Parameters:** `from_id: String, to_id: String, connection_type: String = "linked"`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, _find_record

### `_generate_akashic_id()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_ticks_msec, str, randi

### `_find_record()`
- **Lines:** 0
- **Parameters:** `record_id: String`
- **Returns:** `Dictionary`

### `_matches_criteria()`
- **Lines:** 0
- **Parameters:** `record: Dictionary, criteria: Dictionary`
- **Returns:** `bool`
- **Calls:** get

### `_start_server_connection()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, print

### `generate_text_summary()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** str, size

### `export_to_json()`
- **Lines:** 6
- **Parameters:** `file_path: String = "res://akashic_records.json"`
- **Returns:** `void`
- **Calls:** open, close, store_string, print, stringify


## scripts/core/architecture_harmony_system.gd
**Category:** Core Systems
**Functions:** 17

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _map_script_connections, _scan_project_architecture, _register_harmony_commands, print

### `_scan_project_architecture()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, _analyze_process_usage, _scan_directory, print, size

### `_scan_directory()`
- **Lines:** 0
- **Parameters:** `dir: DirAccess, path: String`
- **Returns:** `void`
- **Calls:** open, get_next, begins_with, _scan_directory, _analyze_script, current_is_dir, ends_with, list_dir_begin

### `_analyze_script()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `void`
- **Calls:** get_as_text, open, close, _extract_extends, get_file, _extract_signals, _physics_process, _process

### `_extract_extends()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `String`
- **Calls:** get_string, search, new, compile

### `_extract_signals()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `Array`
- **Calls:** new, compile, search_all, append, get_string

### `_map_script_connections()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_analyze_process_usage()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** keys, push_warning, emit, print, size

### `get_best_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`

### `get_ragdoll_info()`
- **Lines:** 0
- **Parameters:** `type: String = ""`
- **Returns:** `Dictionary`
- **Calls:** get

### `find_conflicts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** values, append, _guess_purpose

### `_guess_purpose()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `String`
- **Calls:** to_lower, get_file

### `_register_harmony_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null

### `_cmd_architecture_status()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, size, get_best_ragdoll

### `_cmd_ragdoll_status()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, join, s

### `_cmd_process_users()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, users, get_file, get_node, size

### `_cmd_show_conflicts()`
- **Lines:** 11
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node, is_empty, join, find_conflicts


## scripts/core/asset_library.gd
**Category:** Core Systems
**Functions:** 35

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** push_error, str, get_node_or_null, connect, _count_total_assets, print

### `register_asset()`
- **Lines:** 0
- **Parameters:** `category: String, asset_id: String, asset_info: Dictionary`
- **Returns:** `bool`
- **Calls:** print, has, emit_signal, push_error
- **Signals:** asset_catalog_updated

### `unregister_asset()`
- **Lines:** 0
- **Parameters:** `category: String, asset_id: String`
- **Returns:** `bool`
- **Calls:** is_empty, erase, has, emit_signal
- **Signals:** asset_catalog_updated

### `get_asset_info()`
- **Lines:** 0
- **Parameters:** `category: String, asset_id: String`
- **Returns:** `Dictionary`
- **Calls:** has

### `get_assets_by_category()`
- **Lines:** 0
- **Parameters:** `category: String`
- **Returns:** `Dictionary`
- **Calls:** has

### `get_assets_by_tag()`
- **Lines:** 0
- **Parameters:** `tag: String`
- **Returns:** `Array`
- **Calls:** append, has

### `search_assets()`
- **Lines:** 0
- **Parameters:** `search_term: String`
- **Returns:** `Array`
- **Calls:** append, contains, has, to_lower

### `load_asset()`
- **Lines:** 0
- **Parameters:** `category: String, asset_id: String, auto_approve: bool = false`
- **Returns:** `String`
- **Calls:** get_asset_info, queue_operation, push_error, _get_asset_type_enum, is_empty, has, print, append

### `unload_asset()`
- **Lines:** 0
- **Parameters:** `category: String, asset_id: String`
- **Returns:** `bool`
- **Calls:** erase, queue_operation, has, emit_signal
- **Signals:** asset_unloaded

### `preload_category()`
- **Lines:** 0
- **Parameters:** `category: String, auto_approve: bool = false`
- **Returns:** `void`
- **Calls:** load_asset, print, has, push_error

### `preload_by_tag()`
- **Lines:** 0
- **Parameters:** `tag: String, auto_approve: bool = false`
- **Returns:** `void`
- **Calls:** str, get_assets_by_tag, print, size, load_asset

### `spawn_asset()`
- **Lines:** 0
- **Parameters:** `category: String, asset_id: String, parent: Node, position: Vector3 = Vector3.ZERO`
- **Returns:** `String`
- **Calls:** get_asset_info, queue_operation, push_error, is_empty, get_path, has, load_asset

### `_on_asset_approval_needed()`
- **Lines:** 0
- **Parameters:** `asset_path: String`
- **Returns:** `void`
- **Calls:** is_empty, push_warning, emit_signal, _find_asset_by_path, append
- **Signals:** asset_approval_requested

### `approve_asset()`
- **Lines:** 0
- **Parameters:** `full_id: String`
- **Returns:** `void`
- **Calls:** approve_asset, emit_signal, append, remove_at, range, size
- **Signals:** asset_approved

### `reject_asset()`
- **Lines:** 0
- **Parameters:** `full_id: String`
- **Returns:** `void`
- **Calls:** reject_asset, emit_signal, append, remove_at, range, size
- **Signals:** asset_rejected

### `get_pending_approvals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** duplicate

### `auto_approve_all()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** approve_asset, size

### `set_auto_approval()`
- **Lines:** 0
- **Parameters:** `enabled: bool`
- **Returns:** `void`
- **Calls:** set_asset_approval_required

### `_count_total_assets()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `int`
- **Calls:** size

### `_get_asset_type_enum()`
- **Lines:** 0
- **Parameters:** `type_string: String`
- **Returns:** `FloodgateController.AssetType`

### `_find_asset_by_path()`
- **Lines:** 0
- **Parameters:** `path: String`
- **Returns:** `Dictionary`

### `get_catalog_summary()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** size

### `get_loaded_assets_list()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** keys

### `is_asset_loaded()`
- **Lines:** 0
- **Parameters:** `category: String, asset_id: String`
- **Returns:** `bool`
- **Calls:** has

### `get_asset_load_status()`
- **Lines:** 0
- **Parameters:** `category: String, asset_id: String`
- **Returns:** `String`
- **Calls:** has

### `export_catalog()`
- **Lines:** 0
- **Parameters:** `file_path: String`
- **Returns:** `bool`
- **Calls:** open, close, stringify, store_string

### `import_catalog()`
- **Lines:** 0
- **Parameters:** `file_path: String, merge: bool = false`
- **Returns:** `bool`
- **Calls:** get_as_text, open, close, new, push_error, parse, has, emit_signal
- **Signals:** asset_catalog_updated

### `load_universal_being()`
- **Lines:** 0
- **Parameters:** `asset_id: String, variant: String = "default"`
- **Returns:** `void`
- **Calls:** _create_universal_being, load, _get_asset_category, _parse_txt_definition, _create_from_standardized_objects, is_empty, exists, print

### `_create_from_standardized_objects()`
- **Lines:** 0
- **Parameters:** `asset_id: String`
- **Returns:** `void`
- **Calls:** new, load, set_property, capitalize, become, print, add_to_group

### `_get_asset_category()`
- **Lines:** 0
- **Parameters:** `asset_id: String`
- **Returns:** `String`
- **Calls:** has

### `_parse_txt_definition()`
- **Lines:** 0
- **Parameters:** `path: String`
- **Returns:** `Dictionary`
- **Calls:** substr, eof_reached, open, close, find, length, is_empty, get_line, to_lower, _convert_value_type, begins_with, ends_with, strip_edges

### `_convert_value_type()`
- **Lines:** 0
- **Parameters:** `value: String`
- **Returns:** `Variant`
- **Calls:** is_valid_float, Vector3, length, to_int, to_lower, to_float, count, Color, begins_with, strip_edges, size, split

### `_create_universal_being()`
- **Lines:** 0
- **Parameters:** `definition: Dictionary, scene_template: PackedScene, asset_id: String`
- **Returns:** `void`
- **Calls:** new, load, set_property, capitalize, has, print, add_to_group, get

### `create_universal_being()`
- **Lines:** 0
- **Parameters:** `being_type: String, properties: Dictionary = {}`
- **Returns:** `void`
- **Calls:** set, substr, new, load, push_error, _create_from_standardized_objects, has_method, set_script, set_property, _ready, capitalize, become, print, begins_with, load_universal_being, add_to_group, become_interface

### `register_txt_asset()`
- **Lines:** 17
- **Parameters:** `category: String, asset_id: String, txt_path: String, tscn_path: String = ""`
- **Returns:** `void`
- **Calls:** has, print


## scripts/core/astral_being_enhanced_OLD_DEPRECATED.gd
**Category:** Core Systems
**Functions:** 21

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_physics_process, get_node_or_null, _create_star_being, print

### `_create_star_being()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, new, Color, add_child

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_connection_awareness, _process_blinking, _process_following, _process_orbiting, _process_free_flight, _process_creating

### `_process_free_flight()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, distance_to, get_ticks_msec, Vector3, _find_closest_object, is_empty, start_orbiting, cos

### `_process_orbiting()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, is_instance_valid, Vector3, look_at, cos, lerp

### `_process_creating()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, is_instance_valid, _create_trail_light, Vector3, cos, append, float, range, size

### `_process_following()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`

### `_process_blinking()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`

### `_update_connection_awareness()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _is_connected_to, Color, append, clear, size

### `_is_connected_to()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `bool`
- **Calls:** is_in_group, get_groups, get_parent

### `_create_trail_light()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node3D`
- **Calls:** new, add_child

### `_find_closest_object()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node3D`
- **Calls:** distance_to

### `start_orbiting()`
- **Lines:** 0
- **Parameters:** `target: Node3D`
- **Returns:** `void`
- **Calls:** has_method, length, angle_to, get_bounding_box

### `stop_orbiting()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `enter_creation_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, clear, is_instance_valid

### `manipulate_object()`
- **Lines:** 0
- **Parameters:** `target: Node3D, direction: Vector3`
- **Returns:** `bool`
- **Calls:** create_timer, astral_being_manipulate, set_object_state, get_tree, prepare_object_for_manipulation

### `set_following_target()`
- **Lines:** 0
- **Parameters:** `target: Node3D`
- **Returns:** `void`

### `_on_body_entered()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** append

### `_on_body_exited()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** erase, stop_orbiting

### `_on_area_entered()`
- **Lines:** 0
- **Parameters:** `area: Area3D`
- **Returns:** `void`
- **Calls:** append, get_parent

### `_on_area_exited()`
- **Lines:** 5
- **Parameters:** `area: Area3D`
- **Returns:** `void`
- **Calls:** erase, get_parent


## scripts/core/astral_beings_OLD_DEPRECATED.gd
**Category:** Core Systems
**Functions:** 23

### `_init()`
- **Lines:** 0
- **Parameters:** `spawn_pos: Vector3`
- **Returns:** `void`

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _spawn_initial_beings, get_node, str, has_node, get_node_or_null, connect, print, size

### `_spawn_initial_beings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf_range, _create_being_visualization, new, Vector3, append, range

### `_create_being_visualization()`
- **Lines:** 0
- **Parameters:** `being: AstralBeing`
- **Returns:** `void`
- **Calls:** new, add_child, str, Vector3, AABB, size

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_being

### `_update_being()`
- **Lines:** 0
- **Parameters:** `being: AstralBeing, delta: float`
- **Returns:** `void`
- **Calls:** _assist_environmental_harmony, _assist_creative_work, min, _assist_scene_organization, _assist_object_manipulation, normalized, _assist_ragdoll_support

### `_assist_ragdoll_support()`
- **Lines:** 0
- **Parameters:** `being: AstralBeing, delta: float`
- **Returns:** `void`
- **Calls:** get, Vector3, has_method, abs, _help_ragdoll_stand_up, get_body

### `_help_ragdoll_stand_up()`
- **Lines:** 0
- **Parameters:** `ragdoll_body: RigidBody3D, being: AstralBeing`
- **Returns:** `void`
- **Calls:** apply_torque_impulse, Vector3, _create_assistance_effect, print, apply_central_impulse

### `_assist_object_manipulation()`
- **Lines:** 0
- **Parameters:** `being: AstralBeing, delta: float`
- **Returns:** `void`
- **Calls:** is_in_group, apply_central_force, Vector3, is_instance_valid

### `_assist_scene_organization()`
- **Lines:** 0
- **Parameters:** `being: AstralBeing, delta: float`
- **Returns:** `void`
- **Calls:** randf_range, Vector3, randf, randi, apply_central_impulse, get_tree, size, get_nodes_in_group

### `_assist_environmental_harmony()`
- **Lines:** 0
- **Parameters:** `being: AstralBeing, delta: float`
- **Returns:** `void`
- **Calls:** sin, randf, get_ticks_msec, int

### `_assist_creative_work()`
- **Lines:** 0
- **Parameters:** `being: AstralBeing, delta: float`
- **Returns:** `void`
- **Calls:** randf, print

### `_create_assistance_effect()`
- **Lines:** 0
- **Parameters:** `position: Vector3`
- **Returns:** `void`
- **Calls:** create_timer, is_instance_valid, new, add_child, queue_free, Vector3, get_tree

### `_on_player_needs_help()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_on_object_interaction()`
- **Lines:** 0
- **Parameters:** `object: RigidBody3D`
- **Returns:** `void`
- **Calls:** _find_available_being, print

### `_find_available_being()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `AstralBeing`

### `summon_assistance()`
- **Lines:** 0
- **Parameters:** `mode: AssistanceMode, target: Node = null`
- **Returns:** `void`
- **Calls:** str, _find_available_being, print

### `set_all_beings_mode()`
- **Lines:** 0
- **Parameters:** `mode: AssistanceMode`
- **Returns:** `void`
- **Calls:** str, print

### `get_beings_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** str, has, size

### `cmd_beings_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, get_beings_status, print

### `cmd_beings_help_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_all_beings_mode

### `cmd_beings_organize()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_all_beings_mode

### `cmd_beings_harmony()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_all_beings_mode


## scripts/core/astral_ragdoll_helper.gd
**Category:** Core Systems
**Functions:** 7

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_process

### `start_helping_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** start_assisting, set_process, str, is_empty, min, has_method, _find_ragdoll, print, append, get_tree, range, clear, size, get_nodes_in_group

### `stop_helping()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_method, print, set_movement_mode, clear, set_process

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** is_instance_valid, Vector3, randf, speak, has_method, has_property, get_linear_velocity, apply_central_impulse, get_body, range, size, get

### `_find_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node3D`
- **Calls:** get_tree, get_node_or_null, is_empty, get_nodes_in_group

### `toggle_help()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** stop_helping, start_helping_ragdoll

### `assign_specific_being()`
- **Lines:** 5
- **Parameters:** `being: Node3D`
- **Returns:** `void`
- **Calls:** append, start_assisting, has_method


## scripts/core/background_process_manager.gd
**Category:** Core Systems
**Functions:** 11

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_physics_process, set_process, print

### `register_physics_process()`
- **Lines:** 0
- **Parameters:** `node: Node, callback: Callable, priority: int = 5`
- **Returns:** `void`
- **Calls:** append, sort_custom, print

### `register_visual_process()`
- **Lines:** 0
- **Parameters:** `node: Node, callback: Callable, priority: int = 5`
- **Returns:** `void`
- **Calls:** append, sort_custom, print

### `register_debug_process()`
- **Lines:** 0
- **Parameters:** `node: Node, callback: Callable`
- **Returns:** `void`
- **Calls:** append, print

### `unregister_process()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** filter

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** is_instance_valid, call, get_ticks_usec, emit, range, size

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** is_instance_valid, call, get_ticks_usec, emit, pop_front, append, range, size

### `set_debug_enabled()`
- **Lines:** 0
- **Parameters:** `enabled: bool`
- **Returns:** `void`
- **Calls:** print

### `get_performance_stats()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** size

### `set_process_active()`
- **Lines:** 0
- **Parameters:** `node: Node, active: bool`
- **Returns:** `void`

### `_sort_by_priority()`
- **Lines:** 2
- **Parameters:** `a: Dictionary, b: Dictionary`
- **Returns:** `bool`


## scripts/core/bird_ai_behavior.gd
**Category:** Core Systems
**Functions:** 15

### `setup()`
- **Lines:** 0
- **Parameters:** `bird: RigidBody3D`
- **Returns:** `void`
- **Calls:** set_physics_process

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** max, _process_seeking_food, _process_seeking_water, min, _process_resting, _process_drinking, _check_state_transitions, _process_eating, _process_wandering

### `_process_wandering()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** randf_range, sin, _change_state, _find_nearby_food, Vector3, randf, has_method, cos

### `_process_seeking_food()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _change_state, is_instance_valid, has_method, distance_to

### `_process_eating()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _change_state, is_instance_valid, queue_free, randf, has_method, min

### `_process_seeking_water()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _change_state, is_instance_valid, _find_nearby_water, distance_to, has_method

### `_process_drinking()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _change_state, min

### `_process_resting()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _change_state

### `_check_state_transitions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _find_nearby_food, _find_nearby_water, _change_state

### `_change_state()`
- **Lines:** 0
- **Parameters:** `new_state: AIState`
- **Returns:** `void`
- **Calls:** has_method, set_ai_state

### `_find_nearby_food()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node3D`
- **Calls:** get_tree, is_instance_valid, get_nodes_in_group, distance_to

### `_find_nearby_water()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node3D`
- **Calls:** get_tree, is_instance_valid, get_nodes_in_group, distance_to

### `get_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** keys

### `feed()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `give_water()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `void`


## scripts/core/console_channel_system.gd
**Category:** Core Systems
**Functions:** 16

### `setup_channels()`
- **Lines:** 0
- **Parameters:** `console_ui: Control`
- **Returns:** `void`
- **Calls:** Vector2, new, bind, add_child, add_theme_stylebox_override, get_node_or_null, connect, Color, move_child, values, add_theme_color_override

### `print_to_channel()`
- **Lines:** 0
- **Parameters:** `message: String, channel: Channel = Channel.GAME`
- **Returns:** `void`
- **Calls:** _display_message, get_ticks_msec, pop_front, append, size, get

### `_on_channel_toggled()`
- **Lines:** 0
- **Parameters:** `pressed: bool, channel: Channel`
- **Returns:** `void`
- **Calls:** emit, _refresh_display

### `_enable_all_channels()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _refresh_display

### `_disable_all_channels()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _refresh_display

### `_refresh_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _clear_display, _display_message, get

### `_clear_console()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _clear_display, clear

### `_display_message()`
- **Lines:** 0
- **Parameters:** `formatted_text: String`
- **Returns:** `void`
- **Calls:** message

### `_clear_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** display

### `print_system()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** print_to_channel

### `print_game()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** print_to_channel

### `print_universal()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** print_to_channel

### `print_error()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** print_to_channel

### `print_debug()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** print_to_channel

### `print_player()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** print_to_channel

### `print_rules()`
- **Lines:** 3
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** print_to_channel


## scripts/core/debug_3d_screen.gd
**Category:** Core Systems
**Functions:** 27

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _safe_initialize, get_tree, call_deferred, print

### `_safe_initialize()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_process, _create_debug_gizmo, _create_3d_screen

### `_create_3d_screen()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create, new, add_child, str, print, deg_to_rad, set_image, fill

### `_create_debug_gizmo()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_axis_indicator, new, add_child

### `_create_axis_indicator()`
- **Lines:** 0
- **Parameters:** `direction: Vector3, color: Color, label: String`
- **Returns:** `void`
- **Calls:** add_child, new, deg_to_rad

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_gizmo_position, _update_debug_display

### `_update_debug_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _draw_camera_info, _draw_scene_overview, _draw_object_list, _draw_selected_object_info, _collect_scene_debug_info, set_image, fill

### `_collect_scene_debug_info()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_spawned_objects, append_array, get, get_node_or_null, has_method, get_tree, _get_object_type, clear, size, get_nodes_in_group

### `_get_object_type()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `String`
- **Calls:** to_lower

### `_draw_scene_overview()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _draw_text, str, get

### `_draw_object_list()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, str, min, _get_object_type, _draw_text, range, size, get

### `_draw_selected_object_info()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, Vector3, _get_object_type, _draw_text, rad_to_deg, get

### `_draw_camera_info()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _draw_text, str, get_viewport, get_camera_3d

### `_draw_text()`
- **Lines:** 0
- **Parameters:** `text: String, x: int, y: int, color: Color`
- **Returns:** `void`
- **Calls:** _draw_char, length, get_width, get_height, range

### `_draw_char()`
- **Lines:** 0
- **Parameters:** `character: String, x: int, y: int, color: Color`
- **Returns:** `void`
- **Calls:** get_height, range, get_width, set_pixel

### `_update_gizmo_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `select_object()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `void`
- **Calls:** str, print

### `deselect_object()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `move_selected_object()`
- **Lines:** 0
- **Parameters:** `direction: Vector3, amount: float = 1.0`
- **Returns:** `void`
- **Calls:** str, print

### `set_selected_object_position()`
- **Lines:** 0
- **Parameters:** `new_position: Vector3`
- **Returns:** `bool`
- **Calls:** str, print

### `rotate_selected_object()`
- **Lines:** 0
- **Parameters:** `axis: Vector3, angle_deg: float`
- **Returns:** `void`
- **Calls:** print, deg_to_rad

### `set_selected_object_rotation()`
- **Lines:** 0
- **Parameters:** `new_rotation: Vector3`
- **Returns:** `bool`
- **Calls:** str, print

### `scale_selected_object()`
- **Lines:** 0
- **Parameters:** `scale_factor: Vector3`
- **Returns:** `void`
- **Calls:** str, print

### `set_selected_object_scale()`
- **Lines:** 0
- **Parameters:** `new_scale: Vector3`
- **Returns:** `bool`
- **Calls:** str, print

### `set_screen_position()`
- **Lines:** 0
- **Parameters:** `pos: Vector3`
- **Returns:** `void`

### `get_screen_info()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** is_instance_valid, get

### `find_object_by_name()`
- **Lines:** 7
- **Parameters:** `name: String`
- **Returns:** `Node3D`
- **Calls:** contains, is_instance_valid, get, to_lower


## scripts/core/debug_manager.gd
**Category:** Core Systems
**Functions:** 8

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_process, print

### `is_debug_enabled()`
- **Lines:** 0
- **Parameters:** `category: String`
- **Returns:** `bool`
- **Calls:** get

### `set_debug_category()`
- **Lines:** 0
- **Parameters:** `category: String, enabled: bool`
- **Returns:** `void`
- **Calls:** emit, print

### `toggle_debug_category()`
- **Lines:** 0
- **Parameters:** `category: String`
- **Returns:** `void`
- **Calls:** set_debug_category

### `should_print()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `bool`
- **Calls:** get, to_lower

### `filtered_print()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** should_print, print

### `get_debug_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`

### `_on_console_command()`
- **Lines:** 26
- **Parameters:** `command: String, args: Array`
- **Returns:** `void`
- **Calls:** get_debug_status, disabled, set_debug_category, size, get


## scripts/core/delta_frame_guardian.gd
**Category:** Core Systems
**Functions:** 18

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_process, _register_guardian_commands, print

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _track_frame_time, get_ticks_msec, _enter_emergency_mode, _exit_emergency_mode, get_frames_per_second, _distribute_frame_time

### `register_script()`
- **Lines:** 0
- **Parameters:** `node: Node, priority: int = 50, update_rate: float = 60.0`
- **Returns:** `void`
- **Calls:** sort_custom, new, get_file, get_ticks_msec, clamp, s, get_script, print, append

### `unregister_script()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** erase, get_script, get_file, print

### `get_managed_delta()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `float`
- **Calls:** get_ticks_msec, _should_update, get_script, get_process_delta_time, get

### `_distribute_frame_time()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _should_update, append, float, get

### `_should_update()`
- **Lines:** 0
- **Parameters:** `info: ScriptInfo`
- **Returns:** `bool`
- **Calls:** get_ticks_msec

### `_track_frame_time()`
- **Lines:** 0
- **Parameters:** `frame_time: float`
- **Returns:** `void`
- **Calls:** append, pop_front, size, _analyze_performance_issue

### `_analyze_performance_issue()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, sort_custom, size, _throttle_script

### `_throttle_script()`
- **Lines:** 0
- **Parameters:** `info: ScriptInfo, reason: String`
- **Returns:** `void`
- **Calls:** emit, get_file, min, print

### `_enter_emergency_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _throttle_script, print

### `_exit_emergency_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** min, print

### `get_performance_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** filter, size

### `_register_guardian_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null

### `_cmd_fps_status()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, get_performance_report

### `_cmd_list_scripts()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, get_file

### `_cmd_toggle_throttle()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, size, to_lower

### `_cmd_force_emergency()`
- **Lines:** 9
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node, _enter_emergency_mode, to_lower, _exit_emergency_mode, size


## scripts/core/dimensional_color_system.gd
**Category:** Core Systems
**Functions:** 39

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _initialize_mesh_point_map, _initialize_frequency_color_map, str, _generate_tertiary_colors, _generate_color_palettes, _find_systems, print, size

### `_generate_tertiary_colors()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Color, append, range, float, size, lerp

### `_initialize_frequency_color_map()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has, Color, range, float, size, lerp

### `_initialize_mesh_point_map()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, range, has, size

### `_generate_color_palettes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Color

### `_find_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, get_node_or_null, print, _find_node_by_class

### `_find_node_by_class()`
- **Lines:** 0
- **Parameters:** `node, class_name_str`
- **Returns:** `void`
- **Calls:** get_class, get_children, find, to_lower, get_script, get_path, _find_node_by_class, or

### `_process()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _update_animations

### `_update_animations()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _update_pulse_animation, _update_mesh_point_animation, _update_fade_animation, erase, _update_cycle_animation, emit_signal, _update_rainbow_animation, append
- **Signals:** animation_completed

### `_update_pulse_animation()`
- **Lines:** 0
- **Parameters:** `animation, progress`
- **Returns:** `void`
- **Calls:** sin, emit_signal, lerp
- **Signals:** color_frequency_updated

### `_update_fade_animation()`
- **Lines:** 0
- **Parameters:** `animation, progress`
- **Returns:** `void`
- **Calls:** emit_signal, lerp
- **Signals:** color_frequency_updated

### `_update_cycle_animation()`
- **Lines:** 0
- **Parameters:** `animation, progress`
- **Returns:** `void`
- **Calls:** fmod, emit_signal, size, lerp, int
- **Signals:** color_frequency_updated

### `_update_rainbow_animation()`
- **Lines:** 0
- **Parameters:** `animation, progress`
- **Returns:** `void`
- **Calls:** fmod, from_hsv, emit_signal
- **Signals:** color_frequency_updated

### `_update_mesh_point_animation()`
- **Lines:** 0
- **Parameters:** `animation, progress`
- **Returns:** `void`
- **Calls:** sin, emit_signal, fmod, lerp
- **Signals:** mesh_point_activated, color_frequency_updated

### `get_color_for_frequency()`
- **Lines:** 0
- **Parameters:** `frequency: int`
- **Returns:** `Color`
- **Calls:** clamp, has, Color

### `get_mesh_point_type()`
- **Lines:** 0
- **Parameters:** `frequency: int`
- **Returns:** `Array`
- **Calls:** has

### `get_closest_harmonic_frequency()`
- **Lines:** 0
- **Parameters:** `frequency: int`
- **Returns:** `int`
- **Calls:** append_array, abs

### `get_color_palette()`
- **Lines:** 0
- **Parameters:** `palette_name: String = "default"`
- **Returns:** `Array`
- **Calls:** has

### `start_pulse_animation()`
- **Lines:** 0
- **Parameters:** `frequency: int, duration: float = DEFAULT_ANIMATION_DURATION, pulse_freq: float = DEFAULT_PULSE_FREQUENCY, amplitude: float = DEFAULT_AMPLITUDE`
- **Returns:** `String`
- **Calls:** get_color_for_frequency, str, emit_signal, get_closest_harmonic_frequency, get_unix_time_from_system
- **Signals:** animation_started

### `start_fade_animation()`
- **Lines:** 0
- **Parameters:** `frequency: int, target_color: Color, duration: float = DEFAULT_ANIMATION_DURATION`
- **Returns:** `String`
- **Calls:** str, get_unix_time_from_system, emit_signal, get_color_for_frequency
- **Signals:** animation_started

### `start_cycle_animation()`
- **Lines:** 0
- **Parameters:** `frequency: int, palette_name: String = "default", duration: float = DEFAULT_ANIMATION_DURATION, cycle_speed: float = 1.0`
- **Returns:** `String`
- **Calls:** get_color_palette, get_color_for_frequency, str, emit_signal, get_unix_time_from_system
- **Signals:** animation_started

### `start_rainbow_animation()`
- **Lines:** 0
- **Parameters:** `frequency: int, duration: float = DEFAULT_ANIMATION_DURATION, rainbow_speed: float = 1.0, saturation: float = 1.0, brightness: float = 1.0`
- **Returns:** `String`
- **Calls:** str, get_unix_time_from_system, emit_signal, get_color_for_frequency
- **Signals:** animation_started

### `start_mesh_point_animation()`
- **Lines:** 0
- **Parameters:** `frequency: int, duration: float = DEFAULT_ANIMATION_DURATION, pulse_freq: float = DEFAULT_PULSE_FREQUENCY`
- **Returns:** `String`
- **Calls:** get_mesh_point_type, get_color_for_frequency, str, Color, emit_signal, size, get_unix_time_from_system
- **Signals:** mesh_point_activated, animation_started

### `stop_animation()`
- **Lines:** 0
- **Parameters:** `animation_id: String`
- **Returns:** `bool`
- **Calls:** erase, has, get_closest_harmonic_frequency, get_color_for_frequency

### `stop_all_animations()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, get_closest_harmonic_frequency, get_color_for_frequency

### `get_colored_text()`
- **Lines:** 0
- **Parameters:** `text: String, frequency: int`
- **Returns:** `String`
- **Calls:** to_html, get_color_for_frequency

### `get_gradient_text()`
- **Lines:** 0
- **Parameters:** `text: String, start_freq: int, end_freq: int`
- **Returns:** `String`
- **Calls:** to_html, get_color_for_frequency

### `colorize_line()`
- **Lines:** 0
- **Parameters:** `line: String, base_frequency: int, symbol_boost: int = 10`
- **Returns:** `String`
- **Calls:** max, get_color_for_frequency, to_html, length, min, range

### `colorize_mesh_points()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `String`
- **Calls:** new, compile, get_color_for_frequency, keys, to_html, str, sub

### `start_line_animation()`
- **Lines:** 0
- **Parameters:** `line_index: int, frequency: int = 120, animation_type: String = "pulse", duration: float = DEFAULT_ANIMATION_DURATION`
- **Returns:** `String`
- **Calls:** start_pulse_animation, start_rainbow_animation, start_cycle_animation, start_mesh_point_animation

### `animate_text_typing()`
- **Lines:** 0
- **Parameters:** `text: String, base_freq: int = 120, duration: float = 2.0, delay_per_char: float = 0.05`
- **Returns:** `void`
- **Calls:** str, emit_signal, get_unix_time_from_system
- **Signals:** animation_started

### `highlight_mesh_points()`
- **Lines:** 0
- **Parameters:** `frequencies: Array, duration: float = 5.0`
- **Returns:** `void`
- **Calls:** has, start_mesh_point_animation

### `highlight_mesh_centers()`
- **Lines:** 0
- **Parameters:** `duration: float = 5.0`
- **Returns:** `void`
- **Calls:** highlight_mesh_points

### `highlight_mesh_edges()`
- **Lines:** 0
- **Parameters:** `duration: float = 5.0`
- **Returns:** `void`
- **Calls:** highlight_mesh_points

### `highlight_mesh_corners()`
- **Lines:** 0
- **Parameters:** `duration: float = 5.0`
- **Returns:** `void`
- **Calls:** highlight_mesh_points

### `get_mesh_visualization_colors()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_color_for_frequency

### `sync_with_ethereal_bridge()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** clamp, get_active_dimensions, has_method, start_pulse_animation, has, int

### `get_frequency_info()`
- **Lines:** 0
- **Parameters:** `frequency: int`
- **Returns:** `Dictionary`
- **Calls:** get_mesh_point_type, get_color_for_frequency, clamp, has, _frequency_has_animation

### `_frequency_has_animation()`
- **Lines:** 7
- **Parameters:** `frequency: int`
- **Returns:** `bool`


## scripts/core/dimensional_ragdoll_system.gd
**Category:** Core Systems
**Functions:** 25

### `_init()`
- **Lines:** 8
- **Parameters:** `px: float = 0, py: float = 0, pz: float = 0, pw: float = 0, pv: float = 0.1`
- **Returns:** `void`

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _initialize_consciousness, _setup_dimensional_physics, print

### `_setup_dimensional_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_initialize_consciousness()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _learn_initial_spells

### `_learn_initial_spells()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** learn_spell

### `shift_dimension()`
- **Lines:** 0
- **Parameters:** `target_dimension: Dimension`
- **Returns:** `void`
- **Calls:** keys, print, emit_signal, _apply_dimensional_effects, float
- **Signals:** dimension_changed

### `_apply_dimensional_effects()`
- **Lines:** 0
- **Parameters:** `dimension: Dimension`
- **Returns:** `void`

### `add_consciousness_experience()`
- **Lines:** 0
- **Parameters:** `amount: float, source: String = ""`
- **Returns:** `void`
- **Calls:** _get_evolution_stage, get_ticks_msec, clamp, _evolve_to_stage, emit_signal, print, append, f
- **Signals:** consciousness_evolved

### `_get_evolution_stage()`
- **Lines:** 0
- **Parameters:** `level: float`
- **Returns:** `String`

### `_evolve_to_stage()`
- **Lines:** 0
- **Parameters:** `new_stage: String`
- **Returns:** `void`
- **Calls:** _update_emotion_state, learn_spell, print

### `learn_spell()`
- **Lines:** 0
- **Parameters:** `spell_name: String`
- **Returns:** `void`
- **Calls:** append, emit_signal, print
- **Signals:** spell_learned

### `cast_spell()`
- **Lines:** 0
- **Parameters:** `spell_name: String, target: Node3D = null`
- **Returns:** `bool`
- **Calls:** add_consciousness_experience, _spell_float, _spell_glow, _spell_blink, _spell_teleport_short, _spell_wobble, _spell_giggle, _spell_reality_shift, print, _spell_dimension_peek

### `set_emotion()`
- **Lines:** 0
- **Parameters:** `emotion: String, value: float`
- **Returns:** `void`
- **Calls:** _update_emotion_state, clamp

### `_update_emotion_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** s, emit_signal, print
- **Signals:** emotion_changed

### `process_interaction()`
- **Lines:** 0
- **Parameters:** `interaction_type: String, object: Node3D = null`
- **Returns:** `void`
- **Calls:** add_consciousness_experience, _detect_interaction_patterns, get_ticks_msec, append, set_emotion

### `_detect_interaction_patterns()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** slice, add_consciousness_experience, size, print

### `_spell_wobble()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, randf, apply_impulse

### `_spell_blink()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_spell_giggle()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_spell_float()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, get_tree

### `_spell_glow()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_spell_teleport_short()`
- **Lines:** 0
- **Parameters:** `target: Node3D`
- **Returns:** `void`
- **Calls:** normalized

### `_spell_dimension_peek()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** keys, size, print

### `_spell_reality_shift()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** shift_dimension, randi, size

### `get_state()`
- **Lines:** 19
- **Parameters:** ``
- **Returns:** `Dictionary`


## scripts/core/eden_action_system.gd
**Category:** Core Systems
**Functions:** 26

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_process

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_active_actions, _cleanup_old_combos, _process_action_queue

### `queue_action()`
- **Lines:** 0
- **Parameters:** `action_name: String, target: Node, params: Dictionary = {}`
- **Returns:** `bool`
- **Calls:** push_error, get_ticks_msec, _check_action_requirements, has, emit_signal, append
- **Signals:** action_failed

### `process_combo_input()`
- **Lines:** 0
- **Parameters:** `input_type: String, target: Node = null`
- **Returns:** `void`
- **Calls:** filter, _trigger_combo, get_ticks_msec, _check_combo_pattern, append, clear

### `_check_action_requirements()`
- **Lines:** 0
- **Parameters:** `action_def: Dictionary, target: Node`
- **Returns:** `bool`
- **Calls:** is_class, has, size

### `_cleanup_old_combos()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, filter

### `_process_action_queue()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** pop_front, _start_action, is_empty

### `_start_action()`
- **Lines:** 0
- **Parameters:** `action: Dictionary`
- **Returns:** `void`
- **Calls:** append, _execute_action_step, emit_signal
- **Signals:** action_started

### `_execute_action_step()`
- **Lines:** 0
- **Parameters:** `action: Dictionary`
- **Returns:** `void`
- **Calls:** _step_grasp, _step_lift, _complete_action, _step_look, _step_trigger, _step_analyze, _step_target, push_warning, _step_charge, _step_approach, _step_report, size

### `_update_active_actions()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** range, size, _execute_action_step

### `_complete_action()`
- **Lines:** 0
- **Parameters:** `action: Dictionary`
- **Returns:** `void`
- **Calls:** erase, emit_signal
- **Signals:** action_completed

### `_check_combo_pattern()`
- **Lines:** 0
- **Parameters:** `pattern: Dictionary`
- **Returns:** `bool`
- **Calls:** has, range, size

### `_trigger_combo()`
- **Lines:** 0
- **Parameters:** `combo_name: String, pattern: Dictionary`
- **Returns:** `void`
- **Calls:** append, has, emit_signal, queue_action
- **Signals:** combo_triggered

### `_step_look()`
- **Lines:** 0
- **Parameters:** `action: Dictionary`
- **Returns:** `void`
- **Calls:** print

### `_step_analyze()`
- **Lines:** 0
- **Parameters:** `action: Dictionary`
- **Returns:** `void`
- **Calls:** get_class, get_groups

### `_step_report()`
- **Lines:** 0
- **Parameters:** `action: Dictionary`
- **Returns:** `void`
- **Calls:** has, print

### `_step_approach()`
- **Lines:** 0
- **Parameters:** `action: Dictionary`
- **Returns:** `void`
- **Calls:** print

### `_step_grasp()`
- **Lines:** 0
- **Parameters:** `action: Dictionary`
- **Returns:** `void`
- **Calls:** set_freeze_enabled

### `_step_lift()`
- **Lines:** 0
- **Parameters:** `action: Dictionary`
- **Returns:** `void`

### `_step_target()`
- **Lines:** 0
- **Parameters:** `action: Dictionary`
- **Returns:** `void`
- **Calls:** print

### `_step_charge()`
- **Lines:** 0
- **Parameters:** `_action: Dictionary`
- **Returns:** `void`
- **Calls:** print

### `_step_trigger()`
- **Lines:** 0
- **Parameters:** `action: Dictionary`
- **Returns:** `void`
- **Calls:** has_method, activate, print

### `start_selection_mode()`
- **Lines:** 0
- **Parameters:** `mode: String`
- **Returns:** `void`
- **Calls:** clear

### `add_to_selection()`
- **Lines:** 0
- **Parameters:** `target: Node`
- **Returns:** `void`
- **Calls:** append

### `clear_selection()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear

### `execute_multi_target_action()`
- **Lines:** 9
- **Parameters:** `action_name: String`
- **Returns:** `void`
- **Calls:** queue_action, size, duplicate


## scripts/core/enhanced_ragdoll_walker.gd
**Category:** Core Systems
**Functions:** 34

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _configure_physics, _find_body_parts, print, values, get_tree

### `_find_body_parts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_parent, get_meta, print, has_meta, get

### `_configure_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _clear_movement_command, _update_step_cycle, _process_movement_input, _apply_blended_physics, print, _update_state_blending, _update_state_machine, _update_ground_detection

### `_process_movement_input()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** normalized, length, get_viewport, get_camera_3d

### `_update_state_machine()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _is_action_safe, _is_action_just_pressed_safe, length, _enter_state

### `_enter_state()`
- **Lines:** 0
- **Parameters:** `new_state: MovementState`
- **Returns:** `void`
- **Calls:** _perform_landing, _perform_jump

### `_update_state_blending()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** values, lerp

### `_apply_blended_physics()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _adjust_height_to_target, _apply_rotation_forces, _apply_balance_forces, _apply_crouch_walking_forces, _apply_strafing_forces, _apply_walking_forces, _maintain_upright_posture, _apply_running_forces, lerp

### `_apply_walking_forces()`
- **Lines:** 0
- **Parameters:** `weight: float`
- **Returns:** `void`
- **Calls:** apply_central_force, _apply_step_animation

### `_apply_running_forces()`
- **Lines:** 0
- **Parameters:** `weight: float`
- **Returns:** `void`
- **Calls:** apply_central_force, _apply_step_animation

### `_apply_crouch_walking_forces()`
- **Lines:** 0
- **Parameters:** `weight: float`
- **Returns:** `void`
- **Calls:** apply_central_force, _apply_step_animation

### `_apply_strafing_forces()`
- **Lines:** 0
- **Parameters:** `weight: float`
- **Returns:** `void`
- **Calls:** apply_central_force, cross

### `_apply_rotation_forces()`
- **Lines:** 0
- **Parameters:** `weight: float`
- **Returns:** `void`
- **Calls:** apply_torque

### `_apply_step_animation()`
- **Lines:** 0
- **Parameters:** `weight: float, speed: float`
- **Returns:** `void`
- **Calls:** fmod, apply_central_force, sin, cos

### `_apply_balance_forces()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, _calculate_center_of_mass

### `_maintain_upright_posture()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** cross, apply_torque

### `_adjust_height_to_target()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_torque

### `_update_step_cycle()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`

### `_perform_jump()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** length, apply_central_impulse

### `_perform_landing()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_impulse

### `_update_ground_detection()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, get_world_3d, intersect_ray, normalized, get_tree

### `_calculate_center_of_mass()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`

### `set_movement_input()`
- **Lines:** 0
- **Parameters:** `input: Vector2`
- **Returns:** `void`

### `set_speed_mode()`
- **Lines:** 0
- **Parameters:** `mode: SpeedMode`
- **Returns:** `void`

### `set_rotation_input()`
- **Lines:** 0
- **Parameters:** `rotation: float`
- **Returns:** `void`
- **Calls:** length, abs

### `trigger_jump()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _enter_state

### `trigger_crouch()`
- **Lines:** 0
- **Parameters:** `pressed: bool`
- **Returns:** `void`

### `execute_movement_command()`
- **Lines:** 0
- **Parameters:** `command: String, duration: float = -1.0`
- **Returns:** `void`
- **Calls:** _clear_movement_command, Vector2, to_lower, set_speed_mode, trigger_jump, print, set_rotation_input, set_movement_input

### `_clear_movement_command()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_rotation_input, set_movement_input

### `get_current_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `MovementState`

### `get_state_name()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`

### `_is_action_safe()`
- **Lines:** 0
- **Parameters:** `action: String`
- **Returns:** `bool`
- **Calls:** has_action, is_action_pressed

### `_is_action_just_pressed_safe()`
- **Lines:** 4
- **Parameters:** `action: String`
- **Returns:** `bool`
- **Calls:** has_action, is_action_just_pressed


## scripts/core/floodgate_controller.gd
**Category:** Core Systems
**Functions:** 83

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, new, add_child, load, get_datetime_string_from_system, set_script, _log, print, append, range, set_process

### `_exit_tree()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** wait_to_finish, close, _flush_log_buffer, is_started

### `_process()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** each_blimp_of_delta, process_system

### `each_blimp_of_delta()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, pop_front, size

### `process_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** process_system_10, process_system_5, process_system_2, process_system_11, process_system_1, process_system_0, process_system_9, process_system_4, process_system_7, process_system_8, process_system_6, process_system_3

### `queue_operation()`
- **Lines:** 0
- **Parameters:** `type: OperationType, params: Dictionary, priority: int = 0`
- **Returns:** `String`
- **Calls:** unlock, str, _get_operation_name, _log, _get_caller_info, lock, emit_signal, insert, append, _generate_operation_id, range, size, get_unix_time_from_system
- **Signals:** operation_queued, operation_failed

### `_process_next_operation()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, _log, pop_front, lock, emit_signal, append, _execute_operation, size, get_unix_time_from_system
- **Signals:** operation_started, operation_completed

### `_execute_operation()`
- **Lines:** 0
- **Parameters:** `operation: Dictionary`
- **Returns:** `bool`
- **Calls:** _op_delete_node, _op_move_node, _op_reparent_node, _op_create_universal_being, _op_disconnect_signal, _op_transform_universal_being, _op_unload_asset, _op_scale_node, _op_rotate_node, _op_load_asset, _op_modify_property, _op_connect_universal_beings, _log, _op_emit_signal, _op_connect_signal, _op_call_method, _op_create_node

### `_op_create_node()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** set, get_parent, add_child, get_node_or_null, instantiate, _log, get_path, has, _register_node

### `_op_delete_node()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** queue_free, get_node_or_null, _log, has, _unregister_node_recursive

### `_op_move_node()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** _unlock_node, str, get_node_or_null, has_method, _lock_node, _log, has

### `_op_rotate_node()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** _unlock_node, str, get_node_or_null, _lock_node, _log, has

### `_op_scale_node()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** _unlock_node, str, get_node_or_null, _lock_node, _log, has

### `_op_reparent_node()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** get_parent, add_child, _unlock_node, get_node_or_null, _lock_node, _log, has, remove_child, get

### `_op_load_asset()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** load, str, _log, has, emit_signal, append, get_unix_time_from_system
- **Signals:** asset_loaded, asset_approval_needed

### `_op_unload_asset()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** str, erase, has, _log

### `_op_modify_property()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** set, _unlock_node, str, get_node_or_null, _lock_node, _log, has, get

### `_op_call_method()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** _unlock_node, call, str, get_node_or_null, has_method, _lock_node, _log, callv, has

### `_op_emit_signal()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** get_node_or_null, _log, has_signal, has, emit_signal

### `_op_connect_signal()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** bind, get_node_or_null, has_method, _log, connect, Callable, has_signal, has, get

### `_op_disconnect_signal()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** disconnect, get_node_or_null, Callable, _log, is_connected, has

### `_register_node()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `String`
- **Calls:** get_class, get_path, emit_signal, _generate_node_id, get_unix_time_from_system
- **Signals:** node_registered

### `_unregister_node_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** get_children, erase, get_path, emit_signal, _unregister_node_recursive
- **Signals:** node_unregistered

### `_lock_node()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** delay_msec, unlock, get_path, has, lock

### `_unlock_node()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** unlock, erase, get_path, lock

### `approve_asset()`
- **Lines:** 0
- **Parameters:** `asset_path: String`
- **Returns:** `void`
- **Calls:** append, erase, queue_operation, _log

### `reject_asset()`
- **Lines:** 0
- **Parameters:** `asset_path: String`
- **Returns:** `void`
- **Calls:** erase, _log

### `set_asset_approval_required()`
- **Lines:** 0
- **Parameters:** `required: bool`
- **Returns:** `void`
- **Calls:** str, _log

### `_log()`
- **Lines:** 0
- **Parameters:** `message: String, category: String = "INFO", caller_info: Dictionary = {}`
- **Returns:** `void`
- **Calls:** get_datetime_string_from_system, str, has, print, append

### `_flush_log_buffer()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** store_line, clear, flush, is_empty

### `_get_caller_info()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_stack, size, get_file

### `_generate_operation_id()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** str, randi, get_unix_time_from_system

### `_generate_node_id()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** str, randi, get_unix_time_from_system

### `_get_operation_name()`
- **Lines:** 0
- **Parameters:** `type: OperationType`
- **Returns:** `String`

### `process_system_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set, try_lock, unlock, str, min, _log, pop_front, has, lock, range, size

### `process_system_1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _track_new_object, track_node, try_lock, is_instance_valid, get_parent, add_child, unlock, get_node_or_null, min, _should_enforce_object_limits, _log, _check_and_enforce_object_limits, pop_front, _register_node, lock, get_tree, range, size

### `process_system_2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set, try_lock, unlock, get_node_or_null, has_method, min, callv, _log, pop_front, has, lock, append, range, size, get

### `process_system_3()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** try_lock, is_instance_valid, unlock, str, min, _log, pop_front, lock, range, size

### `process_system_4()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** try_lock, queue_free, unlock, get_node_or_null, min, _log, pop_front, lock, _unregister_node_recursive, range, size

### `process_system_5()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** try_lock, is_instance_valid, unlock, str, get_node_or_null, has_method, min, callv, _log, pop_front, lock, range, size

### `process_system_6()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** try_lock, _cleanup_memory, load, get_ticks_msec, unlock, min, _log, exists, pop_front, lock, range, size

### `process_system_7()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set, try_lock, unlock, get_node_or_null, min, _log, pop_front, has_signal, has, lock, emit_signal, append, range, size, get

### `process_system_8()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, try_lock

### `process_system_9()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** try_lock, new, unlock, get_node_or_null, min, _log, erase, has, range, size

### `process_system_10()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** try_lock, unlock, str, min, _log, set_gravity_center, pop_front, set_scene_zero_point, set_object_state, range, size

### `process_system_11()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** try_lock, unlock, str, min, _log, pop_front, track_ragdoll_movement, range, size

### `first_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `type_of_action: String, target_node: Node, additional_data = null`
- **Returns:** `void`
- **Calls:** append, unlock, _log, lock

### `second_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `data_type: int, node_path: String, node_to_add: Node, additional_data = null`
- **Returns:** `void`
- **Calls:** append, unlock, _log, lock

### `third_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `data_type: String, target_path: String, data_payload`
- **Returns:** `void`
- **Calls:** append, unlock, _log, lock

### `fourth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `operation_type: String, target_node: Node, movement_data`
- **Returns:** `void`
- **Calls:** append, unlock, _log, lock

### `fifth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `unload_type: String, node_path: String`
- **Returns:** `void`
- **Calls:** append, unlock, _log, lock

### `sixth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `function_type: String, target_node, function_name: String, function_args = []`
- **Returns:** `void`
- **Calls:** append, unlock, _log, lock

### `seventh_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `operation_type: String, operation_data: String, operation_count: int = 1`
- **Returns:** `void`
- **Calls:** append, unlock, _log, lock

### `eighth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `message_type: String, message_content, receiver: String`
- **Returns:** `void`
- **Calls:** append, unlock, _log, lock

### `ninth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `texture_path: String, texture_data: Dictionary`
- **Returns:** `void`
- **Calls:** unlock, _log, lock

### `_cleanup_memory()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** slice, size, _log

### `get_operation_status()`
- **Lines:** 0
- **Parameters:** `operation_id: String`
- **Returns:** `Dictionary`

### `get_queue_size()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `int`
- **Calls:** size

### `get_loaded_assets()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** keys

### `get_pending_assets()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** duplicate

### `get_registered_nodes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_path, is_instance_valid

### `clear_failed_operations()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, _log

### `get_failed_operations()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** duplicate

### `_should_enforce_object_limits()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `bool`
- **Calls:** is_in_group, has_meta

### `_check_and_enforce_object_limits()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `bool`
- **Calls:** _remove_oldest_object, _cleanup_astral_beings, _cleanup_tracked_objects, _remove_oldest_astral_being, is_in_group, size

### `_track_new_object()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** get_ticks_msec, str, get_meta, _log, is_in_group, append, size

### `_remove_oldest_object()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _notify_beings_of_replacement, is_instance_valid, queue_free, str, is_empty, _log, erase, remove_at, range, size

### `_remove_oldest_astral_being()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_instance_valid, queue_free, speak, has_method, is_empty, _log, remove_at

### `_cleanup_tracked_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** filter, is_instance_valid, remove_at, range, size

### `_cleanup_astral_beings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** filter, is_instance_valid

### `_notify_beings_of_replacement()`
- **Lines:** 0
- **Parameters:** `removed_object: Node`
- **Returns:** `void`
- **Calls:** is_instance_valid, speak, has_method, randi, size

### `get_object_statistics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** _cleanup_tracked_objects, size, get, _cleanup_astral_beings

### `queue_physics_state_change()`
- **Lines:** 0
- **Parameters:** `object: Node3D, state: int`
- **Returns:** `void`
- **Calls:** unlock, str, _log, lock, append, get_unix_time_from_system

### `queue_gravity_update()`
- **Lines:** 0
- **Parameters:** `center: Vector3, strength: float`
- **Returns:** `void`
- **Calls:** unlock, _log, lock, append, get_unix_time_from_system

### `queue_scene_zero_update()`
- **Lines:** 0
- **Parameters:** `point: Vector3`
- **Returns:** `void`
- **Calls:** unlock, _log, lock, append, get_unix_time_from_system

### `queue_ragdoll_position_update()`
- **Lines:** 0
- **Parameters:** `ragdoll_id: String, position: Vector3, state: String`
- **Returns:** `void`
- **Calls:** unlock, _log, lock, append, get_unix_time_from_system

### `get_physics_sync_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** size

### `_op_create_universal_being()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** add_child, queue_free, str, get_node_or_null, has_method, _log, reached, erase, get_tree, has, _register_node, create_universal_being, append, _unregister_node_recursive, size, get, get_unix_time_from_system

### `_op_transform_universal_being()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** has_all, get_node_or_null, has_method, _log, transform_to, get

### `_op_connect_universal_beings()`
- **Lines:** 0
- **Parameters:** `params: Dictionary`
- **Returns:** `bool`
- **Calls:** has_all, get_node_or_null, has_method, _log, connect_to, get

### `queue_create_universal_being()`
- **Lines:** 0
- **Parameters:** `being_type: String, position: Vector3 = Vector3.ZERO, properties: Dictionary = {}`
- **Returns:** `String`
- **Calls:** queue_operation

### `queue_transform_universal_being()`
- **Lines:** 0
- **Parameters:** `node_path: String, new_form: String, transform_params: Dictionary = {}`
- **Returns:** `String`
- **Calls:** queue_operation

### `queue_connect_universal_beings()`
- **Lines:** 8
- **Parameters:** `source_path: String, target_path: String, connection_type: String, connection_data: Dictionary = {}`
- **Returns:** `String`
- **Calls:** queue_operation


## scripts/core/game_launcher.gd
**Category:** Core Systems
**Functions:** 14

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _run_startup_diagnostics, print

### `_run_startup_diagnostics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _check_scene_structure, _check_autoload_systems, _check_floodgate_systems, _generate_status_report, print, _check_critical_assets

### `_check_autoload_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, get_node_or_null, print

### `_check_floodgate_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, str, get_node_or_null, print, append, get_tree, get_catalog_summary, size

### `_check_scene_structure()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, get_first_node_in_group, get_node_or_null, get_viewport, print, append, get_tree, get_camera_3d

### `_check_critical_assets()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_file, queue_free, exists, print, append, create_object

### `_generate_status_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** contains, str, is_empty, _save_diagnostic_report, emit_signal, print, size
- **Signals:** systems_ready, startup_error

### `_save_diagnostic_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, close, get_datetime_string_from_system, store_string, print, get_version_info, stringify

### `get_system_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** duplicate

### `get_error_log()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** duplicate

### `is_startup_complete()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`

### `run_health_check()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _run_startup_diagnostics, print

### `test_floodgate_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, first_dimensional_magic, is_instance_valid, new, add_child, queue_free, Vector3, get_node_or_null, second_dimensional_magic, print, get_tree

### `quick_test()`
- **Lines:** 6
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, print


## scripts/core/heightmap_world_generator.gd
**Category:** Core Systems
**Functions:** 17

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_noise, _create_containers

### `_setup_noise()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new

### `_create_containers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child

### `generate_world()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _place_vegetation, _create_water_sources, _generate_heightmap, emit, print, _create_terrain_mesh

### `_generate_heightmap()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** resize, clamp, sqrt, clear, range, pow, get_noise_2d

### `_create_terrain_mesh()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, Vector2, new, resize, add_child, get_node, PackedVector3Array, Vector3, _create_terrain_collision, PackedColorArray, PackedVector2Array, Color, append, float, range, size, PackedInt32Array

### `_create_terrain_collision()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_trimesh_collision, new, add_child

### `_place_vegetation()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _place_tree, _place_bush, get_node, emit, print, range, int

### `_place_tree()`
- **Lines:** 0
- **Parameters:** `container: Node3D`
- **Returns:** `void`
- **Calls:** add_child, Vector3, get_node_or_null, _create_tree_with_fruits, _check_slope_at, randi, register_world_object, range

### `_place_bush()`
- **Lines:** 0
- **Parameters:** `container: Node3D`
- **Returns:** `void`
- **Calls:** add_child, Vector3, get_node_or_null, _create_bush_with_fruits, randi, register_world_object, range

### `_create_tree_with_fruits()`
- **Lines:** 0
- **Parameters:** `pos: Vector3`
- **Returns:** `Node3D`
- **Calls:** randf_range, sin, new, _create_fruit, add_child, Vector3, randf, randi_range, add_to_group, Color, cos, range

### `_create_bush_with_fruits()`
- **Lines:** 0
- **Parameters:** `pos: Vector3`
- **Returns:** `Node3D`
- **Calls:** randf_range, sin, new, _create_fruit, add_child, Vector3, randf, randi_range, add_to_group, Color, cos, range

### `_create_fruit()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `RigidBody3D`
- **Calls:** add_to_group, new, Color, add_child

### `_create_water_sources()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, get_node, Vector3, _create_water_pool, randi, range

### `_create_water_pool()`
- **Lines:** 0
- **Parameters:** `pos: Vector3`
- **Returns:** `Area3D`
- **Calls:** Vector2, new, rotate_x, add_child, Vector3, Color, add_to_group

### `_check_slope_at()`
- **Lines:** 0
- **Parameters:** `x: int, z: int, max_slope: float`
- **Returns:** `bool`
- **Calls:** max, abs

### `get_height_at_position()`
- **Lines:** 9
- **Parameters:** `world_pos: Vector3`
- **Returns:** `float`
- **Calls:** int


## scripts/core/interface_manifestation_system.gd
**Category:** Core Systems
**Functions:** 27

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _initialize_eden_records_references

### `_initialize_eden_records_references()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_script, get_node_or_null, new, load

### `create_3d_interface_from_eden_records()`
- **Lines:** 0
- **Parameters:** `interface_type: String, properties: Dictionary = {}`
- **Returns:** `Node3D`
- **Calls:** _create_fallback_interface, is_empty, print, _load_3d_blueprint, _create_3d_interface_from_blueprint

### `_load_3d_blueprint()`
- **Lines:** 0
- **Parameters:** `interface_type: String`
- **Returns:** `Dictionary`
- **Calls:** new, file_exists, load, is_empty, create_default_blueprint, print, parse_blueprint_file, get

### `_create_3d_interface_from_blueprint()`
- **Lines:** 0
- **Parameters:** `blueprint_data: Dictionary, interface_type: String`
- **Returns:** `Node3D`
- **Calls:** _create_interface_soul_effects, new, _create_element_from_blueprint, add_child, capitalize, _create_interaction_area, print, size, get

### `_create_element_from_blueprint()`
- **Lines:** 0
- **Parameters:** `element: Dictionary`
- **Returns:** `Node3D`
- **Calls:** Vector2, _create_3d_button, _create_3d_slider, _create_3d_text, _create_3d_particles, _create_3d_panel, print, get

### `_create_3d_panel()`
- **Lines:** 0
- **Parameters:** `position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary`
- **Returns:** `Node3D`
- **Calls:** _get_color_from_string, new, add_child, Vector3, replace, get

### `_create_3d_button()`
- **Lines:** 0
- **Parameters:** `position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary`
- **Returns:** `Node3D`
- **Calls:** _get_color_from_string, new, add_child, Vector3, set_meta, replace, has

### `_create_3d_text()`
- **Lines:** 0
- **Parameters:** `position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary`
- **Returns:** `Node3D`
- **Calls:** _get_color_from_string, new, add_child, replace, has, get

### `_create_3d_slider()`
- **Lines:** 0
- **Parameters:** `position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary`
- **Returns:** `Node3D`
- **Calls:** _get_color_from_string, new, add_child, Vector3, replace, get

### `_create_3d_particles()`
- **Lines:** 0
- **Parameters:** `position: Vector3, size: Vector2, text: String, color: String, properties: Dictionary`
- **Returns:** `Node3D`
- **Calls:** _get_color_from_string, new, add_child, Vector3, replace, get

### `_get_color_from_string()`
- **Lines:** 0
- **Parameters:** `color_name: String`
- **Returns:** `Color`
- **Calls:** Color, to_lower

### `_get_records_map_for_interface()`
- **Lines:** 0
- **Parameters:** `interface_type: String`
- **Returns:** `Dictionary`
- **Calls:** has, _create_generic_interface_records

### `_create_ui_from_records()`
- **Lines:** 0
- **Parameters:** `records_map: Dictionary, interface_type: String`
- **Returns:** `Control`
- **Calls:** Vector2, new, add_child, add_theme_color_override, _create_elements_from_records, capitalize, Color, add_theme_font_size_override, add_theme_stylebox_override

### `_create_elements_from_records()`
- **Lines:** 0
- **Parameters:** `container: Control, records_map: Dictionary, interface_type: String`
- **Returns:** `void`
- **Calls:** Vector2, new, bind, add_child, add_theme_color_override, connect, to_float, Color, size, split, add_theme_stylebox_override

### `_create_interaction_area()`
- **Lines:** 0
- **Parameters:** `interface_type: String`
- **Returns:** `Area3D`
- **Calls:** new, bind, add_child, Vector3, connect

### `_create_interface_soul_effects()`
- **Lines:** 0
- **Parameters:** `interface_type: String`
- **Returns:** `Node3D`
- **Calls:** Vector2, new, add_child, Vector3, Color

### `_wire_interface_interactions()`
- **Lines:** 0
- **Parameters:** `interface_3d: Node3D, ui_control: Control, interface_type: String`
- **Returns:** `void`
- **Calls:** set_meta, print

### `_on_interface_button_pressed()`
- **Lines:** 0
- **Parameters:** `button_text: String, interface_type: String`
- **Returns:** `void`
- **Calls:** _handle_creation_action, _handle_settings_action, to_lower, _handle_exit_action, print

### `_on_interface_area_clicked()`
- **Lines:** 0
- **Parameters:** `camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int`
- **Returns:** `void`
- **Calls:** print

### `_on_interface_hover_start()`
- **Lines:** 0
- **Parameters:** `interface_type: String`
- **Returns:** `void`
- **Calls:** print

### `_on_interface_hover_end()`
- **Lines:** 0
- **Parameters:** `interface_type: String`
- **Returns:** `void`
- **Calls:** print

### `_handle_creation_action()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_handle_settings_action()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_handle_exit_action()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_create_fallback_interface()`
- **Lines:** 0
- **Parameters:** `interface_type: String`
- **Returns:** `Node3D`
- **Calls:** new, add_child, Vector3, capitalize, Color, print

### `_create_generic_interface_records()`
- **Lines:** 21
- **Parameters:** `interface_type: String`
- **Returns:** `Dictionary`
- **Calls:** capitalize


## scripts/core/magical_astral_being.gd
**Category:** Core Systems
**Functions:** 25

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_physics_process, _setup_particles, _create_visuals, print

### `_create_visuals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child

### `_setup_particles()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, get_ticks_msec, size, _process_next_task, rotate_y

### `add_task()`
- **Lines:** 0
- **Parameters:** `task_type: String, params: Dictionary = {}`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, print

### `_process_next_task()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _task_patrol, _task_organize_area, _task_collect_objects, is_empty, _task_help_ragdoll, _task_move_to, pop_front, _complete_task, print, _task_clean_scene, _task_create_light, get

### `_task_move_to()`
- **Lines:** 0
- **Parameters:** `target_position: Vector3`
- **Returns:** `void`
- **Calls:** tween_callback, tween_property, emit, print, _create_teleport_effect, create_tween

### `_task_collect_objects()`
- **Lines:** 0
- **Parameters:** `radius: float`
- **Returns:** `void`
- **Calls:** create_timer, _levitate_object, intersect_shape, new, get_world_3d, _complete_task, print, get_tree

### `_task_organize_area()`
- **Lines:** 0
- **Parameters:** `center: Vector3`
- **Returns:** `void`
- **Calls:** sin, create_timer, max, _find_nearby_objects, Vector3, _levitate_object_to, emit, _create_magic_circle, cos, _complete_task, print, get_tree, range, size

### `_task_create_light()`
- **Lines:** 0
- **Parameters:** `light_position: Vector3`
- **Returns:** `void`
- **Calls:** new, _teleport_to, add_child, Vector3, emit, Color, _complete_task, print, get_tree

### `_task_help_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _teleport_to, Vector3, is_empty, _create_healing_effect, has_method, emit, set_health, _complete_task, print, get_tree, get_nodes_in_group

### `_task_clean_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, contains, get_children, emit, _vanish_object, _complete_task, print, append, get_tree, size

### `_task_patrol()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `void`
- **Calls:** _patrol_loop, Vector3, is_empty, print, size

### `_patrol_loop()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `void`
- **Calls:** create_timer, _patrol_loop, _task_organize_area, _teleport_to, _find_nearby_objects, get_tree, size

### `_create_teleport_effect()`
- **Lines:** 0
- **Parameters:** `pos: Vector3`
- **Returns:** `void`
- **Calls:** new, add_child, tween_callback, set_parallel, tween_property, get_tree, chain, create_tween

### `_create_magic_circle()`
- **Lines:** 0
- **Parameters:** `center: Vector3`
- **Returns:** `void`
- **Calls:** new, add_child, tween_callback, tween_property, Color, get_tree, create_tween

### `_create_healing_effect()`
- **Lines:** 0
- **Parameters:** `pos: Vector3`
- **Returns:** `void`
- **Calls:** create_timer, new, add_child, queue_free, Vector3, Color, get_tree

### `_levitate_object()`
- **Lines:** 0
- **Parameters:** `body: RigidBody3D`
- **Returns:** `void`
- **Calls:** tween_callback, create_tween, tween_property

### `_levitate_object_to()`
- **Lines:** 0
- **Parameters:** `body: RigidBody3D, target_pos: Vector3`
- **Returns:** `void`
- **Calls:** tween_callback, set_ease, create_tween, tween_property

### `_vanish_object()`
- **Lines:** 0
- **Parameters:** `obj: Node`
- **Returns:** `void`
- **Calls:** tween_callback, has_method, set_parallel, tween_property, chain, create_tween

### `_find_nearby_objects()`
- **Lines:** 0
- **Parameters:** `center: Vector3, radius: float`
- **Returns:** `Array`
- **Calls:** append, intersect_shape, new, get_world_3d

### `_teleport_to()`
- **Lines:** 0
- **Parameters:** `pos: Vector3`
- **Returns:** `void`
- **Calls:** create_timer, _create_teleport_effect, get_tree

### `_complete_task()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, print

### `set_color()`
- **Lines:** 0
- **Parameters:** `new_color: Color`
- **Returns:** `void`

### `set_being_name()`
- **Lines:** 3
- **Parameters:** `new_name: String`
- **Returns:** `void`


## scripts/core/miracle_declutterer.gd
**Category:** Core Systems
**Functions:** 19

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, get_node, has_node, connect, start, print

### `_update_declutter()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_player_position, is_instance_valid, _update_object_state, erase, _scan_for_new_objects

### `_update_player_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_viewport, get_tree, size, get_nodes_in_group, get_camera_3d

### `_scan_for_new_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _get_all_3d_nodes, get_tree, _should_track, _start_tracking

### `_get_all_3d_nodes()`
- **Lines:** 0
- **Parameters:** `from_node: Node`
- **Returns:** `Array`
- **Calls:** append, append_array, get_children, _get_all_3d_nodes

### `_should_track()`
- **Lines:** 0
- **Parameters:** `node: Node3D`
- **Returns:** `bool`
- **Calls:** has_method

### `_start_tracking()`
- **Lines:** 0
- **Parameters:** `node: Node3D`
- **Returns:** `void`
- **Calls:** _update_object_state, get_script, new

### `_update_object_state()`
- **Lines:** 0
- **Parameters:** `node: Node3D`
- **Returns:** `void`
- **Calls:** _get_zone_for_distance, _apply_zone_state, distance_to

### `_get_zone_for_distance()`
- **Lines:** 0
- **Parameters:** `distance: float`
- **Returns:** `String`

### `_apply_zone_state()`
- **Lines:** 0
- **Parameters:** `state: ObjectState`
- **Returns:** `void`
- **Calls:** _restore_details, has_method, emit, _simplify_visuals, set_process

### `_simplify_visuals()`
- **Lines:** 0
- **Parameters:** `state: ObjectState, quality: float`
- **Returns:** `void`
- **Calls:** _fade_object

### `_restore_details()`
- **Lines:** 0
- **Parameters:** `state: ObjectState`
- **Returns:** `void`
- **Calls:** emit, _fade_object

### `_fade_object()`
- **Lines:** 0
- **Parameters:** `node: Node3D, alpha: float`
- **Returns:** `void`
- **Calls:** get_surface_override_material_count, get_surface_override_material

### `get_zone_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** values, size

### `force_declutter_all()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, objects, _update_declutter, print

### `register_console_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null

### `_cmd_declutter_status()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node, get_zone_report, zone, Void

### `_cmd_toggle_declutter()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node, _apply_zone_state, to_lower, values, size

### `_cmd_show_zones()`
- **Lines:** 9
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, fm


## scripts/core/mouse_interaction_system.gd
**Category:** Core Systems
**Functions:** 33

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_debug_panel, _find_camera, set_process_unhandled_input, print, set_process

### `_exit_tree()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, call_deferred, get_parent

### `_find_camera()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** push_error, print, get_viewport, get_camera_3d

### `_create_debug_panel()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_content_margin_all, Vector2, call_deferred, new, add_child, push_error, get_viewport, set_border_width_all, Color, print, set_corner_radius_all, add_theme_stylebox_override

### `_unhandled_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** _clear_selection, _handle_mouse_click, print, _handle_mouse_hover, _handle_mouse_release

### `_handle_mouse_click()`
- **Lines:** 0
- **Parameters:** `mouse_pos: Vector2`
- **Returns:** `void`
- **Calls:** create, project_ray_normal, get_class, get_world_3d, _clear_selection, intersect_ray, project_ray_origin, _select_object, print, combo_checker, highlight_collision_shape

### `_select_object()`
- **Lines:** 0
- **Parameters:** `obj: Node`
- **Returns:** `void`
- **Calls:** get_class, _print_to_console, _update_debug_panel, get_parent, str, get_meta, get_node_or_null, has_method, get_first_node_in_group, to_lower, get_script, print, is_in_group, get_tree, inspect_object

### `_clear_selection()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print, get_node_or_null, has_method, _on_close_pressed

### `_update_debug_panel()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_class, get_file, str, get_meta, length, get_child_count, min, join, get_script, get_child, get_groups, range, size, get_meta_list

### `_update_panel_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_visible_rect, clamp, get_viewport

### `_process()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _update_debug_panel, _update_panel_position

### `cmd_toggle_debug_panel()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, print

### `cmd_inspect_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, print, get_tree, size, get_nodes_in_group

### `cmd_set_panel_offset()`
- **Lines:** 0
- **Parameters:** `x: float, y: float`
- **Returns:** `void`
- **Calls:** str, Vector2, print

### `cmd_toggle_panel_follow()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, print

### `_handle_mouse_release()`
- **Lines:** 0
- **Parameters:** `mouse_pos: Vector2`
- **Returns:** `void`
- **Calls:** combo_checker, _get_object_at_position, check_combo_patterns

### `_handle_mouse_hover()`
- **Lines:** 0
- **Parameters:** `mouse_pos: Vector2`
- **Returns:** `void`
- **Calls:** highlight_collision_shape, reset_debug_colors, _get_object_at_position

### `_get_object_at_position()`
- **Lines:** 0
- **Parameters:** `mouse_pos: Vector2`
- **Returns:** `Dictionary`
- **Calls:** create, project_ray_normal, get_world_3d, intersect_ray, project_ray_origin

### `highlight_collision_shape()`
- **Lines:** 0
- **Parameters:** `collider: Node, color: Color`
- **Returns:** `void`
- **Calls:** get_children, get_surface_override_material, get_parent, new, get_meta, set_meta, is_empty, set_surface_override_material, surface_get_material, append, has_meta

### `reset_debug_colors()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** remove_meta, is_instance_valid, get_children, get_parent, get_meta, set_surface_override_material, append, clear, has_meta

### `combo_checker()`
- **Lines:** 0
- **Parameters:** `node: Node, state: int`
- **Returns:** `void`
- **Calls:** format_combo_for_display, get_ticks_msec, is_empty, pop_front, print, or, append, size

### `check_combo_patterns()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _on_combo_double_click, _on_combo_click, size, print

### `format_combo_for_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** append, str

### `_on_combo_click()`
- **Lines:** 0
- **Parameters:** `_node: Node`
- **Returns:** `void`

### `_on_combo_double_click()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** is_in_group, queue_action, print

### `_on_action_started()`
- **Lines:** 0
- **Parameters:** `action_name: String, target: Node`
- **Returns:** `void`
- **Calls:** Color, highlight_collision_shape, print

### `_on_action_completed()`
- **Lines:** 0
- **Parameters:** `action_name: String, result: Dictionary`
- **Returns:** `void`
- **Calls:** str, reset_debug_colors, has, print

### `_on_combo_triggered()`
- **Lines:** 0
- **Parameters:** `combo_name: String, targets: Array`
- **Returns:** `void`
- **Calls:** print

### `_on_shape_detected()`
- **Lines:** 0
- **Parameters:** `shape: String, confidence: float`
- **Returns:** `void`
- **Calls:** _create_shape_feedback, s, print

### `_on_spell_gesture()`
- **Lines:** 0
- **Parameters:** `spell: String`
- **Returns:** `void`
- **Calls:** has_method, cast_spell, _find_dimensional_ragdoll, print, _create_spell_effect

### `_create_shape_feedback()`
- **Lines:** 0
- **Parameters:** `shape: String`
- **Returns:** `void`
- **Calls:** print

### `_create_spell_effect()`
- **Lines:** 0
- **Parameters:** `spell: String`
- **Returns:** `void`
- **Calls:** print

### `_find_dimensional_ragdoll()`
- **Lines:** 15
- **Parameters:** ``
- **Returns:** `Node`
- **Calls:** get_node_or_null


## scripts/core/multi_layer_record_system.gd
**Category:** Core Systems
**Functions:** 9

### `move_between_layers()`
- **Lines:** 0
- **Parameters:** `data_key: String, from_layer: String, to_layer: String`
- **Returns:** `bool`
- **Calls:** unlock, erase, has, emit_signal, lock
- **Signals:** layer_transition

### `check_state_in_layers()`
- **Lines:** 0
- **Parameters:** `data_key: String`
- **Returns:** `Dictionary`
- **Calls:** unlock, is_empty, has, lock

### `promote_to_active()`
- **Lines:** 0
- **Parameters:** `data_key: String`
- **Returns:** `String`
- **Calls:** check_state_in_layers, move_between_layers

### `demote_from_active()`
- **Lines:** 0
- **Parameters:** `data_key: String`
- **Returns:** `String`
- **Calls:** check_state_in_layers, move_between_layers

### `batch_operation()`
- **Lines:** 0
- **Parameters:** `keys: Array, operation: String`
- **Returns:** `Dictionary`
- **Calls:** check_state_in_layers, move_between_layers, promote_to_active, demote_from_active

### `get_layer_stats()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** unlock, size, lock, keys

### `cleanup_empty_entries()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `int`
- **Calls:** unlock, is_empty, erase, lock, append

### `store_with_metadata()`
- **Lines:** 0
- **Parameters:** `key: String, data: Variant, layer: String = "pending"`
- **Returns:** `bool`
- **Calls:** get_ticks_msec, unlock, has, emit_signal, lock
- **Signals:** state_changed

### `access_data()`
- **Lines:** 20
- **Parameters:** `key: String`
- **Returns:** `Variant`
- **Calls:** get_ticks_msec, check_state_in_layers, unlock, has, lock


## scripts/core/perfect_astral_being.gd
**Category:** Core Systems
**Functions:** 31

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_perfect_form, _setup_awareness, _begin_existence

### `_create_perfect_form()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, Color, add_child

### `_setup_awareness()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, new, add_child

### `_begin_existence()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _next_action

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _process_flying, _process_patrolling, _update_visual_effects, _process_dancing, _process_behavior_script, _process_organizing, _process_idle, min, _process_helping, _process_hovering, _process_following, _process_creating

### `_process_idle()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** sin

### `_process_hovering()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** sin

### `_process_flying()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** interpolate_with, distance_to, looking_at, length, normalized

### `_process_following()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** Vector3, is_instance_valid, _process_flying

### `_process_creating()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _create_magical_object

### `_process_organizing()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _organize_nearby_objects

### `_process_helping()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _help_nearest_entity

### `_process_patrolling()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** sin, Vector3, cos, _process_flying

### `_process_dancing()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** sin, cos

### `_update_visual_effects()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** sin, size

### `_process_behavior_script()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** is_empty, _next_action

### `_next_action()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get, execute_action, is_empty, size

### `execute_action()`
- **Lines:** 0
- **Parameters:** `action: String, params: Dictionary = {}`
- **Returns:** `void`
- **Calls:** get_node_or_null, has, emit_signal, print
- **Signals:** action_completed

### `_create_magical_object()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, get_parent, add_child, load, Vector3, randi, become, size

### `_organize_nearby_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sin, is_instance_valid, Vector3, set_target_position, is_empty, has_method, cos, range, size, lerp

### `_help_nearest_entity()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_method, needs_help, emit_signal, receive_help, append
- **Signals:** entity_helped

### `connect_to_being()`
- **Lines:** 0
- **Parameters:** `other_being: PerfectAstralBeing`
- **Returns:** `void`
- **Calls:** _create_connection_line, append, emit_signal, lerp
- **Signals:** being_connected

### `_create_connection_line()`
- **Lines:** 0
- **Parameters:** `target: Node3D`
- **Returns:** `void`
- **Calls:** append, new, add_child

### `_on_body_entered()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** append, connect_to_being

### `_on_body_exited()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** erase

### `_on_area_entered()`
- **Lines:** 0
- **Parameters:** `area: Area3D`
- **Returns:** `void`
- **Calls:** connect_to_being, get_parent

### `execute_wish()`
- **Lines:** 0
- **Parameters:** `wish: String`
- **Returns:** `void`
- **Calls:** connect_to_being, execute_action, is_empty, _next_action, to_lower, get_nodes_in_group, emit_signal, get_tree, size, split
- **Signals:** wish_fulfilled

### `assign_task()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `void`
- **Calls:** execute_action, has, _next_action

### `set_lod_level()`
- **Lines:** 0
- **Parameters:** `level: int`
- **Returns:** `void`

### `serialize()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** to_html

### `deserialize()`
- **Lines:** 11
- **Parameters:** `data: Dictionary`
- **Returns:** `void`
- **Calls:** _create_perfect_form, Color, get


## scripts/core/perfect_delta_process.gd
**Category:** Core Systems
**Functions:** 12

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _register_commands, set_process, print

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** is_instance_valid, _apply_adaptive_skipping, call, _optimize_process_order, get_ticks_usec, emit, erase

### `register_process()`
- **Lines:** 0
- **Parameters:** `node: Node, callback: Callable, priority: int = 50, group: String = "default"`
- **Returns:** `void`
- **Calls:** new, _optimize_process_order, s, has_method, push_warning, emit, get_script, print, append, set_physics_process, set_process

### `unregister_process()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** erase, print

### `_optimize_process_order()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, clear, sort_custom, append_array

### `_apply_adaptive_skipping()`
- **Lines:** 0
- **Parameters:** `info: ProcessorInfo`
- **Returns:** `void`

### `get_processor_stats()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** max, size

### `force_process_all()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_instance_valid, call, immediately, get_process_delta_time, print

### `_register_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null

### `_cmd_show_stats()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, get_processor_stats

### `_cmd_list_processors()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console

### `_cmd_force_process()`
- **Lines:** 5
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, size, force_process_all


## scripts/core/performance_guardian.gd
**Category:** Core Systems
**Functions:** 13

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, set_process, print

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** get_process_frames, size, pop_front, append, get_frames_per_second, _check_performance

### `_check_performance()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _emergency_optimization, _reduce_nodes, get_node_count, _critical_optimization, _reduce_optimization, _get_average_fps, _standard_optimization, _reduce_beings, get_tree, size, get_nodes_in_group

### `_get_average_fps()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `float`
- **Calls:** is_empty, size

### `_standard_optimization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _get_player_position, str, has_method, emit, print, append, get_tree, get_nodes_in_group, freeze

### `_critical_optimization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, length, emit, _standard_optimization, print, get_aabb, append, get_tree, get_nodes_in_group, int

### `_emergency_optimization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sort_custom, distance_to, queue_free, _get_player_position, str, has_method, emit, print, is_in_group, get_tree, range, size, get_nodes_in_group, freeze

### `_reduce_optimization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** max, is_instance_valid, str, unfreeze, print, slice

### `_reduce_nodes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, str, snapped, has, print, get_tree, get_nodes_in_group

### `_reduce_beings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_instance_valid, distance_to, queue_free, print, get_tree, range, size, get_nodes_in_group

### `_get_player_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`
- **Calls:** get_tree, get_first_node_in_group, get_viewport, get_camera_3d

### `get_performance_stats()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_static_memory_usage, size, get_node_count, _get_average_fps, get_tree, get_frames_per_second, get_nodes_in_group

### `force_optimization()`
- **Lines:** 7
- **Parameters:** `level: int`
- **Returns:** `void`
- **Calls:** _critical_optimization, _standard_optimization, _emergency_optimization, _reduce_optimization


## scripts/core/physics_state_manager.gd
**Category:** Core Systems
**Functions:** 27

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_physics_process

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _apply_custom_physics, _process_state_transitions

### `set_object_state()`
- **Lines:** 0
- **Parameters:** `object: Node3D, new_state: PhysicsState, force: bool = false`
- **Returns:** `bool`
- **Calls:** _can_transition, _state_to_string, get_ticks_msec, print, append, get_object_state

### `get_object_state()`
- **Lines:** 0
- **Parameters:** `object: Node3D`
- **Returns:** `PhysicsState`
- **Calls:** get

### `_can_transition()`
- **Lines:** 0
- **Parameters:** `from_state: PhysicsState, to_state: PhysicsState`
- **Returns:** `bool`

### `_process_state_transitions()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _complete_state_transition, _update_state_transition, append, remove_at, range, size

### `_complete_state_transition()`
- **Lines:** 0
- **Parameters:** `transition: Dictionary`
- **Returns:** `void`
- **Calls:** is_instance_valid, _state_to_string, _apply_physics_state, emit_signal, print
- **Signals:** state_changed

### `_update_state_transition()`
- **Lines:** 0
- **Parameters:** `transition: Dictionary, _delta: float`
- **Returns:** `void`
- **Calls:** sin, _apply_transition_physics, is_instance_valid, has_method

### `_apply_physics_state()`
- **Lines:** 0
- **Parameters:** `object: Node3D, state: PhysicsState`
- **Returns:** `void`
- **Calls:** _make_connected, _make_static, _make_ethereal, _make_dynamic, _make_kinematic

### `_make_static()`
- **Lines:** 0
- **Parameters:** `object: Node3D`
- **Returns:** `void`
- **Calls:** set_physics_process, _set_collision_enabled

### `_make_kinematic()`
- **Lines:** 0
- **Parameters:** `object: Node3D`
- **Returns:** `void`
- **Calls:** set_physics_process, _set_collision_enabled

### `_make_dynamic()`
- **Lines:** 0
- **Parameters:** `object: Node3D`
- **Returns:** `void`
- **Calls:** set_physics_process, _set_collision_enabled

### `_make_ethereal()`
- **Lines:** 0
- **Parameters:** `object: Node3D`
- **Returns:** `void`
- **Calls:** has_method, _set_collision_enabled

### `_make_connected()`
- **Lines:** 0
- **Parameters:** `object: Node3D`
- **Returns:** `void`
- **Calls:** _make_kinematic

### `_set_collision_enabled()`
- **Lines:** 0
- **Parameters:** `object: Node3D, enabled: bool`
- **Returns:** `void`
- **Calls:** _find_collision_shapes

### `_find_collision_shapes()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `Array`
- **Calls:** _find_collision_shapes, append, append_array, get_children

### `_apply_transition_physics()`
- **Lines:** 0
- **Parameters:** `object: Node3D, transition: Dictionary, progress: float`
- **Returns:** `void`

### `_apply_custom_physics()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _apply_custom_gravity, is_instance_valid

### `_apply_custom_gravity()`
- **Lines:** 0
- **Parameters:** `object: RigidBody3D, _delta: float`
- **Returns:** `void`
- **Calls:** apply_central_force, max, normalized, distance_to

### `prepare_object_for_manipulation()`
- **Lines:** 0
- **Parameters:** `object: Node3D, _astral_being: Node3D`
- **Returns:** `bool`
- **Calls:** set_object_state, get_object_state, print

### `astral_being_manipulate()`
- **Lines:** 0
- **Parameters:** `astral_being: Node3D, target_object: Node3D, force: Vector3`
- **Returns:** `bool`
- **Calls:** apply_central_force, get_object_state, get_physics_process_delta_time, prepare_object_for_manipulation

### `set_scene_zero_point()`
- **Lines:** 0
- **Parameters:** `point: Vector3`
- **Returns:** `void`

### `set_gravity_center()`
- **Lines:** 0
- **Parameters:** `center: Vector3, strength: float = 9.8`
- **Returns:** `void`
- **Calls:** emit_signal
- **Signals:** gravity_modified

### `set_player_reference()`
- **Lines:** 0
- **Parameters:** `player: Node3D`
- **Returns:** `void`
- **Calls:** set_object_state

### `get_objects_in_state()`
- **Lines:** 0
- **Parameters:** `state: PhysicsState`
- **Returns:** `Array`
- **Calls:** append, is_instance_valid

### `_state_to_string()`
- **Lines:** 0
- **Parameters:** `state: PhysicsState`
- **Returns:** `String`

### `get_state_info()`
- **Lines:** 14
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** values, _state_to_string, size, get_objects_in_state


## scripts/core/pigeon_input_manager.gd
**Category:** Core Systems
**Functions:** 3

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_input_actions

### `_setup_input_actions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _add_action_if_missing

### `_add_action_if_missing()`
- **Lines:** 8
- **Parameters:** `action_name: String, keys: Array`
- **Returns:** `void`
- **Calls:** has_action, add_action, new, action_add_event


## scripts/core/pigeon_physics_controller.gd
**Category:** Core Systems
**Functions:** 15

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_physics_points, _set_idle_position, _create_visual_mesh, _setup_collision, set_physics_process

### `_create_physics_points()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `_create_visual_mesh()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_triangles, new, Color, add_child

### `_setup_collision()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_landing, _process_flying, _process_idle, is_on_floor, _update_triangles, move_and_slide, _process_walking, _update_balance

### `_process_walking()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, Vector3, clamp, get_vector, abs, normalized, lerp

### `_process_flying()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, is_action_pressed, max, Vector3, min, get_vector, normalized, lerp

### `_process_landing()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** set_movement_mode, lerp

### `_process_idle()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** get_ticks_msec, randf, sin, randf_range

### `_update_balance()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** lerp

### `_update_triangles()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, new, resize, PackedVector3Array, PackedColorArray, Color, append, clear_surfaces, range

### `set_movement_mode()`
- **Lines:** 0
- **Parameters:** `mode: MovementMode`
- **Returns:** `void`
- **Calls:** emit

### `jump()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_movement_mode

### `_set_idle_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3

### `_input()`
- **Lines:** 12
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** set_movement_mode, is_action_pressed, jump


## scripts/core/ragdoll_controller.gd
**Category:** Core Systems
**Functions:** 33

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_default_patrol, get_node, has_node, set_behavior_state, print, _find_ragdoll_body

### `_spawn_seven_part_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, load, add_child, Vector3, set_script, print, get_tree

### `_find_ragdoll_body()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _spawn_seven_part_ragdoll, has_method, print, get_tree, size, get_nodes_in_group

### `_setup_default_patrol()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_investigating, _process_organizing, _process_carrying, _process_idle, _process_helping, _process_walking

### `_process_idle()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** move_to_position, move_to_object, _find_nearby_objects, set_behavior_state, size

### `_process_walking()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** distance_to, set_behavior_state, emit_signal, _apply_movement_to_ragdoll, size
- **Signals:** movement_completed

### `_process_investigating()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _find_nearby_objects, set_behavior_state, size, attempt_pickup

### `_process_carrying()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_carried_object_position, set_behavior_state, _look_for_organization_spot

### `_process_helping()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`

### `_process_organizing()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** drop_object_at_position, _find_good_drop_position

### `_apply_movement_to_ragdoll()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** atan2, apply_torque, Vector3, start_walking, length, has_method, normalized, apply_central_force, angle_difference, get_body

### `_find_nearby_objects()`
- **Lines:** 0
- **Parameters:** `radius: float = 5.0`
- **Returns:** `Array`
- **Calls:** sort_custom, distance_to, append, get_tree, get_nodes_in_group

### `_update_carried_object_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_look_for_organization_spot()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf, set_behavior_state

### `_find_good_drop_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`
- **Calls:** randf_range, _is_position_clear, Vector3

### `_is_position_clear()`
- **Lines:** 0
- **Parameters:** `position: Vector3, radius: float`
- **Returns:** `bool`
- **Calls:** _find_nearby_objects, distance_to

### `cmd_ragdoll_come()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_method, get_viewport, print, come_to_position, get_camera_3d

### `cmd_ragdoll_pickup()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** pick_up_nearest_object, has_method, print

### `cmd_ragdoll_drop()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_method, handle_console_command, print

### `cmd_ragdoll_organize()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** organize_nearby_objects, has_method, print

### `cmd_ragdoll_patrol()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** move_to_position, set_behavior_state, print

### `move_to_position()`
- **Lines:** 0
- **Parameters:** `target: Vector3`
- **Returns:** `void`
- **Calls:** str, emit_signal, print
- **Signals:** movement_started

### `move_to_object()`
- **Lines:** 0
- **Parameters:** `object: Node3D`
- **Returns:** `void`
- **Calls:** move_to_position

### `attempt_pickup()`
- **Lines:** 0
- **Parameters:** `object: RigidBody3D`
- **Returns:** `bool`
- **Calls:** distance_to, set_behavior_state, emit_signal, print, add_to_group
- **Signals:** object_picked_up

### `drop_object()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** drop_object_at_position, Vector3

### `drop_object_at_position()`
- **Lines:** 0
- **Parameters:** `position: Vector3`
- **Returns:** `void`
- **Calls:** remove_from_group, set_behavior_state, emit_signal, print
- **Signals:** object_dropped

### `set_behavior_state()`
- **Lines:** 0
- **Parameters:** `new_state: BehaviorState`
- **Returns:** `void`
- **Calls:** start_walking, str, stop_walking, has_method, print

### `help_player_with_task()`
- **Lines:** 0
- **Parameters:** `task_description: String`
- **Returns:** `void`
- **Calls:** set_behavior_state, emit_signal, print
- **Signals:** player_needs_help

### `organize_nearby_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_behavior_state, print

### `cmd_ragdoll_come_here()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** move_to_position, get_viewport, get_camera_3d

### `cmd_ragdoll_pickup_nearest()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, attempt_pickup, move_to_object, _find_nearby_objects, get_tree, size

### `get_ragdoll_body()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `RigidBody3D`


## scripts/core/scene_editor_integration.gd
**Category:** Core Systems
**Functions:** 55

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _register_console_commands, _setup_references, print

### `_setup_references()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null

### `_register_console_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command

### `_cmd_scene_edit()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _exit_edit_mode, size, _enter_edit_mode, print

### `_cmd_scene_save()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** ends_with, _save_scene, size, print

### `_cmd_scene_load()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _load_scene_for_editing, size, print

### `_cmd_scene_new()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _create_new_scene, print

### `_cmd_scene_export()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _export_scene, size, print

### `_cmd_select()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _find_node_by_name, _select_object, size, print

### `_cmd_select_all()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _select_all_children, str, print, get_tree, size

### `_cmd_deselect()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _deselect_all, print

### `_cmd_delete_selected()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** str, is_empty, _queue_delete_operation, print, clear, size

### `_cmd_duplicate_selected()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** str, _queue_duplicate_operation, is_empty, _deselect_all, _select_object, print, append, size

### `_cmd_move()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** Vector3, str, is_empty, _queue_move_operation, print, float, size

### `_cmd_rotate()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** Vector3, str, is_empty, print, _queue_rotate_operation, float, size

### `_cmd_scale()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** Vector3, str, is_empty, print, float, size, _queue_scale_operation

### `_cmd_reset_transform()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** str, is_empty, _queue_move_operation, print, _queue_rotate_operation, size, _queue_scale_operation

### `_cmd_create_node()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _create_node_of_type, _select_object, print, _queue_add_node_operation, size

### `_cmd_create_mesh()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** new, to_lower, _select_object, print, _queue_add_node_operation, size

### `_cmd_create_light()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** new, to_lower, _select_object, print, _queue_add_node_operation, size

### `_cmd_create_camera()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** new, str, Vector3, look_at, _select_object, _queue_add_node_operation, print, get_tree, size, get_nodes_in_group

### `_cmd_inspect()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _find_node_by_name, size, _open_inspector_for_object, print

### `_cmd_set_property()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** set, _track_property_change, str, is_empty, has_method, _parse_property_value, print, size

### `_cmd_get_property()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, is_empty, has_method, print, size, get

### `_cmd_grid()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** size, print

### `_cmd_grid_size()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, float, size, print

### `_cmd_snap_to_grid()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** str, _snap_to_grid_position, is_empty, _queue_move_operation, print

### `_enter_edit_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, _enable_edit_visuals, clear, _capture_scene_state

### `_exit_edit_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _disable_edit_visuals, str, emit, print, size

### `_save_scene()`
- **Lines:** 0
- **Parameters:** `path: String`
- **Returns:** `void`
- **Calls:** pack, new, str, save, print, get_tree, clear

### `_load_scene_for_editing()`
- **Lines:** 0
- **Parameters:** `path: String`
- **Returns:** `void`
- **Calls:** load, queue_free, add_child, instantiate, exists, _enter_edit_mode, print, get_tree, clear

### `_create_new_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, queue_free, Vector3, _enter_edit_mode, get_tree, clear

### `_export_scene()`
- **Lines:** 0
- **Parameters:** `format: String, _path: String`
- **Returns:** `void`
- **Calls:** print

### `_queue_add_node_operation()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** queue_operation, get_parent, add_child, _track_scene_change, get_tree, size

### `_queue_delete_operation()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** queue_free, _track_scene_change, queue_operation

### `_queue_move_operation()`
- **Lines:** 0
- **Parameters:** `node: Node3D, new_position: Vector3`
- **Returns:** `void`
- **Calls:** _track_scene_change, queue_operation, _snap_to_grid_position

### `_queue_rotate_operation()`
- **Lines:** 0
- **Parameters:** `node: Node3D, new_rotation: Vector3`
- **Returns:** `void`
- **Calls:** _track_scene_change, queue_operation

### `_queue_scale_operation()`
- **Lines:** 0
- **Parameters:** `node: Node3D, new_scale: Vector3`
- **Returns:** `void`
- **Calls:** _track_scene_change, queue_operation

### `_queue_duplicate_operation()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `Node`
- **Calls:** Vector3, _queue_add_node_operation, duplicate

### `_find_node_by_name()`
- **Lines:** 0
- **Parameters:** `target_name: String`
- **Returns:** `Node`
- **Calls:** _find_node_recursive, get_tree, get_node_or_null, NodePath

### `_find_node_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node, search_name: String`
- **Returns:** `Node`
- **Calls:** _find_node_recursive, get_children

### `_select_object()`
- **Lines:** 0
- **Parameters:** `obj: Node`
- **Returns:** `void`
- **Calls:** emit, append, _highlight_object

### `_deselect_all()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _highlight_object, clear

### `_select_all_children()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** get_tree, _select_all_children, _select_object, get_children

### `_highlight_object()`
- **Lines:** 0
- **Parameters:** `obj: Node, highlight: bool`
- **Returns:** `void`
- **Calls:** has_method

### `_create_node_of_type()`
- **Lines:** 0
- **Parameters:** `type_name: String`
- **Returns:** `Node`
- **Calls:** instantiate, class_exists, get, to_lower

### `_parse_property_value()`
- **Lines:** 0
- **Parameters:** `value_str: String`
- **Returns:** `Variant`
- **Calls:** Vector2, is_valid_int, is_valid_float, contains, strip_edges, Vector3, to_lower, count, trim_suffix, Color, trim_prefix, begins_with, float, size, split, int

### `_snap_to_grid_position()`
- **Lines:** 0
- **Parameters:** `pos: Vector3`
- **Returns:** `Vector3`
- **Calls:** Vector3, round

### `_capture_scene_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, get_tree, _capture_node_state

### `_capture_node_state()`
- **Lines:** 0
- **Parameters:** `node: Node, state_dict: Dictionary`
- **Returns:** `void`
- **Calls:** _capture_node_state, get_path, has_method, get_children

### `_track_scene_change()`
- **Lines:** 0
- **Parameters:** `change_type: String, node: Node, data: Dictionary = {}`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, emit, get_path

### `_track_property_change()`
- **Lines:** 0
- **Parameters:** `node: Node, property: String, value: Variant`
- **Returns:** `void`
- **Calls:** _track_scene_change

### `_enable_edit_visuals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_disable_edit_visuals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_open_inspector_for_object()`
- **Lines:** 17
- **Parameters:** `obj: Node`
- **Returns:** `void`
- **Calls:** new, load, add_child, has_method, inspect_object, get_tree, add_to_group, size, get_nodes_in_group


## scripts/core/scene_setup.gd
**Category:** Core Systems
**Functions:** 7

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _setup_ragdoll_system, print

### `_setup_ragdoll_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, load, add_child, get_node_or_null, set_script, print, get_tree

### `_setup_astral_beings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, print

### `_setup_existing_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print, is_in_group, get_tree, add_to_group, get_nodes_in_group

### `create_test_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf_range, get_node, Vector3, str, print, create_tree_at_position, range, create_box_at_position

### `cmd_setup_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_ragdoll_system, _setup_existing_ragdoll, print

### `cmd_create_test_objects()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_test_objects


## scripts/core/scene_tree_tracker.gd
**Category:** Core Systems
**Functions:** 19

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** start_up_scene_tree

### `start_up_scene_tree()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_class, get_ticks_msec, unlock, duplicate, lock, get_tree

### `track_node()`
- **Lines:** 0
- **Parameters:** `node: Node, category: String = ""`
- **Returns:** `void`
- **Calls:** get_class, get_base_dir, get_ticks_msec, unlock, str, duplicate, get_path, has, lock, append, range, size, split

### `untrack_node()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** unlock, str, _remove_branch_by_path, get_path, lock

### `jsh_tree_get_node()`
- **Lines:** 0
- **Parameters:** `node_path_get: String`
- **Returns:** `Node`
- **Calls:** get, unlock, has, lock, range, size, split

### `build_pretty_print()`
- **Lines:** 0
- **Parameters:** `start_branch: Dictionary = {}, prefix: String = "", is_last: bool = true`
- **Returns:** `String`
- **Calls:** keys, is_empty, build_pretty_print, range, size, get

### `print_tree_structure()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** build_pretty_print, print

### `get_nodes_by_type()`
- **Lines:** 0
- **Parameters:** `jsh_type: String`
- **Returns:** `Array[Node]`
- **Calls:** unlock, _collect_nodes_by_type, lock

### `_collect_nodes_by_type()`
- **Lines:** 0
- **Parameters:** `branches: Dictionary, jsh_type: String, nodes: Array[Node]`
- **Returns:** `void`
- **Calls:** append, _collect_nodes_by_type, has, get

### `_remove_branch_by_path()`
- **Lines:** 0
- **Parameters:** `path: String`
- **Returns:** `void`
- **Calls:** is_empty, erase, has, append, range, size, split

### `get_tree_stats()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** unlock, lock, _collect_stats

### `_collect_stats()`
- **Lines:** 0
- **Parameters:** `branches: Dictionary, stats: Dictionary`
- **Returns:** `void`
- **Calls:** has, get, _collect_stats

### `has_branch()`
- **Lines:** 0
- **Parameters:** `path: String`
- **Returns:** `bool`
- **Calls:** unlock, has, lock, split

### `get_branch()`
- **Lines:** 0
- **Parameters:** `path: String`
- **Returns:** `Dictionary`
- **Calls:** unlock, has, lock, split

### `_set_branch_unsafe()`
- **Lines:** 0
- **Parameters:** `path: String, data: Dictionary`
- **Returns:** `void`
- **Calls:** has, range, size, split

### `track_ragdoll_movement()`
- **Lines:** 0
- **Parameters:** `ragdoll_id: String, position: Vector3, state: String`
- **Returns:** `void`
- **Calls:** has_branch, unlock, str, _set_branch_unsafe, get_branch, pop_front, has, lock, print, append, _ensure_ragdoll_parent_structure, size, get_unix_time_from_system

### `_ensure_ragdoll_parent_structure()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _set_branch_unsafe, has_branch

### `get_ragdoll_status()`
- **Lines:** 0
- **Parameters:** `ragdoll_id: String`
- **Returns:** `Dictionary`
- **Calls:** has_branch, get_branch

### `get_all_ragdolls()`
- **Lines:** 5
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** has_branch, get_branch, get


## scripts/core/self_repair_system.gd
**Category:** Core Systems
**Functions:** 32

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_python_integration, _setup_repair_strategies, str, _print, _scan_all_scripts, size

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _perform_health_check, _update_csv_data

### `_scan_all_scripts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _register_script, _find_all_scripts, str, _print, size

### `_find_all_scripts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** _scan_directory

### `_scan_directory()`
- **Lines:** 0
- **Parameters:** `path: String, scripts: Array`
- **Returns:** `void`
- **Calls:** open, get_next, begins_with, _scan_directory, current_is_dir, append, ends_with, list_dir_begin

### `_register_script()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `void`
- **Calls:** _analyze_script_content, get_modified_time, _categorize_script

### `_categorize_script()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `String`

### `_analyze_script_content()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `void`
- **Calls:** get_as_text, open, close, _detect_potential_issues, count

### `_detect_potential_issues()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `Array`
- **Calls:** append, contains

### `_perform_health_check()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _attempt_repair, str, _check_script_health, _print, emit

### `_check_script_health()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `String`
- **Calls:** get_modified_time, is_instance_valid, _find_script_instances, file_exists, _analyze_script_content

### `_find_script_instances()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `Array`
- **Calls:** get_tree, _find_instances_recursive

### `_find_instances_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node, script_path: String, instances: Array`
- **Returns:** `void`
- **Calls:** get_children, str, _find_instances_recursive, get_script, append

### `_setup_repair_strategies()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_attempt_repair()`
- **Lines:** 0
- **Parameters:** `script_path: String, issue: String`
- **Returns:** `void`
- **Calls:** emit, call, _print

### `_repair_missing_file()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `bool`
- **Calls:** _print

### `_repair_invalid_instance()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `bool`
- **Calls:** is_instance_valid, _print

### `_repair_recent_modification()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `bool`
- **Calls:** _analyze_script_content, _print

### `_repair_null_access()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `bool`

### `_repair_double_free()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `bool`

### `_setup_python_integration()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_python_updater

### `_update_csv_data()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, close, store_line, get_ticks_msec, str, _print, size, get

### `_create_python_updater()`
- **Lines:** 3
- **Parameters:** ``
- **Returns:** `void`

### `connect_variable_inspector()`
- **Lines:** 0
- **Parameters:** `script_path: String, inspector: Node`
- **Returns:** `void`
- **Calls:** append, _print

### `get_script_variables()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `Dictionary`
- **Calls:** merge, has_method, get_all_variables

### `register_console_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_command, get_node_or_null, has_method

### `_cmd_scan()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** _perform_health_check

### `_cmd_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get_ticks_msec, str, size

### `_cmd_update_csv()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** _update_csv_data

### `_cmd_run_python()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** _create_python_updater, file_exists

### `request_scene_closure()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, _print_to_console, get_node_or_null, has_method, _print, _update_csv_data, quit, get_tree

### `_print()`
- **Lines:** 2
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** print


## scripts/core/seven_part_ragdoll_integration.gd
**Category:** Core Systems
**Functions:** 36

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, _setup_seven_part_body, _connect_to_floodgate, str, has_node, _setup_dialogue_system, stand_up, print, _connect_to_jsh_framework, get_tree, _setup_enhanced_walker, add_to_group, get_unix_time_from_system

### `_setup_seven_part_body()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_joints, add_child, Vector3, _create_body_part, set_meta, has, append

### `_setup_enhanced_walker()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, set_script, print, added

### `_create_body_part()`
- **Lines:** 0
- **Parameters:** `part_name: String`
- **Returns:** `Node3D`
- **Calls:** Vector3, part, new, add_child

### `_create_joints()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary`
- **Returns:** `void`
- **Calls:** _create_knee_joint, _create_hip_joint, _create_ankle_joint

### `_create_hip_joint()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary, parent_name: String, child_name: String`
- **Returns:** `void`
- **Calls:** set_param_y, set_param_z, set_flag_x, set_flag_y, new, add_child, Vector3, set_param_x, get_path, has, set_flag_z

### `_create_knee_joint()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary, parent_name: String, child_name: String`
- **Returns:** `void`
- **Calls:** set_param, new, add_child, Vector3, get_path, has, set_flag

### `_create_ankle_joint()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary, parent_name: String, child_name: String`
- **Returns:** `void`
- **Calls:** set_param, new, add_child, Vector3, get_path, has, set_flag

### `_connect_to_jsh_framework()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, get_node_or_null, has_method, print

### `_connect_to_floodgate()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_ragdoll_position_update, get_node_or_null, connect, print

### `_setup_dialogue_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf_range, add_child, new, connect

### `_speak_random_phrase()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, randi, size, print

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_walking_movement, _update_dialogue

### `_process_walking_movement()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _handle_target_reached, distance_to, str, has_node, length, is_empty, start_walking, stop_walking, get_meta, _next_patrol_point, pop_front, print, _calculate_movement_direction, get

### `come_to_position()`
- **Lines:** 0
- **Parameters:** `pos: Vector3`
- **Returns:** `void`
- **Calls:** emit, str, print

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** say, has_node, stop_walking, emit, clear

### `pick_up_nearest_object()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** distance_to, Vector3, emit, print, get_tree, get_nodes_in_group

### `organize_nearby_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, min, emit, print, get_tree, range, size, get_nodes_in_group

### `reset_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, has_node, get_meta, stop_walking, emit, stand_up, print, get

### `say_text()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** emit, print

### `get_ragdoll_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`

### `_calculate_movement_direction()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`
- **Calls:** _apply_obstacle_avoidance, normalized

### `_apply_obstacle_avoidance()`
- **Lines:** 0
- **Parameters:** `base_direction: Vector3`
- **Returns:** `Vector3`
- **Calls:** create, get_world_3d, return, Vector3, intersect_ray, normalized

### `_handle_target_reached()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, stop_walking, is_empty, _next_patrol_point, pop_front, print

### `_next_patrol_point()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, str, size, print

### `add_waypoint()`
- **Lines:** 0
- **Parameters:** `waypoint: Vector3`
- **Returns:** `void`
- **Calls:** emit, append, str, print

### `clear_waypoints()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, print

### `start_patrol()`
- **Lines:** 0
- **Parameters:** `points: Array[Vector3]`
- **Returns:** `void`
- **Calls:** str, come_to_position, size, print

### `stop_patrol()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, stop_walking, print

### `_on_ragdoll_state_changed()`
- **Lines:** 0
- **Parameters:** `new_state: String`
- **Returns:** `void`
- **Calls:** get_node_or_null, queue_ragdoll_position_update

### `_on_ragdoll_position_updated()`
- **Lines:** 0
- **Parameters:** `pos: Vector3`
- **Returns:** `void`
- **Calls:** get_node_or_null, queue_ragdoll_position_update

### `handle_console_command()`
- **Lines:** 0
- **Parameters:** `command: String, args: Array`
- **Returns:** `String`
- **Calls:** pick_up_nearest_object, say_text, str, Vector3, stop_patrol, get_ragdoll_status, come_to_position, points, join, organize_nearby_objects, add_waypoint, start_patrol, reset_position, append, range, float, size

### `say()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** get_node_or_null, has_method, show_ragdoll_dialogue, emit, print

### `_update_dialogue()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** say, randf, frame, randi, size, get

### `toggle_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** start_walking, stop_walking

### `start_walking()`
- **Lines:** 7
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** say, stand_up, has_method


## scripts/core/shape_gesture_system.gd
**Category:** Core Systems
**Functions:** 16

### `start_gesture()`
- **Lines:** 0
- **Parameters:** `start_pos: Vector2`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, clear

### `add_gesture_point()`
- **Lines:** 0
- **Parameters:** `pos: Vector2`
- **Returns:** `void`
- **Calls:** distance_to, get_ticks_msec, end_gesture, pop_front, append, size

### `end_gesture()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _detect_shape, size, emit_signal
- **Signals:** spell_gesture_recognized, gesture_completed, shape_detected

### `_detect_shape()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `String`
- **Calls:** _is_zigzag, _is_line, _is_triangle, _is_spiral, _is_square, _is_circle, size, _is_star

### `_is_circle()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `bool`
- **Calls:** size, distance_to, abs

### `_is_triangle()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `bool`
- **Calls:** _find_corners, size, distance_to, _get_shape_size

### `_is_square()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `bool`
- **Calls:** _calculate_angle, _find_corners, abs, range, size

### `_is_star()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `bool`
- **Calls:** _find_corners, size

### `_is_spiral()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `bool`
- **Calls:** range, size, distance_to

### `_is_line()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `bool`
- **Calls:** max, distance_to, dot, normalized, size

### `_is_zigzag()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `bool`
- **Calls:** size, abs, normalized, range, angle_to

### `_find_corners()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `Array`
- **Calls:** _calculate_angle, append, range, size

### `_calculate_angle()`
- **Lines:** 0
- **Parameters:** `p1: Vector2, p2: Vector2, p3: Vector2`
- **Returns:** `float`
- **Calls:** acos, clamp, dot, normalized

### `_get_shape_size()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `float`
- **Calls:** max, min, distance_to

### `get_gesture_direction()`
- **Lines:** 0
- **Parameters:** `points: Array`
- **Returns:** `String`
- **Calls:** range, size

### `get_simplified_path()`
- **Lines:** 12
- **Parameters:** `points: Array, max_simplified_points: int = 50`
- **Returns:** `Array`
- **Calls:** append, float, range, size, int


## scripts/core/simple_astral_being.gd
**Category:** Core Systems
**Functions:** 19

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _start_behavior, _create_visual_form

### `_create_visual_form()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, Color, add_child

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** sin, get_ticks_msec, _process_current_action

### `_process_current_action()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _hover_in_place, _fly_to_target, _fly_to_position, _look_around, _next_action, _follow_target, _create_something, _transform_something

### `_next_action()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _find_named_target, _find_random_target, is_empty, emit_signal, size, get
- **Signals:** action_completed

### `_fly_to_target()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** look_at, length, normalized

### `_fly_to_position()`
- **Lines:** 0
- **Parameters:** `target_pos: Vector3, delta`
- **Returns:** `void`
- **Calls:** normalized, distance_to

### `_hover_in_place()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** sin, get_ticks_msec

### `_look_around()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** rotate_y

### `_follow_target()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** Vector3, _fly_to_position

### `_create_something()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, get_parent, add_child, preload, Vector3, randf, become, Color

### `_transform_something()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _find_nearest_object, has_method, become

### `_find_random_target()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node3D`
- **Calls:** randf_range, new, get_parent, add_child, Vector3, is_empty, randi, get_tree, size, get_nodes_in_group

### `_find_named_target()`
- **Lines:** 0
- **Parameters:** `target_name: String`
- **Returns:** `Node3D`
- **Calls:** get_tree, get_node_or_null, get_first_node_in_group

### `_find_nearest_object()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node3D`
- **Calls:** get_tree, get_nodes_in_group, distance_to

### `execute_wish()`
- **Lines:** 0
- **Parameters:** `wish: String`
- **Returns:** `void`
- **Calls:** _find_named_target, is_empty, to_lower, emit_signal, size, split
- **Signals:** wish_granted

### `set_behavior_script()`
- **Lines:** 0
- **Parameters:** `new_script: Array`
- **Returns:** `void`
- **Calls:** _next_action

### `_start_behavior()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _next_action

### `set_lod_level()`
- **Lines:** 14
- **Parameters:** `level: int`
- **Returns:** `void`


## scripts/core/simple_ragdoll_walker.gd
**Category:** Core Systems
**Functions:** 27

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _configure_physics, _find_body_parts, print, get_tree, set_physics_process

### `_find_body_parts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_parent, get_meta, print, has_meta, get

### `_configure_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_state, _process_balancing, _process_standing_up, _process_idle, _process_stepping, _process_falling

### `_update_state()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _is_on_ground, length, _is_upright, _is_falling

### `_process_idle()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_process_standing_up()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _apply_upright_torque, Vector3, apply_central_impulse, _position_feet_for_standing, _apply_leg_straightening_forces, apply_central_force

### `_process_balancing()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _maintain_height, _apply_upright_torque, _balance_over_feet

### `_process_stepping()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _maintain_height, _apply_step_forces, _apply_upright_torque

### `_process_falling()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _orient_feet_down

### `_maintain_height()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force

### `_apply_upright_torque()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_finite, apply_torque, length_squared, dot, is_zero_approx, cross

### `_balance_over_feet()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, _calculate_center_of_mass

### `_apply_step_forces()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, _stabilize_foot

### `_apply_leg_straightening_forces()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, limit_length

### `_stabilize_foot()`
- **Lines:** 0
- **Parameters:** `foot: RigidBody3D`
- **Returns:** `void`
- **Calls:** apply_central_force

### `_orient_feet_down()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_finite, apply_torque, length_squared, is_zero_approx, cross

### `_is_upright()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** dot, length, abs

### `_is_falling()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** or, return, length, _is_on_ground

### `_is_on_ground()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`

### `_calculate_center_of_mass()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`

### `_position_feet_for_standing()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, apply_torque, limit_length

### `start_walking()`
- **Lines:** 0
- **Parameters:** `direction: Vector3`
- **Returns:** `void`
- **Calls:** str, normalized, print

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `stand_up()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `get_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`

### `set_movement_input()`
- **Lines:** 26
- **Parameters:** `input: Vector2`
- **Returns:** `void`
- **Calls:** start_walking, stop_walking, length, Vector3, get_viewport, normalized, get_camera_3d


## scripts/core/skeleton_ragdoll_hybrid.gd
**Category:** Core Systems
**Functions:** 14

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_joints, set_ragdoll_mode, _create_physics_bodies, _create_skeleton, print, _create_visuals

### `_create_skeleton()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, set_bone_pose_position, set_bone_parent, add_bone, Transform3D, has, set_bone_rest

### `_create_physics_bodies()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _get_bone_length, new, get_bone_global_pose, add_child, Vector3, set_meta, has, print

### `_get_bone_length()`
- **Lines:** 0
- **Parameters:** `bone_name: String`
- **Returns:** `float`

### `_create_joints()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_joint

### `_create_joint()`
- **Lines:** 0
- **Parameters:** `parent_bone: String, child_bone: String, joint_name: String, joint_type`
- **Returns:** `void`
- **Calls:** set_param, new, add_child, get_path, has, set_flag

### `_create_visuals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _get_bone_length, new, add_child, has, print

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _sync_skeleton_to_physics, _sync_physics_to_skeleton

### `_sync_skeleton_to_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_bone_pose_rotation, set_bone_pose_position, inverse, has, get_rotation_quaternion

### `_sync_physics_to_skeleton()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has, get_bone_global_pose

### `set_ragdoll_mode()`
- **Lines:** 0
- **Parameters:** `mode: RagdollMode`
- **Returns:** `void`
- **Calls:** values, emit

### `apply_impulse_to_bone()`
- **Lines:** 0
- **Parameters:** `bone_name: String, impulse: Vector3`
- **Returns:** `void`
- **Calls:** emit, has, apply_central_impulse

### `get_bone_position()`
- **Lines:** 0
- **Parameters:** `bone_name: String`
- **Returns:** `Vector3`
- **Calls:** return, has, get_bone_global_pose

### `stand_up()`
- **Lines:** 5
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print


## scripts/core/standardized_objects.gd
**Category:** Core Systems
**Functions:** 16

### `create_object()`
- **Lines:** 0
- **Parameters:** `object_type: String, position: Vector3, properties: Dictionary = {}`
- **Returns:** `Node3D`
- **Calls:** _setup_skeleton_ragdoll, max, new, _add_visuals, _setup_ragdoll, _setup_sun, _apply_property, set_meta, _setup_fruit, _generate_unique_name, _setup_no_gravity, _add_collision, has, print, _setup_astral_being, add_to_group, get

### `_add_visuals()`
- **Lines:** 0
- **Parameters:** `obj: Node3D, def: Dictionary`
- **Returns:** `void`
- **Calls:** new, get, add_child

### `_add_collision()`
- **Lines:** 0
- **Parameters:** `obj: Node3D, def: Dictionary`
- **Returns:** `void`
- **Calls:** new, get, add_child

### `_apply_property()`
- **Lines:** 0
- **Parameters:** `obj: Node3D, property: String, value`
- **Returns:** `void`
- **Calls:** _start_action, str, float, deg_to_rad

### `_setup_ragdoll()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `void`
- **Calls:** preload, set_script

### `_setup_skeleton_ragdoll()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `void`
- **Calls:** preload, add_to_group, set_script

### `_setup_sun()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `void`
- **Calls:** Vector3, new, Color, add_child

### `_setup_astral_being()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `void`
- **Calls:** set_script, load

### `_setup_fruit()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `void`
- **Calls:** set_meta

### `_setup_no_gravity()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `void`
- **Calls:** print

### `_start_action()`
- **Lines:** 0
- **Parameters:** `obj: Node3D, action: String`
- **Returns:** `void`
- **Calls:** get_meta, print

### `_generate_unique_name()`
- **Lines:** 0
- **Parameters:** `object_type: String`
- **Returns:** `String`
- **Calls:** get_main_loop, capitalize, str, find_child

### `_ready()`
- **Lines:** 5
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, _load_custom_assets, size, print

### `save_custom_assets()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, close, str, is_empty, store_string, print, size, stringify

### `_load_custom_assets()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_as_text, open, close, new, file_exists, parse, str, print, size

### `add_custom_asset()`
- **Lines:** 6
- **Parameters:** `asset_name: String, properties: Dictionary`
- **Returns:** `void`
- **Calls:** save_custom_assets, print


## scripts/core/synchronicity_pathfinder.gd
**Category:** Core Systems
**Functions:** 14

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _establish_mirrors, _map_all_paths, print

### `_map_all_paths()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size

### `synchronize()`
- **Lines:** 0
- **Parameters:** `var_name: String, new_value: Variant, source: String = ""`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, _update_mirror, emit_signal
- **Signals:** synchronicity_update

### `_update_mirror()`
- **Lines:** 0
- **Parameters:** `location: String, value: Variant`
- **Returns:** `void`
- **Calls:** set, _set_nested_property, call, get_node_or_null, has_method, trim_suffix, ends_with, size, split

### `follow_path()`
- **Lines:** 0
- **Parameters:** `from_function: String, to_function: String, data: Variant = null`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, emit_signal, push_warning
- **Signals:** path_taken

### `get_available_paths()`
- **Lines:** 0
- **Parameters:** `current_function: String`
- **Returns:** `Array`

### `trace_path_history()`
- **Lines:** 0
- **Parameters:** `steps_back: int = 10`
- **Returns:** `Array`
- **Calls:** slice, max, size

### `find_variable_locations()`
- **Lines:** 0
- **Parameters:** `var_name: String`
- **Returns:** `Array`

### `register_mirror()`
- **Lines:** 0
- **Parameters:** `var_name: String, location: String`
- **Returns:** `void`
- **Calls:** append, print

### `check_harmony()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** emit_signal, _get_mirror_value, push_warning
- **Signals:** harmony_achieved

### `_establish_mirrors()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** synchronize

### `_get_mirror_value()`
- **Lines:** 0
- **Parameters:** `location: String`
- **Returns:** `Variant`
- **Calls:** get, get_node_or_null, size, split

### `_set_nested_property()`
- **Lines:** 0
- **Parameters:** `obj: Object, path: String, value: Variant`
- **Returns:** `void`
- **Calls:** set, split, has, range, size, get

### `generate_path_report()`
- **Lines:** 24
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** str, has, trace_path_history


## scripts/core/talking_astral_being.gd
**Category:** Core Systems
**Functions:** 41

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_visual_components, randf, get_node_or_null, connect, _create_detection_area, has_signal, _apply_personality, set_physics_process, add_to_group

### `_create_visual_components()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child

### `_create_detection_area()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, new, add_child

### `_apply_personality()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Color, get

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_assisting, _update_connection_awareness, _process_assistance, _consider_speaking, _process_blinking, _process_hovering, _process_following, _process_free_flight, _process_orbiting, _update_energy, _process_creating

### `_process_free_flight()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** distance_to, get_ticks_msec, _find_closest_object, randf, start_orbiting, _calculate_pattern_position, lerp

### `_process_orbiting()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, is_instance_valid, Vector3, look_at, cos, lerp

### `_process_creating()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, is_instance_valid, _create_trail_light, Vector3, cos, append, float, range, size

### `_process_following()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** Vector3, is_instance_valid, lerp

### `_process_assisting()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** Vector3, _perform_assistance, lerp

### `_process_hovering()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** get_ticks_msec, Vector3, sin

### `_process_assistance()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _harmonize_environment, _organize_scene, _assist_creation, _assist_ragdoll, _assist_objects

### `_assist_ragdoll()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** get, Vector3, has_method, apply_central_impulse, get_body

### `_assist_objects()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** Vector3, randf, length, has_method, get_linear_velocity, apply_central_impulse

### `_organize_scene()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`

### `_harmonize_environment()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`

### `_assist_creation()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** randf

### `_calculate_pattern_position()`
- **Lines:** 0
- **Parameters:** `time: float`
- **Returns:** `Vector3`
- **Calls:** sin, fmod, Vector3, randf, cos, lerp, int

### `_process_blinking()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** randf_range

### `_update_connection_awareness()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size

### `_update_energy()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** max, min

### `_consider_speaking()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** randf, randi, size, speak

### `_create_trail_light()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node3D`
- **Calls:** new, add_child

### `_find_closest_object()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node3D`
- **Calls:** distance_to

### `_perform_assistance()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** has_method, receive_assistance

### `set_personality()`
- **Lines:** 0
- **Parameters:** `new_personality: Personality`
- **Returns:** `void`
- **Calls:** _apply_personality

### `start_orbiting()`
- **Lines:** 0
- **Parameters:** `target: Node3D`
- **Returns:** `void`
- **Calls:** speak

### `start_following()`
- **Lines:** 0
- **Parameters:** `target: Node3D`
- **Returns:** `void`
- **Calls:** speak

### `start_assisting()`
- **Lines:** 0
- **Parameters:** `target: Node3D, mode: AssistanceMode`
- **Returns:** `void`
- **Calls:** speak

### `speak()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** emit, append, pop_front, size

### `request_help_with()`
- **Lines:** 0
- **Parameters:** `object: Node3D, help_type: String`
- **Returns:** `void`
- **Calls:** emit, start_assisting

### `_on_body_entered()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** is_in_group, append, emit, has_method

### `_on_body_exited()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** erase

### `_on_player_needs_help()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** start_assisting, get

### `handle_console_command()`
- **Lines:** 0
- **Parameters:** `command: String, args: Array`
- **Returns:** `String`
- **Calls:** float, set_hover_center, Vector3, str, get_first_node_in_group, speak, clamp, set_orbit_target, set_assistance_mode, join, to_upper, get_being_status, set_movement_mode, get_tree, set_follow_target, size

### `get_being_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** str, size

### `set_follow_target()`
- **Lines:** 0
- **Parameters:** `target: Node3D`
- **Returns:** `void`

### `set_orbit_target()`
- **Lines:** 0
- **Parameters:** `target: Node3D`
- **Returns:** `void`

### `set_hover_center()`
- **Lines:** 0
- **Parameters:** `center_position: Vector3`
- **Returns:** `void`

### `set_movement_mode()`
- **Lines:** 0
- **Parameters:** `mode: MovementMode`
- **Returns:** `void`

### `set_assistance_mode()`
- **Lines:** 3
- **Parameters:** `mode: AssistanceMode`
- **Returns:** `void`


## scripts/core/the_universal_thing.gd
**Category:** Core Systems
**Functions:** 24

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_thing, _initialize_as_point, get_node, str, has_node, get_instance_id

### `_initialize_as_point()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, new, add_child

### `become()`
- **Lines:** 0
- **Parameters:** `what: Variant, properties: Dictionary = {}`
- **Returns:** `void`
- **Calls:** _cleanup_current_form, _become_word, _become_like, _become_shape, _become_anything, _become_container, _become_creator, to_lower, _become_ragdoll, _become_data, emit_signal, _become_point_form, _become_connector
- **Signals:** became_something

### `_become_point_form()`
- **Lines:** 0
- **Parameters:** `props: Dictionary`
- **Returns:** `void`
- **Calls:** emit_signal, get
- **Signals:** state_changed

### `_become_shape()`
- **Lines:** 0
- **Parameters:** `props: Dictionary`
- **Returns:** `void`
- **Calls:** new, add_child, has, emit_signal, get
- **Signals:** became_something

### `_become_ragdoll()`
- **Lines:** 0
- **Parameters:** `props: Dictionary`
- **Returns:** `void`
- **Calls:** new, add_child, load, instantiate, exists, reparent, emit_signal, get
- **Signals:** became_something

### `_become_word()`
- **Lines:** 0
- **Parameters:** `props: Dictionary`
- **Returns:** `void`
- **Calls:** new, add_child, randf, Color, emit_signal, get
- **Signals:** became_something

### `_become_connector()`
- **Lines:** 0
- **Parameters:** `props: Dictionary`
- **Returns:** `void`
- **Calls:** emit_signal, get, connect_to_thing
- **Signals:** became_something

### `_become_container()`
- **Lines:** 0
- **Parameters:** `props: Dictionary`
- **Returns:** `void`
- **Calls:** emit_signal, get
- **Signals:** became_something

### `_become_creator()`
- **Lines:** 0
- **Parameters:** `props: Dictionary`
- **Returns:** `void`
- **Calls:** emit_signal, max, get
- **Signals:** became_something

### `_become_data()`
- **Lines:** 0
- **Parameters:** `props: Dictionary`
- **Returns:** `void`
- **Calls:** merge, emit_signal, get
- **Signals:** became_something

### `_become_anything()`
- **Lines:** 0
- **Parameters:** `props: Dictionary`
- **Returns:** `void`
- **Calls:** set_meta, emit_signal
- **Signals:** became_something

### `_become_like()`
- **Lines:** 0
- **Parameters:** `other`
- **Returns:** `void`
- **Calls:** emit_signal, duplicate
- **Signals:** became_something

### `_cleanup_current_form()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, get_parent

### `connect_to_thing()`
- **Lines:** 0
- **Parameters:** `other: UniversalThing`
- **Returns:** `void`
- **Calls:** append, emit_signal
- **Signals:** connected_to

### `_on_thing_nearby()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** has_method, connect_to_thing

### `_on_awareness_overlap()`
- **Lines:** 0
- **Parameters:** `area: Area3D`
- **Returns:** `void`
- **Calls:** emit_signal, max, has_method, get_parent
- **Signals:** consciousness_changed

### `create_thing()`
- **Lines:** 0
- **Parameters:** `at_position: Vector3 = Vector3.ZERO`
- **Returns:** `UniversalThing`
- **Calls:** new, get_parent, add_child, connect_to_thing, push_warning, append

### `contain_thing()`
- **Lines:** 0
- **Parameters:** `thing: UniversalThing`
- **Returns:** `bool`
- **Calls:** append, reparent, size, get

### `evolve()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** become, emit_signal
- **Signals:** consciousness_changed

### `sync_data()`
- **Lines:** 0
- **Parameters:** `key: String, value: Variant`
- **Returns:** `void`
- **Calls:** is_instance_valid, emit_signal
- **Signals:** data_synchronized

### `get_possible_becomings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`

### `serialize()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** map

### `deserialize()`
- **Lines:** 8
- **Parameters:** `save_data: Dictionary`
- **Returns:** `void`
- **Calls:** become, get


## scripts/core/triangular_bird_walker.gd
**Category:** Core Systems
**Functions:** 21

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_visual_meshes, _set_idle_position, _create_sensors, _create_bird_physics

### `_create_bird_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_body_part, Vector3, _create_joints

### `_create_body_part()`
- **Lines:** 0
- **Parameters:** `part_name: String, offset: Vector3, part_mass: float`
- **Returns:** `RigidBody3D`
- **Calls:** new, add_child

### `_create_joints()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _connect_bodies

### `_connect_bodies()`
- **Lines:** 0
- **Parameters:** `body_a: RigidBody3D, body_b: RigidBody3D`
- **Returns:** `void`
- **Calls:** get_path, new, add_child

### `_create_visual_meshes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, Color, add_child

### `_create_sensors()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, new, add_child

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_flying, _update_triangle_meshes, _process_idle, _process_drinking, _maintain_balance, _process_eating, _process_walking

### `_process_idle()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** randf_range, Vector3, randf, size

### `_process_walking()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, max, distance_to, Vector3, normalized, apply_central_force

### `_process_flying()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** get_ticks_msec, apply_central_force, Vector3, sin

### `_process_eating()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, apply_central_force, Vector3, get_ticks_msec

### `_process_drinking()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, apply_central_force, Vector3, get_ticks_msec

### `_maintain_balance()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3

### `_update_triangle_meshes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_mesh, PackedVector3Array

### `_update_mesh()`
- **Lines:** 0
- **Parameters:** `mesh_instance: MeshInstance3D, vertices: PackedVector3Array`
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, new, resize, clear_surfaces, PackedVector3Array, normalized, cross

### `_on_food_detected()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** is_in_group, append

### `_on_food_lost()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** erase

### `_set_idle_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3

### `start_flying()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, apply_central_impulse

### `land()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `void`


## scripts/core/txt_rule_editor.gd
**Category:** Core Systems
**Functions:** 8

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_ui, _load_file_list

### `_create_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, set_anchors_and_offsets_preset, add_child, add_spacer, connect, add_keyword_color, set_custom_minimum_size, add_color_region

### `_load_file_list()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, _scan_directory

### `_scan_directory()`
- **Lines:** 0
- **Parameters:** `path: String, category: String`
- **Returns:** `void`
- **Calls:** open, get_next, add_item, ends_with, list_dir_begin

### `_on_file_selected()`
- **Lines:** 0
- **Parameters:** `index: int`
- **Returns:** `void`
- **Calls:** get_as_text, open, close, get_node, get_item_text, is_empty, get

### `_on_text_changed()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_save_current_file()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, close, _notify_rule_change, is_empty, store_string, print

### `_notify_rule_change()`
- **Lines:** 16
- **Parameters:** `file_path: String`
- **Returns:** `void`
- **Calls:** contains, get_file, get_node_or_null, has_method, reload_file, reload_definitions


## scripts/core/unified_being_system.gd
**Category:** Core Systems
**Functions:** 16

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _migrate_existing_beings, _register_commands, print

### `_register_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null

### `create_being()`
- **Lines:** 0
- **Parameters:** `type: String = "basic", position: Vector3 = Vector3.ZERO, properties: Dictionary = {}`
- **Returns:** `Node3D`
- **Calls:** _add_capabilities, new, _create_visual_for_type, load, add_child, set_script, get_child_count, duplicate, get_instance_id, emit, print, become, has, get_child, append, get_tree, add_to_group, size

### `_create_visual_for_type()`
- **Lines:** 0
- **Parameters:** `type: String`
- **Returns:** `Node3D`
- **Calls:** new, add_child, get_node_or_null, has_method, Color, create_object

### `_add_capabilities()`
- **Lines:** 0
- **Parameters:** `being: Node3D, type: String`
- **Returns:** `void`
- **Calls:** set_meta

### `transform_being()`
- **Lines:** 0
- **Parameters:** `being: Node3D, new_type: String`
- **Returns:** `bool`
- **Calls:** get_children, _add_capabilities, _create_visual_for_type, push_error, queue_free, add_child, get_instance_id, emit, erase, print, append

### `_migrate_existing_beings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_instance_id, print, append, get_tree, get_nodes_in_group

### `_cmd_being()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** _create_interface_being, create_being, _create_container_being, Vector3, is_empty, get_child_count, to_float, print, slice, size

### `_create_interface_being()`
- **Lines:** 0
- **Parameters:** `interface_type: String, pos_args: Array`
- **Returns:** `String`
- **Calls:** new, load, add_child, Vector3, set_script, get_child_count, duplicate, get_instance_id, to_float, emit, print, has, get_child, append, get_tree, size, become_interface

### `_cmd_list_beings()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** is_empty, size

### `_cmd_transform_being()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get_tree, transform_being, size, get_nodes_in_group

### `_cmd_container()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** _create_container_being, Vector3, is_empty, to_float, size

### `_create_container_being()`
- **Lines:** 0
- **Parameters:** `container_type: String, size: Vector3, pos: Vector3`
- **Returns:** `String`
- **Calls:** become_container, new, load, add_child, container, set_script, get_child_count, duplicate, get_instance_id, emit, print, has, get_child, append, get_tree, size

### `_cmd_list_containers()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get_container_info, s, is_empty, get_container, size, get

### `_cmd_connect_containers()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get_available_connection_points, connect_to_container, is_empty, _find_container_by_name, size

### `_find_container_by_name()`
- **Lines:** 7
- **Parameters:** `container_name: String`
- **Returns:** `UniversalBeingSceneContainer`
- **Calls:** get_container, contains, get


## scripts/core/unified_creation_system.gd
**Category:** Core Systems
**Functions:** 13

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, print

### `create()`
- **Lines:** 0
- **Parameters:** `what: String, where: Vector3 = Vector3.ZERO, properties: Dictionary = {}`
- **Returns:** `Node3D`
- **Calls:** _create_universal_being, _create_from_scene, _apply_properties, _route_through_floodgate, get_ticks_msec, push_error, emit, has, _is_universal_being_type, print, ends_with, append, _create_standard_object, get, _register_object

### `_is_universal_being_type()`
- **Lines:** 0
- **Parameters:** `type: String`
- **Returns:** `bool`
- **Calls:** file_exists

### `_create_universal_being()`
- **Lines:** 0
- **Parameters:** `type: String, position: Vector3, properties: Dictionary`
- **Returns:** `Node3D`
- **Calls:** load_universal_being, _generate_unique_name

### `_create_standard_object()`
- **Lines:** 0
- **Parameters:** `type: String, position: Vector3, properties: Dictionary`
- **Returns:** `Node3D`
- **Calls:** _generate_unique_name, create_object

### `_create_from_scene()`
- **Lines:** 0
- **Parameters:** `scene_path: String, position: Vector3, properties: Dictionary`
- **Returns:** `Node3D`
- **Calls:** get_file, load, instantiate, _generate_unique_name, get_basename

### `_register_object()`
- **Lines:** 0
- **Parameters:** `obj: Node3D, type: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, str, set_meta, randi, add_to_group, get

### `_apply_properties()`
- **Lines:** 0
- **Parameters:** `obj: Node3D, properties: Dictionary`
- **Returns:** `void`
- **Calls:** set, call, set_meta, has_method

### `_route_through_floodgate()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `void`
- **Calls:** second_dimensional_magic, get_tree, add_child

### `_generate_unique_name()`
- **Lines:** 0
- **Parameters:** `base_type: String`
- **Returns:** `String`
- **Calls:** capitalize, str, get

### `destroy()`
- **Lines:** 0
- **Parameters:** `obj: Node3D`
- **Returns:** `void`
- **Calls:** max, is_instance_valid, queue_free, get_meta, emit, erase, get

### `get_all_of_type()`
- **Lines:** 0
- **Parameters:** `type: String`
- **Returns:** `Array`
- **Calls:** append, get_meta, is_instance_valid

### `get_statistics()`
- **Lines:** 8
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** values, filter, size


## scripts/core/unified_scene_manager.gd
**Category:** Core Systems
**Functions:** 16

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, _create_containers, _find_original_ground, add_child, get_tree

### `_create_containers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child

### `_find_original_ground()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** contains, get_children, get_node_or_null, to_lower, get_tree

### `clear_current_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_instance_valid, get_children, queue_free, _ensure_ground_visible, emit, print

### `load_static_scene()`
- **Lines:** 0
- **Parameters:** `scene_name: String`
- **Returns:** `void`
- **Calls:** get_node, _ensure_ground_visible, clear_current_scene, has_method, load_scene, emit, print

### `generate_procedural_world()`
- **Lines:** 0
- **Parameters:** `size: int = 128`
- **Returns:** `void`
- **Calls:** new, get_parent, load, add_child, clear_current_scene, get_node_or_null, set_script, emit, print, remove_child, get_tree, generate_world

### `load_hybrid_scene()`
- **Lines:** 0
- **Parameters:** `scene_name: String, with_procedural: bool = true`
- **Returns:** `void`
- **Calls:** clear_current_scene, load_static_scene, print

### `restore_default_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, clear_current_scene, print

### `add_object_to_scene()`
- **Lines:** 0
- **Parameters:** `object: Node3D, category: String = "object"`
- **Returns:** `void`
- **Calls:** add_child

### `get_spawn_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`
- **Calls:** get_height_at_position, has_method

### `get_ground_height_at()`
- **Lines:** 0
- **Parameters:** `position: Vector3`
- **Returns:** `float`
- **Calls:** get_height_at_position, has_method

### `get_current_scene_info()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_child_count, keys

### `is_procedural_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`

### `has_terrain()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** or

### `_ensure_ground_visible()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print, _create_emergency_ground, _find_original_ground

### `_create_emergency_ground()`
- **Lines:** 33
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, Color, print, get_tree


## scripts/core/universal_being.gd
**Category:** Core Systems
**Functions:** 22

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, str

### `become()`
- **Lines:** 0
- **Parameters:** `new_form: String`
- **Returns:** `void`
- **Calls:** manifest, print

### `manifest()`
- **Lines:** 0
- **Parameters:** `form_type: String`
- **Returns:** `void`
- **Calls:** get_class, manifest, get_parent, queue_free, add_child, get_node_or_null, has_method, get_child_count, _create_basic_manifestation, has, print, remove_child, create_object

### `_create_basic_manifestation()`
- **Lines:** 0
- **Parameters:** `form_type: String`
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, Color, print

### `set_property()`
- **Lines:** 0
- **Parameters:** `key: String, value: Variant`
- **Returns:** `void`

### `get_property()`
- **Lines:** 0
- **Parameters:** `key: String, default_value: Variant = null`
- **Returns:** `Variant`
- **Calls:** get

### `become_interface()`
- **Lines:** 0
- **Parameters:** `interface_type: String, properties: Dictionary = {}`
- **Returns:** `void`
- **Calls:** _create_console_interface, _create_asset_creator_interface, queue_free, _create_generic_interface, print, _create_grid_interface, _create_inspector_interface

### `become_container()`
- **Lines:** 0
- **Parameters:** `container_type: String, size: Vector3 = Vector3(10, 5, 10), properties: Dictionary = {}`
- **Returns:** `void`
- **Calls:** new, add_child, queue_free, load, set_property, print, get

### `get_container()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `UniversalBeingSceneContainer`
- **Calls:** get_property

### `connect_to()`
- **Lines:** 0
- **Parameters:** `other: UniversalBeing`
- **Returns:** `void`
- **Calls:** print, connection

### `freeze()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_process, being, print

### `unfreeze()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_process, being, print

### `_to_string()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** UniversalBeing

### `_create_asset_creator_interface()`
- **Lines:** 0
- **Parameters:** `properties: Dictionary`
- **Returns:** `void`
- **Calls:** new, add_child, load, create_3d_interface_from_eden_records, print, _create_basic_interface_fallback

### `_create_console_interface()`
- **Lines:** 0
- **Parameters:** `properties: Dictionary`
- **Returns:** `void`
- **Calls:** new, add_child, load, create_3d_interface_from_eden_records, print, _create_basic_interface_fallback

### `_create_grid_interface()`
- **Lines:** 0
- **Parameters:** `properties: Dictionary`
- **Returns:** `void`
- **Calls:** new, add_child, load, create_3d_interface_from_eden_records, print, _create_basic_interface_fallback

### `_create_inspector_interface()`
- **Lines:** 0
- **Parameters:** `properties: Dictionary`
- **Returns:** `void`
- **Calls:** new, add_child, load, create_3d_interface_from_eden_records, print, _create_basic_interface_fallback

### `_create_generic_interface()`
- **Lines:** 0
- **Parameters:** `interface_type: String, properties: Dictionary`
- **Returns:** `void`
- **Calls:** new, add_child, load, create_3d_interface_from_eden_records, print, _create_basic_interface_fallback

### `_create_basic_interface_fallback()`
- **Lines:** 0
- **Parameters:** `interface_type: String`
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, Color, print

### `_on_interface_clicked()`
- **Lines:** 0
- **Parameters:** `camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int, panel: Control`
- **Returns:** `void`
- **Calls:** print

### `_on_interface_hover_start()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, has_node, Color

### `_on_interface_hover_end()`
- **Lines:** 6
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, has_node


## scripts/core/universal_being_3d_blueprint_parser.gd
**Category:** Core Systems
**Functions:** 11

### `parse_blueprint_file()`
- **Lines:** 0
- **Parameters:** `file_path: String`
- **Returns:** `Dictionary`
- **Calls:** eof_reached, open, close, file_exists, _parse_element_line, is_empty, get_line, print, begins_with, append, clear, strip_edges, size

### `_parse_element_line()`
- **Lines:** 0
- **Parameters:** `line: String, line_number: int`
- **Returns:** `Dictionary`
- **Calls:** Vector2, _parse_properties, Vector3, to_float, print, strip_edges, size, split

### `_parse_properties()`
- **Lines:** 0
- **Parameters:** `properties_string: String`
- **Returns:** `Dictionary`
- **Calls:** _convert_property_value, is_empty, strip_edges, size, split

### `_convert_property_value()`
- **Lines:** 0
- **Parameters:** `value_str: String`
- **Returns:** `Variant`
- **Calls:** is_valid_int, is_valid_float, to_int, to_lower, to_float

### `get_elements_by_type()`
- **Lines:** 0
- **Parameters:** `element_type: String`
- **Returns:** `Array`
- **Calls:** append

### `get_element_by_text()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `Dictionary`

### `create_default_blueprint()`
- **Lines:** 0
- **Parameters:** `interface_type: String`
- **Returns:** `Dictionary`
- **Calls:** _create_generic_blueprint, _create_default_console, _create_default_asset_creator, _create_default_inspector

### `_create_default_asset_creator()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** Vector3, Vector2

### `_create_default_console()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** Vector3, Vector2

### `_create_default_inspector()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** Vector3, Vector2

### `_create_generic_blueprint()`
- **Lines:** 36
- **Parameters:** `interface_type: String`
- **Returns:** `Dictionary`
- **Calls:** capitalize, Vector3, Vector2


## scripts/core/universal_being_floodgate_integration.gd
**Category:** Core Systems
**Functions:** 5

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_references

### `_setup_references()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, print

### `create_universal_being_through_floodgate()`
- **Lines:** 0
- **Parameters:** `type: String, position: Vector3, properties: Dictionary = {}`
- **Returns:** `void`
- **Calls:** queue_operation, has_method, has_asset, _create_being_directly, print

### `_on_being_created()`
- **Lines:** 0
- **Parameters:** `result: Dictionary`
- **Returns:** `void`
- **Calls:** has, get, print

### `_create_being_directly()`
- **Lines:** 35
- **Parameters:** `type: String, position: Vector3, properties: Dictionary`
- **Returns:** `void`
- **Calls:** create_being, new, get_parent, load, get_ticks_msec, add_child, str, has_method, set_script, get_child_count, print, get_child, remove_child, get_tree, create_object


## scripts/core/universal_being_layer_system.gd
**Category:** Core Systems
**Functions:** 22

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_interface_materials, add_to_group, _register_commands, print

### `_register_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null

### `add_to_layer()`
- **Lines:** 0
- **Parameters:** `node: Node3D, layer: LayerType`
- **Returns:** `void`
- **Calls:** keys, _apply_world_layer, _apply_overlay_layer, _apply_interface_layer, print, append, remove_from_all_layers

### `remove_from_all_layers()`
- **Lines:** 0
- **Parameters:** `node: Node3D`
- **Returns:** `void`
- **Calls:** erase

### `_apply_world_layer()`
- **Lines:** 0
- **Parameters:** `node: Node3D`
- **Returns:** `void`
- **Calls:** _reset_node_rendering

### `_apply_interface_layer()`
- **Lines:** 0
- **Parameters:** `node: Node3D`
- **Returns:** `void`
- **Calls:** _make_always_visible, _apply_interface_materials_to_node

### `_apply_overlay_layer()`
- **Lines:** 0
- **Parameters:** `node: Node3D`
- **Returns:** `void`
- **Calls:** _make_always_visible, _apply_overlay_materials_to_node

### `_make_always_visible()`
- **Lines:** 0
- **Parameters:** `node: Node3D`
- **Returns:** `void`
- **Calls:** _apply_always_visible_recursive

### `_apply_always_visible_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** _apply_always_visible_recursive, get_children, get_layer_mask, _get_always_visible_material, set_layer_mask, set_meta, has_meta

### `_get_always_visible_material()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `StandardMaterial3D`
- **Calls:** new, Color

### `_setup_interface_materials()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_apply_interface_materials_to_node()`
- **Lines:** 0
- **Parameters:** `node: Node3D`
- **Returns:** `void`
- **Calls:** _make_always_visible, set_meta

### `_apply_overlay_materials_to_node()`
- **Lines:** 0
- **Parameters:** `node: Node3D`
- **Returns:** `void`
- **Calls:** _make_always_visible, set_meta

### `_reset_node_rendering()`
- **Lines:** 0
- **Parameters:** `node: Node3D`
- **Returns:** `void`
- **Calls:** _reset_rendering_recursive

### `_reset_rendering_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** remove_meta, get_children, set_layer_mask, get_meta, _reset_rendering_recursive, has_meta

### `auto_assign_gizmo_to_interface_layer()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, add_to_layer, get_nodes_in_group, print

### `auto_assign_interface_beings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, add_to_layer, get_nodes_in_group

### `cmd_layer_add()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** _find_object_by_name, add_to_layer, size, to_lower

### `cmd_layer_list()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** is_instance_valid, keys, str, Layer, values, size

### `cmd_layer_gizmo()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** auto_assign_interface_beings, auto_assign_gizmo_to_interface_layer, layer

### `cmd_layer_show()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** is_instance_valid, str, is_empty, to_lower, capitalize, size

### `_find_object_by_name()`
- **Lines:** 21
- **Parameters:** `object_name: String`
- **Returns:** `Node3D`
- **Calls:** get_tree, get_nodes_in_group


## scripts/core/universal_being_scene_container.gd
**Category:** Core Systems
**Functions:** 23

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_interaction_area, _initialize_spatial_points, _create_visual_elements

### `_initialize_spatial_points()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, size, print

### `_create_visual_elements()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_connection_point_visualization, _create_boundary_visualization, new, add_child

### `_create_boundary_visualization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, str, _create_point_marker, Color, size

### `_create_connection_point_visualization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, _get_face_normal, add_child, _create_connection_point_visualizer, append, size

### `_create_point_marker()`
- **Lines:** 0
- **Parameters:** `position: Vector3, color: Color, size: float, marker_name: String`
- **Returns:** `Node3D`
- **Calls:** new, add_child

### `_create_connection_point_visualizer()`
- **Lines:** 0
- **Parameters:** `connection_data: Dictionary, index: int`
- **Returns:** `Node3D`
- **Calls:** new, bind, add_child, str, Vector3, connect, capitalize

### `_get_face_normal()`
- **Lines:** 0
- **Parameters:** `side_index: int`
- **Returns:** `Vector3`
- **Calls:** Vector3

### `_setup_interaction_area()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, new, add_child

### `add_being_to_container()`
- **Lines:** 0
- **Parameters:** `being: UniversalBeing, target_position: Vector3 = Vector3.ZERO`
- **Returns:** `bool`
- **Calls:** _is_position_within_bounds, set_meta, reparent, emit_signal, print, append
- **Signals:** being_added_to_container

### `remove_being_from_container()`
- **Lines:** 0
- **Parameters:** `being: UniversalBeing`
- **Returns:** `bool`
- **Calls:** remove_meta, find, emit_signal, print, remove_at
- **Signals:** being_removed_from_container

### `get_snap_position()`
- **Lines:** 0
- **Parameters:** `world_position: Vector3`
- **Returns:** `Vector3`
- **Calls:** position, distance_to, to_local

### `_is_position_within_bounds()`
- **Lines:** 0
- **Parameters:** `position: Vector3`
- **Returns:** `bool`
- **Calls:** return, abs

### `create_connection_point()`
- **Lines:** 0
- **Parameters:** `position: Vector3, connection_type: String, properties: Dictionary = {}`
- **Returns:** `Dictionary`
- **Calls:** Vector2, add_child, _create_connection_point_visualizer, emit_signal, print, append, size, get
- **Signals:** connection_point_created

### `connect_to_container()`
- **Lines:** 0
- **Parameters:** `other_container: UniversalBeingSceneContainer, my_connection_id: int, other_connection_id: int`
- **Returns:** `bool`
- **Calls:** emit_signal, print, append, size, get_unix_time_from_system
- **Signals:** containers_connected

### `_on_being_entered_container()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** print

### `_on_being_exited_container()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** print

### `_on_connection_point_clicked()`
- **Lines:** 0
- **Parameters:** `connection_data: Dictionary, index: int, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int`
- **Returns:** `void`
- **Calls:** print

### `get_available_connection_points()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** append

### `get_beings_near_position()`
- **Lines:** 0
- **Parameters:** `target_position: Vector3, radius: float = 2.0`
- **Returns:** `Array[UniversalBeing]`
- **Calls:** append, distance_to

### `set_container_size()`
- **Lines:** 0
- **Parameters:** `new_size: Vector3`
- **Returns:** `void`
- **Calls:** queue_free, _initialize_spatial_points, _create_visual_elements

### `get_container_info()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** size, get_available_connection_points

### `handle_console_command()`
- **Lines:** 42
- **Parameters:** `command: String, args: Array`
- **Returns:** `String`
- **Calls:** contains, str, get_container_info, Vector3, create_connection_point, get_snap_position, to_float, set_container_size, append, size


## scripts/core/universal_being_visualizer.gd
**Category:** Core Systems
**Functions:** 25

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_transformation_system, _create_star_visualization, get_ticks_msec, _register_with_systems, str, _print, _generate_uuid, _create_interaction_area

### `_generate_uuid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_ticks_msec, str, randi

### `_create_star_visualization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, set_loops, _print, tween_property, Color, _create_star_texture, get_tree, create_tween

### `_create_star_texture()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `ImageTexture`
- **Calls:** create, Vector2, new, set_pixel, length, Vector2i, Color, set_image, range, fill

### `_create_interaction_area()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** created, new, add_child, connect, _print

### `_setup_transformation_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, new, Color, connect

### `_register_with_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_meta, get_node_or_null, get_first_node_in_group, has_method, _print, second_dimensional_magic, get_tree, make_object_inspectable, add_to_group

### `_on_input_event()`
- **Lines:** 0
- **Parameters:** `camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int`
- **Returns:** `void`
- **Calls:** _on_clicked

### `_on_clicked()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _print_to_console, _create_click_effect, keys, str, get_node_or_null, has_method, _print, emit, Being, size

### `_create_click_effect()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, Vector3, create_tween, tween_property

### `_on_body_entered()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** str, _print, emit, append, size, _analyze_transformation_possibilities

### `_on_body_exited()`
- **Lines:** 0
- **Parameters:** `body: Node3D`
- **Returns:** `void`
- **Calls:** str, _print, emit, erase, size

### `_on_area_entered()`
- **Lines:** 0
- **Parameters:** `area: Area3D`
- **Returns:** `void`
- **Calls:** is_in_group, append, _print, get_parent

### `_on_area_exited()`
- **Lines:** 0
- **Parameters:** `area: Area3D`
- **Returns:** `void`
- **Calls:** erase, _print, get_parent

### `transform_into()`
- **Lines:** 0
- **Parameters:** `new_form: String, properties: Dictionary = {}`
- **Returns:** `void`
- **Calls:** emit, _start_transformation_visual, start, _print

### `_start_transformation_visual()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, tween_property, Color, get_tree, create_tween

### `_complete_transformation()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_new_manifestation, _print, emit, Color, get

### `_create_new_manifestation()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, queue_free, Vector3, _print, create_object

### `_analyze_transformation_possibilities()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, get_meta, _print, append, size

### `get_full_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** size

### `_print()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** print

### `register_console_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_command, get_node_or_null, has_method

### `_cmd_transform()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** transform_into, size

### `_cmd_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** str, size

### `_cmd_nearby()`
- **Lines:** 9
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get_meta, size


## scripts/core/universal_data_hub.gd
**Category:** Core Systems
**Functions:** 21

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_process, print

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`

### `register_system()`
- **Lines:** 0
- **Parameters:** `system_name: String, system: Node`
- **Returns:** `bool`
- **Calls:** emit, print, push_warning

### `get_system()`
- **Lines:** 0
- **Parameters:** `system_name: String`
- **Returns:** `Node`
- **Calls:** get

### `register_object()`
- **Lines:** 0
- **Parameters:** `obj: Node, type: String = "generic"`
- **Returns:** `String`
- **Calls:** set_meta, has_method, emit, _generate_uuid, append

### `get_object()`
- **Lines:** 0
- **Parameters:** `uuid: String`
- **Returns:** `Node`
- **Calls:** get

### `get_objects_by_type()`
- **Lines:** 0
- **Parameters:** `type: String`
- **Returns:** `Array`
- **Calls:** append, is_instance_valid, get

### `unregister_object()`
- **Lines:** 0
- **Parameters:** `uuid: String`
- **Returns:** `void`
- **Calls:** erase, get_meta

### `get_all_beings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** append, is_instance_valid

### `get_beings_by_form()`
- **Lines:** 0
- **Parameters:** `form: String`
- **Returns:** `Array`
- **Calls:** append, get_all_beings, get

### `register_rule()`
- **Lines:** 0
- **Parameters:** `rule_name: String, callable: Callable`
- **Returns:** `void`
- **Calls:** print

### `execute_rule()`
- **Lines:** 0
- **Parameters:** `rule_name: String, params: Array = []`
- **Returns:** `Variant`
- **Calls:** callv, push_error

### `set_global()`
- **Lines:** 0
- **Parameters:** `var_name: String, value: Variant`
- **Returns:** `void`

### `get_global()`
- **Lines:** 0
- **Parameters:** `var_name: String, default: Variant = null`
- **Returns:** `Variant`
- **Calls:** get

### `check_limits()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_frames_per_second, _estimate_memory

### `cleanup_invalid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `int`
- **Calls:** is_instance_valid, get_ticks_msec, erase, unregister_object, append

### `_generate_uuid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** str, randi, get_unix_time_from_system

### `_estimate_memory()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `float`

### `get_stats()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** size, _estimate_memory

### `find_nearest_object()`
- **Lines:** 0
- **Parameters:** `pos: Vector3, type: String = ""`
- **Returns:** `Node`
- **Calls:** is_instance_valid, distance_to, values, has_method, get_objects_by_type

### `broadcast_to_systems()`
- **Lines:** 6
- **Parameters:** `message: String, data: Dictionary = {}`
- **Returns:** `void`
- **Calls:** is_instance_valid, has_method, receive_broadcast


## scripts/core/universal_entity/global_variable_inspector.gd
**Category:** Core Systems
**Functions:** 21

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** scan_all_variables, get_node_or_null, _print

### `scan_all_variables()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _scan_engine_settings, _scan_scene_variables, _scan_autoloads, _scan_project_settings

### `_scan_autoloads()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, get_property_list, _scan_node_properties, trim_prefix, begins_with, clear

### `_scan_project_settings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** begins_with, clear, get_property_list, get_setting

### `_scan_engine_settings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_frames_per_second

### `_scan_scene_variables()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, get_tree, _scan_node_recursive

### `_scan_node_properties()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `Dictionary`
- **Calls:** get, get_property_list

### `_scan_node_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node, max_depth: int = 3, current_depth: int = 0`
- **Returns:** `Dictionary`
- **Calls:** get_class, get_children, _scan_node_recursive, _scan_node_properties, get_path

### `get_variable()`
- **Lines:** 0
- **Parameters:** `path: String`
- **Returns:** `void`
- **Calls:** has, path, split

### `set_variable()`
- **Lines:** 0
- **Parameters:** `path: String, value`
- **Returns:** `bool`
- **Calls:** _set_autoload_variable, _set_project_setting, _set_engine_setting, split

### `_set_autoload_variable()`
- **Lines:** 0
- **Parameters:** `parts: Array, value`
- **Returns:** `bool`
- **Calls:** set, get_node_or_null, emit, join, slice, size, get

### `_set_project_setting()`
- **Lines:** 0
- **Parameters:** `parts: Array, value`
- **Returns:** `bool`
- **Calls:** set_setting, emit, join, get_setting, slice, size

### `_set_engine_setting()`
- **Lines:** 0
- **Parameters:** `parts: Array, value`
- **Returns:** `bool`
- **Calls:** emit, join, size

### `watch_variable()`
- **Lines:** 0
- **Parameters:** `path: String, callback: Callable`
- **Returns:** `void`
- **Calls:** append, has

### `unwatch_variable()`
- **Lines:** 0
- **Parameters:** `path: String, callback: Callable`
- **Returns:** `void`
- **Calls:** erase, has

### `export_to_txt()`
- **Lines:** 0
- **Parameters:** `filepath: String`
- **Returns:** `void`
- **Calls:** open, close, store_line, get_datetime_string_from_system, _write_variables_recursive, _print, to_upper

### `_write_variables_recursive()`
- **Lines:** 0
- **Parameters:** `file: FileAccess, data: Dictionary, indent: String`
- **Returns:** `void`
- **Calls:** store_line, str, _write_variables_recursive, has, begins_with

### `get_all_variables()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`

### `search_variables()`
- **Lines:** 0
- **Parameters:** `search_term: String`
- **Returns:** `Array`
- **Calls:** _search_recursive, to_lower

### `_search_recursive()`
- **Lines:** 0
- **Parameters:** `data: Dictionary, path: String, search: String, results: Array`
- **Returns:** `void`
- **Calls:** _search_recursive, contains, to_lower, has, append

### `_print()`
- **Lines:** 6
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** _print_to_console, has_method, print


## scripts/core/universal_entity/initialize_universal_entity.gd
**Category:** Core Systems
**Functions:** 1

### `_ready()`
- **Lines:** 40
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print


## scripts/core/universal_entity/lists_viewer_system.gd
**Category:** Core Systems
**Functions:** 26

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load_all_lists, get_node_or_null, _ensure_directories, connect, load_all_rules, _print, start, _create_example_files

### `_ensure_directories()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, dir_exists, make_dir

### `_create_example_files()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, close, store_line, file_exists

### `load_all_lists()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, get_next, ends_with, load_list, list_dir_begin

### `load_list()`
- **Lines:** 0
- **Parameters:** `filename: String`
- **Returns:** `Dictionary`
- **Calls:** eof_reached, open, _parse_list_line, close, get_modified_time, str, is_empty, _print, get_line, emit, trim_suffix, begins_with, append, strip_edges, size, split

### `_parse_list_line()`
- **Lines:** 0
- **Parameters:** `line: String`
- **Returns:** `Dictionary`
- **Calls:** Vector3, is_empty, to_float, range, size, split

### `load_all_rules()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, get_next, load_rules, ends_with, list_dir_begin

### `load_rules()`
- **Lines:** 0
- **Parameters:** `filename: String`
- **Returns:** `void`
- **Calls:** eof_reached, open, close, get_modified_time, str, is_empty, _print, get_line, begins_with, strip_edges, _parse_rule

### `_parse_rule()`
- **Lines:** 0
- **Parameters:** `line: String`
- **Returns:** `Dictionary`
- **Calls:** _parse_interval, replace, strip_edges, split, _parse_condition

### `_parse_condition()`
- **Lines:** 0
- **Parameters:** `condition_str: String`
- **Returns:** `Dictionary`
- **Calls:** to_int, to_float, replace, size, split

### `_parse_interval()`
- **Lines:** 0
- **Parameters:** `interval_str: String`
- **Returns:** `float`
- **Calls:** to_float, replace

### `check_and_execute_rules()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, _check_condition, _execute_action

### `_check_condition()`
- **Lines:** 0
- **Parameters:** `condition: Dictionary`
- **Returns:** `bool`
- **Calls:** get_static_memory_usage, size, get_node_count, _compare_values, _check_proximity, get_tree, get_frames_per_second

### `_compare_values()`
- **Lines:** 0
- **Parameters:** `value1, operator: String, value2`
- **Returns:** `bool`

### `_check_proximity()`
- **Lines:** 0
- **Parameters:** `target_type: String`
- **Returns:** `bool`
- **Calls:** get_tree, get_first_node_in_group, distance_to

### `_execute_action()`
- **Lines:** 0
- **Parameters:** `action: String, rule_id: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, get_node, has_node, get_first_node_in_group, force_cleanup, _print, force_health_check, split, _spawn_from_list, emit, _make_nearby_tree_talk, begins_with, append, get_tree, _save_game_state, unload_nodes_by_distance

### `_spawn_from_list()`
- **Lines:** 0
- **Parameters:** `list_filename: String`
- **Returns:** `void`
- **Calls:** trim_suffix, load_list, has, _spawn_object

### `_spawn_object()`
- **Lines:** 0
- **Parameters:** `item: Dictionary`
- **Returns:** `void`
- **Calls:** add_child, make_object_inspectable, get_node_or_null, get_first_node_in_group, _print, has_method, second_dimensional_magic, append, get_tree, create_object, get

### `_spawn_object_old_method()`
- **Lines:** 0
- **Parameters:** `item: Dictionary`
- **Returns:** `void`
- **Calls:** load_node_immediate, get_node, has_node, get_tree, get

### `_save_game_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, close, keys, get_datetime_string_from_system, _print, store_string, size, stringify

### `_make_nearby_tree_talk()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _print_to_console, distance_to, get_first_node_in_group, talk, get_tree, get_nodes_in_group

### `_check_file_changes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _reload_file, get_modified_time

### `_reload_file()`
- **Lines:** 0
- **Parameters:** `filepath: String`
- **Returns:** `void`
- **Calls:** _print, erase, replace, load_rules, begins_with, append, load_list

### `_print()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** _print_to_console, has_method, print

### `get_list()`
- **Lines:** 0
- **Parameters:** `list_name: String`
- **Returns:** `Dictionary`
- **Calls:** get

### `add_rule()`
- **Lines:** 9
- **Parameters:** `rule_text: String, rule_id: String = ""`
- **Returns:** `void`
- **Calls:** str, is_empty, size, emit, _parse_rule


## scripts/core/universal_entity/system_health_monitor.gd
**Category:** Core Systems
**Functions:** 13

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, get_node_or_null, connect, _print, start

### `_perform_health_check()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append_array, max, _status_to_string, get_ticks_msec, _apply_node_limit_fix, str, _check_floodgate_queues, size, _apply_memory_fix, get_node_count, _apply_fps_fix, _estimate_memory_usage, pop_front, emit, append, get_tree, get_frames_per_second

### `_estimate_memory_usage()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `float`
- **Calls:** get_node_count, get_tree, node

### `_check_floodgate_queues()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** append, str, size

### `_apply_fps_fix()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _emergency_optimization, queue_free, get_viewport, _print, emit, get_tree, get_nodes_in_group

### `_apply_node_limit_fix()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, force_cleanup, _print, emit, get_tree, get_nodes_in_group

### `_apply_memory_fix()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, force_cleanup, _print, emit, get_tree

### `get_health_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `HealthStatus`

### `get_health_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** is_empty, min, duplicate, range, size

### `set_auto_fix()`
- **Lines:** 0
- **Parameters:** `enabled: bool`
- **Returns:** `void`
- **Calls:** _print

### `force_health_check()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _perform_health_check

### `_status_to_string()`
- **Lines:** 0
- **Parameters:** `status: HealthStatus`
- **Returns:** `String`

### `_print()`
- **Lines:** 6
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** _print_to_console, has_method, print


## scripts/core/universal_entity/universal_entity.gd
**Category:** Core Systems
**Functions:** 20

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, _register_universal_commands, str, _print, _initialize_core_systems, get_tree, _realize_the_dream

### `_initialize_core_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, connect, _print, has_signal, get_tree

### `_register_universal_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, _print

### `_realize_the_dream()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _check_perfection, new, add_child, connect, _print, emit, start

### `_self_regulate()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** check_and_execute_rules, force_cleanup, get_health_report, _update_satisfaction

### `_check_perfection()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** get_health_status, _print, emit, values, size

### `_update_satisfaction()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_health_status, str, _print, values, get_frames_per_second, int

### `_cmd_universal_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, _print, int

### `_cmd_evolve()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** emit, is_empty, _print

### `_cmd_make_perfect()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** set_auto_fix, force_cleanup, _print, _check_perfection

### `_cmd_check_satisfaction()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _update_satisfaction, str, _print, int

### `_cmd_health_check()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _status_to_string, str, force_health_check, _print, get_health_report, size, int

### `_cmd_list_variables()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, search_variables, is_empty, _print, export_to_txt, size

### `_cmd_show_lists()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, size, _print

### `_cmd_optimize_now()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _apply_fps_fix, force_cleanup, _print

### `_cmd_export_variables()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** export_to_txt, size, _print

### `_on_system_warning()`
- **Lines:** 0
- **Parameters:** `severity: String, message: String`
- **Returns:** `void`
- **Calls:** _print

### `_on_performance_warning()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** _print

### `_on_rule_executed()`
- **Lines:** 0
- **Parameters:** `rule_name: String, result`
- **Returns:** `void`
- **Calls:** _print

### `_print()`
- **Lines:** 7
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, has_method, print


## scripts/core/universal_entity/universal_loader_unloader.gd
**Category:** Core Systems
**Functions:** 20

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, set_process, _print

### `load_node()`
- **Lines:** 0
- **Parameters:** `path: String, parent: Node = null, priority: int = 0`
- **Returns:** `void`
- **Calls:** append, sort_custom, get_ticks_msec, _optimize_memory, _print, _can_load_new_node, get_tree

### `load_node_immediate()`
- **Lines:** 0
- **Parameters:** `path: String, parent: Node = null`
- **Returns:** `Node`
- **Calls:** load, get_ticks_msec, add_child, has_method, _print, instantiate, emit, exists, second_dimensional_magic, get_tree, get

### `unload_node()`
- **Lines:** 0
- **Parameters:** `node: Node, priority: UnloadPriority = UnloadPriority.NORMAL`
- **Returns:** `void`
- **Calls:** is_in_group, append, is_instance_valid, set_meta

### `unload_nodes_by_distance()`
- **Lines:** 0
- **Parameters:** `center: Vector3, max_distance: float`
- **Returns:** `int`
- **Calls:** get_tree, unload_node, get_nodes_in_group, distance_to

### `unload_heavy_nodes()`
- **Lines:** 0
- **Parameters:** `memory_threshold_mb: float = 50`
- **Returns:** `void`
- **Calls:** sort_custom, has_method, _estimate_node_memory, append, get_tree, unload_node, get_nodes_in_group

### `freeze_node_scripts()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** is_instance_valid, get_children, freeze_node_scripts, set_meta, set_script, set_process_input, get_script, set_process_unhandled_input, set_physics_process, set_process

### `unfreeze_node_scripts()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** unfreeze_node_scripts, remove_meta, is_instance_valid, get_children, get_meta, set_script, set_physics_process, has_meta, set_process

### `_process()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _process_load_queue, _emergency_optimization, size, get_node_count, _process_unload_queue, pop_front, _get_average_fps, append, get_tree, get_frames_per_second

### `_process_load_queue()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** load_node_immediate, pop_front, is_empty

### `_process_unload_queue()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _perform_unload, pop_front, is_instance_valid, is_empty

### `_perform_unload()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** queue_free, str, emit, get_path, fifth_dimensional_magic

### `_can_load_new_node()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** return, _get_average_fps

### `_optimize_memory()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_meta, emit, erase, has_cached, get_tree, unload_node, get_nodes_in_group

### `_emergency_optimization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** distance_to, freeze_node_scripts, unload_heavy_nodes, get_viewport, _print, emit, get_tree, get_nodes_in_group, get_camera_3d

### `_get_average_fps()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `float`
- **Calls:** is_empty, size

### `_estimate_node_memory()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `int`
- **Calls:** mesh, get_child_count, texture

### `get_performance_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** _get_average_fps, size

### `force_cleanup()`
- **Lines:** 0
- **Parameters:** `aggressive: bool = false`
- **Returns:** `void`
- **Calls:** _optimize_memory, get_tree, is_in_group, clear, unload_node, get_nodes_in_group

### `_print()`
- **Lines:** 6
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** _print_to_console, has_method, print


## scripts/core/universal_gizmo_system.gd
**Category:** Core Systems
**Functions:** 36

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** call_deferred, _create_scale_gizmos, _create_rotation_gizmos, _create_translation_gizmos, print, _ready_commands, add_to_group

### `attach_to_object()`
- **Lines:** 0
- **Parameters:** `object: Node3D`
- **Returns:** `void`
- **Calls:** call_deferred, set_mode, is_empty, print, _update_gizmo_position, size, detach

### `detach()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_unhandled_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** create, project_ray_normal, get_world_3d, _end_drag, _is_gizmo_component, get_viewport, intersect_ray, project_ray_origin, set_input_as_handled, _handle_gizmo_click, _update_drag, get_camera_3d

### `_create_translation_gizmos()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_gizmo_interaction, add_child, _setup_arrow_visual, _create_gizmo_being, get_node_or_null, set_property, print, _setup_plane_visual

### `_create_rotation_gizmos()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_gizmo_interaction, add_child, _create_gizmo_being, _setup_ring_visual, set_property

### `_create_scale_gizmos()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_uniform_scale_visual, _setup_gizmo_interaction, add_child, _create_gizmo_being, set_property, _setup_scale_visual

### `_create_gizmo_being()`
- **Lines:** 0
- **Parameters:** `being_name: String`
- **Returns:** `Node3D`
- **Calls:** set_script, set_property, new, load

### `_setup_arrow_visual()`
- **Lines:** 0
- **Parameters:** `arrow_being: Node3D, axis: String`
- **Returns:** `void`
- **Calls:** set_property, new, add_child

### `_setup_plane_visual()`
- **Lines:** 0
- **Parameters:** `plane_being: Node3D, plane: String`
- **Returns:** `void`
- **Calls:** Vector3, Vector2, new, add_child

### `_setup_ring_visual()`
- **Lines:** 0
- **Parameters:** `ring_being: Node3D, axis: String`
- **Returns:** `void`
- **Calls:** set_property, new, add_child

### `_setup_scale_visual()`
- **Lines:** 0
- **Parameters:** `scale_being: Node3D, axis: String`
- **Returns:** `void`
- **Calls:** set_property, new, add_child

### `_setup_uniform_scale_visual()`
- **Lines:** 0
- **Parameters:** `uniform_being: Node3D`
- **Returns:** `void`
- **Calls:** set_property, new, add_child

### `_setup_gizmo_interaction()`
- **Lines:** 0
- **Parameters:** `gizmo_being: Node3D, axis: String, mode: String`
- **Returns:** `void`
- **Calls:** set_property, _on_gizmo_selected, set_meta, add_to_group

### `_process()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _handle_drag, _update_gizmo_position, _end_drag, is_mouse_button_pressed

### `_update_gizmo_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_aabb, _find_mesh_instance

### `_find_mesh_instance()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `MeshInstance3D`
- **Calls:** _find_mesh_instance, get_children

### `_handle_drag()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** project_ray_normal, max, get_mouse_position, Vector3, get_viewport, emit, project_ray_origin, get_camera_3d

### `set_mode()`
- **Lines:** 0
- **Parameters:** `mode: String`
- **Returns:** `void`
- **Calls:** values, print

### `_ready_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null

### `_cmd_gizmo()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** set_mode, str, _find_object_by_name, is_empty, attach_to_object, shown, print, values, size

### `_find_object_by_name()`
- **Lines:** 0
- **Parameters:** `object_name: String`
- **Returns:** `Node3D`
- **Calls:** _recursive_find_by_name, get_child_count, get_child, get_tree, get_nodes_in_group

### `_recursive_find_by_name()`
- **Lines:** 0
- **Parameters:** `node: Node, target_name: String`
- **Returns:** `Node3D`
- **Calls:** get_children, _recursive_find_by_name

### `_connect_to_mouse_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_first_node_in_group, get_node_or_null, get_child_count, set_meta, print, set_process_unhandled_input, get_child, get_tree

### `_is_gizmo_component()`
- **Lines:** 0
- **Parameters:** `obj: Node`
- **Returns:** `bool`
- **Calls:** is_in_group, get_meta, has_meta, get_parent

### `_handle_gizmo_click()`
- **Lines:** 0
- **Parameters:** `obj: Node`
- **Returns:** `void`
- **Calls:** _find_gizmo_being, get_property, get_meta, has_method, _on_gizmo_selected, print

### `_find_gizmo_being()`
- **Lines:** 0
- **Parameters:** `clicked_obj: Node`
- **Returns:** `Node3D`
- **Calls:** is_in_group, get_meta, has_meta, get_parent

### `_on_gizmo_selected()`
- **Lines:** 0
- **Parameters:** `gizmo_being: Node3D, axis: String, mode: String`
- **Returns:** `void`
- **Calls:** get_mouse_position, get_viewport, print

### `_update_drag()`
- **Lines:** 0
- **Parameters:** `mouse_pos: Vector2`
- **Returns:** `void`
- **Calls:** get_viewport, _apply_translation, _apply_rotation, _apply_scale, get_camera_3d

### `_end_drag()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, _print_to_console, get_node_or_null, print

### `_apply_translation()`
- **Lines:** 0
- **Parameters:** `delta: Vector2, camera: Camera3D`
- **Returns:** `void`
- **Calls:** _update_gizmo_position, distance_to

### `_apply_rotation()`
- **Lines:** 0
- **Parameters:** `delta: Vector2`
- **Returns:** `void`
- **Calls:** get_euler, _update_gizmo_position

### `_apply_scale()`
- **Lines:** 0
- **Parameters:** `delta: Vector2`
- **Returns:** `void`
- **Calls:** max, _update_gizmo_position, get_scale

### `_cmd_gizmo_scale()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** str, float, is_empty

### `_cmd_gizmo_offset()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** str, is_empty, _update_gizmo_position, float, size

### `_assign_to_interface_layer()`
- **Lines:** 14
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_instance_valid, get_first_node_in_group, has_method, add_to_layer, print, values, get_tree


## scripts/core/universal_inspection_bridge.gd
**Category:** Core Systems
**Functions:** 18

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** call_deferred, print

### `_connect_to_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _connect_universal_signals, get_node_or_null, _setup_scene_tree_monitoring, emit, _register_bridge_commands, _find_inspector_in_scene, print, _connect_floodgate_signals, get_tree

### `_find_inspector_in_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node`
- **Calls:** filter, get_first_node_in_group, to_lower, print, get_tree, size, get_nodes_in_group

### `_setup_scene_tree_monitoring()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_connected, get_tree, connect, print

### `_on_any_node_added()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** _should_make_inspectable, is_instance_valid, _make_object_inspectable

### `_should_make_inspectable()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `bool`
- **Calls:** any_keyword_in_string, to_lower

### `any_keyword_in_string()`
- **Lines:** 0
- **Parameters:** `text: String, keywords: Array`
- **Returns:** `bool`

### `_make_object_inspectable()`
- **Lines:** 0
- **Parameters:** `object: Node, source: String = "unknown"`
- **Returns:** `void`
- **Calls:** get_class, is_instance_valid, get_ticks_msec, _get_object_position, str, s, get_instance_id, has_method, add_tracked_object, emit, print

### `_get_object_position()`
- **Lines:** 0
- **Parameters:** `object: Node`
- **Returns:** `Vector3`
- **Calls:** Vector3

### `_connect_floodgate_signals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_signal, connect

### `_connect_universal_signals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_signal, connect

### `_on_floodgate_object_created()`
- **Lines:** 0
- **Parameters:** `object: Node`
- **Returns:** `void`
- **Calls:** _make_object_inspectable

### `_on_universal_object_spawned()`
- **Lines:** 0
- **Parameters:** `object: Node`
- **Returns:** `void`
- **Calls:** _make_object_inspectable

### `_register_bridge_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, has_method

### `_cmd_list_inspectable()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** s, _print_to_console, is_instance_valid, at

### `_cmd_inspect_by_name()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, is_instance_valid, _find_and_list_inspectors, get_node_or_null, has_method, inspect_object, size

### `_cmd_bridge_status()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** str, _print_to_console, size

### `_find_and_list_inspectors()`
- **Lines:** 46
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_class, _print_to_console, str, get_node_or_null, is_empty, to_lower, get_path, append, get_tree, size, get_nodes_in_group


## scripts/core/universal_workflow_analyzer.gd
**Category:** Core Systems
**Functions:** 14

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** analyze_entire_project, print

### `analyze_entire_project()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _generate_workflow_graph, _map_execution_flows, _suggest_combinations, _find_duplicates, generate_complete_report, emit_signal, print, _scan_all_scripts
- **Signals:** analysis_complete

### `_scan_all_scripts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, _scan_directory_recursive

### `_scan_directory_recursive()`
- **Lines:** 0
- **Parameters:** `dir: DirAccess, path: String`
- **Returns:** `void`
- **Calls:** open, get_next, begins_with, _scan_directory_recursive, _analyze_script, current_is_dir, ends_with, list_dir_begin

### `_analyze_script()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `void`
- **Calls:** close, get_as_text, open, _determine_purpose, new, compile, search_all, append, get_string

### `_determine_purpose()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `String`
- **Calls:** get_base_dir, get_basename, get_file

### `_map_execution_flows()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _trace_execution_path

### `_trace_execution_path()`
- **Lines:** 0
- **Parameters:** `func_name: String, visited: Array = []`
- **Returns:** `Array`
- **Calls:** append_array, duplicate, _trace_execution_path, append, get

### `_find_duplicates()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, size, emit_signal
- **Signals:** duplicate_found

### `_suggest_combinations()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, has, size

### `_generate_workflow_graph()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _get_files_with_substring

### `_get_files_with_substring()`
- **Lines:** 0
- **Parameters:** `substring: String`
- **Returns:** `Array`
- **Calls:** append

### `generate_complete_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_file, str, min, to_upper, slice, size, get

### `generate_combination_script()`
- **Lines:** 44
- **Parameters:** `suggestion: Dictionary`
- **Returns:** `String`
- **Calls:** str, to_upper, append_array, get


## scripts/core/upright_ragdoll_controller.gd
**Category:** Core Systems
**Functions:** 17

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _configure_physics, _store_rest_positions, _find_body_parts

### `_find_body_parts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children

### `_store_rest_positions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3

### `_configure_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_physics_mode, _process_blend_mode, _apply_balance_forces, _process_controlled_mode

### `_process_controlled_mode()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** apply_torque, _maintain_rest_pose, get_euler, apply_central_force, _process_walking

### `_process_walking()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** sin, max, _apply_rotation_force, Vector3, length, apply_central_force

### `_maintain_rest_pose()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, get

### `_apply_rotation_force()`
- **Lines:** 0
- **Parameters:** `body: RigidBody3D, target_euler: Vector3`
- **Returns:** `void`
- **Calls:** apply_torque

### `_apply_balance_forces()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, abs

### `_process_physics_mode()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`

### `_process_blend_mode()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_controlled_mode

### `start_walking()`
- **Lines:** 0
- **Parameters:** `direction: Vector3`
- **Returns:** `void`
- **Calls:** normalized

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `set_ragdoll_mode()`
- **Lines:** 0
- **Parameters:** `new_mode: RagdollMode`
- **Returns:** `void`

### `stand_up()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, _maintain_rest_pose

### `ragdoll_fall()`
- **Lines:** 3
- **Parameters:** ``
- **Returns:** `void`


## scripts/debug/movement_test.gd
**Category:** Debug & Testing
**Functions:** 1

### `test_movement_stacking()`
- **Lines:** 58
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, backward, get_node_or_null, get_first_node_in_group, has_method, get_method_list, execute_movement_command, has, print, begins_with, get_tree


## scripts/debug/ragdoll_debug_visualizer.gd
**Category:** Debug & Testing
**Functions:** 14

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_materials, set_process, print

### `_create_materials()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new

### `set_ragdoll()`
- **Lines:** 0
- **Parameters:** `ragdoll: Node3D`
- **Returns:** `void`
- **Calls:** get_node, has_node, print

### `_process()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _clear_debug_elements, _visualize_center_of_mass, get_meta, is_empty, _visualize_velocities, _visualize_walker_state, _visualize_support_polygon, _visualize_joints

### `_clear_debug_elements()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, clear

### `_visualize_joints()`
- **Lines:** 0
- **Parameters:** `body_parts: Dictionary`
- **Returns:** `void`
- **Calls:** has, _draw_line

### `_visualize_center_of_mass()`
- **Lines:** 0
- **Parameters:** `body_parts: Dictionary`
- **Returns:** `void`
- **Calls:** _draw_sphere, Vector3, _create_label

### `_visualize_velocities()`
- **Lines:** 0
- **Parameters:** `body_parts: Dictionary`
- **Returns:** `void`
- **Calls:** Vector3, _create_label, length, _draw_line

### `_visualize_walker_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_status, Vector3, get_meta, _create_label, get

### `_visualize_support_polygon()`
- **Lines:** 0
- **Parameters:** `body_parts: Dictionary`
- **Returns:** `void`
- **Calls:** _draw_sphere, get, _draw_line

### `_draw_line()`
- **Lines:** 0
- **Parameters:** `start: Vector3, end: Vector3, material: Material, thickness: float = 0.02`
- **Returns:** `void`
- **Calls:** rotate_object_local, new, distance_to, add_child, look_at, append

### `_draw_sphere()`
- **Lines:** 0
- **Parameters:** `position: Vector3, radius: float, material: Material`
- **Returns:** `void`
- **Calls:** append, new, add_child

### `_create_label()`
- **Lines:** 0
- **Parameters:** `position: Vector3, text: String, color: Color`
- **Returns:** `void`
- **Calls:** append, new, add_child

### `toggle_debug_option()`
- **Lines:** 31
- **Parameters:** `option: String`
- **Returns:** `String`
- **Calls:** str


## scripts/debug/ragdoll_physics_test.gd
**Category:** Debug & Testing
**Functions:** 9

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `test_configuration()`
- **Lines:** 0
- **Parameters:** `config_name: String`
- **Returns:** `void`
- **Calls:** keys, str, get_first_node_in_group, _apply_config_to_ragdoll, has, print, get_tree

### `_apply_config_to_ragdoll()`
- **Lines:** 0
- **Parameters:** `config: Dictionary`
- **Returns:** `void`
- **Calls:** _find_rigid_bodies_recursive, str, has, print, size

### `_find_rigid_bodies_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node, bodies: Array`
- **Returns:** `void`
- **Calls:** append, get_children, _find_rigid_bodies_recursive

### `show_physics_info()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _find_rigid_bodies_recursive, str, get_first_node_in_group, print, get_tree

### `adjust_single_property()`
- **Lines:** 0
- **Parameters:** `property: String, value: float`
- **Returns:** `void`
- **Calls:** _find_rigid_bodies_recursive, str, get_first_node_in_group, print, get_tree, size

### `run_movement_test()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, get_tree, get_first_node_in_group, print

### `compare_all_configs()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, to_upper, print

### `handle_physics_command()`
- **Lines:** 27
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** adjust_single_property, test_configuration, show_physics_info, compare_all_configs, float, size


## scripts/debug/universal_entity_debug.gd
**Category:** Debug & Testing
**Functions:** 1

### `_ready()`
- **Lines:** 84
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, new, load, queue_free, str, get_node_or_null, set_script, has_method, exists, get_script, print, get_tree, size


## scripts/effects/blink_animation_controller.gd
**Category:** Visual Effects
**Functions:** 26

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_current_turn, new, add_child, str, _schedule_next_blink, get_node_or_null, connect, Callable, _initialize_timers, _create_default_animations, print, _schedule_next_flicker, _find_node_by_class, register_system, get_tree, _schedule_next_wink

### `_find_node_by_class()`
- **Lines:** 0
- **Parameters:** `node, class_name_str`
- **Returns:** `void`
- **Calls:** get_class, get_children, find, to_lower, get_script, get_path, _find_node_by_class, or

### `_initialize_timers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, new, Callable, connect

### `_create_default_animations()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_animation_library, add_track, add_animation, track_insert_key, track_set_path

### `_schedule_next_blink()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_debug_build, max, str, randf, start, print, pow

### `_schedule_next_wink()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_debug_build, max, str, randf, start, print, pow

### `_schedule_next_flicker()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_debug_build, max, str, randf, start, print, pow

### `_execute_blink()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, is_debug_build, str, randf, _schedule_next_blink, get_tree, print, _blink_node

### `_execute_wink()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, is_debug_build, randf, wink, print, _wink_node, get_tree, _schedule_next_wink

### `_execute_flicker()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, is_debug_build, str, randi, _schedule_next_flicker, print, get_tree, _flicker_node

### `_blink_node()`
- **Lines:** 0
- **Parameters:** `node_name: String, blink_count: int`
- **Returns:** `void`
- **Calls:** create_timer, has_parameter, is_instance_valid, apply_blink, has_method, has_property, tween_property, erase, has, emit_signal, get_tree, range, create_tween
- **Signals:** blink_ended, blink_started

### `_wink_node()`
- **Lines:** 0
- **Parameters:** `node_name: String, is_left: bool`
- **Returns:** `void`
- **Calls:** has_parameter, is_instance_valid, get_node_or_null, has_method, has_property, tween_property, erase, has, emit_signal, Color, create_tween, apply_wink
- **Signals:** wink_started, wink_ended

### `_flicker_node()`
- **Lines:** 0
- **Parameters:** `node_name: String, flicker_count: int`
- **Returns:** `void`
- **Calls:** create_timer, has_parameter, is_instance_valid, randf, has_method, has_property, tween_property, erase, has, emit_signal, apply_flicker, get_tree, range, create_tween
- **Signals:** flicker_started, flicker_ended

### `_on_blink_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _execute_blink

### `_on_wink_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _execute_wink

### `_on_flicker_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _execute_flicker

### `_on_turn_started()`
- **Lines:** 0
- **Parameters:** `turn_number`
- **Returns:** `void`
- **Calls:** create_timer, str, _schedule_next_blink, stop, _blink_node, _schedule_next_flicker, print, get_tree, _schedule_next_wink

### `register_node()`
- **Lines:** 0
- **Parameters:** `node_name: String, node: Node`
- **Returns:** `bool`
- **Calls:** has, print

### `unregister_node()`
- **Lines:** 0
- **Parameters:** `node_name: String`
- **Returns:** `bool`
- **Calls:** erase, has, print

### `trigger_blink()`
- **Lines:** 0
- **Parameters:** `node_name: String = "", blink_count: int = 1`
- **Returns:** `bool`
- **Calls:** _blink_node, has, is_empty, print

### `trigger_wink()`
- **Lines:** 0
- **Parameters:** `node_name: String = "", is_left: bool = true`
- **Returns:** `bool`
- **Calls:** _wink_node, has, is_empty, print

### `trigger_flicker()`
- **Lines:** 0
- **Parameters:** `node_name: String = "", flicker_count: int = 3`
- **Returns:** `bool`
- **Calls:** has, _flicker_node, is_empty, print

### `set_enabled()`
- **Lines:** 0
- **Parameters:** `is_enabled: bool`
- **Returns:** `void`
- **Calls:** stop, _schedule_next_blink, print, is_stopped

### `set_wink_enabled()`
- **Lines:** 0
- **Parameters:** `is_enabled: bool`
- **Returns:** `void`
- **Calls:** stop, print, _schedule_next_wink, is_stopped

### `set_flicker_enabled()`
- **Lines:** 0
- **Parameters:** `is_enabled: bool`
- **Returns:** `void`
- **Calls:** stop, print, _schedule_next_flicker, is_stopped

### `on_turn_changed()`
- **Lines:** 23
- **Parameters:** `turn_number: int, turn_data: Dictionary`
- **Returns:** `void`
- **Calls:** _schedule_next_blink, stop, _schedule_next_flicker, has, _schedule_next_wink


## scripts/effects/dimensional_color_system.gd
**Category:** Visual Effects
**Functions:** 39

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _initialize_mesh_point_map, _initialize_frequency_color_map, str, _generate_tertiary_colors, _generate_color_palettes, _find_systems, print, size

### `_generate_tertiary_colors()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Color, append, range, float, size, lerp

### `_initialize_frequency_color_map()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has, Color, range, float, size, lerp

### `_initialize_mesh_point_map()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, range, has, size

### `_generate_color_palettes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Color

### `_find_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, get_node_or_null, print, _find_node_by_class

### `_find_node_by_class()`
- **Lines:** 0
- **Parameters:** `node, class_name_str`
- **Returns:** `void`
- **Calls:** get_class, get_children, find, to_lower, get_script, get_path, _find_node_by_class, or

### `_process()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _update_animations

### `_update_animations()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _update_pulse_animation, _update_mesh_point_animation, _update_fade_animation, erase, _update_cycle_animation, emit_signal, _update_rainbow_animation, append
- **Signals:** animation_completed

### `_update_pulse_animation()`
- **Lines:** 0
- **Parameters:** `animation, progress`
- **Returns:** `void`
- **Calls:** sin, emit_signal, lerp
- **Signals:** color_frequency_updated

### `_update_fade_animation()`
- **Lines:** 0
- **Parameters:** `animation, progress`
- **Returns:** `void`
- **Calls:** emit_signal, lerp
- **Signals:** color_frequency_updated

### `_update_cycle_animation()`
- **Lines:** 0
- **Parameters:** `animation, progress`
- **Returns:** `void`
- **Calls:** fmod, emit_signal, size, lerp, int
- **Signals:** color_frequency_updated

### `_update_rainbow_animation()`
- **Lines:** 0
- **Parameters:** `animation, progress`
- **Returns:** `void`
- **Calls:** fmod, from_hsv, emit_signal
- **Signals:** color_frequency_updated

### `_update_mesh_point_animation()`
- **Lines:** 0
- **Parameters:** `animation, progress`
- **Returns:** `void`
- **Calls:** sin, emit_signal, fmod, lerp
- **Signals:** mesh_point_activated, color_frequency_updated

### `get_color_for_frequency()`
- **Lines:** 0
- **Parameters:** `frequency: int`
- **Returns:** `Color`
- **Calls:** clamp, has, Color

### `get_mesh_point_type()`
- **Lines:** 0
- **Parameters:** `frequency: int`
- **Returns:** `Array`
- **Calls:** has

### `get_closest_harmonic_frequency()`
- **Lines:** 0
- **Parameters:** `frequency: int`
- **Returns:** `int`
- **Calls:** append_array, abs

### `get_color_palette()`
- **Lines:** 0
- **Parameters:** `palette_name: String = "default"`
- **Returns:** `Array`
- **Calls:** has

### `start_pulse_animation()`
- **Lines:** 0
- **Parameters:** `frequency: int, duration: float = DEFAULT_ANIMATION_DURATION, pulse_freq: float = DEFAULT_PULSE_FREQUENCY, amplitude: float = DEFAULT_AMPLITUDE`
- **Returns:** `String`
- **Calls:** get_color_for_frequency, str, emit_signal, get_closest_harmonic_frequency, get_unix_time_from_system
- **Signals:** animation_started

### `start_fade_animation()`
- **Lines:** 0
- **Parameters:** `frequency: int, target_color: Color, duration: float = DEFAULT_ANIMATION_DURATION`
- **Returns:** `String`
- **Calls:** str, get_unix_time_from_system, emit_signal, get_color_for_frequency
- **Signals:** animation_started

### `start_cycle_animation()`
- **Lines:** 0
- **Parameters:** `frequency: int, palette_name: String = "default", duration: float = DEFAULT_ANIMATION_DURATION, cycle_speed: float = 1.0`
- **Returns:** `String`
- **Calls:** get_color_palette, get_color_for_frequency, str, emit_signal, get_unix_time_from_system
- **Signals:** animation_started

### `start_rainbow_animation()`
- **Lines:** 0
- **Parameters:** `frequency: int, duration: float = DEFAULT_ANIMATION_DURATION, rainbow_speed: float = 1.0, saturation: float = 1.0, brightness: float = 1.0`
- **Returns:** `String`
- **Calls:** str, get_unix_time_from_system, emit_signal, get_color_for_frequency
- **Signals:** animation_started

### `start_mesh_point_animation()`
- **Lines:** 0
- **Parameters:** `frequency: int, duration: float = DEFAULT_ANIMATION_DURATION, pulse_freq: float = DEFAULT_PULSE_FREQUENCY`
- **Returns:** `String`
- **Calls:** get_mesh_point_type, get_color_for_frequency, str, Color, emit_signal, size, get_unix_time_from_system
- **Signals:** mesh_point_activated, animation_started

### `stop_animation()`
- **Lines:** 0
- **Parameters:** `animation_id: String`
- **Returns:** `bool`
- **Calls:** erase, has, get_closest_harmonic_frequency, get_color_for_frequency

### `stop_all_animations()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, get_closest_harmonic_frequency, get_color_for_frequency

### `get_colored_text()`
- **Lines:** 0
- **Parameters:** `text: String, frequency: int`
- **Returns:** `String`
- **Calls:** to_html, get_color_for_frequency

### `get_gradient_text()`
- **Lines:** 0
- **Parameters:** `text: String, start_freq: int, end_freq: int`
- **Returns:** `String`
- **Calls:** to_html, get_color_for_frequency

### `colorize_line()`
- **Lines:** 0
- **Parameters:** `line: String, base_frequency: int, symbol_boost: int = 10`
- **Returns:** `String`
- **Calls:** max, get_color_for_frequency, to_html, length, min, range

### `colorize_mesh_points()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `String`
- **Calls:** new, compile, get_color_for_frequency, keys, to_html, str, sub

### `start_line_animation()`
- **Lines:** 0
- **Parameters:** `line_index: int, frequency: int = 120, animation_type: String = "pulse", duration: float = DEFAULT_ANIMATION_DURATION`
- **Returns:** `String`
- **Calls:** start_pulse_animation, start_rainbow_animation, start_cycle_animation, start_mesh_point_animation

### `animate_text_typing()`
- **Lines:** 0
- **Parameters:** `text: String, base_freq: int = 120, duration: float = 2.0, delay_per_char: float = 0.05`
- **Returns:** `void`
- **Calls:** str, emit_signal, get_unix_time_from_system
- **Signals:** animation_started

### `highlight_mesh_points()`
- **Lines:** 0
- **Parameters:** `frequencies: Array, duration: float = 5.0`
- **Returns:** `void`
- **Calls:** has, start_mesh_point_animation

### `highlight_mesh_centers()`
- **Lines:** 0
- **Parameters:** `duration: float = 5.0`
- **Returns:** `void`
- **Calls:** highlight_mesh_points

### `highlight_mesh_edges()`
- **Lines:** 0
- **Parameters:** `duration: float = 5.0`
- **Returns:** `void`
- **Calls:** highlight_mesh_points

### `highlight_mesh_corners()`
- **Lines:** 0
- **Parameters:** `duration: float = 5.0`
- **Returns:** `void`
- **Calls:** highlight_mesh_points

### `get_mesh_visualization_colors()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_color_for_frequency

### `sync_with_ethereal_bridge()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** clamp, get_active_dimensions, has_method, start_pulse_animation, has, int

### `get_frequency_info()`
- **Lines:** 0
- **Parameters:** `frequency: int`
- **Returns:** `Dictionary`
- **Calls:** get_mesh_point_type, get_color_for_frequency, clamp, has, _frequency_has_animation

### `_frequency_has_animation()`
- **Lines:** 7
- **Parameters:** `frequency: int`
- **Returns:** `bool`


## scripts/effects/visual_indicator_system.gd
**Category:** Visual Effects
**Functions:** 17

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, _find_time_tracker, _setup_timers, print, _apply_mode_settings

### `_setup_timers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, new, connect

### `_find_time_tracker()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, has_signal, print, _find_node_by_class, get_tree, size, get_nodes_in_group

### `_find_node_by_class()`
- **Lines:** 0
- **Parameters:** `node: Node, target_class: String`
- **Returns:** `Node`
- **Calls:** get_class, get_children, _find_node_by_class

### `_apply_mode_settings()`
- **Lines:** 0
- **Parameters:** `mode_index`
- **Returns:** `void`
- **Calls:** emit_signal, _set_symbol
- **Signals:** mode_changed

### `_set_symbol()`
- **Lines:** 0
- **Parameters:** `symbol_index`
- **Returns:** `void`
- **Calls:** emit_signal
- **Signals:** symbol_changed

### `_on_blink_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit_signal
- **Signals:** blink_occurred

### `_on_color_cycle_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, emit_signal
- **Signals:** color_updated, layer_changed

### `_on_animation_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_on_time_updated()`
- **Lines:** 0
- **Parameters:** `session_time, total_time`
- **Returns:** `void`
- **Calls:** _set_symbol, floor, size, min

### `_on_hour_limit_reached()`
- **Lines:** 0
- **Parameters:** `hours`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _set_symbol

### `set_mode()`
- **Lines:** 0
- **Parameters:** `mode_index: int`
- **Returns:** `bool`
- **Calls:** size, _apply_mode_settings

### `cycle_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `int`
- **Calls:** size, _apply_mode_settings

### `toggle_enabled()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`

### `get_current_symbol()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`

### `get_current_mode_name()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`

### `get_visual_state()`
- **Lines:** 17
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** size, get_current_mode_name


## scripts/jsh_framework/core/JSH_console.gd
**Category:** Core Systems
**Functions:** 218

### `_ready_add()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_output_display, update_memory_display, update_input_display, update_status

### `_process_add()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** update_cursor

### `update_cursor()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, length

### `update_input_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_cursor

### `update_output_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `update_status()`
- **Lines:** 0
- **Parameters:** `status: String`
- **Returns:** `void`

### `update_memory_display()`
- **Lines:** 0
- **Parameters:** `percentage: int`
- **Returns:** `void`
- **Calls:** str

### `handle_key_input()`
- **Lines:** 0
- **Parameters:** `key: String`
- **Returns:** `void`
- **Calls:** substr, length, update_input_display, execute_command

### `history_up()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, update_input_display

### `history_down()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, update_input_display

### `execute_command()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** process_command, pop_front, update_output_display, push_back, strip_edges, size, update_input_display, int

### `process_command()`
- **Lines:** 0
- **Parameters:** `command_text: String`
- **Returns:** `void`
- **Calls:** substr, show_help, find, update_memory_display, update_status, to_lower, clear_terminal, show_command_history, list_things, strip_edges, size, split

### `setup_terminal()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, connect, jsh_tree_get_node, start, print

### `terminal_blink_cursor()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** jsh_tree_get_node

### `handle_terminal_key_press()`
- **Lines:** 0
- **Parameters:** `key: String`
- **Returns:** `void`
- **Calls:** update_terminal_display, len

### `handle_terminal_backspace()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_terminal_display, substr, length

### `update_terminal_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** jsh_tree_get_node, Vector3, length

### `history_upp()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_terminal_display, size

### `history_downn()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_terminal_display, size

### `execute_commandd()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** strip_edges, push_back, size

### `_readyy()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command_aliases, setup_cursor_timer, setup_terminal_variables, initialize_terminal

### `_init()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_readyyy()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_default_commands, get_node, setup_material_cache, has_node, get_node_or_null, get_viewport, setup_terminal_container, add_text_line, get_camera_3d

### `_processs()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** look_at, update_letter_visuals

### `_input()`
- **Lines:** 0
- **Parameters:** `event`
- **Returns:** `void`
- **Calls:** add_command_character, execute_command, remove_command_character, char, navigate_history

### `_process_cmd()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** update_cursor

### `initialize_terminal()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `setup_terminal_variables()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `setup_cursor_timer()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, start, new, add_child

### `register_command_aliases()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `setup_terminal_visual_components()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** eighth_dimensional_magic, update_memory_display, update_status, jsh_tree_get_node, update_output_display, print, update_input_display

### `update_cursorr()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, length

### `update_input_displayy()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_cursor

### `update_output_displayy()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `update_statuss()`
- **Lines:** 0
- **Parameters:** `status: String`
- **Returns:** `void`

### `update_memory_displayy()`
- **Lines:** 0
- **Parameters:** `percentage: int`
- **Returns:** `void`
- **Calls:** str

### `blink_cursor()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_cursor

### `handle_key_press()`
- **Lines:** 0
- **Parameters:** `key: String`
- **Returns:** `void`
- **Calls:** update_input_display, len, length, insert

### `handle_backspace()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, length, update_input_display

### `history_uppp()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, update_input_display

### `history_downnn()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, update_input_display

### `execute_commanddd()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_status, update_output_display, pop_front, push_back, strip_edges, size, update_input_display, int

### `process_commandddd()`
- **Lines:** 0
- **Parameters:** `command_text: String`
- **Returns:** `void`
- **Calls:** hide_container, update_status, clear_terminal, run_script_file, update_output_display, size, split, delete_thing, set_variable, substr, move_object, rotate_object, has, find_objects, show_help, display_system_status, update_memory_display, to_lower, create_planet, connect_things, display_memory_usage, start_snake_game, unload_scene, close_terminal, list_things, strip_edges, show_container, find, load_scene, create_thing, show_command_history, get_variable_value

### `show_help()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get_command_usage, has, size, to_lower

### `get_command_usage()`
- **Lines:** 0
- **Parameters:** `cmd: String`
- **Returns:** `String`

### `clear_terminal()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`

### `show_command_history()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** str, range, size

### `list_things()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** has, size, split

### `create_thing()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** create_new_task, range, size, split

### `delete_thing()`
- **Lines:** 0
- **Parameters:** `name: String`
- **Returns:** `String`
- **Calls:** find_thing_path, is_empty, fifth_dimensional_magic

### `connect_things()`
- **Lines:** 0
- **Parameters:** `thing1: String, thing2: String`
- **Returns:** `String`
- **Calls:** eighth_dimensional_magic

### `show_container()`
- **Lines:** 0
- **Parameters:** `container_name: String`
- **Returns:** `String`
- **Calls:** seventh_dimensional_magic, has

### `hide_container()`
- **Lines:** 0
- **Parameters:** `container_name: String`
- **Returns:** `String`
- **Calls:** seventh_dimensional_magic, has

### `move_object()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** Vector3, str, the_fourth_dimensional_magic, is_empty, jsh_tree_get_node, find_thing_path, float, size, split

### `rotate_object()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** Vector3, str, the_fourth_dimensional_magic, is_empty, jsh_tree_get_node, find_thing_path, float, size, split

### `load_scene()`
- **Lines:** 0
- **Parameters:** `scene_name: String`
- **Returns:** `String`
- **Calls:** create_new_task

### `unload_scene()`
- **Lines:** 0
- **Parameters:** `scene_name: String`
- **Returns:** `String`
- **Calls:** fifth_dimensional_magic

### `find_objects()`
- **Lines:** 0
- **Parameters:** `query: String`
- **Returns:** `String`
- **Calls:** contains, str, to_lower, has, object

### `display_system_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** str, get_thread_count, get_queued_tasks, has, get_frames_per_second, get_active_tasks, size

### `display_memory_usage()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** snapped, str, get_monitor

### `set_variable()`
- **Lines:** 0
- **Parameters:** `name: String, value: String`
- **Returns:** `String`
- **Calls:** has

### `register_command()`
- **Lines:** 0
- **Parameters:** `command: String, handler_object: Object, handler_method: String`
- **Returns:** `void`
- **Calls:** unlock, lock

### `set_command_help()`
- **Lines:** 0
- **Parameters:** `command: String, usage: String, help_text: String`
- **Returns:** `void`
- **Calls:** unlock, has, lock

### `process_command_new()`
- **Lines:** 0
- **Parameters:** `command_text: String`
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec, unlock, add_output_line, call, to_lower, has, lock, slice, append, remove_at, strip_edges, size, split

### `add_output_line()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, unlock, lock, append, remove_at, size

### `get_output_history()`
- **Lines:** 0
- **Parameters:** `count: int = -1`
- **Returns:** `Array`
- **Calls:** unlock, duplicate, lock, slice, size

### `clear_output()`
- **Lines:** 66
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, clear, lock

### `execute_commandddd()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** process_command, update_command_line, has_method, size, submit_task, append, add_text_line

### `add_command_character()`
- **Lines:** 0
- **Parameters:** `character: String`
- **Returns:** `void`
- **Calls:** update_command_line

### `remove_command_character()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, length, update_command_line

### `navigate_history()`
- **Lines:** 0
- **Parameters:** `direction: int`
- **Returns:** `void`
- **Calls:** update_command_line, clamp, size

### `update_command_line()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, add_child, queue_free, Vector3, length, create_3d_letter, range

### `add_text_line()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** reposition_text_lines, remove_floating_word, Vector3, pop_front, has, append, size, create_floating_text

### `create_delimiter_instance()`
- **Lines:** 0
- **Parameters:** `position: Vector3`
- **Returns:** `MeshInstance3D`
- **Calls:** get_node, duplicate

### `remove_floating_word()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** queue_free, erase, clean_word_connections, has

### `clean_word_connections()`
- **Lines:** 0
- **Parameters:** `text_key: String`
- **Returns:** `void`
- **Calls:** queue_free, get_meta, remove_at, has_meta, range, size

### `reposition_text_lines()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, tween_property, has, range, size, create_tween

### `toggle_visibility()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit_signal
- **Signals:** terminal_toggled

### `clear_terminall()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, remove_floating_word, add_text_line, keys

### `set_terminal_shape()`
- **Lines:** 0
- **Parameters:** `shape: String`
- **Returns:** `void`
- **Calls:** add_text_line

### `log_message()`
- **Lines:** 0
- **Parameters:** `message: String, type: int = LogType.INFO`
- **Returns:** `void`
- **Calls:** add_text_line, emit_signal
- **Signals:** log_added

### `_cmd_help()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** sort, keys, has, size, add_text_line

### `_cmd_clear()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** clear_terminal

### `_cmd_shape()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** set_terminal_shape, join, has, size, add_text_line

### `_cmd_snake()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** call_deferred, add_text_line

### `_ready_older()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, get_viewport, setup_terminal_container, add_text_line, get_camera_3d

### `_ready_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, get_viewport, setup_terminal_container, add_text_line, get_camera_3d

### `_ready_new_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** setup_containers, setup_material_cache, get_node_or_null, get_viewport, setup_grid, setup_combo_rules, setup_shape_viewer, add_text_line, get_camera_3d

### `_ready_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** load_function_network, setup_containers, get_node, setup_material_cache, has_node, get_node_or_null, get_viewport, add_text_line, get_camera_3d

### `_ready_new_v2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** log_message, connect, _setup_ui

### `check_terminal_combo_pattern()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** range, size, split, to_lower

### `_init_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_init_new_v2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command

### `_init_new_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_init_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `update_letter_visuals_new_v2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sin, distance_to, get_ticks_msec, Vector3, get_meta, clamp, set_meta, Color, cos, float, range, size, pow, int

### `update_letter_visuals_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sin, distance_to, get_ticks_msec, Vector3, get_meta, clamp, set_meta, Color, cos, float, has_meta, range, size, pow, int

### `update_word_connections_new_v2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, create_word_connection, clear, range, size

### `update_letter_visuals_new_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sin, distance_to, get_ticks_msec, Vector3, get_meta, clamp, set_meta, Color, cos, float, range, size, pow, int

### `update_primitive_shape()`
- **Lines:** 0
- **Parameters:** `shape_type: String, params: Dictionary`
- **Returns:** `void`
- **Calls:** Vector2, new, Vector3, duplicate, get

### `update_command_line_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, add_child, queue_free, Vector3, length, create_3d_letter, range

### `update_word_connections()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_function_connection, queue_free, has, clear, size

### `update_letter_visuals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sin, distance_to, get_ticks_msec, Vector3, get_meta, clamp, set_meta, has, Color, cos, float, has_meta, range, size, pow, int

### `remove_floating_word_new_v2()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** queue_free, erase, has

### `reposition_text_lines_new_v2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, tween_property, has, range, size, create_tween

### `reposition_text_lines_new_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, tween_property, has, range, size, create_tween

### `remove_floating_word_new_v1()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** queue_free, erase, has

### `launch_snake_game_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** show_snake_game, get_node_or_null, has_method, create_snake_game

### `remove_command_character_new_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, length, update_command_line

### `execute_command_new_v3()`
- **Lines:** 40
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** process_command, update_command_line, has_method, size, submit_task, append, add_text_line

### `create_snake_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, Vector3, print, add_text_line

### `create_3d_text_terminal()`
- **Lines:** 0
- **Parameters:** `position: Vector3, size: Vector2`
- **Returns:** `Node3D`
- **Calls:** Vector2, new, add_child

### `create_grid_primitive()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `create_function_connection()`
- **Lines:** 0
- **Parameters:** `source_func: String, target_func: String`
- **Returns:** `void`
- **Calls:** rotate_object_local, look_at_from_position, new, distance_to, add_child, dot, length, set_meta, duplicate, abs, normalized, append, range, size

### `create_delimiter_instance_new()`
- **Lines:** 0
- **Parameters:** `position: Vector3`
- **Returns:** `MeshInstance3D`
- **Calls:** get_node, duplicate

### `create_floating_text_new_v2()`
- **Lines:** 0
- **Parameters:** `text: String, position: Vector3`
- **Returns:** `Node3D`
- **Calls:** substr, create_delimiter_instance, new, add_child, get_ticks_msec, sha1_text, str, length, Vector3, create_3d_letter, append, range, size, split

### `create_3d_letter_new_v2()`
- **Lines:** 0
- **Parameters:** `letter: String, position: Vector3`
- **Returns:** `Node3D`
- **Calls:** new, add_child, Vector3, set_meta, Color

### `create_3d_letter()`
- **Lines:** 0
- **Parameters:** `letter: String, position: Vector3`
- **Returns:** `Node3D`
- **Calls:** new, add_child, Vector3, set_meta, Color

### `create_delimiter_instance_new_v1()`
- **Lines:** 0
- **Parameters:** `position: Vector3`
- **Returns:** `MeshInstance3D`
- **Calls:** get_node, duplicate

### `create_floating_text_new_v1()`
- **Lines:** 0
- **Parameters:** `text: String, position: Vector3`
- **Returns:** `Node3D`
- **Calls:** substr, create_delimiter_instance, new, add_child, get_ticks_msec, sha1_text, str, length, Vector3, create_3d_letter, append, range, size, split

### `create_snake_game_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, Vector3, print, add_text_line

### `create_delimiter_instance_new_v2()`
- **Lines:** 0
- **Parameters:** `position: Vector3`
- **Returns:** `MeshInstance3D`
- **Calls:** get_node, duplicate

### `create_delimiter_instance_new_v23()`
- **Lines:** 0
- **Parameters:** `position: Vector3`
- **Returns:** `MeshInstance3D`
- **Calls:** get_node, duplicate

### `create_floating_text_new()`
- **Lines:** 0
- **Parameters:** `text: String, position: Vector3`
- **Returns:** `Node3D`
- **Calls:** substr, create_delimiter_instance, new, add_child, get_ticks_msec, sha1_text, str, length, Vector3, set_meta, get_meta, create_3d_letter, has, Color, append, range, size, split

### `create_3d_letter_new()`
- **Lines:** 0
- **Parameters:** `letter: String, position: Vector3`
- **Returns:** `Node3D`
- **Calls:** new, add_child, Vector3, set_meta, Color

### `create_3d_letter_new_v1()`
- **Lines:** 0
- **Parameters:** `letter: String, position: Vector3`
- **Returns:** `Node3D`
- **Calls:** new, add_child, Vector3, set_meta, Color

### `create_floating_text()`
- **Lines:** 0
- **Parameters:** `text: String, position: Vector3`
- **Returns:** `Node3D`
- **Calls:** substr, create_delimiter_instance, new, add_child, get_ticks_msec, sha1_text, str, length, Vector3, set_meta, get_meta, create_3d_letter, has, Color, append, range, size, split

### `add_command_character_new()`
- **Lines:** 0
- **Parameters:** `character: String`
- **Returns:** `void`
- **Calls:** update_command_line

### `add_command_character_new_v1()`
- **Lines:** 0
- **Parameters:** `character: String`
- **Returns:** `void`
- **Calls:** update_command_line

### `add_text_line_new_v1()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** reposition_text_lines, remove_floating_word, Vector3, pop_front, has, append, size, create_floating_text

### `add_text_line_n3()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** reposition_text_lines, remove_floating_word, process_keywords, Vector3, update_word_connections, pop_front, has, append, process_function_references, size, create_floating_text

### `add_path_to_network()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `add_node_to_network()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `add_command_character_n3()`
- **Lines:** 0
- **Parameters:** `character: String`
- **Returns:** `void`
- **Calls:** update_command_line

### `add_log()`
- **Lines:** 0
- **Parameters:** `message: String, type: int = LogType.INFO`
- **Returns:** `void`
- **Calls:** log_message

### `add_text_line_new()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** reposition_text_lines, remove_floating_word, process_keywords, Vector3, update_word_connections, pop_front, has, append, check_combos, size, create_floating_text

### `add_text_line_new_v2()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** reposition_text_lines, remove_floating_word, Vector3, pop_front, has, append, size, create_floating_text

### `execute_command_new_v1()`
- **Lines:** 0
- **Parameters:** `text`
- **Returns:** `void`
- **Calls:** print

### `clear_terminal_n3()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, remove_floating_word, keys

### `launch_snake_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** show_snake_game, get_node_or_null, has_method, create_snake_game

### `execute_command_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, add_text_line, size

### `remove_command_character_n3()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, length, update_command_line

### `execute_command_new_n1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_command_line, has_method, size, submit_task, append, add_text_line

### `setup_grid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `setup_shape_viewer()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `setup_containers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, Color, setup_grid_viewer, setup_shape_viewer

### `setup_material_cache()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, Color

### `setup_grid_viewer()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, queue_free, Vector3, set_meta, Vector3i, duplicate, append, clear, range

### `setup_containers_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, Color, add_child

### `setup_material_cache_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, Color

### `setup_terminal_container_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, Color, add_child

### `setup_combo_rules()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `setup_shape_viewer_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_primitive_shape, new, add_child

### `_setup_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, set_anchors_preset, add_child

### `setup_terminal_container()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, Color, add_child

### `check_combos()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** keys, has, append, activate_combo, split

### `activate_combo()`
- **Lines:** 0
- **Parameters:** `combo: String`
- **Returns:** `void`
- **Calls:** set_terminal_shape, toggle_dimension_mode, create_grid_primitive, toggle_light_mode, add_text_line, split

### `set_terminal_shape_new()`
- **Lines:** 0
- **Parameters:** `shape: String`
- **Returns:** `void`
- **Calls:** add_text_line

### `clear_terminal_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, remove_floating_word, keys

### `remove_floating_word_new()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** queue_free, erase, clean_word_connections, has

### `reposition_text_lines_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, tween_property, has, range, size, create_tween

### `toggle_gravity_effects_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `toggle_gravity_effects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `toggle_light_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Color, add_text_line

### `toggle_dimension_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_text_line

### `remove_command_character_new()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, length, update_command_line

### `_process_new()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** look_at, update_letter_visuals

### `_process_old()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** look_at, update_letter_visuals

### `_process_new_v1()`
- **Lines:** 0
- **Parameters:** `_delta`
- **Returns:** `void`
- **Calls:** _navigate_history, is_action_just_pressed, size, has_focus, toggle_console

### `process_terminal_command_()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `process_grid_command()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `process_shape_command()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `process_command_add()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** call_deferred, add_text_line, clear_terminal, has, toggle_gravity_effects, begins_with, size, split

### `process_command_neww()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** call_deferred, add_text_line, clear_terminal, has, toggle_gravity_effects, begins_with, size, split

### `process_keywords_new()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** append, has, split

### `_inpu()`
- **Lines:** 0
- **Parameters:** `event`
- **Returns:** `void`
- **Calls:** add_command_character, execute_command, remove_command_character, char, navigate_history

### `_input_old()`
- **Lines:** 0
- **Parameters:** `event`
- **Returns:** `void`
- **Calls:** add_command_character, execute_command, remove_command_character, char, navigate_history

### `clean_word_connections_new()`
- **Lines:** 0
- **Parameters:** `text_key: String`
- **Returns:** `void`
- **Calls:** queue_free, get_meta, remove_at, has_meta, range, size

### `look_at()`
- **Lines:** 0
- **Parameters:** `data0, data_1`
- **Returns:** `void`
- **Calls:** print

### `load_function_network()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `remove_floating_wor()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** queue_free, erase, clean_word_connections, has

### `clean_word_connection()`
- **Lines:** 0
- **Parameters:** `text_key: String`
- **Returns:** `void`
- **Calls:** queue_free, get_meta, remove_at, has_meta, range, size

### `reposition_text_line()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, tween_property, has, range, size, create_tween

### `process_keywords()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** find, add_path_to_network, add_node_to_network, begins_with, split

### `process_function_references()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** substr, process_terminal_command_new, update_command_line, length, has_method, submit_task, process_grid_command, process_shape_command, ends_with, range, size, split

### `process_terminal_command_new()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `register_console_commands()`
- **Lines:** 0
- **Parameters:** `main: Node`
- **Returns:** `void`
- **Calls:** register_command

### `navigate_historyy()`
- **Lines:** 0
- **Parameters:** `direction: int`
- **Returns:** `void`
- **Calls:** update_command_line, clamp, size

### `initialize_3d_terminal()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, Vector3, print

### `_on_input_submitted()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** log_message, execute_command_new, insert, strip_edges, size, pop_back

### `_on_visibility_changed()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** grab_focus, emit_signal
- **Signals:** console_toggled

### `_navigate_history()`
- **Lines:** 0
- **Parameters:** `direction: int`
- **Returns:** `void`
- **Calls:** length, size

### `toggle_console()`
- **Lines:** 5
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** grab_focus

### `execute_command_new_v2()`
- **Lines:** 0
- **Parameters:** `command_text: String`
- **Returns:** `void`
- **Calls:** call, str, log_message, has_method, to_lower, has, emit_signal, slice, size, split
- **Signals:** command_executed

### `log_messag()`
- **Lines:** 0
- **Parameters:** `message: String, type: int = LogType.INFO`
- **Returns:** `void`
- **Calls:** join, emit_signal, print, slice, size, split, get_line_count
- **Signals:** log_added

### `_cmd_hel()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** sort, keys, log_message, has, size

### `_cmd_clea()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`

### `_cmd_history()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** str, range, log_message, size

### `_cmd_echo()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** join

### `_cmd_status()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_system_metrics, str, log_message, has_method

### `_cmd_memory()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** check_memory_state, str, log_message, has_method

### `_cmd_threads()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** log_message, has_method, check_thread_status_type

### `_cmd_create()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** create_new_task, has_method, size

### `_cmd_unload()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** unload_container, has_method, size

### `_cmd_scene()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** size

### `update_command_line_new_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, add_child, queue_free, Vector3, length, create_3d_letter, range

### `update_command_line_ne()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, add_child, queue_free, Vector3, length, create_3d_letter, range

### `navigate_history_new()`
- **Lines:** 0
- **Parameters:** `direction: int`
- **Returns:** `void`
- **Calls:** update_command_line, clamp, size

### `_cmd_statu()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_parse_stats, get_thread_stats, str, get_node_or_null, has_method, size, add_text_line

### `_cmd_load()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** load_file, has_method, size, add_text_line

### `_cmd_creat()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** has_method, size, add_text_line, three_stages_of_creation

### `setup_terminal_containe()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, Vector3, Color

### `setup_material_cach()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, Color

### `register_default_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command

### `update_letter_visuals_ne()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sin, distance_to, get_ticks_msec, Vector3, get_meta, clamp, set_meta, Color, cos, float, has_meta, range, size, pow, int

### `create_floating_text_ne()`
- **Lines:** 0
- **Parameters:** `text: String, position: Vector3`
- **Returns:** `Node3D`
- **Calls:** substr, create_delimiter_instance, new, add_child, get_ticks_msec, sha1_text, str, length, Vector3, set_meta, create_3d_letter, append, range, size, split

### `create_3d_letter_ne()`
- **Lines:** 0
- **Parameters:** `letter: String, position: Vector3`
- **Returns:** `Node3D`
- **Calls:** new, add_child, Vector3, set_meta, Color

### `process_command_ne()`
- **Lines:** 28
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** add_text_line, call, has_method, to_lower, has, emit_signal, slice, size, split
- **Signals:** command_executed


## scripts/jsh_framework/core/JSH_mainframe_database.gd
**Category:** Core Systems
**Functions:** 51

### `update_ram()`
- **Lines:** 0
- **Parameters:** `usage: int`
- **Returns:** `void`
- **Calls:** min

### `update_cpu()`
- **Lines:** 0
- **Parameters:** `usage: float`
- **Returns:** `void`
- **Calls:** min

### `update_nodes()`
- **Lines:** 0
- **Parameters:** `count: int`
- **Returns:** `void`
- **Calls:** min

### `update_file_ops()`
- **Lines:** 0
- **Parameters:** `count: int`
- **Returns:** `void`
- **Calls:** min

### `get_ram_percentage()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `float`
- **Calls:** float

### `get_cpu_percentage()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `float`

### `get_node_percentage()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `float`
- **Calls:** float

### `get_file_percentage()`
- **Lines:** 4
- **Parameters:** ``
- **Returns:** `float`
- **Calls:** float

### `_init()`
- **Lines:** 0
- **Parameters:** `p_name: String, p_type: int, p_execution_time: float = 5.0`
- **Returns:** `void`

### `add_dependency()`
- **Lines:** 0
- **Parameters:** `func_name: String`
- **Returns:** `void`
- **Calls:** append, has

### `set_resource_requirement()`
- **Lines:** 0
- **Parameters:** `resource: String, amount`
- **Returns:** `void`

### `set_error_probability()`
- **Lines:** 0
- **Parameters:** `probability: float`
- **Returns:** `void`
- **Calls:** clamp

### `execute()`
- **Lines:** 8
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** randf

### `_init()`
- **Lines:** 0
- **Parameters:** `p_name: String`
- **Returns:** `void`

### `add_pack()`
- **Lines:** 0
- **Parameters:** `pack_name: String`
- **Returns:** `bool`
- **Calls:** append, size

### `start()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `advance()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** size

### `get_current_pack()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** size

### `reset()`
- **Lines:** 10
- **Parameters:** ``
- **Returns:** `void`

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _build_connection_matrix, _initialize_system, _initialize_corner_indicators, _initialize_functions, _start_turn_system, print, _initialize_mutexes, _initialize_combos

### `_initialize_mutexes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_initialize_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _register_corner_markers, _register_node_path, _update_memory_tracking, print

### `_initialize_functions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _add_process_function, _add_system_function, _add_input_function, _add_memory_function, str, print, _add_render_function, add_dependency, size, _add_file_function

### `_initialize_combos()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, str, add_pack, print, size

### `_initialize_corner_indicators()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_register_node_path()`
- **Lines:** 0
- **Parameters:** `key: String, path: String`
- **Returns:** `bool`
- **Calls:** print, get_node_or_null, emit_signal, push_error
- **Signals:** node_registered

### `_build_connection_matrix()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has, emit_signal
- **Signals:** connection_established

### `_start_turn_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _can_execute_pack, append, _process_turn

### `_can_execute_pack()`
- **Lines:** 0
- **Parameters:** `pack_name: String`
- **Returns:** `bool`
- **Calls:** has

### `_execute_function_pack()`
- **Lines:** 0
- **Parameters:** `pack_name: String`
- **Returns:** `void`
- **Calls:** push_error, unlock, call, has_method, has, lock, print, emit_signal, _update_memory_tracking
- **Signals:** pack_completed

### `_update_memory_tracking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** max, unlock, update_ram, emit_signal, lock, update_nodes
- **Signals:** resource_updated

### `_register_corner_markers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_add_system_function()`
- **Lines:** 0
- **Parameters:** `name: String, execution_time: float = 5.0`
- **Returns:** `void`
- **Calls:** set_resource_requirement, new

### `_add_input_function()`
- **Lines:** 0
- **Parameters:** `name: String, execution_time: float = 2.0`
- **Returns:** `void`
- **Calls:** set_resource_requirement, new

### `_add_file_function()`
- **Lines:** 0
- **Parameters:** `name: String, execution_time: float = 4.0`
- **Returns:** `void`
- **Calls:** set_resource_requirement, new

### `_add_render_function()`
- **Lines:** 0
- **Parameters:** `name: String, execution_time: float = 3.0`
- **Returns:** `void`
- **Calls:** set_resource_requirement, new

### `_add_process_function()`
- **Lines:** 0
- **Parameters:** `name: String, execution_time: float = 4.0`
- **Returns:** `void`
- **Calls:** set_resource_requirement, new

### `_add_memory_function()`
- **Lines:** 0
- **Parameters:** `name: String, execution_time: float = 3.0`
- **Returns:** `void`
- **Calls:** set_resource_requirement, new

### `_execute_init_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_execute_check_resources()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_execute_verify_paths()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_execute_poll_input()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_execute_process_keys()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_execute_handle_mouse()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_execute_load_config()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_execute_parse_data()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_execute_save_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_execute_update_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_execute_render_frame()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_execute_update_corners()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_process_turn()`
- **Lines:** 51
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** call_deferred, _can_execute_pack, str, is_empty, _execute_function_pack, duplicate, has, emit_signal, print, append, clear
- **Signals:** turn_completed


## scripts/jsh_framework/core/JSH_reality_shaders.gd
**Category:** Core Systems
**Functions:** 10

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** load_reality_shader, new, add_child, get_node, get_node_or_null, print

### `_process()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** process_transition

### `load_reality_shader()`
- **Lines:** 0
- **Parameters:** `reality_name`
- **Returns:** `void`
- **Calls:** open, push_error, load, unlock, has, lock, print, emit_signal
- **Signals:** shader_loaded

### `start_transition()`
- **Lines:** 0
- **Parameters:** `from_reality, to_reality`
- **Returns:** `void`
- **Calls:** open, push_error, load, unlock, has, lock, print

### `process_transition()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** unlock, min, finish_transition, lock, get_next_reality

### `finish_transition()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit_signal, load_reality_shader, get_next_reality, print
- **Signals:** transition_complete

### `get_next_reality()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, split, keys

### `create_glitch_effect()`
- **Lines:** 0
- **Parameters:** `parameter, intensity, duration_str`
- **Returns:** `void`
- **Calls:** create_timer, substr, bind, push_error, unlock, str, length, connect, Callable, lock, print, ends_with, get_tree, float

### `remove_glitch_effect()`
- **Lines:** 0
- **Parameters:** `parameter`
- **Returns:** `void`
- **Calls:** unlock, lock, print

### `apply_color_palette()`
- **Lines:** 73
- **Parameters:** `palette_name`
- **Returns:** `void`
- **Calls:** unlock, Color, lock, print


## scripts/jsh_framework/core/container.gd
**Category:** Core Systems
**Functions:** 7

### `_init()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `containter_start_up()`
- **Lines:** 0
- **Parameters:** `con_num, data`
- **Returns:** `void`
- **Calls:** append

### `get_datapoint()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `containter_get_data()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `container_get_additional_datapoints()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `containers_connections()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** append

### `get_containers_connected()`
- **Lines:** 3
- **Parameters:** ``
- **Returns:** `void`


## scripts/jsh_framework/core/data_point.gd
**Category:** Core Systems
**Functions:** 70

### `setup_terminal()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, set_connection_target, connect, jsh_tree_get_node, start

### `terminal_blink_cursor()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** jsh_tree_get_node

### `handle_terminal_key_press()`
- **Lines:** 0
- **Parameters:** `key: String`
- **Returns:** `void`
- **Calls:** update_terminal_display, len

### `handle_terminal_backspace()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_terminal_display, substr, length

### `update_terminal_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** jsh_tree_get_node, Vector3, length

### `history_up()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_terminal_display, size

### `history_down()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_terminal_display, size

### `execute_command()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** strip_edges, push_back, size

### `_init()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `process_delta_fake()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `connect_keyboard_to_field()`
- **Lines:** 0
- **Parameters:** `target_container, target_thing`
- **Returns:** `void`
- **Calls:** create_new_task, get_node_or_null, eight_dimensional_magic

### `receive_keyboard_connection()`
- **Lines:** 0
- **Parameters:** `connection_info`
- **Returns:** `void`
- **Calls:** print

### `on_keyboard_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_text_and_cursor, is_empty

### `set_connection_target()`
- **Lines:** 0
- **Parameters:** `target_container, target_thing, target_datapoint`
- **Returns:** `void`
- **Calls:** get_children, unlock, get_node_or_null, length, jsh_tree_get_node, update_text_and_cursor, update_cursor_position, lock, print, size, split

### `finishied_setting_up_datapoint()`
- **Lines:** 0
- **Parameters:** `my_name`
- **Returns:** `void`
- **Calls:** get_parent

### `check_amount_of_container()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_parent

### `check_state_of_dictionary_and_three_ints_of_doom()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, duplicate, lock, print, append

### `new_datapoint_layer_system()`
- **Lines:** 0
- **Parameters:** `deep_state_copy_of_apples`
- **Returns:** `void`
- **Calls:** unlock, lock, prepare_to_move_things_around

### `check_dictionary_from_datapoint()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, lock, duplicate

### `check_if_datapoint_moved_once()`
- **Lines:** 19
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, lock

### `initialize_loading_file()`
- **Lines:** 0
- **Parameters:** `file_name`
- **Returns:** `void`
- **Calls:** check_all_settings_data, str, settings_labels_start, print, append

### `settings_labels_start()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, unlock, has, lock, print, size

### `receive_a_message()`
- **Lines:** 0
- **Parameters:** `message`
- **Returns:** `void`
- **Calls:** append, print

### `singular_lines_added()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `change_dual_text()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, str, has, lock, size

### `connect_keyboard_string()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `setup_text_handling()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** setup_cursor_timer, add_cursor

### `add_cursor()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, get_parent, add_child, unlock, Vector3, get_node, update_cursor_position, Color, lock

### `setup_cursor_timer()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, start, new, add_child

### `blink_cursor()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, lock

### `handle_key_press()`
- **Lines:** 0
- **Parameters:** `key: String`
- **Returns:** `void`
- **Calls:** unlock, is_empty, update_text_and_cursor, len, insert, lock, update_connected_target

### `handle_backspace()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, is_empty, update_text_and_cursor, erase, lock, update_connected_target

### `return_string_from_keyboards()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, get_node_or_null, is_empty, jsh_tree_get_node, has, print, strip_edges, size, split, save_settings_data

### `find_label_in_node()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `Label3D`
- **Calls:** get_children, find_label_in_node

### `update_connected_target()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, get_node_or_null, size, print, NodePath, split

### `update_text_and_cursor()`
- **Lines:** 0
- **Parameters:** `key`
- **Returns:** `void`
- **Calls:** get_text_width, first_dimensional_magic, create_new_task, set_text, get_parent, get_node, unlock, is_empty, update_cursor_position, lock, append, pop_back

### `update_text_cursor_after()`
- **Lines:** 0
- **Parameters:** `text_label`
- **Returns:** `void`
- **Calls:** get_text_width, update_cursor_position

### `update_cursor_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, Vector3, lock

### `get_text_width()`
- **Lines:** 0
- **Parameters:** `text_label: Label3D`
- **Returns:** `float`
- **Calls:** get_aabb

### `change_numbers_letters()`
- **Lines:** 0
- **Parameters:** `scene_to_pull`
- **Returns:** `void`
- **Calls:** print

### `shift_keyboard()`
- **Lines:** 0
- **Parameters:** `scene_to_pull`
- **Returns:** `void`
- **Calls:** print

### `undo_a_character()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** handle_backspace

### `write_on_keyboard()`
- **Lines:** 0
- **Parameters:** `data_of_key_pressed`
- **Returns:** `void`
- **Calls:** print

### `power_up_data_point()`
- **Lines:** 0
- **Parameters:** `datapoint_name, datapoint_number, array_of_data`
- **Returns:** `void`
- **Calls:** append, str, int

### `datapoint_check()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, clear

### `datapoint_assign_priority()`
- **Lines:** 0
- **Parameters:** `send_priority_number`
- **Returns:** `void`
- **Calls:** int

### `add_thing_to_datapoint()`
- **Lines:** 0
- **Parameters:** `array_from_main`
- **Returns:** `void`
- **Calls:** append

### `datapoint_max_things_number_setter()`
- **Lines:** 3
- **Parameters:** `sended_max_number`
- **Returns:** `void`
- **Calls:** int

### `upload_scenes_frames()`
- **Lines:** 0
- **Parameters:** `header_line, information_lines`
- **Returns:** `void`
- **Calls:** unlock, duplicate, lock, print, append, prepare_to_move_things_around, size

### `upload_interactions()`
- **Lines:** 0
- **Parameters:** `header_line, information_lines`
- **Returns:** `void`
- **Calls:** unlock, duplicate, lock, print, append

### `setup_main_reference()`
- **Lines:** 0
- **Parameters:** `main_ref: Node`
- **Returns:** `void`

### `check_all_things_inside_datapoint()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `get_datapoint_info_for_containter_connection()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `check_things_in_scene()`
- **Lines:** 0
- **Parameters:** `scene_we_wanna`
- **Returns:** `Array`
- **Calls:** append, get_parent

### `scene_to_set_number_later()`
- **Lines:** 0
- **Parameters:** `number_int_eh`
- **Returns:** `void`
- **Calls:** unlock, prepare_to_move_things_around, lock, print

### `set_maximum_interaction_number()`
- **Lines:** 0
- **Parameters:** `mode : String, amount : int`
- **Returns:** `void`

### `thing_interaction()`
- **Lines:** 0
- **Parameters:** `thing`
- **Returns:** `void`
- **Calls:** unlock, duplicate, check_possible_interactions, has, lock, print

### `check_possible_interactions()`
- **Lines:** 0
- **Parameters:** `thing`
- **Returns:** `void`
- **Calls:** do_action_found, check_possible_actions, print

### `check_possible_actions()`
- **Lines:** 0
- **Parameters:** `thing`
- **Returns:** `void`
- **Calls:** unlock, duplicate, lock, print

### `do_action_found()`
- **Lines:** 0
- **Parameters:** `action_page, thing_name`
- **Returns:** `void`
- **Calls:** create_new_task, move_things_around, get_parent, return_string_from_keyboards, str, sixth_dimensional_magic, callv, jsh_tree_get_node, eight_dimensional_magic, fifth_dimensional_magic, print, append, size, split, int

### `safe_get()`
- **Lines:** 0
- **Parameters:** `array: Array, indices: Array, default = null`
- **Returns:** `Variant`
- **Calls:** typeof, size

### `create_new_task()`
- **Lines:** 0
- **Parameters:** `function_name: String, data`
- **Returns:** `void`
- **Calls:** get_ticks_msec, str, submit_task

### `create_new_task_empty()`
- **Lines:** 0
- **Parameters:** `function_name: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, str, submit_task_unparameterized

### `lets_move_them_again()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `the_checking_stuff()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_instance_valid, unlock, str, Vector3, is_empty, duplicate, get_path, lock, print, append, float, size, split, int

### `prepare_to_move_things_around()`
- **Lines:** 0
- **Parameters:** `scene_to_set`
- **Returns:** `void`
- **Calls:** move_things_around

### `move_things_around()`
- **Lines:** 0
- **Parameters:** `scene_number: int`
- **Returns:** `void`
- **Calls:** get_parent, unlock, the_fourth_dimensional_magic, is_empty, lock, print, append, size, split, Vector3, check_multi_stuff, prepare_data_for_unloading, get_path, float, seventh_dimensional_magic, is_instance_valid, str, change_dual_text, int, duplicate

### `check_multi_stuff()`
- **Lines:** 0
- **Parameters:** `scene_number`
- **Returns:** `void`
- **Calls:** move_things_around, unlock, lock, print, append, range, size

### `prepare_data_for_unloading()`
- **Lines:** 0
- **Parameters:** `scene_stuff`
- **Returns:** `void`
- **Calls:** unlock, print, fifth_dimensional_magic, lock, append

### `some_snake_game()`
- **Lines:** 202
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sixth_dimensional_magic, eighth_dimensional_magic, fifth_dimensional_magic


## scripts/jsh_framework/core/function_metadata.gd
**Category:** Core Systems
**Functions:** 7

### `get_function_metadata()`
- **Lines:** 0
- **Parameters:** `script_path: String, function_name: String`
- **Returns:** `Dictionary`
- **Calls:** has, duplicate

### `get_category_functions()`
- **Lines:** 0
- **Parameters:** `category: String`
- **Returns:** `Array`
- **Calls:** append

### `get_mutex_dependencies()`
- **Lines:** 0
- **Parameters:** `script_path: String, function_name: String`
- **Returns:** `Array`
- **Calls:** get_function_metadata

### `get_global_variables()`
- **Lines:** 0
- **Parameters:** `script_path: String, function_name: String`
- **Returns:** `Array`
- **Calls:** get_function_metadata

### `get_function_dependencies()`
- **Lines:** 0
- **Parameters:** `script_path: String, function_name: String`
- **Returns:** `Array`
- **Calls:** get_function_metadata

### `generate_report()`
- **Lines:** 0
- **Parameters:** `script_path: String = "", category: String = ""`
- **Returns:** `String`
- **Calls:** _generate_function_report, get_category_functions, has, is_empty

### `_generate_function_report()`
- **Lines:** 29
- **Parameters:** `script_path: String, function_name: String`
- **Returns:** `String`
- **Calls:** get_function_metadata, str, length, is_empty


## scripts/jsh_framework/core/functions_database.gd
**Category:** Core Systems
**Functions:** 18

### `register_command()`
- **Lines:** 0
- **Parameters:** `command_name: String, target_node: Node, function_name: String`
- **Returns:** `void`

### `create_chain()`
- **Lines:** 0
- **Parameters:** `chain_name: String, commands: Array`
- **Returns:** `void`

### `execute_chain()`
- **Lines:** 41
- **Parameters:** `chain_name: String, args = null`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, call, has

### `_init()`
- **Lines:** 0
- **Parameters:** `func_name: String`
- **Returns:** `void`
- **Calls:** analyze_name

### `analyze_name()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, has, get_char_type

### `get_char_type()`
- **Lines:** 14
- **Parameters:** `c: String`
- **Returns:** `int`
- **Calls:** unicode_at

### `add_function()`
- **Lines:** 0
- **Parameters:** `func_text: String`
- **Returns:** `void`
- **Calls:** count_parameters, new, extract_function_name, extract_return_type, is_empty, size, split

### `extract_function_name()`
- **Lines:** 0
- **Parameters:** `declaration: String`
- **Returns:** `String`
- **Calls:** substr, strip_edges, find

### `count_parameters()`
- **Lines:** 0
- **Parameters:** `declaration: String`
- **Returns:** `int`
- **Calls:** substr, find, is_empty, strip_edges, size, split

### `extract_return_type()`
- **Lines:** 0
- **Parameters:** `declaration: String`
- **Returns:** `String`
- **Calls:** substr, length, find, strip_edges

### `get_function_analysis()`
- **Lines:** 0
- **Parameters:** `func_name: String`
- **Returns:** `FunctionAnalysis`
- **Calls:** get

### `print_analysis()`
- **Lines:** 0
- **Parameters:** `func_name: String`
- **Returns:** `String`
- **Calls:** get_function_analysis, get_type_name

### `get_type_name()`
- **Lines:** 0
- **Parameters:** `type_code: int`
- **Returns:** `String`

### `analyze_function_requirements()`
- **Lines:** 0
- **Parameters:** `function_name: String`
- **Returns:** `Dictionary`
- **Calls:** get_parent, has_node, has, append, NodePath, split

### `check_function_compatibility()`
- **Lines:** 0
- **Parameters:** `function_name: String`
- **Returns:** `Dictionary`
- **Calls:** append, get_dependency_chain, is_empty, get

### `get_dependency_chain()`
- **Lines:** 0
- **Parameters:** `function_name: String, chain: Array = []`
- **Returns:** `Dictionary`
- **Calls:** duplicate, has, append, get_dependency_chain, split

### `get_function_usage()`
- **Lines:** 0
- **Parameters:** `var_name: String`
- **Returns:** `Array`
- **Calls:** append

### `generate_function_report()`
- **Lines:** 34
- **Parameters:** `function_name: String`
- **Returns:** `String`
- **Calls:** check_function_compatibility, str, length, is_empty, has


## scripts/jsh_framework/core/godot_timers_system.gd
**Category:** Core Systems
**Functions:** 16

### `_init()`
- **Lines:** 8
- **Parameters:** `p_timer: Timer, p_duration: float, p_callback: Callable = Callable(), p_user_data: Variant = null`
- **Returns:** `void`

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, start_timer, emit_signal
- **Signals:** interval_tick

### `create_timer()`
- **Lines:** 0
- **Parameters:** `timer_id: String, duration: float, callback: Callable = Callable(), repeating: bool = false, user_data: Variant = null`
- **Returns:** `Error`
- **Calls:** new, bind, add_child, connect, push_warning, has

### `start_timer()`
- **Lines:** 0
- **Parameters:** `timer_id: String`
- **Returns:** `Error`
- **Calls:** start, has, emit_signal, push_warning
- **Signals:** timer_started

### `stop_timer()`
- **Lines:** 0
- **Parameters:** `timer_id: String`
- **Returns:** `Error`
- **Calls:** has, emit_signal, stop
- **Signals:** timer_stopped

### `pause_timer()`
- **Lines:** 0
- **Parameters:** `timer_id: String`
- **Returns:** `Error`
- **Calls:** has, emit_signal
- **Signals:** timer_paused

### `resume_timer()`
- **Lines:** 0
- **Parameters:** `timer_id: String`
- **Returns:** `Error`
- **Calls:** has, emit_signal
- **Signals:** timer_resumed

### `remove_timer()`
- **Lines:** 0
- **Parameters:** `timer_id: String`
- **Returns:** `Error`
- **Calls:** queue_free, stop, erase, has, append

### `clear_all_timers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** remove_timer, keys

### `get_time_left()`
- **Lines:** 0
- **Parameters:** `timer_id: String`
- **Returns:** `float`
- **Calls:** has

### `get_progress()`
- **Lines:** 0
- **Parameters:** `timer_id: String`
- **Returns:** `float`
- **Calls:** get_time_left, has

### `is_timer_active()`
- **Lines:** 0
- **Parameters:** `timer_id: String`
- **Returns:** `bool`
- **Calls:** has

### `is_timer_paused()`
- **Lines:** 0
- **Parameters:** `timer_id: String`
- **Returns:** `bool`
- **Calls:** has

### `get_active_timers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array[String]`
- **Calls:** append, is_timer_active

### `_on_timer_timeout()`
- **Lines:** 0
- **Parameters:** `timer_id: String`
- **Returns:** `void`
- **Calls:** call, is_valid, erase, start, has, emit_signal, remove_timer
- **Signals:** timer_completed

### `_exit_tree()`
- **Lines:** 3
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear_all_timers


## scripts/jsh_framework/core/init_function.gd
**Category:** Core Systems
**Functions:** 2

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_process()`
- **Lines:** 26
- **Parameters:** `delta: float`
- **Returns:** `void`


## scripts/jsh_framework/core/jsh_data_splitter.gd
**Category:** Core Systems
**Functions:** 20

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** initialize_parser, check_all_settings_data

### `check_all_things()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `initialize_parser()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_empty, push_error

### `process_directory()`
- **Lines:** 0
- **Parameters:** `path: String = ""`
- **Returns:** `Dictionary`
- **Calls:** path_join, process_file, open, get_next, unlock, is_empty, get_extension, duplicate, has, lock, emit_signal, append, list_dir_end, list_dir_begin
- **Signals:** parsing_completed

### `process_file()`
- **Lines:** 0
- **Parameters:** `file_path: String`
- **Returns:** `bool`
- **Calls:** open, get_as_text, file_exists, unlock, is_empty, update_parse_stats, lock, parse_jsh_file

### `update_parse_stats()`
- **Lines:** 0
- **Parameters:** `success: bool, file_path: String`
- **Returns:** `void`

### `get_parse_stats()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** unlock, lock, duplicate

### `parse_jsh_file()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `Dictionary`
- **Calls:** is_empty, parse_block_metadata, trim_suffix, has, trim_prefix, begins_with, append, size, split

### `parse_block_metadata()`
- **Lines:** 0
- **Parameters:** `metadata_str: String`
- **Returns:** `Dictionary`
- **Calls:** strip_edges, size, split

### `validate_file_format()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `Dictionary`
- **Calls:** begins_with, append, contains

### `collect_system_stats()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** max, float

### `analyze_file_content()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `Dictionary`
- **Calls:** contains, length, has, append, split

### `split_by_rules()`
- **Lines:** 0
- **Parameters:** `content: String, level: String`
- **Returns:** `Array`
- **Calls:** append_array, has, split

### `parse_function_data()`
- **Lines:** 0
- **Parameters:** `function_content: String`
- **Returns:** `Dictionary`
- **Calls:** get_function_name, get_function_body, analyze_file_content, get_function_inputs

### `get_function_name()`
- **Lines:** 0
- **Parameters:** `function_content: String`
- **Returns:** `String`
- **Calls:** begins_with, substr, strip_edges, split

### `get_function_inputs()`
- **Lines:** 0
- **Parameters:** `function_content: String`
- **Returns:** `Array`
- **Calls:** begins_with, append, strip_edges, size, split

### `get_function_body()`
- **Lines:** 0
- **Parameters:** `function_content: String`
- **Returns:** `String`
- **Calls:** begins_with, append, join, split

### `process_with_limits()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `Dictionary`
- **Calls:** append, size, split

### `generate_ender_version()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `String`
- **Calls:** append, join, strip_edges, split

### `compare_versions()`
- **Lines:** 22
- **Parameters:** `old_content: String, new_content: String`
- **Returns:** `Dictionary`
- **Calls:** append, has, parse_jsh_file, range, size


## scripts/jsh_framework/core/jsh_database_system.gd
**Category:** Core Systems
**Functions:** 45

### `_init()`
- **Lines:** 0
- **Parameters:** `func_name: String`
- **Returns:** `void`
- **Calls:** analyze_name

### `analyze_name()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, has, get_char_type

### `get_char_type()`
- **Lines:** 13
- **Parameters:** `c: String`
- **Returns:** `int`
- **Calls:** unicode_at

### `add_function()`
- **Lines:** 0
- **Parameters:** `func_text: String`
- **Returns:** `void`
- **Calls:** count_parameters, new, extract_function_name, extract_return_type, is_empty, size, split

### `extract_function_name()`
- **Lines:** 0
- **Parameters:** `declaration: String`
- **Returns:** `String`
- **Calls:** substr, strip_edges, find

### `count_parameters()`
- **Lines:** 0
- **Parameters:** `declaration: String`
- **Returns:** `int`
- **Calls:** substr, find, is_empty, strip_edges, size, split

### `extract_return_type()`
- **Lines:** 0
- **Parameters:** `declaration: String`
- **Returns:** `String`
- **Calls:** substr, length, find, strip_edges

### `get_function_analysis()`
- **Lines:** 0
- **Parameters:** `func_name: String`
- **Returns:** `FunctionAnalysis`
- **Calls:** get

### `print_analysis()`
- **Lines:** 0
- **Parameters:** `func_name: String`
- **Returns:** `String`
- **Calls:** get_function_analysis, get_type_name

### `get_type_name()`
- **Lines:** 0
- **Parameters:** `type_code: int`
- **Returns:** `String`

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** initialize_parser, check_all_settings_data

### `check_all_things()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `initialize_parser()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_empty, push_error

### `collect_system_stats()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** max, float

### `get_parse_stats()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** unlock, lock, duplicate

### `register_node()`
- **Lines:** 0
- **Parameters:** `node, identifier`
- **Returns:** `void`

### `connect_nodes()`
- **Lines:** 0
- **Parameters:** `sender_id, receiver_id`
- **Returns:** `void`
- **Calls:** append

### `send_signal()`
- **Lines:** 0
- **Parameters:** `sender_id, action`
- **Returns:** `void`
- **Calls:** receive_action

### `get_function_metadata()`
- **Lines:** 0
- **Parameters:** `script_path: String, function_name: String`
- **Returns:** `Dictionary`
- **Calls:** has, duplicate

### `get_category_functions()`
- **Lines:** 0
- **Parameters:** `category: String`
- **Returns:** `Array`
- **Calls:** append

### `get_mutex_dependencies()`
- **Lines:** 0
- **Parameters:** `script_path: String, function_name: String`
- **Returns:** `Array`
- **Calls:** get_function_metadata

### `get_global_variables()`
- **Lines:** 0
- **Parameters:** `script_path: String, function_name: String`
- **Returns:** `Array`
- **Calls:** get_function_metadata

### `get_function_dependencies()`
- **Lines:** 0
- **Parameters:** `script_path: String, function_name: String`
- **Returns:** `Array`
- **Calls:** get_function_metadata

### `generate_report()`
- **Lines:** 0
- **Parameters:** `script_path: String = "", category: String = ""`
- **Returns:** `String`
- **Calls:** _generate_function_report, get_category_functions, has, is_empty

### `_generate_function_report()`
- **Lines:** 0
- **Parameters:** `script_path: String, function_name: String`
- **Returns:** `String`
- **Calls:** get_function_metadata, str, length, is_empty

### `analyze_function_requirements()`
- **Lines:** 0
- **Parameters:** `function_name: String`
- **Returns:** `Dictionary`
- **Calls:** get_parent, has_node, has, append, NodePath, split

### `check_function_compatibility()`
- **Lines:** 0
- **Parameters:** `function_name: String`
- **Returns:** `Dictionary`
- **Calls:** append, get_dependency_chain, is_empty, get

### `get_dependency_chain()`
- **Lines:** 0
- **Parameters:** `function_name: String, chain: Array = []`
- **Returns:** `Dictionary`
- **Calls:** duplicate, has, append, get_dependency_chain, split

### `get_function_usage()`
- **Lines:** 0
- **Parameters:** `var_name: String`
- **Returns:** `Array`
- **Calls:** append

### `generate_function_report()`
- **Lines:** 0
- **Parameters:** `function_name: String`
- **Returns:** `String`
- **Calls:** check_function_compatibility, str, length, is_empty, has

### `process_directory()`
- **Lines:** 0
- **Parameters:** `path: String = ""`
- **Returns:** `Dictionary`
- **Calls:** path_join, process_file, open, get_next, unlock, is_empty, get_extension, duplicate, has, lock, emit_signal, append, list_dir_end, list_dir_begin
- **Signals:** parsing_completed

### `process_file()`
- **Lines:** 0
- **Parameters:** `file_path: String`
- **Returns:** `bool`
- **Calls:** open, get_as_text, file_exists, unlock, is_empty, update_parse_stats, lock, parse_jsh_file

### `update_parse_stats()`
- **Lines:** 0
- **Parameters:** `success: bool, file_path: String`
- **Returns:** `void`

### `parse_jsh_file()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `Dictionary`
- **Calls:** is_empty, parse_block_metadata, trim_suffix, has, trim_prefix, begins_with, append, size, split

### `parse_block_metadata()`
- **Lines:** 0
- **Parameters:** `metadata_str: String`
- **Returns:** `Dictionary`
- **Calls:** strip_edges, size, split

### `validate_file_format()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `Dictionary`
- **Calls:** begins_with, append, contains

### `analyze_file_content()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `Dictionary`
- **Calls:** contains, length, has, append, split

### `split_by_rules()`
- **Lines:** 0
- **Parameters:** `content: String, level: String`
- **Returns:** `Array`
- **Calls:** append_array, has, split

### `parse_function_data()`
- **Lines:** 0
- **Parameters:** `function_content: String`
- **Returns:** `Dictionary`
- **Calls:** get_function_name, get_function_body, analyze_file_content, get_function_inputs

### `get_function_name()`
- **Lines:** 0
- **Parameters:** `function_content: String`
- **Returns:** `String`
- **Calls:** begins_with, substr, strip_edges, split

### `get_function_inputs()`
- **Lines:** 0
- **Parameters:** `function_content: String`
- **Returns:** `Array`
- **Calls:** begins_with, append, strip_edges, size, split

### `get_function_body()`
- **Lines:** 0
- **Parameters:** `function_content: String`
- **Returns:** `String`
- **Calls:** begins_with, append, join, split

### `process_with_limits()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `Dictionary`
- **Calls:** append, size, split

### `generate_ender_version()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `String`
- **Calls:** append, join, strip_edges, split

### `compare_versions()`
- **Lines:** 22
- **Parameters:** `old_content: String, new_content: String`
- **Returns:** `Dictionary`
- **Calls:** append, has, parse_jsh_file, range, size


## scripts/jsh_framework/core/jsh_digital_earthlings.gd
**Category:** Core Systems
**Functions:** 62

### `_ready_add()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print, get_node_or_null, initialize_grid

### `initialize_grid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, create_axis_labels, add_child, create_info_panel, create_title, create_grid_cells, append, range

### `set_grid_size()`
- **Lines:** 0
- **Parameters:** `width, height`
- **Returns:** `void`
- **Calls:** clear_grid, initialize_grid

### `set_data()`
- **Lines:** 0
- **Parameters:** `data_array`
- **Returns:** `void`
- **Calls:** max, track_data_flow, has_method, min, update_grid_visualization, print, emit_signal, range, size
- **Signals:** grid_updated

### `update_cell_value()`
- **Lines:** 0
- **Parameters:** `x, y, value`
- **Returns:** `void`
- **Calls:** record_interaction, has_method, update_cell_visualization

### `highlight_cell()`
- **Lines:** 0
- **Parameters:** `x, y, highlight = true`
- **Returns:** `void`
- **Calls:** Vector3

### `set_title()`
- **Lines:** 0
- **Parameters:** `title_text`
- **Returns:** `void`

### `set_data_properties()`
- **Lines:** 0
- **Parameters:** `label, units`
- **Returns:** `void`
- **Calls:** update_info_panel

### `animate_to_new_data()`
- **Lines:** 0
- **Parameters:** `new_data, duration = 1.0`
- **Returns:** `void`
- **Calls:** set_trans, set_delay, tween_callback, tween_property, set_data, set_ease, lerp, append, range, create_tween

### `generate_wave_pattern()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sin, get_ticks_msec, cos, append, range, float

### `generate_ripple_pattern()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sin, get_ticks_msec, sqrt, append, range

### `generate_random_pattern()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, get_ticks_msec, get_noise_2d, append, int, range, get_unix_time_from_system

### `generate_gradient_pattern()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, float, range

### `generate_mountain_pattern()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** float, max, new, get_noise_2d, sqrt, append, int, range, pow, get_unix_time_from_system

### `create_grid_cells()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_cell, append, range, add_child

### `create_cell()`
- **Lines:** 0
- **Parameters:** `x, y`
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, has_method, connect, get_spectrum_color, _on_cell_input_event, Color, _on_cell_mouse_entered, _on_cell_mouse_exited

### `create_axis_labels()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, str, Vector3, append, range

### `create_title()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `create_info_panel()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, create_color_legend, new, add_child, Vector3, Color

### `create_color_legend()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, Vector3, has_method, get_spectrum_color, Color, float, range, lerp

### `update_grid_visualization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_info_panel, range, update_cell_visualization

### `update_cell_visualization()`
- **Lines:** 0
- **Parameters:** `x, y`
- **Returns:** `void`
- **Calls:** max, get_node, Vector3, has_method, get_spectrum_color, Color, lerp

### `update_info_panel()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, range

### `clear_grid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, get_children

### `_on_cell_input_event()`
- **Lines:** 0
- **Parameters:** `x, y, camera, event, position, normal, shape_idx`
- **Returns:** `void`
- **Calls:** record_interaction, has_method, emit_signal
- **Signals:** cell_selected

### `_on_cell_mouse_entered()`
- **Lines:** 0
- **Parameters:** `x, y`
- **Returns:** `void`
- **Calls:** get_node, highlight_cell, Color

### `_on_cell_mouse_exited()`
- **Lines:** 0
- **Parameters:** `x, y`
- **Returns:** `void`
- **Calls:** get_node, highlight_cell, Color

### `setup_main_reference()`
- **Lines:** 0
- **Parameters:** `main_ref`
- **Returns:** `void`
- **Calls:** update_grid_visualization

### `create_from_records()`
- **Lines:** 0
- **Parameters:** `record_map_id, record_index`
- **Returns:** `void`
- **Calls:** generate_wave_pattern, Vector3, get_node_or_null, set_title, set_data, has, print, float, size, split

### `_ready_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `initialize_integration()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, initialize_reality_systems, connect, initialize_command_system, register_records, print, get_tree

### `register_records()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `initialize_reality_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_new_task, has_method, print

### `initialize_command_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** setup_command_processor, print

### `setup_command_processor()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_meta

### `initialize_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, create_new_task, has_method, connect, print, get_tree

### `show_welcome_message()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** find_interface_text_node, print

### `find_interface_text_node()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null

### `parse_command()`
- **Lines:** 0
- **Parameters:** `command_text: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, call, get_meta, has_method, to_lower, emit, has, slice, append, strip_edges, size, split

### `_cmd_help()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** find_interface_text_node, print

### `_cmd_create()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** first_dimensional_magic, has_method, range, size

### `_cmd_transform()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** has_method, range, size, the_fourth_dimensional_magic

### `_cmd_remember()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** slice, join, size

### `_cmd_shift()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** str, to_lower, has, shift_reality, size

### `_cmd_speak()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** has_method, join, slice, size, eight_dimensional_magic

### `_cmd_glitch()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** size, create_glitch_effect

### `_cmd_spawn()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** first_dimensional_magic, Vector3, has_method, size

### `_cmd_guardian()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** join, Vector3, size

### `_cmd_reality()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** find_interface_text_node, to_upper, print

### `_cmd_deja_vu()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`

### `shift_reality()`
- **Lines:** 0
- **Parameters:** `new_reality`
- **Returns:** `void`
- **Calls:** create_timer, toggle_reality_containers, get_node_or_null, has_method, sixth_dimensional_magic, connect, get_surface_material, emit, to_upper, has, print, get_tree, get_reality_color

### `toggle_reality_containers()`
- **Lines:** 0
- **Parameters:** `old_reality, new_reality`
- **Returns:** `void`
- **Calls:** get_node_or_null

### `get_reality_color()`
- **Lines:** 0
- **Parameters:** `reality`
- **Returns:** `void`
- **Calls:** Color

### `create_glitch_effect()`
- **Lines:** 0
- **Parameters:** `parameter, intensity, duration_str`
- **Returns:** `void`
- **Calls:** substr, apply_visual_glitch, apply_audio_glitch, apply_physics_glitch, length, min, ends_with, float, int

### `apply_visual_glitch()`
- **Lines:** 0
- **Parameters:** `intensity, duration`
- **Returns:** `void`
- **Calls:** create_timer, the_fourth_dimensional_magic, has_method, connect, print, get_tree

### `apply_physics_glitch()`
- **Lines:** 0
- **Parameters:** `intensity, duration`
- **Returns:** `void`
- **Calls:** randf, Vector2

### `apply_audio_glitch()`
- **Lines:** 0
- **Parameters:** `intensity, duration`
- **Returns:** `void`
- **Calls:** str, print

### `handle_snake_menu_interaction()`
- **Lines:** 0
- **Parameters:** `option, difficulty = "normal"`
- **Returns:** `void`
- **Calls:** display_high_scores, launch_snake_game, print

### `launch_snake_game()`
- **Lines:** 0
- **Parameters:** `difficulty`
- **Returns:** `void`
- **Calls:** get_node_or_null, print

### `display_high_scores()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, print

### `process_snake_button_click()`
- **Lines:** 0
- **Parameters:** `button_name`
- **Returns:** `void`
- **Calls:** handle_snake_menu_interaction, get_current_menu_context

### `get_current_menu_context()`
- **Lines:** 16
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_meta, has_meta, get_node_or_null


## scripts/jsh_framework/core/jsh_marching_shapes_system.gd
**Category:** Core Systems
**Functions:** 61

### `_ready_add()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** initialize_scalar_field, get_node_or_null, setup_nodes, print, generate_mesh

### `_process_add()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** update_scalar_field, generate_mesh

### `_ready_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, create_data_grid, connect, setup_task_manager, create_pattern_controls, start

### `_process_old()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`

### `_ready_old_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print, get_node_or_null, initialize_grid

### `add_quad_seven()`
- **Lines:** 0
- **Parameters:** `vertices, indices, v1, v2, v3, v4, v5`
- **Returns:** `void`
- **Calls:** append, size, print

### `setup_nodes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child

### `initialize_scalar_field()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, range, get_noise_value

### `update_scalar_field()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** range, get_noise_value

### `get_noise_value()`
- **Lines:** 0
- **Parameters:** `x, y`
- **Returns:** `void`
- **Calls:** float, get_noise_2d

### `generate_mesh()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, PackedVector3Array, generate_normals, append, size, lerp_vertex, track_data_flow, Vector3, has_method, create_from, add_pentagon_nine, add_triangle, add_surface_from_arrays, resize, add_quad_seven, commit, add_wireframe_line, range, add_quad, emit_signal, PackedInt32Array
- **Signals:** mesh_generated

### `set_iso_level()`
- **Lines:** 0
- **Parameters:** `value`
- **Returns:** `void`
- **Calls:** clamp, emit_signal, generate_mesh
- **Signals:** contour_changed

### `lerp_vertex()`
- **Lines:** 0
- **Parameters:** `x1, y1, x2, y2, val1, val2`
- **Returns:** `void`
- **Calls:** Vector3, lerp, abs

### `add_triangle()`
- **Lines:** 0
- **Parameters:** `vertices, indices, v1, v2, v3`
- **Returns:** `void`
- **Calls:** append, size

### `add_quad()`
- **Lines:** 0
- **Parameters:** `vertices, indices, v1, v2, v3, v4`
- **Returns:** `void`
- **Calls:** append, size

### `add_pentagon_nine()`
- **Lines:** 0
- **Parameters:** `vertices, indices, v1, v2, v3, v4, v5, v6, v7`
- **Returns:** `void`
- **Calls:** append, size

### `add_pentagon()`
- **Lines:** 0
- **Parameters:** `vertices, indices, v1, v2, v3, v4, v5`
- **Returns:** `void`
- **Calls:** append, size

### `add_wireframe_line()`
- **Lines:** 0
- **Parameters:** `wireframe_vertices, start, end`
- **Returns:** `void`
- **Calls:** append

### `set_noise_parameters()`
- **Lines:** 0
- **Parameters:** `scale, octaves, persistence, lacunarity, seed_value`
- **Returns:** `void`
- **Calls:** generate_mesh, initialize_scalar_field

### `set_animation()`
- **Lines:** 0
- **Parameters:** `enabled, speed = 1.0`
- **Returns:** `void`

### `set_wireframe()`
- **Lines:** 0
- **Parameters:** `enabled`
- **Returns:** `void`
- **Calls:** generate_mesh

### `set_grid_points()`
- **Lines:** 0
- **Parameters:** `enabled`
- **Returns:** `void`
- **Calls:** generate_mesh

### `setup_main_reference()`
- **Lines:** 0
- **Parameters:** `main_ref`
- **Returns:** `void`
- **Calls:** get_spectrum_color, has_method

### `generate_gradient_pattern()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** float, range

### `generate_mountain_pattern()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** max, new, get_noise_2d, sqrt, int, range, float, pow, get_unix_time_from_system

### `generate_random_pattern()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** new, get_noise_2d, int, range, get_unix_time_from_system

### `setup_task_manager()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, get_node_or_null, print, get_tree

### `create_data_grid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** setup_main_reference, new, add_child, Vector3, set_data_properties, connect, set_title, set_data, generate_data

### `create_pattern_controls()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, keys, Vector3, create_pattern_button, range, size

### `create_pattern_button()`
- **Lines:** 0
- **Parameters:** `label_text, position, pattern_index`
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, Vector3, connect, Color, _on_pattern_selected

### `_on_pattern_selected()`
- **Lines:** 0
- **Parameters:** `pattern_index`
- **Returns:** `void`
- **Calls:** track_data_flow, keys, has_method, set_title, animate_to_new_data, generate_data

### `_on_update_timer()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_data, generate_data

### `_on_cell_selected()`
- **Lines:** 0
- **Parameters:** `x, y, value`
- **Returns:** `void`
- **Calls:** new, add_child, connect, highlight_cell, start, print

### `generate_data()`
- **Lines:** 0
- **Parameters:** `pattern`
- **Returns:** `void`
- **Calls:** generate_ripple_pattern, generate_mountain_pattern, generate_wave_pattern, generate_gradient_pattern, generate_random_pattern, append, range

### `generate_gradient_pattern_old()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `generate_mountain_pattern_old()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `generate_wave_pattern()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** sin, float, range, cos

### `generate_ripple_pattern()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** sin, range, sqrt

### `generate_random_pattern_old()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** range, print

### `initialize_grid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, create_axis_labels, add_child, create_info_panel, create_title, create_grid_cells, append, range

### `set_grid_size()`
- **Lines:** 0
- **Parameters:** `width, height`
- **Returns:** `void`
- **Calls:** clear_grid, initialize_grid

### `set_data()`
- **Lines:** 0
- **Parameters:** `data_array`
- **Returns:** `void`
- **Calls:** max, track_data_flow, has_method, min, update_grid_visualization, print, emit_signal, range, size
- **Signals:** grid_updated

### `update_cell_value()`
- **Lines:** 0
- **Parameters:** `x, y, value`
- **Returns:** `void`
- **Calls:** record_interaction, has_method, update_cell_visualization

### `highlight_cell()`
- **Lines:** 0
- **Parameters:** `x, y, highlight = true`
- **Returns:** `void`
- **Calls:** Vector3

### `set_title()`
- **Lines:** 0
- **Parameters:** `title_text`
- **Returns:** `void`

### `set_data_properties()`
- **Lines:** 0
- **Parameters:** `label, units`
- **Returns:** `void`
- **Calls:** update_info_panel

### `animate_to_new_data()`
- **Lines:** 0
- **Parameters:** `new_data, duration = 1.0`
- **Returns:** `void`
- **Calls:** set_trans, set_delay, tween_callback, tween_property, set_data, set_ease, lerp, append, range, create_tween

### `create_grid_cells()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_cell, append, range, add_child

### `create_cell()`
- **Lines:** 0
- **Parameters:** `x, y`
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, has_method, connect, get_spectrum_color, _on_cell_input_event, Color, _on_cell_mouse_entered, _on_cell_mouse_exited

### `create_axis_labels()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, str, Vector3, append, range

### `create_title()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `create_info_panel()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, create_color_legend, new, add_child, Vector3, Color

### `create_color_legend()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, Vector3, has_method, get_spectrum_color, Color, float, range, lerp

### `update_grid_visualization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_info_panel, range, update_cell_visualization

### `update_cell_visualization()`
- **Lines:** 0
- **Parameters:** `x, y`
- **Returns:** `void`
- **Calls:** max, get_node, Vector3, has_method, get_spectrum_color, Color, lerp

### `update_info_panel()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, range

### `clear_grid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, get_children

### `_on_cell_input_event()`
- **Lines:** 0
- **Parameters:** `x, y, camera, event, position, normal, shape_idx`
- **Returns:** `void`
- **Calls:** record_interaction, has_method, emit_signal
- **Signals:** cell_selected

### `_on_cell_mouse_entered()`
- **Lines:** 0
- **Parameters:** `x, y`
- **Returns:** `void`
- **Calls:** get_node, highlight_cell, Color

### `_on_cell_mouse_exited()`
- **Lines:** 0
- **Parameters:** `x, y`
- **Returns:** `void`
- **Calls:** get_node, highlight_cell, Color

### `setup_main_reference_old()`
- **Lines:** 5
- **Parameters:** `main_ref`
- **Returns:** `void`
- **Calls:** update_grid_visualization


## scripts/jsh_framework/core/jsh_scene_tree_system.gd
**Category:** Core Systems
**Functions:** 40

### `_init()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_scene_tree_monitoring, start_up_scene_tree, get_tree, print

### `start_up_scene_tree()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, unlock, duplicate, emit_signal, lock
- **Signals:** tree_updated

### `add_branch()`
- **Lines:** 0
- **Parameters:** `branch_path: String, branch_data: Dictionary`
- **Returns:** `bool`
- **Calls:** unlock, duplicate, has, lock, emit_signal, range, size, split
- **Signals:** tree_updated, branch_added

### `remove_branch()`
- **Lines:** 0
- **Parameters:** `branch_path: String`
- **Returns:** `bool`
- **Calls:** cache_branch_data, unlock, erase, has, lock, emit_signal, slice, split
- **Signals:** branch_removed, tree_updated

### `get_branch()`
- **Lines:** 0
- **Parameters:** `branch_path: String`
- **Returns:** `Dictionary`
- **Calls:** unlock, duplicate, has, lock, range, size, split

### `set_branch_status()`
- **Lines:** 0
- **Parameters:** `branch_path: String, status: String`
- **Returns:** `bool`
- **Calls:** unlock, has, lock, emit_signal, range, size, split
- **Signals:** branch_status_changed, tree_updated

### `get_branch_status()`
- **Lines:** 0
- **Parameters:** `branch_path: String`
- **Returns:** `String`
- **Calls:** get_branch, get

### `disable_branch()`
- **Lines:** 0
- **Parameters:** `branch_path: String`
- **Returns:** `bool`
- **Calls:** set_branch_status

### `activate_branch()`
- **Lines:** 0
- **Parameters:** `branch_path: String`
- **Returns:** `bool`
- **Calls:** set_branch_status

### `set_branch_node()`
- **Lines:** 0
- **Parameters:** `branch_path: String, node: Node`
- **Returns:** `bool`
- **Calls:** unlock, has, lock, emit_signal, range, size, split
- **Signals:** tree_updated

### `get_branch_node()`
- **Lines:** 0
- **Parameters:** `branch_path: String`
- **Returns:** `Node`
- **Calls:** get_branch, get

### `jsh_tree_get_node()`
- **Lines:** 0
- **Parameters:** `node_path: String`
- **Returns:** `Node`
- **Calls:** get, unlock, has, lock, range, size, split

### `validate_branch_nodes()`
- **Lines:** 0
- **Parameters:** `branch_path: String`
- **Returns:** `Array`
- **Calls:** is_instance_valid, get_branch, has, append, empty

### `cache_branch_data()`
- **Lines:** 0
- **Parameters:** `branch_path: String, branch_data: Dictionary`
- **Returns:** `void`
- **Calls:** unlock, duplicate, has, lock, split

### `restore_cached_branch()`
- **Lines:** 0
- **Parameters:** `branch_name: String`
- **Returns:** `Dictionary`
- **Calls:** unlock, duplicate, erase, has, lock

### `has_cached_branch()`
- **Lines:** 0
- **Parameters:** `branch_name: String`
- **Returns:** `bool`
- **Calls:** unlock, has, lock

### `_append_branch_to_output()`
- **Lines:** 0
- **Parameters:** `branch: Dictionary, output: String, prefix: String`
- **Returns:** `void`
- **Calls:** _append_branch_to_output, keys, has, range, size, get

### `build_pretty_print()`
- **Lines:** 0
- **Parameters:** `node: Node, prefix: String = "", is_last: bool = true`
- **Returns:** `String`
- **Calls:** range, get_children, size, build_pretty_print

### `capture_tree_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_root, build_pretty_print, get_tree, capture_node_structure, get_unix_time_from_system

### `capture_node_structure()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `Dictionary`
- **Calls:** get_class, get_children, str, get_path, append, capture_node_structure

### `match_node_type()`
- **Lines:** 0
- **Parameters:** `type: String`
- **Returns:** `String`

### `check_if_container_available()`
- **Lines:** 0
- **Parameters:** `container: String`
- **Returns:** `bool`
- **Calls:** unlock, has, lock

### `check_if_datapoint_available()`
- **Lines:** 0
- **Parameters:** `container: String`
- **Returns:** `bool`
- **Calls:** unlock, has, lock

### `check_if_datapoint_node_available()`
- **Lines:** 0
- **Parameters:** `container: String`
- **Returns:** `String`
- **Calls:** unlock, has, lock

### `jsh_tree_get_node_status_changer()`
- **Lines:** 0
- **Parameters:** `node_path: String, node_name: String, node_to_check: Node`
- **Returns:** `void`
- **Calls:** unlock, has, lock, emit_signal, range, size, split
- **Signals:** branch_status_changed, tree_updated

### `_setup_scene_tree_monitoring()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, connect, print, get_tree

### `_on_godot_node_added()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** _get_jsh_path_for_node, print, add_branch, _create_branch_data_from_node

### `_on_godot_node_removed()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** is_instance_valid, _get_jsh_path_for_node, erase, has, print, remove_branch

### `_on_godot_node_renamed()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** _get_jsh_path_for_node, is_empty, emit, get_branch, print

### `_sync_with_godot_tree()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _cleanup_node_path_cache, get_tree, _sync_node_recursive

### `_sync_node_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node, jsh_path: String`
- **Returns:** `void`
- **Calls:** get_children, _create_branch_data_from_node, is_empty, get_branch, _sync_node_recursive, add_branch

### `_get_jsh_path_for_node()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `String`
- **Calls:** get_main_loop, is_instance_valid, get_parent, is_inside_tree, push_front, join, has, size

### `_create_branch_data_from_node()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec, get_class, _get_jsh_type_for_node, duplicate

### `_get_jsh_type_for_node()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `String`

### `force_full_sync()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, _sync_with_godot_tree, emit, lock, print, start_up_scene_tree, clear

### `get_sync_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** _count_godot_nodes, get_ticks_msec, _count_jsh_nodes, get_tree, float

### `_count_godot_nodes()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `int`
- **Calls:** get_children, _count_godot_nodes

### `_count_jsh_nodes()`
- **Lines:** 0
- **Parameters:** `tree_dict: Dictionary`
- **Returns:** `int`
- **Calls:** _count_jsh_nodes, has

### `_cleanup_node_path_cache()`
- **Lines:** 10
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_instance_valid, is_inside_tree, erase, or, append


## scripts/jsh_framework/core/jsh_snake_game.gd
**Category:** Core Systems
**Functions:** 62

### `_ready_add()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** initialize_console, initialize_keyboard, initialize_camera, log_message, initialize_records_system, initialize_thread_system, show_main_menu, setup_window_layers, initialize_menu_system

### `_process_add()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** process_window, has_method, update_camera

### `_ready_add0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** initialize_animator, get_root, get_node, has_node, get_node_or_null, initialize_materials, initialize_snake, spawn_food, get_tree, create_grid, create_ui_elements

### `_process_add0()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** start_game, reset_game, handle_input, is_action_just_pressed, get_viewport, process_animations, move_snake, get_camera_3d

### `initialize_console()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_console_commands

### `initialize_keyboard()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, load, add_child, Vector3, has_method, setup_text_handling

### `initialize_menu_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child

### `initialize_camera()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, Color, add_child

### `initialize_thread_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, load, add_child, get_node_or_null, set_script

### `initialize_records_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, set_script, new, load

### `setup_window_layers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, Vector3

### `show_scene()`
- **Lines:** 0
- **Parameters:** `scene_number`
- **Returns:** `void`
- **Calls:** str, log_message, has_method, scene_to_set_number_later

### `upload_scene_data()`
- **Lines:** 0
- **Parameters:** `container_name, scene_data`
- **Returns:** `void`
- **Calls:** append, has_method, has, upload_scenes_frames

### `show_main_menu()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, set_view_mode

### `hide_menu_container()`
- **Lines:** 0
- **Parameters:** `container_name`
- **Returns:** `void`
- **Calls:** get_node_or_null

### `show_menu_scene()`
- **Lines:** 0
- **Parameters:** `menu_name, page_index`
- **Returns:** `void`
- **Calls:** get_node

### `launch_snake_game()`
- **Lines:** 0
- **Parameters:** `difficulty = "normal"`
- **Returns:** `void`
- **Calls:** set_view_mode, hide_menu_container, create_snake_game, get_parent

### `create_snake_game()`
- **Lines:** 0
- **Parameters:** `difficulty = "normal"`
- **Returns:** `void`
- **Calls:** new, load, add_child, has_method, set_difficulty

### `show_snake_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_view_mode, get_node_or_null, launch_snake_game

### `set_view_mode()`
- **Lines:** 0
- **Parameters:** `mode`
- **Returns:** `void`
- **Calls:** Vector3, set_meta

### `update_camera()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** from_euler, Vector3, get_meta, get_euler, slerp, has_meta, lerp

### `register_console_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_input()`
- **Lines:** 0
- **Parameters:** `event`
- **Returns:** `void`
- **Calls:** toggle_console, show_main_menu

### `toggle_console()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, set_view_mode

### `create_new_task()`
- **Lines:** 0
- **Parameters:** `function_name, data`
- **Returns:** `void`
- **Calls:** get_ticks_msec, str, has_method, submit_task, new_task_appeared

### `three_stages_of_creation()`
- **Lines:** 0
- **Parameters:** `set_name`
- **Returns:** `void`
- **Calls:** get_node, log_message, create_snake_game

### `log_message()`
- **Lines:** 0
- **Parameters:** `message, type = "info"`
- **Returns:** `void`
- **Calls:** get_ticks_msec, get_time_string_from_system, pop_front, has, print, append, size

### `first_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `action_to_do, datapoint_node, additional_node = null`
- **Returns:** `void`
- **Calls:** log_message

### `fourth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `type_of_stuff, node, data`
- **Returns:** `void`
- **Calls:** log_message

### `fifth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `type_of_unload, container_name`
- **Returns:** `void`
- **Calls:** get_node_or_null, log_message

### `sixth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `type_of_action, node_path_or_nodes, function_name, data = null`
- **Returns:** `void`
- **Calls:** call, get_node_or_null, log_message, has_method, split

### `seventh_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `action_type, path, data`
- **Returns:** `void`
- **Calls:** get_node_or_null, log_message

### `eighth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `name_of_action, data_to_send, container_name`
- **Returns:** `void`
- **Calls:** set_connection_target, get_node_or_null, log_message, has_method, initialize_loading_file

### `initialize_materials()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, Color, duplicate

### `create_grid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, create_grid_line, append, range

### `create_grid_line()`
- **Lines:** 0
- **Parameters:** `start, end`
- **Returns:** `void`
- **Calls:** new, surface_add_vertex, surface_end, surface_begin, clear_surfaces

### `create_ui_elements()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, update_score_display, add_child

### `initialize_snake()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_instance_valid, queue_free, Vector2i, clear, add_snake_segment

### `add_snake_segment()`
- **Lines:** 0
- **Parameters:** `grid_pos, is_head = false`
- **Returns:** `void`
- **Calls:** new, add_child, str, append, size

### `initialize_animator()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, new, add_child, load, start_breathing_animation, setup_materials

### `start_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_score_display

### `reset_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, setup_materials, initialize_snake, start_breathing_animation, spawn_food, update_score_display, append

### `handle_input()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2i, is_action_just_pressed

### `move_snake()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_ready_snake()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_root, get_parent, get_node, create_meshes, has_node, update_info_text, start_new_game, update_score_display, get_tree, create_grid

### `_process_snake()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** move_snake

### `create_meshes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Color, create_cube_mesh

### `create_cube_mesh()`
- **Lines:** 0
- **Parameters:** `color: Color`
- **Returns:** `Mesh`
- **Calls:** Vector3, new

### `start_new_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, is_instance_valid, queue_free, spawn_food, update_score_display, clear, range, add_snake_segment

### `spawn_food()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, queue_free, Vector3, get_meta, get_node_or_null, randi, append, range, size

### `handle_game_over()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_info_text

### `update_info_text()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`

### `update_score_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str

### `create_grid_add()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, Vector3, Color

### `add_snake_segment_add()`
- **Lines:** 0
- **Parameters:** `grid_pos: Vector2`
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, push_front, set_meta, size

### `move_snake_add()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, get_meta, spawn_food, handle_game_over, update_score_display, front, range, size, add_snake_segment, pop_back

### `handle_input_add()`
- **Lines:** 0
- **Parameters:** `input_type: String`
- **Returns:** `void`
- **Calls:** first_dimensional_magic, get_meta, update_info_text, has_method, start_new_game, front, add_snake_segment

### `handle_snake_menu_interaction()`
- **Lines:** 0
- **Parameters:** `option, difficulty = "normal"`
- **Returns:** `void`
- **Calls:** display_high_scores, launch_snake_game, print

### `launch_snake_game_add()`
- **Lines:** 0
- **Parameters:** `difficulty`
- **Returns:** `void`
- **Calls:** get_node_or_null, print

### `display_high_scores()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, print

### `process_snake_button_click()`
- **Lines:** 0
- **Parameters:** `button_name`
- **Returns:** `void`
- **Calls:** handle_snake_menu_interaction, get_current_menu_context

### `get_current_menu_context()`
- **Lines:** 62
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_meta, has_meta, get_node_or_null


## scripts/jsh_framework/core/jsh_task_manager.gd
**Category:** Core Systems
**Functions:** 61

### `_init()`
- **Lines:** 0
- **Parameters:** `container_seed : int, pos : Vector3`
- **Returns:** `void`
- **Calls:** substr, str, sha1_text

### `evolve()`
- **Lines:** 0
- **Parameters:** `turn : int, command`
- **Returns:** `void`
- **Calls:** new, duplicate, has, apply_scale_pattern, append

### `apply_scale_pattern()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `serialize()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, initialize_task_system, new, print

### `add_task()`
- **Lines:** 0
- **Parameters:** `task_name, priority = 0, dependencies = []`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, prune_completed_tasks, size

### `start_task()`
- **Lines:** 0
- **Parameters:** `task_id`
- **Returns:** `void`
- **Calls:** get_ticks_msec, _find_task_index, print

### `complete_task()`
- **Lines:** 0
- **Parameters:** `task_id, success = true`
- **Returns:** `void`
- **Calls:** get_ticks_msec, _find_task_index

### `track_data_flow()`
- **Lines:** 0
- **Parameters:** `source_path, target_path, data_type, amount = 1.0`
- **Returns:** `void`
- **Calls:** get_ticks_msec, has, _update_flow_visualization

### `record_interaction()`
- **Lines:** 0
- **Parameters:** `position, type, data = null`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, _visualize_interaction, size

### `track_scene_movement()`
- **Lines:** 0
- **Parameters:** `scene_path, from_position, to_position, duration`
- **Returns:** `void`
- **Calls:** get_ticks_msec, _visualize_movement, has, append, size

### `complete_scene_movement()`
- **Lines:** 0
- **Parameters:** `scene_path, movement_index`
- **Returns:** `void`
- **Calls:** has, size

### `generate_statistics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** values, has, get_ticks_msec, size

### `export_data()`
- **Lines:** 0
- **Parameters:** `file_path = "user://task_manager_data.json"`
- **Returns:** `void`
- **Calls:** open, close, store_string, get_unix_time_from_system, stringify

### `create_3d_visualization()`
- **Lines:** 0
- **Parameters:** `parent_node`
- **Returns:** `void`
- **Calls:** new, add_child, queue_free, _visualize_movement, size, _visualize_interaction, range, _create_flow_line

### `_find_task_index()`
- **Lines:** 0
- **Parameters:** `task_id`
- **Returns:** `void`
- **Calls:** range, size

### `prune_completed_tasks()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append

### `_update_flow_visualization()`
- **Lines:** 0
- **Parameters:** `flow_key`
- **Returns:** `void`
- **Calls:** _create_flow_line, range, size, min

### `_create_flow_line()`
- **Lines:** 0
- **Parameters:** `flow_key`
- **Returns:** `void`
- **Calls:** end, new, add_child, get_node_or_null, begin, append, clear, add_vertex

### `_visualize_interaction()`
- **Lines:** 0
- **Parameters:** `interaction`
- **Returns:** `void`
- **Calls:** str, new, Color, add_child

### `_visualize_movement()`
- **Lines:** 0
- **Parameters:** `scene_path, movement`
- **Returns:** `void`
- **Calls:** sin, end, float, new, distance_to, add_child, str, Color, begin, clear, add_vertex, range, lerp

### `new_task_appeared()`
- **Lines:** 0
- **Parameters:** `task_id, function_called, data_send_to_function`
- **Returns:** `void`
- **Calls:** unlock, str, check_if_that_task_was, duplicate, lock, append, collect_tasks

### `collect_tasks()`
- **Lines:** 0
- **Parameters:** `function_name, task_data`
- **Returns:** `void`
- **Calls:** unlock, lock

### `check_if_that_task_was()`
- **Lines:** 0
- **Parameters:** `function_name`
- **Returns:** `void`
- **Calls:** unlock, has, lock

### `check_all_things()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `initialize_task_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, lock, duplicate

### `parse_code_structure()`
- **Lines:** 0
- **Parameters:** `content: String`
- **Returns:** `Dictionary`
- **Calls:** substr, join, begins_with, append, strip_edges, split

### `create_tasks_from_structure()`
- **Lines:** 0
- **Parameters:** `structure: Dictionary`
- **Returns:** `void`
- **Calls:** determine_category, unlock, generate_task_id, lock, append

### `generate_task_id()`
- **Lines:** 0
- **Parameters:** `base_name: String`
- **Returns:** `String`
- **Calls:** get_ticks_msec, str, replace, to_lower

### `determine_category()`
- **Lines:** 0
- **Parameters:** `system_name: String`
- **Returns:** `String`
- **Calls:** to_lower

### `get_task_info()`
- **Lines:** 0
- **Parameters:** `task_id: String`
- **Returns:** `Dictionary`
- **Calls:** get, unlock, lock, duplicate

### `update_task_status_now()`
- **Lines:** 0
- **Parameters:** `task_id: String, new_status: String`
- **Returns:** `bool`
- **Calls:** get_ticks_msec, unlock, has, lock

### `update_task_status()`
- **Lines:** 0
- **Parameters:** `task_id: String, new_status: String`
- **Returns:** `bool`
- **Calls:** unlock, has, lock

### `get_category_tasks()`
- **Lines:** 0
- **Parameters:** `category: String`
- **Returns:** `Array`
- **Calls:** append, unlock, lock, duplicate

### `generate_task_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_category_tasks, unlock, length, lock, print

### `initialize_world_seed()`
- **Lines:** 0
- **Parameters:** `master_seed : int`
- **Returns:** `void`
- **Calls:** generate_initial_containers, new

### `store_container()`
- **Lines:** 0
- **Parameters:** `container : SpatialContainer`
- **Returns:** `void`
- **Calls:** serialize, open, stringify, store_string

### `save_container_states()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** values, store_container, duplicate

### `apply_scale_pattern()`
- **Lines:** 0
- **Parameters:** `data, seed`
- **Returns:** `void`
- **Calls:** print

### `load_from_rom()`
- **Lines:** 0
- **Parameters:** `def`
- **Returns:** `void`
- **Calls:** apply_scale_pattern, check_history, check_scale, duplicate

### `check_scale()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `check_history()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `generate_initial_rules()`
- **Lines:** 0
- **Parameters:** `rng_number`
- **Returns:** `void`
- **Calls:** print

### `generate_initial_containers()`
- **Lines:** 0
- **Parameters:** `rng`
- **Returns:** `void`
- **Calls:** randf_range, generate_initial_rules, new, Vector3, check_rules_of_container, store_container, randi

### `check_rules_of_container()`
- **Lines:** 0
- **Parameters:** `container_rules`
- **Returns:** `void`
- **Calls:** print

### `process_turn()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** process_commands, save_container_states, load_required_containers, apply_procedural_rules, update_container_lod, unload_distant_containers

### `apply_procedural_rules()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `unload_distant_containers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `update_container_lod()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** calculate_lod, distance_to, get_viewport, values, get_camera_3d

### `calculate_lod()`
- **Lines:** 0
- **Parameters:** `distance : float`
- **Returns:** `int`
- **Calls:** size

### `load_required_containers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** distance_to, get_viewport, has, load_from_rom, values, get_camera_3d

### `process_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** pop_front, is_empty, execute_command

### `execute_command()`
- **Lines:** 0
- **Parameters:** `command`
- **Returns:** `void`
- **Calls:** new, evolve, detect_repetition_patterns, store_container, apply_global_scale, inherit_rules

### `apply_global_scale()`
- **Lines:** 0
- **Parameters:** `command`
- **Returns:** `void`
- **Calls:** print

### `inherit_rules()`
- **Lines:** 0
- **Parameters:** `source_container`
- **Returns:** `void`
- **Calls:** mutate_rule, randf, new

### `detect_repetition_patterns()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** slice, size, apply_pattern_response, values, check_pattern_repetition

### `mutate_rule()`
- **Lines:** 0
- **Parameters:** `data, seed`
- **Returns:** `void`
- **Calls:** print

### `check_pattern_repetition()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `apply_pattern_response()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `store_container_old()`
- **Lines:** 0
- **Parameters:** `container : SpatialContainer`
- **Returns:** `void`
- **Calls:** serialize, open, stringify, store_string

### `save_container_states_old()`
- **Lines:** 52
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** values, store_container, duplicate


## scripts/jsh_framework/core/jsh_thread_pool_manager.gd
**Category:** Core Systems
**Functions:** 4

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, get_processor_count, print

### `check_all_things()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, get_processor_count, print

### `store_thread_check()`
- **Lines:** 0
- **Parameters:** `thread_data: Dictionary`
- **Returns:** `void`
- **Calls:** get_ticks_msec, pop_front, has, append, size

### `analyze_thread_performance()`
- **Lines:** 76
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec


## scripts/jsh_framework/core/line.gd
**Category:** Core Systems
**Functions:** 3

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** send_any_message

### `change_points_of_line()`
- **Lines:** 0
- **Parameters:** `start_end_points`
- **Returns:** `void`
- **Calls:** surface_add_vertex, Vector3, surface_end, surface_begin, clear_surfaces

### `send_any_message()`
- **Lines:** 3
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print


## scripts/jsh_framework/core/main.gd
**Category:** Core Systems
**Functions:** 390

### `_init()`
- **Lines:** 0
- **Parameters:** `parent_node = null`
- **Returns:** `void`

### `register_command()`
- **Lines:** 0
- **Parameters:** `cmd_name, target, method_name`
- **Returns:** `void`

### `parse()`
- **Lines:** 0
- **Parameters:** `raw_input: String`
- **Returns:** `Dictionary`
- **Calls:** call_command, to_lower, has, slice, size, split

### `call_command()`
- **Lines:** 0
- **Parameters:** `cmd: String, args: Array`
- **Returns:** `Dictionary`
- **Calls:** call

### `_init()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** setup_system_checks, prepare_akashic_records_init, _ready, print, append, check_status_just_timer, print_tree_pretty

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** check_settings_file, new, save_file_list_text, capture_tree_state, create_tasks_from_structure, get_name, print, track_task_status, append, print_tree_pretty, check_tree_branches, get_as_text, get_mouse_position, _setup_retry_timer, connect, Callable, check_three_tries_for_threads, scan_res_directory, queue_pusher_adder, test_single_core, start_up_scene_tree, is_debug_build, scan_eden_directory, open, test_multi_threaded, add_child, initialize_base_textures, check_status_just_timer, generate_task_report, get_camera_3d, parse_code_structure, get_viewport, scan_directory_with_sizes

### `_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** _input_event

### `_input_event()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** input, get_ray_points, process_ray_cast

### `_process()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** process_roll, each_blimp_of_delta, is_mouse_button_pressed, process_system, process

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** Quaternion, lerp

### `process_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** process_system_5, process_system_2, process_system_1, process_system_0, process_system_9, process_system_4, process_system_7, process_system_8, process_system_6, process_system_3

### `each_blimp_of_delta()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, pop_front, size

### `update_delta_history()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, unlock, lock

### `calculate_time()`
- **Lines:** 0
- **Parameters:** `delta_current, time, hour, minute, second`
- **Returns:** `void`
- **Calls:** get_ticks_msec, print

### `before_time_blimp()`
- **Lines:** 0
- **Parameters:** `how_many_finished, how_many_shall_been_finished`
- **Returns:** `void`
- **Calls:** get_ticks_msec

### `blimp_time_for_some_reason()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_on_interval_tick()`
- **Lines:** 0
- **Parameters:** `interval_name: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, check_quick_functions, check_short_functions, print

### `track_delta_timing()`
- **Lines:** 0
- **Parameters:** `validation`
- **Returns:** `void`
- **Calls:** print

### `_setup_retry_timer()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect

### `_on_retry_timer_completed()`
- **Lines:** 0
- **Parameters:** `timer_id: String`
- **Returns:** `void`
- **Calls:** prepare_akashic_records, print

### `ready_for_once()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_new_task

### `process_pending_sets()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_new_task, get_system_state, check_system_function, unlock, is_empty, lock, append, size

### `handle_creation_task()`
- **Lines:** 0
- **Parameters:** `target_argument`
- **Returns:** `void`
- **Calls:** get_ticks_msec, unlock, has, lock, print, the_current_state_of_tree, int

### `handle_unload_task()`
- **Lines:** 0
- **Parameters:** `target_argument`
- **Returns:** `void`
- **Calls:** substr, get_ticks_msec, unlock, str, length, has, lock, print, the_current_state_of_tree, int

### `check_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, breaks_and_handles_check, push_error, start_timer, connect, check_thread_status, check_thread_status_type, print, is_timer_active

### `check_status_just_timer()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, get_ticks_msec, start_timer, str, check_thread_status, check_thread_status_type, print

### `track_task_status()`
- **Lines:** 0
- **Parameters:** `task_id`
- **Returns:** `void`
- **Calls:** get_ticks_msec

### `track_task_completion()`
- **Lines:** 0
- **Parameters:** `task_id`
- **Returns:** `void`
- **Calls:** create_timer, handle_task_timeout, get_ticks_msec, has, get_tree

### `handle_task_timeout()`
- **Lines:** 0
- **Parameters:** `task_id`
- **Returns:** `void`

### `clear_task_queues()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `first_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `type_of_action_to_do : String, datapoint_node : Node, additional_node : Node = null`
- **Returns:** `void`
- **Calls:** append, unlock, lock

### `the_fourth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `type_of_operation : String, node : Node, data_of_movement`
- **Returns:** `void`
- **Calls:** append, unlock, lock

### `fifth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `type_of_unloading : String, node_path_for_unload : String`
- **Returns:** `void`
- **Calls:** append, unlock, lock

### `sixth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `type_of_function, node_to_call, function_name : String, additional_data = null`
- **Returns:** `void`
- **Calls:** append, unlock, lock

### `seventh_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `type_of_action : String, kind_of_action : String, amount_of_actions : int`
- **Returns:** `void`
- **Calls:** append, unlock, lock, print

### `check_magical_array()`
- **Lines:** 0
- **Parameters:** `path_of_the_node`
- **Returns:** `void`
- **Calls:** Array, unlock, join, lock, print, begins_with, split, pop_back

### `eight_dimensional_magic()`
- **Lines:** 12
- **Parameters:** `type_of_message : String, message_now, receiver_name : String`
- **Returns:** `void`
- **Calls:** append, unlock, lock, print

### `ninth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** `operation, path, texture = null`
- **Returns:** `void`
- **Calls:** print

### `newer_even_function_for_dictionary()`
- **Lines:** 0
- **Parameters:** `name_of_container`
- **Returns:** `void`
- **Calls:** new_datapoint_layer_system, unlock, lock, duplicate

### `task_to_send_data_to_datapoint()`
- **Lines:** 0
- **Parameters:** `data_for_sending`
- **Returns:** `void`
- **Calls:** scene_frames_upload_to_datapoint, interactions_upload_to_datapoint, instructions_analiser, print

### `interactions_upload_to_datapoint()`
- **Lines:** 0
- **Parameters:** `header_line, information_lines, datapoint`
- **Returns:** `void`
- **Calls:** upload_interactions, print

### `scene_frames_upload_to_datapoint()`
- **Lines:** 0
- **Parameters:** `header_line, information_lines, datapointi, containeri`
- **Returns:** `void`
- **Calls:** upload_scenes_frames

### `load_cached_data_second_impact()`
- **Lines:** 0
- **Parameters:** `data_set: String`
- **Returns:** `void`
- **Calls:** unlock, duplicate, data_to_be_send_processing, lock, print, append, clear, size, int

### `load_cached_data_second_impact_old()`
- **Lines:** 0
- **Parameters:** `data_set: String`
- **Returns:** `void`
- **Calls:** unlock, duplicate, data_to_be_send_processing, lock, print, append, clear, size, int

### `instructions_analiser()`
- **Lines:** 0
- **Parameters:** `metadata_parts, second_line, third_line, datapoint, container`
- **Returns:** `void`
- **Calls:** datapoint_assign_priority, Vector3, the_fourth_dimensional_magic, sixth_dimensional_magic, datapoint_max_things_number_setter, set_maximum_interaction_number, scene_to_set_number_later, print, float, containter_start_up, add_thing_to_datapoint, int

### `data_to_be_send_processing()`
- **Lines:** 0
- **Parameters:** `container_name, data_id, path_for_datapoint, place_for_data, first_line, lines_parsed, data_set_name`
- **Returns:** `void`
- **Calls:** unlock, has, lock, print

### `check_type_of_container()`
- **Lines:** 0
- **Parameters:** `data_set_name`
- **Returns:** `void`
- **Calls:** unlock, lock, print

### `check_scene_container()`
- **Lines:** 0
- **Parameters:** `data_set_name`
- **Returns:** `void`
- **Calls:** unlock, lock, print

### `test_single_core()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** prepare_akashic_records

### `test_multi_threaded()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_new_task_empty

### `check_thread_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_thread_stats, get_processor_count, print

### `check_thread_status_type()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_thread_stats, str, s, get_processor_count, print

### `multi_threads_start_checker()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, print

### `prepare_akashic_records()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, get_thread_caller_id, print

### `create_new_task()`
- **Lines:** 0
- **Parameters:** `function_name: String, data`
- **Returns:** `void`
- **Calls:** get_ticks_msec, str, submit_task

### `create_new_task_empty()`
- **Lines:** 0
- **Parameters:** `function_name: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, str, submit_task_unparameterized

### `check_three_tries_for_threads()`
- **Lines:** 0
- **Parameters:** `threads_0, threads_1, threads_2`
- **Returns:** `void`

### `validate_thread_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec, get_processor_count, get_active_threads, check_thread_status

### `three_stages_of_creation()`
- **Lines:** 0
- **Parameters:** `data_set_name`
- **Returns:** `void`
- **Calls:** unlock, handle_creation_task, lock, print, begins_with, append

### `check_if_we_are_adding_container()`
- **Lines:** 0
- **Parameters:** `path_of_the_node`
- **Returns:** `void`
- **Calls:** Array, unlock, join, lock, print, begins_with, split, pop_back

### `check_if_already_loading_one()`
- **Lines:** 0
- **Parameters:** `set_name`
- **Returns:** `void`
- **Calls:** begins_with, unlock, lock

### `the_current_state_of_tree()`
- **Lines:** 0
- **Parameters:** `set_name_now, the_state`
- **Returns:** `void`
- **Calls:** unlock, has, lock, print

### `change_creation_set_name()`
- **Lines:** 0
- **Parameters:** `record_type, additional_set_name_`
- **Returns:** `void`
- **Calls:** unlock, lock, print

### `process_creation_further()`
- **Lines:** 0
- **Parameters:** `record_type : String, amount : int`
- **Returns:** `void`
- **Calls:** unlock, lock

### `whip_out_set_by_its_name()`
- **Lines:** 0
- **Parameters:** `set_name_to_test`
- **Returns:** `CreationStatus`
- **Calls:** create_new_task, typeof, is_empty, print, is_creation_possible

### `attempt_creation()`
- **Lines:** 0
- **Parameters:** `set_name: String`
- **Returns:** `CreationState`
- **Calls:** is_creation_possible, print

### `queue_pusher_adder()`
- **Lines:** 0
- **Parameters:** `task`
- **Returns:** `void`
- **Calls:** handle_task_timeout, get_ticks_msec, str, has, print

### `check_currently_being_created_sets()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, has, lock, print, int

### `process_stages()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** third_stage_of_creation_, unlock, size, first_stage_of_creation_, fifth_impact_of_creation_, fourth_impact_of_creation_, erase, lock, second_stage_of_creation_, sixth_impact_of_creation

### `first_stage_of_creation_()`
- **Lines:** 0
- **Parameters:** `data_set_name_0, sets_to_create_0`
- **Returns:** `void`
- **Calls:** create_new_task

### `second_stage_of_creation_()`
- **Lines:** 0
- **Parameters:** `data_set_name_1, sets_to_create_1`
- **Returns:** `void`
- **Calls:** create_new_task

### `second_impact_for_real()`
- **Lines:** 0
- **Parameters:** `set_to_do_thingy`
- **Returns:** `void`
- **Calls:** process_active_records_for_tree, unlock, container_finder, has, lock

### `third_stage_of_creation_()`
- **Lines:** 0
- **Parameters:** `data_set_name_2, sets_to_create_2`
- **Returns:** `void`
- **Calls:** create_new_task

### `third_impact_right_now()`
- **Lines:** 0
- **Parameters:** `data_set_thingiess`
- **Returns:** `void`
- **Calls:** unlock, load_cached_data, lock

### `fourth_impact_of_creation_()`
- **Lines:** 0
- **Parameters:** `data_set_name_3, sets_to_create_3`
- **Returns:** `void`
- **Calls:** create_new_task

### `fourth_impact_right_now()`
- **Lines:** 0
- **Parameters:** `data_set_nameeee`
- **Returns:** `void`
- **Calls:** unlock, load_cached_data_second_impact, lock

### `fifth_impact_of_creation_()`
- **Lines:** 0
- **Parameters:** `data_set_name_4, sets_to_create_4`
- **Returns:** `void`
- **Calls:** create_new_task

### `fifth_impact_right_now()`
- **Lines:** 0
- **Parameters:** `data_set_nameeeeee`
- **Returns:** `void`
- **Calls:** unlock, lock, print

### `sixth_impact_of_creation()`
- **Lines:** 0
- **Parameters:** `data_set_name_6, sets_to_create_6`
- **Returns:** `void`
- **Calls:** create_new_task

### `sixth_impact_right_now()`
- **Lines:** 0
- **Parameters:** `data_set_name_here`
- **Returns:** `void`
- **Calls:** substr, unlock, check_scene_container, length, has, lock, print, check_type_of_container

### `file_creation()`
- **Lines:** 0
- **Parameters:** `file_content,  path_for_file, name_for_file`
- **Returns:** `void`
- **Calls:** open, store_line

### `create_file()`
- **Lines:** 0
- **Parameters:** `array_with_data: Array, lines_amount: int, name_for_file: String`
- **Returns:** `void`
- **Calls:** open, range, store_line

### `save_file_list_text()`
- **Lines:** 0
- **Parameters:** `scan_results: Dictionary, output_file: String, target_directory: String`
- **Returns:** `void`
- **Calls:** open, close, store_line, str, print

### `create_default_settings()`
- **Lines:** 0
- **Parameters:** `file_path_c_d_s`
- **Returns:** `void`
- **Calls:** append, size, create_file

### `save_file_list_json()`
- **Lines:** 0
- **Parameters:** `scan_results: Dictionary, output_file: String = "user://file_list.json"`
- **Returns:** `void`
- **Calls:** open, close, store_string, print, stringify

### `find_or_create_eden_directory()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** scan_available_storage, dir_exists_absolute, make_dir_recursive_absolute

### `file_finder()`
- **Lines:** 0
- **Parameters:** `file_name, path_to_file, list_of_files, type_of_data`
- **Returns:** `void`
- **Calls:** size

### `check_folder()`
- **Lines:** 0
- **Parameters:** `folder_path`
- **Returns:** `void`
- **Calls:** check_folder_content, open

### `check_folder_content()`
- **Lines:** 22
- **Parameters:** `directory`
- **Returns:** `void`
- **Calls:** get_directories, get_files, size

### `check_settings_file()`
- **Lines:** 0
- **Parameters:** `type_of_file`
- **Returns:** `void`
- **Calls:** scan_available_storage, update_main_path, open, close, store_line, file_exists, dir_exists_absolute, load_settings_file, is_empty, make_dir_recursive_absolute, update_database_path, print, append, split

### `update_main_path()`
- **Lines:** 0
- **Parameters:** `updated_path`
- **Returns:** `void`

### `update_database_path()`
- **Lines:** 0
- **Parameters:** `updated_db_path`
- **Returns:** `void`

### `scan_eden_directory()`
- **Lines:** 0
- **Parameters:** `directory: String = "D:/Eden", indent: int = 0`
- **Returns:** `Dictionary`
- **Calls:** path_join, scan_eden_directory, open, get_directories, get_files, print, append

### `scan_available_storage()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, get_directories, get_name, print, char, append, range

### `scan_res_directory()`
- **Lines:** 0
- **Parameters:** `directory: String = "res://", indent: int = 0`
- **Returns:** `Dictionary`
- **Calls:** path_join, open, get_directories, get_files, scan_res_directory, print, append, repeat

### `scan_directory_with_sizes()`
- **Lines:** 0
- **Parameters:** `directory: String, indent: int = 0`
- **Returns:** `Dictionary`
- **Calls:** path_join, open, close, get_directories, get_files, get_length, append, scan_directory_with_sizes

### `get_data_structure_size()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `int`
- **Calls:** var_to_bytes, typeof, length, size, get_data_structure_size

### `get_jsh()`
- **Lines:** 0
- **Parameters:** `property_name: String`
- **Returns:** `void`

### `check_memory_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** keys, get_ticks_msec, get_jsh, print, clean_dictionary, clean_array, get_data_structure_size

### `setup_settings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** file_exists, dir_exists_absolute, load_settings_file, make_dir_recursive_absolute, create_default_settings, find_or_create_eden_directory

### `clean_array()`
- **Lines:** 0
- **Parameters:** `array_name: String`
- **Returns:** `void`
- **Calls:** slice, filter, get_ticks_msec, size

### `clean_dictionary()`
- **Lines:** 0
- **Parameters:** `dict_name: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, erase, get, keys

### `data_splitter_some_function()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** analyze_file_content

### `zippy_unzipper_data_center()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `check_record_in_active()`
- **Lines:** 0
- **Parameters:** `records_set_name`
- **Returns:** `void`
- **Calls:** unlock, is_empty, has, lock

### `check_record_in_cached()`
- **Lines:** 0
- **Parameters:** `records_set_name`
- **Returns:** `void`
- **Calls:** unlock, is_empty, has, lock

### `check_set_limit()`
- **Lines:** 0
- **Parameters:** `records_set_name`
- **Returns:** `void`
- **Calls:** has

### `check_current_set_container_count()`
- **Lines:** 0
- **Parameters:** `record_set_name`
- **Returns:** `void`
- **Calls:** unlock, has, lock

### `check_record_set_type()`
- **Lines:** 0
- **Parameters:** `record_set_name`
- **Returns:** `void`
- **Calls:** has, print

### `check_if_first_time()`
- **Lines:** 0
- **Parameters:** `set_name_first, the_current_of_energy`
- **Returns:** `void`
- **Calls:** unlock, has, lock, print

### `containers_states_checker()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_instance_valid, unlock, get_node, has_method, has, lock, print, check_state_of_dictionary_and_three_ints_of_doom, size

### `the_basic_sets_creation()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** check_if_every_basic_set_is_loaded, size, print

### `get_every_basic_set()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `get_every_basic_set_()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `check_if_every_basic_set_is_loaded()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** check_basic_set_if_loaded, append, print

### `container_finder()`
- **Lines:** 0
- **Parameters:** `set_name`
- **Returns:** `void`
- **Calls:** unlock, has, lock, size, split

### `initialize_menu()`
- **Lines:** 0
- **Parameters:** `record_type: String`
- **Returns:** `void`
- **Calls:** change_creation_set_name, check_set_limit, load_cached_record_to_active, check_record_in_cached, str, create_record_from_script, process_creation_further, check_record_in_active, check_record_set_type, print, create_additional_record_set, check_current_set_container_count

### `find_record_set()`
- **Lines:** 0
- **Parameters:** `record_type: String`
- **Returns:** `Dictionary`

### `find_instructions_set()`
- **Lines:** 0
- **Parameters:** `record_type: String`
- **Returns:** `Dictionary`

### `find_scene_frames()`
- **Lines:** 0
- **Parameters:** `record_type: String`
- **Returns:** `Dictionary`

### `find_interactions_list()`
- **Lines:** 0
- **Parameters:** `record_type: String`
- **Returns:** `Dictionary`

### `record_mistake()`
- **Lines:** 0
- **Parameters:** `mistake_data: Dictionary`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, unlock, lock

### `get_record_type_id()`
- **Lines:** 0
- **Parameters:** `record_type: String`
- **Returns:** `int`

### `get_cache_total_size()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `int`
- **Calls:** get_dictionary_memory_size, unlock, lock

### `get_dictionary_memory_size()`
- **Lines:** 0
- **Parameters:** `dict: Dictionary`
- **Returns:** `int`
- **Calls:** var_to_bytes, size

### `find_highest_in_array()`
- **Lines:** 0
- **Parameters:** `numbers: Array`
- **Returns:** `int`
- **Calls:** max

### `new_function_for_creation_recovery()`
- **Lines:** 0
- **Parameters:** `record_type_now, first_stage_of_creation_now, stage_of_creation_now`
- **Returns:** `void`
- **Calls:** append, try_lock, print

### `create_additional_record_set()`
- **Lines:** 0
- **Parameters:** `record_type, current_container_count_check`
- **Returns:** `void`
- **Calls:** unlock, str, duplicate, erase, continue_recreation, lock, size, split

### `continue_recreation()`
- **Lines:** 0
- **Parameters:** `data_to_work_on_additional_set, datapoint_name_thing, container_name_thing, set_name_to_work_on, current_container_count_check, record_type, amount_of_things, container_name`
- **Returns:** `void`
- **Calls:** unlock, str, has, lock, print, begins_with, split, int

### `create_record_from_script()`
- **Lines:** 0
- **Parameters:** `record_type`
- **Returns:** `void`
- **Calls:** find_interactions_list, find_instructions_set, load_record_set, find_scene_frames, process_creation_further, find_record_set

### `find_record_set_new_file_finder()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** print

### `process_creation_request()`
- **Lines:** 0
- **Parameters:** `set_name: String`
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec, is_creation_possible, whip_out_set_by_its_name, record_mistake

### `prepare_akashic_records_init()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, before_time_blimp, check_thread_status, print

### `load_record_set()`
- **Lines:** 0
- **Parameters:** `records_part: String, record_type: String, type_of_data : int, records : Dictionary`
- **Returns:** `void`
- **Calls:** get_ticks_msec, has, append, clear, size, split

### `load_cached_data()`
- **Lines:** 0
- **Parameters:** `data_set: String`
- **Returns:** `void`
- **Calls:** move_things_around, get_datapoint, unlock, get_node, duplicate, analise_data, lock, print, append, clear, size, int

### `load_cached_record_to_active()`
- **Lines:** 0
- **Parameters:** `records_set_name`
- **Returns:** `void`
- **Calls:** unlock, erase, lock, duplicate

### `deep_copy_dictionary()`
- **Lines:** 0
- **Parameters:** `original: Dictionary`
- **Returns:** `Dictionary`
- **Calls:** parse_string, stringify

### `clean_oldest_dataset()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, unlock, erase, lock, begins_with, append, split

### `process_to_unload_records()`
- **Lines:** 0
- **Parameters:** `container_name_to_unload`
- **Returns:** `void`
- **Calls:** unlock, erase, unload_record_set, has, lock, size, split

### `unload_record_set()`
- **Lines:** 0
- **Parameters:** `records_sets_name : String, record_type: String`
- **Returns:** `void`
- **Calls:** cache_data, unlock, erase, has, lock

### `cache_data()`
- **Lines:** 0
- **Parameters:** `records_sets_name: String, record_type: String, data, meta_data`
- **Returns:** `void`
- **Calls:** get_dictionary_memory_size, clean_oldest_dataset, get_ticks_msec, unlock, str, duplicate, has, lock, print, get_cache_total_size

### `add_container_count()`
- **Lines:** 0
- **Parameters:** `records_set_name`
- **Returns:** `void`
- **Calls:** unlock, has, lock, print

### `recreator()`
- **Lines:** 0
- **Parameters:** `number_to_add, data_to_process, data_set_name, new_name_for_set`
- **Returns:** `void`
- **Calls:** substr, get_ticks_msec, str, length, duplicate, join, erase, print, begins_with, clear, size, split, int

### `check_if_container_available()`
- **Lines:** 0
- **Parameters:** `container`
- **Returns:** `void`
- **Calls:** unlock, has, lock, print

### `check_if_datapoint_available()`
- **Lines:** 0
- **Parameters:** `container`
- **Returns:** `void`
- **Calls:** unlock, has, lock

### `check_if_datapoint_node_available()`
- **Lines:** 0
- **Parameters:** `container`
- **Returns:** `void`
- **Calls:** unlock, lock

### `build_pretty_print()`
- **Lines:** 0
- **Parameters:** `node: Node, prefix: String = "", is_last: bool = true`
- **Returns:** `String`
- **Calls:** range, get_children, size, build_pretty_print

### `find_branch_to_unload()`
- **Lines:** 0
- **Parameters:** `thing_path`
- **Returns:** `void`
- **Calls:** unlock, str, duplicate, cache_branch, erase, has, lock, print, split

### `check_tree_branches()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, has, lock

### `print_tree_structure()`
- **Lines:** 0
- **Parameters:** `branch: Dictionary, indent: int = 0`
- **Returns:** `void`
- **Calls:** print_tree_structure, unlock, s, has, lock, print, values, repeat, get

### `jsh_tree_get_node()`
- **Lines:** 0
- **Parameters:** `node_path_get_node: String`
- **Returns:** `Node`
- **Calls:** unlock, has, split, lock

### `containers_list_creator()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, connect_containers, container_finder, has, lock, print, check_if_first_time, size

### `validate_container_state()`
- **Lines:** 0
- **Parameters:** `container_name`
- **Returns:** `void`
- **Calls:** is_instance_valid, unlock, attempt_container_repair, has, lock, append, size

### `capture_tree_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_root, build_pretty_print, get_tree, capture_node_structure, get_unix_time_from_system

### `capture_node_structure()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `Dictionary`
- **Calls:** get_class, get_children, str, get_path, append, capture_node_structure

### `start_up_scene_tree()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_class, get_ticks_msec, unlock, duplicate, lock

### `recreator_of_singular_thing()`
- **Lines:** 0
- **Parameters:** `data_set`
- **Returns:** `void`
- **Calls:** append, analise_data, clear, duplicate

### `recreate_missing_nodes()`
- **Lines:** 0
- **Parameters:** `array_of_recreation`
- **Returns:** `void`
- **Calls:** print_tree_structure, unlock, disable_all_branches_reset_counters, has, lock, print, print_tree_pretty, unload_node_branch, size, split

### `unload_node_branch()`
- **Lines:** 0
- **Parameters:** `path_for_node_to_unload, recreation_of_node_data`
- **Returns:** `void`
- **Calls:** queue_free, jsh_tree_get_node, recreator_of_singular_thing, print, print_tree_pretty

### `attempt_container_repair()`
- **Lines:** 0
- **Parameters:** `container_name, missing_nodes`
- **Returns:** `void`
- **Calls:** unlock, split, has, lock, recreate_node_from_records

### `recreate_node_from_records()`
- **Lines:** 0
- **Parameters:** `container_name: String, node_type: String, records: Dictionary`
- **Returns:** `void`
- **Calls:** tasked_children, setup_main_reference, new, container_initialize, unlock, set_script, has_method, power_up_data_point, has, lock, print, log_error_state, int

### `tasked_children()`
- **Lines:** 0
- **Parameters:** `node_to_be_added, node_to_be_added_path`
- **Returns:** `void`
- **Calls:** unlock, join, lock, slice, append, size, split

### `process_active_records_for_tree()`
- **Lines:** 0
- **Parameters:** `active_records: Dictionary, set_name_to_process : String, container_name_here : String`
- **Returns:** `void`
- **Calls:** unlock, has, the_pretender_printer, lock, match_node_type

### `match_node_type()`
- **Lines:** 0
- **Parameters:** `type: String`
- **Returns:** `String`

### `the_pretender_printer()`
- **Lines:** 0
- **Parameters:** `node_name: String, node_path_jsh_tree: String, godot_node_type, node_type: String = "Node3D"`
- **Returns:** `void`
- **Calls:** get_base_dir, get_ticks_msec, unlock, duplicate, erase, has, lock, print, range, size, split

### `unload_container()`
- **Lines:** 0
- **Parameters:** `container_to_unload`
- **Returns:** `void`
- **Calls:** process_to_unload_records, cache_tree_branch_fully, unlock, erase, has, lock, print

### `unload_nodes()`
- **Lines:** 0
- **Parameters:** `array_of_thingiess_that_shall_remain`
- **Returns:** `void`
- **Calls:** get_children, queue_free, str, find_branch_to_unload, get_path, print

### `cache_tree_branch_fully()`
- **Lines:** 0
- **Parameters:** `container_to_unload`
- **Returns:** `void`
- **Calls:** unlock, disable_all_branches, erase, has, lock, print

### `cache_branch()`
- **Lines:** 0
- **Parameters:** `branch_name, child_name, branch_part`
- **Returns:** `void`
- **Calls:** unlock, disable_all_branches, has, lock, print

### `the_finisher_for_nodes()`
- **Lines:** 0
- **Parameters:** `data_to_be_parsed`
- **Returns:** `void`
- **Calls:** jsh_tree_get_node_status_changer

### `disable_all_branches_reset_counters()`
- **Lines:** 0
- **Parameters:** `branch_to_disable, container_name_for_array`
- **Returns:** `void`
- **Calls:** unlock, call, duplicate, traverse_branch, has, lock, append, remove_at, size

### `jsh_tree_get_node_status_changer()`
- **Lines:** 0
- **Parameters:** `node_path_jsh_tree_status: String, node_name: String, node_to_check: Node`
- **Returns:** `void`
- **Calls:** create_new_task, unlock, has, lock, print, size, split

### `connect_containers()`
- **Lines:** 0
- **Parameters:** `container_name_0, container_name_1`
- **Returns:** `void`
- **Calls:** unlock, has, lock, print

### `disable_all_branches()`
- **Lines:** 0
- **Parameters:** `branch_to_disable`
- **Returns:** `void`
- **Calls:** unlock, call, duplicate, traverse_branch, has, lock, append, remove_at, size

### `check_quick_functions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, sixth_dimensional_magic, is_empty, size

### `check_short_functions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, is_empty, size, print

### `preparer_for_combos()`
- **Lines:** 0
- **Parameters:** `data_to_understand`
- **Returns:** `void`
- **Calls:** print, append, clear, size, split

### `call_some_thingy()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, process_delta_fake, print

### `process_turn_0()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `Dictionary`
- **Calls:** unlock, process_stages, size, lock

### `process_system_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** try_lock, unlock, ready_for_once, size, min, update_text_cursor_after, pop_front, lock, print, append, range, process_stages

### `process_system_1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_new_task, try_lock, add_child, unlock, get_node, get_node_or_null, min, pop_front, has, lock, print, append, range, size

### `process_system_2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_new_task, try_lock, unlock, get_node_or_null, min, duplicate, pop_front, lock, print, append, range, size

### `process_system_3()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** try_lock, get_children, unlock, min, pop_front, lock, deg_to_rad, range, size

### `process_system_4()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, create_new_task, try_lock, queue_free, unlock, get_node_or_null, length, min, check_magical_array, pop_front, check_if_we_are_adding_container, lock, print, append, range, size

### `process_system_5()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** try_lock, preparer_for_combos, unlock, call, get_node_or_null, has_method, min, pop_front, lock, print, range, size, split

### `process_system_6()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** try_lock, three_stages_of_creation, get_ticks_msec, unlock, get_node, check_if_scene_was_set, min, check_memory_state, pop_front, has, lock, print, append, range, size, check_if_already_loading_one

### `process_system_7()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_new_task, try_lock, check_if_datapoint_node_available, receive_a_message, check_if_container_available, unlock, set_connection_target, get_node_or_null, min, check_if_datapoint_moved_once, initialize_loading_file, pop_front, check_if_datapoint_available, lock, print, append, range, size

### `process_system_8()`
- **Lines:** 8
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, try_lock

### `process_system_9()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** generate_uvs_for_mesh, try_lock, new, unlock, get_node_or_null, min, change_material_settings, erase, print, range, size

### `change_material_settings()`
- **Lines:** 0
- **Parameters:** `material`
- **Returns:** `void`

### `apply_texture_with_proper_settings()`
- **Lines:** 0
- **Parameters:** `node_to_apply_texture, texture, node_type="default"`
- **Returns:** `void`
- **Calls:** faces, Vector3, generate_uvs_for_mesh, new

### `get_ray_points()`
- **Lines:** 0
- **Parameters:** `mouse_position: Vector2`
- **Returns:** `void`
- **Calls:** create, project_ray_normal, create_new_task, get_world_3d, intersect_ray, project_ray_origin, print, another_ray_cast, append

### `another_ray_cast()`
- **Lines:** 0
- **Parameters:** `result`
- **Returns:** `void`
- **Calls:** reset_debug_colors, highlight_collision_shape

### `process_ray_cast()`
- **Lines:** 0
- **Parameters:** `stuff`
- **Returns:** `void`
- **Calls:** create, project_ray_normal, get_world_3d, intersect_ray, project_ray_origin, reset_debug_colors, highlight_collision_shape

### `reset_debug_colors()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** reset_collider_debug_color, clear, is_instance_valid

### `reset_collider_debug_color()`
- **Lines:** 0
- **Parameters:** `collider`
- **Returns:** `void`
- **Calls:** get_children, Color

### `highlight_collision_shape()`
- **Lines:** 0
- **Parameters:** `collider`
- **Returns:** `void`
- **Calls:** get_children, Color, print, combo_checker, append

### `combo_checker()`
- **Lines:** 0
- **Parameters:** `node_to_check, state_of_button`
- **Returns:** `void`
- **Calls:** check_combo_patterns, get_ticks_msec, format_combo_for_display, is_empty, pop_front, print, or, append, size

### `format_combo_for_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, get_parent

### `check_combo_patterns()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, get_parent, print

### `ray_cast_data_preparer()`
- **Lines:** 0
- **Parameters:** `data_ray_cast`
- **Returns:** `void`
- **Calls:** multi_threaded_ray_cast, print

### `multi_threaded_ray_cast()`
- **Lines:** 0
- **Parameters:** `result, to, from`
- **Returns:** `void`
- **Calls:** thing_interaction, change_points_of_line, unlock, str, has_method, jsh_tree_get_node, get_path, has, lock, print, split

### `old_multi_thread_thingy()`
- **Lines:** 0
- **Parameters:** `result, to, from`
- **Returns:** `void`
- **Calls:** get_datapoint, thing_interaction, get_parent, unlock, call, str, has_method, jsh_tree_get_node, lock, print, begins_with, change_points_of_line

### `secondary_interaction_after_rc()`
- **Lines:** 0
- **Parameters:** `array_of_data`
- **Returns:** `void`
- **Calls:** unload_container, size

### `analise_data()`
- **Lines:** 0
- **Parameters:** `thing_name_, type, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed`
- **Returns:** `void`
- **Calls:** create_array_mesh, create_container, create_connection, create_textmesh, create_datapoint, create_text_label, create_circle_shape, create_cursor, print, create_screen, create_flat_shape, create_button_with_rounded_corners

### `create_circle_shape()`
- **Lines:** 0
- **Parameters:** `node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array`
- **Returns:** `void`
- **Calls:** generate_circle_points, create_flat_shape, int

### `generate_circle_points()`
- **Lines:** 0
- **Parameters:** `radius: float, num_points: int`
- **Returns:** `Array`
- **Calls:** sin, clamp, cos, append, range, split

### `create_flat_shape()`
- **Lines:** 0
- **Parameters:** `node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array`
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, node_creation, new, resize, PackedVector3Array, Vector3, get_spectrum_color, push_back, PackedInt32Array, append, range, float, size

### `create_text_label()`
- **Lines:** 0
- **Parameters:** `node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array`
- **Returns:** `void`
- **Calls:** node_creation, new, Color, int

### `create_array_mesh()`
- **Lines:** 0
- **Parameters:** `node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array`
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, node_creation, new, resize, PackedVector3Array, Vector3, get_spectrum_color, append, float

### `create_textmesh()`
- **Lines:** 0
- **Parameters:** `node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array`
- **Returns:** `void`
- **Calls:** new, get_spectrum_color, float, node_creation, int

### `generate_rounded_rect()`
- **Lines:** 0
- **Parameters:** `width: float, height: float, corner_radius: float, depth: float = 0.0`
- **Returns:** `Array`
- **Calls:** sin, str, min, cos, append, range

### `create_rounded_button()`
- **Lines:** 67
- **Parameters:** `node_name: String, first_line: Array, data_to_write: Array, group_name: String, version_of_thing: String, information_lines_parsed: Array, corner_radius: float = 0.1`
- **Returns:** `void`
- **Calls:** sin, max, str, create_button, min, cos, append, range, float

### `create_button()`
- **Lines:** 0
- **Parameters:** `node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array`
- **Returns:** `void`
- **Calls:** tasked_children, add_surface_from_arrays, node_creation, new, resize, PackedVector3Array, Vector3, PackedInt32Array, get_spectrum_color, push_back, Color, print, append, float, int

### `create_cursor()`
- **Lines:** 0
- **Parameters:** `node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array`
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, node_creation, new, resize, PackedVector3Array, Vector3, get_spectrum_color, append, float

### `create_connection()`
- **Lines:** 0
- **Parameters:** `node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array`
- **Returns:** `void`
- **Calls:** node_creation, new, surface_add_vertex, Vector3, surface_end, surface_begin, set_script, get_spectrum_color, float

### `create_screen()`
- **Lines:** 0
- **Parameters:** `node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array`
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, node_creation, new, resize, PackedVector3Array, Vector3, get_spectrum_color, append, float

### `create_datapoint()`
- **Lines:** 0
- **Parameters:** `node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array`
- **Returns:** `void`
- **Calls:** setup_main_reference, new, set_script, power_up_data_point, node_creation, int

### `create_container()`
- **Lines:** 0
- **Parameters:** `node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array`
- **Returns:** `void`
- **Calls:** container_initialize, new, has_method, set_script, print, node_creation, int

### `get_spectrum_color()`
- **Lines:** 0
- **Parameters:** `value: float`
- **Returns:** `Color`
- **Calls:** clamp, min, floor, Color, lerp, ceil

### `node_creation()`
- **Lines:** 0
- **Parameters:** `node_name, crafted_data, coords, to_rotate, group_number, node_type, path_of_thing`
- **Returns:** `void`
- **Calls:** tasked_children, add_collision_to_thing, add_texture_to_thing_task_creator, Vector3, add_to_group, float

### `add_texture_to_thing_task_creator()`
- **Lines:** 11
- **Parameters:** `thing_node, node_type, color_params, path_for_thing`
- **Returns:** `void`
- **Calls:** append, create_new_task

### `add_texture_to_thing_preparer()`
- **Lines:** 57
- **Parameters:** `data_to_create`
- **Returns:** `void`
- **Calls:** initialize_base_textures, unlock, get_spectrum_color, has, lock, print

### `initialize_base_textures()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create, Vector2, distance_to, set_pixel, create_from_image, unlock, clamp, set_texture, Color, lock, range

### `generate_rounded_rect_texture()`
- **Lines:** 0
- **Parameters:** `width, height, corner_radius, color_value=0.5, alpha_value=1.0`
- **Returns:** `void`
- **Calls:** create, Vector2, distance_to, set_pixel, create_from_image, min, get_spectrum_color, Color, add_noise_pattern, range, fill

### `add_texture_to_thing()`
- **Lines:** 0
- **Parameters:** `thing_node, node_type, mesh_data, color_params`
- **Returns:** `void`
- **Calls:** new, generate_texture_for_shape, set_meta, duplicate, is_textures_enabled

### `get_mesh_data()`
- **Lines:** 9
- **Parameters:** `node`
- **Returns:** `void`
- **Calls:** get_faces, append

### `toggle_textures()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_meta, print, get_tree, has_meta, get_nodes_in_group

### `is_textures_enabled()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `generate_texture_for_shape()`
- **Lines:** 0
- **Parameters:** `shape_data, node_type, default_params=null`
- **Returns:** `void`
- **Calls:** create, Vector2, draw_gradient_texture, create_from_image, draw_screen_texture, is_empty, draw_circle_texture, draw_button_texture, has, Color, draw_polygon_texture, append, int, float, size, split, fill

### `draw_polygon_texture()`
- **Lines:** 0
- **Parameters:** `img, vertices, color_value, alpha_value`
- **Returns:** `void`
- **Calls:** max, Vector2, distance_to, set_pixel, min, is_point_in_polygon, get_spectrum_color, get_width, add_noise_pattern, append, get_height, range

### `draw_gradient_fill()`
- **Lines:** 0
- **Parameters:** `img, base_color`
- **Returns:** `void`
- **Calls:** set_pixel, Color, get_width, get_height, range, float, lerp

### `draw_ring()`
- **Lines:** 0
- **Parameters:** `img, center, radius, color, thickness=2.0`
- **Returns:** `void`
- **Calls:** Vector2, get_pixel, distance_to, set_pixel, abs, get_width, get_height, range, lerp

### `is_point_in_polygon()`
- **Lines:** 0
- **Parameters:** `point, polygon`
- **Returns:** `void`
- **Calls:** range, size

### `draw_circle_texture()`
- **Lines:** 0
- **Parameters:** `img, radius, num_points, color_value, alpha_value`
- **Returns:** `void`
- **Calls:** sin, darkened, Vector2, distance_to, set_pixel, min, get_spectrum_color, draw_ring, cos, get_width, add_noise_pattern, lightened, append, get_height, range, lerp

### `draw_button_texture()`
- **Lines:** 0
- **Parameters:** `img, vertices, color_value, alpha_value`
- **Returns:** `void`
- **Calls:** max, Vector2, distance_to, set_pixel, min, abs, lightened, is_point_in_polygon, get_spectrum_color, closest_point_on_segment, get_width, add_noise_pattern, darkened, append, get_height, range, size, lerp

### `draw_screen_texture()`
- **Lines:** 0
- **Parameters:** `img, vertices, color_value, alpha_value`
- **Returns:** `void`
- **Calls:** max, Vector2, distance_to, set_pixel, min, is_point_in_polygon, lightened, get_spectrum_color, get_width, add_noise_pattern, darkened, append, get_height, range, lerp

### `draw_gradient_texture()`
- **Lines:** 0
- **Parameters:** `img, color_value, alpha_value`
- **Returns:** `void`
- **Calls:** darkened, float, set_pixel, get_spectrum_color, get_width, add_noise_pattern, lightened, get_height, range, lerp

### `add_noise_pattern()`
- **Lines:** 0
- **Parameters:** `img, base_color, intensity`
- **Returns:** `void`
- **Calls:** get_pixel, new, set_pixel, randf, randomize, clamp, get_width, get_height, range

### `closest_point_on_segment()`
- **Lines:** 0
- **Parameters:** `p, a, b`
- **Returns:** `void`
- **Calls:** dot, clamp

### `generate_uvs_for_mesh()`
- **Lines:** 0
- **Parameters:** `mesh_instance`
- **Returns:** `void`
- **Calls:** max, Vector2, new, get_mesh, surface_remove, print, size, surface_get_format, PackedVector2Array, surface_get_primitive_type, add_surface_from_arrays, surface_get_arrays, surface_get_material, push_back, get_aabb, get_surface_count, surface_set_material, range, surface_get_blend_shape_arrays

### `add_collision_to_thing()`
- **Lines:** 0
- **Parameters:** `thing_node, node_type, path_of_thingy, name_of_thingy`
- **Returns:** `void`
- **Calls:** get_faces, tasked_children, new, PackedVector3Array, Vector3, push_back, get_aabb

### `check_system_function()`
- **Lines:** 0
- **Parameters:** `check_name: String`
- **Returns:** `bool`
- **Calls:** is_creation_possible

### `check_if_scene_was_set()`
- **Lines:** 0
- **Parameters:** `container_now`
- **Returns:** `void`
- **Calls:** get_datapoint, str, get_node_or_null, print, lets_move_them_again

### `setup_system_checks()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `test_init()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** validate_system_environment, append, retry_thread_initialization, validate_thread_system

### `retry_thread_initialization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `validate_system_environment()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec, get_name, get_processor_count, get_version_info

### `log_error_state()`
- **Lines:** 0
- **Parameters:** `error_type, details`
- **Returns:** `void`
- **Calls:** get_ticks_msec, unlock, has, lock, trigger_deep_repair, append

### `start_health_checks()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, get_tree, check_system_health

### `check_system_health()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** log_error_state, unlock, validate_container_state, lock

### `handle_random_errors()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, has, lock, print, int

### `trigger_deep_repair()`
- **Lines:** 0
- **Parameters:** `error_type: String`
- **Returns:** `void`
- **Calls:** is_instance_valid, keys, unlock, containers_states_checker, has, lock, print, containers_list_creator, append, clear, recreate_node_from_records, size, split

### `breaks_and_handles_check()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `breaks_and_handles_check_issue()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, try_lock, print

### `unlock_stuck_mutexes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, try_lock, print

### `check_first_time_status()`
- **Lines:** 0
- **Parameters:** `status_name: String`
- **Returns:** `bool`
- **Calls:** get, unlock, lock

### `is_creation_possible()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** get_ticks_msec, unlock, is_empty, lock, print, size

### `check_system_state()`
- **Lines:** 0
- **Parameters:** `state_name: String`
- **Returns:** `SystemState`
- **Calls:** get, unlock, lock

### `set_system_state()`
- **Lines:** 0
- **Parameters:** `state_name: String, new_state: SystemState`
- **Returns:** `bool`
- **Calls:** unlock, has, lock

### `check_system_readiness()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** is_empty, check_thread_status, print, has, breaks_and_handles_check, size

### `check_if_all_systems_are_green()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, check_all_things, add_stuff_to_basic, print

### `process_pre_delta_check()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** check_system_readiness, is_creation_possible, is_empty, print

### `get_system_state()`
- **Lines:** 0
- **Parameters:** `state_name: String`
- **Returns:** `Dictionary`
- **Calls:** has

### `print_system_metrics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_system_metrics, print

### `first_turn_validation()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec, track_delta_timing, size, check_thread_status

### `get_system_metrics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** filter, open, keys, get_next, size, get_property_list, get_node_count, ends_with, get_active_thread_count, get_tree, list_dir_end, list_dir_begin

### `initialize_integration()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** initialize_ai_system, initialize_reality_systems, initialize_command_system, register_records, test_thread_system

### `register_records()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_records_entries, add_available_record_sets

### `initialize_command_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_new_task, register_command_handlers

### `initialize_reality_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_new_task, print

### `initialize_physical_reality()`
- **Lines:** 0
- **Parameters:** `settings`
- **Returns:** `void`
- **Calls:** get_root, str, get_node_or_null, print, get_tree

### `initialize_digital_reality()`
- **Lines:** 0
- **Parameters:** `settings`
- **Returns:** `void`
- **Calls:** get_root, str, get_node_or_null, print, get_tree

### `initialize_astral_reality()`
- **Lines:** 0
- **Parameters:** `settings`
- **Returns:** `void`
- **Calls:** get_root, str, get_node_or_null, print, get_tree

### `initialize_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, create_new_task, has_method, connect, print, get_tree

### `initialize_digital_earthlings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** initialize_integration, load, add_child, get_node, has_node, has_method, instantiate, register_digital_earthlings_records, print

### `initialize_ai_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_new_task, open, print

### `load_gemma_model()`
- **Lines:** 0
- **Parameters:** `model_path`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, print

### `generate_ai_response()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** str, simulate_gemma_response, simulate_basic_response, print

### `_on_ai_error()`
- **Lines:** 0
- **Parameters:** `error_message`
- **Returns:** `void`
- **Calls:** print

### `query_ai()`
- **Lines:** 0
- **Parameters:** `prompt`
- **Returns:** `void`
- **Calls:** process

### `generate_from_word()`
- **Lines:** 0
- **Parameters:** `word: String`
- **Returns:** `void`
- **Calls:** new, get_ticks_msec, sha1_text, randf, generate_density_field, randi, march_cubes, hash

### `generate_guardian_message()`
- **Lines:** 0
- **Parameters:** `action: String`
- **Returns:** `String`
- **Calls:** randi, size, seed

### `simulate_gemma_response()`
- **Lines:** 0
- **Parameters:** `message, context`
- **Returns:** `void`
- **Calls:** contains, keys, to_lower, randi, size

### `simulate_basic_response()`
- **Lines:** 0
- **Parameters:** `message`
- **Returns:** `void`
- **Calls:** randi, size

### `_cmd_reality()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** find_interface_text_node, to_upper

### `_cmd_help()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** find_interface_text_node

### `setup_command_processor()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_meta

### `show_welcome_message()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** find_interface_text_node

### `register_command_handlers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_new_task

### `cmd_help()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** state, print

### `get_lod()`
- **Lines:** 0
- **Parameters:** `distance`
- **Returns:** `void`

### `generate_icosphere()`
- **Lines:** 0
- **Parameters:** `lod`
- **Returns:** `void`

### `load_chunk()`
- **Lines:** 0
- **Parameters:** `position`
- **Returns:** `void`
- **Calls:** has, get

### `generate_icosphere_old()`
- **Lines:** 6
- **Parameters:** `lod: int, time: float`
- **Returns:** `ArrayMesh`
- **Calls:** sin, float, lerp, int

### `_init()`
- **Lines:** 6
- **Parameters:** `pos: Vector3, seed_hash: String`
- **Returns:** `void`
- **Calls:** get_unix_time_from_system

### `_init()`
- **Lines:** 0
- **Parameters:** `pos: Vector3, dir: Vector3, word: String`
- **Returns:** `void`
- **Calls:** get_unix_time_from_system

### `load_chunk_old()`
- **Lines:** 0
- **Parameters:** `position: Vector3, word_seed: String`
- **Returns:** `ChunkData`
- **Calls:** new, erase, has, values, size, get_unix_time_from_system

### `march_cubes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `ArrayMesh`
- **Calls:** add_surface_from_arrays, new, resize, PackedVector3Array, normalized, append, cross

### `generate_density_field()`
- **Lines:** 0
- **Parameters:** `word: String, time: float`
- **Returns:** `void`
- **Calls:** calculate_word_density, Vector3, smoothstep, distance_to

### `check_for_deja_vu()`
- **Lines:** 0
- **Parameters:** `concept, details`
- **Returns:** `void`
- **Calls:** trigger_deja_vu, unlock, Vector3, str, has, lock, print, size

### `trigger_normal_cleanup()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** keys, get_ticks_msec, unlock, erase, remove, lock, print, size

### `trigger_emergency_cleanup()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** keys, unlock, lock, print, size

### `spawn_guardian()`
- **Lines:** 0
- **Parameters:** `guardian_data`
- **Returns:** `void`
- **Calls:** first_dimensional_magic, generate_guardian_message, str, Vector3, has_method, emit, print, get

### `shift_reality()`
- **Lines:** 0
- **Parameters:** `new_reality`
- **Returns:** `void`
- **Calls:** apply_reality_rules, unlock, str, trigger_transition_effect, has, lock, print, emit_signal
- **Signals:** reality_shifted

### `apply_reality_rules()`
- **Lines:** 0
- **Parameters:** `reality_type`
- **Returns:** `void`
- **Calls:** apply_color_palette

### `apply_color_palette()`
- **Lines:** 0
- **Parameters:** `palette_name`
- **Returns:** `void`
- **Calls:** get_node_or_null, print

### `trigger_transition_effect()`
- **Lines:** 0
- **Parameters:** `from_reality, to_reality`
- **Returns:** `void`
- **Calls:** create_new_task, print

### `spawn_entity()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** get_ticks_msec, str, emit_signal, print
- **Signals:** entity_created

### `transform_entity()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** get, str, emit_signal, print
- **Signals:** entity_transformed

### `trigger_deja_vu()`
- **Lines:** 0
- **Parameters:** `action, location`
- **Returns:** `void`
- **Calls:** create_new_task, select_guardian_type, generate_guardian_message, str, emit_signal, print
- **Signals:** deja_vu_triggered

### `select_guardian_type()`
- **Lines:** 0
- **Parameters:** `action: String`
- **Returns:** `String`
- **Calls:** begins_with, str, keys

### `process_entity_interaction()`
- **Lines:** 0
- **Parameters:** `interaction_data, entity_path`
- **Returns:** `void`
- **Calls:** create_new_task, str, get_node_or_null, print, get

### `remember()`
- **Lines:** 0
- **Parameters:** `concept, details`
- **Returns:** `void`
- **Calls:** check_for_deja_vu, get_ticks_msec, unlock, str, pop_front, has, lock, print, append, size

### `recall()`
- **Lines:** 0
- **Parameters:** `concept`
- **Returns:** `void`
- **Calls:** unlock, str, duplicate, has, lock, print

### `_on_command_processed()`
- **Lines:** 0
- **Parameters:** `command, result`
- **Returns:** `void`
- **Calls:** remember, print

### `_cmd_create()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** create_new_task, remember, print, range, size

### `_cmd_transform()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** create_new_task, remember, print, range, size

### `_cmd_remember()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** slice, join, size, remember

### `_cmd_shift()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** create_new_task, remember, str, has, print, size

### `initialize_command_parser()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, new, str, print, size

### `create_command_parser()`
- **Lines:** 0
- **Parameters:** `_unused`
- **Returns:** `void`
- **Calls:** set_meta, new

### `register_command()`
- **Lines:** 0
- **Parameters:** `data`
- **Returns:** `void`
- **Calls:** get_meta, register_command

### `parse_command()`
- **Lines:** 0
- **Parameters:** `input_text`
- **Returns:** `void`
- **Calls:** parse, get_meta, emit_signal
- **Signals:** command_processed

### `find_interface_text_node()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null

### `enter_command()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, has_method, parse_command, get_tree, eight_dimensional_magic

### `_cmd_guardian()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** join, Vector3, size

### `_cmd_deja_vu()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** trigger_deja_vu, Vector3

### `_cmd_spawn()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** first_dimensional_magic, Vector3, has_method, size

### `create_anomaly()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, apply_reality_rules, bind, create_glitch_effect, Vector3, randf, spawn_guardian, connect, Callable, duplicate, erase, randi, get_tree, size

### `toggle_reality_containers()`
- **Lines:** 0
- **Parameters:** `old_reality, new_reality`
- **Returns:** `void`
- **Calls:** get_node_or_null

### `cycle_reality()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** shift_reality, size, find

### `get_spatiotemporal_hash()`
- **Lines:** 0
- **Parameters:** `pos: Vector3, time_window: float`
- **Returns:** `String`
- **Calls:** floor, Vector3

### `get_spatiotemporal_hash_old()`
- **Lines:** 0
- **Parameters:** `pos: Vector3, time_window: float`
- **Returns:** `String`
- **Calls:** floor, Vector3

### `handle_snake_menu_interaction()`
- **Lines:** 0
- **Parameters:** `option, difficulty = "normal"`
- **Returns:** `void`
- **Calls:** display_high_scores, launch_snake_game, print

### `launch_snake_game()`
- **Lines:** 0
- **Parameters:** `difficulty`
- **Returns:** `void`
- **Calls:** three_stages_of_creation_snake, show_snake_game, get_node_or_null, print

### `display_high_scores()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, print

### `process_snake_button_click()`
- **Lines:** 0
- **Parameters:** `button_name`
- **Returns:** `void`
- **Calls:** handle_snake_menu_interaction, get_current_menu_context

### `get_current_menu_context()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_meta, has_meta, get_node_or_null

### `show_snake_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** three_stages_of_creation_snake, get_node_or_null, position_camera_for_snake_game, print, setup_snake_input_handling

### `hide_snake_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** restore_camera_position, get_node_or_null, restore_normal_input_handling, print

### `position_camera_for_snake_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, Vector3, has_node, get_node_or_null, set_meta, look_at

### `restore_camera_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, has_node, has_meta, get_meta

### `setup_snake_input_handling()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** character_stop, print

### `restore_normal_input_handling()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** character_move_backward, get_meta, character_move_left, character_move_forward, print, has_meta, character_move_right

### `_input_snake()`
- **Lines:** 0
- **Parameters:** `event`
- **Returns:** `void`
- **Calls:** character_move_backward, hide_snake_game, get_node_or_null, character_move_left, character_move_forward, show_snake_game, character_stop, character_move_right

### `_cmd_glitch()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** create_new_task, remember, str, min, has, print, size, int

### `apply_visual_glitch()`
- **Lines:** 0
- **Parameters:** `intensity, duration`
- **Returns:** `void`
- **Calls:** create_timer, the_fourth_dimensional_magic, has_method, connect, print, get_tree

### `apply_physics_glitch()`
- **Lines:** 0
- **Parameters:** `intensity, duration`
- **Returns:** `void`
- **Calls:** randf, Vector2

### `apply_audio_glitch()`
- **Lines:** 0
- **Parameters:** `intensity, duration`
- **Returns:** `void`
- **Calls:** create_timer, str, connect, print, get_tree

### `apply_time_glitch()`
- **Lines:** 0
- **Parameters:** `intensity, duration`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, randf, connect

### `create_glitch_effect()`
- **Lines:** 0
- **Parameters:** `parameter, intensity, duration_str`
- **Returns:** `void`
- **Calls:** substr, remember, str, length, sixth_dimensional_magic, min, print, ends_with, float, int

### `_cmd_speak()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** remember, join, print, slice, size, eight_dimensional_magic

### `calculate_word_density()`
- **Lines:** 0
- **Parameters:** `word: String, pos: Vector3, time: float`
- **Returns:** `float`
- **Calls:** sin, distance_to, Vector3, length, unicode_at, exp, cos

### `initialize_volume()`
- **Lines:** 0
- **Parameters:** `size: int`
- **Returns:** `void`
- **Calls:** resize

### `get_guardian_color()`
- **Lines:** 0
- **Parameters:** `guardian_type`
- **Returns:** `void`
- **Calls:** Color

### `get_reality_color()`
- **Lines:** 0
- **Parameters:** `reality`
- **Returns:** `void`
- **Calls:** Color

### `_on_main_node_signal()`
- **Lines:** 0
- **Parameters:** `signal_name, signal_data`
- **Returns:** `void`
- **Calls:** str, print

### `_on_task_discarded()`
- **Lines:** 0
- **Parameters:** `task`
- **Returns:** `void`
- **Calls:** str, print

### `_on_task_started()`
- **Lines:** 0
- **Parameters:** `task`
- **Returns:** `void`
- **Calls:** str, print

### `_on_reality_shifted()`
- **Lines:** 0
- **Parameters:** `old_reality, new_reality`
- **Returns:** `void`
- **Calls:** print

### `_on_guardian_spawned()`
- **Lines:** 0
- **Parameters:** `guardian_type, location`
- **Returns:** `void`
- **Calls:** str, print

### `_on_deja_vu_triggered()`
- **Lines:** 0
- **Parameters:** `trigger_data`
- **Returns:** `void`
- **Calls:** str, print

### `connect_signals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_signal, connect

### `apply_reality_shader()`
- **Lines:** 0
- **Parameters:** `reality_type`
- **Returns:** `void`
- **Calls:** sixth_dimensional_magic

### `register_with_banks_combiner()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, has

### `register_digital_earthlings_records()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_basic_set, has_method, has, print, append

### `test_thread_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, test_multi_threaded, str, multi_threads_start_checker, test_single_core, print, check_thread_status_type, get_tree

### `initialize_thread_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, get_node, str, has_node, connect, Callable, get_processor_count, print

### `cmd_threads()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** str, min, get_processor_count, print, size, int

### `cmd_thread_status()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** check_thread_status_type, print

### `cmd_reset_threads()`
- **Lines:** 0
- **Parameters:** `args`
- **Returns:** `void`
- **Calls:** str, get_processor_count, min, print

### `process_system_snake()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** get_node_or_null, has_method

### `character_move_forward()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, has_method, move_forward

### `character_move_backward()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** move_backward, get_node_or_null, has_method

### `character_move_left()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** move_left, get_node_or_null, has_method

### `character_move_right()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** move_right, get_node_or_null, has_method

### `character_stop()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, has_method, stop_moving

### `first_dimensional_magic_snake()`
- **Lines:** 0
- **Parameters:** `type_of_action_to_do, datapoint_node, additional_node = null`
- **Returns:** `void`
- **Calls:** character_move_backward, handle_input, hide_snake_game, get_node_or_null, has_method, character_move_left, character_move_forward, show_snake_game, character_stop, character_move_right

### `three_stages_of_creation_snake()`
- **Lines:** 0
- **Parameters:** `set_name: String`
- **Returns:** `void`
- **Calls:** new, add_child, load, unlock, Vector3, get_node_or_null, set_script, has, lock, print

### `create_character()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, load, add_child, Vector3, get_node_or_null, set_script, print

### `create_racing_game_integrator()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, load, add_child, get_node_or_null, set_script, print

### `create_records_entries()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append

### `add_available_record_sets()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_basic_set, has_method

### `initialize_console_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** load, create_racing_game_integrator, new, print

### `start_racing_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** seventh_dimensional_magic, create_new_task, unlock, get_node_or_null, lock, print, append

### `position_camera_for_racing_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, Vector3, has_node, get_node_or_null, set_meta, look_at

### `setup_racing_game_input_handling()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `set_up_racing_game()`
- **Lines:** 0
- **Parameters:** `container_name, visibility`
- **Returns:** `void`
- **Calls:** setup_main_reference, new, load, add_child, unlock, get_node_or_null, set_script, has_method, position_camera_for_racing_game, setup_racing_game_input_handling, lock, print, append

### `hide_racing_game()`
- **Lines:** 68
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** restore_normal_input_handling, get_meta, get_node_or_null, print, restore_camera_position, has_meta


## scripts/jsh_framework/core/pallets_racing_game.gd
**Category:** Core Systems
**Functions:** 14

### `setup_main_reference()`
- **Lines:** 0
- **Parameters:** `main_ref`
- **Returns:** `void`
- **Calls:** print

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** initialize_racing_game, print

### `initialize_racing_game()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** setup_player_vehicle, setup_race_ui, setup_race_track, print

### `setup_race_track()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** setup_checkpoints, new, add_child, Vector3, create_pallet_obstacle, Color, print

### `create_pallet_obstacle()`
- **Lines:** 0
- **Parameters:** `position: Vector3`
- **Returns:** `void`
- **Calls:** Vector3, new, Color, add_child

### `setup_checkpoints()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, str, Color, range, size

### `setup_player_vehicle()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, Color, print

### `setup_race_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, Vector3, new, print

### `start_race()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, print

### `process_input()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** is_action_pressed, clamp, is_action_just_pressed, start_race, rotate_y

### `_process()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** process_input, get_node, str, finish_race, snapped

### `finish_race()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, str, snapped, print

### `reset_race()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, Vector3

### `exit_to_menu()`
- **Lines:** 5
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_method, hide_racing_game, print


## scripts/jsh_framework/core/racing_menu_integrator.gd
**Category:** Core Systems
**Functions:** 3

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, get_parent, load, add_child, register_racing_actions, print, get_tree, add_racing_to_menu

### `register_racing_actions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_action, has_method, print

### `add_racing_to_menu()`
- **Lines:** 21
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_menu_button, add_menu_button, has_method, print


## scripts/jsh_framework/core/record_set_manager.gd
**Category:** Core Systems
**Functions:** 12

### `check_all_things()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `add_stuff_to_basic()`
- **Lines:** 0
- **Parameters:** `list_of_things`
- **Returns:** `void`
- **Calls:** is_empty

### `check_basic_set_if_loaded()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_empty, print

### `add_record_set_to_list()`
- **Lines:** 0
- **Parameters:** `key_input_a, key_input_b, record_pack`
- **Returns:** `void`
- **Calls:** has, print

### `get_all_records_packs()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `get_one_records_pack()`
- **Lines:** 0
- **Parameters:** `key_input_a, key_input_b`
- **Returns:** `void`
- **Calls:** has, print

### `compare_list_of_records()`
- **Lines:** 0
- **Parameters:** `key_input_a, key_input_b, record_pack`
- **Returns:** `void`
- **Calls:** has, print

### `add_record_set()`
- **Lines:** 0
- **Parameters:** `set_name: String, data: Dictionary`
- **Returns:** `bool`
- **Calls:** get_ticks_msec, unlock, lock

### `get_record_set()`
- **Lines:** 0
- **Parameters:** `set_name: String`
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec, unlock, erase, lock

### `cache_record_set()`
- **Lines:** 0
- **Parameters:** `set_name: String`
- **Returns:** `bool`
- **Calls:** unlock, erase, lock

### `cleanup_cache()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sort_custom, keys, get_ticks_msec, unlock, erase, pop_front, lock, values, get_record_size

### `get_record_size()`
- **Lines:** 9
- **Parameters:** `record: Dictionary`
- **Returns:** `int`
- **Calls:** length


## scripts/jsh_framework/core/scene_tree_check.gd
**Category:** Core Systems
**Functions:** 1

### `_ready()`
- **Lines:** 6
- **Parameters:** ``
- **Returns:** `void`


## scripts/jsh_framework/core/system_check.gd
**Category:** Core Systems
**Functions:** 21

### `check_all_things()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_init()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** initialize_word_system, scan_available_storage, print

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** bind, get_node, has_node, connect, has_signal

### `find_matching_symbols()`
- **Lines:** 0
- **Parameters:** `text: String, start_symbol: String, end_symbol: String`
- **Returns:** `Array`
- **Calls:** substr, append, range, length

### `verify_system_component()`
- **Lines:** 0
- **Parameters:** `component_name: String`
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec, unlock, lock

### `_on_system_ready()`
- **Lines:** 6
- **Parameters:** `system_name: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, unlock, lock

### `verify_system()`
- **Lines:** 0
- **Parameters:** `system_name: String`
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec, emit_signal
- **Signals:** system_verified

### `get_data_structure_size()`
- **Lines:** 48
- **Parameters:** `data`
- **Returns:** `int`
- **Calls:** var_to_bytes, typeof, length, size, get_data_structure_size

### `get_jsh()`
- **Lines:** 0
- **Parameters:** `property_name: String`
- **Returns:** `void`

### `check_memory_state()`
- **Lines:** 30
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** keys, get_ticks_msec, get_jsh, print, clean_dictionary, clean_array, get_data_structure_size

### `clean_dictionary()`
- **Lines:** 0
- **Parameters:** `dict_name: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, erase, get, keys

### `clean_array()`
- **Lines:** 0
- **Parameters:** `array_name: String`
- **Returns:** `void`
- **Calls:** slice, filter, get_ticks_msec, size

### `scan_available_storage()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, dir_exists_absolute, to_lower, get_name, char, range

### `initialize_word_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has

### `get_next_word()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_ticks_msec, append

### `map_data_to_word()`
- **Lines:** 0
- **Parameters:** `data_type: String, data_path: String`
- **Returns:** `String`
- **Calls:** get_ticks_msec, get_next_word

### `create_zip_archive()`
- **Lines:** 0
- **Parameters:** `archive_name: String, source_path: String`
- **Returns:** `bool`
- **Calls:** dir_exists_absolute, make_dir_recursive_absolute, _create_zip_file

### `_create_zip_file()`
- **Lines:** 0
- **Parameters:** `zip_path: String, source_path: String`
- **Returns:** `void`
- **Calls:** open, map_data_to_word, get_file_as_bytes, get_ticks_msec, get_files, store_var, size

### `extract_zip_archive()`
- **Lines:** 0
- **Parameters:** `zip_path: String, extract_path: String`
- **Returns:** `bool`
- **Calls:** eof_reached, open, store_buffer, dir_exists_absolute, make_dir_recursive_absolute, get_var

### `get_file_by_word()`
- **Lines:** 0
- **Parameters:** `word: String`
- **Returns:** `String`
- **Calls:** has

### `generate_word_report()`
- **Lines:** 24
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** sort_custom, min, append, range, size


## scripts/jsh_framework/core/system_interfaces.gd
**Category:** Core Systems
**Functions:** 2

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_process()`
- **Lines:** 3
- **Parameters:** `delta: float`
- **Returns:** `void`


## scripts/jsh_framework/core/text_label.gd
**Category:** Core Systems
**Functions:** 2

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_process()`
- **Lines:** 3
- **Parameters:** `delta: float`
- **Returns:** `void`


## scripts/jsh_framework/core/text_screen.gd
**Category:** Core Systems
**Functions:** 197

### `register_command()`
- **Lines:** 0
- **Parameters:** `name: String, callback: Callable`
- **Returns:** `void`
- **Calls:** to_lower

### `unregister_command()`
- **Lines:** 0
- **Parameters:** `name: String`
- **Returns:** `void`
- **Calls:** erase, has, to_lower

### `execute_command()`
- **Lines:** 36
- **Parameters:** `name: String, args: Array`
- **Returns:** `Dictionary`
- **Calls:** has, to_lower

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_display, _setup_components, _setup_signals, emit_signal, find_integration_nodes
- **Signals:** window_focused

### `_process()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _update_cursor_position, project_ray_normal, get_mouse_position, Vector3, get_viewport, project_ray_origin, is_mouse_button_pressed, Plane, intersects_ray, get_camera_3d

### `_input()`
- **Lines:** 0
- **Parameters:** `event`
- **Returns:** `void`
- **Calls:** substr, unfocus, _update_display, _submit_text, char, scroll_messages_up, length, _navigate_command_history, scroll_messages_down

### `_ready_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_default_commands, set_text, emit_signal, find_integration_nodes, setup_signals, setup_window
- **Signals:** window_focused

### `_process_0()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _update_cursor_position, project_ray_normal, get_mouse_position, Vector3, get_viewport, project_ray_origin, is_mouse_button_pressed, Plane, intersects_ray, get_camera_3d

### `_input_0()`
- **Lines:** 0
- **Parameters:** `event`
- **Returns:** `void`
- **Calls:** substr, unfocus, _update_display, _submit_text, char, scroll_messages_up, length, _navigate_command_history, scroll_messages_down

### `_setup_components()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_border, new, add_child, Vector3, duplicate, create_control_buttons, create_text_area

### `_create_border()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `_setup_signals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect

### `find_integration_nodes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** track_data_flow, get_node_or_null, has_method

### `setup_window()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_window_background, create_control_buttons, create_input_line, create_text_area, create_cursor, create_title_bar

### `setup_signals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect

### `find_integration_nodes_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** track_data_flow, get_node_or_null, has_method

### `register_default_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command

### `create_window_background()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_window_collision, new, add_child, Vector3, create_border

### `create_border()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `create_title_bar()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, Vector3, Color

### `create_text_area()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** int, Vector3, new, add_child

### `create_control_buttons()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_button, Vector3, Vector2, Color

### `create_input_line()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `create_cursor()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `create_button()`
- **Lines:** 0
- **Parameters:** `name, position, size, color, label_text`
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, connect, _on_button_input_event

### `add_window_collision()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, connect, new, add_child

### `_on_window_input_event()`
- **Lines:** 0
- **Parameters:** `camera, event, position, normal, shape_idx`
- **Returns:** `void`
- **Calls:** focus

### `_on_window_mouse_entered()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** min

### `_on_window_mouse_exited()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_on_button_input_event()`
- **Lines:** 0
- **Parameters:** `name, camera, event, pos, normal, shape_idx`
- **Returns:** `void`
- **Calls:** get_parent, queue_free, toggle_minimized, scroll_messages_up, emit_signal, remove_child, scroll_messages_down
- **Signals:** window_closed

### `_on_cursor_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_submit_text()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, _update_display, add_text, _process_command, push_front, length, emit, begins_with, strip_edges, size, pop_back

### `_navigate_command_history()`
- **Lines:** 0
- **Parameters:** `up: bool`
- **Returns:** `void`
- **Calls:** _update_display, length, is_empty, size

### `_update_cursor_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, Vector3, length

### `_process_command()`
- **Lines:** 0
- **Parameters:** `command_text: String`
- **Returns:** `void`
- **Calls:** add_text, execute_command, emit, slice, strip_edges, size, split

### `_update_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** join, _update_border_color

### `_update_border_color()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** range, Color, get_child

### `toggle_minimized()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_display

### `scroll_messages_up()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** max, size, min, update_text_display

### `scroll_messages_down()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** max, update_text_display

### `update_text_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** min, range, size, split

### `add_text()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** append, remove_at, size, _update_display

### `clear_text()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_display, clear

### `focus()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, _update_display

### `unfocus()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, _update_display

### `register_command()`
- **Lines:** 0
- **Parameters:** `command_name: String, callback: Callable`
- **Returns:** `void`
- **Calls:** register_command

### `resize()`
- **Lines:** 0
- **Parameters:** `new_width, new_height`
- **Returns:** `void`
- **Calls:** _update_display, Vector2, get_children, queue_free, emit_signal, remove_child, setup_signals, setup_window
- **Signals:** window_resized

### `set_text()`
- **Lines:** 0
- **Parameters:** `text_content, format_links = true`
- **Returns:** `void`
- **Calls:** process_text_links, _update_display, max, track_data_flow, length, has_method, count, emit_signal, size, split
- **Signals:** text_updated

### `process_text_links()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, compile, search_all, get_end, split, replace, clear, get_start, get_string

### `_submit_text_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, _update_display, add_text, _process_command, push_front, length, emit, begins_with, strip_edges, size, pop_back

### `_navigate_command_history_0()`
- **Lines:** 0
- **Parameters:** `up: bool`
- **Returns:** `void`
- **Calls:** _update_display, length, is_empty, size

### `_update_cursor_position_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, Vector3, length

### `_process_command_0()`
- **Lines:** 0
- **Parameters:** `command_text: String`
- **Returns:** `void`
- **Calls:** add_text, execute_command, emit, slice, strip_edges, size, split

### `_on_cursor_timer_timeout_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_update_display_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** join, _update_border_color

### `_update_border_color_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** range, Color, get_child

### `add_text_0()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** append, remove_at, size, _update_display

### `clear_text_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_display, clear

### `focus_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, _update_display

### `unfocus_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, _update_display

### `register_command_0()`
- **Lines:** 0
- **Parameters:** `command_name: String, callback: Callable`
- **Returns:** `void`
- **Calls:** register_command

### `resize_0()`
- **Lines:** 0
- **Parameters:** `new_width, new_height`
- **Returns:** `void`
- **Calls:** _update_display, Vector2, get_children, queue_free, _setup_components, _setup_signals, emit_signal, remove_child
- **Signals:** window_resized

### `set_text_0()`
- **Lines:** 0
- **Parameters:** `text_content, format_links = true`
- **Returns:** `void`
- **Calls:** process_text_links, max, track_data_flow, length, has_method, count, emit_signal, update_text_display
- **Signals:** text_updated

### `update_text_display_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** min, range, size, split

### `process_text_links_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, compile, search_all, get_end, replace, clear, get_start, get_string

### `create_control_buttons_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_button, Vector3, Vector2, Color

### `create_button_0()`
- **Lines:** 0
- **Parameters:** `name, position, size, color, label_text`
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, connect, _on_button_input_event

### `_on_button_input_event_0()`
- **Lines:** 0
- **Parameters:** `name, camera, event, pos, normal, shape_idx`
- **Returns:** `void`
- **Calls:** get_parent, queue_free, toggle_minimized, scroll_messages_up, emit_signal, remove_child, scroll_messages_down
- **Signals:** window_closed

### `toggle_minimized_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_display

### `scroll_messages_up_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** max, size, min, update_text_display

### `scroll_messages_down_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** max, update_text_display

### `add_system_message()`
- **Lines:** 0
- **Parameters:** `message`
- **Returns:** `void`
- **Calls:** add_message

### `add_message()`
- **Lines:** 0
- **Parameters:** `message, sender_name = "User"`
- **Returns:** `void`
- **Calls:** add_text, track_data_flow, get_time_string_from_system, length, has_method, emit_signal
- **Signals:** message_sent

### `link_to_datapoint()`
- **Lines:** 0
- **Parameters:** `datapoint_path: String`
- **Returns:** `void`
- **Calls:** set_text, register_window, str, has_method, get_datapoint_data

### `update_from_datapoint()`
- **Lines:** 0
- **Parameters:** `datapoint_path: String`
- **Returns:** `void`
- **Calls:** get_datapoint_data, str, set_text, has_method

### `create_text_area_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_window_collision, new, add_child, Vector3, int

### `add_window_collision_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, connect, new, add_child

### `_setup_components_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_border, new, add_child, Vector3, duplicate, create_control_buttons

### `_create_border_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `_setup_signals_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect

### `find_integration_nodes_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** track_data_flow, get_node_or_null, has_method

### `_process_old_v3()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _update_cursor_position

### `_input_old_v4()`
- **Lines:** 0
- **Parameters:** `event`
- **Returns:** `void`
- **Calls:** substr, unfocus, _update_display, _submit_text, char, scroll_messages_up, length, _navigate_command_history, scroll_messages_down

### `_submit_text_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, _update_display, add_text, _process_command, push_front, length, emit, begins_with, strip_edges, size, pop_back

### `_navigate_command_history_old()`
- **Lines:** 0
- **Parameters:** `up: bool`
- **Returns:** `void`
- **Calls:** _update_display, length, is_empty, size

### `_update_cursor_position_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, Vector3, length

### `_process_command_old()`
- **Lines:** 0
- **Parameters:** `command_text: String`
- **Returns:** `void`
- **Calls:** add_text, execute_command, emit, slice, strip_edges, size, split

### `_on_cursor_timer_timeout_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_update_display_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** join, _update_border_color

### `_update_border_color_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** range, Color, get_child

### `add_text_old()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** append, remove_at, size, _update_display

### `clear_text_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_display, clear

### `focus_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, _update_display

### `unfocus_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, _update_display

### `register_command_old()`
- **Lines:** 0
- **Parameters:** `command_name: String, callback: Callable`
- **Returns:** `void`
- **Calls:** register_command

### `resize_old()`
- **Lines:** 0
- **Parameters:** `new_width, new_height`
- **Returns:** `void`
- **Calls:** Vector2, emit_signal
- **Signals:** window_resized

### `set_text_old()`
- **Lines:** 0
- **Parameters:** `text_content, format_links = true`
- **Returns:** `void`
- **Calls:** process_text_links, max, track_data_flow, length, has_method, count, emit_signal, update_text_display
- **Signals:** text_updated

### `update_text_display_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** min, range, size, split

### `process_text_links_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, compile, search_all, get_end, replace, clear, get_start, get_string

### `create_control_buttons_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_button, Vector3, Vector2, Color

### `create_button_old()`
- **Lines:** 0
- **Parameters:** `name, position, size, color, label_text`
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, connect, _on_button_input_event

### `_on_button_input_event_old()`
- **Lines:** 0
- **Parameters:** `name, camera, event, pos, normal, shape_idx`
- **Returns:** `void`
- **Calls:** get_parent, queue_free, toggle_minimized, scroll_messages_up, emit_signal, remove_child, scroll_messages_down
- **Signals:** window_closed

### `toggle_minimized_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_display

### `scroll_messages_up_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** max, size, min, update_text_display

### `scroll_messages_down_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** max, update_text_display

### `add_system_message_old()`
- **Lines:** 0
- **Parameters:** `message`
- **Returns:** `void`
- **Calls:** add_message

### `add_message_old()`
- **Lines:** 0
- **Parameters:** `message, sender_name = "User"`
- **Returns:** `void`
- **Calls:** add_text, track_data_flow, get_time_string_from_system, length, has_method, emit_signal
- **Signals:** message_sent

### `create_text_window_container()`
- **Lines:** 0
- **Parameters:** `container_name: String, position: Vector3, size: Vector2 = Vector2(4, 3)`
- **Returns:** `Dictionary`

### `setup_text_window_commands()`
- **Lines:** 0
- **Parameters:** `window_node: JSHTextWindow`
- **Returns:** `void`
- **Calls:** register_command

### `_cmd_help_0()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** color

### `_cmd_clear()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `Dictionary`
- **Calls:** clear_text

### `change_color_of_letter_or_s()`
- **Lines:** 0
- **Parameters:** `string`
- **Returns:** `void`

### `_on_window_input_event_0()`
- **Lines:** 0
- **Parameters:** `camera, event, position, normal, shape_idx`
- **Returns:** `void`
- **Calls:** emit_signal
- **Signals:** window_focused

### `_on_window_mouse_entered_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** min

### `_on_window_mouse_exited_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `setup_window_0()`
- **Lines:** 5
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_window_background, create_title_bar

### `register_command()`
- **Lines:** 0
- **Parameters:** `name: String, callback: Callable`
- **Returns:** `void`
- **Calls:** to_lower

### `unregister_command()`
- **Lines:** 0
- **Parameters:** `name: String`
- **Returns:** `void`
- **Calls:** erase, has, to_lower

### `_ready_old_v3()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** setup_window, setup_input_handling, get_node_or_null, print

### `_ready_old_v2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_components, _update_display, _setup_signals

### `_ready_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, print, setup_cursor_blink, setup_window, setup_input_handling

### `_ready_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** setup_window, setup_input_handling, emit_signal, find_integration_nodes
- **Signals:** window_focused

### `_process_old()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** process_keyboard_input

### `_process_old_v1()`
- **Lines:** 0
- **Parameters:** `delta`
- **Returns:** `void`
- **Calls:** _update_cursor_position

### `_input_old()`
- **Lines:** 0
- **Parameters:** `event`
- **Returns:** `void`
- **Calls:** substr, unfocus, _update_display, _submit_text, char, length, _navigate_command_history

### `_input_old_v1()`
- **Lines:** 0
- **Parameters:** `event`
- **Returns:** `void`
- **Calls:** substr, add_message, max, scroll_messages_up, length, min, update_cursor_position, emit_signal, char, strip_edges, scroll_messages_down
- **Signals:** message_sent

### `_setup_signals_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect

### `clear_text_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_display, clear

### `focus_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, _update_display

### `unfocus_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, _update_display

### `register_command_old_v1()`
- **Lines:** 0
- **Parameters:** `command_name: String, callback: Callable`
- **Returns:** `void`
- **Calls:** register_command

### `add_system_message_old_v1()`
- **Lines:** 0
- **Parameters:** `message`
- **Returns:** `void`
- **Calls:** add_message

### `_cmd_teleport()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** str, Vector3, size

### `_cmd_resize()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** str, size, resize

### `_cmd_color()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** b, size, Color

### `setup_input_handling()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `process_keyboard_input()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_on_cursor_blink()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `setup_text_window_commands_old()`
- **Lines:** 0
- **Parameters:** `window_node: JSHTextWindow`
- **Returns:** `void`
- **Calls:** register_command

### `setup_cursor_blink()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, start, new, add_child

### `update_cursor_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3

### `setup_main_reference()`
- **Lines:** 0
- **Parameters:** `main_ref`
- **Returns:** `void`
- **Calls:** get_spectrum_color

### `create_window_background_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, add_window_collision, new, add_child, resize, PackedVector3Array, Vector3, has_method, get_spectrum_color, Color, PackedInt32Array, append, GetSpectrumColor

### `create_title_bar_0()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, new, add_child, resize, PackedVector3Array, Vector3, has_method, get_spectrum_color, Color, PackedInt32Array, append, GetSpectrumColor

### `create_message_area()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `create_input_field()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, Vector2, new, add_child, resize, PackedVector3Array, Vector3, has_method, get_spectrum_color, update_cursor_position, Color, PackedInt32Array, append

### `update_message_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** max, get_children, new, add_child, queue_free, Vector3, min, Color, range, size, int

### `resize_old_v1()`
- **Lines:** 0
- **Parameters:** `new_width, new_height`
- **Returns:** `void`
- **Calls:** Vector2, emit_signal
- **Signals:** window_resized

### `setup_input_handling_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `set_text_old_v1()`
- **Lines:** 0
- **Parameters:** `string_text`
- **Returns:** `void`
- **Calls:** print

### `change_color_of_letter_or_s_old()`
- **Lines:** 0
- **Parameters:** `string`
- **Returns:** `void`
- **Calls:** print

### `create_control_buttons_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `create_text_area_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `create_title_bar_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_setup_components_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_border, new, add_child, Vector3, duplicate

### `_create_border_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `_submit_text_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, _update_display, add_text, _process_command, push_front, length, emit, begins_with, strip_edges, size, pop_back

### `_navigate_command_history_old_v1()`
- **Lines:** 0
- **Parameters:** `up: bool`
- **Returns:** `void`
- **Calls:** _update_display, length, is_empty, size

### `add_text_old_v1()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** append, remove_at, size, _update_display

### `_update_display_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** join, _update_border_color

### `_update_border_color_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** range, Color, get_child

### `_update_cursor_position_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** substr, Vector3, length

### `_process_command_old_v1()`
- **Lines:** 0
- **Parameters:** `command_text: String`
- **Returns:** `void`
- **Calls:** add_text, execute_command, emit, slice, strip_edges, size, split

### `_on_cursor_timer_timeout_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `create_text_window_container_old()`
- **Lines:** 0
- **Parameters:** `container_name: String, position: Vector3, size: Vector2 = Vector2(4, 3)`
- **Returns:** `Dictionary`

### `_cmd_help_old()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** color

### `_cmd_clear_old()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `Dictionary`

### `_cmd_teleport_old()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** str, Vector3, size

### `_cmd_resize_old()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** str, size

### `_cmd_color_old()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** b, size, Color

### `find_integration_nodes_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** track_data_flow, get_node_or_null, has_method

### `scroll_messages_up_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** max, update_message_display, min, size, int

### `scroll_messages_down_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** max, update_message_display

### `create_text_area_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** int, Vector3, new, add_child

### `create_control_buttons_old_v2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_button, Vector3, Vector2, Color

### `create_button_old_v1()`
- **Lines:** 0
- **Parameters:** `name, position, size, color, label_text`
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, connect, _on_button_input_event

### `_on_button_input_event_old_v1()`
- **Lines:** 0
- **Parameters:** `name, camera, event, pos, normal, shape_idx`
- **Returns:** `void`
- **Calls:** print

### `add_window_collision_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, connect, new, add_child

### `set_text_old_v2()`
- **Lines:** 0
- **Parameters:** `text_content, format_links = true`
- **Returns:** `void`
- **Calls:** process_text_links, max, track_data_flow, length, has_method, count, emit_signal, update_text_display
- **Signals:** text_updated

### `update_text_display_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `process_text_links_old_v2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, compile, search_all, clear, get_string

### `create_window_background_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, add_window_collision, new, add_child, resize, PackedVector3Array, Vector3, has_method, get_spectrum_color, Color, PackedInt32Array, append

### `create_title_bar_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, new, add_child, resize, PackedVector3Array, Vector3, has_method, get_spectrum_color, Color, PackedInt32Array, append

### `create_control_buttons_old_v3()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_button, Vector3, Vector2, Color

### `create_button_old_v2()`
- **Lines:** 0
- **Parameters:** `name, position, size, color, label_text`
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `add_window_collision_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, connect, new, add_child

### `add_message_old_v1()`
- **Lines:** 0
- **Parameters:** `message, sender_name = "User"`
- **Returns:** `void`
- **Calls:** update_message_display, track_data_flow, get_time_string_from_system, length, has_method, append, remove_at, size

### `toggle_minimized_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** update_message_display

### `create_window_background_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_surface_from_arrays, new, add_child, resize, PackedVector3Array, Vector3, PackedInt32Array, append

### `setup_window_old()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_window_background, add_system_message, create_control_buttons, create_message_area, create_input_field, create_title_bar

### `setup_window_old_v1()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_window_background, set_text, create_control_buttons, create_text_area, create_title_bar

### `_setup_signals_old_v2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect

### `clear_text_old_v2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_display, clear

### `focus_old_v2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, _update_display

### `unfocus_old_v2()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, _update_display

### `register_command_old_v2()`
- **Lines:** 0
- **Parameters:** `command_name: String, callback: Callable`
- **Returns:** `void`
- **Calls:** register_command

### `add_system_message_old_v2()`
- **Lines:** 3
- **Parameters:** `message`
- **Returns:** `void`
- **Calls:** add_message


## scripts/jsh_framework/core/thread_pool_manager.gd
**Category:** Core Systems
**Functions:** 9

### `_init()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** setup_thread_pool

### `setup_thread_pool()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** range

### `add_task()`
- **Lines:** 0
- **Parameters:** `task_data`
- **Returns:** `void`
- **Calls:** unlock, push_back, lock, process_queue

### `process_queue()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** unlock, is_empty, pop_front, find_available_thread, lock, start_task

### `find_available_thread()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `start_task()`
- **Lines:** 0
- **Parameters:** `thread_id, task`
- **Returns:** `void`
- **Calls:** new, bind, get_ticks_msec, Callable, start

### `cleanup_thread()`
- **Lines:** 0
- **Parameters:** `thread_id`
- **Returns:** `void`
- **Calls:** process_queue

### `check_timeouts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, handle_timeout

### `handle_timeout()`
- **Lines:** 8
- **Parameters:** `thread_id`
- **Returns:** `void`
- **Calls:** wait_to_finish, emit, is_alive, cleanup_thread


## scripts/jsh_framework/jsh_adapter.gd
**Category:** JSH Framework
**Functions:** 1

### `initialize_jsh_for_ragdoll()`
- **Lines:** 31
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_main_loop, get_node_or_null, has_method, print, setup_terminal_variables


## scripts/main_game_controller.gd
**Category:** Utility Scripts
**Functions:** 21

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_connections, new, _on_systems_ready, add_child, load, str, _add_quick_test_commands, set_script, connect, _setup_jsh_framework, print, size, register_console_commands

### `_setup_jsh_framework()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, connect, new, print

### `_on_jsh_tree_updated()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_on_jsh_branch_added()`
- **Lines:** 0
- **Parameters:** `branch_path: String, _branch_data: Dictionary`
- **Returns:** `void`
- **Calls:** contains, get_node_or_null

### `_on_systems_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _enable_game_features, print

### `_on_startup_error()`
- **Lines:** 0
- **Parameters:** `error_message: String`
- **Returns:** `void`
- **Calls:** print, push_error

### `_enable_game_features()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_ui_elements, _setup_input_handlers, _setup_layer_system, _setup_dimensional_ragdoll, print, _setup_akashic_bridge, _setup_mouse_interaction

### `_setup_input_handlers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, set_script, print

### `_setup_ui_elements()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, set_script, print

### `get_system_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_system_status

### `run_health_check()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** run_health_check

### `test_floodgate()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** test_floodgate_system

### `is_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`

### `_setup_ragdoll_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, load, add_child, push_error, get_node_or_null, set_script, print

### `_setup_astral_beings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, print

### `_setup_mouse_interaction()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, load, add_child, push_error, get_node_or_null, set_script, print

### `_setup_dimensional_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, print

### `_setup_layer_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, get_node, has_node, set_script, print, register_console_commands

### `_setup_akashic_bridge()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, push_error, get_node_or_null, set_script, print, register_console_commands

### `_add_quick_test_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, get_node_or_null, _add_test_commands_to_console, print, get_tree, range

### `_add_test_commands_to_console()`
- **Lines:** 83
- **Parameters:** `console: Node`
- **Returns:** `void`
- **Calls:** create_timer, _print_to_console, new, add_child, load, get_ticks_msec, Vector3, str, get_node_or_null, set_script, queue_free, has_method, _cmd_tutorial, quit, print, get_tree


## scripts/old_implementations/ragdoll_with_legs.gd
**Category:** Deprecated/Archive
**Functions:** 13

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_ragdoll_parts, _apply_materials, set_physics_process, _setup_joints, add_to_group

### `_create_ragdoll_parts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, new, add_child

### `_setup_joints()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_param_z, set_param, new, add_child, Vector3, set_param_x, get_path

### `_apply_materials()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, Color, get_child

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _apply_walking_forces, _check_balance, _update_walk_cycle

### `_update_walk_cycle()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _stumble, randf

### `_apply_walking_forces()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sin, apply_central_force, Vector3

### `_check_balance()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, apply_torque

### `_stumble()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf_range, call, Vector3, has_method, apply_central_impulse

### `start_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `set_walk_speed()`
- **Lines:** 0
- **Parameters:** `speed: float`
- **Returns:** `void`
- **Calls:** clamp

### `get_body()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `RigidBody3D`


## scripts/old_implementations/simple_walking_ragdoll.gd
**Category:** Deprecated/Archive
**Functions:** 10

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_simple_ragdoll

### `_create_simple_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, Color, _create_simple_leg

### `_create_simple_leg()`
- **Lines:** 0
- **Parameters:** `is_left: bool`
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, get_path, Color

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** randf_range, _speak_random_dialogue, dot, _take_step, apply_central_force

### `_take_step()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_impulse

### `_speak_random_dialogue()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** show_dialogue, Vector3, randi, print, size

### `start_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, show_dialogue

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, show_dialogue

### `toggle_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** start_walking, stop_walking

### `get_body()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `RigidBody3D`


## scripts/old_implementations/stable_ragdoll.gd
**Category:** Deprecated/Archive
**Functions:** 14

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_stable_ragdoll, set_physics_process

### `_create_stable_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set, new, add_child, Vector3, connect, get_path, Color, _create_leg, deg_to_rad, add_to_group

### `_create_leg()`
- **Lines:** 0
- **Parameters:** `is_left: bool`
- **Returns:** `void`
- **Calls:** set, new, bind, add_child, Vector3, connect, get_path, Color, deg_to_rad

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _process_dialogue, _process_walking, length, normalized

### `_process_walking()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** apply_central_impulse

### `_process_dialogue()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** randf_range, show_dialogue, Vector3, randi, emit_signal, size
- **Signals:** dialogue_spoken

### `_on_body_collision()`
- **Lines:** 0
- **Parameters:** `other_body: Node`
- **Returns:** `void`
- **Calls:** show_dialogue, Vector3, randi, is_in_group, size

### `_on_head_collision()`
- **Lines:** 0
- **Parameters:** `other_body: Node`
- **Returns:** `void`
- **Calls:** is_in_group, Vector3, show_dialogue

### `_on_leg_collision()`
- **Lines:** 0
- **Parameters:** `other_body: Node, is_left: bool`
- **Returns:** `void`
- **Calls:** is_in_group, show_dialogue

### `start_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, show_dialogue

### `stop_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, show_dialogue

### `toggle_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** start_walking, stop_walking

### `set_walk_speed()`
- **Lines:** 0
- **Parameters:** `speed: float`
- **Returns:** `void`
- **Calls:** str, clamp, Vector3, show_dialogue

### `get_body()`
- **Lines:** 3
- **Parameters:** ``
- **Returns:** `RigidBody3D`


## scripts/old_implementations/talking_ragdoll.gd
**Category:** Deprecated/Archive
**Functions:** 13

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf_range, _say_something, set_angular_damp, set_linear_damp, set_action_state, set_freeze_enabled, set_max_contacts_reported, Vector3, connect, set_gravity_scale, set_contact_monitor, apply_central_impulse, _setup_visual_indicators, _setup_blink_animation

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** randf_range, _say_something, _get_mouse_world_position, set_action_state, get_viewport, set_gravity_scale, look_at, apply_central_force, get_camera_3d

### `_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** randf_range, _say_something, is_action_pressed, _get_mouse_world_position, distance_to, Vector3, is_action_released, apply_central_impulse

### `_get_mouse_world_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`
- **Calls:** project_ray_normal, get_mouse_position, get_world_3d, new, get_viewport, intersect_ray, project_ray_origin, Plane, intersects_ray, get_camera_3d

### `_say_something()`
- **Lines:** 0
- **Parameters:** `category: String`
- **Returns:** `void`
- **Calls:** create_timer, randf, connect, randi, print, get_tree, size

### `_on_body_entered()`
- **Lines:** 0
- **Parameters:** `body: Node`
- **Returns:** `void`
- **Calls:** randf_range, _say_something, set_action_state, length, take_damage, is_in_group

### `set_floppiness()`
- **Lines:** 0
- **Parameters:** `factor: float`
- **Returns:** `void`
- **Calls:** set_linear_damp, _say_something, clamp, set_angular_damp

### `_say_something_custom()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, connect, print

### `_setup_blink_animation()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, set_script, connect, has_signal, print, find_child

### `_on_blink_started()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _say_something_custom, randf, randi, size

### `_setup_visual_indicators()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, setup_indicator, add_child, load, set_script, has_method, print

### `set_action_state()`
- **Lines:** 0
- **Parameters:** `action: String`
- **Returns:** `void`
- **Calls:** has_method, update_status

### `take_damage()`
- **Lines:** 13
- **Parameters:** `amount: float`
- **Returns:** `void`
- **Calls:** update_health, _say_something_custom, max, has_method


## scripts/passive_mode/autonomous_developer.gd
**Category:** Passive Mode Systems
**Functions:** 38

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _load_state, start_passive_mode

### `start_passive_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _change_state, get_ticks_msec, _log_activity, print, set_process

### `stop_passive_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _change_state, _save_state, _log_activity, print, set_process

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _change_state, _process_testing, _process_coding, _process_planning, _process_idle, _process_reviewing, _process_documenting, _process_resting, _check_limits, _process_committing

### `_check_limits()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** get_ticks_msec, emit_signal, float, _log_activity
- **Signals:** token_limit_approaching

### `_process_idle()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _change_state, is_empty, _generate_passive_tasks

### `_process_planning()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _change_state, _select_next_task, get_ticks_msec, is_empty, _estimate_task_tokens, _create_task_plan, _log_activity, get

### `_process_coding()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _change_state, _execute_coding_task, _log_activity, _complete_task, get

### `_process_testing()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _change_state, _run_tests, _log_activity, _revert_changes, _complete_task, get

### `_process_documenting()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _change_state, _update_documentation

### `_process_reviewing()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _change_state, _queue_for_approval, _generate_task_report, _log_activity, _complete_task, _requires_approval, get

### `_process_committing()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _commit_changes, _update_version, _complete_task, get

### `_process_resting()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _change_state, get_ticks_msec, _save_state, _check_limits, _generate_daily_report

### `_select_next_task()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** sort_custom, pop_front, is_empty, get

### `_generate_passive_tasks()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, append_array

### `_estimate_task_tokens()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `int`
- **Calls:** get

### `_create_task_plan()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `Dictionary`

### `_execute_coding_task()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `Dictionary`

### `_run_tests()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `Dictionary`

### `_update_documentation()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `void`

### `_generate_task_report()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `String`
- **Calls:** get_ticks_msec, str, get

### `_requires_approval()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `bool`
- **Calls:** get

### `_queue_for_approval()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `void`
- **Calls:** append, _load_approval_queue, _save_approval_queue

### `_commit_changes()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `void`

### `_update_version()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_revert_changes()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `void`

### `_complete_task()`
- **Lines:** 0
- **Parameters:** `success: bool`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, _change_state, emit_signal
- **Signals:** task_completed

### `_change_state()`
- **Lines:** 0
- **Parameters:** `new_state: DevelopmentState`
- **Returns:** `void`
- **Calls:** get_ticks_msec, emit_signal
- **Signals:** state_changed

### `_generate_daily_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_datetime_string_from_system, str, emit_signal, size, get
- **Signals:** daily_report_ready

### `_save_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, close, store_var

### `_load_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** close, open, file_exists, get_var, get

### `_load_approval_queue()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** close, open, get_var, file_exists

### `_save_approval_queue()`
- **Lines:** 0
- **Parameters:** `queue: Array`
- **Returns:** `void`
- **Calls:** open, close, store_var

### `_log_activity()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** open, close, get_datetime_string_from_system, store_string, print, seek_end

### `add_task()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `void`
- **Calls:** append

### `get_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** size

### `approve_task()`
- **Lines:** 0
- **Parameters:** `task_id: String`
- **Returns:** `void`

### `set_project()`
- **Lines:** 8
- **Parameters:** `project_name: String`
- **Returns:** `void`
- **Calls:** get_datetime_string_from_system, has


## scripts/passive_mode/multi_project_manager.gd
**Category:** Passive Mode Systems
**Functions:** 24

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, _load_project_data, set_process, _initialize_todo_lists

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _on_user_timeout

### `start_waiting_for_user()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, print

### `user_responded()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, str, print

### `_on_user_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, _start_background_work, reached, emit_signal, print
- **Signals:** user_timeout_reached

### `_start_background_work()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** switch_project, _select_background_project, _perform_background_tasks, emit_signal
- **Signals:** background_work_started

### `_select_background_project()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** append, sort_custom, is_empty, _priority_value

### `_priority_value()`
- **Lines:** 0
- **Parameters:** `priority: String`
- **Returns:** `int`

### `_perform_background_tasks()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** filter, get_project_todos, is_empty, _execute_background_task, get

### `_execute_background_task()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `void`
- **Calls:** get_ticks_msec, _research_feature, _cleanup_project_files, print, emit_signal, _optimize_code, _update_documentation, get
- **Signals:** task_completed_in_background

### `switch_project()`
- **Lines:** 0
- **Parameters:** `project_id: String`
- **Returns:** `bool`
- **Calls:** get_ticks_msec, has, emit_signal, print
- **Signals:** project_switched

### `get_project_todos()`
- **Lines:** 0
- **Parameters:** `project_id: String`
- **Returns:** `Array`
- **Calls:** has

### `add_task_to_project()`
- **Lines:** 0
- **Parameters:** `project_id: String, task: Dictionary`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, get_project_todos, has

### `get_current_project_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** filter, get_project_todos, size

### `get_all_projects_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_ticks_msec, filter, get_project_todos, size

### `_initialize_todo_lists()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_task_to_project

### `_cleanup_project_files()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_update_documentation()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_research_feature()`
- **Lines:** 0
- **Parameters:** `topic: String`
- **Returns:** `void`
- **Calls:** print

### `_optimize_code()`
- **Lines:** 0
- **Parameters:** `target: String`
- **Returns:** `void`
- **Calls:** print

### `_load_project_data()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** close, open, file_exists, has, get_var

### `save_project_data()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, open, close, store_var

### `list_projects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** str, int

### `get_timing_report()`
- **Lines:** 14
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_ticks_msec, str, s, int


## scripts/passive_mode/passive_mode_controller.gd
**Category:** Passive Mode Systems
**Functions:** 21

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** preload, connect, new, add_child

### `start_passive_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** start_passive_mode

### `stop_passive_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** stop_passive_mode

### `get_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_status, get_workflow_status, _state_to_string, str, is_empty, size, get

### `add_task()`
- **Lines:** 0
- **Parameters:** `name: String, priority: String = "medium"`
- **Returns:** `String`
- **Calls:** add_task, _infer_task_type, _parse_priority

### `create_branch()`
- **Lines:** 0
- **Parameters:** `branch_name: String`
- **Returns:** `String`
- **Calls:** create_feature_branch

### `switch_branch()`
- **Lines:** 0
- **Parameters:** `branch_name: String`
- **Returns:** `String`
- **Calls:** switch_branch

### `commit()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `String`
- **Calls:** commit_changes

### `create_mr()`
- **Lines:** 0
- **Parameters:** `title: String`
- **Returns:** `String`
- **Calls:** create_merge_request

### `approve_mr()`
- **Lines:** 0
- **Parameters:** `mr_id: String`
- **Returns:** `String`
- **Calls:** review_merge_request

### `merge()`
- **Lines:** 0
- **Parameters:** `mr_id: String`
- **Returns:** `String`
- **Calls:** merge_branch, get

### `show_diff()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_change_diff

### `set_token_budget()`
- **Lines:** 0
- **Parameters:** `budget: int`
- **Returns:** `String`
- **Calls:** str

### `set_auto_commit()`
- **Lines:** 0
- **Parameters:** `enabled: bool`
- **Returns:** `String`

### `set_require_approval()`
- **Lines:** 0
- **Parameters:** `enabled: bool`
- **Returns:** `String`

### `_state_to_string()`
- **Lines:** 0
- **Parameters:** `state: int`
- **Returns:** `String`

### `_parse_priority()`
- **Lines:** 0
- **Parameters:** `priority: String`
- **Returns:** `int`
- **Calls:** to_lower

### `_infer_task_type()`
- **Lines:** 0
- **Parameters:** `name: String`
- **Returns:** `String`
- **Calls:** to_lower

### `_on_task_completed()`
- **Lines:** 0
- **Parameters:** `task: Dictionary`
- **Returns:** `void`
- **Calls:** get, print

### `_on_daily_report()`
- **Lines:** 0
- **Parameters:** `report: String`
- **Returns:** `void`
- **Calls:** open, close, store_string, print, get_date_string_from_system

### `_on_merge_requested()`
- **Lines:** 2
- **Parameters:** `mr_id: String`
- **Returns:** `void`
- **Calls:** print


## scripts/passive_mode/passive_mode_test.gd
**Category:** Passive Mode Systems
**Functions:** 1

### `run_test()`
- **Lines:** 38
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_status, create_branch, create_mr, new, add_child, switch_branch, preload, stop_passive_mode, queue_free, add_task, commit, print, start_passive_mode


## scripts/passive_mode/threaded_test_system.gd
**Category:** Passive Mode Systems
**Functions:** 29

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_process, _initialize_test_containers

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _should_start_new_zone, _start_next_zone, is_empty, _process_tests_this_frame

### `_initialize_test_containers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _get_test_dependencies

### `_get_test_dependencies()`
- **Lines:** 0
- **Parameters:** `feature: String`
- **Returns:** `Array`

### `start_zone_test()`
- **Lines:** 0
- **Parameters:** `zone: String`
- **Returns:** `void`
- **Calls:** _dependencies_met, str, has, print, append, clear, size

### `_dependencies_met()`
- **Lines:** 0
- **Parameters:** `feature: String`
- **Returns:** `bool`
- **Calls:** get

### `_process_tests_this_frame()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _check_zone_completion, size, _process_test_step

### `_process_test_step()`
- **Lines:** 0
- **Parameters:** `feature: String, container: Dictionary`
- **Returns:** `void`
- **Calls:** append, _run_feature_test, get, print

### `_run_feature_test()`
- **Lines:** 0
- **Parameters:** `feature: String`
- **Returns:** `Dictionary`
- **Calls:** _test_ragdoll_walking, _test_physics_system, _test_dialogue_system, _test_object_spawning, _test_workflow_system, _test_console_system, _test_passive_mode, _test_scene_loading, _test_version_control, _test_ragdoll_physics, _test_astral_beings

### `_test_console_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_node_or_null, has_method

### `_test_physics_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_node_or_null, has_method

### `_test_object_spawning()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_node_or_null, has_method

### `_test_ragdoll_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_node_or_null, has_method, is_empty, get_tree, get_nodes_in_group

### `_test_ragdoll_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_tree, has_method, is_empty, get_nodes_in_group

### `_test_scene_loading()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** str, list_available_scenes, get_node_or_null, has_method, size

### `_test_dialogue_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_node_or_null, has_method

### `_test_astral_beings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_node_or_null, has_method

### `_test_passive_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** has_node, get_node_or_null

### `_test_workflow_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** has_node, get_node_or_null

### `_test_version_control()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`

### `_check_zone_completion()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _start_next_zone, _finalize_all_tests, _has_next_zone, emit_signal, print
- **Signals:** test_zone_completed

### `_should_start_new_zone()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** is_empty

### `_has_next_zone()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** size, find, keys

### `_start_next_zone()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** start_zone_test, size, find, keys

### `_finalize_all_tests()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, emit_signal, print, size, get
- **Signals:** all_tests_completed

### `run_full_test_suite()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** start_zone_test, clear

### `run_zone_test()`
- **Lines:** 0
- **Parameters:** `zone: String`
- **Returns:** `void`
- **Calls:** start_zone_test

### `get_test_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** size

### `get_zone_progress()`
- **Lines:** 12
- **Parameters:** `zone: String`
- **Returns:** `float`
- **Calls:** float, has, size


## scripts/passive_mode/version_backup_system.gd
**Category:** Passive Mode Systems
**Functions:** 28

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _ensure_backup_directory, _load_version_history

### `run_test_suite()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_datetime_string_from_system, _create_version_backup, _test_feature, has, emit_signal, print, append
- **Signals:** feature_status_changed, test_completed

### `_test_feature()`
- **Lines:** 0
- **Parameters:** `feature: String`
- **Returns:** `Dictionary`
- **Calls:** _test_ragdoll_walking, _test_dialogue_system, _test_object_spawning, _test_console_system, _test_scene_saving, _test_passive_mode, _test_scene_loading, print, _test_version_control, _test_ragdoll_physics, _test_astral_beings

### `_test_console_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_node_or_null, has_method

### `_test_object_spawning()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** create_tree, has_method, get_node_or_null, size

### `_test_ragdoll_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_node_or_null, has_method, is_empty, get_body, get_tree, get_nodes_in_group

### `_test_ragdoll_walking()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_tree, has_method, is_empty, get_nodes_in_group

### `_test_scene_loading()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** str, list_available_scenes, get_node_or_null, has_method, size

### `_test_scene_saving()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_node_or_null, has_method

### `_test_dialogue_system()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_node_or_null, has_method

### `_test_astral_beings()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_node_or_null, has_method

### `_test_passive_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** has_node, get_node_or_null

### `_test_version_control()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`

### `_create_version_backup()`
- **Lines:** 0
- **Parameters:** `test_results: Dictionary`
- **Returns:** `void`
- **Calls:** open, close, get_datetime_string_from_system, str, _cleanup_old_backups, _get_files_snapshot, duplicate, pop_front, store_var, emit_signal, print, append, size
- **Signals:** version_backed_up

### `_get_files_snapshot()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_datetime_string_from_system

### `find_last_working_version()`
- **Lines:** 0
- **Parameters:** `feature: String`
- **Returns:** `Dictionary`
- **Calls:** range, size

### `compare_versions()`
- **Lines:** 0
- **Parameters:** `version1: String, version2: String`
- **Returns:** `Dictionary`
- **Calls:** _array_diff, _find_version_data, is_empty

### `restore_version()`
- **Lines:** 0
- **Parameters:** `version_number: String`
- **Returns:** `bool`
- **Calls:** _find_version_data, duplicate, is_empty, print

### `generate_feature_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** range, has, size

### `_find_version_data()`
- **Lines:** 0
- **Parameters:** `version_number: String`
- **Returns:** `Dictionary`

### `_array_diff()`
- **Lines:** 0
- **Parameters:** `arr1: Array, arr2: Array`
- **Returns:** `Array`
- **Calls:** append

### `_ensure_backup_directory()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, dir_exists, make_dir

### `_load_version_history()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sort_custom, open, close, get_next, ends_with, append, get_var, list_dir_begin

### `_cleanup_old_backups()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, remove_absolute, range, size

### `increment_version()`
- **Lines:** 0
- **Parameters:** `bump_type: String = "patch"`
- **Returns:** `void`
- **Calls:** str, split, int

### `get_current_version()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`

### `get_working_features()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`

### `get_broken_features()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `Array`


## scripts/passive_mode/workflow_manager.gd
**Category:** Passive Mode Systems
**Functions:** 22

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _load_workflow_state

### `create_feature_branch()`
- **Lines:** 0
- **Parameters:** `branch_name: String, description: String = ""`
- **Returns:** `String`
- **Calls:** get_datetime_string_from_system, _log_workflow, has, emit_signal
- **Signals:** branch_created

### `switch_branch()`
- **Lines:** 0
- **Parameters:** `branch_name: String`
- **Returns:** `bool`
- **Calls:** _log_workflow, has

### `track_change()`
- **Lines:** 0
- **Parameters:** `file_path: String, change_type: ChangeType, content: String = ""`
- **Returns:** `void`
- **Calls:** get_ticks_msec, has

### `commit_changes()`
- **Lines:** 0
- **Parameters:** `message: String, author: String = "Autonomous Developer"`
- **Returns:** `String`
- **Calls:** _generate_commit_hash, get_datetime_string_from_system, _log_workflow, duplicate, _reset_change_summary, emit_signal, append, _allow_direct_main_commit, get
- **Signals:** changes_committed

### `create_merge_request()`
- **Lines:** 0
- **Parameters:** `title: String, description: String = ""`
- **Returns:** `String`
- **Calls:** get_datetime_string_from_system, str, _log_workflow, duplicate, has, emit_signal, append, size
- **Signals:** merge_requested

### `review_merge_request()`
- **Lines:** 0
- **Parameters:** `mr_id: String, approved: bool, comments: String = ""`
- **Returns:** `bool`
- **Calls:** get_datetime_string_from_system, _log_workflow, _find_merge_request, has, append

### `merge_branch()`
- **Lines:** 0
- **Parameters:** `mr_id: String`
- **Returns:** `Dictionary`
- **Calls:** append_array, _perform_merge, _log_workflow, _find_merge_request, emit_signal, _bump_version, get
- **Signals:** merge_completed

### `_perform_merge()`
- **Lines:** 0
- **Parameters:** `source: String, target: String`
- **Returns:** `Dictionary`
- **Calls:** _check_conflicts, is_empty

### `_check_conflicts()`
- **Lines:** 0
- **Parameters:** `source: String, target: String`
- **Returns:** `Array`
- **Calls:** append, has, get

### `_bump_version()`
- **Lines:** 0
- **Parameters:** `merge_request: Dictionary`
- **Returns:** `void`
- **Calls:** str, _log_workflow, to_lower, emit_signal, split, int
- **Signals:** version_released

### `get_workflow_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** _get_open_merge_requests, size, get, keys

### `get_change_diff()`
- **Lines:** 0
- **Parameters:** `branch: String = ""`
- **Returns:** `String`
- **Calls:** _get_change_symbol, str, is_empty, get

### `_get_change_symbol()`
- **Lines:** 0
- **Parameters:** `type: ChangeType`
- **Returns:** `String`

### `_find_merge_request()`
- **Lines:** 0
- **Parameters:** `mr_id: String`
- **Returns:** `Dictionary`

### `_get_open_merge_requests()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** append

### `_generate_commit_hash()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_ticks_msec, right, str, randi

### `_allow_direct_main_commit()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`

### `_reset_change_summary()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_log_workflow()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** open, close, get_datetime_string_from_system, store_string, seek_end

### `_save_workflow_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, close, store_var

### `_load_workflow_state()`
- **Lines:** 14
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** close, open, file_exists, get_var, get


## scripts/patches/add_commands_directly.gd
**Category:** Patches & Fixes
**Functions:** 6

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** push_error, str, get_node_or_null, Callable, print, get_tree, size

### `_cmd_spawn_biowalker()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, str, _print, get_tree, float, size

### `_cmd_walker_debug()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, _print

### `_cmd_layers()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_node_or_null, _print

### `_cmd_layer()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** size, _print

### `_print()`
- **Lines:** 4
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, has_method


## scripts/patches/advanced_inspector_integration.gd
**Category:** Patches & Fixes
**Functions:** 28

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_integration

### `_setup_integration()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_scene_editor, get_node_or_null, _register_advanced_commands, print, get_tree, _create_advanced_inspector

### `_create_advanced_inspector()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, preload, connect, exists, print, get_tree

### `_create_scene_editor()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, preload, exists, print

### `_register_advanced_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, has_method, inspector, print, object

### `_cmd_inspect()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_class, mouse, _print_to_console, _find_object_by_name, _get_object_under_mouse, inspect_object, selected, size

### `_cmd_inspector_control()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** hide, _print_to_console, show, size

### `_cmd_edit_property()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** set, _print_to_console, _update_properties_tab, str, is_empty, has_method, _parse_value, size

### `_cmd_select()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** substr, _print_to_console, _find_objects_by_type, str, is_empty, _find_objects_by_pattern, _deselect_all, _select_object, begins_with, get_tree, size, get_nodes_in_group

### `_cmd_select_all()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _cmd_select_all

### `_cmd_deselect()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _cmd_deselect

### `_cmd_show_selection()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_class, _print_to_console, str, is_empty, Selection, size

### `_cmd_set_position()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _cmd_move, _print_to_console, size

### `_cmd_set_rotation()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _cmd_rotate, size

### `_cmd_set_scale()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _cmd_scale, size

### `_cmd_save_scene()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _cmd_scene_save

### `_cmd_load_scene()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _cmd_scene_load

### `_find_object_by_name()`
- **Lines:** 0
- **Parameters:** `name: String`
- **Returns:** `Node`
- **Calls:** get_tree, _find_node_recursive

### `_find_node_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node, name: String, exact_match: bool`
- **Returns:** `Node`
- **Calls:** _find_node_recursive, contains, get_children, to_lower

### `_find_objects_by_pattern()`
- **Lines:** 0
- **Parameters:** `pattern: String`
- **Returns:** `Array`
- **Calls:** get_tree, _collect_matching_nodes, to_lower

### `_find_objects_by_type()`
- **Lines:** 0
- **Parameters:** `type_name: String`
- **Returns:** `Array`
- **Calls:** get_tree, _collect_nodes_by_type

### `_collect_matching_nodes()`
- **Lines:** 0
- **Parameters:** `node: Node, pattern: String, results: Array`
- **Returns:** `void`
- **Calls:** contains, get_children, to_lower, _collect_matching_nodes, append

### `_collect_nodes_by_type()`
- **Lines:** 0
- **Parameters:** `node: Node, type_name: String, results: Array`
- **Returns:** `void`
- **Calls:** get_class, get_children, is_class, _collect_nodes_by_type, append

### `_get_object_under_mouse()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node`
- **Calls:** create, project_ray_normal, get_mouse_position, get_world_3d, get_viewport, intersect_ray, project_ray_origin, get_camera_3d

### `_parse_value()`
- **Lines:** 0
- **Parameters:** `value_str: String`
- **Returns:** `Variant`
- **Calls:** Vector2, is_valid_int, is_valid_float, Vector3, to_lower, Color, float, size, split, int

### `_on_property_changed()`
- **Lines:** 0
- **Parameters:** `object: Node, property: String, value: Variant`
- **Returns:** `void`
- **Calls:** str, _print_to_console

### `_on_scene_save_requested()`
- **Lines:** 0
- **Parameters:** `scene_data: Dictionary`
- **Returns:** `void`
- **Calls:** _print_to_console

### `_on_object_deleted()`
- **Lines:** 2
- **Parameters:** `object: Node`
- **Returns:** `void`
- **Calls:** _print_to_console


## scripts/patches/biomechanical_walker_commands.gd
**Category:** Patches & Fixes
**Functions:** 10

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, get_node_or_null, _register_walker_commands, print

### `_register_walker_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** push_error, register_command, has_method, print

### `_cmd_spawn_biowalker()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** set, feet, new, load, queue_free, add_child, Vector3, str, set_script, has_method, _print, set_walker, get_tree, float, size

### `_cmd_walker_speed()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, _print, set_walk_speed, float, size

### `_cmd_walker_phase()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** str, is_foot_on_ground, get_current_phase, _print

### `_cmd_walker_debug()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** handle_console_command, is_empty, _print

### `_cmd_walker_params()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, float, size, _print

### `_cmd_walker_teleport()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, Vector3, _print, float, size

### `_cmd_walker_freeze()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** size, _print

### `_print()`
- **Lines:** 5
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** _print_to_console, has_method, print


## scripts/patches/console_command_extension.gd
**Category:** Patches & Fixes
**Functions:** 10

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** disconnect, push_error, get_signal_connection_list, _find_and_hook_input_field, get_node_or_null, connect, has_signal, print, get_tree, get_object

### `_find_and_hook_input_field()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** get_children, _find_and_hook_input_field, connect, is_connected, print

### `_on_extended_input_submitted()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** _cmd_spawn_biowalker, _on_input_submitted, _cmd_layers, is_empty, _print, to_lower, _clear_input_field, has_method, _cmd_walker_debug, print, slice, _cmd_layer, strip_edges, split

### `_clear_input_field()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _clear_input_recursive

### `_clear_input_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** get_children, _clear_input_recursive

### `_cmd_spawn_biowalker()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** set, new, load, add_child, Vector3, str, set_script, _print, get_tree, float, size

### `_cmd_walker_debug()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, _print

### `_cmd_layers()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_node_or_null, _print, Console

### `_cmd_layer()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_node_or_null, size, _print

### `_print()`
- **Lines:** 4
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** _print_to_console, has_method


## scripts/patches/console_debug_overlay.gd
**Category:** Patches & Fixes
**Functions:** 3

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, get_node_or_null, get_tree, add_theme_font_size_override, add_theme_color_override

### `_process()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** append, str, join, get_parent

### `_input()`
- **Lines:** 4
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** queue_free


## scripts/patches/console_diagnostic.gd
**Category:** Patches & Fixes
**Functions:** 1

### `_ready()`
- **Lines:** 49
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** contains, typeof, str, get_node_or_null, get_property_list, print, get_tree, size, get


## scripts/patches/console_layer_integration.gd
**Category:** Patches & Fixes
**Functions:** 14

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, _register_layer_commands, get_node_or_null, print

### `_register_layer_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** push_error, print

### `_cmd_layer()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** values, _apply_layer_action, size, _print

### `_apply_layer_action()`
- **Lines:** 0
- **Parameters:** `layer: int, action: String, name: String`
- **Returns:** `void`
- **Calls:** toggle_layer, is_layer_visible, _print, toggled, set_layer_visibility

### `_cmd_layers()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** str, _get_view_mode_name, is_layer_visible, _print, F4, range, F5

### `_cmd_reality()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _get_view_mode_name, cycle_view_mode, _print

### `_cmd_debug_point()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** Vector3, str, _print, add_debug_point, _parse_color, float, size

### `_cmd_debug_line()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** Vector3, _print, _parse_color, add_debug_line, float, size

### `_cmd_debug_clear()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** clear_debug_draw, _print

### `_cmd_world_view()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** is_empty, _print

### `_cmd_map_view()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** is_empty, _print

### `_print()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** _print_to_console, has_method, print

### `_get_view_mode_name()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`

### `_parse_color()`
- **Lines:** 23
- **Parameters:** `color_str: String`
- **Returns:** `Color`
- **Calls:** begins_with, Color, to_lower


## scripts/patches/console_spam_filter.gd
**Category:** Patches & Fixes
**Functions:** 14

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** setup_console_commands, new, add_child, get_node_or_null, connect, print, get_tree

### `should_show_message()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `bool`
- **Calls:** _apply_filtering_rules, str, _get_message_key, has, _get_message_priority, get_unix_time_from_system

### `_get_message_key()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `String`
- **Calls:** begins_with, substr, keys

### `_get_message_priority()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `MessagePriority`
- **Calls:** begins_with, keys

### `_apply_filtering_rules()`
- **Lines:** 0
- **Parameters:** `message_key: String, priority: MessagePriority, time_since_last: float, current_time: float`
- **Returns:** `bool`

### `_cleanup_old_messages()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, erase, keys, get_unix_time_from_system

### `filter_message()`
- **Lines:** 0
- **Parameters:** `message: String`
- **Returns:** `String`
- **Calls:** should_show_message

### `get_filter_stats()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** size, _count_total_suppressions

### `_count_total_suppressions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `int`
- **Calls:** values

### `setup_console_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, has_method

### `_cmd_filter_stats()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_filter_stats, keys, str, is_empty, _print

### `_cmd_filter_reset()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** clear, _print

### `_cmd_filter_config()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, size, _print, int

### `_print()`
- **Lines:** 5
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** _print_to_console, print


## scripts/patches/console_ui_fix.gd
**Category:** Patches & Fixes
**Functions:** 9

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _apply_console_fixes, get_tree

### `_apply_console_fixes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _fix_console_sizing, get_node_or_null, connect, print, get_tree

### `_fix_console_sizing()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, get_child_count, min, get_viewport, _find_node_by_type, _center_console, get_child, add_theme_font_size_override

### `_center_console()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, get_viewport

### `_find_node_by_type()`
- **Lines:** 0
- **Parameters:** `parent: Node, type_name: String`
- **Returns:** `Node`
- **Calls:** get_class, get_children, _find_node_by_type

### `_on_viewport_changed()`
- **Lines:** 0
- **Parameters:** `_new_size: Vector2i`
- **Returns:** `void`
- **Calls:** _fix_console_sizing

### `_notification()`
- **Lines:** 0
- **Parameters:** `what: int`
- **Returns:** `void`
- **Calls:** get_tree, register_command, has_method

### `_cmd_fix_console()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, _fix_console_sizing

### `_cmd_console_scale()`
- **Lines:** 12
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, Vector2, str, clamp, float, size


## scripts/patches/debug_integration_patch.gd
**Category:** Patches & Fixes
**Functions:** 5

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** push_error, add_debug_commands, get_node_or_null, patch_console_manager, print, get_tree, patch_jsh_systems

### `patch_console_manager()`
- **Lines:** 0
- **Parameters:** `console: Node`
- **Returns:** `void`

### `patch_jsh_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_verbose, get_node_or_null, has_method, print

### `add_debug_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _on_console_command, get_node_or_null, has, print

### `_init()`
- **Lines:** 4
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_physics_process, set_process


## scripts/patches/debug_test_commands.gd
**Category:** Patches & Fixes
**Functions:** 2

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_command, register_command, contains, push_error, get_node_or_null, has_method, get_method_list, print, begins_with, get_tree

### `_test_command()`
- **Lines:** 4
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node, str, has_node, print


## scripts/patches/delayed_command_injector.gd
**Category:** Patches & Fixes
**Functions:** 1

### `_ready()`
- **Lines:** 115
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, _print_to_console, feet, typeof, new, push_error, load, add_child, str, Vector3, get_node_or_null, set_script, toggle_layer, set_layer_visibility, print, get_tree, size, get


## scripts/patches/floodgate_console_bridge.gd
**Category:** Patches & Fixes
**Functions:** 32

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _register_floodgate_commands, push_error, get_node_or_null, print, get_tree

### `_register_floodgate_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command

### `_cmd_create_node()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, Vector3, _print, float, size

### `_cmd_delete_node()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, size, _print

### `_cmd_duplicate_node()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_class, queue_operation, get_parent, Vector3, get_node_or_null, has_method, _print, get_path, float, size

### `_cmd_move_node()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, Vector3, _print, float, size

### `_cmd_rotate_node()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, Vector3, _print, deg_to_rad, float, size

### `_cmd_scale_node()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, Vector3, _print, float, size

### `_cmd_reparent_node()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, size, _print

### `_cmd_set_property()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, Vector3, _print, _parse_value, size

### `_cmd_get_property()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, get_node_or_null, has_method, _print, size, get

### `_cmd_list_properties()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, get_node_or_null, get_property_list, _print, has, size, get

### `_cmd_call_method()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, _print, _parse_value, append, range, size

### `_cmd_list_methods()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_node_or_null, get_method_list, _print, has, size

### `_cmd_connect_signal()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, size, _print

### `_cmd_disconnect_signal()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, size, _print

### `_cmd_emit_signal()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, _print, _parse_value, append, range, size

### `_cmd_list_signals()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_node_or_null, _print, get_signal_list, has, size

### `_cmd_load_asset()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** to_upper, queue_operation, size, _print

### `_cmd_unload_asset()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, size, _print

### `_cmd_list_assets()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** is_empty, _print

### `_cmd_save_scene()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** pack, new, save, _print, get_tree, size

### `_cmd_load_scene()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** load, _print, change_scene_to_packed, get_tree, size

### `_cmd_clear_scene()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** queue_operation, get_children, _print, get_path, get_tree

### `_cmd_list_nodes()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** _print_node_tree, get_node_or_null, size, _print

### `_cmd_floodgate_status()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** str, size, _print

### `_cmd_floodgate_queue()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** str, is_empty, min, _print, _get_operation_name, range, size

### `_cmd_floodgate_history()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** is_empty, min, _print, _get_operation_name, range, size

### `_parse_value()`
- **Lines:** 0
- **Parameters:** `value_str: String`
- **Returns:** `void`
- **Calls:** substr, Vector2, is_valid_int, is_valid_float, Vector3, length, to_lower, begins_with, ends_with, float, size, split, int

### `_get_operation_name()`
- **Lines:** 0
- **Parameters:** `op_type`
- **Returns:** `String`

### `_print_node_tree()`
- **Lines:** 0
- **Parameters:** `node: Node, depth: int`
- **Returns:** `void`
- **Calls:** get_class, _print_node_tree, get_children, _print, repeat

### `_print()`
- **Lines:** 5
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** _print_to_console, print


## scripts/patches/gizmo_collision_fix.gd
**Category:** Patches & Fixes
**Functions:** 4

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** call_deferred, print

### `_fix_gizmo_collisions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, is_instance_valid, find_gizmo_system, _add_collision_to_gizmo, get_path, print, get_tree

### `_add_collision_to_gizmo()`
- **Lines:** 0
- **Parameters:** `gizmo_being: Node3D, axis: String, mode: String`
- **Returns:** `void`
- **Calls:** get_children, new, add_child, Vector3, set_meta, len, print, add_to_group

### `_visualize_collision_shapes()`
- **Lines:** 4
- **Parameters:** `enable: bool = true`
- **Returns:** `void`
- **Calls:** get_tree, print


## scripts/patches/gizmo_comprehensive_diagnostics.gd
**Category:** Patches & Fixes
**Functions:** 5

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _register_commands, print

### `_register_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null, print

### `cmd_full_diagnosis()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get, get_class, str, get_meta, get_node_or_null, find_gizmo_system, has_method, get_child_count, get_first_node_in_group, get_script, get_path, append, get_tree, has_meta, size, get_nodes_in_group

### `cmd_emergency_fix()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** set_mode, str, create_gizmo_system, has_method, find_gizmo_system, attach_to_object, get_nodes_in_group, append, get_tree, size, get

### `cmd_connection_test()`
- **Lines:** 72
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** create, project_ray_normal, contains, get_world_3d, str, get_node_or_null, has_method, find_gizmo_system, get_viewport, intersect_ray, project_ray_origin, get_visible_rect, append, get_tree, size, get_nodes_in_group, get_camera_3d


## scripts/patches/gizmo_debug_commands.gd
**Category:** Patches & Fixes
**Functions:** 9

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _register_debug_commands, print

### `_register_debug_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null, print

### `cmd_gizmo_debug()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** str, get_first_node_in_group, get_path, get_nodes_in_group, get_tree, size, get

### `cmd_list_gizmo_parts()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get_class, get_parent, str, get_meta, get_path, Components, get_tree, has_meta, size, get_nodes_in_group

### `cmd_show_gizmo_layers()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get_node_or_null

### `cmd_test_gizmo_click()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** create, project_ray_normal, get_world_3d, Test, str, get_meta, get_viewport, intersect_ray, project_ray_origin, get_visible_rect, has_meta, get_camera_3d

### `cmd_toggle_collision_debug()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get_tree, size

### `fix_gizmo_layers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, get_nodes_in_group, print

### `cmd_test_rotation_fix()`
- **Lines:** 52
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get, set_mode, str, ring, get_first_node_in_group, get_node_or_null, to_upper, get_tree, size, get_nodes_in_group


## scripts/patches/gizmo_direct_interaction_fix.gd
**Category:** Patches & Fixes
**Functions:** 10

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_process_unhandled_input, call_deferred, print

### `_setup_gizmo_fix()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, find_gizmo_system, get_path, print, get_tree, _ensure_gizmo_collision_layers

### `_ensure_gizmo_collision_layers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, size, get_nodes_in_group, print

### `_unhandled_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** _on_mouse_pressed, _on_mouse_released, _on_mouse_dragged

### `_on_mouse_pressed()`
- **Lines:** 0
- **Parameters:** `mouse_pos: Vector2`
- **Returns:** `void`
- **Calls:** _raycast_for_gizmo, get_first_node_in_group, has_method, get_viewport, set_input_as_handled, _handle_gizmo_click, print, get_tree

### `_on_mouse_released()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_method, _end_drag

### `_on_mouse_dragged()`
- **Lines:** 0
- **Parameters:** `mouse_pos: Vector2`
- **Returns:** `void`
- **Calls:** has_method, _update_drag

### `_raycast_for_gizmo()`
- **Lines:** 0
- **Parameters:** `mouse_pos: Vector2`
- **Returns:** `Dictionary`
- **Calls:** create, project_ray_normal, get_world_3d, get_viewport, intersect_ray, project_ray_origin, print, get_camera_3d

### `cmd_debug_gizmo_collisions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, print

### `cmd_list_gizmo_components()`
- **Lines:** 9
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_class, components, str, print, get_tree, size, get_nodes_in_group


## scripts/patches/gizmo_perfect_fix.gd
**Category:** Patches & Fixes
**Functions:** 3

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null

### `cmd_perfect_gizmo()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** new, load, add_child, set_mode, get_first_node_in_group, set_script, has_method, attach_to_object, get_tree, size, get_nodes_in_group

### `cmd_gizmo_show()`
- **Lines:** 30
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** new, load, add_child, set_mode, get_first_node_in_group, set_script, has_method, attach_to_object, get_tree


## scripts/patches/gizmo_reset_command.gd
**Category:** Patches & Fixes
**Functions:** 3

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null, print

### `cmd_gizmo_reset()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** get_child, new, is_instance_valid, load, queue_free, add_child, get_first_node_in_group, set_script, get_child_count, attach_to_object, print, get_tree

### `cmd_gizmo_create()`
- **Lines:** 21
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** new, load, get_ticks_msec, add_child, str, set_script, get_child_count, get_child, get_tree


## scripts/patches/gizmo_system_finder.gd
**Category:** Patches & Fixes
**Functions:** 8

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _register_console_commands, print

### `_register_console_commands()`
- **Lines:** 10
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null, print

### `cmd_find_gizmo()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** str, create_gizmo_system, has_method, find_gizmo_system, get_path, size, get

### `cmd_gizmo_status()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** is_instance_valid, str, has_method, find_gizmo_system, get_path, get_nodes_in_group, get_tree, size, get

### `cmd_force_show()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** set_mode, has_method, visible, find_gizmo_system

### `cmd_gizmo_target()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `String`
- **Calls:** _find_object_by_name, has_method, is_empty, find_gizmo_system, attach_to_object

### `_find_object_by_name()`
- **Lines:** 0
- **Parameters:** `object_name: String`
- **Returns:** `Node3D`
- **Calls:** get_tree, _recursive_find_by_name, get_nodes_in_group

### `_recursive_find_by_name()`
- **Lines:** 11
- **Parameters:** `node: Node, target_name: String`
- **Returns:** `Node3D`
- **Calls:** get_children, _recursive_find_by_name


## scripts/patches/ragdoll_neural_integration.gd
**Category:** Patches & Fixes
**Functions:** 14

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _scan_integration_status, _register_neural_commands, print

### `_register_neural_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null

### `_scan_integration_status()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** file_exists, print

### `copy_neural_files()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** open, file_exists, emit, copy, print, size

### `enhance_biomechanical_walker()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _add_health_indicators, is_empty, _migrate_to_perfect_delta, emit, _add_blinking_to_ragdoll, print, _add_emotional_colors, get_tree, get_nodes_in_group

### `_add_blinking_to_ragdoll()`
- **Lines:** 0
- **Parameters:** `ragdoll: Node`
- **Returns:** `void`
- **Calls:** new, add_child, load, has_node, print, get

### `_add_health_indicators()`
- **Lines:** 0
- **Parameters:** `ragdoll: Node`
- **Returns:** `void`
- **Calls:** new, add_child, load, has_node, print, get

### `_add_emotional_colors()`
- **Lines:** 0
- **Parameters:** `ragdoll: Node`
- **Returns:** `void`
- **Calls:** new, add_child, load, has_node, print, get

### `_migrate_to_perfect_delta()`
- **Lines:** 0
- **Parameters:** `ragdoll: Node`
- **Returns:** `void`
- **Calls:** register_process, get_node_or_null, has_method, print, set_physics_process

### `spawn_perfect_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Node3D`
- **Calls:** new, load, add_child, _add_health_indicators, get_node_or_null, set_script, _migrate_to_perfect_delta, emit, _add_blinking_to_ragdoll, print, _add_emotional_colors, get_tree, add_to_group

### `_cmd_activate_neural()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, copy_neural_files, enhance_biomechanical_walker

### `_cmd_neural_status()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _scan_integration_status, get_node, _print_to_console

### `_cmd_copy_neural_files()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _scan_integration_status, get_node, _print_to_console, copy_neural_files

### `_cmd_spawn_perfect_ragdoll()`
- **Lines:** 13
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, spawn_perfect_ragdoll


## scripts/patches/scene_command_injector.gd
**Category:** Patches & Fixes
**Functions:** 1

### `_ready()`
- **Lines:** 7
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, set_script, print, get_tree


## scripts/patches/simple_console_test.gd
**Category:** Patches & Fixes
**Functions:** 3

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, register_command, str, get_node_or_null, has_method, get_property_list, to_lower, print, get_tree, get

### `_test_command()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** str, print

### `_hello_command()`
- **Lines:** 4
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** join, size, print


## scripts/patches/spawn_limiter.gd
**Category:** Patches & Fixes
**Functions:** 6

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _count_existing_objects, get_tree, connect, print

### `_count_existing_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, print, get_nodes_in_group, to_lower

### `_on_node_added()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `void`
- **Calls:** queue_free, _make_clickable, s, to_lower, print, add_to_group

### `_make_clickable()`
- **Lines:** 0
- **Parameters:** `node: Node3D`
- **Returns:** `void`
- **Calls:** get_children, get_ticks_msec, str, set_meta, to_lower, print, has_meta

### `reset_counts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _count_existing_objects

### `get_status()`
- **Lines:** 7
- **Parameters:** ``
- **Returns:** `String`


## scripts/patches/unified_walker_commands.gd
**Category:** Patches & Fixes
**Functions:** 11

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, get_node_or_null, _register_walker_commands, print

### `_register_walker_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** push_error, register_command, has_method, print

### `_cmd_spawn_walker()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** feet, new, add_child, queue_free, Vector3, str, connect, _print, get_tree, float, size

### `_cmd_walker_speed()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, is_empty, _print, set_walk_speed, float

### `_cmd_walker_teleport()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** Vector3, str, _print, float, size, teleport_to

### `_cmd_walker_info()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** str, get_debug_info, _print

### `_cmd_walker_destroy()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** queue_free, _print

### `_cmd_walker_debug()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** Feet, Torso, Legs, on, get_debug_info, is_empty, _print, to_lower

### `_on_step_completed()`
- **Lines:** 0
- **Parameters:** `foot: String`
- **Returns:** `void`
- **Calls:** _print

### `_on_phase_changed()`
- **Lines:** 0
- **Parameters:** `leg: String, phase: String`
- **Returns:** `void`
- **Calls:** _print

### `_print()`
- **Lines:** 5
- **Parameters:** `message: String`
- **Returns:** `void`
- **Calls:** _print_to_console, has_method, print


## scripts/patches/universal_console_helper.gd
**Category:** Patches & Fixes
**Functions:** 2

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _ensure_universal_commands

### `_ensure_universal_commands()`
- **Lines:** 62
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _cmd_make_perfect, _cmd_check_satisfaction, _print_to_console, _cmd_optimize_now, _cmd_show_lists, _cmd_health_check, get_node_or_null, _cmd_universal_status, has_method, _cmd_evolve, print, _cmd_list_variables


## scripts/patches/universal_quickfix.gd
**Category:** Patches & Fixes
**Functions:** 1

### `_ready()`
- **Lines:** 32
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, _cmd_make_perfect, _cmd_check_satisfaction, _cmd_optimize_now, _cmd_show_lists, queue_free, _cmd_health_check, get_node_or_null, _cmd_universal_status, _cmd_evolve, _cmd_export_variables, print, get_tree, _cmd_list_variables


## scripts/ragdoll/biomechanical_walker.gd
**Category:** Ragdoll Systems
**Functions:** 30

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _initialize_gait, _setup_physics, _create_skeleton

### `_create_skeleton()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, _create_body, get_path, _create_leg

### `_create_leg()`
- **Lines:** 0
- **Parameters:** `side: String, offset: Vector3`
- **Returns:** `Leg`
- **Calls:** _create_hip_joint, new, add_child, _create_toe_joint, Vector3, _create_midfoot_joint, _create_knee_joint, _create_ankle_joint, _create_body

### `_create_body()`
- **Lines:** 0
- **Parameters:** `name: String, mass: float, size: Vector3`
- **Returns:** `RigidBody3D`
- **Calls:** connect, new, bind, add_child

### `_create_hip_joint()`
- **Lines:** 0
- **Parameters:** `pelvis: RigidBody3D, hip: RigidBody3D, thigh: RigidBody3D`
- **Returns:** `Generic6DOFJoint3D`
- **Calls:** set_param_y, set_param_z, new, add_child, set_param_x, get_path

### `_create_knee_joint()`
- **Lines:** 0
- **Parameters:** `thigh: RigidBody3D, shin: RigidBody3D`
- **Returns:** `HingeJoint3D`
- **Calls:** set_param, new, add_child, get_path, set_flag

### `_create_ankle_joint()`
- **Lines:** 0
- **Parameters:** `shin: RigidBody3D, heel: RigidBody3D`
- **Returns:** `Generic6DOFJoint3D`
- **Calls:** set_param_z, new, add_child, set_param_x, get_path

### `_create_midfoot_joint()`
- **Lines:** 0
- **Parameters:** `heel: RigidBody3D, foot: RigidBody3D`
- **Returns:** `HingeJoint3D`
- **Calls:** set_param, new, add_child, get_path, set_flag

### `_create_toe_joint()`
- **Lines:** 0
- **Parameters:** `foot: RigidBody3D, toes: RigidBody3D`
- **Returns:** `HingeJoint3D`
- **Calls:** set_param, new, add_child, get_path, set_flag

### `_setup_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_initialize_gait()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_leg_phase, _update_center_of_mass, _maintain_balance, _apply_gait_forces

### `_update_leg_phase()`
- **Lines:** 0
- **Parameters:** `leg: Leg, delta: float`
- **Returns:** `void`
- **Calls:** _transition_to_next_phase

### `_transition_to_next_phase()`
- **Lines:** 0
- **Parameters:** `leg: Leg`
- **Returns:** `void`
- **Calls:** emit, keys

### `_apply_gait_forces()`
- **Lines:** 0
- **Parameters:** `leg: Leg`
- **Returns:** `void`
- **Calls:** _apply_heel_strike_forces, _apply_initial_swing_forces, _apply_midstance_forces, _apply_terminal_swing_forces, _apply_foot_flat_forces, _apply_heel_off_forces, _apply_mid_swing_forces, _apply_toe_off_forces

### `_apply_heel_strike_forces()`
- **Lines:** 0
- **Parameters:** `leg: Leg`
- **Returns:** `void`
- **Calls:** Vector3, apply_torque

### `_apply_foot_flat_forces()`
- **Lines:** 0
- **Parameters:** `leg: Leg`
- **Returns:** `void`
- **Calls:** Vector3, apply_torque

### `_apply_midstance_forces()`
- **Lines:** 0
- **Parameters:** `leg: Leg`
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, apply_torque

### `_apply_heel_off_forces()`
- **Lines:** 0
- **Parameters:** `leg: Leg`
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, apply_torque

### `_apply_toe_off_forces()`
- **Lines:** 0
- **Parameters:** `leg: Leg`
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, apply_torque

### `_apply_initial_swing_forces()`
- **Lines:** 0
- **Parameters:** `leg: Leg`
- **Returns:** `void`
- **Calls:** Vector3, apply_torque

### `_apply_mid_swing_forces()`
- **Lines:** 0
- **Parameters:** `leg: Leg`
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, apply_torque

### `_apply_terminal_swing_forces()`
- **Lines:** 0
- **Parameters:** `leg: Leg`
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, apply_torque

### `_maintain_balance()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, apply_torque, length, normalized

### `_update_center_of_mass()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_on_body_contact()`
- **Lines:** 0
- **Parameters:** `body: Node3D, contacting_body: Node3D`
- **Returns:** `void`

### `_on_body_exit_contact()`
- **Lines:** 0
- **Parameters:** `body: Node3D, contacting_body: Node3D`
- **Returns:** `void`
- **Calls:** erase

### `set_walk_speed()`
- **Lines:** 0
- **Parameters:** `speed: float`
- **Returns:** `void`

### `get_current_phase()`
- **Lines:** 0
- **Parameters:** `leg_side: String`
- **Returns:** `String`
- **Calls:** keys

### `is_foot_on_ground()`
- **Lines:** 3
- **Parameters:** `leg_side: String`
- **Returns:** `bool`


## scripts/ragdoll/gait_phase_visualizer.gd
**Category:** Ragdoll Systems
**Functions:** 12

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_debug_labels, get_node_or_null, connect, _setup_timeline_ui

### `_setup_timeline_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, add_child

### `_create_debug_labels()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_phase_labels, _update_timeline, _update_contact_visualization, is_layer_visible, _update_force_vectors

### `_update_phase_labels()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, get_current_phase, get

### `_update_contact_visualization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, add_debug_point, clear_debug_draw, add_debug_line, is_foot_on_ground

### `_update_force_vectors()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_debug_line, Vector3, length, normalized

### `_update_timeline()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _calculate_cycle_progress, new, add_theme_stylebox_override

### `_calculate_cycle_progress()`
- **Lines:** 0
- **Parameters:** `leg: BiomechanicalWalker.Leg`
- **Returns:** `float`
- **Calls:** lerp, get

### `_on_phase_changed()`
- **Lines:** 0
- **Parameters:** `leg_side: String, phase_name: String`
- **Returns:** `void`
- **Calls:** print

### `_on_step_completed()`
- **Lines:** 0
- **Parameters:** `foot: String`
- **Returns:** `void`
- **Calls:** play_footstep, get_node, has_node, print

### `handle_console_command()`
- **Lines:** 28
- **Parameters:** `command: String, args: Array`
- **Returns:** `String`
- **Calls:** str, size


## scripts/ragdoll/unified_biomechanical_walker.gd
**Category:** Ragdoll Systems
**Functions:** 20

### `_init()`
- **Lines:** 4
- **Parameters:** ``
- **Returns:** `void`

### `_init()`
- **Lines:** 4
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_physics, _create_body, _create_joints, print

### `_create_body()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_rigid_body, _create_leg, Vector3, add_child

### `_create_leg()`
- **Lines:** 0
- **Parameters:** `side: String, offset: Vector3`
- **Returns:** `Leg`
- **Calls:** _create_rigid_body, Vector3, new, add_child

### `_create_rigid_body()`
- **Lines:** 0
- **Parameters:** `name: String, size: Vector3, mass: float`
- **Returns:** `RigidBody3D`
- **Calls:** new, add_child

### `_create_joints()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_leg_joints, _create_6dof_joint, _limit_6dof_joint, print

### `_create_leg_joints()`
- **Lines:** 0
- **Parameters:** `leg: Leg, pelvis_body: RigidBody3D`
- **Returns:** `void`
- **Calls:** set_param, _create_hinge_joint, _create_6dof_joint, _limit_6dof_joint, set_flag

### `_create_6dof_joint()`
- **Lines:** 0
- **Parameters:** `body_a: RigidBody3D, body_b: RigidBody3D, joint_name: String`
- **Returns:** `Generic6DOFJoint3D`
- **Calls:** get_path, new, add_child

### `_create_hinge_joint()`
- **Lines:** 0
- **Parameters:** `body_a: RigidBody3D, body_b: RigidBody3D, joint_name: String`
- **Returns:** `HingeJoint3D`
- **Calls:** get_path, new, add_child

### `_limit_6dof_joint()`
- **Lines:** 0
- **Parameters:** `joint: Generic6DOFJoint3D, x_degrees: float, y_degrees: float, z_degrees: float`
- **Returns:** `void`
- **Calls:** set_param_y, set_param_z, set_flag_x, set_flag_y, set_param_x, set_flag_z, deg_to_rad

### `_setup_physics()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_gait, _maintain_balance

### `_update_gait()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_leg_phase, _apply_gait_forces

### `_update_leg_phase()`
- **Lines:** 0
- **Parameters:** `leg: Leg, delta: float`
- **Returns:** `void`
- **Calls:** emit, keys

### `_apply_gait_forces()`
- **Lines:** 0
- **Parameters:** `leg: Leg`
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3

### `_maintain_balance()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** apply_central_force, Vector3, apply_torque

### `set_walk_speed()`
- **Lines:** 0
- **Parameters:** `speed: float`
- **Returns:** `void`
- **Calls:** clamp, print

### `teleport_to()`
- **Lines:** 0
- **Parameters:** `position: Vector3`
- **Returns:** `void`
- **Calls:** print

### `get_debug_info()`
- **Lines:** 9
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** keys


## scripts/ragdoll_v2/advanced_ragdoll_controller.gd
**Category:** Ragdoll Systems
**Functions:** 28

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, _create_subsystems, print

### `initialize_ragdoll()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary`
- **Returns:** `void`
- **Calls:** _change_state, set_body_parts, push_error, set_ground_detection, print, get

### `_create_subsystems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** update_animation, _apply_ik_to_animation_goals, _update_ground_state, _apply_movement_physics, _update_velocity, _update_state_machine, _apply_balance_physics, _update_balance

### `_update_ground_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_foot_ground_info

### `_update_balance()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _point_to_line_distance, _calculate_center_of_mass, size, append, clear, _is_point_in_polygon

### `_update_velocity()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_update_state_machine()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_recovering_state, _update_idle_state, _update_walking_state, _update_preparing_state, _update_turning_state, _update_falling_state, _update_running_state

### `_update_idle_state()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _change_state, not, length, play_cycle

### `_update_preparing_state()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _change_state, length

### `_update_walking_state()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _change_state, length, _plan_next_step, play_cycle

### `_update_running_state()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _change_state, length, play_cycle

### `_update_turning_state()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _change_state

### `_update_falling_state()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _change_state

### `_update_recovering_state()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _change_state

### `_plan_next_step()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_viewport, get_safe_foot_placement, normalized, get, get_camera_3d

### `_apply_movement_physics()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** apply_torque, limit_length, length, get_viewport, abs, normalized, apply_central_force, get_camera_3d

### `_apply_balance_physics()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** apply_central_force, cross, apply_torque

### `_apply_ik_to_animation_goals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_limb_goal, solve_all_chains

### `_calculate_center_of_mass()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`

### `_is_point_in_polygon()`
- **Lines:** 0
- **Parameters:** `point: Vector3, polygon: Array`
- **Returns:** `bool`
- **Calls:** _point_to_line_distance, Vector2, polygon, length, size

### `_point_to_line_distance()`
- **Lines:** 0
- **Parameters:** `point: Vector3, line_start: Vector3, line_end: Vector3`
- **Returns:** `float`
- **Calls:** Vector2, dot, clamp, length

### `_change_state()`
- **Lines:** 0
- **Parameters:** `new_state: MovementState`
- **Returns:** `void`
- **Calls:** emit, keys, print

### `set_movement_input()`
- **Lines:** 0
- **Parameters:** `input: Vector2`
- **Returns:** `void`
- **Calls:** limit_length

### `set_turn_input()`
- **Lines:** 0
- **Parameters:** `input: float`
- **Returns:** `void`
- **Calls:** clamp

### `set_desired_speed()`
- **Lines:** 0
- **Parameters:** `speed: float`
- **Returns:** `void`
- **Calls:** clamp

### `execute_action()`
- **Lines:** 0
- **Parameters:** `action: String`
- **Returns:** `void`
- **Calls:** _change_state

### `get_state_info()`
- **Lines:** 12
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** length, get_animation_state, keys


## scripts/ragdoll_v2/ground_detection_system.gd
**Category:** Ragdoll Systems
**Functions:** 14

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_edge_detection, _create_debug_markers, _setup_foot_rays, print, get_tree

### `set_body_parts()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary`
- **Returns:** `void`
- **Calls:** _position_rays, get

### `_setup_foot_rays()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, Vector3, append, range

### `_setup_edge_detection()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, Vector3, new, add_child

### `_position_rays()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, range, size

### `get_ground_info()`
- **Lines:** 0
- **Parameters:** `world_position: Vector3, use_cache: bool = true`
- **Returns:** `GroundInfo`
- **Calls:** get_ticks_msec, snapped, str, _perform_ground_check

### `_perform_ground_check()`
- **Lines:** 0
- **Parameters:** `world_pos: Vector3`
- **Returns:** `GroundInfo`
- **Calls:** create, acos, has_meta, new, distance_to, get_world_3d, dot, get_meta, intersect_ray, _check_for_edge, rad_to_deg

### `_check_for_edge()`
- **Lines:** 0
- **Parameters:** `world_pos: Vector3`
- **Returns:** `bool`
- **Calls:** create, Vector3, get_world_3d, intersect_ray

### `get_foot_ground_info()`
- **Lines:** 0
- **Parameters:** `foot_name: String`
- **Returns:** `GroundInfo`
- **Calls:** acos, new, distance_to, dot, get_collision_normal, min, normalized, force_raycast_update, _check_for_edge, rad_to_deg, get_collision_point, is_colliding

### `get_safe_foot_placement()`
- **Lines:** 0
- **Parameters:** `current_pos: Vector3, desired_direction: Vector3, step_length: float`
- **Returns:** `Vector3`
- **Calls:** get_ground_info, rotated, deg_to_rad

### `get_balance_assessment()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get_foot_ground_info, abs

### `_create_debug_markers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, range, new, add_child

### `update_debug_visualization()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** acos, dot, get_collision_normal, is_empty, size, rad_to_deg, get_collision_point, is_colliding

### `_physics_process()`
- **Lines:** 14
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** update_debug_visualization, get_ticks_msec, erase, append, size


## scripts/ragdoll_v2/ik_solver.gd
**Category:** Ragdoll Systems
**Functions:** 18

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `set_body_parts()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary`
- **Returns:** `void`
- **Calls:** _setup_ik_chains

### `_setup_ik_chains()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, Vector3, _has_parts, print, size

### `_has_parts()`
- **Lines:** 0
- **Parameters:** `part_names: Array`
- **Returns:** `bool`

### `solve_chain()`
- **Lines:** 0
- **Parameters:** `chain_name: String, target_position: Vector3, weight: float = 1.0`
- **Returns:** `void`
- **Calls:** _solve_two_bone_ik_physics

### `_solve_two_bone_ik_physics()`
- **Lines:** 0
- **Parameters:** `chain: IKChain, target: Vector3, weight: float`
- **Returns:** `void`
- **Calls:** acos, distance_to, _calculate_pole_direction, clamp, length, _apply_ik_forces, normalized, deg_to_rad, rotated, cross, rad_to_deg

### `_calculate_pole_direction()`
- **Lines:** 0
- **Parameters:** `chain: IKChain, root_pos: Vector3, target: Vector3`
- **Returns:** `Vector3`
- **Calls:** dot, cross, length, normalized

### `_apply_ik_forces()`
- **Lines:** 0
- **Parameters:** `chain: IKChain, middle_target: Vector3, end_target: Vector3, weight: float`
- **Returns:** `void`
- **Calls:** apply_central_force, _apply_alignment_torques, length

### `_apply_alignment_torques()`
- **Lines:** 0
- **Parameters:** `chain: IKChain, weight: float`
- **Returns:** `void`
- **Calls:** cross, apply_torque, normalized

### `solve_all_chains()`
- **Lines:** 0
- **Parameters:** `targets: Dictionary, weights: Dictionary = {}`
- **Returns:** `void`
- **Calls:** get, solve_chain

### `get_chain_info()`
- **Lines:** 0
- **Parameters:** `chain_name: String`
- **Returns:** `Dictionary`
- **Calls:** _get_chain_bend_angle, _get_chain_length

### `_get_chain_length()`
- **Lines:** 0
- **Parameters:** `chain: IKChain`
- **Returns:** `float`
- **Calls:** distance_to

### `_get_chain_bend_angle()`
- **Lines:** 0
- **Parameters:** `chain: IKChain`
- **Returns:** `float`
- **Calls:** acos, dot, clamp, normalized, rad_to_deg

### `enable_debug()`
- **Lines:** 0
- **Parameters:** `enabled: bool`
- **Returns:** `void`
- **Calls:** _clear_debug_lines

### `_create_debug_line()`
- **Lines:** 0
- **Parameters:** `from: Vector3, to: Vector3, color: Color`
- **Returns:** `void`
- **Calls:** line

### `_clear_debug_lines()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, clear

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`
- **Calls:** _update_debug_visualization

### `_update_debug_visualization()`
- **Lines:** 27
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** darkened, _clear_debug_lines, _create_debug_line


## scripts/ragdoll_v2/keypoint_animation_system.gd
**Category:** Ragdoll Systems
**Functions:** 19

### `get_frame_at_time()`
- **Lines:** 0
- **Parameters:** `normalized_time: float`
- **Returns:** `Dictionary`
- **Calls:** _apply_easing, range, size, lerp

### `_apply_easing()`
- **Lines:** 17
- **Parameters:** `t: float, easing: String`
- **Returns:** `float`
- **Calls:** pow

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_animation_cycles, _setup_default_keypoints, print

### `set_body_parts()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary`
- **Returns:** `void`
- **Calls:** _update_rest_positions

### `set_ground_detection()`
- **Lines:** 0
- **Parameters:** `detector: GroundDetectionSystem`
- **Returns:** `void`

### `_setup_default_keypoints()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new

### `_update_rest_positions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_create_animation_cycles()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, Vector3, _create_run_cycle, duplicate, append, _create_crouch_cycle, _create_turn_cycle

### `_create_run_cycle()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new

### `_create_turn_cycle()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new

### `_create_crouch_cycle()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new

### `play_cycle()`
- **Lines:** 0
- **Parameters:** `cycle_name: String, transition_time: float = 0.3`
- **Returns:** `void`
- **Calls:** print, push_error

### `update_animation()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** fmod, _apply_frame_goals, _process_animation_events, min, lerp, get_frame_at_time

### `_apply_frame_goals()`
- **Lines:** 0
- **Parameters:** `goals: Dictionary`
- **Returns:** `void`
- **Calls:** ends_with, get_ground_info, get, get_parent

### `_process_animation_events()`
- **Lines:** 0
- **Parameters:** `normalized_time: float`
- **Returns:** `void`

### `get_limb_goal()`
- **Lines:** 0
- **Parameters:** `limb_name: String`
- **Returns:** `Vector3`

### `set_limb_goal_weight()`
- **Lines:** 0
- **Parameters:** `limb_name: String, weight: float`
- **Returns:** `void`
- **Calls:** clamp

### `is_foot_in_support_phase()`
- **Lines:** 0
- **Parameters:** `foot_name: String`
- **Returns:** `bool`

### `get_animation_state()`
- **Lines:** 9
- **Parameters:** ``
- **Returns:** `Dictionary`


## scripts/ragdoll_v2/ragdoll_v2_spawner.gd
**Category:** Ragdoll Systems
**Functions:** 9

### `spawn_ragdoll_v2()`
- **Lines:** 0
- **Parameters:** `spawn_position: Vector3 = Vector3.ZERO`
- **Returns:** `Node3D`
- **Calls:** _create_joints, new, add_child, initialize_ragdoll, set_meta, print, get_tree, add_to_group, _create_body_parts

### `_create_body_parts()`
- **Lines:** 0
- **Parameters:** `parent: Node3D`
- **Returns:** `Dictionary`
- **Calls:** Vector3, set_meta, new, add_child

### `_create_joints()`
- **Lines:** 0
- **Parameters:** `parts: Dictionary, parent: Node3D`
- **Returns:** `void`
- **Calls:** _create_joint

### `_create_joint()`
- **Lines:** 0
- **Parameters:** `body_a: RigidBody3D, body_b: RigidBody3D, joint_name: String, parent: Node3D`
- **Returns:** `void`
- **Calls:** set_param, new, push_error, add_child, set_flag, get_path, deg_to_rad

### `register_console_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null, has_method

### `_cmd_spawn_ragdoll_v2()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** Vector3, spawn_ragdoll_v2, print, float, size

### `_cmd_ragdoll2_move()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** Vector2, get_meta, get_first_node_in_group, to_lower, set_movement_input, print, get_tree, size

### `_cmd_ragdoll2_state()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_meta, get_first_node_in_group, print, get_tree, get_state_info

### `_cmd_ragdoll2_debug()`
- **Lines:** 16
- **Parameters:** `args: Array`
- **Returns:** `void`
- **Calls:** get_meta, get_first_node_in_group, enable_debug, print, get_tree


## scripts/test/automated_warning_fixer.gd
**Category:** Testing Systems
**Functions:** 6

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`

### `_on_body_entered()`
- **Lines:** 0
- **Parameters:** `body: Node2D`
- **Returns:** `void`
- **Calls:** print

### `calculate_damage()`
- **Lines:** 3
- **Parameters:** `attacker: Node, defender: Node, weapon: String`
- **Returns:** `int`

### `_process()`
- **Lines:** 0
- **Parameters:** `_delta: float`
- **Returns:** `void`

### `_on_body_entered()`
- **Lines:** 0
- **Parameters:** `_body: Node2D`
- **Returns:** `void`
- **Calls:** print

### `calculate_damage()`
- **Lines:** 3
- **Parameters:** `_attacker: Node, defender: Node, _weapon: String`
- **Returns:** `int`


## scripts/test/debug_scene_inspector.gd
**Category:** Testing Systems
**Functions:** 4

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** inspect_scene

### `inspect_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_class, get_children, s, print, get_tree, _print_tree

### `_print_tree()`
- **Lines:** 0
- **Parameters:** `node: Node, indent: int, max_depth: int`
- **Returns:** `void`
- **Calls:** get_children, repeat, _print_tree, print

### `get_node_info()`
- **Lines:** 17
- **Parameters:** `path: String`
- **Returns:** `void`
- **Calls:** get_class, get_node_or_null, get_script, print, get_groups


## scripts/test/final_universal_check.gd
**Category:** Testing Systems
**Functions:** 1

### `_ready()`
- **Lines:** 45
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, queue_free, has_node, get_node_or_null, print, get_tree


## scripts/test/floodgate_test.gd
**Category:** Testing Systems
**Functions:** 12

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, push_error, get_node, connect, print, get_tree, run_all_tests

### `run_all_tests()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, test_asset_library, test_stress_operations, show_test_results, test_fourth_dimensional_magic, test_sixth_dimensional_magic, test_third_dimensional_magic, print, get_tree, test_first_dimensional_magic, test_second_dimensional_magic

### `test_first_dimensional_magic()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** first_dimensional_magic, new, add_child, Vector3, Magic, print, append, get_tree, deg_to_rad

### `test_second_dimensional_magic()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** second_dimensional_magic, new, Magic, print

### `test_third_dimensional_magic()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** third_dimensional_magic, Vector3, Magic, print

### `test_fourth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, Vector3, get_node_or_null, Magic, fourth_dimensional_magic, print, get_tree, deg_to_rad

### `test_sixth_dimensional_magic()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, sixth_dimensional_magic, get_node_or_null, Magic, print

### `test_asset_library()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** search_assets, str, print, get_catalog_summary, size, load_asset

### `test_stress_operations()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, Test, get_ticks_msec, str, Vector3, fourth_dimensional_magic, second_dimensional_magic, fifth_dimensional_magic, print, range

### `show_test_results()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_loaded_assets_list, get_registered_nodes, str, print, size

### `_on_operation_completed()`
- **Lines:** 0
- **Parameters:** `operation, success`
- **Returns:** `void`
- **Calls:** str, get, print

### `_exit_tree()`
- **Lines:** 5
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, is_instance_valid


## scripts/test/function_flow_tracker.gd
**Category:** Testing Systems
**Functions:** 8

### `trace_function_call()`
- **Lines:** 0
- **Parameters:** `script_name: String, function_name: String, params: Array = []`
- **Returns:** `void`
- **Calls:** get_ticks_msec, push_back, _check_floodgate_trigger, append, size

### `trace_function_return()`
- **Lines:** 0
- **Parameters:** `script_name: String, function_name: String, return_value = null`
- **Returns:** `void`
- **Calls:** get_ticks_msec, back, is_empty, pop_back

### `_check_floodgate_trigger()`
- **Lines:** 0
- **Parameters:** `script_name: String, function_name: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, has

### `generate_flow_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** sort_custom, min, append, size, get

### `test_execution_path()`
- **Lines:** 0
- **Parameters:** `path_name: String`
- **Returns:** `Dictionary`
- **Calls:** append, trace_function_call, has, trace_function_return

### `record_fix_applied()`
- **Lines:** 0
- **Parameters:** `error_type: String, file_path: String, fix_description: String`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, has

### `simulate_user_action()`
- **Lines:** 0
- **Parameters:** `action: String`
- **Returns:** `Array`
- **Calls:** get_tree_models, _on_input_submitted, execute_command, _input, request_spawn, _cmd_create_tree, _parse_command, create_tree, _physics_process, toggle_console, get

### `get_test_recommendations()`
- **Lines:** 16
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** append, size


## scripts/test/integration_test.gd
**Category:** Testing Systems
**Functions:** 4

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _test_console_commands, _test_ragdoll_enhancements, _test_jsh_systems, print

### `_test_jsh_systems()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, has_node, has_method, print

### `_test_ragdoll_enhancements()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_action_state, has_node, take_damage, has_method, print, get_tree, size, get_nodes_in_group

### `_test_console_commands()`
- **Lines:** 14
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node, has_node, has_method, print


## scripts/test/layer_system_demo.gd
**Category:** Testing Systems
**Functions:** 7

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _print_instructions, print, _create_demo_environment, _setup_demo_path, _create_demo_ragdoll

### `_create_demo_ragdoll()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, Vector3, set_script

### `_create_demo_environment()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, load, Vector3, set_script

### `_setup_demo_path()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, Color, add_debug_line, range, size

### `_print_instructions()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `void`

### `_physics_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** distance_to, has_method, is_layer_visible, set_text_state, normalized, Color, add_debug_line, size

### `handle_console_command()`
- **Lines:** 20
- **Parameters:** `command: String, args: Array`
- **Returns:** `String`
- **Calls:** str, float, size, Vector3


## scripts/test/minimal_universal_test.gd
**Category:** Testing Systems
**Functions:** 2

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, get_tree, get_node_or_null, print

### `_test_command()`
- **Lines:** 9
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_node_or_null, has_method, print


## scripts/test/run_warning_fixes.gd
**Category:** Testing Systems
**Functions:** 7

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** load, _input, _apply_fixes, _on_body_entered, _create_backups, _analyze_files, print, _generate_report, _process

### `_analyze_files()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, size, file_exists, print

### `_create_backups()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, file_exists, get_file, get_datetime_string_from_system, make_dir, replace, print, dir_exists

### `_apply_fixes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** file_exists, load, get_file, fix_file, print, size

### `_generate_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _apply_fixes, print

### `show_examples()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _on_button_pressed, _on_body_entered, emit_signal, print, _process
- **Signals:** hit

### `test_single_file()`
- **Lines:** 14
- **Parameters:** `file_path: String`
- **Returns:** `void`
- **Calls:** load, fix_file, print, strip_edges, size


## scripts/test/startup_diagnostic.gd
**Category:** Testing Systems
**Functions:** 5

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _check_critical_nodes, _check_input_actions, _check_autoloads, _check_common_issues, print

### `_check_autoloads()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, print

### `_check_input_actions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** has_action, print

### `_check_critical_nodes()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, has_node, print

### `_check_common_issues()`
- **Lines:** 14
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, has_method, get_setting, print


## scripts/test/startup_test.gd
**Category:** Testing Systems
**Functions:** 1

### `_ready()`
- **Lines:** 29
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, execute_command, get_node, has_node, has_method, print, get_tree


## scripts/test/test_universal_being_assets.gd
**Category:** Testing Systems
**Functions:** 2

### `run_tests()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_being, _check_manifestation, Vector3, get_node_or_null, print

### `_check_manifestation()`
- **Lines:** 49
- **Parameters:** `being: Node3D, expected_type: String`
- **Returns:** `void`
- **Calls:** get_class, get_children, parts, has_method, get_script, print, leaves, get


## scripts/test/universal_entity_test.gd
**Category:** Testing Systems
**Functions:** 1

### `_ready()`
- **Lines:** 49
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null, print


## scripts/test/universal_launcher.gd
**Category:** Testing Systems
**Functions:** 1

### `_ready()`
- **Lines:** 41
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, _execute_command, get_node_or_null, has_method, print, get_tree


## scripts/test/universal_ready_check.gd
**Category:** Testing Systems
**Functions:** 1

### `_ready()`
- **Lines:** 43
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, queue_free, has_node, get_node_or_null, print, get_tree


## scripts/tools/optimize_autoloads.gd
**Category:** Development Tools
**Functions:** 3

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** analyze_autoloads, print

### `analyze_autoloads()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Essential, get_children, essential, Unknown, str, get_child_count, get_script, print, append, get_tree, size

### `disable_heavy_autoloads()`
- **Lines:** 17
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, has_method, set_process_input, set_process_unhandled_input, print, get_tree, set_physics_process, set_process


## scripts/tools/organize_project_files.gd
**Category:** Development Tools
**Functions:** 2

### `organize_files()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, make_dir, print, _move_files_to_folder, dir_exists

### `_move_files_to_folder()`
- **Lines:** 11
- **Parameters:** `dir: DirAccess, files: Array, target_folder: String`
- **Returns:** `void`
- **Calls:** rename, s, file_exists, print


## scripts/tools/script_migration_helper.gd
**Category:** Development Tools
**Functions:** 12

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print

### `scan_all_scripts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** clear, size, _scan_directory, print

### `_scan_directory()`
- **Lines:** 0
- **Parameters:** `path: String`
- **Returns:** `void`
- **Calls:** open, get_next, begins_with, _scan_directory, _analyze_script, current_is_dir, ends_with, list_dir_begin

### `_analyze_script()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `void`
- **Calls:** get_as_text, open, close, emit, _physics_process, append, _process

### `generate_migration_plan()`
- **Lines:** 0
- **Parameters:** `script_analysis: Dictionary`
- **Returns:** `String`
- **Calls:** get_file, register_process, to_lower, _ready, _physics_process, _process, process_managed

### `auto_migrate_script()`
- **Lines:** 0
- **Parameters:** `script_path: String`
- **Returns:** `bool`
- **Calls:** close, new, print, process_managed, _process, get_as_text, compile, length, store_string, _ready, open, get_file, sub, register_process, tset_process, find, search, replace, tset_physics_process, insert, _physics_process, set_process

### `migrate_all_scripts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** auto_migrate_script, emit, print, scan_all_scripts, size

### `get_migration_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** get_datetime_string_from_system, size, get_file

### `register_console_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null

### `_cmd_scan_scripts()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** scan_all_scripts, get_node, _print_to_console

### `_cmd_show_report()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** scan_all_scripts, get_node, _print_to_console, get_file

### `_cmd_migrate_all()`
- **Lines:** 4
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, migrate_all_scripts


## scripts/tutorial/tutorial_manager.gd
**Category:** Tutorial Systems
**Functions:** 19

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_tutorial_ui, get_node_or_null, connect, print, values

### `_create_tutorial_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, set_anchors_and_offsets_preset, add_child, set_offsets_preset, console, set_anchors_preset

### `start_tutorial()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_instructions, get_ticks_msec, get_datetime_string_from_system, _load_tutorial_scene, print, _log_action

### `stop_tutorial()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** keys, _calculate_completion_percentage, _save_log, change_scene_to_file, get_tree, print, _log_action

### `_load_tutorial_scene()`
- **Lines:** 0
- **Parameters:** `phase: TutorialPhase`
- **Returns:** `void`
- **Calls:** _log_action, keys, print

### `_update_instructions()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _is_phase_complete, _update_progress, _advance_to_next_phase

### `_update_progress()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_ticks_msec, min, has, float, size

### `_is_phase_complete()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`
- **Calls:** get_ticks_msec, has

### `_advance_to_next_phase()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_instructions, _show_phase_transition, stop_tutorial, keys, get_ticks_msec, _load_tutorial_scene, _log_action, clear

### `_show_phase_transition()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, set_anchors_and_offsets_preset, add_child, tween_callback, tween_property, create_tween

### `_on_command_executed()`
- **Lines:** 0
- **Parameters:** `command: String, args: Array`
- **Returns:** `void`
- **Calls:** keys, trim_prefix, begins_with, _log_action, size

### `_log_action()`
- **Lines:** 0
- **Parameters:** `action_type: String, data: Dictionary`
- **Returns:** `void`
- **Calls:** get_ticks_msec, append, print

### `_save_log()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, close, get_ticks_msec, get_datetime_string_from_system, store_string, _calculate_completion_percentage, print, stringify

### `_calculate_completion_percentage()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `float`
- **Calls:** return, float, int

### `show_hint()`
- **Lines:** 0
- **Parameters:** `hint_text: String, duration: float = 3.0`
- **Returns:** `void`
- **Calls:** new, set_anchors_and_offsets_preset, add_child, tween_callback, tween_property, set_offsets_preset, tween_interval, create_tween

### `is_tutorial_active()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`

### `get_current_phase()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `TutorialPhase`

### `log_custom_action()`
- **Lines:** 3
- **Parameters:** `action: String, data: Dictionary`
- **Returns:** `void`
- **Calls:** _log_action


## scripts/ui/advanced_object_inspector.gd
**Category:** Interface Systems
**Functions:** 64

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_shortcuts, _connect_signals, print, hide, _setup_ui

### `_setup_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, set_anchors_and_offsets_preset, add_child, _create_transform_tab, _create_properties_tab, _create_physics_tab, _create_scene_tab, _create_materials_tab, _apply_advanced_style, _create_title_bar

### `_create_title_bar()`
- **Lines:** 0
- **Parameters:** `parent: VBoxContainer`
- **Returns:** `void`
- **Calls:** Vector2, new, add_check_item, add_child, get_popup, add_item, add_separator

### `_create_properties_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, new, add_child

### `_create_transform_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Rotation, new, _create_vector3_editor, add_child

### `_create_materials_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child

### `_create_physics_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child

### `_create_scene_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_filter, new, add_child

### `_create_vector3_editor()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `HBoxContainer`
- **Calls:** new, add_child

### `_apply_advanced_style()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_theme_stylebox_override, Color, add_theme_font_size_override, add_theme_color_override

### `_connect_signals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, get_popup

### `_setup_shortcuts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `inspect_object()`
- **Lines:** 0
- **Parameters:** `object: Node`
- **Returns:** `void`
- **Calls:** get_class, _update_properties_tab, _update_transform_tab, _update_materials_tab, show, _update_scene_tab, _add_to_history, print, _update_physics_tab

### `_update_properties_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _populate_properties, _clear_properties

### `_update_transform_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** rad_to_deg, get_children

### `_update_materials_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_update_physics_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_update_scene_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, get_tree, _build_scene_tree

### `_build_scene_tree()`
- **Lines:** 0
- **Parameters:** `node: Node, parent_item: TreeItem`
- **Returns:** `void`
- **Calls:** set_custom_bg_color, get_class, set_text, get_children, set_metadata, _build_scene_tree, Color, create_item

### `_populate_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _categorize_properties, size, get_property_list, _create_category_section

### `_categorize_properties()`
- **Lines:** 0
- **Parameters:** `property_list: Array`
- **Returns:** `Dictionary`
- **Calls:** append

### `_create_category_section()`
- **Lines:** 0
- **Parameters:** `category_name: String, properties: Array`
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, str, connect, _create_enhanced_property_editor, Color, add_theme_font_size_override, size, add_theme_color_override

### `_create_enhanced_property_editor()`
- **Lines:** 0
- **Parameters:** `property: Dictionary, parent: Control`
- **Returns:** `void`
- **Calls:** Vector2, new, _connect_advanced_editor_signal, add_child, _should_show_property, _get_type_name, _is_property_modified, connect, _humanize_property_name, _reset_property, _create_advanced_editor_for_type, get

### `_create_advanced_editor_for_type()`
- **Lines:** 0
- **Parameters:** `type: int, current_value: Variant, property: Dictionary`
- **Returns:** `Control`
- **Calls:** get_class, set_value, Vector2, new, add_child, _create_vector2_editor, _get_type_name, str, length, connect, has, _create_vector3_editor_with_value, _open_array_editor, inspect_object, size, _setup_range_from_hint, add_theme_color_override

### `_create_vector2_editor()`
- **Lines:** 0
- **Parameters:** `value: Vector2`
- **Returns:** `HBoxContainer`
- **Calls:** new, add_child

### `_create_vector3_editor_with_value()`
- **Lines:** 0
- **Parameters:** `value: Vector3`
- **Returns:** `HBoxContainer`
- **Calls:** range, new, add_child

### `_on_save_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, popup_centered

### `_on_load_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, popup_centered

### `_on_scene_file_selected()`
- **Lines:** 0
- **Parameters:** `path: String`
- **Returns:** `void`
- **Calls:** _save_scene_to_file, _load_scene_from_file

### `_save_scene_to_file()`
- **Lines:** 0
- **Parameters:** `path: String`
- **Returns:** `void`
- **Calls:** pack, new, str, save, print, get_tree

### `_load_scene_from_file()`
- **Lines:** 0
- **Parameters:** `path: String`
- **Returns:** `void`
- **Calls:** emit

### `request_floodgate_operation()`
- **Lines:** 0
- **Parameters:** `operation: Dictionary`
- **Returns:** `void`
- **Calls:** queue_operation, get_node_or_null, has_method

### `_on_create_node()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_on_duplicate_node()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** request_floodgate_operation, get_parent

### `_on_delete_node()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** request_floodgate_operation, hide, _clear_properties

### `_humanize_property_name()`
- **Lines:** 0
- **Parameters:** `name: String`
- **Returns:** `String`
- **Calls:** substr, length, to_upper, strip_edges, split

### `_get_type_name()`
- **Lines:** 0
- **Parameters:** `type: int`
- **Returns:** `String`

### `_setup_range_from_hint()`
- **Lines:** 0
- **Parameters:** `control: Range, hint_string: String`
- **Returns:** `void`
- **Calls:** float, size, split

### `_is_property_modified()`
- **Lines:** 0
- **Parameters:** `prop_name: String, value: Variant`
- **Returns:** `bool`

### `_reset_property()`
- **Lines:** 0
- **Parameters:** `prop_name: String`
- **Returns:** `void`

### `_add_to_history()`
- **Lines:** 0
- **Parameters:** `object: Node`
- **Returns:** `void`
- **Calls:** append, pop_front, size

### `_undo_last_change()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_redo_last_change()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_open_array_editor()`
- **Lines:** 0
- **Parameters:** `prop_name: String, array: Array`
- **Returns:** `void`

### `_on_close_pressed()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, hide

### `_on_pin_toggled()`
- **Lines:** 0
- **Parameters:** `pressed: bool`
- **Returns:** `void`

### `_on_menu_item_selected()`
- **Lines:** 0
- **Parameters:** `id: int`
- **Returns:** `void`
- **Calls:** _update_properties_tab, _reset_all_properties, _import_properties, _export_properties

### `_on_search_changed()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** _update_properties_tab

### `_on_global_transform_toggled()`
- **Lines:** 0
- **Parameters:** `enabled: bool`
- **Returns:** `void`
- **Calls:** _update_transform_tab

### `_on_transform_reset()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_transform_tab

### `_on_scene_tree_item_selected()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** inspect_object, get_metadata, is_instance_valid, get_selected

### `_connect_advanced_editor_signal()`
- **Lines:** 0
- **Parameters:** `editor: Control, prop_name: String, prop_type: int`
- **Returns:** `void`
- **Calls:** bind, _on_string_changed, get_child_count, connect, get_child, range

### `_on_color_changed()`
- **Lines:** 0
- **Parameters:** `color: Color, prop_name: String`
- **Returns:** `void`
- **Calls:** _apply_property_change

### `_on_vector3_component_changed()`
- **Lines:** 0
- **Parameters:** `value: float, prop_name: String, component: int`
- **Returns:** `void`
- **Calls:** _apply_property_change, get

### `_on_bool_changed()`
- **Lines:** 0
- **Parameters:** `value: bool, prop_name: String`
- **Returns:** `void`
- **Calls:** _apply_property_change

### `_on_number_changed()`
- **Lines:** 0
- **Parameters:** `value: float, prop_name: String`
- **Returns:** `void`
- **Calls:** _apply_property_change, typeof, get, int

### `_on_string_changed()`
- **Lines:** 0
- **Parameters:** `text: String, prop_name: String`
- **Returns:** `void`
- **Calls:** _apply_property_change

### `_on_vector2_changed()`
- **Lines:** 0
- **Parameters:** `value: float, prop_name: String, component: String`
- **Returns:** `void`
- **Calls:** _apply_property_change, get

### `_apply_property_change()`
- **Lines:** 0
- **Parameters:** `prop_name: String, new_value: Variant`
- **Returns:** `void`
- **Calls:** set, str, emit, print, get

### `_clear_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, clear, get_children

### `_should_show_property()`
- **Lines:** 0
- **Parameters:** `property: Dictionary`
- **Returns:** `bool`
- **Calls:** begins_with, contains, to_lower

### `_export_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clipboard_set, print, get, stringify

### `_import_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set, _update_properties_tab, clipboard_get, new, parse, has_method, print

### `_reset_all_properties()`
- **Lines:** 3
- **Parameters:** ``
- **Returns:** `void`


## scripts/ui/asset_creator_panel.gd
**Category:** Interface Systems
**Functions:** 13

### `get_spectrum_color()`
- **Lines:** 0
- **Parameters:** `value: float`
- **Returns:** `Color`
- **Calls:** White, Red, Blue, clamp, Yellow, Black, floor, Color, Brown, lerp, Purple, Green, Orange, size, ceil, int

### `_on_spectrum_changed()`
- **Lines:** 0
- **Parameters:** `value: float, color_preview: Panel`
- **Returns:** `void`
- **Calls:** _update_preview_mesh, get_spectrum_color, new, add_theme_stylebox_override

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_preview, _setup_ui

### `_setup_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Rigid, connect, Static, _create_ui_elements, add_item, Character

### `_create_ui_elements()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_theme_constant_override, middle, Size, Vector2, new, set_anchors_and_offsets_preset, add_child, bind, Vector3, connect, Mass, look_at, set_custom_minimum_size, add_theme_font_size_override, _on_spectrum_changed, set_anchors_preset, Tags

### `_create_preview()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, queue_free, Vector3, _update_preview_mesh

### `_update_preview_mesh()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector3, get_spectrum_color, new, get_selected_id

### `_on_type_changed()`
- **Lines:** 0
- **Parameters:** `index: int`
- **Returns:** `void`

### `_on_mesh_changed()`
- **Lines:** 0
- **Parameters:** `index: int`
- **Returns:** `void`
- **Calls:** _update_preview_mesh

### `_on_size_changed()`
- **Lines:** 0
- **Parameters:** `value: float`
- **Returns:** `void`
- **Calls:** _update_preview_mesh

### `_on_create_pressed()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_custom_asset, push_error, Vector3, get_node_or_null, is_empty, emit, get_spectrum_color, print, _on_cancel_pressed, strip_edges, split

### `_on_cancel_pressed()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit

### `show_panel()`
- **Lines:** 4
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** grab_focus


## scripts/ui/blink_animation_controller.gd
**Category:** Interface Systems
**Functions:** 26

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_current_turn, new, add_child, str, _schedule_next_blink, get_node_or_null, connect, Callable, _initialize_timers, _create_default_animations, print, _schedule_next_flicker, _find_node_by_class, register_system, get_tree, _schedule_next_wink

### `_find_node_by_class()`
- **Lines:** 0
- **Parameters:** `node, class_name_str`
- **Returns:** `void`
- **Calls:** get_class, get_children, find, to_lower, get_script, get_path, _find_node_by_class, or

### `_initialize_timers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, new, Callable, connect

### `_create_default_animations()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_animation_library, add_track, add_animation, track_insert_key, track_set_path

### `_schedule_next_blink()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_debug_build, max, str, randf, start, print, pow

### `_schedule_next_wink()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_debug_build, max, str, randf, start, print, pow

### `_schedule_next_flicker()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** is_debug_build, max, str, randf, start, print, pow

### `_execute_blink()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, is_debug_build, str, randf, _schedule_next_blink, get_tree, print, _blink_node

### `_execute_wink()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, is_debug_build, randf, wink, print, _wink_node, get_tree, _schedule_next_wink

### `_execute_flicker()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, is_debug_build, str, randi, _schedule_next_flicker, print, get_tree, _flicker_node

### `_blink_node()`
- **Lines:** 0
- **Parameters:** `node_name: String, blink_count: int`
- **Returns:** `void`
- **Calls:** create_timer, has_parameter, is_instance_valid, apply_blink, has_method, has_property, tween_property, erase, has, emit_signal, get_tree, range, create_tween
- **Signals:** blink_ended, blink_started

### `_wink_node()`
- **Lines:** 0
- **Parameters:** `node_name: String, is_left: bool`
- **Returns:** `void`
- **Calls:** has_parameter, is_instance_valid, get_node_or_null, has_method, has_property, tween_property, erase, has, emit_signal, Color, create_tween, apply_wink
- **Signals:** wink_started, wink_ended

### `_flicker_node()`
- **Lines:** 0
- **Parameters:** `node_name: String, flicker_count: int`
- **Returns:** `void`
- **Calls:** create_timer, has_parameter, is_instance_valid, randf, has_method, has_property, tween_property, erase, has, emit_signal, apply_flicker, get_tree, range, create_tween
- **Signals:** flicker_started, flicker_ended

### `_on_blink_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _execute_blink

### `_on_wink_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _execute_wink

### `_on_flicker_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _execute_flicker

### `_on_turn_started()`
- **Lines:** 0
- **Parameters:** `turn_number`
- **Returns:** `void`
- **Calls:** create_timer, str, _schedule_next_blink, stop, _blink_node, _schedule_next_flicker, print, get_tree, _schedule_next_wink

### `register_node()`
- **Lines:** 0
- **Parameters:** `node_name: String, node: Node`
- **Returns:** `bool`
- **Calls:** has, print

### `unregister_node()`
- **Lines:** 0
- **Parameters:** `node_name: String`
- **Returns:** `bool`
- **Calls:** erase, has, print

### `trigger_blink()`
- **Lines:** 0
- **Parameters:** `node_name: String = "", blink_count: int = 1`
- **Returns:** `bool`
- **Calls:** _blink_node, print, has, empty

### `trigger_wink()`
- **Lines:** 0
- **Parameters:** `node_name: String = "", is_left: bool = true`
- **Returns:** `bool`
- **Calls:** _wink_node, print, has, empty

### `trigger_flicker()`
- **Lines:** 0
- **Parameters:** `node_name: String = "", flicker_count: int = 3`
- **Returns:** `bool`
- **Calls:** print, _flicker_node, has, empty

### `set_enabled()`
- **Lines:** 0
- **Parameters:** `is_enabled: bool`
- **Returns:** `void`
- **Calls:** stop, _schedule_next_blink, print, is_stopped

### `set_wink_enabled()`
- **Lines:** 0
- **Parameters:** `is_enabled: bool`
- **Returns:** `void`
- **Calls:** stop, print, _schedule_next_wink, is_stopped

### `set_flicker_enabled()`
- **Lines:** 0
- **Parameters:** `is_enabled: bool`
- **Returns:** `void`
- **Calls:** stop, print, _schedule_next_flicker, is_stopped

### `on_turn_changed()`
- **Lines:** 23
- **Parameters:** `turn_number: int, turn_data: Dictionary`
- **Returns:** `void`
- **Calls:** _schedule_next_blink, stop, _schedule_next_flicker, has, _schedule_next_wink


## scripts/ui/bryce_grid_interface.gd
**Category:** Interface Systems
**Functions:** 13

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_grid_cells, connect, _load_sample_entities, print, _calculate_grid_layout

### `_calculate_grid_layout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, max, print, get_viewport_rect, int

### `_create_grid_cells()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, queue_free, _create_cell, append, clear, range

### `_create_cell()`
- **Lines:** 0
- **Parameters:** `col: int, row: int`
- **Returns:** `Control`
- **Calls:** Vector2, new, bind, set_anchors_and_offsets_preset, add_child, str, add_theme_color_override, connect, set_border_width_all, add_theme_stylebox_override

### `_on_cell_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent, cell_index: int`
- **Returns:** `void`
- **Calls:** _select_cell

### `_on_cell_hover()`
- **Lines:** 0
- **Parameters:** `cell_index: int`
- **Returns:** `void`
- **Calls:** _update_cell_visual, size, emit_signal
- **Signals:** cell_hovered

### `_on_cell_unhover()`
- **Lines:** 0
- **Parameters:** `cell_index: int`
- **Returns:** `void`
- **Calls:** _update_cell_visual

### `_select_cell()`
- **Lines:** 0
- **Parameters:** `cell_index: int`
- **Returns:** `void`
- **Calls:** _update_cell_visual, size, emit_signal, print
- **Signals:** cell_selected

### `_update_cell_visual()`
- **Lines:** 0
- **Parameters:** `cell_index: int`
- **Returns:** `void`
- **Calls:** get_theme_stylebox, size, get_child

### `_on_window_resized()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_grid_cells, _calculate_grid_layout, _populate_grid

### `_load_sample_entities()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _populate_grid

### `_populate_grid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** range, size, min, _update_cell_visual

### `get_grid_info()`
- **Lines:** 8
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** float


## scripts/ui/console_world_view.gd
**Category:** Interface Systems
**Functions:** 16

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_theme_font_override, load, get_node_or_null, connect, _initialize_world_grid

### `_initialize_world_grid()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, clear, range

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_world_display

### `_update_world_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _initialize_world_grid, _generate_display_text, _place_entity_on_grid

### `_place_entity_on_grid()`
- **Lines:** 0
- **Parameters:** `entity_data: Dictionary`
- **Returns:** `void`
- **Calls:** Vector2, has, get, _world_to_grid

### `_world_to_grid()`
- **Lines:** 0
- **Parameters:** `world_pos: Vector2`
- **Returns:** `Vector2i`
- **Calls:** Vector2i, int

### `_generate_display_text()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`
- **Calls:** join, append, range, repeat, get

### `update_entity()`
- **Lines:** 0
- **Parameters:** `entity_id: String, data: Dictionary`
- **Returns:** `void`

### `remove_entity()`
- **Lines:** 0
- **Parameters:** `entity_id: String`
- **Returns:** `void`
- **Calls:** erase

### `clear_entities()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear

### `pan_view()`
- **Lines:** 0
- **Parameters:** `direction: Vector2`
- **Returns:** `void`

### `zoom_view()`
- **Lines:** 0
- **Parameters:** `factor: float`
- **Returns:** `void`
- **Calls:** clamp

### `center_on_position()`
- **Lines:** 0
- **Parameters:** `world_pos: Vector3`
- **Returns:** `void`
- **Calls:** Vector2

### `_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** pan_view, zoom_view

### `_on_layer_visibility_changed()`
- **Lines:** 0
- **Parameters:** `layer: int, visible: bool`
- **Returns:** `void`

### `handle_console_command()`
- **Lines:** 32
- **Parameters:** `command: String, args: Array`
- **Returns:** `String`
- **Calls:** str, Vector2, float, size


## scripts/ui/creative_mode_inventory.gd
**Category:** Interface Systems
**Functions:** 15

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_ui, get_node_or_null, _populate_inventory, set_process_unhandled_input, print

### `_create_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_theme_constant_override, Vector2, new, bind, add_child, add_theme_color_override, connect, get_viewport, Color, get_child, add_theme_font_size_override, add_theme_stylebox_override

### `_unhandled_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** is_action_pressed, toggle_inventory, get_viewport, hide_inventory, set_input_as_handled

### `toggle_inventory()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** show_inventory, hide_inventory

### `show_inventory()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree

### `hide_inventory()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree

### `_populate_inventory()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, clear, _get_filtered_items, _create_item_slot

### `_get_filtered_items()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** get

### `_create_item_slot()`
- **Lines:** 0
- **Parameters:** `item_id: String, item_data: Dictionary`
- **Returns:** `void`
- **Calls:** new, bind, add_child, connect, Color, _generate_placeholder_icon, append, add_theme_font_size_override, add_theme_stylebox_override

### `_generate_placeholder_icon()`
- **Lines:** 0
- **Parameters:** `item_id: String`
- **Returns:** `ImageTexture`
- **Calls:** create, create_from_image, new, fill

### `_on_category_selected()`
- **Lines:** 0
- **Parameters:** `category_id: String`
- **Returns:** `void`
- **Calls:** _populate_inventory

### `_on_item_selected()`
- **Lines:** 0
- **Parameters:** `item_id: String, item_data: Dictionary`
- **Returns:** `void`
- **Calls:** execute_command, get_node_or_null, has_method, emit, print

### `_on_close_pressed()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** hide_inventory

### `refresh_inventory()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _populate_inventory

### `set_category()`
- **Lines:** 10
- **Parameters:** `category_id: String`
- **Returns:** `void`
- **Calls:** keys, get_child_count, _populate_inventory, get_child, range


## scripts/ui/enhanced_object_inspector.gd
**Category:** Interface Systems
**Functions:** 23

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, connect, print, _create_inspector_ui

### `_position_panel()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, get_viewport

### `_create_inspector_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_theme_constant_override, Vector2, call_deferred, new, add_child, connect, add_theme_font_size_override

### `inspect_object()`
- **Lines:** 0
- **Parameters:** `obj: Node`
- **Returns:** `void`
- **Calls:** _add_physics_properties, is_instance_valid, get_children, _add_metadata_properties, queue_free, get_meta, _add_basic_properties, emit, _add_transform_properties, start, _add_custom_properties, print, clear

### `_add_basic_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _add_label_property, get_class, _add_section_header, join, get_groups, size, _add_string_property

### `_add_transform_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _add_section_header, _add_vector3_property

### `_add_physics_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _add_section_header, _add_vector3_property, _add_bool_property, _add_float_property

### `_add_metadata_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _add_label_property, _add_section_header, _add_bool_property, str, get_meta, size, get_meta_list

### `_add_custom_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _add_action_button, _add_label_property, _add_section_header, get_meta, join, size

### `_add_section_header()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** new, add_child, Color, add_theme_font_size_override, add_theme_color_override

### `_add_label_property()`
- **Lines:** 0
- **Parameters:** `label: String, value: String`
- **Returns:** `void`
- **Calls:** add_theme_color_override, new, Color, add_child

### `_add_string_property()`
- **Lines:** 0
- **Parameters:** `label: String, property: String, value: String`
- **Returns:** `void`
- **Calls:** connect, new, _on_property_changed, add_child

### `_add_float_property()`
- **Lines:** 0
- **Parameters:** `label: String, property: String, value: float`
- **Returns:** `void`
- **Calls:** connect, new, _on_property_changed, add_child

### `_add_bool_property()`
- **Lines:** 0
- **Parameters:** `label: String, property: String, value: bool, is_metadata: bool = false`
- **Returns:** `void`
- **Calls:** connect, new, _on_property_changed, add_child

### `_add_vector3_property()`
- **Lines:** 0
- **Parameters:** `label: String, property: String, value: Vector3`
- **Returns:** `void`
- **Calls:** _on_vector3_component_changed, connect, new, add_child

### `_add_action_button()`
- **Lines:** 0
- **Parameters:** `action: String`
- **Returns:** `void`
- **Calls:** _trigger_action, new, add_child, connect, capitalize

### `_on_property_changed()`
- **Lines:** 0
- **Parameters:** `property: String, value: Variant`
- **Returns:** `void`
- **Calls:** set, is_instance_valid, modify_object, str, get_node_or_null, emit, print

### `_on_vector3_component_changed()`
- **Lines:** 0
- **Parameters:** `property: String, component: String, value: float`
- **Returns:** `void`
- **Calls:** _on_property_changed, is_instance_valid, get

### `_trigger_action()`
- **Lines:** 0
- **Parameters:** `action: String`
- **Returns:** `void`
- **Calls:** start_walking, has_method, say_something, print

### `_update_live_values()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_value_no_signal, is_instance_valid, _on_close_pressed

### `_on_close_pressed()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** stop

### `setup_mouse_integration()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `get_inspected_object()`
- **Lines:** 3
- **Parameters:** ``
- **Returns:** `Node`


## scripts/ui/feature_test_panel.gd
**Category:** Interface Systems
**Functions:** 31

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_anchors_and_offsets_preset, _create_buttons, print, _setup_references, _setup_ui

### `_setup_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_theme_constant_override, Vector2, new, add_child, add_theme_color_override, add_spacer, connect, Color, add_theme_font_size_override, add_theme_stylebox_override

### `_create_buttons()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, bind, add_child, add_theme_stylebox_override, set_meta, connect, duplicate, Color, add_theme_font_size_override, add_theme_color_override

### `_setup_references()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_node_or_null

### `_on_button_pressed()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** _execute_command, _mark_success, call_deferred, call, get_meta, _update_status, has

### `_test_console()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _mark_result

### `_test_commands()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** _mark_result

### `_test_console_fix()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _mark_success

### `_test_inspector()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, _mark_result, get_tree, size, get_nodes_in_group

### `_test_selection()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _mark_success

### `_test_edit()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _mark_success

### `_spawn_astral_being()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf_range, new, add_child, preload, str, Vector3, randf, Color, append, get_tree, size

### `_test_astral_spawn()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, _spawn_astral_being, _mark_result, get_tree, size

### `_test_astral_move()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, _mark_success, _spawn_astral_being, Vector3, is_empty, add_task, get_tree

### `_test_astral_organize()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** randf_range, create_timer, _mark_success, new, _spawn_astral_being, add_child, Vector3, is_empty, add_task, get_tree, range

### `_test_astral_light()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, _mark_success, _spawn_astral_being, Vector3, is_empty, add_task, get_tree

### `_test_ragdoll_spawn()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, _mark_result, get_tree, size, get_nodes_in_group

### `_test_ragdoll_walk()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _mark_success

### `_test_ragdoll_debug()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _mark_success

### `_test_create_object()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _mark_success

### `_test_save_scene()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _mark_success

### `_test_clear_scene()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _mark_success

### `_test_floodgate_status()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** _mark_success, get_node_or_null, _update_status, _mark_failure

### `_test_floodgate_queue()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** _mark_success, queue_operation, get_node_or_null, has_method, _mark_failure

### `_test_performance()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _mark_success

### `_mark_success()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** get_meta, Color, _update_test_count

### `_mark_failure()`
- **Lines:** 0
- **Parameters:** `button: Button`
- **Returns:** `void`
- **Calls:** get_meta, Color, _update_test_count

### `_mark_result()`
- **Lines:** 0
- **Parameters:** `button: Button, success: bool`
- **Returns:** `void`
- **Calls:** _mark_success, _mark_failure

### `_update_status()`
- **Lines:** 0
- **Parameters:** `text: String, color: Color = Color.WHITE`
- **Returns:** `void`
- **Calls:** add_theme_color_override

### `_update_test_count()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** d, _update_status, values, float, size

### `_toggle_minimize()`
- **Lines:** 11
- **Parameters:** ``
- **Returns:** `void`


## scripts/ui/global_variable_spreadsheet.gd
**Category:** Interface Systems
**Functions:** 27

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_ui, _scan_everything, print

### `_create_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_theme_constant_override, _create_performance_tab, _create_autoloads_tab, new, set_anchors_and_offsets_preset, add_child, add_spacer, _create_scripts_tab, connect, add_theme_font_size_override, _create_scene_nodes_tab

### `_create_autoloads_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_tab_title, new, add_child

### `_create_scene_nodes_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_tab_title, new, add_child

### `_create_scripts_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_tab_title, new, add_child

### `_create_performance_tab()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_tab_title, new, add_child

### `_scan_everything()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _scan_scripts, _scan_autoloads, print, _update_all_displays, clear, _scan_scene_tree

### `_scan_autoloads()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _get_all_methods, get_script, get_node_or_null, _get_all_properties

### `_scan_scene_tree()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, _scan_node_recursive

### `_scan_node_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node, path: String = ""`
- **Returns:** `void`
- **Calls:** get_class, get_children, _scan_node_recursive, get_child_count, count, get_script, _get_all_properties

### `_scan_scripts()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** values, _get_script_static_vars

### `_get_all_properties()`
- **Lines:** 0
- **Parameters:** `obj: Object`
- **Returns:** `Dictionary`
- **Calls:** begins_with, get, get_property_list

### `_get_all_methods()`
- **Lines:** 0
- **Parameters:** `obj: Object`
- **Returns:** `Array`
- **Calls:** begins_with, append, get_method_list

### `_get_script_static_vars()`
- **Lines:** 0
- **Parameters:** `script: Script`
- **Returns:** `Dictionary`

### `_update_all_displays()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_autoloads_display, _update_performance_display, _update_scene_nodes_display, _update_scripts_display

### `_update_autoloads_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, add_child, queue_free, get_child, _create_object_expander

### `_update_scene_nodes_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, new, add_child, queue_free, str, get_child, _create_node_expander, size

### `_update_scripts_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, new, add_child, queue_free, str, get_child

### `_update_performance_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, new, add_child, queue_free, str, get_monitor, Color, get_child, get_frames_per_second, add_theme_color_override

### `_create_object_expander()`
- **Lines:** 0
- **Parameters:** `obj_name: String, data: Dictionary`
- **Returns:** `VBoxContainer`
- **Calls:** add_theme_constant_override, _create_property_editor, new, add_child, connect

### `_create_node_expander()`
- **Lines:** 0
- **Parameters:** `path: String, data: Dictionary`
- **Returns:** `VBoxContainer`
- **Calls:** new, add_child

### `_create_property_editor()`
- **Lines:** 0
- **Parameters:** `obj_name: String, prop_name: String, prop_data: Dictionary`
- **Returns:** `Control`
- **Calls:** _on_value_changed, typeof, new, add_child, str, connect, Color, get, add_theme_color_override

### `_on_value_changed()`
- **Lines:** 0
- **Parameters:** `obj_name: String, prop_name: String, value: Variant`
- **Returns:** `void`
- **Calls:** set, str, emit, get_script, print

### `_on_search_changed()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`

### `_on_auto_refresh_toggled()`
- **Lines:** 0
- **Parameters:** `pressed: bool`
- **Returns:** `void`
- **Calls:** set_process

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _scan_everything

### `toggle_visibility()`
- **Lines:** 5
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _scan_everything


## scripts/ui/grid_list_console_bridge.gd
**Category:** Interface Systems
**Functions:** 18

### `register_grid_cell()`
- **Lines:** 0
- **Parameters:** `x: int, y: int, page: int, command: String`
- **Returns:** `void`
- **Calls:** Vector2i

### `register_list_item()`
- **Lines:** 0
- **Parameters:** `index: int, page: int, command: String`
- **Returns:** `void`

### `visual_to_command()`
- **Lines:** 0
- **Parameters:** `action: String, target: Dictionary`
- **Returns:** `String`
- **Calls:** str, emit_signal, get
- **Signals:** command_generated

### `execute_unified_command()`
- **Lines:** 0
- **Parameters:** `command: String, source: String = "console"`
- **Returns:** `Dictionary`
- **Calls:** _handle_delete, execute_command, _handle_page_change, get_node, _handle_mode_change, has_node, _handle_create, is_empty, _handle_move, _handle_select, slice, _log_command, split

### `get_command_suggestions()`
- **Lines:** 0
- **Parameters:** `partial: String`
- **Returns:** `Array`
- **Calls:** _get_page_numbers, _get_selectable_items, begins_with, append, size, split, _get_entity_types

### `get_item_from_page()`
- **Lines:** 0
- **Parameters:** `page: int, index: int`
- **Returns:** `Dictionary`

### `grid_to_list_index()`
- **Lines:** 0
- **Parameters:** `x: int, y: int, columns: int`
- **Returns:** `int`

### `list_to_grid_pos()`
- **Lines:** 0
- **Parameters:** `index: int, columns: int`
- **Returns:** `Vector2i`
- **Calls:** Vector2i

### `_handle_select()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** substr, is_empty, begins_with, size, split, int

### `_handle_create()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** size

### `_handle_page_change()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** is_empty, int

### `_get_entity_types()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`

### `_get_page_numbers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** append, str, range

### `_get_selectable_items()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Array`
- **Calls:** append, get_tree, get_nodes_in_group

### `_log_command()`
- **Lines:** 0
- **Parameters:** `command: String, source: String, result: Dictionary`
- **Returns:** `void`
- **Calls:** get_ticks_msec, get_node, has_node, store_with_metadata

### `_handle_move()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** size

### `_handle_delete()`
- **Lines:** 0
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** is_empty

### `_handle_mode_change()`
- **Lines:** 12
- **Parameters:** `args: Array`
- **Returns:** `Dictionary`
- **Calls:** is_empty


## scripts/ui/height_map_overlay.gd
**Category:** Interface Systems
**Functions:** 19

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _initialize_map, _create_height_gradient, _setup_legend

### `_initialize_map()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create, fill, Color, create_from_image

### `_create_height_gradient()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new

### `_setup_legend()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Water, High, Deep, Hills, Ground, Peak

### `_process()`
- **Lines:** 0
- **Parameters:** `delta: float`
- **Returns:** `void`
- **Calls:** _update_map

### `_update_map()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _draw_entities, _fade_map, _update_terrain_heights, update

### `_fade_map()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** range, size, get_data, int

### `_update_terrain_heights()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, set_pixel, _height_to_color, Vector2i, _pixel_to_world, range, get_noise_2d

### `_draw_entities()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _world_to_pixel, Vector2, _is_valid_pixel, _height_to_color, pop_front, _draw_circle_on_map, has, Color, append, float, range, size

### `_world_to_pixel()`
- **Lines:** 0
- **Parameters:** `world_pos: Vector2`
- **Returns:** `Vector2i`
- **Calls:** Vector2i, int

### `_pixel_to_world()`
- **Lines:** 0
- **Parameters:** `pixel_pos: Vector2i`
- **Returns:** `Vector2`
- **Calls:** Vector2

### `_is_valid_pixel()`
- **Lines:** 0
- **Parameters:** `pos: Vector2i`
- **Returns:** `bool`

### `_height_to_color()`
- **Lines:** 0
- **Parameters:** `height: float`
- **Returns:** `Color`
- **Calls:** clamp, sample

### `_draw_circle_on_map()`
- **Lines:** 0
- **Parameters:** `center: Vector2i, radius: int, color: Color`
- **Returns:** `void`
- **Calls:** set_pixelv, Vector2i, range, _is_valid_pixel

### `update_entity_position()`
- **Lines:** 0
- **Parameters:** `entity_id: String, position: Vector3`
- **Returns:** `void`

### `remove_entity()`
- **Lines:** 0
- **Parameters:** `entity_id: String`
- **Returns:** `void`
- **Calls:** erase

### `set_world_bounds()`
- **Lines:** 0
- **Parameters:** `bounds: Rect2`
- **Returns:** `void`

### `set_height_range()`
- **Lines:** 0
- **Parameters:** `min_h: float, max_h: float`
- **Returns:** `void`

### `_gui_input()`
- **Lines:** 11
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** get_node, call, has_node, Vector3, Vector2i, _pixel_to_world, print


## scripts/ui/interactive_tutorial_system.gd
**Category:** Interface Systems
**Functions:** 15

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_ui, _save_initial_state

### `_save_initial_state()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_viewport, get_tree, size, get_nodes_in_group, get_camera_3d

### `_create_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, connect, add_theme_font_size_override

### `_start_tutorial()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, _update_test_ui, print

### `_update_test_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, new, add_child, queue_free, connect, begins_with, _show_final_results, _add_test_buttons

### `_add_test_buttons()`
- **Lines:** 0
- **Parameters:** `tests: Array`
- **Returns:** `void`
- **Calls:** bind, new, add_child, connect, get

### `_run_test()`
- **Lines:** 0
- **Parameters:** `test_name: String, command: String`
- **Returns:** `void`
- **Calls:** _execute_command, _update_results, print

### `_record_result()`
- **Lines:** 0
- **Parameters:** `test_name: String, success: bool`
- **Returns:** `void`
- **Calls:** get_datetime_string_from_system, _update_results, emit_signal
- **Signals:** test_completed

### `_next_test()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_test_ui

### `_reset_scene()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _execute_command, _update_results, get_viewport, has, print, get, get_camera_3d

### `_update_results()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** append_text

### `_show_final_results()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _save_results_to_file, append_text, emit_signal, clear, float
- **Signals:** tutorial_finished

### `_save_results_to_file()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** open, close, _update_results, get_datetime_string_from_system, store_string, stringify

### `_close_tutorial()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `show_tutorial()`
- **Lines:** 5
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _save_initial_state


## scripts/ui/object_inspector.gd
**Category:** Interface Systems
**Functions:** 24

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** hide, print, _connect_signals, _setup_ui

### `_setup_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, _apply_inspector_style, new, set_anchors_and_offsets_preset, add_child

### `_apply_inspector_style()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_theme_color_override, new, Color, add_theme_stylebox_override

### `_connect_signals()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect

### `inspect_object()`
- **Lines:** 0
- **Parameters:** `object: Node`
- **Returns:** `void`
- **Calls:** _populate_properties, get_class, _clear_properties, show, print

### `_clear_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, clear, get_children

### `_populate_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** append, size, get_property_list, _create_category_section

### `_create_category_section()`
- **Lines:** 0
- **Parameters:** `category_name: String, properties: Array`
- **Returns:** `void`
- **Calls:** _create_property_editor, new, add_child, Color, add_theme_color_override

### `_create_property_editor()`
- **Lines:** 0
- **Parameters:** `property: Dictionary`
- **Returns:** `void`
- **Calls:** _create_editor_for_type, new, add_child, _connect_editor_signal, _should_show_property, get

### `_create_editor_for_type()`
- **Lines:** 0
- **Parameters:** `type: int, current_value: Variant`
- **Returns:** `Control`
- **Calls:** get_class, new, add_child, str, add_theme_color_override

### `_connect_editor_signal()`
- **Lines:** 0
- **Parameters:** `editor: Control, prop_name: String, prop_type: int`
- **Returns:** `void`
- **Calls:** connect, bind, get_child

### `_should_show_property()`
- **Lines:** 0
- **Parameters:** `property: Dictionary`
- **Returns:** `bool`
- **Calls:** begins_with, contains, to_lower

### `_on_bool_changed()`
- **Lines:** 0
- **Parameters:** `value: bool, prop_name: String`
- **Returns:** `void`
- **Calls:** _apply_property_change

### `_on_number_changed()`
- **Lines:** 0
- **Parameters:** `value: float, prop_name: String`
- **Returns:** `void`
- **Calls:** _apply_property_change, typeof, get, int

### `_on_string_changed()`
- **Lines:** 0
- **Parameters:** `text: String, prop_name: String`
- **Returns:** `void`
- **Calls:** _apply_property_change

### `_on_vector2_changed()`
- **Lines:** 0
- **Parameters:** `value: float, prop_name: String, component: String`
- **Returns:** `void`
- **Calls:** _apply_property_change, get

### `_on_vector3_changed()`
- **Lines:** 0
- **Parameters:** `value: float, prop_name: String, component: String`
- **Returns:** `void`
- **Calls:** _apply_property_change, get

### `_apply_property_change()`
- **Lines:** 0
- **Parameters:** `prop_name: String, new_value: Variant`
- **Returns:** `void`
- **Calls:** set, str, has_method, emit, print

### `_on_close_pressed()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit, hide

### `_on_search_changed()`
- **Lines:** 0
- **Parameters:** `text: String`
- **Returns:** `void`
- **Calls:** _populate_properties, _clear_properties

### `toggle_hidden_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _populate_properties, _clear_properties

### `set_target_object()`
- **Lines:** 0
- **Parameters:** `object: Node`
- **Returns:** `void`
- **Calls:** inspect_object

### `close_inspector()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** hide, _clear_properties

### `is_inspecting()`
- **Lines:** 2
- **Parameters:** ``
- **Returns:** `bool`


## scripts/ui/script_orchestra_interface.gd
**Category:** Interface Systems
**Functions:** 17

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_interface, _ready_console_commands, _setup_monitoring, print

### `_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** is_action_pressed, set_input_as_handled, get_viewport, toggle_visibility

### `_create_interface()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_theme_constant_override, Vector2, new, add_child, View, connect, Scripts, add_theme_font_size_override

### `_setup_monitoring()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, get_node, has_node, connect, start

### `_update_orchestra()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** sort_custom, get_item_count, set_item_custom_fg_color, get_file, _get_player_position, _scan_node_recursive, _update_miracle_ratio, _get_creation_icon, get_tree, add_item, append, clear, get_nodes_in_group

### `_scan_node_recursive()`
- **Lines:** 0
- **Parameters:** `node: Node, player_pos: Vector3`
- **Returns:** `void`
- **Calls:** is_instance_valid, new, distance_to, get_parent, get_children, _scan_node_recursive, has_method, get_script, _analyze_creation_state

### `_get_player_position()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Vector3`
- **Calls:** to_lower, get_viewport, get_camera_3d

### `_analyze_creation_state()`
- **Lines:** 0
- **Parameters:** `node: Node`
- **Returns:** `String`
- **Calls:** has_meta, has_method, to_lower

### `_get_creation_icon()`
- **Lines:** 0
- **Parameters:** `info: ScriptInfo`
- **Returns:** `String`

### `_update_miracle_ratio()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** randf, emit, values, float, size

### `_on_script_selected()`
- **Lines:** 0
- **Parameters:** `index: int`
- **Returns:** `void`
- **Calls:** sort_custom, get_file, _get_creation_icon, emit, values, size

### `_on_distance_changed()`
- **Lines:** 0
- **Parameters:** `value: float`
- **Returns:** `void`
- **Calls:** print

### `toggle_visibility()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_orchestra

### `get_orchestra_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** values, size

### `_ready_console_commands()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** register_command, get_node_or_null

### `_cmd_toggle_orchestra()`
- **Lines:** 0
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** get_node, _print_to_console, toggle_visibility

### `_cmd_create_miracle()`
- **Lines:** 16
- **Parameters:** `_args: Array`
- **Returns:** `void`
- **Calls:** _print_to_console, get_file, get_node, emit, values


## scripts/ui/simple_testing_guide.gd
**Category:** Interface Systems
**Functions:** 9

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_test_message, show_guide_temporarily, _create_guide_ui

### `_create_guide_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, set_anchors_and_offsets_preset, add_child, add_theme_color_override, connect, Color, add_theme_stylebox_override

### `_update_test_message()`
- **Lines:** 4
- **Parameters:** ``
- **Returns:** `void`

### `show_guide_temporarily()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_fade_out_guide()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_tree, connect, create_tween, tween_property

### `_hide_guide()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** _update_test_message, _hide_guide

### `update_test_message()`
- **Lines:** 0
- **Parameters:** `new_message: String`
- **Returns:** `void`
- **Calls:** _update_test_message

### `show_success_message()`
- **Lines:** 4
- **Parameters:** `feature: String`
- **Returns:** `void`


## scripts/ui/systematic_test_tutorial.gd
**Category:** Interface Systems
**Functions:** 15

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _start_tutorial, _position_ui, _create_tutorial_ui

### `_create_tutorial_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, add_theme_color_override, connect, Color, add_theme_font_size_override, add_theme_stylebox_override

### `_position_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_visible_rect, get_viewport

### `_start_tutorial()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** clear, _update_current_test

### `_update_current_test()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, _finish_tutorial

### `_run_current_test()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** create_timer, _count_scene_objects, _record_test_result, execute_command, get_node_or_null, has_method, executed, get_tree, size, get_nodes_in_group

### `_record_test_result()`
- **Lines:** 0
- **Parameters:** `test_name: String, result: String, success: bool`
- **Returns:** `void`
- **Calls:** append, get_datetime_string_from_system, emit_signal, print
- **Signals:** test_completed

### `_next_test()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, _finish_tutorial, _update_current_test

### `_previous_test()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _update_current_test

### `_finish_tutorial()`
- **Lines:** 7
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** filter, size

### `_generate_final_report()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** filter, size, FUNCTIONS, print, range, repeat

### `_restart_tutorial()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _start_tutorial, disconnect, connect

### `_close_tutorial()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free

### `_count_scene_objects()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `int`
- **Calls:** _count_children_recursive, get_tree

### `_count_children_recursive()`
- **Lines:** 5
- **Parameters:** `node: Node`
- **Returns:** `int`
- **Calls:** _count_children_recursive, get_children


## scripts/ui/unified_grid_list_system.gd
**Category:** Interface Systems
**Functions:** 31

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _setup_console_overlay, _load_page, _setup_grid_container, set_process_unhandled_input, print, _setup_list_container

### `_load_page()`
- **Lines:** 0
- **Parameters:** `page_num: int`
- **Returns:** `void`
- **Calls:** erase, _wait_for_pending_page, has, emit_signal, _generate_page_data, _refresh_display
- **Signals:** page_changed

### `_generate_page_data()`
- **Lines:** 0
- **Parameters:** `page_num: int`
- **Returns:** `void`
- **Calls:** _get_item_icon, get_ticks_msec, min, append, range, _get_item_type

### `_get_item_type()`
- **Lines:** 0
- **Parameters:** `index: int`
- **Returns:** `String`
- **Calls:** size

### `_get_item_icon()`
- **Lines:** 0
- **Parameters:** `index: int`
- **Returns:** `String`
- **Calls:** size

### `_cycle_display_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** values, emit_signal, size, _refresh_display
- **Signals:** mode_changed

### `_move_cursor()`
- **Lines:** 0
- **Parameters:** `direction: Vector2i`
- **Returns:** `void`
- **Calls:** wrapi, clamp, _update_cursor_visual

### `_update_cursor_visual()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _highlight_item, get_child_count, get_child

### `_execute_console_command()`
- **Lines:** 0
- **Parameters:** `command: String`
- **Returns:** `void`
- **Calls:** _select_item_by_id, _prev_page, _load_page, _goto_item, _set_display_mode, _next_page, emit_signal, slice, size, split, int
- **Signals:** command_executed

### `_goto_item()`
- **Lines:** 0
- **Parameters:** `global_index: int`
- **Returns:** `void`
- **Calls:** _load_page

### `set_player_state()`
- **Lines:** 0
- **Parameters:** `state_name: String, value: bool`
- **Returns:** `void`
- **Calls:** set_process_unhandled_input, has

### `_unhandled_input()`
- **Lines:** 0
- **Parameters:** `event: InputEvent`
- **Returns:** `void`
- **Calls:** call, is_action_pressed, has_focus, _cycle_focus

### `_cycle_focus()`
- **Lines:** 0
- **Parameters:** `direction: int`
- **Returns:** `void`
- **Calls:** wrapi, _update_cursor_visual

### `_setup_grid_container()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_theme_constant_override

### `_setup_list_container()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_refresh_display()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_children, queue_free, _populate_grid, has, _populate_list

### `_populate_grid()`
- **Lines:** 0
- **Parameters:** `items: Array`
- **Returns:** `void`
- **Calls:** _create_grid_cell, add_child

### `_populate_list()`
- **Lines:** 0
- **Parameters:** `items: Array`
- **Returns:** `void`
- **Calls:** add_child, _create_list_row

### `_create_grid_cell()`
- **Lines:** 0
- **Parameters:** `item: Dictionary`
- **Returns:** `Control`
- **Calls:** Vector2, new, bind, connect

### `_create_list_row()`
- **Lines:** 0
- **Parameters:** `item: Dictionary`
- **Returns:** `Control`
- **Calls:** new, add_child

### `_select_current()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit_signal, has, size
- **Signals:** item_selected

### `_execute_current()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _execute_console_command, has, size

### `_next_page()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _load_page

### `_prev_page()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _load_page

### `_toggle_console()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** grab_focus

### `_highlight_item()`
- **Lines:** 0
- **Parameters:** `item: Control`
- **Returns:** `void`
- **Calls:** new, Color, add_theme_stylebox_override

### `_on_item_clicked()`
- **Lines:** 0
- **Parameters:** `item: Dictionary`
- **Returns:** `void`
- **Calls:** emit_signal
- **Signals:** item_selected

### `_setup_console_overlay()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, new, connect

### `_wait_for_pending_page()`
- **Lines:** 0
- **Parameters:** `page_num: int`
- **Returns:** `void`
- **Calls:** erase, get_tree, has, get_process_delta_time

### `_select_item_by_id()`
- **Lines:** 0
- **Parameters:** `item_id: String`
- **Returns:** `void`
- **Calls:** emit_signal, range, has, size
- **Signals:** item_selected

### `_set_display_mode()`
- **Lines:** 13
- **Parameters:** `mode_name: String`
- **Returns:** `void`
- **Calls:** _cycle_display_mode, to_lower


## scripts/ui/universal_object_inspector.gd
**Category:** Interface Systems
**Functions:** 20

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** hide, print, _setup_ui

### `_setup_ui()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** Vector2, _create_properties_section, new, _apply_inspector_style, add_child, connect, _create_gizmo_section, _create_transform_section

### `_create_transform_section()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _create_axis_control, new, add_child, connect, Rotation, else, to_upper, Color, add_theme_font_size_override, add_theme_color_override

### `_create_axis_control()`
- **Lines:** 0
- **Parameters:** `label_text: String, axis: String, color: Color`
- **Returns:** `Dictionary`
- **Calls:** Vector2, new, add_child, connect, to_lower, set_value_no_signal, _on_transform_changed

### `_create_gizmo_section()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_child, connect, add_theme_font_size_override, _set_gizmo_mode

### `_create_properties_section()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_theme_font_size_override, new, Color, add_child

### `_apply_inspector_style()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** new, add_theme_stylebox_override, Color, add_theme_font_size_override, add_theme_color_override

### `inspect_object()`
- **Lines:** 0
- **Parameters:** `object: Node`
- **Returns:** `void`
- **Calls:** get_class, _update_transform_controls, show, _update_properties, print

### `_update_transform_controls()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** set_value_no_signal

### `_update_properties()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** queue_free, _add_property_control, get_children

### `_add_property_control()`
- **Lines:** 0
- **Parameters:** `label: String, property: String, value: Variant`
- **Returns:** `void`
- **Calls:** Vector2, new, add_child, connect, _on_property_changed

### `_on_transform_changed()`
- **Lines:** 0
- **Parameters:** `transform_type: String, axis: String, value: float`
- **Returns:** `void`
- **Calls:** begins_with, Vector3, set_value_no_signal, emit_signal
- **Signals:** property_changed

### `_on_property_changed()`
- **Lines:** 0
- **Parameters:** `property: String, value: Variant`
- **Returns:** `void`
- **Calls:** set, emit_signal
- **Signals:** property_changed

### `_on_gizmo_requested()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** get_child, new, load, add_child, get_first_node_in_group, set_script, get_child_count, has_method, attach_to_object, emit_signal, print, _update_gizmo_button_text, get_tree, add_to_group, detach
- **Signals:** gizmo_requested

### `_update_gizmo_button_text()`
- **Lines:** 0
- **Parameters:** `is_active: bool`
- **Returns:** `void`
- **Calls:** contains, get_children

### `_on_close_pressed()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** hide, emit_signal
- **Signals:** inspector_closed

### `handle_command()`
- **Lines:** 0
- **Parameters:** `command: String, args: Array`
- **Returns:** `String`
- **Calls:** show, get_node_or_null, is_empty, hide, inspect_object, toggle

### `toggle()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_on_attach_gizmo_pressed()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** _on_gizmo_requested

### `_set_gizmo_mode()`
- **Lines:** 8
- **Parameters:** `mode: String`
- **Returns:** `void`
- **Calls:** set_mode, get_first_node_in_group, has_method, print, mode, get_tree


## scripts/ui/visual_indicator_system.gd
**Category:** Interface Systems
**Functions:** 17

### `_ready()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** str, _find_time_tracker, _setup_timers, print, _apply_mode_settings

### `_setup_timers()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** add_child, new, connect

### `_find_time_tracker()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** connect, has_signal, print, _find_node_by_class, get_tree, size, get_nodes_in_group

### `_find_node_by_class()`
- **Lines:** 0
- **Parameters:** `node: Node, class_name: String`
- **Returns:** `Node`
- **Calls:** get_class, get_children, _find_node_by_class

### `_apply_mode_settings()`
- **Lines:** 0
- **Parameters:** `mode_index`
- **Returns:** `void`
- **Calls:** emit_signal, _set_symbol
- **Signals:** mode_changed

### `_set_symbol()`
- **Lines:** 0
- **Parameters:** `symbol_index`
- **Returns:** `void`
- **Calls:** emit_signal
- **Signals:** symbol_changed

### `_on_blink_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** emit_signal
- **Signals:** blink_occurred

### `_on_color_cycle_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** size, emit_signal
- **Signals:** color_updated, layer_changed

### `_on_animation_timer_timeout()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `void`

### `_on_time_updated()`
- **Lines:** 0
- **Parameters:** `session_time, total_time`
- **Returns:** `void`
- **Calls:** _set_symbol, floor, size, min

### `_on_hour_limit_reached()`
- **Lines:** 0
- **Parameters:** `hours`
- **Returns:** `void`
- **Calls:** create_timer, get_tree, _set_symbol

### `set_mode()`
- **Lines:** 0
- **Parameters:** `mode_index: int`
- **Returns:** `bool`
- **Calls:** size, _apply_mode_settings

### `cycle_mode()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `int`
- **Calls:** size, _apply_mode_settings

### `toggle_enabled()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `bool`

### `get_current_symbol()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`

### `get_current_mode_name()`
- **Lines:** 0
- **Parameters:** ``
- **Returns:** `String`

### `get_visual_state()`
- **Lines:** 17
- **Parameters:** ``
- **Returns:** `Dictionary`
- **Calls:** size, get_current_mode_name


## test_ragdoll_standing.gd
**Category:** Utility Scripts
**Functions:** 1

### `_ready()`
- **Lines:** 14
- **Parameters:** ``
- **Returns:** `void`
- **Calls:** print, detection, forces, damping, stance


