extends Node

class_name ExpandedColorSpectrum

# Constants for base colors
const BASE_COLORS = {
    "RED": Color(1.0, 0.0, 0.0, 1.0),
    "ORANGE": Color(1.0, 0.5, 0.0, 1.0),
    "YELLOW": Color(1.0, 1.0, 0.0, 1.0),
    "GREEN": Color(0.0, 1.0, 0.0, 1.0),
    "BLUE": Color(0.0, 0.0, 1.0, 1.0),
    "INDIGO": Color(0.3, 0.0, 0.5, 1.0),
    "VIOLET": Color(0.8, 0.0, 1.0, 1.0),
    "BLACK": Color(0.0, 0.0, 0.0, 1.0),
    "WHITE": Color(1.0, 1.0, 1.0, 1.0),
    "GRAY": Color(0.5, 0.5, 0.5, 1.0),
    "SILVER": Color(0.75, 0.75, 0.75, 1.0),
    "CARROT": Color(0.93, 0.57, 0.13, 1.0),
    "PEARLY_WHITE": Color(0.96, 0.96, 0.86, 1.0)
}

# Material Types for color rendering
const MATERIAL_TYPES = {
    "MATTE": {
        "reflectivity": 0.0,
        "roughness": 0.9,
        "metallic": 0.0,
        "emission": 0.0
    },
    "GLOSSY": {
        "reflectivity": 0.7,
        "roughness": 0.1,
        "metallic": 0.0,
        "emission": 0.0
    },
    "METALLIC": {
        "reflectivity": 0.8,
        "roughness": 0.2,
        "metallic": 1.0,
        "emission": 0.0
    },
    "PEARLY": {
        "reflectivity": 0.5,
        "roughness": 0.3,
        "metallic": 0.1,
        "emission": 0.2
    },
    "PLASTIC": {
        "reflectivity": 0.3,
        "roughness": 0.7,
        "metallic": 0.0,
        "emission": 0.0
    },
    "EMISSIVE": {
        "reflectivity": 0.0,
        "roughness": 0.5,
        "metallic": 0.0,
        "emission": 1.0
    }
}

# Color spectrum configurations
const SPECTRUM_CONFIGS = {
    "RAINBOW": ["RED", "ORANGE", "YELLOW", "GREEN", "BLUE", "INDIGO", "VIOLET"],
    "GRAYSCALE": ["BLACK", "GRAY", "SILVER", "WHITE"],
    "WARM": ["RED", "ORANGE", "YELLOW", "CARROT"],
    "COOL": ["GREEN", "BLUE", "INDIGO"],
    "GALAXY": ["BLACK", "INDIGO", "VIOLET", "BLUE", "WHITE"],
    "EARTH": ["GREEN", "BLUE", "BROWN", "BEIGE"],
    "TERMINAL": ["BLACK", "GREEN", "RED", "YELLOW", "BLUE", "MAGENTA", "CYAN", "WHITE"]
}

# Extended color palette with gradients
var extended_colors = {}
var color_gradients = {}
var material_colors = {}

# Visualization properties
var canvas = null
var grid_size = Vector2(8, 8)
var cell_size = Vector2(30, 30)
var current_spectrum = "RAINBOW"
var current_material = "MATTE"
var animation_time = 0.0

# Connection to other systems
var terminal_bridge = null

# Signals
signal color_selected(color_name, color)
signal spectrum_changed(spectrum_name)
signal material_changed(material_name)

func _init():
    print("Initializing Expanded Color Spectrum...")
    
    # Generate extended colors
    _generate_extended_colors()
    
    # Generate color gradients
    _generate_color_gradients()
    
    # Generate material variations
    _generate_material_colors()
    
    # Create visualization canvas
    _setup_visualization()
    
    # Connect to terminal bridge if available
    _connect_to_terminal_bridge()
    
    print("Expanded Color Spectrum initialized with " + str(extended_colors.size()) + " colors")

