# GODOT CLASS USAGE ANALYSIS REPORT
# talking_ragdoll_game project
================================================================================

## SUMMARY STATISTICS
Total scripts analyzed: 40
Unique Godot classes extended: 5

## CLASS INHERITANCE OVERVIEW

- **Node**: 23 scripts
- **Node3D**: 11 scripts
- **CharacterBody3D**: 2 scripts
- **RigidBody3D**: 2 scripts
- **Resource**: 1 scripts

## DETAILED SCRIPT ANALYSIS

### scripts/autoload/

#### claude_timer_system.gd
**Extends:** `Node`

**Key Method Calls:**
- `Time.get_ticks_msec`: lines 40, 48, 66, 74, 83
  ... and 4 more
- `user_wait_threshold_reached.connect`: lines 45

**Signals:**
- Defines signal `user_wait_threshold_reached` at line 35
- Defines signal `autonomous_work_started` at line 36
- Defines signal `session_metrics_updated` at line 37
- Connects to `_on_user_wait_threshold` at lines: 45

#### console_manager.gd
**Extends:** `Node`

**Instantiated Classes:**
- `PassiveController` at lines: 229
- `ThreadedTestSystem` at lines: 237
- `PhysicsStateManager` at lines: 245
- `MultiProjectManager` at lines: 254
- `ClaudeTimer` at lines: 263
- `MultiTodoManager` at lines: 277
- `WindowsConsoleFix` at lines: 286
- `Control` at lines: 314
- `ColorRect` at lines: 320
- `CenterContainer` at lines: 327
- `PanelContainer` at lines: 333
- `StyleBoxFlat` at lines: 339, 417
- `VBoxContainer` at lines: 360
- `HBoxContainer` at lines: 364, 403
- `Label` at lines: 367, 406
- `Button` at lines: 375, 429
- `HSeparator` at lines: 382
- `ScrollContainer` at lines: 386
- `RichTextLabel` at lines: 393
- `LineEdit` at lines: 412
- `CanvasLayer` at lines: 435
- `Node` at lines: 884, 987, 2179, 2341
- `Node3D` at lines: 1223, 2228

**Key Method Calls:**
- `ResourceLoader.exists`: lines 227, 235, 243, 252, 261
  ... and 2 more
- `action_system.process_combo_input`: lines 1933, 1935, 1937, 1939, 1942
- `args.is_empty`: lines 673, 682, 692, 803, 817
  ... and 22 more
- `args.size`: lines 762, 769, 995, 1037, 1041
  ... and 43 more
- `args.slice`: lines 1097, 1477, 1514, 1537
- `astral_beings.has_method`: lines 1756, 1764, 1772, 1780
- `canvas_layer.call_deferred`: lines 439
- `center_container.add_child`: lines 336
- `command_history.size`: lines 526, 528, 571, 573
- `console_container.add_child`: lines 324, 330
- `console_panel.add_child`: lines 361
- `container.queue_free`: lines 2245
- `content_vbox.add_child`: lines 365, 383, 390, 404
- `current_scene.add_child`: lines 1226, 2230
- `debug_screen.call`: lines 1270, 1290, 1310, 1335
- `debug_screen.queue_free`: lines 1230
- `event.is_action_pressed`: lines 297, 302, 305, 308
- `finished.connect`: lines 494, 509
- `get_node`: 4 calls
- `input_container.add_child`: lines 409, 426, 432
- `main_scene.has_method`: lines 1624, 1631, 1657, 1790
- `output_scroll.add_child`: lines 400
- `passive_controller.get_status`: lines 1026, 1035, 1079, 1112
- `physics_tester.queue_free`: lines 2349, 2357
- `pressed.connect`: lines 378, 431
- `ragdoll_controller.has_method`: lines 1714, 1722, 1730, 1738, 1746
- `root.add_child`: lines 247, 887, 990, 2182
- `root.call_deferred`: lines 438
- `settings_changed.connect`: lines 189
- `text_submitted.connect`: lines 415
- `title_bar.add_child`: lines 371, 379
- `tween.parallel`: lines 489, 491, 504, 506

