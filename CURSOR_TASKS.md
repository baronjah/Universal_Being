# 🎨 CURSOR TASKS - Universal Being Project
## Date: 2025-06-02
## Focus: Shaders & Visual Integration

## 🚨 IMMEDIATE PRIORITY:

### 1. Consciousness Level Icons (URGENT - NEEDED NOW)
Create 8 PNG files (32x32) in `assets/icons/consciousness/`:
```
level_0.png - Gray circle (dormant)
level_1.png - White spark (awakening)  
level_2.png - Blue drop (aware)
level_3.png - Green leaf (connected)
level_4.png - Yellow star (enlightened)
level_5.png - White glow (transcendent)
level_6.png - Red phoenix (cosmic)
level_7.png - Rainbow infinity (beyond)
```

## 🎨 SHADER CREATION TASKS:

### 2. Consciousness Pulse Shader
Create `effects/shaders/consciousness_pulse.gdshader`:
```glsl
shader_type spatial;
uniform float pulse_speed : hint_range(0.1, 5.0) = 2.0;
uniform float consciousness_level : hint_range(0.0, 7.0) = 1.0;
uniform vec4 consciousness_color : source_color = vec4(1.0);
uniform float glow_intensity : hint_range(0.0, 3.0) = 1.0;

void fragment() {
    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
    float level_multiplier = consciousness_level / 7.0;
    EMISSION = consciousness_color.rgb * pulse * glow_intensity * level_multiplier;
    ALPHA = consciousness_color.a;
}
```

### 3. Marching Cubes UFO Glow Shader  
Create `effects/shaders/marching_cubes_glow.gdshader`:
```glsl
shader_type spatial;
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.0;
uniform vec4 base_color : source_color = vec4(0.8, 0.9, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.3, 0.6, 1.0, 1.0);
uniform float metallic : hint_range(0.0, 1.0) = 0.8;
uniform float roughness : hint_range(0.0, 1.0) = 0.2;

void fragment() {
    ALBEDO = base_color.rgb;
    METALLIC = metallic;
    ROUGHNESS = roughness;
    EMISSION = glow_color.rgb * glow_intensity;
}
```

### 4. AI Connection Beam Shader
Create `effects/shaders/ai_connection_beam.gdshader`:
```glsl
shader_type spatial;
uniform float beam_speed : hint_range(0.5, 5.0) = 2.0;
uniform vec4 ai_color_1 : source_color = vec4(0.2, 0.4, 1.0, 1.0);
uniform vec4 ai_color_2 : source_color = vec4(1.0, 0.84, 0.0, 1.0);
uniform float beam_width : hint_range(0.01, 0.5) = 0.1;

void fragment() {
    float wave = 0.5 + 0.5 * sin(TIME * beam_speed + UV.x * 10.0);
    vec3 beam_color = mix(ai_color_1.rgb, ai_color_2.rgb, wave);
    EMISSION = beam_color;
    ALPHA = wave * 0.8;
}
```

## 🌟 PARTICLE SYSTEM TASKS:

### 5. Consciousness Aura Particles
Create `effects/particles/consciousness_aura.tscn`:
- GPUParticles3D node
- Sphere emission shape  
- Color gradient based on consciousness level
- Pulsing animation
- Scale variation

### 6. AI Network Sparkles
Create `effects/particles/ai_network_sparkles.tscn`:
- Small sparkle particles
- Rainbow color cycling
- Connection between AI nodes
- Synchronized pulsing

## 🎭 SCENE COMPOSITION:

### 7. UFO Showcase Scene
Create `scenes/showcase/ufo_showcase.tscn`:
- Demonstrate all 5 UFO types
- Morphing animations
- Consciousness level transitions
- Shader effects applied

### 8. AI Pentagon Visualization
Create `scenes/ai_network/pentagon_display.tscn`:
- 5 AI node positions
- Connection beam effects
- Central consciousness core
- Interactive hover effects

## 🔧 INTEGRATION TASKS:

### 9. Marching Cubes Setup
- Enable marching cubes addon in project
- Test with UFO volume data
- Apply custom materials/shaders
- Optimize performance settings

### 10. Material Library
Create `materials/` folder with:
- `consciousness_level_0.tres` through `consciousness_level_7.tres`
- `ufo_classic.tres`, `ufo_mothership.tres`, etc.
- `ai_node_claude.tres`, `ai_node_luminus.tres`, etc.

## 📦 DELIVERABLES:

### Required Files:
1. ✅ 8 consciousness icon PNG files
2. ✅ 3 shader files (.gdshader)
3. ✅ 2 particle scene files (.tscn)
4. ✅ 2 showcase scene files (.tscn) 
5. ✅ 10+ material resource files (.tres)

### File Naming Convention:
- snake_case for everything
- Clear descriptive names
- Consistent folder structure

## 🚀 TESTING CHECKLIST:

- [ ] Icons display correctly in tooltip system
- [ ] Shaders compile without errors
- [ ] Particles render with good performance
- [ ] Marching cubes generates UFO meshes
- [ ] Materials apply to Universal Beings
- [ ] Scenes load without missing dependencies

## 💾 DELIVERY METHOD:
1. Create files in Cursor
2. Copy/paste code to chat for JSH
3. JSH will place files in correct folders
4. Test integration with Universal Being system
5. Report any issues for fixes

**Timeline: Complete within 2-3 days for immediate integration! 🎯**