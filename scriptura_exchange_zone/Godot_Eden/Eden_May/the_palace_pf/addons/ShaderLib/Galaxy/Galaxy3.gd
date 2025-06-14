@tool
class_name VisualShaderNodeGalaxy3 extends VisualShaderNodeCustom

func _init():
	set_input_port_default_value(1, 5.0)  # swirl_amount
	set_input_port_default_value(2, 4.0)  # arm_count
	set_input_port_default_value(3, 0.1)  # center_size
	set_input_port_default_value(4, 0.1)  # star_density
	set_input_port_default_value(5, 5.0)  # star_spacing
	set_input_port_default_value(6, 4.0)  # radial_line_count
	set_input_port_default_value(7, Vector3(1.0, 0.5, 0.2))  # galaxy_color
	set_input_port_default_value(8, Vector3(0.0, 0.0, 0.1))  # space_color
	set_input_port_default_value(9, Vector3(1.0, 1.0, 0.8))  # inner_star_color
	set_input_port_default_value(10, Vector3(0.8, 0.8, 1.0))  # outer_star_color
	set_input_port_default_value(11, 0.5)  # color_band_sharpness
	set_input_port_default_value(12, 0.4)  # inner_star_radius
	set_input_port_default_value(13, 0.1)  # radial_line_width
	set_input_port_default_value(14, Vector3(1.0, 1.0, 1.0))  # radial_line_color

func _get_name():
	return "Galaxy3"

func _get_category():
	return "Galaxy3"

func _get_description():
	return "Generates a customizable galaxy3 shape with color controls"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_input_port_count():
	return 15

func _get_input_port_name(port):
	match port:
		0: return "uv"
		1: return "swirl_amount"
		2: return "arm_count"
		3: return "center_size"
		4: return "star_density"
		5: return "star_spacing"
		6: return "radial_line_count"
		7: return "galaxy_color"
		8: return "space_color"
		9: return "inner_star_color"
		10: return "outer_star_color"
		11: return "color_band_sharpness"
		12: return "inner_star_radius"
		13: return "radial_line_width" #radial_line_width
		14: return "radial_line_color"

func _get_input_port_type(port):
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		7, 8, 9, 10, 14: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		_: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "color"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_global_code(mode):
	return preload("Galaxy3.gdshaderinc").code

func _get_code(input_vars, output_vars, mode, type):
	var uv = "UV"
	if input_vars[0]:
		uv = input_vars[0]
	return "%s = generate_galaxy3(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);" % [
		output_vars[0], uv, input_vars[1], input_vars[2], input_vars[3], input_vars[4], input_vars[5], 
		input_vars[6], input_vars[7], input_vars[8], input_vars[9], input_vars[10], input_vars[11], input_vars[12], input_vars[13], input_vars[14]
	]

