@tool
class_name VisualShaderNodeGalaxy4 extends VisualShaderNodeCustom

func _init():
	set_input_port_default_value(1, 5.0)  # swirl_amount
	set_input_port_default_value(2, 4.0)  # arm_count
	set_input_port_default_value(3, 0.1)  # arm_width
	set_input_port_default_value(4, 0.1)  # star_density
	set_input_port_default_value(5, 512.0)  # star_size
	set_input_port_default_value(6, Vector3(0.0, 0.0, 0.0))  # arm_color
	set_input_port_default_value(7, Vector3(0.0, 0.0, 0.0))  # space_color
	set_input_port_default_value(8, Vector3(1.0, 1.0, 1.0))  # star_color
	set_input_port_default_value(9, 0.5)  # circle_radius
	set_input_port_default_value(10, Vector3(0.0, 0.0, 0.0))  # background color
	set_input_port_default_value(11, 0.01) # your_seed_value

func _get_name():
	return "Galaxy4"

func _get_category():
	return "Galaxy4"

func _get_description():
	return "Generates a customizable galaxy4 shape with radial arms and stars"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_input_port_count():
	return 12

func _get_input_port_name(port):
	match port:
		0: return "uv"
		1: return "swirl_amount"
		2: return "arm_count"
		3: return "arm_width"
		4: return "star_density"
		5: return "star_size"
		6: return "arm_color"
		7: return "space_color"
		8: return "star_color"
		9: return "circle_radius"
		10: return "background_color"
		11: return "your_seed_value"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		6, 7, 8, 10: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		_: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "color"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_global_code(mode):
	return preload("Galaxy4.gdshaderinc").code

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	if input_vars[0]:
		uv = input_vars[0]
	return "%s = generate_galaxy4(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);" % [
		output_vars[0], uv, input_vars[1], input_vars[2], input_vars[3], input_vars[4], input_vars[5], 
		input_vars[6], input_vars[7], input_vars[8], input_vars[9], input_vars[10], input_vars[11]
	]
