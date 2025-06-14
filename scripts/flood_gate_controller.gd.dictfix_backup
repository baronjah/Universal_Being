extends Node
class_name FloodGateController

var beings: Array[UniversalBeing] = []

func register_being(being: UniversalBeing) -> void:
	if not beings.has(being):
		beings.append(being)
		print("🌊 FloodGate registered: %s (%s)" % [being.being_name, being.being_uuid])

func deregister_being(being: UniversalBeing) -> void:
	beings.erase(being)
	print("🌊 FloodGate deregistered: %s" % being.being_name)

func get_all_beings() -> Array[UniversalBeing]:
	return beings

func get_beings_by_type(type: String) -> Array[UniversalBeing]:
	return beings.filter(func(b): return b.being_type == type)

func get_being_by_uuid(uuid: String) -> UniversalBeing:
	for being in beings:
		if being.being_uuid == uuid:
			return being
	return null