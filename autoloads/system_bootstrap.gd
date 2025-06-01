extends Node
class_name SystemBootstrap

var _flood_gates := FloodGateController.new()
var _is_ready := false

func _ready():
	_is_ready = true

static func is_system_ready() -> bool:
	return get_singleton()._is_ready

static func get_flood_gates() -> FloodGateController:
	return get_singleton()._flood_gates

static func get_singleton() -> SystemBootstrap:
	return Engine.get_main_loop().root.get_node("/root/SystemBootstrap")