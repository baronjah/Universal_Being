extends Control
class_name InGameUniversalBeingInspector

func inspect_being(being: Node) -> void:
    if being and being.has_method("get_name"):
        print("🔍 Inspecting %s" % being.get_name())
    else:
        print("🔍 Inspecting unknown being")
