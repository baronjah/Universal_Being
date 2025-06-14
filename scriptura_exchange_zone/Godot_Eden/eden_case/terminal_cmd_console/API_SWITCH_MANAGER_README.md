# API Switch Manager for Eden Garden System

A comprehensive API endpoint management system with offline support and restart persistence, designed to integrate with the Eden Garden ecosystem.

## Overview

The API Switch Manager provides a robust solution for managing multiple API endpoints in the Eden Garden System, with special focus on:

1. **Offline Mode Operation**: Seamlessly transition between online and offline states while preserving user actions
2. **System Restart Persistence**: Maintain API configuration and state across system restarts
3. **Health Monitoring**: Automatically monitor endpoint health and switch to healthy alternatives when needed
4. **Custom Endpoint Management**: Create, configure, and persist custom API endpoints

The implementation consists of three core components:

- **ApiSwitchManager**: The core endpoint management system
- **EdenApiIntegration**: Integration layer between the Eden Garden System and API manager
- **ApiSwitchExample**: Demonstration of usage and integration methods

## Key Features

### Multiple Endpoint Management

- Register, update, and remove API endpoints with advanced configuration
- Prioritize endpoints for automatic fallback scenarios
- Store authentication tokens and custom headers per endpoint
- Support different timeout and connection parameters per endpoint

### Offline Synchronization

- Queue actions while offline for later execution
- Save and restore offline queues across system restarts
- Prioritize and process offline actions efficiently
- Provide cached responses for offline operation

### Health Monitoring

- Regular health checks for all registered endpoints
- Automatic fallback to healthy endpoints when needed
- Configurable retry mechanisms for transient failures
- Health status reporting via signals

### Persistent Configuration

- Save endpoint configurations to persistent storage
- Restore system state after restart
- Maintain offline queues across sessions
- Track usage statistics and session information

### API Switching During Runtime

- Switch between endpoints at any time during execution
- Support for dynamic endpoint creation and configuration
- Seamless transition for users when switching endpoints
- Preservation of in-progress operations during switches

## Usage Examples

### Basic Setup

```gdscript
# Create the API Switch Manager
var api_manager = ApiSwitchManager.new()
add_child(api_manager)

# Create the API Integration layer
var api_integration = EdenApiIntegration.new()
add_child(api_integration)

# Initialize with Eden Garden System
api_integration.initialize(api_manager, eden_garden_system)
```

### Adding Custom Endpoints

```gdscript
# Add a standard endpoint
api_manager.add_endpoint(
    "production", 
    "https://api.eden-garden.com",
    "auth_token_here",
    {"Content-Type": "application/json"},
    15.0,  # timeout
    10     # priority
)

# Add a custom endpoint through the integration layer
api_integration.create_custom_endpoint(
    "development",
    "https://dev-api.eden-garden.com"
)
```

### Switching Endpoints

```gdscript
# Direct switch through API manager
api_manager.switch_to_endpoint("backup")

# Through the integration layer
api_integration.switch_api_endpoint("custom_endpoint")
```

### Handling Online/Offline Transitions

```gdscript
# Set offline mode
api_manager.set_online_mode(false)

# Perform actions while offline
# (They will be queued automatically)
api_integration.execute_command("update_garden_state", garden_state)

# Return to online mode and process queue
api_manager.set_online_mode(true)
```

### Persisting Through Restart

```gdscript
# Before restart, save state
api_manager.save_persistent_data()

# After restart, state will be loaded automatically
# in the _ready() function
```

## API Reference

### ApiSwitchManager

**Properties:**

- `endpoints`: Dictionary of registered endpoints
- `current_endpoint`: Name of the currently selected endpoint
- `is_online`: Boolean indicating online/offline state
- `auto_fallback`: Whether to automatically switch to healthy endpoints

**Methods:**

- `add_endpoint(name, url, auth_token, headers, timeout, priority)`: Register a new endpoint
- `remove_endpoint(name)`: Remove an endpoint
- `switch_to_endpoint(name)`: Change the active endpoint
- `set_online_mode(online)`: Toggle online/offline mode
- `make_request(endpoint_path, method, body, custom_headers, use_endpoint)`: Send API request
- `save_persistent_data()`: Save configuration to persistent storage
- `check_endpoint_health(name)`: Check if an endpoint is responding

**Signals:**

- `api_switched(endpoint_name)`: Emitted when endpoint changes
- `connection_state_changed(is_online)`: Emitted when online state changes
- `api_health_changed(endpoint_name, is_healthy)`: Emitted when endpoint health changes
- `request_completed(endpoint_name, success, data)`: Emitted when request completes