**Signals:**
- Defines signal `command_executed` at line 9
- Connects to `_on_settings_changed` at lines: 189
- Connects to `toggle_console` at lines: 378
- Connects to `_on_command_submitted` at lines: 415
- Connects to `func(` at lines: 431, 494, 509

#### dialogue_system.gd
**Extends:** `Node`

**Instantiated Classes:**
- `Label3D` at lines: 48

**Key Method Calls:**
- `root.add_child`: lines 58

#### multi_todo_manager.gd
**Extends:** `Node`

**Key Method Calls:**
- `Time.get_ticks_msec`: lines 42, 71, 90, 114, 169
  ... and 1 more

#### scene_loader.gd
**Extends:** `Node`

**Key Method Calls:**
- `FileAccess.open`: lines 150, 171, 191, 336, 405
- `file.close`: lines 152, 173, 205, 355, 407
- `file.store_line`: lines 339, 340, 341, 348, 353
- `ragdoll.queue_free`: lines 188

**Signals:**
- Defines signal `scene_loaded` at line 9
- Defines signal `scene_saved` at line 10

#### ui_settings_manager.gd
**Extends:** `Node`

**Instantiated Classes:**
- `ConfigFile` at lines: 36, 62

**Key Method Calls:**
- `config.get_value`: lines 45, 46, 47, 48, 49
  ... and 6 more
- `config.set_value`: lines 65, 66, 67, 68, 69
  ... and 6 more
- `size_changed.connect`: lines 33

**Signals:**
- Defines signal `settings_changed` at line 9
- Connects to `_on_viewport_size_changed` at lines: 33

#### windows_console_fix.gd
**Extends:** `Node`

**Key Method Calls:**

#### world_builder.gd
**Extends:** `Node`

**Instantiated Classes:**
- `PhysicsRayQueryParameters3D` at lines: 87
- `Node3D` at lines: 223
- `RigidBody3D` at lines: 282
- `Node` at lines: 295

**Key Method Calls:**
- `StandardizedObjects.create_object`: lines 106, 120, 132, 148, 164
  ... and 10 more
- `bird.add_child`: lines 298
- `floodgate.second_dimensional_magic`: lines 113, 138, 154, 170, 186
  ... and 2 more
- `get_node`: 2 calls
- `obj.queue_free`: lines 325, 356
- `ragdoll.queue_free`: lines 196
- `root.add_child`: lines 123, 201, 210, 242, 252
  ... and 7 more
- `spawned_objects.append`: lines 114, 124, 139, 155, 171
  ... and 14 more

**Groups:** astral_beings, spawned_objects, birds

### scripts/core/

#### asset_library.gd
**Extends:** `Node`

**Instantiated Classes:**
- `JSON` at lines: 454

**Key Method Calls:**
- `asset_approval_needed.connect`: lines 148
- `asset_catalog.has`: lines 154, 169, 180, 185, 299
  ... and 1 more
- `asset_info.has`: lines 158, 158, 194, 221, 329
- `loaded_assets.has`: lines 252, 281, 324, 429, 433
- `results.append`: lines 195, 212, 224, 234

**Signals:**
- Defines signal `asset_catalog_updated` at line 130
- Defines signal `asset_loaded` at line 131
- Defines signal `asset_unloaded` at line 132
- Defines signal `asset_approval_requested` at line 133
- Defines signal `asset_approved` at line 134
- Defines signal `asset_rejected` at line 135
- Connects to `_on_asset_approval_needed` at lines: 148

#### astral_being_enhanced_OLD_DEPRECATED.gd
**Extends:** `Node3D`

**Instantiated Classes:**
- `OmniLight3D` at lines: 62, 264
- `GPUParticles3D` at lines: 70
- `ParticleProcessMaterial` at lines: 76
- `SphereMesh` at lines: 88
- `StandardMaterial3D` at lines: 94
- `Area3D` at lines: 105
- `CollisionShape3D` at lines: 106
- `SphereShape3D` at lines: 107
- `Node3D` at lines: 262

**Key Method Calls:**
- `area_detector.add_child`: lines 110
- `area_entered.connect`: lines 116
- `area_exited.connect`: lines 117
- `body_entered.connect`: lines 114
- `body_exited.connect`: lines 115
- `particle.queue_free`: lines 308
- `trail.add_child`: lines 268