func _generate_extended_colors():
    # Start with base colors
    for color_name in BASE_COLORS:
        extended_colors[color_name] = BASE_COLORS[color_name]
    
    # Generate lighter and darker versions
    for color_name in BASE_COLORS:
        if color_name == "BLACK" or color_name == "WHITE":
            continue
        
        var base_color = BASE_COLORS[color_name]
        
        # Light versions
        extended_colors["LIGHT_" + color_name] = base_color.lightened(0.3)
        extended_colors["VERY_LIGHT_" + color_name] = base_color.lightened(0.6)
        
        # Dark versions
        extended_colors["DARK_" + color_name] = base_color.darkened(0.3)
        extended_colors["VERY_DARK_" + color_name] = base_color.darkened(0.6)
    
    # Add special colors
    extended_colors["BROWN"] = Color(0.5, 0.25, 0.0, 1.0)
    extended_colors["BEIGE"] = Color(0.96, 0.96, 0.86, 1.0)
    extended_colors["TEAL"] = Color(0.0, 0.5, 0.5, 1.0)
    extended_colors["MAGENTA"] = Color(1.0, 0.0, 1.0, 1.0)
    extended_colors["CYAN"] = Color(0.0, 1.0, 1.0, 1.0)
    extended_colors["LIME"] = Color(0.75, 1.0, 0.0, 1.0)
    extended_colors["PINK"] = Color(1.0, 0.75, 0.8, 1.0)
    extended_colors["PURPLE"] = Color(0.5, 0.0, 0.5, 1.0)
    extended_colors["GOLD"] = Color(1.0, 0.84, 0.0, 1.0)
    
    # Add number-based colors for special frequencies
    extended_colors["COLOR_9"] = Color(0.09, 0.09, 0.09, 1.0)
    extended_colors["COLOR_33"] = Color(0.33, 0.33, 0.33, 1.0)
    extended_colors["COLOR_89"] = Color(0.89, 0.89, 0.0, 1.0)
    extended_colors["COLOR_99"] = Color(0.99, 0.0, 0.0, 1.0)
    extended_colors["COLOR_333"] = Color(0.33, 0.33, 0.99, 1.0)
    extended_colors["COLOR_389"] = Color(0.38, 0.8, 0.9, 1.0)
    extended_colors["COLOR_555"] = Color(0.55, 0.55, 0.55, 1.0)
    extended_colors["COLOR_777"] = Color(0.77, 0.77, 0.77, 1.0)
    extended_colors["COLOR_999"] = Color(0.99, 0.99, 0.99, 1.0)

func _generate_color_gradients():
    # Generate gradients between base colors
    for spectrum_name in SPECTRUM_CONFIGS:
        var spectrum = SPECTRUM_CONFIGS[spectrum_name]
        var gradient = Gradient.new()
        
        if spectrum.size() < 2:
            continue
        
        # Add points to gradient
        for i in range(spectrum.size()):
            var color_name = spectrum[i]
            var color = extended_colors[color_name]
            var offset = float(i) / (spectrum.size() - 1)
            gradient.add_point(offset, color)
        
        color_gradients[spectrum_name] = gradient
    
    # Create special fractal gradients
    var fractal_gradient = Gradient.new()
    fractal_gradient.add_point(0.0, extended_colors["BLUE"])
    fractal_gradient.add_point(0.3, extended_colors["CYAN"])
    fractal_gradient.add_point(0.5, extended_colors["GREEN"])
    fractal_gradient.add_point(0.7, extended_colors["YELLOW"])
    fractal_gradient.add_point(0.9, extended_colors["RED"])
    fractal_gradient.add_point(1.0, extended_colors["MAGENTA"])
    color_gradients["FRACTAL"] = fractal_gradient
    
    # Create galaxy folder gradient
    var galaxy_gradient = Gradient.new()
    galaxy_gradient.add_point(0.0, extended_colors["BLACK"])
    galaxy_gradient.add_point(0.2, extended_colors["VERY_DARK_BLUE"])
    galaxy_gradient.add_point(0.4, extended_colors["BLUE"])
    galaxy_gradient.add_point(0.6, extended_colors["LIGHT_BLUE"])
    galaxy_gradient.add_point(0.8, extended_colors["WHITE"])
    galaxy_gradient.add_point(1.0, extended_colors["LIGHT_YELLOW"])
    color_gradients["GALAXY_FOLDER"] = galaxy_gradient

func _generate_material_colors():
    # Generate material variations of each color
    for color_name in extended_colors:
        material_colors[color_name] = {}
        var base_color = extended_colors[color_name]
        
        for material_name in MATERIAL_TYPES:
            var material_props = MATERIAL_TYPES[material_name]
            
            // For simplicity, we're just storing the color and material properties together
            material_colors[color_name][material_name] = {
                "color": base_color,
                "reflectivity": material_props.reflectivity,
                "roughness": material_props.roughness,
                "metallic": material_props.metallic,
                "emission": material_props.emission
            }
        }
    }