### EdenApiIntegration

**Properties:**

- `api_manager`: Reference to the ApiSwitchManager
- `eden_garden`: Reference to the Eden Garden System
- `auto_sync_enabled`: Whether to automatically sync garden state
- `registered_commands`: Dictionary of registered API commands

**Methods:**

- `initialize(api_manager_node, eden_garden_node)`: Set up integration
- `register_command(name, endpoint_path, method, requires_online, permission_level)`: Add API command
- `execute_command(command_name, data, custom_headers, use_endpoint)`: Execute API command
- `sync_garden_state()`: Synchronize garden state with API
- `import_garden_state()`: Import garden state from API
- `process_offline_actions()`: Process queued offline actions
- `switch_api_endpoint(endpoint_name)`: Change the active endpoint
- `create_custom_endpoint(name, url, auth_token, headers)`: Add a custom endpoint

**Signals:**

- `api_data_received(data)`: Emitted when data is received from API
- `api_sync_completed(success)`: Emitted when sync operation completes
- `api_status_changed(status_code, message)`: Emitted when API status changes
- `api_command_processed(command_name, success)`: Emitted when command processing completes

## Integration with Eden Garden System

The API Switch Manager is designed to be seamlessly integrated with the Eden Garden System. Here's how to add API switching capabilities to your Eden Garden implementation:

1. **Add Required Signals to Eden Garden System**:
   ```gdscript
   signal system_went_offline
   signal system_went_online
   signal eden_restart_requested
   ```

2. **Initialize the API Manager and Integration Layer**:
   ```gdscript
   var api_manager = ApiSwitchManager.new()
   var api_integration = EdenApiIntegration.new()
   
   func _ready():
       add_child(api_manager)
       add_child(api_integration)
       api_integration.initialize(api_manager, self)
   ```

3. **Add API Offline/Online Methods**:
   ```gdscript
   func set_offline_mode(offline):
       var previous_state = is_offline
       is_offline = offline
       
       if is_offline and not previous_state:
           emit_signal("system_went_offline")
       elif not is_offline and previous_state:
           emit_signal("system_went_online")
   ```

4. **Add API Switch Methods**:
   ```gdscript
   func switch_api_endpoint(endpoint_name):
       if api_integration and api_integration.switch_api_endpoint(endpoint_name):
           return true
       return false
   ```

5. **Add Signal Handlers**:
   ```gdscript
   func _on_api_switched(endpoint_name):
       current_api_endpoint = endpoint_name
       update_garden_interface()
       
   func _on_connection_state_changed(is_online):
       update_garden_interface()
   ```

## Example Usage Scenarios

1. **Multi-Environment Operation**:
   - Register endpoints for development, staging, and production
   - Switch between environments as needed during testing
   - Configure different parameters for each environment

2. **Fallback During Outages**:
   - Automatically switch to backup endpoints when primary fails
   - Queue operations that need the primary endpoint
   - Process queued operations once primary returns

3. **Offline Field Operation**:
   - Continue operation while disconnected from network
   - Queue changes to garden state
   - Synchronize changes when connectivity returns

4. **API Experimentation**:
   - Create custom endpoints for testing new API versions
   - Switch between different API implementations
   - Compare results from different endpoints

## Tips for Effective Use

1. **Endpoint Priorities**:
   - Set higher priorities for more reliable endpoints
   - Use priority 0 for test/debugging endpoints
   - Consider fast response times when assigning priorities

2. **Offline Mode Optimization**:
   - Register commands that don't require online access with `requires_online=false`
   - Provide cached responses for commonly used data
   - Limit offline operations to save storage space

3. **System Restart Handling**:
   - Call `save_persistent_data()` before planned restarts
   - Data is automatically loaded on startup
   - Test restart recovery paths in your application

4. **Health Monitoring Configuration**:
   - Customize `HEALTH_CHECK_INTERVAL` based on your needs
   - Set appropriate `MAX_RETRY_COUNT` for your environment
   - Implement custom health criteria if needed

## Conclusion

The API Switch Manager provides a comprehensive solution for API endpoint management in the Eden Garden System. By handling endpoint switching, offline mode, and restart persistence, it enables a robust and resilient API integration experience.

This implementation allows the Eden Garden System to operate in a variety of network conditions, seamlessly transition between different API endpoints, and maintain state across system restarts.