**Signals:**
- Connects to `_on_body_entered` at lines: 114
- Connects to `_on_body_exited` at lines: 115
- Connects to `_on_area_entered` at lines: 116
- Connects to `_on_area_exited` at lines: 117

#### astral_beings_OLD_DEPRECATED.gd
**Extends:** `Node3D`

**Instantiated Classes:**
- `GPUParticles3D` at lines: 76, 230
- `ParticleProcessMaterial` at lines: 81, 234
- `SphereMesh` at lines: 95

**Key Method Calls:**
- `astral_beings.size`: lines 59, 77, 291, 309, 310
- `get_node`: 1 calls
- `ragdoll_controller.connect`: lines 55, 56, 57
- `temp_particles.queue_free`: lines 248

**Signals:**
- Connects to `"player_needs_help", _on_player_needs_help` at lines: 55
- Connects to `"object_picked_up", _on_object_interaction` at lines: 56
- Connects to `"object_dropped", _on_object_interaction` at lines: 57

#### astral_ragdoll_helper.gd
**Extends:** `Node`

**Key Method Calls:**
- `being.has_method`: lines 59, 72, 118, 166

#### bird_ai_behavior.gd
**Extends:** `Node`

**Key Method Calls:**
- `bird_body.has_method`: lines 106, 123, 163, 220
- `global_position.distance_to`: lines 129, 169, 236, 252
- `target_object.queue_free`: lines 148

#### complete_ragdoll.gd

**Instantiated Classes:**
- `RigidBody3D` at lines: 37, 66, 89
- `MeshInstance3D` at lines: 46, 74, 97
- `BoxMesh` at lines: 47, 75, 98
- `CollisionShape3D` at lines: 52, 81, 104
- `BoxShape3D` at lines: 53, 82, 105
- `Generic6DOFJoint3D` at lines: 115
- `HingeJoint3D` at lines: 131
- `StandardMaterial3D` at lines: 149, 154

**Key Method Calls:**
- `body.add_child`: lines 50, 56
- `knee_joint.set_param`: lines 139, 140, 141, 142
- `lower_leg.add_child`: lines 102, 109
- `side.capitalize`: lines 67, 90, 116, 132
- `upper_leg.add_child`: lines 79, 86

**Groups:** ragdoll

#### debug_3d_screen.gd
**Extends:** `Node3D`

**Instantiated Classes:**
- `MeshInstance3D` at lines: 53, 94, 119
- `PlaneMesh` at lines: 54
- `StandardMaterial3D` at lines: 63, 109
- `ImageTexture` at lines: 71
- `Node3D` at lines: 83
- `CylinderMesh` at lines: 95
- `SphereMesh` at lines: 120

**Key Method Calls:**
- `debug_gizmo.add_child`: lines 116, 127
- `debug_info.get`: lines 214, 222, 232, 381, 385

#### dimensional_ragdoll_system.gd
**Extends:** `Node`
**Class Name:** `DimensionalRagdollSystem`

**Key Method Calls:**

**Signals:**
- Defines signal `dimension_changed` at line 11
- Defines signal `consciousness_evolved` at line 12
- Defines signal `emotion_changed` at line 13
- Defines signal `spell_learned` at line 14

#### eden_action_system.gd
**Extends:** `Node`
**Class Name:** `EdenActionSystem`

**Key Method Calls:**

**Signals:**
- Defines signal `action_started` at line 6
- Defines signal `action_completed` at line 7
- Defines signal `action_failed` at line 8
- Defines signal `combo_triggered` at line 9

#### floodgate_controller.gd
**Extends:** `Node`
**Class Name:** `var`

**Instantiated Classes:**
- `Mutex` at lines: 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 98
- `SceneTreeTracker` at lines: 138
- `Thread` at lines: 149
- `StandardMaterial3D` at lines: 1179

**Key Method Calls:**
- `Time.get_unix_time_from_system`: lines 203, 252, 546, 738, 839
  ... and 1 more
