# FUNCTION SEARCH INDEX

## 🔍 Quick Function Finder

This index provides instant access to key functions without line numbers, organized by purpose.

---

## 🎮 Universal Being Functions

### Core Transformation
- **`universal_being.gd::become(new_form)`** - Transform being into new form/type
- **`universal_being.gd::manifest(form_type)`** - Create visual representation in 3D world
- **`universal_being.gd::unmanifest()`** - Remove visual representation
- **`universal_being.gd::get_form()`** - Get current form/type
- **`universal_being.gd::set_essence(essence_data)`** - Set essence/properties

### Universal Being Creation
- **`universal_being_floodgate_integration.gd::create_universal_being()`** - Create new universal being
- **`universal_being_asset_connector.gd::connect_to_asset_library()`** - Link with asset system
- **`universal_being_visualizer.gd::update_visualization()`** - Update visual display

---

## 🌊 Floodgate Controller Functions

### Queue Management
- **`floodgate_controller.gd::queue_operation(type, data)`** - Add operation to processing queue
- **`floodgate_controller.gd::process_queue()`** - Process queued operations with rate limiting
- **`floodgate_controller.gd::get_queue_status()`** - Get current queue size and stats
- **`floodgate_controller.gd::clear_queue()`** - Clear all pending operations

### Safe Operations
- **`floodgate_controller.gd::create_node_safe(parent, scene)`** - Safely create node with protection
- **`floodgate_controller.gd::delete_node_safe(node)`** - Safely delete node with cleanup
- **`floodgate_controller.gd::load_asset_async(asset_path)`** - Load asset asynchronously

### System Control
- **`floodgate_controller.gd::set_rate_limits(limits)`** - Configure processing rate limits
- **`floodgate_controller.gd::is_overloaded()`** - Check if system is under heavy load
- **`floodgate_controller.gd::register_object(obj)`** - Register object with tracking

---

## 💻 Console System Functions

### Console Control
- **`console_manager.gd::toggle_console()`** - Show/hide console with animation
- **`console_manager.gd::setup_console_ui()`** - Create and configure console interface
- **`console_manager.gd::clear_console()`** - Clear console output display

### Command System
- **`console_manager.gd::execute_command(cmd, args)`** - Parse and execute console command
- **`console_manager.gd::register_command(name, callable)`** - Register new console command
- **`console_manager.gd::get_command_list()`** - Get list of available commands
- **`console_manager.gd::add_to_history(command)`** - Add command to history buffer

### Output Management
- **`console_manager.gd::print_output(text)`** - Display text output in console
- **`console_manager.gd::print_error(error_text)`** - Display error message
- **`console_manager.gd::print_success(success_text)`** - Display success message

---

## 📦 Asset Library Functions

### Asset Loading
- **`asset_library.gd::load_asset(asset_name)`** - Load asset from catalog by name
- **`asset_library.gd::get_asset_info(asset_name)`** - Get metadata about an asset
- **`asset_library.gd::validate_asset(asset_path)`** - Check if asset is valid and loadable

### Asset Management
- **`asset_library.gd::register_asset(name, data)`** - Add new asset to the library
- **`asset_library.gd::scan_assets(directory)`** - Scan directory for available assets
- **`asset_library.gd::get_assets_by_category(category)`** - Get all assets in a category

### Asset Creation
- **`asset_library.gd::create_preview(asset)`** - Generate preview thumbnail for asset
- **`asset_library.gd::import_asset(path)`** - Import external asset into library

---

## 🤖 Ragdoll System Functions

### Core Ragdoll Control
- **`ragdoll_controller.gd::spawn_ragdoll(position)`** - Create new ragdoll at position
- **`ragdoll_controller.gd::walk_to(target_position)`** - Make ragdoll walk to location
- **`ragdoll_controller.gd::reset_pose()`** - Reset ragdoll to default position
- **`ragdoll_controller.gd::get_physics_state()`** - Get current physics state

### Advanced Movement
- **`seven_part_ragdoll_integration.gd::initialize_ragdoll()`** - Set up seven-part ragdoll
- **`simple_ragdoll_walker.gd::start_walking(direction)`** - Begin walking movement
- **`simple_ragdoll_walker.gd::stop_walking()`** - Stop walking movement
- **`simple_ragdoll_walker.gd::balance_character()`** - Maintain balance and stability

### Physics Control
- **`ragdoll_physics_test.gd::apply_force_to_limb(limb, force)`** - Apply physics force
- **`ragdoll_debug_visualizer.gd::show_debug_info()`** - Display physics debug info
- **`ragdoll_debug_visualizer.gd::toggle_visualization()`** - Toggle debug visualization

---

## 🔧 Debug and Testing Functions

### Debug Control
- **`debug_manager.gd::toggle_debug_mode()`** - Enable/disable debug mode
- **`debug_manager.gd::show_performance_stats()`** - Display performance information
- **`universal_gizmo_system.gd::show_gizmos()`** - Show 3D manipulation gizmos
- **`universal_gizmo_system.gd::hide_gizmos()`** - Hide 3D manipulation gizmos

### System Testing
- **`universal_entity_test.gd::run_all_tests()`** - Execute all system tests
- **`startup_diagnostic.gd::check_system_health()`** - Verify system integrity
- **`integration_test.gd::test_system_connections()`** - Test inter-system communication

---

## 🎨 UI and Interface Functions

### Object Inspector
- **`universal_object_inspector.gd::inspect_object(obj)`** - Inspect object properties
- **`advanced_object_inspector.gd::show_inspector(target)`** - Show advanced inspector
- **`object_inspector.gd::update_property_display()`** - Refresh property display

### Grid Interface
- **`bryce_grid_interface.gd::create_grid()`** - Create grid interface
- **`unified_grid_list_system.gd::add_grid_item(item)`** - Add item to grid
- **`grid_list_console_bridge.gd::sync_with_console()`** - Sync grid with console

### Visual Effects
- **`visual_indicator_system.gd::show_indicator(position, type)`** - Show visual indicator
- **`dimensional_color_system.gd::set_color_theme(theme)`** - Set color theme
- **`blink_animation_controller.gd::start_blink_animation()`** - Start blinking effect

---

## 🧠 JSH Framework Functions

### Data Management
- **`jsh_database_system.gd::store_data(key, value)`** - Store data in database
- **`jsh_database_system.gd::retrieve_data(key)`** - Retrieve data from database
- **`functions_database.gd::register_function(func_data)`** - Register function metadata

### System Integration
- **`jsh_adapter.gd::connect_systems(system_a, system_b)`** - Connect JSH systems
- **`jsh_scene_tree_system.gd::manage_scene_tree()`** - Manage scene tree operations
- **`jsh_task_manager.gd::create_task(task_data)`** - Create new task

---

## 🎯 Quick Search Tips

**To find a function quickly:**
1. Use Ctrl+F to search for function name
2. Search by system prefix (e.g., "universal_being::" or "console_manager::")
3. Search by action (e.g., "create", "spawn", "toggle", "execute")
4. Search by category (e.g., "ragdoll", "debug", "asset", "ui")

**Common search patterns:**
- `::create` - Find all creation functions
- `::get_` - Find all getter functions  
- `::set_` - Find all setter functions
- `::toggle_` - Find all toggle functions
- `debug` - Find all debug-related functions
- `spawn` - Find all spawn functions

---

**Total Functions Indexed:** 4,726 across 238 scripts
**Last Updated:** 2025-05-30