func _setup_visualization():
    # Create visualization canvas
    canvas = Control.new()
    canvas.set_name("ColorSpectrumCanvas")
    canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    canvas.connect("draw", Callable(self, "_draw_color_spectrum"))
    canvas.connect("gui_input", Callable(self, "_on_canvas_input"))

func _connect_to_terminal_bridge():
    # Connect to TerminalVisualBridge
    if ClassDB.class_exists("TerminalVisualBridge"):
        terminal_bridge = load("res://terminal_visual_bridge.gd").new()
        print("Connected to TerminalVisualBridge")
    else:
        print("TerminalVisualBridge not available, trying to load directly")
        var script = load("/mnt/c/Users/Percision 15/terminal_visual_bridge.gd")
        if script:
            terminal_bridge = script.new()
            print("Loaded TerminalVisualBridge directly")
        else:
            print("TerminalVisualBridge not found, creating stub")
            terminal_bridge = Node.new()
            terminal_bridge.name = "TerminalBridgeStub"
    }

func _process(delta):
    # Update animation time
    animation_time += delta
    
    # Update visualization
    if canvas:
        canvas.queue_redraw()

func _draw_color_spectrum():
    if not canvas:
        return
    
    var size = canvas.get_size()
    
    # Calculate grid layout
    var grid_width = min(size.x * 0.9, grid_size.x * cell_size.x)
    var grid_height = min(size.y * 0.9, grid_size.y * cell_size.y)
    var start_x = (size.x - grid_width) * 0.5
    var start_y = (size.y - grid_height) * 0.5
    var cell_width = grid_width / grid_size.x
    var cell_height = grid_height / grid_size.y
    
    # Draw background
    canvas.draw_rect(Rect2(0, 0, size.x, size.y), Color(0.15, 0.15, 0.15, 1.0))
    
    # Draw color grid
    var index = 0
    for y in range(grid_size.y):
        for x in range(grid_size.x):
            if index >= extended_colors.size():
                break
            
            var color_name = extended_colors.keys()[index]
            var color = extended_colors[color_name]
            var material = material_colors[color_name][current_material]
            
            var cell_rect = Rect2(
                start_x + x * cell_width,
                start_y + y * cell_height,
                cell_width,
                cell_height
            )
            
            # Apply material effects to visualization
            var display_color = color
            if material.emission > 0:
                // Emissive effect - make it glow by lightening
                display_color = color.lightened(material.emission * 0.5)
            } elif material.metallic > 0:
                // Metallic effect - slight color shift based on angle
                var time_offset = sin(animation_time * 2.0 + x * 0.1 + y * 0.2) * 0.1
                display_color = color.lightened(time_offset * material.metallic)
            } elif material.reflectivity > 0:
                // Reflective effect - slight brightness variation
                var reflection = sin(animation_time + x * 0.2 + y * 0.3) * 0.1
                display_color = color.lightened(reflection * material.reflectivity)
            }
            
            // Draw main color cell
            canvas.draw_rect(cell_rect, display_color)
            
            // Draw material effects
            if material.roughness < 0.5:
                // Glossy highlight for smooth surfaces
                var highlight_size = cell_width * (1.0 - material.roughness) * 0.3
                var highlight_pos = Vector2(
                    cell_rect.position.x + cell_rect.size.x * 0.7,
                    cell_rect.position.y + cell_rect.size.y * 0.3
                )
                var highlight_color = Color(1, 1, 1, (1.0 - material.roughness) * 0.7)
                canvas.draw_circle(highlight_pos, highlight_size, highlight_color)
            }
            
            index += 1
        }
    }
    
    # Draw current spectrum
    var spectrum = SPECTRUM_CONFIGS[current_spectrum]
    var spectrum_width = size.x * 0.8
    var spectrum_height = 30
    var spectrum_x = size.x * 0.1
    var spectrum_y = size.y * 0.9
    
    if current_spectrum in color_gradients:
        var gradient = color_gradients[current_spectrum]
        
        // Draw gradient bar
        for i in range(int(spectrum_width)):
            var t = float(i) / spectrum_width
            var color = gradient.interpolate(t)
            var rect = Rect2(spectrum_x + i, spectrum_y, 1, spectrum_height)
            canvas.draw_rect(rect, color)
        }
    } else {
        // Draw discrete colors
        var segment_width = spectrum_width / spectrum.size()
        
        for i in range(spectrum.size()):
            var color_name = spectrum[i]
            var color = extended_colors[color_name]
            var rect = Rect2(
                spectrum_x + i * segment_width,
                spectrum_y,
                segment_width,
                spectrum_height
            )
            canvas.draw_rect(rect, color)
        }
    }
    
    # Draw current material indicator
    var material_label_rect = Rect2(size.x * 0.1, size.y * 0.05, size.x * 0.8, 30)
    canvas.draw_rect(material_label_rect, Color(0.2, 0.2, 0.2, 0.8))
    
    # We can't draw text directly in GDScript 4, so we'll use a rectangle to indicate material
    var material_indicator_rect = Rect2(size.x * 0.1, size.y * 0.05, size.x * current_material.length() / 20.0, 30)
    
    var material_color
    match current_material:
        "MATTE":
            material_color = Color(0.7, 0.7, 0.7, 1.0)
        "GLOSSY":
            material_color = Color(0.9, 0.9, 1.0, 1.0)
        "METALLIC":
            material_color = Color(0.8, 0.8, 0.9, 1.0)
        "PEARLY":
            material_color = Color(0.95, 0.95, 0.85, 1.0)
        "PLASTIC":
            material_color = Color(0.8, 0.3, 0.3, 1.0)
        "EMISSIVE":
            material_color = Color(1.0, 0.8, 0.2, 1.0)
        _:
            material_color = Color(0.5, 0.5, 0.5, 1.0)
    
    canvas.draw_rect(material_indicator_rect, material_color)