- `creation_array.append`: lines 1204, 1205, 1206, 1208
- `data_to_process.size`: lines 878, 971, 1069, 1099
- `function_array.append`: lines 1245, 1246, 1247, 1248
- `movmentes_mutex.unlock`: lines 997, 999, 1026, 1231
- `mutex.lock`: lines 196, 233, 254, 759, 764
  ... and 1 more
- `mutex.unlock`: lines 210, 229, 236, 242, 263
  ... and 3 more
- `mutex_actions.unlock`: lines 866, 868, 897, 1199
- `mutex_additionals_call.unlock`: lines 1088, 1090, 1113, 1261
- `mutex_data_to_send.unlock`: lines 960, 962, 991, 1221
- `mutex_for_unloading_nodes.unlock`: lines 1032, 1034, 1051, 1240
- `mutex_function_call.unlock`: lines 1057, 1059, 1082, 1251
- `mutex_messages_call.unlock`: lines 1125, 1127, 1155, 1271
- `mutex_nodes_to_be_added.unlock`: lines 903, 905, 954, 1211
- `new_parent.add_child`: lines 496
- `node.emit_signal`: lines 663, 665
- `node.get_path`: lines 345, 736, 741, 749, 758
  ... and 2 more
- `node.has_method`: lines 377, 377, 620, 1079
- `node.is_in_group`: lines 1345, 1345, 1353, 1370
- `node.queue_free`: lines 362
- `node_to_remove.queue_free`: lines 1404
- `oldest_being.queue_free`: lines 1420
- `operation_queue.size`: lines 209, 217, 235, 1314
- `params.has`: lines 309, 309, 326, 332, 349
  ... and 33 more
- `parent.add_child`: lines 340
- `parent_node.add_child`: lines 942
- `receiver_node.emit_signal`: lines 1146
- `root.add_child`: lines 926
- `source.connect`: lines 698
- `target_node.queue_free`: lines 1047
- `tracked_objects.size`: lines 1361, 1381, 1391, 1425, 1460
  ... and 1 more

**Signals:**
- Defines signal `operation_queued` at line 124
- Defines signal `operation_started` at line 125
- Defines signal `operation_completed` at line 126
- Defines signal `operation_failed` at line 127
- Defines signal `asset_loaded` at line 128
- Defines signal `asset_approval_needed` at line 129
- Defines signal `node_registered` at line 130
- Defines signal `node_unregistered` at line 131
- Defines signal `missing` at line 648
- Defines signal `emission` at line 653
- Connects to `signal_name, Callable(target, method` at lines: 698

#### game_launcher.gd
**Extends:** `Node`
**Class Name:** `GameLauncher`

**Instantiated Classes:**
- `Node3D` at lines: 239, 246

**Key Method Calls:**
- `error_log.append`: lines 57, 83, 92, 110, 122
  ... and 3 more
- `root.add_child`: lines 241
- `test_node.queue_free`: lines 254
- `test_object.queue_free`: lines 147

**Signals:**
- Defines signal `systems_ready` at line 11
- Defines signal `startup_error` at line 12

#### heightmap_world_generator.gd
**Extends:** `Node3D`

**Instantiated Classes:**
- `FastNoiseLite` at lines: 63
- `Node3D` at lines: 72, 77, 82, 315, 365
- `MeshInstance3D` at lines: 137, 320, 334, 370, 402, 472
- `ArrayMesh` at lines: 142
- `StandardMaterial3D` at lines: 210, 328, 341, 377, 407, 478
- `StaticBody3D` at lines: 219
- `CylinderMesh` at lines: 321
- `SphereMesh` at lines: 335, 371, 403
- `RigidBody3D` at lines: 398
- `CollisionShape3D` at lines: 416, 487
- `SphereShape3D` at lines: 417
- `Area3D` at lines: 467
- `PlaneMesh` at lines: 473
- `BoxShape3D` at lines: 488

**Key Method Calls:**
- `bush_root.add_child`: lines 380, 392
- `container.add_child`: lines 275, 305
- `fruit.add_child`: lines 413, 420
- `get_node`: 4 calls
- `indices.append`: lines 189, 190, 191, 194, 195
  ... and 1 more
- `terrain_mesh_instance.add_child`: lines 221
- `tree_root.add_child`: lines 331, 344, 359
- `water.add_child`: lines 484, 492
- `water_container.add_child`: lines 464

