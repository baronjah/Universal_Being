# ==================================================
# UNIVERSAL BEING COMPONENT: Akashic Logger
# PURPOSE: Universal poetic logging for all actions and changes
# ==================================================

extends Component
class_name AkashicLoggerComponent

# Logger state
var last_log: Dictionary = {}

func pentagon_init() -> void:
    component_name = "akashic_logger"
    component_version = "1.0.0"
    component_description = "Universal poetic logger for the Akashic Library"

func log_action(event_type: String, message: String = "", data: Dictionary = {}) -> void:
    """Log an action to the Akashic Library in poetic, genesis style"""
    if SystemBootstrap and SystemBootstrap.is_system_ready():
        var akashic = SystemBootstrap.get_akashic_library()
        if akashic:
            # Use poetic template if message is empty
            if message == "":
                akashic.log_system_event(parent_being.being_name, event_type, data)
            else:
                var merged_data = data.duplicate()
                merged_data["message"] = message
                akashic.log_system_event(parent_being.being_name, event_type, merged_data)
            last_log = {
                "timestamp": Time.get_datetime_string_from_system(),
                "type": event_type,
                "message": message,
                "data": data
            }
            print("📚 [AkashicLogger] %s: %s" % [event_type, message])
        else:
            push_error("Akashic Library not available for logging!")
    else:
        push_error("SystemBootstrap not ready for Akashic logging!")

func get_last_log() -> Dictionary:
    return last_log 