@tool
class_name VisualShaderNodeGalaxy extends VisualShaderNodeCustom

func _init():
	set_input_port_default_value(1, 5.0)  # swirl_amount
	set_input_port_default_value(2, 4.0)  # arm_count
	set_input_port_default_value(3, 0.1)  # center_size
	set_input_port_default_value(4, 0.1)  # star_density
	set_input_port_default_value(5, 3.0)  # star_spacing
	set_input_port_default_value(6, 4.0)  # radial_line_count

func _get_name():
	return "Galaxy"

func _get_category():
	return "Galaxy"

func _get_description():
	return "Generates a customizable galaxy shape"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_input_port_count():
	return 7

func _get_input_port_name(port):
	match port:
		0: return "uv"
		1: return "swirl_amount"
		2: return "arm_count"
		3: return "center_size"
		4: return "star_density"
		5: return "star_spacing"
		6: return "radial_line_count"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		_: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "color"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_global_code(mode):
	return preload("Galaxy.gdshaderinc").code



func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"  # Use the built-in UV variable if available
	if input_vars[0]:
		uv = input_vars[0]
	return "%s = generate_galaxy(%s, %s, %s, %s, %s, %s, %s);" % [
		output_vars[0],
		uv,
		input_vars[1],
		input_vars[2],
		input_vars[3],
		input_vars[4],
		input_vars[5],
		input_vars[6]
	]