**Signals:**
- Defines signal `terrain_generated` at line 10
- Defines signal `vegetation_placed` at line 11

**Groups:** trees, bushes, fruit, food, water

#### mouse_interaction_system.gd
**Extends:** `Node`

**Instantiated Classes:**
- `PanelContainer` at lines: 105
- `StyleBoxFlat` at lines: 110
- `RichTextLabel` at lines: 119
- `CanvasLayer` at lines: 132
- `StandardMaterial3D` at lines: 423

**Key Method Calls:**
- `canvas_layer.add_child`: lines 138
- `canvas_layer.queue_free`: lines 91
- `collider.get_parent`: lines 405, 406, 460, 461
- `debug_panel.add_child`: lines 126
- `main_viewport.add_child`: lines 137
- `meshes_to_highlight.append`: lines 397, 402, 408, 411
- `meshes_to_reset.append`: lines 452, 457, 463, 466
- `target.get_parent`: lines 223, 223, 224, 225

#### multi_layer_record_system.gd
**Extends:** `Node`

**Instantiated Classes:**
- `Mutex` at lines: 19

**Key Method Calls:**
- `data.is_empty`: lines 90, 92, 225, 227
- `layer_mutex.lock`: lines 47, 82, 194, 215, 248
  ... and 1 more
- `layer_mutex.unlock`: lines 51, 56, 64, 98, 202
  ... and 4 more

**Signals:**
- Defines signal `state_changed` at line 37
- Defines signal `layer_transition` at line 38

#### physics_state_manager.gd
**Extends:** `Node`

**Key Method Calls:**

**Signals:**
- Defines signal `state_changed` at line 37
- Defines signal `gravity_modified` at line 38

#### pigeon_input_manager.gd
**Extends:** `Node`

**Instantiated Classes:**
- `InputEventKey` at lines: 32

**Key Method Calls:**

#### pigeon_physics_controller.gd
**Extends:** `CharacterBody3D`

**Instantiated Classes:**
- `Node3D` at lines: 88, 94, 98, 103, 107, 112
- `MeshInstance3D` at lines: 118
- `StandardMaterial3D` at lines: 126
- `CollisionShape3D` at lines: 133
- `CapsuleShape3D` at lines: 134
- `ArrayMesh` at lines: 288

**Key Method Calls:**
- `vertices.append`: lines 302, 303, 304, 307, 308
  ... and 1 more

**Signals:**
- Defines signal `mode_changed` at line 10
- Defines signal `balance_shifted` at line 11

#### ragdoll_controller.gd
**Extends:** `Node3D`

**Instantiated Classes:**
- `CharacterBody3D` at lines: 72

**Key Method Calls:**
- `current_scene.add_child`: lines 78
- `get_node`: 2 calls
- `global_position.distance_to`: lines 239, 239, 292, 362
- `ragdoll_body.has_method`: lines 91, 191, 196, 302, 316
  ... and 4 more

**Signals:**
- Defines signal `object_picked_up` at line 42
- Defines signal `object_dropped` at line 43
- Defines signal `movement_started` at line 44
- Defines signal `movement_completed` at line 45
- Defines signal `player_needs_help` at line 46

**Groups:** carried

#### ragdoll_with_legs.gd
**Extends:** `Node3D`

**Instantiated Classes:**
- `RigidBody3D` at lines: 46, 64, 85, 102, 121
- `MeshInstance3D` at lines: 51, 70, 91, 108, 127
- `BoxMesh` at lines: 52, 71, 109
- `CollisionShape3D` at lines: 57, 77, 96, 114, 131
- `BoxShape3D` at lines: 58, 78, 115
- `Generic6DOFJoint3D` at lines: 137, 151
- `HingeJoint3D` at lines: 164, 174
- `StandardMaterial3D` at lines: 185, 190

**Key Method Calls:**
- `body.add_child`: lines 55, 61
- `left_foot.add_child`: lines 112, 118
- `left_leg.add_child`: lines 75, 82
- `right_foot.add_child`: lines 129, 133
- `right_leg.add_child`: lines 94, 99

**Groups:** ragdoll

