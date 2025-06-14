# SYSTEM CONNECTIONS MAP

This document shows how different systems interact with each other through function calls.

## Universal Being System
**File:** `scripts/core/universal_being.gd`
**Functions:** 22

### Connections to Other Systems:

- No direct connections detected

---

## Floodgate Controller
**File:** `scripts/core/floodgate_controller.gd`
**Functions:** 83

### Connections to Other Systems:

- → **Asset Library**: calls `create_universal_being()`
- → **Universal Being System**: calls `connect_to()`

---

## Console Manager
**File:** `scripts/autoload/console_manager.gd`
**Functions:** 181

### Connections to Other Systems:

- → **Asset Library**: calls `_ready()`
- → **Asset Library**: calls `load_universal_being()`
- → **Astral Being Manager**: calls `_cmd_spawn_being()`
- → **Astral Being Manager**: calls `_ready()`
- → **Floodgate Controller**: calls `_ready()`
- → **Floodgate Controller**: calls `_register_node()`
- → **Floodgate Controller**: calls `first_dimensional_magic()`
- → **Floodgate Controller**: calls `get_object_statistics()`
- → **Floodgate Controller**: calls `queue_connect_universal_beings()`
- → **Floodgate Controller**: calls `queue_create_universal_being()`
- → **Floodgate Controller**: calls `queue_transform_universal_being()`
- → **Floodgate Controller**: calls `second_dimensional_magic()`
- → **Ragdoll Controller**: calls `_ready()`
- → **Ragdoll Controller**: calls `cmd_ragdoll_come_here()`
- → **Ragdoll Controller**: calls `cmd_ragdoll_drop()`
- → **Ragdoll Controller**: calls `cmd_ragdoll_organize()`
- → **Ragdoll Controller**: calls `cmd_ragdoll_patrol()`
- → **Ragdoll Controller**: calls `cmd_ragdoll_pickup_nearest()`
- → **Ragdoll Controller**: calls `get_state_info()`
- → **Ragdoll Controller**: calls `set_movement_input()`
- → **Ragdoll Controller**: calls `stand_up()`
- → **Ragdoll Controller**: calls `start_walking()`
- → **Ragdoll Controller**: calls `stop_walking()`
- → **Universal Being System**: calls `_ready()`
- → **Universal Being System**: calls `become()`
- → **Universal Being System**: calls `become_interface()`
- → **Universal Being System**: calls `connect_to()`

---

## Asset Library
**File:** `scripts/core/asset_library.gd`
**Functions:** 35

### Connections to Other Systems:

- → **Astral Being Manager**: calls `_ready()`
- → **Console Manager**: calls `_ready()`
- → **Floodgate Controller**: calls `_ready()`
- → **Floodgate Controller**: calls `approve_asset()`
- → **Floodgate Controller**: calls `queue_operation()`
- → **Floodgate Controller**: calls `reject_asset()`
- → **Floodgate Controller**: calls `set_asset_approval_required()`
- → **Ragdoll Controller**: calls `_ready()`
- → **Universal Being System**: calls `_ready()`
- → **Universal Being System**: calls `become()`
- → **Universal Being System**: calls `become_interface()`
- → **Universal Being System**: calls `set_property()`

---

## Ragdoll Controller
**File:** `copy_ragdoll_all_files/ragdoll_controller.gd`
**Functions:** 33

### Connections to Other Systems:

- No direct connections detected

---

## Astral Being Manager
**File:** `scripts/autoload/astral_being_manager.gd`
**Functions:** 19

### Connections to Other Systems:

- → **Console Manager**: calls `_print_to_console()`
- → **Console Manager**: calls `register_command()`
- → **Floodgate Controller**: calls `queue_operation()`
- → **Ragdoll Controller**: calls `_find_nearby_objects()`

---