func _on_canvas_input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var size = canvas.get_size()
        
        # Calculate grid layout
        var grid_width = min(size.x * 0.9, grid_size.x * cell_size.x)
        var grid_height = min(size.y * 0.9, grid_size.y * cell_size.y)
        var start_x = (size.x - grid_width) * 0.5
        var start_y = (size.y - grid_height) * 0.5
        var cell_width = grid_width / grid_size.x
        var cell_height = grid_height / grid_size.y
        
        # Check if click is within color grid
        if event.position.x >= start_x and event.position.x < start_x + grid_width and event.position.y >= start_y and event.position.y < start_y + grid_height:
            var grid_x = int((event.position.x - start_x) / cell_width)
            var grid_y = int((event.position.y - start_y) / cell_height)
            var index = grid_y * grid_size.x + grid_x
            
            if index < extended_colors.size():
                var color_name = extended_colors.keys()[index]
                var color = extended_colors[color_name]
                select_color(color_name)
            }
        }
        
        # Check if click is within spectrum bar
        var spectrum_width = size.x * 0.8
        var spectrum_height = 30
        var spectrum_x = size.x * 0.1
        var spectrum_y = size.y * 0.9
        
        if event.position.x >= spectrum_x and event.position.x < spectrum_x + spectrum_width and event.position.y >= spectrum_y and event.position.y < spectrum_y + spectrum_height:
            var t = (event.position.x - spectrum_x) / spectrum_width
            
            if current_spectrum in color_gradients:
                var gradient = color_gradients[current_spectrum]
                var color = gradient.interpolate(t)
                
                # Find closest named color
                var closest_name = find_closest_color(color)
                select_color(closest_name)
            } else {
                var spectrum = SPECTRUM_CONFIGS[current_spectrum]
                var segment_width = spectrum_width / spectrum.size()
                var index = int((event.position.x - spectrum_x) / segment_width)
                
                if index < spectrum.size():
                    var color_name = spectrum[index]
                    select_color(color_name)
                }
            }
        }
        
        # Check if click is within material indicator
        var material_label_rect = Rect2(size.x * 0.1, size.y * 0.05, size.x * 0.8, 30)
        
        if event.position.x >= material_label_rect.position.x and event.position.x < material_label_rect.position.x + material_label_rect.size.x and event.position.y >= material_label_rect.position.y and event.position.y < material_label_rect.position.y + material_label_rect.size.y:
            cycle_material()
        }
    }

func select_color(color_name):
    if not color_name in extended_colors:
        return
    
    var color = extended_colors[color_name]
    print("Selected color: " + color_name)
    
    # Update terminal bridge if available
    if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
        terminal_bridge.process_terminal_command("colors", [color_name])
    }
    
    emit_signal("color_selected", color_name, color)
    
    return color