#### scene_setup.gd
**Extends:** `Node`

**Instantiated Classes:**
- `Node3D` at lines: 30

**Key Method Calls:**
- `get_node`: 1 calls
- `main_scene.add_child`: lines 37

**Groups:** objects, enhanced_ragdoll

#### scene_tree_tracker.gd
**Extends:** `Node`
**Class Name:** `SceneTreeTracker`

**Instantiated Classes:**
- `Mutex` at lines: 13

**Key Method Calls:**
- `current.has`: lines 136, 145, 229, 240
- `path_parts.size`: lines 88, 95, 106, 134, 137
  ... and 1 more
- `tree_mutex.lock`: lines 61, 73, 122, 130, 195
  ... and 1 more
- `tree_mutex.unlock`: lines 69, 118, 125, 140, 148
  ... and 4 more

#### seven_part_ragdoll_integration.gd
**Extends:** `CharacterBody3D`

**Instantiated Classes:**
- `Node3D` at lines: 112
- `RigidBody3D` at lines: 123
- `CollisionShape3D` at lines: 127
- `CapsuleShape3D` at lines: 128
- `BoxShape3D` at lines: 134, 146
- `MeshInstance3D` at lines: 157
- `BoxMesh` at lines: 160
- `CapsuleMesh` at lines: 164
- `StandardMaterial3D` at lines: 170
- `Generic6DOFJoint3D` at lines: 189, 195
- `HingeJoint3D` at lines: 202, 208, 215, 221
- `Timer` at lines: 266

**Key Method Calls:**
- `joint.set_node_a`: lines 190, 196, 203, 209, 216
  ... and 1 more
- `joint.set_node_b`: lines 191, 197, 204, 210, 217
  ... and 1 more
- `part.add_child`: lines 154, 181
- `parts.has`: lines 188, 188, 194, 194, 201
  ... and 7 more
- `ragdoll_state_changed.emit`: lines 327, 339, 360, 375
- `timeout.connect`: lines 268

**Signals:**
- Defines signal `ragdoll_state_changed` at line 32
- Defines signal `ragdoll_position_updated` at line 33
- Defines signal `ragdoll_dialogue_started` at line 34
- Connects to `_speak_random_phrase` at lines: 268

**Groups:** ragdoll

#### shape_gesture_system.gd
**Extends:** `Node`
**Class Name:** `ShapeGestureSystem`

**Key Method Calls:**
- `corners.size`: lines 179, 189, 208, 208
- `points.size`: lines 127, 149, 156, 162, 169
  ... and 12 more

**Signals:**
- Defines signal `shape_detected` at line 11
- Defines signal `gesture_completed` at line 12
- Defines signal `spell_gesture_recognized` at line 13

#### simple_ragdoll_walker.gd
**Extends:** `Node3D`

**Key Method Calls:**
- `body_parts.size`: lines 40, 68, 184, 196

#### simple_walking_ragdoll.gd
**Extends:** `Node3D`

**Instantiated Classes:**
- `RigidBody3D` at lines: 42, 78
- `MeshInstance3D` at lines: 52, 89
- `BoxMesh` at lines: 53, 90
- `StandardMaterial3D` at lines: 56, 95
- `CollisionShape3D` at lines: 62, 101
- `BoxShape3D` at lines: 63, 102
- `PinJoint3D` at lines: 109

**Key Method Calls:**
- `body.add_child`: lines 59, 66
- `leg.add_child`: lines 98, 106

#### stable_ragdoll.gd
**Extends:** `Node3D`

**Instantiated Classes:**
- `RigidBody3D` at lines: 71, 98, 151
- `MeshInstance3D` at lines: 80, 107, 160
- `BoxMesh` at lines: 81, 161
- `StandardMaterial3D` at lines: 85, 112, 166
- `CollisionShape3D` at lines: 91, 118, 172
- `BoxShape3D` at lines: 92, 173
- `SphereMesh` at lines: 108
- `SphereShape3D` at lines: 119
- `Generic6DOFJoint3D` at lines: 129
- `HingeJoint3D` at lines: 180

**Key Method Calls:**
- `DialogueSystem.show_dialogue`: lines 247, 252, 256, 261, 266
  ... and 2 more
- `body.add_child`: lines 88, 95
- `body_entered.connect`: lines 147, 148, 201
- `head.add_child`: lines 115, 122
- `hip_joint.set`: lines 187, 188, 189, 190, 191
  ... and 1 more
- `leg.add_child`: lines 169, 177
- `neck_joint.set`: lines 136, 137, 138, 139, 140
  ... and 4 more

**Signals:**
- Defines signal `dialogue_spoken` at line 34
- Connects to `_on_body_collision` at lines: 147
- Connects to `_on_head_collision` at lines: 148
- Connects to `_on_leg_collision.bind(is_left` at lines: 201

**Groups:** ragdoll_body

#### standardized_objects.gd
**Extends:** `Resource`
**Class Name:** `StandardizedObjects`

**Instantiated Classes:**
- `StaticBody3D` at lines: 166
- `RigidBody3D` at lines: 168
- `PhysicsMaterial` at lines: 171
- `Node3D` at lines: 175, 177, 179, 181
- `MeshInstance3D` at lines: 222, 236, 250
- `BoxMesh` at lines: 226
- `SphereMesh` at lines: 230, 251
- `CylinderMesh` at lines: 237
- `StandardMaterial3D` at lines: 244, 256, 265
- `CollisionShape3D` at lines: 276
- `BoxShape3D` at lines: 280
- `SphereShape3D` at lines: 284
- `CylinderShape3D` at lines: 288
- `DirectionalLight3D` at lines: 316

**Key Method Calls:**
- `def.get`: lines 169, 191, 216, 216, 227
  ... and 3 more
- `obj.add_child`: lines 247, 259, 273, 294, 320
- `obj.set_meta`: lines 190, 191, 330, 331

**Groups:** spawned_objects

#### talking_astral_being.gd
**Extends:** `Node3D`
**Class Name:** `TalkingAstralBeing`

**Instantiated Classes:**
- `OmniLight3D` at lines: 190, 547
- `GPUParticles3D` at lines: 198
- `ParticleProcessMaterial` at lines: 206
- `MeshInstance3D` at lines: 217
- `SphereMesh` at lines: 219
- `StandardMaterial3D` at lines: 225
- `Area3D` at lines: 235
- `CollisionShape3D` at lines: 239
- `SphereShape3D` at lines: 240
- `Node3D` at lines: 544

**Key Method Calls:**
- `area_detector.add_child`: lines 243
- `body_entered.connect`: lines 246
- `body_exited.connect`: lines 247
- `data.get`: lines 253, 262, 263, 264, 265
  ... and 1 more
- `global_position.lerp`: lines 313, 336, 374, 383
- `ragdoll_controller.connect`: lines 184
- `trail.add_child`: lines 551

**Signals:**
- Defines signal `being_spoke` at line 11
- Defines signal `being_action_taken` at line 12
- Defines signal `connection_made` at line 13
- Defines signal `assistance_completed` at line 14
- Connects to `"player_needs_help", _on_player_needs_help` at lines: 184
- Connects to `_on_body_entered` at lines: 246
- Connects to `_on_body_exited` at lines: 247

#### talking_ragdoll.gd
**Extends:** `RigidBody3D`

**Instantiated Classes:**
- `PhysicsRayQueryParameters3D` at lines: 176
- `Node` at lines: 283
- `Node3D` at lines: 322

**Key Method Calls:**
- `blink_started.connect`: lines 300
- `body_entered.connect`: lines 92
- `timeout.connect`: lines 218, 269

**Signals:**
- Connects to `_on_body_entered` at lines: 92
- Connects to `func(` at lines: 218, 269
- Connects to `_on_blink_started` at lines: 300

#### triangular_bird_walker.gd
**Extends:** `RigidBody3D`

**Instantiated Classes:**
- `RigidBody3D` at lines: 100
- `CollisionShape3D` at lines: 106, 172
- `SphereShape3D` at lines: 107, 170
- `MeshInstance3D` at lines: 113, 146, 151
- `SphereMesh` at lines: 114
- `PinJoint3D` at lines: 138
- `StandardMaterial3D` at lines: 156, 161
- `Area3D` at lines: 168
- `ArrayMesh` at lines: 329