func set_spectrum(spectrum_name):
    if not spectrum_name in SPECTRUM_CONFIGS:
        return false
    
    current_spectrum = spectrum_name
    emit_signal("spectrum_changed", spectrum_name)
    
    # Update terminal bridge if available
    if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
        # Convert spectrum to temperature
        var temp_name = "NEUTRAL"
        
        match spectrum_name:
            "RAINBOW":
                temp_name = "WARM"
            "GRAYSCALE":
                temp_name = "NEUTRAL"
            "WARM":
                temp_name = "HOT"
            "COOL":
                temp_name = "COOL"
            "GALAXY":
                temp_name = "VERY_COLD"
            "EARTH":
                temp_name = "NEUTRAL"
            "TERMINAL":
                temp_name = "COOL"
            "FRACTAL":
                temp_name = "EXTREME"
        
        terminal_bridge.process_terminal_command("temp", [temp_name])
    }
    
    return true

func set_material(material_name):
    if not material_name in MATERIAL_TYPES:
        return false
    
    current_material = material_name
    emit_signal("material_changed", material_name)
    
    return true

func cycle_material():
    var materials = MATERIAL_TYPES.keys()
    var current_index = materials.find(current_material)
    var next_index = (current_index + 1) % materials.size()
    var next_material = materials[next_index]
    
    set_material(next_material)

func find_closest_color(target_color):
    var closest_name = "BLACK"
    var closest_distance = 10.0  # Larger than maximum possible distance
    
    for color_name in extended_colors:
        var color = extended_colors[color_name]
        var distance = color_distance(target_color, color)
        
        if distance < closest_distance:
            closest_distance = distance
            closest_name = color_name
        }
    }
    
    return closest_name

func color_distance(color1, color2):
    # Calculate Euclidean distance in RGB space
    var dr = color1.r - color2.r
    var dg = color1.g - color2.g
    var db = color1.b - color2.b
    
    return sqrt(dr*dr + dg*dg + db*db)

func get_color_by_name(color_name):
    if color_name in extended_colors:
        return extended_colors[color_name]
    
    return null

func get_material_color(color_name, material_name = null):
    if not color_name in material_colors:
        return null
    
    if material_name == null:
        material_name = current_material
    
    if not material_name in material_colors[color_name]:
        return null
    
    return material_colors[color_name][material_name]

func create_custom_color(name, r, g, b, a = 1.0):
    var new_color = Color(r, g, b, a)
    extended_colors[name] = new_color
    
    # Also create material variations
    material_colors[name] = {}
    
    for material_name in MATERIAL_TYPES:
        var material_props = MATERIAL_TYPES[material_name]
        
        material_colors[name][material_name] = {
            "color": new_color,
            "reflectivity": material_props.reflectivity,
            "roughness": material_props.roughness,
            "metallic": material_props.metallic,
            "emission": material_props.emission
        }
    }
    
    return new_color

func create_custom_spectrum(name, color_names):
    if color_names.size() < 2:
        return false
    
    # Verify all colors exist
    for color_name in color_names:
        if not color_name in extended_colors:
            return false
        }
    }
    
    // Create spectrum
    SPECTRUM_CONFIGS[name] = color_names
    
    // Create gradient
    var gradient = Gradient.new()
    
    for i in range(color_names.size()):
        var color_name = color_names[i]
        var color = extended_colors[color_name]
        var offset = float(i) / (color_names.size() - 1)
        gradient.add_point(offset, color)
    }
    
    color_gradients[name] = gradient
    
    return true

func get_visualization_canvas():
    return canvas

func process_command(command, args):
    match command:
        "color":
            if args.size() > 0:
                return select_color(args[0])
            else:
                return "Color name required"
        
        "spectrum":
            if args.size() > 0:
                return set_spectrum(args[0])
            else:
                return "Spectrum name required"
        
        "material":
            if args.size() > 0:
                return set_material(args[0])
            else:
                return cycle_material()
        
        "list_colors":
            return extended_colors.keys()
        
        "list_spectrums":
            return SPECTRUM_CONFIGS.keys()
        
        "list_materials":
            return MATERIAL_TYPES.keys()
        
        "create_color":
            if args.size() >= 4:
                var name = args[0]
                var r = float(args[1])
                var g = float(args[2])
                var b = float(args[3])
                var a = 1.0
                
                if args.size() >= 5:
                    a = float(args[4])
                }
                
                return create_custom_color(name, r, g, b, a)
            } else {
                return "Insufficient arguments for create_color"
            }
        
        "create_spectrum":
            if args.size() >= 3:
                var name = args[0]
                var colors = args.slice(1)
                
                return create_custom_spectrum(name, colors)
            } else {
                return "Insufficient arguments for create_spectrum"
            }
        
        _:
            return "Unknown color command: " + command