**Key Method Calls:**
- `body.add_child`: lines 110, 118
- `body_entered.connect`: lines 178
- `body_exited.connect`: lines 179
- `food_detector.add_child`: lines 174
- `head_body.apply_central_force`: lines 257, 278, 283, 295
- `left_leg_body.apply_central_force`: lines 243, 244, 246, 254, 272
- `right_leg_body.apply_central_force`: lines 247, 250, 251, 253, 273

**Signals:**
- Defines signal `found_food` at line 10
- Defines signal `drinking_water` at line 11
- Connects to `_on_food_detected` at lines: 178
- Connects to `_on_food_lost` at lines: 179

#### unified_scene_manager.gd
**Extends:** `Node`

**Instantiated Classes:**
- `Node3D` at lines: 41, 52, 56, 60, 138

**Key Method Calls:**
- `child.queue_free`: lines 95, 97
- `creatures_container.add_child`: lines 193
- `get_node`: 1 calls
- `objects_container.add_child`: lines 197
- `procedural_world.queue_free`: lines 85
- `root.add_child`: lines 43, 141
- `scene_root.add_child`: lines 54, 58, 62
- `static_scene.queue_free`: lines 90
- `terrain_container.add_child`: lines 118, 147, 195

**Signals:**
- Defines signal `scene_changed` at line 10
- Defines signal `world_cleared` at line 11

#### upright_ragdoll_controller.gd
**Extends:** `Node3D`

**Key Method Calls:**

## CLASS TO SCRIPTS MAPPING

### CharacterBody3D
- scripts/core/pigeon_physics_controller.gd
- scripts/core/seven_part_ragdoll_integration.gd

### Node
- scripts/autoload/claude_timer_system.gd
- scripts/autoload/console_manager.gd
- scripts/autoload/dialogue_system.gd
- scripts/autoload/multi_todo_manager.gd
- scripts/autoload/scene_loader.gd
- scripts/autoload/ui_settings_manager.gd
- scripts/autoload/windows_console_fix.gd
- scripts/autoload/world_builder.gd
- scripts/core/asset_library.gd
- scripts/core/astral_ragdoll_helper.gd
- scripts/core/bird_ai_behavior.gd
- scripts/core/dimensional_ragdoll_system.gd
- scripts/core/eden_action_system.gd
- scripts/core/floodgate_controller.gd
- scripts/core/game_launcher.gd
- scripts/core/mouse_interaction_system.gd
- scripts/core/multi_layer_record_system.gd
- scripts/core/physics_state_manager.gd
- scripts/core/pigeon_input_manager.gd
- scripts/core/scene_setup.gd
- scripts/core/scene_tree_tracker.gd
- scripts/core/shape_gesture_system.gd
- scripts/core/unified_scene_manager.gd

### Node3D
- scripts/core/astral_being_enhanced_OLD_DEPRECATED.gd
- scripts/core/astral_beings_OLD_DEPRECATED.gd
- scripts/core/debug_3d_screen.gd
- scripts/core/heightmap_world_generator.gd
- scripts/core/ragdoll_controller.gd
- scripts/core/ragdoll_with_legs.gd
- scripts/core/simple_ragdoll_walker.gd
- scripts/core/simple_walking_ragdoll.gd
- scripts/core/stable_ragdoll.gd
- scripts/core/talking_astral_being.gd
- scripts/core/upright_ragdoll_controller.gd

### Resource
- scripts/core/standardized_objects.gd

### RigidBody3D
- scripts/core/talking_ragdoll.gd
- scripts/core/triangular_bird_walker.gd

## COMMON PATTERNS AND USAGE

### Most Instantiated Classes
- `Node3D`: 31 instantiations
- `MeshInstance3D`: 31 instantiations
- `StandardMaterial3D`: 28 instantiations
- `CollisionShape3D`: 22 instantiations
- `RigidBody3D`: 18 instantiations
- `BoxShape3D`: 14 instantiations
- `Mutex`: 13 instantiations
- `BoxMesh`: 12 instantiations
- `SphereMesh`: 11 instantiations
- `HingeJoint3D`: 8 instantiations
